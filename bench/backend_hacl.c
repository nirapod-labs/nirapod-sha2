/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * backend_hacl.c
 * ==============
 *
 * The backend for HACL* 0.7.2, with two variants:
 *
 *     hacl-streaming   Hacl_Streaming_SHA2_* for the single hashes and
 *                      Hacl_HMAC_compute_* for HMAC. This variant also
 *                      has the library's multi-way entry points,
 *                      Hacl_SHA2_Vec256_sha256_8 and
 *                      Hacl_SHA2_Vec256_sha512_4.
 *     evercrypt        EverCrypt_Hash_Incremental_* and
 *                      EverCrypt_HMAC_compute, the agile API that picks
 *                      the implementation at run time.
 *
 * HACL* 0.7.2 has no SHA-512/224 or SHA-512/256 streaming entry point and
 * no incremental HMAC, so those workloads are not offered. The multi-way
 * forms take one input pointer per lane; this library's take one packed
 * buffer. Both hash the same bytes, and the driver's known answers are
 * the same for either layout.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <EverCrypt_AutoConfig2.h>
#include <EverCrypt_HMAC.h>
#include <EverCrypt_Hash.h>
#include <Hacl_HMAC.h>
#include <Hacl_Hash_SHA2.h>
#include <Hacl_SHA2_Vec128.h>
#include <Hacl_SHA2_Vec256.h>

#include "bench.h"

#ifndef BENCH_HACL_VEC256
#define BENCH_HACL_VEC256 0
#endif
#ifndef BENCH_HACL_VEC128
#define BENCH_HACL_VEC128 0
#endif

#ifndef BENCH_VERSION
#define BENCH_VERSION "unknown"
#endif
#ifndef BENCH_REVISION
#define BENCH_REVISION "unknown"
#endif

#define HACL_LIBRARY "hacl-star"

static Hacl_Streaming_MD_state_32 *state_224;
static Hacl_Streaming_MD_state_32 *state_256;
static Hacl_Streaming_MD_state_64 *state_384;
static Hacl_Streaming_MD_state_64 *state_512;

static EverCrypt_Hash_Incremental_hash_state *ec_224;
static EverCrypt_Hash_Incremental_hash_state *ec_256;
static EverCrypt_Hash_Incremental_hash_state *ec_384;
static EverCrypt_Hash_Incremental_hash_state *ec_512;

static int streaming_alg(bench_fn fn, uint8_t *alg)
{
    switch (fn) {
    case BENCH_SHA224: *alg = Spec_Hash_Definitions_SHA2_224; return 0;
    case BENCH_SHA256: *alg = Spec_Hash_Definitions_SHA2_256; return 0;
    case BENCH_SHA384: *alg = Spec_Hash_Definitions_SHA2_384; return 0;
    case BENCH_SHA512: *alg = Spec_Hash_Definitions_SHA2_512; return 0;
    case BENCH_HMAC_SHA256: *alg = Spec_Hash_Definitions_SHA2_256; return 0;
    case BENCH_HMAC_SHA512: *alg = Spec_Hash_Definitions_SHA2_512; return 0;
    default: return -1;
    }
}

static int streaming_hash(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    switch (fn) {
    case BENCH_SHA224:
        Hacl_Streaming_SHA2_hash_224((uint8_t *)in, (uint32_t)len, out);
        return 0;
    case BENCH_SHA256:
        Hacl_Streaming_SHA2_hash_256((uint8_t *)in, (uint32_t)len, out);
        return 0;
    case BENCH_SHA384:
        Hacl_Streaming_SHA2_hash_384((uint8_t *)in, (uint32_t)len, out);
        return 0;
    case BENCH_SHA512:
        Hacl_Streaming_SHA2_hash_512((uint8_t *)in, (uint32_t)len, out);
        return 0;
    default:
        return -1;
    }
}

static int streaming_incremental(bench_fn fn, uint8_t *out, const uint8_t *in,
                                 size_t len)
{
    switch (fn) {
    case BENCH_SHA224:
        Hacl_Streaming_SHA2_init_224(state_224);
        if (Hacl_Streaming_SHA2_update_224(state_224, (uint8_t *)in, (uint32_t)len) != 0) {
            return -1;
        }
        Hacl_Streaming_SHA2_finish_224(state_224, out);
        return 0;
    case BENCH_SHA256:
        Hacl_Streaming_SHA2_init_256(state_256);
        if (Hacl_Streaming_SHA2_update_256(state_256, (uint8_t *)in, (uint32_t)len) != 0) {
            return -1;
        }
        Hacl_Streaming_SHA2_finish_256(state_256, out);
        return 0;
    case BENCH_SHA384:
        Hacl_Streaming_SHA2_init_384(state_384);
        if (Hacl_Streaming_SHA2_update_384(state_384, (uint8_t *)in, (uint32_t)len) != 0) {
            return -1;
        }
        Hacl_Streaming_SHA2_finish_384(state_384, out);
        return 0;
    case BENCH_SHA512:
        Hacl_Streaming_SHA2_init_512(state_512);
        if (Hacl_Streaming_SHA2_update_512(state_512, (uint8_t *)in, (uint32_t)len) != 0) {
            return -1;
        }
        Hacl_Streaming_SHA2_finish_512(state_512, out);
        return 0;
    default:
        return -1;
    }
}

