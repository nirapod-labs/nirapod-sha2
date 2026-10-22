/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * fuzz.c
 * ======
 *
 * Seeded random testing of the incremental functions against the oracles.
 * Each case draws a function (one of the six hashes or two HMACs), a
 * message length, a key length for HMAC, the message and key bytes, a set
 * of update boundaries and a point at which the context is copied with
 * memcpy. Every target absorbs the message in those pieces, the copy is
 * finished as well as the original, and both must equal the one-shot
 * answer of every oracle that implements the function.
 *
 * The splits suite compares the incremental and one-shot functions with
 * each other, and the differential suite compares the one-shot functions
 * with the oracles; this suite closes the remaining side, the incremental
 * path with random boundaries against an implementation that is not this
 * library.
 *
 * Why not a coverage-guided fuzzer: the code under test branches only on
 * lengths, counts and buffer offsets, never on message or key bytes (the
 * constant-time checks hold it to that), so coverage feedback over input
 * bytes has nothing to steer by. The space that matters is lengths and
 * boundaries, and it is sampled here directly, with the boundaries biased
 * towards block edges.
 *
 * The run is fixed by --seed (default FUZZ_SEED) and the case count
 * (--fuzz-cases, default 20000); a failure prints the seed, the case
 * number and its parameters, which reproduce it.
 */

#include "validation.h"
#include "oracle.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FUZZ_MAX_MSG 5000
#define FUZZ_MAX_KEY 400
#define FUZZ_MAX_PIECES 9

/* A boundary near a block edge most of the time, anywhere otherwise. */
static size_t draw_boundary(validation_rng *rng, size_t len, size_t block)
{
    size_t b;

    if (len == 0) {
        return 0;
    }
    if (rng_below(rng, 4) != 0) {
        size_t edge = block * rng_below(rng, len / block + 2);
        size_t off = rng_below(rng, 5);

        b = rng_below(rng, 2) ? edge + off : (edge >= off ? edge - off : 0);
    } else {
        b = rng_below(rng, len + 1);
    }
    return b > len ? len : b;
}

static int cmp_size(const void *a, const void *b)
{
    size_t x = *(const size_t *)a, y = *(const size_t *)b;

    return x < y ? -1 : x > y;
}

