/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * multiway.c
 * ==========
 *
 * sha256_x8 and sha512_x4 against the single-way one-shot function: every
 * lane gets its own message of the same length, and each lane's digest
 * must equal the one-shot digest of that message. Lengths cover both
 * padding edges, the empty message, random lengths and a large message;
 * the output must be written exactly.
 *
 * The incremental forms: every split point of a message of three blocks
 * and a few bytes into two updates; init_from a single-way context at
 * every pending length, followed by lengths that cross block boundaries,
 * with the source context left unchanged and still usable; a context
 * forked with memcpy and continued two ways; all lanes reading one
 * buffer.
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MULTIWAY_MAX_SMALL 4096

static void run_multiway(validation_suite *s, int x4, int kernel)
{
    const hash_alg *single = &HASH_ALGS[x4 ? 3 : 1];
    size_t block = x4 ? 128 : 64;
    size_t ways = x4 ? 4 : 8;
    size_t lane_bytes = x4 ? NIRAPOD_SHA2_SHA512_BYTES : NIRAPOD_SHA2_SHA256_BYTES;
    size_t out_len = x4 ? NIRAPOD_SHA2_SHA512_X4_BYTES : NIRAPOD_SHA2_SHA256_X8_BYTES;
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    size_t boundaries[128], nb, m;
    size_t large = validation.large_bytes < (1u << 20) ? validation.large_bytes : (1u << 20);
    uint8_t *buf, *out;
    uint8_t one[64];
    validation_rng rng;
    size_t cases;

    if (large < 4096) {
        large = 4096;
    }
    buf = xmalloc(ways * (large + 1));
    out = xmalloc(out_len + 16);
    nb = validation_boundaries(block, boundaries, 128);
    rng_seed(&rng, UINT64_C(0x8a00000) + (uint64_t)x4 + (uint64_t)(kernel + 2));

    for (cases = 0; cases < nb + validation.iterations + 1; cases++) {
        size_t len = cases < nb ? boundaries[cases]
                                : (cases == nb + validation.iterations
                                       ? large
                                       : rng_length(&rng, block, 8));
        int ok = 1;
        int rc;

        if (len > large) {
            die("multiway: length %zu exceeds the buffer", len);
        }
        if (cases < nb || cases == nb + validation.iterations) {
            for (m = 0; m < ways; m++) {
                fill_pattern(buf + m * len, len, (unsigned)(31 + m));
            }
        } else {
            rng_bytes(&rng, buf, len * ways);
        }
        guard_fill(out, out_len + 16);
        rc = multiway_oneshot(x4, kernel, out, len == 0 ? NULL : buf, len);
        if (rc != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: length %zu returned %d", name, len, rc);
            continue;
        }
        if (!guard_intact(out + out_len, 16)) {
            fail_case(s, kernel, "%s: length %zu wrote past the output", name, len);
        } else {
            count_pass(s, kernel);
        }
        for (m = 0; m < ways; m++) {
            rc = hash_oneshot(single, kernel, one, len == 0 ? NULL : buf + m * len, len);
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: length %zu lane %zu single hash returned %d", name,
                          len, m, rc);
                ok = 0;
                continue;
            }
            if (!check_bytes(s, kernel, out + m * lane_bytes, one, lane_bytes,
                             "%s: length %zu lane %zu", name, len, m)) {
                ok = 0;
            }
        }
        (void)ok;
    }
    free(buf);
    free(out);
}

/* Lane m of a packed buffer: buf + m len. */
static void lane_table(const uint8_t **t, const uint8_t *buf, size_t len)
{
    size_t m;

    for (m = 0; m < 8; m++) {
        t[m] = buf + m * len;
    }
}

/* The digests of the one-shot single-way hash of each lane's message. */
static int lane_digests(int x4, int kernel, uint8_t *out, const uint8_t *const *t, size_t len)
{
    const hash_alg *single = &HASH_ALGS[x4 ? 3 : 1];
    size_t ways = x4 ? 4 : 8;
    size_t lane_bytes = x4 ? 64 : 32;
    size_t m;

    for (m = 0; m < ways; m++) {
        if (hash_oneshot(single, kernel, out + m * lane_bytes, t[m], len) != NIRAPOD_SHA2_OK) {
            return 0;
        }
    }
    return 1;
}