static int streaming_hmac(bench_fn fn, uint8_t *out, const uint8_t *key, size_t key_len,
                          const uint8_t *msg, size_t msg_len)
{
    switch (fn) {
    case BENCH_HMAC_SHA256:
        Hacl_HMAC_compute_sha2_256(out, (uint8_t *)key, (uint32_t)key_len,
                                   (uint8_t *)msg, (uint32_t)msg_len);
        return 0;
    case BENCH_HMAC_SHA512:
        Hacl_HMAC_compute_sha2_512(out, (uint8_t *)key, (uint32_t)key_len,
                                   (uint8_t *)msg, (uint32_t)msg_len);
        return 0;
    default:
        return -1;
    }
}

#if BENCH_HACL_VEC256
static void vec256_sha256_8(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    (void)fn;
    Hacl_SHA2_Vec256_sha256_8(out, out + 32, out + 64, out + 96, out + 128,
                              out + 160, out + 192, out + 224,
                              (uint32_t)len,
                              (uint8_t *)in, (uint8_t *)(in + len),
                              (uint8_t *)(in + 2 * len), (uint8_t *)(in + 3 * len),
                              (uint8_t *)(in + 4 * len), (uint8_t *)(in + 5 * len),
                              (uint8_t *)(in + 6 * len), (uint8_t *)(in + 7 * len));
}

static void vec256_sha512_4(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    (void)fn;
    Hacl_SHA2_Vec256_sha512_4(out, out + 64, out + 128, out + 192,
                              (uint32_t)len,
                              (uint8_t *)in, (uint8_t *)(in + len),
                              (uint8_t *)(in + 2 * len), (uint8_t *)(in + 3 * len));
}
#endif

#if !BENCH_HACL_VEC256 && BENCH_HACL_VEC128
static void vec128_sha256_8(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    (void)fn;
    Hacl_SHA2_Vec128_sha256_4(out, out + 32, out + 64, out + 96, (uint32_t)len,
                              (uint8_t *)in, (uint8_t *)(in + len),
                              (uint8_t *)(in + 2 * len), (uint8_t *)(in + 3 * len));
    Hacl_SHA2_Vec128_sha256_4(out + 128, out + 160, out + 192, out + 224,
                              (uint32_t)len,
                              (uint8_t *)(in + 4 * len), (uint8_t *)(in + 5 * len),
                              (uint8_t *)(in + 6 * len), (uint8_t *)(in + 7 * len));
}
#endif

static int evercrypt_hash(bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    uint8_t alg;

    if (streaming_alg(fn, &alg) != 0) {
        return -1;
    }
    EverCrypt_Hash_Incremental_hash(alg, out, (uint8_t *)in, (uint32_t)len);
    return 0;
}

static int evercrypt_incremental(bench_fn fn, uint8_t *out, const uint8_t *in,
                                 size_t len)
{
    EverCrypt_Hash_Incremental_hash_state *s;

    switch (fn) {
    case BENCH_SHA224: s = ec_224; break;
    case BENCH_SHA256: s = ec_256; break;
    case BENCH_SHA384: s = ec_384; break;
    case BENCH_SHA512: s = ec_512; break;
    default: return -1;
    }
    EverCrypt_Hash_Incremental_init(s);
    if (EverCrypt_Hash_Incremental_update(s, (uint8_t *)in, (uint32_t)len)
        != EverCrypt_Error_Success) {
        return -1;
    }
    EverCrypt_Hash_Incremental_finish(s, out);
    return 0;
}

static int evercrypt_hmac(bench_fn fn, uint8_t *out, const uint8_t *key, size_t key_len,
                          const uint8_t *msg, size_t msg_len)
{
    uint8_t alg;

    if (streaming_alg(fn, &alg) != 0) {
        return -1;
    }
    EverCrypt_HMAC_compute(alg, out, (uint8_t *)key, (uint32_t)key_len,
                           (uint8_t *)msg, (uint32_t)msg_len);
    return 0;
}

