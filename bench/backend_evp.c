/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * backend_evp.c
 * =============
 *
 * The backend for the OpenSSL-style EVP libraries: OpenSSL, AWS-LC and
 * BoringSSL. It is compiled once per library, with one of BENCH_OPENSSL,
 * BENCH_AWSLC or BENCH_BORINGSSL defined; each is the library's own
 * documented path, through EVP_Digest and HMAC.
 *
 * The one-shot operations call the library's one-shot entry points. The
 * incremental ones keep one EVP_MD_CTX or HMAC_CTX allocated between
 * calls and run init, one update and final per call, which is the work of
 * this library's incremental operations when the caller holds the state.
 *
 * BoringSSL has no SHA-512/224; the Makefile leaves BENCH_HAVE_SHA512_224
 * undefined there and the workload is not offered.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <openssl/evp.h>
#include <openssl/hmac.h>

#include "bench.h"

#if !defined(BENCH_OPENSSL) && !defined(BENCH_AWSLC) && !defined(BENCH_BORINGSSL)
#error "backend_evp.c: define one of BENCH_OPENSSL, BENCH_AWSLC, BENCH_BORINGSSL"
#endif

#ifndef BENCH_LIBRARY
#define BENCH_LIBRARY "unknown"
#endif
#ifndef BENCH_VERSION
#define BENCH_VERSION "unknown"
#endif
#ifndef BENCH_REVISION
#define BENCH_REVISION "unknown"
#endif

static EVP_MD_CTX *md_ctx;
static HMAC_CTX *hmac_ctx;

static const EVP_MD *evp_md(bench_fn fn)
{
    switch (fn) {
    case BENCH_SHA224: return EVP_sha224();
    case BENCH_SHA256: return EVP_sha256();
    case BENCH_SHA384: return EVP_sha384();
    case BENCH_SHA512: return EVP_sha512();
#if defined(BENCH_HAVE_SHA512_224)
    case BENCH_SHA512_224: return EVP_sha512_224();
#endif
    case BENCH_SHA512_256: return EVP_sha512_256();
    case BENCH_HMAC_SHA256: return EVP_sha256();
    case BENCH_HMAC_SHA512: return EVP_sha512();
    case BENCH_SHA256_X8_REF: return EVP_sha256();
    case BENCH_SHA512_X4_REF: return EVP_sha512();
    default: return NULL;
    }
}

#if defined(BENCH_OPENSSL)
#define EVP_HMAC_LEN(x) ((int)(x))
#else
#define EVP_HMAC_LEN(x) (x)
#endif

static int evp_hash(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    const EVP_MD *md = evp_md(fn);
    unsigned int out_len = 0;

    if (md == NULL) {
        return -1;
    }
    if (EVP_Digest(in, len, out, &out_len, md, NULL) != 1) {
        return -1;
    }
    return out_len == bench_fn_out_len(fn) ? 0 : -1;
}

static int evp_hash_incremental(bench_fn fn, uint8_t *out, const uint8_t *in,
                                size_t len)
{
    const EVP_MD *md = evp_md(fn);
    unsigned int out_len = 0;

    if (md == NULL || md_ctx == NULL) {
        return -1;
    }
    if (EVP_DigestInit_ex(md_ctx, md, NULL) != 1) {
        return -1;
    }
    if (EVP_DigestUpdate(md_ctx, in, len) != 1) {
        return -1;
    }
    if (EVP_DigestFinal_ex(md_ctx, out, &out_len) != 1) {
        return -1;
    }
    return out_len == bench_fn_out_len(fn) ? 0 : -1;
}

static int evp_hmac(bench_fn fn, uint8_t *out, const uint8_t *key, size_t key_len,
                    const uint8_t *msg, size_t msg_len)
{
    const EVP_MD *md = evp_md(fn);
    unsigned int out_len = 0;

    if (md == NULL) {
        return -1;
    }
    if (HMAC(md, key, EVP_HMAC_LEN(key_len), msg, msg_len, out, &out_len) == NULL) {
        return -1;
    }
    return out_len == bench_fn_out_len(fn) ? 0 : -1;
}

static int evp_hmac_incremental(bench_fn fn, uint8_t *out, const uint8_t *key,
                                size_t key_len, const uint8_t *msg, size_t msg_len)
{
    const EVP_MD *md = evp_md(fn);
    unsigned int out_len = 0;

    if (md == NULL || hmac_ctx == NULL) {
        return -1;
    }
    if (HMAC_Init_ex(hmac_ctx, key, EVP_HMAC_LEN(key_len), md, NULL) != 1) {
        return -1;
    }
    if (HMAC_Update(hmac_ctx, msg, msg_len) != 1) {
        return -1;
    }
    if (HMAC_Final(hmac_ctx, out, &out_len) != 1) {
        return -1;
    }
    return out_len == bench_fn_out_len(fn) ? 0 : -1;
}

static int evp_run(const bench_variant *v, const bench_workload *w, uint8_t *out)
{
    (void)v;

    switch (w->fn) {
    case BENCH_SHA224:
    case BENCH_SHA256:
    case BENCH_SHA384:
    case BENCH_SHA512:
    case BENCH_SHA512_224:
    case BENCH_SHA512_256:
        return w->incremental ? evp_hash_incremental(w->fn, out, bench_msg(), w->len)
                              : evp_hash(w->fn, out, bench_msg(), w->len);
    case BENCH_HMAC_SHA256:
    case BENCH_HMAC_SHA512:
        return w->incremental
                   ? evp_hmac_incremental(w->fn, out, bench_key(), w->key_len,
                                          bench_msg(), w->len)
                   : evp_hmac(w->fn, out, bench_key(), w->key_len,
                              bench_msg(), w->len);
    case BENCH_SHA256_X8_REF:
    case BENCH_SHA512_X4_REF: {
        int x8 = w->fn == BENCH_SHA256_X8_REF;
        size_t ways = x8 ? 8 : 4;
        size_t bytes = x8 ? 32 : 64;
        bench_fn single = x8 ? BENCH_SHA256 : BENCH_SHA512;
        size_t m;

        for (m = 0; m < ways; m++) {
            if (evp_hash(single, out + m * bytes, bench_msg() + m * w->len, w->len) != 0) {
                return -1;
            }
        }
        return 0;
    }
    default:
        return -1;
    }
}

static int evp_supports(const bench_variant *v, const bench_workload *w)
{
    (void)v;
    if (evp_md(w->fn) == NULL) {
        return 0;
    }
    switch (w->fn) {
    case BENCH_SHA256_X8:
    case BENCH_SHA512_X4:
        return 0;
    default:
        return 1;
    }
}

static const bench_variant variants[] = {
    { BENCH_LIBRARY, BENCH_VERSION, BENCH_REVISION, "public", 0,
      evp_supports, evp_run },
};

void bench_backend_init(void)
{
    md_ctx = EVP_MD_CTX_new();
    hmac_ctx = HMAC_CTX_new();
    if (md_ctx == NULL || hmac_ctx == NULL) {
        fprintf(stderr, "bench: %s: context allocation failed\n", BENCH_LIBRARY);
        exit(2);
    }
    bench_variants = variants;
    bench_variant_count = sizeof(variants) / sizeof(variants[0]);
}