static void run_multiway_splits(validation_suite *s, int x4, int kernel)
{
    size_t block = x4 ? 128 : 64;
    size_t len = 3 * block + 5;
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    uint8_t *buf = xmalloc(8 * len);
    const uint8_t *a[8], *b[8];
    uint8_t want[256], got[256 + 16];
    validation_ctx c;
    size_t cut, m;

    for (m = 0; m < 8; m++) {
        fill_pattern(buf + m * len, len, (unsigned)(71 + m));
    }
    lane_table(a, buf, len);
    if (!lane_digests(x4, kernel, want, a, len)) {
        fail_case(s, kernel, "%s: single-way reference failed", name);
        free(buf);
        return;
    }
    for (cut = 0; cut <= len; cut++) {
        for (m = 0; m < 8; m++) {
            b[m] = a[m] + cut;
        }
        guard_fill(got, sizeof got);
        if (multiway_init(x4, kernel, &c) != NIRAPOD_SHA2_OK ||
            multiway_update(x4, kernel, &c, a, cut) != NIRAPOD_SHA2_OK ||
            multiway_update(x4, kernel, &c, b, len - cut) != NIRAPOD_SHA2_OK ||
            multiway_final(x4, kernel, &c, got) != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: split at %zu returned an error", name, cut);
            continue;
        }
        check_bytes(s, kernel, got, want, 256, "%s: split at %zu", name, cut);
        check(s, kernel, guard_intact(got + 256, 16), "%s: split at %zu wrote past out", name,
              cut);
    }
    free(buf);
}

static void run_multiway_from(validation_suite *s, int x4, int kernel)
{
    const hash_alg *single = &HASH_ALGS[x4 ? 3 : 1];
    size_t block = x4 ? 128 : 64;
    size_t ways = x4 ? 4 : 8;
    size_t lane_bytes = x4 ? 64 : 32;
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    size_t plens[160], np = 0, p, i, m;
    size_t lens[5];
    size_t maxlen = 3 * block + 1;
    uint8_t *pre = xmalloc(3 * block);
    uint8_t *buf = xmalloc(8 * maxlen);
    uint8_t *joined = xmalloc(3 * block + maxlen);
    uint8_t got[256], one[64];
    validation_ctx src, keep, c;
    const uint8_t *t[8];

    for (p = 0; p < block; p++) {
        plens[np++] = p;
    }
    plens[np++] = block;
    plens[np++] = 2 * block + 3;
    fill_pattern(pre, 3 * block, 5);

    for (i = 0; i < np; i++) {
        size_t plen = plens[i];
        size_t j;

        lens[0] = 0;
        lens[1] = 1;
        lens[2] = block - plen % block;
        lens[3] = block;
        lens[4] = 2 * block + 1;
        for (j = 0; j < 5; j++) {
            size_t len = lens[j];

            for (m = 0; m < ways; m++) {
                fill_pattern(buf + m * len, len, (unsigned)(plen * 7 + j * 3 + m));
            }
            lane_table(t, buf, len);
            if (hash_init(single, kernel, &src) != NIRAPOD_SHA2_OK ||
                hash_update(single, kernel, &src, pre, plen) != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: source context failed", name);
                continue;
            }
            keep = src;
            if (multiway_init_from(x4, kernel, &c, &src) != NIRAPOD_SHA2_OK ||
                multiway_update(x4, kernel, &c, t, len) != NIRAPOD_SHA2_OK ||
                multiway_final(x4, kernel, &c, got) != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: from %zu bytes, length %zu returned an error", name,
                          plen, len);
                continue;
            }
            check(s, kernel, memcmp(&src, &keep, single->ctx_len) == 0,
                  "%s: init_from changed its source (%zu bytes)", name, plen);
            for (m = 0; m < ways; m++) {
                memcpy(joined, pre, plen);
                memcpy(joined + plen, t[m], len);
                if (hash_oneshot(single, kernel, one, joined, plen + len) != NIRAPOD_SHA2_OK) {
                    fail_case(s, kernel, "%s: single-way reference failed", name);
                    continue;
                }
                check_bytes(s, kernel, got + m * lane_bytes, one, lane_bytes,
                            "%s: from %zu bytes, length %zu, lane %zu", name, plen, len, m);
            }
            /* The source still finishes its own hash. */
            if (hash_final(single, kernel, &src, one) == NIRAPOD_SHA2_OK &&
                hash_oneshot(single, kernel, got, pre, plen) == NIRAPOD_SHA2_OK) {
                check_bytes(s, kernel, one, got, lane_bytes,
                            "%s: source after init_from (%zu bytes)", name, plen);
            } else {
                fail_case(s, kernel, "%s: source after init_from failed", name);
            }
        }
    }
    free(pre);
    free(buf);
    free(joined);
}

