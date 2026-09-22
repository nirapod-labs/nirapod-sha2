/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-main.c
 * =============
 *
 * The oracle program. It is compiled once per independent implementation,
 * against that implementation's headers and library, and answers the
 * requests of oracle-protocol.h until end of input. It shares no code
 * with the library under test.
 *
 * The banner names the implementation from its own headers, so a run
 * records the identity it actually linked:
 *
 *     --version   print the banner and exit
 */

#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>

#include "oracle-protocol.h"

#ifndef OPENSSL_VERSION_TEXT
#define OPENSSL_VERSION_TEXT "unknown OpenSSL-compatible library"
#endif

static const EVP_MD *digest_for(unsigned alg)
{
    switch (alg) {
    case 0: return EVP_sha224();
    case 1: return EVP_sha256();
    case 2: return EVP_sha384();
    case 3: return EVP_sha512();
#if defined(OPENSSL_IS_BORINGSSL) || defined(OPENSSL_IS_AWSLC)
    case 4:
    case 5:
        return NULL;
#else
    case 4: return EVP_sha512_224();
    case 5: return EVP_sha512_256();
#endif
    default:
        return NULL;
    }
}

static const EVP_MD *mac_for(unsigned alg)
{
    return alg == 0 ? EVP_sha256() : EVP_sha512();
}

static unsigned supported_mask(void)
{
    unsigned mask = 0;
    unsigned i;

    for (i = 0; i < 6; i++) {
        if (digest_for(i) != NULL) {
            mask |= 1u << i;
        }
    }
    for (i = 0; i < 2; i++) {
        mask |= 1u << (8 + i);
    }
    return mask;
}

static uint32_t get32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
           ((uint32_t)p[3] << 24);
}

static int read_all(uint8_t *p, size_t n)
{
    return n == 0 || fread(p, 1, n, stdin) == n;
}

static void send_error(uint8_t status)
{
    uint8_t head[2] = { status, 0 };

    fwrite(head, 1, sizeof head, stdout);
    fflush(stdout);
}

int main(int argc, char **argv)
{
    unsigned mask = supported_mask();

    if (argc > 1 && strcmp(argv[1], "--version") == 0) {
        printf("%s %08x %s\n", ORACLE_BANNER, mask, OPENSSL_VERSION_TEXT);
        return 0;
    }
    printf("%s %08x %s\n", ORACLE_BANNER, mask, OPENSSL_VERSION_TEXT);
    fflush(stdout);

    for (;;) {
        uint8_t head[ORACLE_HEADER_BYTES], reply[2];
        uint32_t key_len, msg_len, total;
        uint8_t *buf = NULL, out[ORACLE_MAX_DIGEST];
        size_t out_len = 0;
        unsigned alg;
        int status = ORACLE_STATUS_OK;

        if (!read_all(head, sizeof head)) {
            break;
        }
        alg = head[1];
        key_len = get32(head + 4);
        msg_len = get32(head + 8);
        total = key_len + msg_len;
        if (total < key_len) {
            send_error(ORACLE_STATUS_ERROR);
            continue;
        }
        buf = malloc(total ? total : 1);
        if (buf == NULL || !read_all(buf, total)) {
            free(buf);
            send_error(ORACLE_STATUS_ERROR);
            continue;
        }

        if (head[0] == ORACLE_OP_HASH) {
            const EVP_MD *md = alg < 6 ? digest_for(alg) : NULL;
            unsigned int len = 0;

            if (md == NULL) {
                status = ORACLE_STATUS_UNSUPPORTED;
            } else if (EVP_Digest(buf, msg_len, out, &len, md, NULL) != 1) {
                status = ORACLE_STATUS_ERROR;
            } else {
                out_len = len;
            }
        } else if (head[0] == ORACLE_OP_HMAC) {
            unsigned int len = 0;

            if (alg >= 2 || key_len > INT_MAX || msg_len > INT_MAX) {
                status = ORACLE_STATUS_UNSUPPORTED;
            } else if (HMAC(mac_for(alg), buf, (int)key_len, buf + key_len, (int)msg_len,
                            out, &len) == NULL) {
                status = ORACLE_STATUS_ERROR;
            } else {
                out_len = len;
            }
        } else {
            status = ORACLE_STATUS_ERROR;
        }

        reply[0] = (uint8_t)status;
        reply[1] = (uint8_t)(status == ORACLE_STATUS_OK ? out_len : 0);
        fwrite(reply, 1, sizeof reply, stdout);
        if (status == ORACLE_STATUS_OK) {
            fwrite(out, 1, out_len, stdout);
        }
        fflush(stdout);
        free(buf);
    }
    return 0;
}
