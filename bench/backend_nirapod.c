/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * backend_nirapod.c
 * =================
 *
 * The backend for this library. One variant is the public API, which is
 * the default dispatch; the others name a kernel through the testing
 * interface (capi/testing/nirapod_sha2_testing.h), so every kernel the
 * build contains is measured, whether or not it is admitted to the
 * default dispatch. The testing interface reports a kernel this
 * architecture did not build, or whose CPU features are absent, as
 * unavailable, and the driver skips those workloads.
 *
 * The *_REF workloads call the single-way function 8 (or 4) times on the
 * same kernel, which is the comparison the multi-way forms are reported
 * against.
 */

#include <stddef.h>
#include <stdint.h>

#include "bench.h"
#include "nirapod/sha2.h"
#include "nirapod_sha2_testing.h"

#ifndef BENCH_VERSION
#define BENCH_VERSION "unknown"
#endif
#ifndef BENCH_REVISION
#define BENCH_REVISION "unknown"
#endif

#define NZ_LIBRARY "nirapod-sha2"

typedef union nz_ctx {
    uint64_t words[NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES / 8];
    nirapod_sha2_sha224_ctx sha224;
    nirapod_sha2_sha256_ctx sha256;
    nirapod_sha2_sha384_ctx sha384;
    nirapod_sha2_sha512_ctx sha512;
    nirapod_sha2_sha512_224_ctx sha512_224;
    nirapod_sha2_sha512_256_ctx sha512_256;
    nirapod_sha2_hmac_sha256_ctx hmac256;
    nirapod_sha2_hmac_sha512_ctx hmac512;
} nz_ctx;

#define NZ_K(k) ((nirapod_sha2_testing_kernel)(k))

static int nz_hash(int k, bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    if (k < 0) {
        switch (fn) {
        case BENCH_SHA224: return nirapod_sha2_sha224(out, in, len);
        case BENCH_SHA256: return nirapod_sha2_sha256(out, in, len);
        case BENCH_SHA384: return nirapod_sha2_sha384(out, in, len);
        case BENCH_SHA512: return nirapod_sha2_sha512(out, in, len);
        case BENCH_SHA512_224: return nirapod_sha2_sha512_224(out, in, len);
        case BENCH_SHA512_256: return nirapod_sha2_sha512_256(out, in, len);
        default: return -1;
        }
    }
    switch (fn) {
    case BENCH_SHA224: return nirapod_sha2_testing_sha224(NZ_K(k), out, in, len);
    case BENCH_SHA256: return nirapod_sha2_testing_sha256(NZ_K(k), out, in, len);
    case BENCH_SHA384: return nirapod_sha2_testing_sha384(NZ_K(k), out, in, len);
    case BENCH_SHA512: return nirapod_sha2_testing_sha512(NZ_K(k), out, in, len);
    case BENCH_SHA512_224: return nirapod_sha2_testing_sha512_224(NZ_K(k), out, in, len);
    case BENCH_SHA512_256: return nirapod_sha2_testing_sha512_256(NZ_K(k), out, in, len);
    default: return -1;
    }
}

static int nz_init(int k, bench_fn fn, void *ctx)
{
    if (k < 0) {
        switch (fn) {
        case BENCH_SHA224: return nirapod_sha2_sha224_init((nirapod_sha2_sha224_ctx *)ctx);
        case BENCH_SHA256: return nirapod_sha2_sha256_init((nirapod_sha2_sha256_ctx *)ctx);
        case BENCH_SHA384: return nirapod_sha2_sha384_init((nirapod_sha2_sha384_ctx *)ctx);
        case BENCH_SHA512: return nirapod_sha2_sha512_init((nirapod_sha2_sha512_ctx *)ctx);
        case BENCH_SHA512_224: return nirapod_sha2_sha512_224_init((nirapod_sha2_sha512_224_ctx *)ctx);
        case BENCH_SHA512_256: return nirapod_sha2_sha512_256_init((nirapod_sha2_sha512_256_ctx *)ctx);
        default: return -1;
        }
    }
    switch (fn) {
    case BENCH_SHA224:
        return nirapod_sha2_testing_sha224_init(NZ_K(k), (nirapod_sha2_sha224_ctx *)ctx);
    case BENCH_SHA256:
        return nirapod_sha2_testing_sha256_init(NZ_K(k), (nirapod_sha2_sha256_ctx *)ctx);
    case BENCH_SHA384:
        return nirapod_sha2_testing_sha384_init(NZ_K(k), (nirapod_sha2_sha384_ctx *)ctx);
    case BENCH_SHA512:
        return nirapod_sha2_testing_sha512_init(NZ_K(k), (nirapod_sha2_sha512_ctx *)ctx);
    case BENCH_SHA512_224:
        return nirapod_sha2_testing_sha512_224_init(NZ_K(k), (nirapod_sha2_sha512_224_ctx *)ctx);
    case BENCH_SHA512_256:
        return nirapod_sha2_testing_sha512_256_init(NZ_K(k), (nirapod_sha2_sha512_256_ctx *)ctx);
    default: return -1;
    }
}