static int hacl_run(const bench_variant *v, const bench_workload *w, uint8_t *out)
{
    int streaming = v->id == 0;

    switch (w->fn) {
    case BENCH_SHA224:
    case BENCH_SHA256:
    case BENCH_SHA384:
    case BENCH_SHA512:
        if (streaming) {
            return w->incremental ? streaming_incremental(w->fn, out, bench_msg(), w->len)
                                  : streaming_hash(w->fn, out, bench_msg(), w->len);
        }
        return w->incremental ? evercrypt_incremental(w->fn, out, bench_msg(), w->len)
                              : evercrypt_hash(w->fn, out, bench_msg(), w->len);
    case BENCH_HMAC_SHA256:
    case BENCH_HMAC_SHA512:
        if (w->incremental) {
            return -1;
        }
        return streaming
                   ? streaming_hmac(w->fn, out, bench_key(), BENCH_HMAC_KEY_LEN,
                                    bench_msg(), w->len)
                   : evercrypt_hmac(w->fn, out, bench_key(), BENCH_HMAC_KEY_LEN,
                                    bench_msg(), w->len);
    case BENCH_SHA256_X8:
        if (!streaming) {
            return -1;
        }
#if BENCH_HACL_VEC256
        vec256_sha256_8(w->fn, out, bench_msg(), w->len);
        return 0;
#elif BENCH_HACL_VEC128
        vec128_sha256_8(w->fn, out, bench_msg(), w->len);
        return 0;
#else
        return -1;
#endif
    case BENCH_SHA512_X4:
        if (!streaming) {
            return -1;
        }
#if BENCH_HACL_VEC256
        vec256_sha512_4(w->fn, out, bench_msg(), w->len);
        return 0;
#else
        return -1;
#endif
    case BENCH_SHA256_X8_REF:
    case BENCH_SHA512_X4_REF: {
        int x8 = w->fn == BENCH_SHA256_X8_REF;
        size_t ways = x8 ? 8 : 4;
        size_t bytes = x8 ? 32 : 64;
        bench_fn single = x8 ? BENCH_SHA256 : BENCH_SHA512;
        size_t m;

        for (m = 0; m < ways; m++) {
            int rc = streaming
                         ? streaming_hash(single, out + m * bytes,
                                          bench_msg() + m * w->len, w->len)
                         : evercrypt_hash(single, out + m * bytes,
                                          bench_msg() + m * w->len, w->len);
            if (rc != 0) {
                return rc;
            }
        }
        return 0;
    }
    default:
        return -1;
    }
}

static int hacl_supports(const bench_variant *v, const bench_workload *w)
{
    uint8_t alg;

    switch (w->fn) {
    case BENCH_SHA224:
    case BENCH_SHA256:
    case BENCH_SHA384:
    case BENCH_SHA512:
        return 1;
    case BENCH_HMAC_SHA256:
    case BENCH_HMAC_SHA512:
        return streaming_alg(w->fn, &alg) == 0 && !w->incremental;
    case BENCH_SHA256_X8:
        return v->id == 0 && (BENCH_HACL_VEC256 || BENCH_HACL_VEC128);
    case BENCH_SHA512_X4:
        return v->id == 0 && BENCH_HACL_VEC256;
    case BENCH_SHA256_X8_REF:
    case BENCH_SHA512_X4_REF:
        return 1;
    default:
        return 0;
    }
}

static const bench_variant variants[] = {
    { HACL_LIBRARY, BENCH_VERSION, BENCH_REVISION, "hacl-streaming", 0,
      hacl_supports, hacl_run },
    { HACL_LIBRARY, BENCH_VERSION, BENCH_REVISION, "evercrypt", 1,
      hacl_supports, hacl_run },
};

void bench_backend_init(void)
{
    EverCrypt_AutoConfig2_init();

    state_224 = Hacl_Streaming_SHA2_create_in_224();
    state_256 = Hacl_Streaming_SHA2_create_in_256();
    state_384 = Hacl_Streaming_SHA2_create_in_384();
    state_512 = Hacl_Streaming_SHA2_create_in_512();

    ec_224 = EverCrypt_Hash_Incremental_create_in(Spec_Hash_Definitions_SHA2_224);
    ec_256 = EverCrypt_Hash_Incremental_create_in(Spec_Hash_Definitions_SHA2_256);
    ec_384 = EverCrypt_Hash_Incremental_create_in(Spec_Hash_Definitions_SHA2_384);
    ec_512 = EverCrypt_Hash_Incremental_create_in(Spec_Hash_Definitions_SHA2_512);

    if (state_224 == NULL || state_256 == NULL || state_384 == NULL || state_512 == NULL ||
        ec_224 == NULL || ec_256 == NULL || ec_384 == NULL || ec_512 == NULL) {
        fprintf(stderr, "bench: hacl-star: state allocation failed\n");
        exit(2);
    }

    bench_variants = variants;
    bench_variant_count = sizeof(variants) / sizeof(variants[0]);
}
