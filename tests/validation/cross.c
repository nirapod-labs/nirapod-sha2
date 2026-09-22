/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * cross.c
 * =======
 *
 * Byte-identical results across kernels. For each message the first
 * usable kernel computes the reference; every other kernel and the public
 * functions must produce the same digest or tag, one-shot and
 * incremental. The multi-way forms are compared lane by lane in the same
 * way. The reference kernel is not assumed to be right: the CAVP,
 * Wycheproof and differential suites check it against published vectors
 * and independent implementations.
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CROSS_MAX_SMALL 4096

static size_t collect(validation_suite *s, nirapod_sha2_testing_family family, int *kernels)
{
    size_t n = 0;
    int k;

    for (k = 0; k < VALIDATION_KERNELS; k++) {
        if (validation_usable(s, k, family)) {
            kernels[n++] = k;
        }
    }
    return n;
}

static void cross_hash(validation_suite *s, const hash_alg *a, uint8_t *msg, size_t msg_cap)
{
    int kernels[VALIDATION_KERNELS];
    size_t nk = collect(s, a->family, kernels);
    size_t boundaries[128], nb;
    uint8_t one[64], inc[64], ref[64];
    validation_ctx c;
    validation_rng rng;
    size_t cases;

    if (nk == 0) {
        return;
    }
    nb = validation_boundaries(a->block_len, boundaries, 128);
    rng_seed(&rng, UINT64_C(0xc2055000) + (uint64_t)(a - HASH_ALGS));

    for (cases = 0; cases < nb + validation.iterations + 1; cases++) {
        size_t len;
        const uint8_t *in;
        int k;
        size_t t;

        if (cases < nb) {
            len = boundaries[cases];
        } else if (cases == nb + validation.iterations) {
            len = validation.large_bytes;
        } else {
            len = rng_length(&rng, a->block_len, 8);
        }
        if (len > msg_cap) {
            die("cross: length %zu exceeds the buffer", len);
        }
        if (cases < nb) {
            fill_pattern(msg, len, (unsigned)(17 + cases));
        } else if (cases != nb + validation.iterations) {
            rng_bytes(&rng, msg, len);
        }
        in = len == 0 ? NULL : msg;
        if (hash_oneshot(a, kernels[0], ref, in, len) != NIRAPOD_SHA2_OK) {
            fail_case(s, kernels[0], "%s: length %zu reference returned an error", a->name, len);
            continue;
        }
        for (t = 0; t < nk; t++) {
            k = kernels[t];
            if (hash_oneshot(a, k, one, in, len) != NIRAPOD_SHA2_OK ||
                hash_init(a, k, &c) != NIRAPOD_SHA2_OK ||
                hash_update(a, k, &c, in, len) != NIRAPOD_SHA2_OK ||
                hash_final(a, k, &c, inc) != NIRAPOD_SHA2_OK) {
                fail_case(s, k, "%s: length %zu returned an error", a->name, len);
                continue;
            }
            check_bytes(s, k, one, ref, a->digest_len, "%s: length %zu one-shot across kernels",
                        a->name, len);
            check_bytes(s, k, inc, ref, a->digest_len,
                        "%s: length %zu incremental across kernels", a->name, len);
        }
        if (hash_oneshot(a, VALIDATION_PUBLIC, one, in, len) != NIRAPOD_SHA2_OK ||
            hash_init(a, VALIDATION_PUBLIC, &c) != NIRAPOD_SHA2_OK ||
            hash_update(a, VALIDATION_PUBLIC, &c, in, len) != NIRAPOD_SHA2_OK ||
            hash_final(a, VALIDATION_PUBLIC, &c, inc) != NIRAPOD_SHA2_OK) {
            fail_case(s, VALIDATION_PUBLIC, "%s: length %zu returned an error", a->name, len);
        } else {
            check_bytes(s, VALIDATION_PUBLIC, one, ref, a->digest_len,
                        "%s: length %zu one-shot across kernels", a->name, len);
            check_bytes(s, VALIDATION_PUBLIC, inc, ref, a->digest_len,
                        "%s: length %zu incremental across kernels", a->name, len);
        }
    }
}