int suite_fuzz(void)
{
    validation_suite s;
    oracle *oracles[VALIDATION_MAX_ORACLES];
    static uint8_t msg[FUZZ_MAX_MSG], key[FUZZ_MAX_KEY];
    validation_rng rng;
    size_t c, o, m;

    suite_begin(&s, "fuzz");
    if (validation.oracle_count == 0) {
        printf("suite fuzz\n");
        printf("  oracle %-15s SKIP (no oracle binary named)\n", "none");
        printf("  %-22s %s\n", "suite total", validation.require_oracle ? "FAIL" : "SKIP");
        return validation.require_oracle ? 1 : 0;
    }
    for (o = 0; o < (size_t)validation.oracle_count; o++) {
        oracles[o] = oracle_start(validation.oracle[o]);
        if (oracles[o] == NULL) {
            die("cannot start oracle %s", validation.oracle[o]);
        }
    }
    printf("  fuzz: seed %#llx, %zu cases\n", (unsigned long long)validation.seed,
           validation.fuzz_cases);
    fflush(stdout);
    rng_seed(&rng, validation.seed);

    for (c = 0; c < validation.fuzz_cases; c++) {
        size_t which = rng_below(&rng, 8);
        int is_hmac = which >= 6;
        const hash_alg *ha = is_hmac ? NULL : &HASH_ALGS[which];
        const hmac_alg *ma = is_hmac ? &HMAC_ALGS[which - 6] : NULL;
        const char *name = is_hmac ? ma->name : ha->name;
        size_t block = is_hmac ? ma->block_len : ha->block_len;
        size_t digest = is_hmac ? ma->digest_len : ha->digest_len;
        nirapod_sha2_testing_family family = is_hmac ? ma->family : ha->family;
        size_t len = rng_length(&rng, block, FUZZ_MAX_MSG / block - 1);
        size_t key_len = is_hmac ? rng_below(&rng, 3 * block + 9) : 0;
        size_t bounds[FUZZ_MAX_PIECES + 1], pieces, fork_at, b;
        uint8_t want[VALIDATION_MAX_DIGEST];
        size_t answered = 0;

        if (len > FUZZ_MAX_MSG || key_len > FUZZ_MAX_KEY) {
            die("fuzz: case %zu: buffer too small", c);
        }
        rng_bytes(&rng, msg, len);
        rng_bytes(&rng, key, key_len);
        pieces = 1 + rng_below(&rng, FUZZ_MAX_PIECES);
        for (b = 0; b + 1 < pieces; b++) {
            bounds[b] = draw_boundary(&rng, len, block);
        }
        bounds[pieces - 1] = len;
        qsort(bounds, pieces, sizeof bounds[0], cmp_size);
        fork_at = rng_below(&rng, pieces + 1);

        for (o = 0; o < (size_t)validation.oracle_count; o++) {
            uint8_t got[VALIDATION_MAX_DIGEST];
            size_t got_len = 0;
            int rc = is_hmac
                         ? oracle_hmac(oracles[o], (unsigned)ma->oracle_id,
                                       key_len ? key : NULL, key_len, len ? msg : NULL, len,
                                       got, &got_len)
                         : oracle_hash(oracles[o], (unsigned)ha->oracle_id, len ? msg : NULL,
                                       len, got, &got_len);

            if (rc < 0 || (rc == 1 && got_len != digest)) {
                fail_case(&s, VALIDATION_PUBLIC, "seed %#llx case %zu: %s: oracle %zu failed",
                          (unsigned long long)validation.seed, c, name, o);
                answered = 0;
                break;
            }
            if (rc == 1) {
                if (answered > 0 && memcmp(want, got, digest) != 0) {
                    fail_case(&s, VALIDATION_PUBLIC, "seed %#llx case %zu: %s: oracles disagree",
                              (unsigned long long)validation.seed, c, name);
                    answered = 0;
                    break;
                }
                memcpy(want, got, digest);
                answered++;
            }
        }
        if (answered == 0) {
            continue;
        }

        for (m = 0; m <= (size_t)VALIDATION_KERNELS; m++) {
            int target = m == VALIDATION_KERNELS ? VALIDATION_PUBLIC : (int)m;
            validation_ctx ctx, copy;
            uint8_t out[VALIDATION_MAX_DIGEST], out2[VALIDATION_MAX_DIGEST];
            size_t at = 0;
            int rc, forked = 0;

            if (!validation_usable(&s, target, family)) {
                continue;
            }
            rc = is_hmac ? hmac_init(ma, target, &ctx, key_len ? key : NULL, key_len)
                         : hash_init(ha, target, &ctx);
            for (b = 0; rc == NIRAPOD_SHA2_OK && b < pieces; b++) {
                size_t n = bounds[b] - at;

                if (b == fork_at) {
                    memcpy(&copy, &ctx, sizeof ctx);
                    forked = 1;
                }
                rc = is_hmac ? hmac_update(ma, target, &ctx, n ? msg + at : NULL, n)
                             : hash_update(ha, target, &ctx, n ? msg + at : NULL, n);
                if (rc == NIRAPOD_SHA2_OK && forked) {
                    rc = is_hmac ? hmac_update(ma, target, &copy, n ? msg + at : NULL, n)
                                 : hash_update(ha, target, &copy, n ? msg + at : NULL, n);
                }
                at = bounds[b];
            }
            if (rc == NIRAPOD_SHA2_OK) {
                rc = is_hmac ? hmac_final(ma, target, &ctx, out)
                             : hash_final(ha, target, &ctx, out);
            }
            if (rc == NIRAPOD_SHA2_OK && forked) {
                rc = is_hmac ? hmac_final(ma, target, &copy, out2)
                             : hash_final(ha, target, &copy, out2);
            }
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(&s, target, "seed %#llx case %zu: %s len %zu key %zu: returned %d",
                          (unsigned long long)validation.seed, c, name, len, key_len, rc);
                continue;
            }
            check_bytes(&s, target, out, want, digest,
                        "seed %#llx case %zu: %s len %zu key %zu, %zu pieces",
                        (unsigned long long)validation.seed, c, name, len, key_len, pieces);
            if (forked) {
                check_bytes(&s, target, out2, want, digest,
                            "seed %#llx case %zu: %s len %zu key %zu, copy at piece %zu",
                            (unsigned long long)validation.seed, c, name, len, key_len, fork_at);
            }
        }
    }

    for (o = 0; o < (size_t)validation.oracle_count; o++) {
        oracle_stop(oracles[o]);
    }
    return suite_end(&s);
}
