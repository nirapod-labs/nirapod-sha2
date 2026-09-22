/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * bounds.c
 * ========
 *
 * Message and key lengths around every padding edge of both block sizes,
 * the empty message and a large message. For each length the one-shot and
 * the incremental form must agree, on every kernel and through the public
 * functions. The differential suite checks the same lengths against an
 * independent implementation.
 *
 * Password hashing is not involved, so the key lengths are the HMAC key
 * block edges: the block itself, one byte either side, and two blocks.
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BOUNDS_MAX_MESSAGE 1024
#define BOUNDS_MAX_KEY 512

static void bounds_hash(validation_suite *s, const hash_alg *a, int kernel, uint8_t *msg,
                        size_t msg_cap)
{
    size_t lengths[128];
    size_t n, i;
    uint8_t one[64], inc[64];
    validation_ctx c;

    n = validation_boundaries(a->block_len, lengths, sizeof lengths / sizeof lengths[0]);
    for (i = 0; i < n; i++) {
        size_t len = lengths[i];
        const uint8_t *in = len == 0 ? NULL : msg;
        int rc_one, rc_inc;

        if (len > msg_cap) {
            die("bounds: boundary %zu exceeds the message buffer", len);
        }
        rc_one = hash_oneshot(a, kernel, one, in, len);
        rc_inc = hash_init(a, kernel, &c);
        if (rc_inc == NIRAPOD_SHA2_OK) {
            rc_inc = hash_update(a, kernel, &c, in, len);
        }
        if (rc_inc == NIRAPOD_SHA2_OK) {
            rc_inc = hash_final(a, kernel, &c, inc);
        }
        if (rc_one != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: length %zu one-shot returned %d", a->name, len, rc_one);
            continue;
        }
        if (rc_inc != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: length %zu incremental returned %d", a->name, len, rc_inc);
            continue;
        }
        check_bytes(s, kernel, one, inc, a->digest_len,
                    "%s: length %zu one-shot and incremental", a->name, len);
    }
}

static void bounds_hmac(validation_suite *s, const hmac_alg *a, int kernel, uint8_t *key,
                        uint8_t *msg)
{
    static const size_t key_edges[] = { 0, 1, 2, 3, 55, 56, 63, 64, 65, 111, 112, 127,
                                        128, 129, 191, 192, 193, 255, 256, 257, 383, 384 };
    size_t lengths[128];
    size_t n, i, j;
    uint8_t one[64], inc[64];
    validation_ctx c;

    n = validation_boundaries(a->block_len, lengths, sizeof lengths / sizeof lengths[0]);
    for (j = 0; j < sizeof key_edges / sizeof key_edges[0]; j++) {
        size_t key_len = key_edges[j];
        const uint8_t *kp = key_len == 0 ? NULL : key;

        for (i = 0; i < n; i++) {
            size_t len = lengths[i];
            const uint8_t *mp = len == 0 ? NULL : msg;
            int rc_one, rc_inc;

            if (len > BOUNDS_MAX_MESSAGE) {
                die("bounds: HMAC message %zu exceeds the buffer", len);
            }
            rc_one = hmac_oneshot(a, kernel, one, kp, key_len, mp, len);
            rc_inc = hmac_init(a, kernel, &c, kp, key_len);
            if (rc_inc == NIRAPOD_SHA2_OK) {
                rc_inc = hmac_update(a, kernel, &c, mp, len);
            }
            if (rc_inc == NIRAPOD_SHA2_OK) {
                rc_inc = hmac_final(a, kernel, &c, inc);
            }
            if (rc_one != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: key %zu message %zu one-shot returned %d", a->name,
                          key_len, len, rc_one);
                continue;
            }
            if (rc_inc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: key %zu message %zu incremental returned %d", a->name,
                          key_len, len, rc_inc);
                continue;
            }
            check_bytes(s, kernel, one, inc, a->digest_len,
                        "%s: key %zu message %zu one-shot and incremental", a->name, key_len,
                        len);
        }
    }
}

static void bounds_large(validation_suite *s, int kernel)
{
    size_t large = validation.large_bytes;
    uint8_t *big;
    uint8_t one[64], inc[64];
    validation_ctx c;
    size_t i, off;

    if (large < (1u << 20)) {
        large = 1u << 20;
    }
    big = xmalloc(large + 1);
    fill_pattern(big, large, 7);

    for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
        const hash_alg *a = &HASH_ALGS[i];
        int rc_one, rc_inc = NIRAPOD_SHA2_OK;

        if (!validation_usable(s, kernel, a->family)) {
            continue;
        }
        rc_one = hash_oneshot(a, kernel, one, big, large);
        rc_inc = hash_init(a, kernel, &c);
        off = 0;
        while (rc_inc == NIRAPOD_SHA2_OK && off < large) {
            size_t chunk = large - off;

            if (chunk > 65521) {
                chunk = 65521;
            }
            rc_inc = hash_update(a, kernel, &c, big + off, chunk);
            off += chunk;
        }
        if (rc_inc == NIRAPOD_SHA2_OK) {
            rc_inc = hash_final(a, kernel, &c, inc);
        }
        if (rc_one != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: large one-shot returned %d", a->name, rc_one);
        } else if (rc_inc != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: large incremental returned %d", a->name, rc_inc);
        } else {
            check_bytes(s, kernel, one, inc, a->digest_len,
                        "%s: %zu-byte message one-shot and incremental", a->name, large);
        }
    }
    free(big);
}

int suite_bounds(void)
{
    validation_suite s;
    uint8_t *msg = xmalloc(BOUNDS_MAX_MESSAGE);
    uint8_t *key = xmalloc(BOUNDS_MAX_KEY);
    int k;
    size_t i;

    suite_begin(&s, "bounds");
    fill_pattern(msg, BOUNDS_MAX_MESSAGE, 11);
    fill_pattern(key, BOUNDS_MAX_KEY, 29);

    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
            if (validation_usable(&s, target, HASH_ALGS[i].family)) {
                bounds_hash(&s, &HASH_ALGS[i], target, msg, BOUNDS_MAX_MESSAGE);
            }
        }
        for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
            if (validation_usable(&s, target, HMAC_ALGS[i].family)) {
                bounds_hmac(&s, &HMAC_ALGS[i], target, key, msg);
            }
        }
        if (validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_SHA256) ||
            validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_SHA512)) {
            bounds_large(&s, target);
        }
    }

    free(msg);
    free(key);
    return suite_end(&s);
}
