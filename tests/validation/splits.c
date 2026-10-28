/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * splits.c
 * ========
 *
 * Incremental use against the one-shot form: every two-way split offset
 * of a message that spans several blocks, a three-way split whose middle
 * part is one block, byte-by-byte absorption, random multi-way splits,
 * and the documented copy of a context in mid-stream. The same coverage
 * is given to HMAC, with keys on both sides of the block boundary.
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SPLITS_MAX_MESSAGE 4096
#define SPLITS_MAX_KEY 512

static void splits_hash(validation_suite *s, const hash_alg *a, int kernel, uint8_t *msg)
{
    size_t len = 3 * a->block_len + 7;
    uint8_t one[64], got[64];
    validation_ctx c, fork_ctx;
    validation_rng rng;
    size_t j, i;
    int rc;

    fill_pattern(msg, len, 41);
    rc = hash_oneshot(a, kernel, one, msg, len);
    if (rc != NIRAPOD_SHA2_OK) {
        fail_case(s, kernel, "%s: one-shot returned %d", a->name, rc);
        return;
    }

    /* Every two-way split, including both empty pieces. */
    for (j = 0; j <= len; j++) {
        int ok = hash_init(a, kernel, &c) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, j == 0 ? NULL : msg, j) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, j == len ? NULL : msg + j, len - j) ==
                     NIRAPOD_SHA2_OK &&
                 hash_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: split at %zu returned an error", a->name, j);
            continue;
        }
        check_bytes(s, kernel, got, one, a->digest_len, "%s: split at %zu", a->name, j);
    }

    /* A block-sized middle piece, moved across the message. */
    for (j = 0; j + a->block_len <= len; j++) {
        size_t mid = j + a->block_len;
        int ok = hash_init(a, kernel, &c) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, j == 0 ? NULL : msg, j) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, msg + j, a->block_len) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, mid == len ? NULL : msg + mid, len - mid) ==
                     NIRAPOD_SHA2_OK &&
                 hash_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: three-way split at %zu returned an error", a->name, j);
            continue;
        }
        check_bytes(s, kernel, got, one, a->digest_len, "%s: three-way split at %zu", a->name,
                    j);
    }

    /* One byte per update, with an empty update between. */
    {
        int ok = hash_init(a, kernel, &c) == NIRAPOD_SHA2_OK;

        for (i = 0; i < len && ok; i++) {
            ok = hash_update(a, kernel, &c, msg + i, 1) == NIRAPOD_SHA2_OK &&
                 hash_update(a, kernel, &c, NULL, 0) == NIRAPOD_SHA2_OK;
        }
        ok = ok && hash_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: byte by byte returned an error", a->name);
        } else {
            check_bytes(s, kernel, got, one, a->digest_len, "%s: byte by byte", a->name);
        }
    }

    /* Random multi-way splits with random lengths. */
    rng_seed(&rng, UINT64_C(0x5100000) + (uint64_t)(a - HASH_ALGS) * 131 +
                       (uint64_t)(kernel + 2));
    for (i = 0; i < validation.iterations; i++) {
        size_t n = rng_length(&rng, a->block_len, 4);
        size_t pieces = 1 + rng_below(&rng, 8);
        size_t off = 0, p;
        int ok;

        if (n > SPLITS_MAX_MESSAGE) {
            n = SPLITS_MAX_MESSAGE;
        }
        rng_bytes(&rng, msg, n);
        ok = hash_oneshot(a, kernel, one, n == 0 ? NULL : msg, n) == NIRAPOD_SHA2_OK &&
             hash_init(a, kernel, &c) == NIRAPOD_SHA2_OK;
        for (p = 0; p < pieces && ok; p++) {
            size_t take;

            if (p + 1 == pieces) {
                take = n - off;
            } else {
                take = rng_below(&rng, n - off + 1);
            }
            ok = hash_update(a, kernel, &c, take == 0 ? NULL : msg + off, take) ==
                 NIRAPOD_SHA2_OK;
            off += take;
            if (rng_below(&rng, 3) == 0) {
                ok = ok && hash_update(a, kernel, &c, NULL, 0) == NIRAPOD_SHA2_OK;
            }
        }
        ok = ok && off == n && hash_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: random split %zu (length %zu) returned an error", a->name,
                      i, n);
        } else {
            check_bytes(s, kernel, got, one, a->digest_len,
                        "%s: random split %zu (length %zu)", a->name, i, n);
        }
    }

    /* Copying a context forks the hash (nirapod/sha2.h, "Contexts"). The
     * random loop above left the one-shot digest of another message in
     * one, so compute it again. */
    {
        size_t half = len / 2;
        int ok;

        memset(&c, 0, sizeof c);
        ok = hash_oneshot(a, kernel, one, msg, len) == NIRAPOD_SHA2_OK &&
             hash_init(a, kernel, &c) == NIRAPOD_SHA2_OK &&
             hash_update(a, kernel, &c, msg, half) == NIRAPOD_SHA2_OK;
        memcpy(&fork_ctx, &c, sizeof c);
        ok = ok && hash_update(a, kernel, &c, msg + half, len - half) == NIRAPOD_SHA2_OK &&
             hash_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: context copy, first stream, returned an error", a->name);
        } else {
            check_bytes(s, kernel, got, one, a->digest_len, "%s: context copy, full stream",
                        a->name);
        }
        ok = hash_final(a, kernel, &fork_ctx, got) == NIRAPOD_SHA2_OK &&
             hash_oneshot(a, kernel, one, msg, half) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: context copy, forked stream, returned an error", a->name);
        } else {
            check_bytes(s, kernel, got, one, a->digest_len, "%s: context copy, forked stream",
                        a->name);
        }
    }
}

