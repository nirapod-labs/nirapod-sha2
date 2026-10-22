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
 *
 * Negative controls, on the first case of each function with a nonempty
 * message, through the public functions: the oracle answers with one more
 * oracle added that answers a digest with one bit flipped must be rejected
 * as a disagreement; the comparison of the target's answer with the agreed
 * answer, one bit flipped, must fail; and the same pieces absorbed with
 * one byte of the first nonempty piece left out, as an update that lost a
 * byte at a boundary would, must fail against the oracles.
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

/* One drawn case: the function, the lengths and the update boundaries. */
typedef struct fuzz_case {
    const hash_alg *ha;
    const hmac_alg *ma;
    const uint8_t *msg, *key;
    size_t len, key_len;
    size_t bounds[FUZZ_MAX_PIECES + 1], pieces, fork_at;
} fuzz_case;

/*
 * Absorbs the case on target in its pieces, copying the context before
 * piece fork_at, and finishes both. With lose set, the first nonempty
 * piece is passed one byte short (the negative control). Returns the
 * first error code, else NIRAPOD_SHA2_OK with *forked set when out2
 * holds the copy's answer.
 */
static int absorb(const fuzz_case *fc, int target, int lose, uint8_t *out, uint8_t *out2,
                  int *forked)
{
    const hash_alg *ha = fc->ha;
    const hmac_alg *ma = fc->ma;
    validation_ctx ctx, copy;
    size_t at = 0, b;
    int rc;

    *forked = 0;
    rc = ma != NULL ? hmac_init(ma, target, &ctx, fc->key_len ? fc->key : NULL, fc->key_len)
                    : hash_init(ha, target, &ctx);
    for (b = 0; rc == NIRAPOD_SHA2_OK && b < fc->pieces; b++) {
        size_t n = fc->bounds[b] - at;
        const uint8_t *p = n ? fc->msg + at : NULL;

        if (b == fc->fork_at) {
            memcpy(&copy, &ctx, sizeof ctx);
            *forked = 1;
        }
        if (lose && n != 0) {
            n--;
            lose = 0;
        }
        rc = ma != NULL ? hmac_update(ma, target, &ctx, p, n) : hash_update(ha, target, &ctx, p, n);
        if (rc == NIRAPOD_SHA2_OK && *forked) {
            rc = ma != NULL ? hmac_update(ma, target, &copy, p, n)
                            : hash_update(ha, target, &copy, p, n);
        }
        at = fc->bounds[b];
    }
    if (rc == NIRAPOD_SHA2_OK) {
        rc = ma != NULL ? hmac_final(ma, target, &ctx, out) : hash_final(ha, target, &ctx, out);
    }
    if (rc == NIRAPOD_SHA2_OK && *forked) {
        rc = ma != NULL ? hmac_final(ma, target, &copy, out2)
                        : hash_final(ha, target, &copy, out2);
    }
    return rc;
}