static void cross_hmac(validation_suite *s, const hmac_alg *a, uint8_t *msg, size_t msg_cap,
                       uint8_t *key, size_t key_cap)
{
    int kernels[VALIDATION_KERNELS];
    size_t nk = collect(s, a->family, kernels);
    static const size_t key_edges[] = { 0, 1, 63, 64, 65, 127, 128, 129, 300 };
    size_t boundaries[128], nb;
    uint8_t one[64], inc[64], ref[64];
    validation_ctx c;
    validation_rng rng;
    size_t cases;

    if (nk == 0) {
        return;
    }
    nb = validation_boundaries(a->block_len, boundaries, 128);
    rng_seed(&rng, UINT64_C(0xc2055000) + 100 + (uint64_t)(a - HMAC_ALGS));

    for (cases = 0; cases < nb + validation.iterations + 1; cases++) {
        size_t len = cases < nb ? boundaries[cases]
                                : (cases == nb + validation.iterations
                                       ? validation.large_bytes
                                       : rng_length(&rng, a->block_len, 8));
        size_t key_len = key_edges[cases % (sizeof key_edges / sizeof key_edges[0])];
        const uint8_t *in, *kp;
        size_t t;
        int k;

        if (len > msg_cap || key_len > key_cap) {
            die("cross: HMAC buffer too small");
        }
        if (cases < nb) {
            fill_pattern(msg, len, (unsigned)(23 + cases));
            fill_pattern(key, key_len, (unsigned)(101 + cases));
        } else if (cases != nb + validation.iterations) {
            rng_bytes(&rng, msg, len);
            rng_bytes(&rng, key, key_len);
        }
        in = len == 0 ? NULL : msg;
        kp = key_len == 0 ? NULL : key;
        if (hmac_oneshot(a, kernels[0], ref, kp, key_len, in, len) != NIRAPOD_SHA2_OK) {
            fail_case(s, kernels[0], "%s: length %zu reference returned an error", a->name, len);
            continue;
        }
        for (t = 0; t < nk; t++) {
            k = kernels[t];
            if (hmac_oneshot(a, k, one, kp, key_len, in, len) != NIRAPOD_SHA2_OK ||
                hmac_init(a, k, &c, kp, key_len) != NIRAPOD_SHA2_OK ||
                hmac_update(a, k, &c, in, len) != NIRAPOD_SHA2_OK ||
                hmac_final(a, k, &c, inc) != NIRAPOD_SHA2_OK) {
                fail_case(s, k, "%s: length %zu returned an error", a->name, len);
                continue;
            }
            check_bytes(s, k, one, ref, a->digest_len, "%s: length %zu one-shot across kernels",
                        a->name, len);
            check_bytes(s, k, inc, ref, a->digest_len,
                        "%s: length %zu incremental across kernels", a->name, len);
        }
        if (hmac_oneshot(a, VALIDATION_PUBLIC, one, kp, key_len, in, len) == NIRAPOD_SHA2_OK &&
            hmac_init(a, VALIDATION_PUBLIC, &c, kp, key_len) == NIRAPOD_SHA2_OK &&
            hmac_update(a, VALIDATION_PUBLIC, &c, in, len) == NIRAPOD_SHA2_OK &&
            hmac_final(a, VALIDATION_PUBLIC, &c, inc) == NIRAPOD_SHA2_OK) {
            check_bytes(s, VALIDATION_PUBLIC, one, ref, a->digest_len,
                        "%s: length %zu one-shot across kernels", a->name, len);
            check_bytes(s, VALIDATION_PUBLIC, inc, ref, a->digest_len,
                        "%s: length %zu incremental across kernels", a->name, len);
        } else {
            fail_case(s, VALIDATION_PUBLIC, "%s: length %zu returned an error", a->name, len);
        }
    }
}