static int nz_update(int k, bench_fn fn, void *ctx, const uint8_t *in, size_t len)
{
    if (k < 0) {
        switch (fn) {
        case BENCH_SHA224: return nirapod_sha2_sha224_update((nirapod_sha2_sha224_ctx *)ctx, in, len);
        case BENCH_SHA256: return nirapod_sha2_sha256_update((nirapod_sha2_sha256_ctx *)ctx, in, len);
        case BENCH_SHA384: return nirapod_sha2_sha384_update((nirapod_sha2_sha384_ctx *)ctx, in, len);
        case BENCH_SHA512: return nirapod_sha2_sha512_update((nirapod_sha2_sha512_ctx *)ctx, in, len);
        case BENCH_SHA512_224:
            return nirapod_sha2_sha512_224_update((nirapod_sha2_sha512_224_ctx *)ctx, in, len);
        case BENCH_SHA512_256:
            return nirapod_sha2_sha512_256_update((nirapod_sha2_sha512_256_ctx *)ctx, in, len);
        case BENCH_HMAC_SHA256:
            return nirapod_sha2_hmac_sha256_update((nirapod_sha2_hmac_sha256_ctx *)ctx, in, len);
        case BENCH_HMAC_SHA512:
            return nirapod_sha2_hmac_sha512_update((nirapod_sha2_hmac_sha512_ctx *)ctx, in, len);
        default: return -1;
        }
    }
    switch (fn) {
    case BENCH_SHA224:
        return nirapod_sha2_testing_sha224_update(NZ_K(k), (nirapod_sha2_sha224_ctx *)ctx, in, len);
    case BENCH_SHA256:
        return nirapod_sha2_testing_sha256_update(NZ_K(k), (nirapod_sha2_sha256_ctx *)ctx, in, len);
    case BENCH_SHA384:
        return nirapod_sha2_testing_sha384_update(NZ_K(k), (nirapod_sha2_sha384_ctx *)ctx, in, len);
    case BENCH_SHA512:
        return nirapod_sha2_testing_sha512_update(NZ_K(k), (nirapod_sha2_sha512_ctx *)ctx, in, len);
    case BENCH_SHA512_224:
        return nirapod_sha2_testing_sha512_224_update(NZ_K(k),
                                                      (nirapod_sha2_sha512_224_ctx *)ctx, in, len);
    case BENCH_SHA512_256:
        return nirapod_sha2_testing_sha512_256_update(NZ_K(k),
                                                      (nirapod_sha2_sha512_256_ctx *)ctx, in, len);
    case BENCH_HMAC_SHA256:
        return nirapod_sha2_testing_hmac_sha256_update(NZ_K(k),
                                                       (nirapod_sha2_hmac_sha256_ctx *)ctx, in, len);
    case BENCH_HMAC_SHA512:
        return nirapod_sha2_testing_hmac_sha512_update(NZ_K(k),
                                                       (nirapod_sha2_hmac_sha512_ctx *)ctx, in, len);
    default: return -1;
    }
}

