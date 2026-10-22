/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-backend.h
 * ================
 *
 * What an oracle program needs from the implementation it is built
 * against. oracle-main.c speaks the protocol of oracle-protocol.h and
 * calls these; one backend file is linked per program:
 *
 *     oracle-openssl.c   the EVP and HMAC entry points that OpenSSL,
 *                        AWS-LC and BoringSSL share
 *     oracle-hacl.c      the HACL* C package
 *
 * Algorithm numbers are those of the protocol. Every function returns an
 * ORACLE_STATUS_ value and, on ORACLE_STATUS_OK, sets *out_len.
 */

#ifndef NIRAPOD_SHA2_ORACLE_BACKEND_H
#define NIRAPOD_SHA2_ORACLE_BACKEND_H

#include <stddef.h>
#include <stdint.h>

/* The name and version of the implementation, for the banner. */
const char *oracle_backend_identity(void);

/* The banner's mask (oracle-protocol.h). */
unsigned oracle_backend_mask(void);

int oracle_backend_hash(unsigned alg, const uint8_t *in, size_t len, uint8_t *out,
                        size_t *out_len);
int oracle_backend_hmac(unsigned alg, const uint8_t *key, size_t key_len, const uint8_t *msg,
                        size_t msg_len, uint8_t *out, size_t *out_len);

/* The hash of len bytes made of block (period bytes) repeated, through the
 * implementation's incremental interface, one block per update. */
int oracle_backend_stream(unsigned alg, const uint8_t *block, size_t period, uint64_t len,
                          uint8_t *out, size_t *out_len);

#endif /* NIRAPOD_SHA2_ORACLE_BACKEND_H */
