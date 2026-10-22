/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * long.c
 * ======
 *
 * Messages whose length in bits does not fit in 32 bits. SHA-256 and
 * SHA-512 hash a message of LONG_BYTES = 2^29 + 4099 bytes, so the bit
 * length that padding writes is 2^32 + 32792: an implementation that kept
 * the bit count, or the byte count shifted, in 32 bits would write a
 * different length field and a different digest.
 *
 * The message is the block of oracle_stream_block (oracle-protocol.h)
 * repeated, the last copy cut short. Every kernel and the public
 * functions absorb it through init, one update per block and final, so the
 * memory used is one block; the block length is prime, so the updates
 * leave every buffer offset in turn. Each oracle generates the same
 * message itself (protocol operation 3) and hashes it through its own
 * incremental interface. At least one oracle must answer for each
 * function, every answer must agree, and every target must match it.
 *
 * The one-shot functions are not run at this length: that would need the
 * whole message in memory.
 */

#include "validation.h"
#include "oracle.h"
#include "oracle-protocol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LONG_BYTES ((UINT64_C(1) << 29) + 4099)

/* The bit length must reach 2^32. */
typedef char long_bytes_reach_2_32_bits[(LONG_BYTES * 8 >> 32) != 0 ? 1 : -1];

/* SHA-256 and SHA-512, as indices of HASH_ALGS. */
static const size_t long_algs[] = { 1, 3 };

static int absorb(const hash_alg *a, int target, const uint8_t *block, uint8_t *out)
{
    validation_ctx ctx;
    uint64_t left = LONG_BYTES;
    int rc;

    memset(&ctx, 0, sizeof ctx);
    rc = hash_init(a, target, &ctx);
    while (rc == NIRAPOD_SHA2_OK && left > 0) {
        size_t piece = left < ORACLE_STREAM_PERIOD ? (size_t)left : ORACLE_STREAM_PERIOD;

        rc = hash_update(a, target, &ctx, block, piece);
        left -= piece;
    }
    if (rc == NIRAPOD_SHA2_OK) {
        rc = hash_final(a, target, &ctx, out);
    }
    return rc;
}

int suite_long(void)
{
    validation_suite s;
    oracle *oracles[VALIDATION_MAX_ORACLES];
    uint8_t *block;
    size_t i, o, m;

    suite_begin(&s, "long");
    if (validation.oracle_count == 0) {
        printf("suite long\n");
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
    block = xmalloc(ORACLE_STREAM_PERIOD);
    oracle_stream_block(block);

    for (i = 0; i < sizeof long_algs / sizeof long_algs[0]; i++) {
        const hash_alg *a = &HASH_ALGS[long_algs[i]];
        uint8_t expected[VALIDATION_MAX_DIGEST];
        size_t answered = 0;
        int disagree = 0;

        for (o = 0; o < (size_t)validation.oracle_count; o++) {
            uint8_t got[ORACLE_MAX_DIGEST];
            size_t got_len = 0;
            int rc = oracle_stream(oracles[o], (unsigned)a->oracle_id, LONG_BYTES, got,
                                   &got_len);

            if (rc < 0 || (rc == 1 && got_len != a->digest_len)) {
                fail_case(&s, VALIDATION_PUBLIC, "%s: oracle %zu failed on %llu bytes",
                          a->name, o, (unsigned long long)LONG_BYTES);
                disagree = 1;
                continue;
            }
            if (rc == 0) {
                continue;
            }
            if (answered > 0 && memcmp(expected, got, a->digest_len) != 0) {
                fail_case(&s, VALIDATION_PUBLIC, "%s: oracle %zu disagrees with oracle 0 on "
                          "%llu bytes", a->name, o, (unsigned long long)LONG_BYTES);
                disagree = 1;
                continue;
            }
            memcpy(expected, got, a->digest_len);
            answered++;
        }
        printf("  %s, %llu bytes (bit length 2^32 + %llu): %zu of %d oracles answered\n",
               a->name, (unsigned long long)LONG_BYTES,
               (unsigned long long)(LONG_BYTES * 8 - (UINT64_C(1) << 32)), answered,
               validation.oracle_count);
        fflush(stdout);
        if (answered == 0) {
            fail_case(&s, VALIDATION_PUBLIC, "%s: no oracle implements operation 3", a->name);
            continue;
        }
        if (disagree) {
            continue;
        }
        for (m = 0; m <= (size_t)VALIDATION_KERNELS; m++) {
            int target = m == VALIDATION_KERNELS ? VALIDATION_PUBLIC : (int)m;
            uint8_t got[VALIDATION_MAX_DIGEST];

            if (!validation_usable(&s, target, a->family)) {
                continue;
            }
            if (absorb(a, target, block, got) != NIRAPOD_SHA2_OK) {
                fail_case(&s, target, "%s: %llu bytes returned an error", a->name,
                          (unsigned long long)LONG_BYTES);
                continue;
            }
            check_bytes(&s, target, got, expected, a->digest_len, "%s: %llu bytes", a->name,
                        (unsigned long long)LONG_BYTES);
        }
    }

    free(block);
    for (o = 0; o < (size_t)validation.oracle_count; o++) {
        oracle_stop(oracles[o]);
    }
    return suite_end(&s);
}