static int nz_final(int k, bench_fn fn, void *ctx, uint8_t *out)
{
    if (k < 0) {
        switch (fn) {
        case BENCH_SHA224: return nirapod_sha2_sha224_final((nirapod_sha2_sha224_ctx *)ctx, out);
        case BENCH_SHA256: return nirapod_sha2_sha256_final((nirapod_sha2_sha256_ctx *)ctx, out);
        case BENCH_SHA384: return nirapod_sha2_sha384_final((nirapod_sha2_sha384_ctx *)ctx, out);
        case BENCH_SHA512: return nirapod_sha2_sha512_final((nirapod_sha2_sha512_ctx *)ctx, out);
        case BENCH_SHA512_224:
            return nirapod_sha2_sha512_224_final((nirapod_sha2_sha512_224_ctx *)ctx, out);
        case BENCH_SHA512_256:
            return nirapod_sha2_sha512_256_final((nirapod_sha2_sha512_256_ctx *)ctx, out);
        case BENCH_HMAC_SHA256:
            return nirapod_sha2_hmac_sha256_final((nirapod_sha2_hmac_sha256_ctx *)ctx, out);
        case BENCH_HMAC_SHA512:
            return nirapod_sha2_hmac_sha512_final((nirapod_sha2_hmac_sha512_ctx *)ctx, out);
        default: return -1;
        }
    }
    switch (fn) {
    case BENCH_SHA224:
        return nirapod_sha2_testing_sha224_final(NZ_K(k), (nirapod_sha2_sha224_ctx *)ctx, out);
    case BENCH_SHA256:
        return nirapod_sha2_testing_sha256_final(NZ_K(k), (nirapod_sha2_sha256_ctx *)ctx, out);
    case BENCH_SHA384:
        return nirapod_sha2_testing_sha384_final(NZ_K(k), (nirapod_sha2_sha384_ctx *)ctx, out);
    case BENCH_SHA512:
        return nirapod_sha2_testing_sha512_final(NZ_K(k), (nirapod_sha2_sha512_ctx *)ctx, out);
    case BENCH_SHA512_224:
        return nirapod_sha2_testing_sha512_224_final(NZ_K(k),
                                                     (nirapod_sha2_sha512_224_ctx *)ctx, out);
    case BENCH_SHA512_256:
        return nirapod_sha2_testing_sha512_256_final(NZ_K(k),
                                                     (nirapod_sha2_sha512_256_ctx *)ctx, out);
    case BENCH_HMAC_SHA256:
        return nirapod_sha2_testing_hmac_sha256_final(NZ_K(k),
                                                      (nirapod_sha2_hmac_sha256_ctx *)ctx, out);
    case BENCH_HMAC_SHA512:
        return nirapod_sha2_testing_hmac_sha512_final(NZ_K(k),
                                                      (nirapod_sha2_hmac_sha512_ctx *)ctx, out);
    default: return -1;
    }
}

static int nz_hmac(int k, bench_fn fn, uint8_t *out, const uint8_t *key,
                   size_t key_len, const uint8_t *msg, size_t msg_len)
{
    int h512 = fn == BENCH_HMAC_SHA512;

    if (k < 0) {
        return h512 ? nirapod_sha2_hmac_sha512(out, key, key_len, msg, msg_len)
                    : nirapod_sha2_hmac_sha256(out, key, key_len, msg, msg_len);
    }
    return h512 ? nirapod_sha2_testing_hmac_sha512(NZ_K(k), out, key, key_len, msg, msg_len)
                : nirapod_sha2_testing_hmac_sha256(NZ_K(k), out, key, key_len, msg, msg_len);
}

static int nz_hmac_init(int k, bench_fn fn, void *ctx, const uint8_t *key, size_t key_len)
{
    int h512 = fn == BENCH_HMAC_SHA512;

    if (k < 0) {
        return h512 ? nirapod_sha2_hmac_sha512_init((nirapod_sha2_hmac_sha512_ctx *)ctx,
                                                    key, key_len)
                    : nirapod_sha2_hmac_sha256_init((nirapod_sha2_hmac_sha256_ctx *)ctx,
                                                    key, key_len);
    }
    return h512 ? nirapod_sha2_testing_hmac_sha512_init(NZ_K(k),
                                                        (nirapod_sha2_hmac_sha512_ctx *)ctx,
                                                        key, key_len)
                : nirapod_sha2_testing_hmac_sha256_init(NZ_K(k),
                                                        (nirapod_sha2_hmac_sha256_ctx *)ctx,
                                                        key, key_len);
}

