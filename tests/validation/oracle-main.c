/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-main.c
 * =============
 *
 * The oracle program. It is compiled once per independent implementation,
 * with the backend for that implementation (oracle-backend.h), and answers
 * the requests of oracle-protocol.h until end of input. It shares no code
 * with the library under test.
 *
 * The banner names the implementation as the backend reports it, so a run
 * records the identity it actually linked:
 *
 *     --version   print the banner and exit
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oracle-backend.h"
#include "oracle-protocol.h"

static uint32_t get32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
           ((uint32_t)p[3] << 24);
}

static int read_all(uint8_t *p, size_t n)
{
    return n == 0 || fread(p, 1, n, stdin) == n;
}

static void reply(int status, const uint8_t *out, size_t out_len)
{
    uint8_t head[2];

    head[0] = (uint8_t)status;
    head[1] = (uint8_t)(status == ORACLE_STATUS_OK ? out_len : 0);
    fwrite(head, 1, sizeof head, stdout);
    if (status == ORACLE_STATUS_OK) {
        fwrite(out, 1, out_len, stdout);
    }
    fflush(stdout);
}

static void banner(void)
{
    printf("%s %08x %s\n", ORACLE_BANNER, oracle_backend_mask(), oracle_backend_identity());
    fflush(stdout);
}

int main(int argc, char **argv)
{
    if (argc > 1 && strcmp(argv[1], "--version") == 0) {
        banner();
        return 0;
    }
    banner();

    for (;;) {
        uint8_t head[ORACLE_HEADER_BYTES];
        uint8_t out[ORACLE_MAX_DIGEST];
        uint32_t key_len, msg_len, total;
        uint8_t *buf;
        size_t out_len = 0;
        int status;

        if (!read_all(head, sizeof head)) {
            break;
        }
        key_len = get32(head + 4);
        msg_len = get32(head + 8);
        total = key_len + msg_len;
        if (total < key_len) {
            reply(ORACLE_STATUS_ERROR, NULL, 0);
            continue;
        }
        buf = malloc(total ? total : 1);
        if (buf == NULL || !read_all(buf, total)) {
            free(buf);
            reply(ORACLE_STATUS_ERROR, NULL, 0);
            continue;
        }

        if (head[0] == ORACLE_OP_HASH) {
            status = oracle_backend_hash(head[1], buf, msg_len, out, &out_len);
        } else if (head[0] == ORACLE_OP_HMAC) {
            status = oracle_backend_hmac(head[1], buf, key_len, buf + key_len, msg_len, out,
                                         &out_len);
        } else {
            status = ORACLE_STATUS_ERROR;
        }
        if (status == ORACLE_STATUS_OK && out_len > ORACLE_MAX_DIGEST) {
            status = ORACLE_STATUS_ERROR;
        }
        reply(status, out, out_len);
        free(buf);
    }
    return 0;
}
