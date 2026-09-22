/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * multiway.c
 * ==========
 *
 * sha256_x8 and sha512_x4 against the single-way one-shot function: every
 * lane gets its own message of the same length, packed as the header
 * describes, and each lane's digest must equal the one-shot digest of
 * that message. Lengths cover both padding edges, the empty message,
 * random lengths and a large message; the output must be written exactly.
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

int suite_multiway(void)
{
    validation_suite s;
    int k;

    suite_begin(&s, "multiway");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        if (validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_X8)) {
            run_multiway(&s, 0, target);
        }
        if (validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_X4)) {
            run_multiway(&s, 1, target);
        }
    }
    return suite_end(&s);
}