/* The multi-way one-shot on packed messages: lane m reads in + m len. */
static int nz_multi(int k, bench_fn fn, uint8_t *out, const uint8_t *in, size_t len)
{
    int x4 = fn == BENCH_SHA512_X4;
    const uint8_t *t[8];
    size_t m;

    for (m = 0; m < 8; m++) {
        t[m] = in + m * len;
    }
    if (k < 0) {
        return x4 ? nirapod_sha2_sha512_x4(out, t, len)
                  : nirapod_sha2_sha256_x8(out, t, len);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4(NZ_K(k), out, t, len)
              : nirapod_sha2_testing_sha256_x8(NZ_K(k), out, t, len);
}

static int nz_run(const bench_variant *v, const bench_workload *w, uint8_t *out)
{
    int k = v->id;
    const uint8_t *in = bench_msg();

    switch (w->fn) {
    case BENCH_SHA224:
    case BENCH_SHA256:
    case BENCH_SHA384:
    case BENCH_SHA512:
    case BENCH_SHA512_224:
    case BENCH_SHA512_256:
        if (!w->incremental) {
            return nz_hash(k, w->fn, out, in, w->len);
        } else {
            nz_ctx ctx;
            int rc = nz_init(k, w->fn, &ctx);

            if (rc == 0) {
                rc = nz_update(k, w->fn, &ctx, in, w->len);
            }
            if (rc == 0) {
                rc = nz_final(k, w->fn, &ctx, out);
            }
            return rc;
        }
    case BENCH_HMAC_SHA256:
    case BENCH_HMAC_SHA512:
        if (!w->incremental) {
            return nz_hmac(k, w->fn, out, bench_key(), w->key_len, in, w->len);
        } else {
            nz_ctx ctx;
            int rc = nz_hmac_init(k, w->fn, &ctx, bench_key(), w->key_len);

            if (rc == 0) {
                rc = nz_update(k, w->fn, &ctx, in, w->len);
            }
            if (rc == 0) {
                rc = nz_final(k, w->fn, &ctx, out);
            }
            return rc;
        }
    case BENCH_SHA256_X8:
    case BENCH_SHA512_X4:
        return nz_multi(k, w->fn, out, in, w->len);
    case BENCH_SHA256_X8_REF:
    case BENCH_SHA512_X4_REF: {
        int x8 = w->fn == BENCH_SHA256_X8_REF;
        size_t ways = x8 ? 8 : 4;
        size_t bytes = x8 ? NIRAPOD_SHA2_SHA256_BYTES : NIRAPOD_SHA2_SHA512_BYTES;
        bench_fn single = x8 ? BENCH_SHA256 : BENCH_SHA512;
        size_t m;

        for (m = 0; m < ways; m++) {
            int rc = nz_hash(k, single, out + m * bytes, in + m * w->len, w->len);

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

static int nz_family(bench_fn fn)
{
    switch (fn) {
    case BENCH_SHA224:
    case BENCH_SHA256:
    case BENCH_HMAC_SHA256:
    case BENCH_SHA256_X8_REF:
        return NIRAPOD_SHA2_TESTING_FAMILY_SHA256;
    case BENCH_SHA384:
    case BENCH_SHA512:
    case BENCH_SHA512_224:
    case BENCH_SHA512_256:
    case BENCH_HMAC_SHA512:
    case BENCH_SHA512_X4_REF:
        return NIRAPOD_SHA2_TESTING_FAMILY_SHA512;
    case BENCH_SHA256_X8:
        return NIRAPOD_SHA2_TESTING_FAMILY_X8;
    case BENCH_SHA512_X4:
        return NIRAPOD_SHA2_TESTING_FAMILY_X4;
    default:
        return -1;
    }
}

static int nz_supports(const bench_variant *v, const bench_workload *w)
{
    int family = nz_family(w->fn);

    if (family < 0) {
        return 0;
    }
    if (v->id < 0) {
        return 1;
    }
    if (nirapod_sha2_testing_kernel_name(NZ_K(v->id)) == NULL) {
        return 0;
    }
    return nirapod_sha2_testing_available(NZ_K(v->id),
                                          (nirapod_sha2_testing_family)family);
}

#if defined(__aarch64__)
static const bench_variant variants[] = {
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "public", -1, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "aarch64-portable",
      NIRAPOD_SHA2_TESTING_PORTABLE, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "aarch64-scalar",
      NIRAPOD_SHA2_TESTING_AARCH64_SCALAR, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "aarch64-sha2",
      NIRAPOD_SHA2_TESTING_AARCH64_SHA2, nz_supports, nz_run },
};
#elif defined(__x86_64__)
static const bench_variant variants[] = {
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "public", -1, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "x86_64-portable",
      NIRAPOD_SHA2_TESTING_PORTABLE, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "x86_64-shani",
      NIRAPOD_SHA2_TESTING_X86_64_SHANI, nz_supports, nz_run },
    { NZ_LIBRARY, BENCH_VERSION, BENCH_REVISION, "x86_64-avx2",
      NIRAPOD_SHA2_TESTING_X86_64_AVX2, nz_supports, nz_run },
};
#else
#error "backend_nirapod.c: unsupported architecture"
#endif

void bench_backend_init(void)
{
    bench_variants = variants;
    bench_variant_count = sizeof(variants) / sizeof(variants[0]);
}