int suite_fuzz(void)
{
    validation_suite s;
    oracle *oracles[VALIDATION_MAX_ORACLES];
    static uint8_t msg[FUZZ_MAX_MSG], key[FUZZ_MAX_KEY];
    int controlled[8] = { 0 };
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
        uint8_t want[VALIDATION_MAX_DIGEST], wrong[VALIDATION_MAX_DIGEST];
        uint8_t answer[VALIDATION_MAX_ORACLES + 1][VALIDATION_MAX_DIGEST];
        int has[VALIDATION_MAX_ORACLES + 1];
        fuzz_case fc;
        size_t b, first = 0;
        int answered, failed = 0;

        memset(&fc, 0, sizeof fc);
        fc.ha = ha;
        fc.ma = ma;
        fc.msg = msg;
        fc.key = key;
        fc.len = rng_length(&rng, block, FUZZ_MAX_MSG / block - 1);
        fc.key_len = is_hmac ? rng_below(&rng, 3 * block + 9) : 0;
        if (fc.len > FUZZ_MAX_MSG || fc.key_len > FUZZ_MAX_KEY) {
            die("fuzz: case %zu: buffer too small", c);
        }
        rng_bytes(&rng, msg, fc.len);
        rng_bytes(&rng, key, fc.key_len);
        fc.pieces = 1 + rng_below(&rng, FUZZ_MAX_PIECES);
        for (b = 0; b + 1 < fc.pieces; b++) {
            fc.bounds[b] = draw_boundary(&rng, fc.len, block);
        }
        fc.bounds[fc.pieces - 1] = fc.len;
        qsort(fc.bounds, fc.pieces, sizeof fc.bounds[0], cmp_size);
        fc.fork_at = rng_below(&rng, fc.pieces + 1);

        for (o = 0; o < (size_t)validation.oracle_count; o++) {
            size_t got_len = 0;
            int rc = is_hmac
                         ? oracle_hmac(oracles[o], (unsigned)ma->oracle_id,
                                       fc.key_len ? key : NULL, fc.key_len,
                                       fc.len ? msg : NULL, fc.len, answer[o], &got_len)
                         : oracle_hash(oracles[o], (unsigned)ha->oracle_id,
                                       fc.len ? msg : NULL, fc.len, answer[o], &got_len);

            has[o] = rc == 1;
            if (rc < 0 || (rc == 1 && got_len != digest)) {
                fail_case(&s, VALIDATION_PUBLIC, "seed %#llx case %zu: %s: oracle %zu failed",
                          (unsigned long long)validation.seed, c, name, o);
                failed = 1;
                break;
            }
        }
        if (failed) {
            continue;
        }
        answered = oracle_consensus(answer[0], sizeof answer[0], has,
                                    (size_t)validation.oracle_count, digest, want, &first);
        if (answered < 0) {
            fail_case(&s, VALIDATION_PUBLIC, "seed %#llx case %zu: %s: oracles disagree",
                      (unsigned long long)validation.seed, c, name);
            continue;
        }
        if (answered == 0) {
            continue;
        }

        for (m = 0; m <= (size_t)VALIDATION_KERNELS; m++) {
            int target = m == VALIDATION_KERNELS ? VALIDATION_PUBLIC : (int)m;
            uint8_t out[VALIDATION_MAX_DIGEST], out2[VALIDATION_MAX_DIGEST];
            int rc, forked;

            if (!validation_usable(&s, target, family)) {
                continue;
            }
            rc = absorb(&fc, target, 0, out, out2, &forked);
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(&s, target, "seed %#llx case %zu: %s len %zu key %zu: returned %d",
                          (unsigned long long)validation.seed, c, name, fc.len, fc.key_len, rc);
                continue;
            }
            check_bytes(&s, target, out, want, digest,
                        "seed %#llx case %zu: %s len %zu key %zu, %zu pieces",
                        (unsigned long long)validation.seed, c, name, fc.len, fc.key_len,
                        fc.pieces);
            if (forked) {
                check_bytes(&s, target, out2, want, digest,
                            "seed %#llx case %zu: %s len %zu key %zu, copy at piece %zu",
                            (unsigned long long)validation.seed, c, name, fc.len, fc.key_len,
                            fc.fork_at);
            }
        }

        if (!controlled[which] && fc.len != 0) {
            uint8_t out[VALIDATION_MAX_DIGEST], out2[VALIDATION_MAX_DIGEST];
            validation_suite k;
            int forked, lose;

            controlled[which] = 1;

            /* One more oracle, whose answer has one bit flipped. */
            o = (size_t)validation.oracle_count;
            memcpy(answer[o], want, digest);
            answer[o][digest / 2] ^= 0x10;
            has[o] = 1;
            control_record(&s,
                           oracle_consensus(answer[0], sizeof answer[0], has, o + 1, digest,
                                            wrong, &first) < 0,
                           "case %zu: %s: an oracle answering a wrong digest", c, name);

            /*
             * The comparison against the agreed answer with one bit flipped,
             * then an absorb that loses one byte against the agreed answer.
             * An error from the absorb is not a rejection by the comparison,
             * so it counts as a control not rejected.
             */
            memcpy(wrong, want, digest);
            wrong[digest - 1] ^= 0x01;
            for (lose = 0; lose <= 1; lose++) {
                int rc = absorb(&fc, VALIDATION_PUBLIC, lose, out, out2, &forked);

                control_begin(&k, &s);
                if (rc == NIRAPOD_SHA2_OK) {
                    check_bytes(&k, VALIDATION_PUBLIC, out, lose ? want : wrong, digest,
                                "case %zu", c);
                }
                if (lose) {
                    control_end(&s, &k, "case %zu: %s len %zu: an update one byte short", c,
                                name, fc.len);
                } else {
                    control_end(&s, &k, "case %zu: %s: a digest with one bit flipped", c, name);
                }
            }
        }
    }

    for (o = 0; o < (size_t)validation.oracle_count; o++) {
        oracle_stop(oracles[o]);
    }
    return suite_end(&s);
}
