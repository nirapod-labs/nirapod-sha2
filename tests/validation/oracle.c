/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle.c
 * ========
 *
 * Client side of the oracle protocol (oracle-protocol.h). The runner
 * starts one child per independent implementation and asks it one request
 * at a time, so the runner and the oracles never share symbols.
 */

#define _POSIX_C_SOURCE 200809L

#include "oracle.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "oracle-protocol.h"

struct oracle {
    pid_t pid;
    int to;
    int from;
    unsigned mask;
    char identity[256];
};

static int send_all(int fd, const uint8_t *p, size_t n)
{
    while (n > 0) {
        ssize_t got = write(fd, p, n);

        if (got < 0) {
            if (errno == EINTR) {
                continue;
            }
            return -1;
        }
        p += (size_t)got;
        n -= (size_t)got;
    }
    return 0;
}

static int recv_all(int fd, uint8_t *p, size_t n)
{
    while (n > 0) {
        ssize_t got = read(fd, p, n);

        if (got < 0) {
            if (errno == EINTR) {
                continue;
            }
            return -1;
        }
        if (got == 0) {
            return -1;
        }
        p += (size_t)got;
        n -= (size_t)got;
    }
    return 0;
}

static void put32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16);
    p[3] = (uint8_t)(v >> 24);
}

/* Keep one oracle's pipes out of the children started for the others:
 * an inherited write end would keep the first oracle from seeing EOF. */
static void set_cloexec(int fd)
{
    int flags = fcntl(fd, F_GETFD);

    if (flags >= 0) {
        fcntl(fd, F_SETFD, flags | FD_CLOEXEC);
    }
}

oracle *oracle_start(const char *path)
{
    int to_child[2], from_child[2];
    struct oracle *o;
    char line[512];
    size_t n = 0;
    unsigned mask = 0;
    char identity[256] = "";

    if (pipe(to_child) != 0 || pipe(from_child) != 0) {
        return NULL;
    }
    set_cloexec(to_child[0]);
    set_cloexec(to_child[1]);
    set_cloexec(from_child[0]);
    set_cloexec(from_child[1]);
    o = calloc(1, sizeof *o);
    if (o == NULL) {
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        return NULL;
    }

    o->pid = fork();
    if (o->pid < 0) {
        free(o);
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        return NULL;
    }
    if (o->pid == 0) {
        if (dup2(to_child[0], STDIN_FILENO) < 0 ||
            dup2(from_child[1], STDOUT_FILENO) < 0) {
            _exit(127);
        }
        close(to_child[0]);
        close(to_child[1]);
        close(from_child[0]);
        close(from_child[1]);
        execl(path, path, (char *)NULL);
        _exit(127);
    }

    close(to_child[0]);
    close(from_child[1]);
    o->to = to_child[1];
    o->from = from_child[0];
    signal(SIGPIPE, SIG_IGN);

    while (n + 1 < sizeof line) {
        ssize_t got = read(o->from, line + n, 1);

        if (got < 0 && errno == EINTR) {
            continue;
        }
        if (got != 1) {
            break;
        }
        if (line[n++] == '\n') {
            break;
        }
    }
    line[n] = '\0';
    if (sscanf(line, ORACLE_BANNER " %x %255[^\n]", &mask, identity) < 1) {
        close(o->to);
        close(o->from);
        kill(o->pid, SIGTERM);
        waitpid(o->pid, NULL, 0);
        free(o);
        return NULL;
    }
    o->mask = mask;
    snprintf(o->identity, sizeof o->identity, "%s", identity[0] ? identity : "unnamed");
    return o;
}

void oracle_stop(oracle *o)
{
    int status;

    if (o == NULL) {
        return;
    }
    close(o->to);
    waitpid(o->pid, &status, 0);
    close(o->from);
    free(o);
}

const char *oracle_identity(const oracle *o)
{
    return o->identity;
}

static int response(oracle *o, uint8_t *out, size_t *out_len)
{
    uint8_t head[2];

    if (recv_all(o->from, head, sizeof head) != 0) {
        return -1;
    }
    if (head[0] == ORACLE_STATUS_UNSUPPORTED) {
        *out_len = 0;
        return 0;
    }
    if (head[0] != ORACLE_STATUS_OK || head[1] > ORACLE_MAX_DIGEST) {
        *out_len = 0;
        return -1;
    }
    if (recv_all(o->from, out, head[1]) != 0) {
        return -1;
    }
    *out_len = head[1];
    return 1;
}

int oracle_hash(oracle *o, unsigned alg, const uint8_t *in, size_t len, uint8_t *out,
                size_t *out_len)
{
    uint8_t head[ORACLE_HEADER_BYTES];

    if (alg > 5 || len > UINT32_MAX || !ORACLE_SUPPORTS(o->mask, alg)) {
        *out_len = 0;
        return 0;
    }
    memset(head, 0, sizeof head);
    head[0] = ORACLE_OP_HASH;
    head[1] = (uint8_t)alg;
    put32(head + 4, 0);
    put32(head + 8, (uint32_t)len);
    if (send_all(o->to, head, sizeof head) != 0 ||
        (len != 0 && send_all(o->to, in, len) != 0)) {
        return -1;
    }
    return response(o, out, out_len);
}

int oracle_hmac(oracle *o, unsigned alg, const uint8_t *key, size_t key_len,
                const uint8_t *msg, size_t msg_len, uint8_t *out, size_t *out_len)
{
    uint8_t head[ORACLE_HEADER_BYTES];

    if (alg > 1 || key_len > UINT32_MAX || msg_len > UINT32_MAX ||
        !ORACLE_SUPPORTS_HMAC(o->mask, alg)) {
        *out_len = 0;
        return 0;
    }
    memset(head, 0, sizeof head);
    head[0] = ORACLE_OP_HMAC;
    head[1] = (uint8_t)alg;
    put32(head + 4, (uint32_t)key_len);
    put32(head + 8, (uint32_t)msg_len);
    if (send_all(o->to, head, sizeof head) != 0 ||
        (key_len != 0 && send_all(o->to, key, key_len) != 0) ||
        (msg_len != 0 && send_all(o->to, msg, msg_len) != 0)) {
        return -1;
    }
    return response(o, out, out_len);
}

int oracle_stream(oracle *o, unsigned alg, uint64_t len, uint8_t *out, size_t *out_len)
{
    uint8_t head[ORACLE_HEADER_BYTES];

    if (alg > 5 || !ORACLE_SUPPORTS_STREAM(o->mask, alg)) {
        *out_len = 0;
        return 0;
    }
    memset(head, 0, sizeof head);
    head[0] = ORACLE_OP_STREAM;
    head[1] = (uint8_t)alg;
    put32(head + 4, (uint32_t)len);
    put32(head + 8, (uint32_t)(len >> 32));
    if (send_all(o->to, head, sizeof head) != 0) {
        return -1;
    }
    return response(o, out, out_len);
}
