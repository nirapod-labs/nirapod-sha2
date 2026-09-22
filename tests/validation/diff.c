/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * diff.c
 * ======
 *
 * Differential tests against independent implementations, one child
 * process each (oracle.c). Every oracle that supports an algorithm must
 * produce the same digest or tag as every kernel and as the public
 * functions, over the padding edges, random lengths and a large message.
 *
 * The oracle binaries are named on the command line. Their banners record
 * the implementation and version actually linked; the runner prints them
 * and the run log keeps them.
 */

#include "validation.h"
#include "oracle.h"
#include "oracle-protocol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DIFF_MAX_KEY 512

static oracle *oracles[VALIDATION_MAX_ORACLES];
static size_t oracle_count;

static void open_oracles(void)
{
    size_t i;

    for (i = 0; i < (size_t)validation.oracle_count; i++) {
        oracles[i] = oracle_start(validation.oracle[i]);
        if (oracles[i] == NULL) {
            die("cannot start oracle %s", validation.oracle[i]);
        }
        printf("  oracle %zu: %s\n", i, oracle_identity(oracles[i]));
        fflush(stdout);
    }
    oracle_count = (size_t)validation.oracle_count;
}

static void close_oracles(void)
{
    size_t i;

    for (i = 0; i < oracle_count; i++) {
        oracle_stop(oracles[i]);
        oracles[i] = NULL;
    }
    oracle_count = 0;
}

/*
 * Asks every oracle for the digest. Returns the number that answered and
 * stores each digest in expected[o]. Returns -1 when an oracle fails or
 * two oracles disagree.
 */
static int oracle_hashes(const hash_alg *a, const uint8_t *in, size_t len, uint8_t *expected,
                         size_t *lengths)
{
    size_t o;
    int answered = 0;

    for (o = 0; o < oracle_count; o++) {
        lengths[o] = 0;
    }
    for (o = 0; o < oracle_count; o++) {
        size_t got = 0;
        int rc;

        rc = oracle_hash(oracles[o], (unsigned)a->oracle_id, in, len, expected + o * 64, &got);
        if (rc < 0) {
            return -1;
        }
        if (rc == 0) {
            continue;
        }
        if (got != a->digest_len) {
            return -1;
        }
        lengths[o] = got;
        if (answered > 0) {
            size_t p;

            for (p = 0; p < oracle_count; p++) {
                if (p != o && lengths[p] == got &&
                    memcmp(expected + p * 64, expected + o * 64, got) != 0) {
                    return -1;
                }
            }
        }
        answered++;
    }
    return answered;
}

static int oracle_hmacs(const hmac_alg *a, const uint8_t *key, size_t key_len,
                        const uint8_t *msg, size_t msg_len, uint8_t *expected, size_t *lengths)
{
    size_t o;
    int answered = 0;

    for (o = 0; o < oracle_count; o++) {
        lengths[o] = 0;
    }
    for (o = 0; o < oracle_count; o++) {
        size_t got = 0;
        int rc;

        rc = oracle_hmac(oracles[o], (unsigned)a->oracle_id, key, key_len, msg, msg_len,
                         expected + o * 64, &got);
        if (rc < 0) {
            return -1;
        }
        if (rc == 0) {
            continue;
        }
        if (got != a->digest_len) {
            return -1;
        }
        lengths[o] = got;
        answered++;
    }
    return answered;
}

static void diff_hash(validation_suite *s)
{
    size_t boundaries[128], nb, i, m;
    uint8_t *msg;
    size_t msg_cap;
    validation_rng rng;

    msg_cap = validation.large_bytes > 4096 ? validation.large_bytes : 4096;
    msg = xmalloc(msg_cap);

    for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
        const hash_alg *a = &HASH_ALGS[i];
        size_t cases;

        nb = validation_boundaries(a->block_len, boundaries, 128);
        rng_seed(&rng, UINT64_C(0xd1ff0000) + (uint64_t)i);
        for (cases = 0; cases < nb + validation.iterations + 1; cases++) {
            size_t len = cases < nb ? boundaries[cases]
                                    : (cases == nb + validation.iterations
                                           ? validation.large_bytes
                                           : rng_length(&rng, a->block_len, 8));
            uint8_t expected[VALIDATION_MAX_ORACLES * 64];
            size_t lengths[VALIDATION_MAX_ORACLES];
            int answered;
            size_t o;

            if (len > msg_cap) {
                die("diff: length %zu exceeds the buffer", len);
            }
            if (cases < nb) {
                fill_pattern(msg, len, (unsigned)(37 + cases));
            } else if (cases != nb + validation.iterations) {
                rng_bytes(&rng, msg, len);
            }
            answered = oracle_hashes(a, len == 0 ? NULL : msg, len, expected, lengths);
            if (answered < 0) {
                fail_case(s, VALIDATION_PUBLIC, "%s: length %zu: an oracle failed or two "
                          "oracles disagree", a->name, len);
                continue;
            }
            for (m = 0; m <= (size_t)VALIDATION_KERNELS; m++) {
                int target = m == VALIDATION_KERNELS ? VALIDATION_PUBLIC : (int)m;
                uint8_t got[64];

                if (!validation_usable(s, target, a->family)) {
                    continue;
                }
                if (hash_oneshot(a, target, got, len == 0 ? NULL : msg, len) !=
                    NIRAPOD_SHA2_OK) {
                    fail_case(s, target, "%s: length %zu returned an error", a->name, len);
                    continue;
                }
                for (o = 0; o < oracle_count; o++) {
                    if (lengths[o] == 0) {
                        continue;
                    }
                    check_bytes(s, target, got, expected + o * 64, lengths[o],
                                "%s: length %zu against oracle %zu", a->name, len, o);
                }
            }
        }
    }
    free(msg);
}

