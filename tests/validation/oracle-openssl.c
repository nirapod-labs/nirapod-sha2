/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * oracle-openssl.c
 * ================
 *
 * The oracle backend for OpenSSL, AWS-LC and BoringSSL, through the
 * digest and HMAC entry points the three share. The identity is the
 * version text of the headers the program was compiled with.
 *
 * AWS-LC and BoringSSL have no EVP_sha512_224 or EVP_sha512_256, so their
 * programs do not implement SHA-512/224 and SHA-512/256. The three
 * libraries descend from one code base; this backend is one oracle
 * family, not three independent ones (README.md, "Oracles").
 */

#include <limits.h>
#include <stdint.h>

#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>

#include "oracle-backend.h"
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

const char *oracle_backend_identity(void)
{
    return OPENSSL_VERSION_TEXT;
}

unsigned oracle_backend_mask(void)
{
    unsigned mask = 0;
    unsigned i;

    for (i = 0; i < 6; i++) {
        if (digest_for(i) != NULL) {
            mask |= 1u << i;
        }
    }
    return mask | (1u << 8) | (1u << 9);
}

int oracle_backend_hash(unsigned alg, const uint8_t *in, size_t len, uint8_t *out,
                        size_t *out_len)
{
    const EVP_MD *md = digest_for(alg);
    unsigned int n = 0;

    if (md == NULL) {
        return ORACLE_STATUS_UNSUPPORTED;
    }
    if (EVP_Digest(in, len, out, &n, md, NULL) != 1) {
        return ORACLE_STATUS_ERROR;
    }
    *out_len = n;
    return ORACLE_STATUS_OK;
}

int oracle_backend_hmac(unsigned alg, const uint8_t *key, size_t key_len, const uint8_t *msg,
                        size_t msg_len, uint8_t *out, size_t *out_len)
{
    unsigned int n = 0;

    if (alg >= 2 || key_len > INT_MAX) {
        return ORACLE_STATUS_UNSUPPORTED;
    }
    if (HMAC(alg == 0 ? EVP_sha256() : EVP_sha512(), key, (int)key_len, msg, msg_len, out,
             &n) == NULL) {
        return ORACLE_STATUS_ERROR;
    }
    *out_len = n;
    return ORACLE_STATUS_OK;
}
