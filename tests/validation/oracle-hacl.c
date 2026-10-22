/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-hacl.c
 * =============
 *
 * The oracle backend for the HACL* C package: C code extracted from F*
 * specifications and proofs, unrelated to the OpenSSL code base and to
 * this library. It uses the portable streaming SHA-2
 * (Hacl_Streaming_SHA2_*) and HMAC (Hacl_HMAC_compute_sha2_*) entry
 * points, not the EverCrypt layer, which may dispatch to Vale assembly.
 *
 * The pinned package has SHA-224, SHA-256, SHA-384 and SHA-512 and the two
 * HMACs; it has no SHA-512/224 or SHA-512/256 entry point, so this oracle
 * does not implement them. Its lengths are 32-bit: a longer input is
 * reported as not implemented.
 *
 * The headers carry no version, so the build names the identity:
 * ORACLE_IDENTITY, set by tests/validation/Makefile from the install
 * prefix and the SHA-256 of the library it links.
 */

#include <stdint.h>
#include <stdlib.h>

#include "Hacl_HMAC.h"
#include "Hacl_Hash_SHA2.h"

#include "oracle-backend.h"
#include "oracle-protocol.h"

#ifndef ORACLE_IDENTITY
#define ORACLE_IDENTITY "HACL* C package, unidentified build"
#endif

static const size_t digest_bytes[4] = { 28, 32, 48, 64 };

const char *oracle_backend_identity(void)
{
    return ORACLE_IDENTITY;
}

unsigned oracle_backend_mask(void)
{
    return 0x0fu | (1u << 8) | (1u << 9);
}

int oracle_backend_hash(unsigned alg, const uint8_t *in, size_t len, uint8_t *out,
                        size_t *out_len)
{
    uint8_t *p = (uint8_t *)in;

    if (alg >= 4 || len > UINT32_MAX) {
        return ORACLE_STATUS_UNSUPPORTED;
    }
    switch (alg) {
    case 0: Hacl_Streaming_SHA2_hash_224(p, (uint32_t)len, out); break;
    case 1: Hacl_Streaming_SHA2_hash_256(p, (uint32_t)len, out); break;
    case 2: Hacl_Streaming_SHA2_hash_384(p, (uint32_t)len, out); break;
    default: Hacl_Streaming_SHA2_hash_512(p, (uint32_t)len, out); break;
    }
    *out_len = digest_bytes[alg];
    return ORACLE_STATUS_OK;
}

int oracle_backend_hmac(unsigned alg, const uint8_t *key, size_t key_len, const uint8_t *msg,
                        size_t msg_len, uint8_t *out, size_t *out_len)
{
    if (alg >= 2 || key_len > UINT32_MAX || msg_len > UINT32_MAX) {
        return ORACLE_STATUS_UNSUPPORTED;
    }
    if (alg == 0) {
        Hacl_HMAC_compute_sha2_256(out, (uint8_t *)key, (uint32_t)key_len, (uint8_t *)msg,
                                   (uint32_t)msg_len);
        *out_len = 32;
    } else {
        Hacl_HMAC_compute_sha2_512(out, (uint8_t *)key, (uint32_t)key_len, (uint8_t *)msg,
                                   (uint32_t)msg_len);
        *out_len = 64;
    }
    return ORACLE_STATUS_OK;
}