static void cross_multiway(validation_suite *s, int x4, uint8_t *buf, size_t cap)
{
    size_t block = x4 ? 128 : 64;
    size_t ways = x4 ? 4 : 8;
    size_t out_len = x4 ? NIRAPOD_SHA2_SHA512_X4_BYTES : NIRAPOD_SHA2_SHA256_X8_BYTES;
    int kernels[VALIDATION_KERNELS];
    size_t nk = collect(s, x4 ? NIRAPOD_SHA2_TESTING_FAMILY_X4 : NIRAPOD_SHA2_TESTING_FAMILY_X8,
                        kernels);
    size_t boundaries[128], nb, m;
    uint8_t ref[256], got[256];
    validation_rng rng;
    size_t cases;

    if (nk == 0) {
        return;
    }
    nb = validation_boundaries(block, boundaries, 128);
    rng_seed(&rng, UINT64_C(0xc2055000) + 200 + (uint64_t)x4);
    for (cases = 0; cases < nb + validation.iterations; cases++) {
        size_t len = cases < nb ? boundaries[cases] : rng_length(&rng, block, 8);
        size_t t;

        if (len * ways > cap) {
            die("cross: multi-way input exceeds the buffer");
        }
        if (cases < nb) {
            for (m = 0; m < ways; m++) {
                fill_pattern(buf + m * len, len, (unsigned)(m + 1));
            }
        } else {
            rng_bytes(&rng, buf, len * ways);
        }
        if (multiway_oneshot(x4, kernels[0], ref, len == 0 ? NULL : buf, len) !=
            NIRAPOD_SHA2_OK) {
            fail_case(s, kernels[0], "%s: length %zu reference returned an error",
                      x4 ? "sha512_x4" : "sha256_x8", len);
            continue;
        }
        for (t = 0; t < nk; t++) {
            int k = kernels[t];

            if (multiway_oneshot(x4, k, got, len == 0 ? NULL : buf, len) != NIRAPOD_SHA2_OK) {
                fail_case(s, k, "%s: length %zu returned an error",
                          x4 ? "sha512_x4" : "sha256_x8", len);
                continue;
            }
            check_bytes(s, k, got, ref, out_len, "%s: length %zu across kernels",
                        x4 ? "sha512_x4" : "sha256_x8", len);
        }
        if (multiway_oneshot(x4, VALIDATION_PUBLIC, got, len == 0 ? NULL : buf, len) ==
            NIRAPOD_SHA2_OK) {
            check_bytes(s, VALIDATION_PUBLIC, got, ref, out_len, "%s: length %zu across kernels",
                        x4 ? "sha512_x4" : "sha256_x8", len);
        } else {
            fail_case(s, VALIDATION_PUBLIC, "%s: length %zu returned an error",
                      x4 ? "sha512_x4" : "sha256_x8", len);
        }
    }
}

int suite_cross(void)
{
    validation_suite s;
    size_t msg_cap = CROSS_MAX_SMALL;
    uint8_t *msg, *key, *multi;
    size_t i;
    size_t multi_cap;

    if (validation.large_bytes > msg_cap) {
        msg_cap = validation.large_bytes;
    }
    multi_cap = msg_cap < (1u << 20) ? msg_cap : (1u << 20);
    msg = xmalloc(msg_cap);
    key = xmalloc(CROSS_MAX_SMALL);
    multi = xmalloc(8 * multi_cap);

    suite_begin(&s, "cross");
    for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
        cross_hash(&s, &HASH_ALGS[i], msg, msg_cap);
    }
    for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
        cross_hmac(&s, &HMAC_ALGS[i], msg, msg_cap, key, CROSS_MAX_SMALL);
    }
    cross_multiway(&s, 0, multi, 8 * multi_cap);
    cross_multiway(&s, 1, multi, 8 * multi_cap);
    free(msg);
    free(key);
    free(multi);
    return suite_end(&s);
}