static void run_multiway_fork_and_alias(validation_suite *s, int x4, int kernel)
{
    size_t block = x4 ? 128 : 64;
    size_t ways = x4 ? 4 : 8;
    size_t len = 2 * block + 9;
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    uint8_t *buf = xmalloc(16 * len);
    const uint8_t *a[8], *b[8], *one[8];
    uint8_t want[256], got[256];
    validation_ctx c, fork;
    size_t m;

    for (m = 0; m < 16; m++) {
        fill_pattern(buf + m * len, len, (unsigned)(201 + m));
    }

    /* Fork after a first update; continue with two different second halves. */
    lane_table(a, buf, len);
    lane_table(b, buf + 8 * len, len);
    if (multiway_init(x4, kernel, &c) != NIRAPOD_SHA2_OK ||
        multiway_update(x4, kernel, &c, a, block + 3) != NIRAPOD_SHA2_OK) {
        fail_case(s, kernel, "%s: fork setup failed", name);
    } else {
        const uint8_t *a2[8], *b2[8];
        uint8_t *joined = xmalloc(2 * len);

        fork = c;
        for (m = 0; m < 8; m++) {
            a2[m] = a[m] + block + 3;
            b2[m] = b[m];
        }
        if (multiway_update(x4, kernel, &c, a2, len - block - 3) != NIRAPOD_SHA2_OK ||
            multiway_final(x4, kernel, &c, got) != NIRAPOD_SHA2_OK ||
            !lane_digests(x4, kernel, want, a, len)) {
            fail_case(s, kernel, "%s: fork, first branch failed", name);
        } else {
            check_bytes(s, kernel, got, want, 256, "%s: fork, first branch", name);
        }
        if (multiway_update(x4, kernel, &fork, b2, len) != NIRAPOD_SHA2_OK ||
            multiway_final(x4, kernel, &fork, got) != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: fork, second branch failed", name);
        } else {
            const hash_alg *single = &HASH_ALGS[x4 ? 3 : 1];
            size_t lane_bytes = x4 ? 64 : 32;
            uint8_t d[64];

            for (m = 0; m < ways; m++) {
                memcpy(joined, a[m], block + 3);
                memcpy(joined + block + 3, b[m], len);
                if (hash_oneshot(single, kernel, d, joined, block + 3 + len) == NIRAPOD_SHA2_OK) {
                    check_bytes(s, kernel, got + m * lane_bytes, d, lane_bytes,
                                "%s: fork, second branch, lane %zu", name, m);
                }
            }
        }
        free(joined);
    }

    /* Every lane reading the same buffer. */
    for (m = 0; m < 8; m++) {
        one[m] = buf;
    }
    if (multiway_lanes(x4, kernel, got, one, len) != NIRAPOD_SHA2_OK ||
        !lane_digests(x4, kernel, want, one, len)) {
        fail_case(s, kernel, "%s: lanes sharing one buffer failed", name);
    } else {
        check_bytes(s, kernel, got, want, 256, "%s: lanes sharing one buffer", name);
    }
    /* Lanes overlapping each other by one byte. */
    for (m = 0; m < 8; m++) {
        one[m] = buf + m * (len - 1);
    }
    if (multiway_lanes(x4, kernel, got, one, len) != NIRAPOD_SHA2_OK ||
        !lane_digests(x4, kernel, want, one, len)) {
        fail_case(s, kernel, "%s: overlapping lanes failed", name);
    } else {
        check_bytes(s, kernel, got, want, 256, "%s: overlapping lanes", name);
    }
    free(buf);
}

int suite_multiway(void)
{
    validation_suite s;
    int k;

    suite_begin(&s, "multiway");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        int x4;

        for (x4 = 0; x4 <= 1; x4++) {
            if (validation_usable(&s, target, x4 ? NIRAPOD_SHA2_TESTING_FAMILY_X4
                                                  : NIRAPOD_SHA2_TESTING_FAMILY_X8)) {
                run_multiway(&s, x4, target);
                run_multiway_splits(&s, x4, target);
                run_multiway_from(&s, x4, target);
                run_multiway_fork_and_alias(&s, x4, target);
            }
        }
    }
    return suite_end(&s);
}