static void splits_hmac(validation_suite *s, const hmac_alg *a, int kernel, uint8_t *msg,
                        uint8_t *key)
{
    static const size_t key_lens[] = { 0, 1, 63, 64, 65, 127, 128, 129, 300 };
    size_t len = 3 * a->block_len + 7;
    uint8_t one[64], got[64];
    validation_ctx c, fork_ctx;
    validation_rng rng;
    size_t j, i, kk;
    int rc;

    fill_pattern(msg, len, 53);
    fill_pattern(key, SPLITS_MAX_KEY, 67);

    for (kk = 0; kk < sizeof key_lens / sizeof key_lens[0]; kk++) {
        size_t key_len = key_lens[kk];
        const uint8_t *kp = key_len == 0 ? NULL : key;

        rc = hmac_oneshot(a, kernel, one, kp, key_len, msg, len);
        if (rc != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "%s: key %zu one-shot returned %d", a->name, key_len, rc);
            continue;
        }
        for (j = 0; j <= len; j++) {
            int ok = hmac_init(a, kernel, &c, kp, key_len) == NIRAPOD_SHA2_OK &&
                     hmac_update(a, kernel, &c, j == 0 ? NULL : msg, j) == NIRAPOD_SHA2_OK &&
                     hmac_update(a, kernel, &c, j == len ? NULL : msg + j, len - j) ==
                         NIRAPOD_SHA2_OK &&
                     hmac_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
            if (!ok) {
                fail_case(s, kernel, "%s: key %zu split at %zu returned an error", a->name,
                          key_len, j);
                continue;
            }
            check_bytes(s, kernel, got, one, a->digest_len, "%s: key %zu split at %zu", a->name,
                        key_len, j);
        }

        /* A context copy after half the message. */
        {
            size_t half = len / 2;
            int ok;

            memset(&c, 0, sizeof c);
            ok = hmac_init(a, kernel, &c, kp, key_len) == NIRAPOD_SHA2_OK &&
                 hmac_update(a, kernel, &c, msg, half) == NIRAPOD_SHA2_OK;
            memcpy(&fork_ctx, &c, sizeof c);
            ok = ok && hmac_update(a, kernel, &c, msg + half, len - half) == NIRAPOD_SHA2_OK &&
                 hmac_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
            if (!ok) {
                fail_case(s, kernel, "%s: key %zu context copy returned an error", a->name,
                          key_len);
            } else {
                check_bytes(s, kernel, got, one, a->digest_len,
                            "%s: key %zu context copy, full stream", a->name, key_len);
            }
            ok = hmac_final(a, kernel, &fork_ctx, got) == NIRAPOD_SHA2_OK &&
                 hmac_oneshot(a, kernel, one, kp, key_len, msg, half) == NIRAPOD_SHA2_OK;
            if (!ok) {
                fail_case(s, kernel, "%s: key %zu forked copy returned an error", a->name,
                          key_len);
            } else {
                check_bytes(s, kernel, got, one, a->digest_len,
                            "%s: key %zu context copy, forked stream", a->name, key_len);
            }
        }
    }

    /* Random multi-way splits: random key and message lengths. */
    rng_seed(&rng, UINT64_C(0x5200000) + (uint64_t)(a - HMAC_ALGS) * 131 +
                       (uint64_t)(kernel + 2));
    for (i = 0; i < validation.iterations; i++) {
        size_t key_len = rng_below(&rng, 2 * a->block_len + 9);
        size_t n = rng_length(&rng, a->block_len, 4);
        size_t pieces = 1 + rng_below(&rng, 8);
        size_t off = 0, p;
        int ok;

        if (n > SPLITS_MAX_MESSAGE) {
            n = SPLITS_MAX_MESSAGE;
        }
        rng_bytes(&rng, key, key_len);
        rng_bytes(&rng, msg, n);
        ok = hmac_oneshot(a, kernel, one, key_len == 0 ? NULL : key, key_len,
                          n == 0 ? NULL : msg, n) == NIRAPOD_SHA2_OK &&
             hmac_init(a, kernel, &c, key_len == 0 ? NULL : key, key_len) == NIRAPOD_SHA2_OK;
        for (p = 0; p < pieces && ok; p++) {
            size_t take = p + 1 == pieces ? n - off : rng_below(&rng, n - off + 1);

            ok = hmac_update(a, kernel, &c, take == 0 ? NULL : msg + off, take) ==
                 NIRAPOD_SHA2_OK;
            off += take;
            if (rng_below(&rng, 3) == 0) {
                ok = ok && hmac_update(a, kernel, &c, NULL, 0) == NIRAPOD_SHA2_OK;
            }
        }
        ok = ok && off == n && hmac_final(a, kernel, &c, got) == NIRAPOD_SHA2_OK;
        if (!ok) {
            fail_case(s, kernel, "%s: random split %zu (key %zu, message %zu) returned an error",
                      a->name, i, key_len, n);
        } else {
            check_bytes(s, kernel, got, one, a->digest_len,
                        "%s: random split %zu (key %zu, message %zu)", a->name, i, key_len, n);
        }
    }
}

int suite_splits(void)
{
    validation_suite s;
    uint8_t *msg = xmalloc(SPLITS_MAX_MESSAGE);
    uint8_t *key = xmalloc(SPLITS_MAX_KEY);
    int k;
    size_t i;

    suite_begin(&s, "splits");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
            if (validation_usable(&s, target, HASH_ALGS[i].family)) {
                splits_hash(&s, &HASH_ALGS[i], target, msg);
            }
        }
        for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
            if (validation_usable(&s, target, HMAC_ALGS[i].family)) {
                splits_hmac(&s, &HMAC_ALGS[i], target, msg, key);
            }
        }
    }
    free(msg);
    free(key);
    return suite_end(&s);
}