static void diff_hmac(validation_suite *s)
{
    size_t boundaries[128], nb, i, m;
    uint8_t *msg;
    uint8_t key[DIFF_MAX_KEY];
    size_t msg_cap;
    validation_rng rng;

    msg_cap = validation.large_bytes > 4096 ? validation.large_bytes : 4096;
    msg = xmalloc(msg_cap);

    for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
        const hmac_alg *a = &HMAC_ALGS[i];
        size_t cases;

        nb = validation_boundaries(a->block_len, boundaries, 128);
        rng_seed(&rng, UINT64_C(0xd1ff1000) + (uint64_t)i);
        for (cases = 0; cases < nb + validation.iterations + 1; cases++) {
            size_t len = cases < nb ? boundaries[cases]
                                    : (cases == nb + validation.iterations
                                           ? validation.large_bytes
                                           : rng_length(&rng, a->block_len, 8));
            size_t key_len = cases % 2 == 0 ? 0 : (cases * 37) % (2 * a->block_len + 9);
            uint8_t expected[VALIDATION_MAX_ORACLES * 64];
            size_t lengths[VALIDATION_MAX_ORACLES];
            int answered;
            size_t o;

            if (len > msg_cap || key_len > sizeof key) {
                die("diff: HMAC buffer too small");
            }
            if (cases < nb) {
                fill_pattern(msg, len, (unsigned)(43 + cases));
                fill_pattern(key, key_len, (unsigned)(149 + cases));
            } else if (cases != nb + validation.iterations) {
                rng_bytes(&rng, msg, len);
                rng_bytes(&rng, key, key_len);
            }
            answered = oracle_hmacs(a, key_len == 0 ? NULL : key, key_len,
                                    len == 0 ? NULL : msg, len, expected, lengths);
            if (answered < 0) {
                fail_case(s, VALIDATION_PUBLIC, "%s: length %zu: an oracle failed", a->name,
                          len);
                continue;
            }
            for (m = 0; m <= (size_t)VALIDATION_KERNELS; m++) {
                int target = m == VALIDATION_KERNELS ? VALIDATION_PUBLIC : (int)m;
                uint8_t got[64];

                if (!validation_usable(s, target, a->family)) {
                    continue;
                }
                if (hmac_oneshot(a, target, got, key_len == 0 ? NULL : key, key_len,
                                 len == 0 ? NULL : msg, len) != NIRAPOD_SHA2_OK) {
                    fail_case(s, target, "%s: length %zu key %zu returned an error", a->name,
                              len, key_len);
                    continue;
                }
                for (o = 0; o < oracle_count; o++) {
                    if (lengths[o] == 0) {
                        continue;
                    }
                    check_bytes(s, target, got, expected + o * 64, lengths[o],
                                "%s: length %zu key %zu against oracle %zu", a->name, len,
                                key_len, o);
                }
            }
        }
    }
    free(msg);
}

int suite_oracle(void)
{
    validation_suite s;

    suite_begin(&s, "differential");
    if (validation.oracle_count == 0) {
        printf("suite differential\n");
        printf("  oracle %-15s SKIP (no oracle binary named)\n", "none");
        printf("  %-22s %s\n", "suite total",
               validation.require_oracle ? "FAIL" : "SKIP");
        return validation.require_oracle ? 1 : 0;
    }
    open_oracles();
    diff_hash(&s);
    diff_hmac(&s);
    close_oracles();
    return suite_end(&s);
}
