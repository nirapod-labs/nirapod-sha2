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
 *
 * Negative controls, run on the answers already computed so that they
 * cost no second pass over the message: for each function, the oracle
 * answers with one more oracle added that answers a digest with one bit
 * flipped must be rejected as a disagreement, and for each target the
 * comparison with the agreed answer, one bit flipped, must fail.
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
        uint8_t expected[VALIDATION_MAX_DIGEST], wrong[VALIDATION_MAX_DIGEST];
        uint8_t answer[VALIDATION_MAX_ORACLES + 1][ORACLE_MAX_DIGEST];
        int has[VALIDATION_MAX_ORACLES + 1];
        size_t first = 0;
        int answered, disagree = 0;

        for (o = 0; o < (size_t)validation.oracle_count; o++) {
            size_t got_len = 0;
            int rc = oracle_stream(oracles[o], (unsigned)a->oracle_id, LONG_BYTES, answer[o],
                                   &got_len);

            has[o] = rc == 1 && got_len == a->digest_len;
            if (rc < 0 || (rc == 1 && got_len != a->digest_len)) {
                fail_case(&s, VALIDATION_PUBLIC, "%s: oracle %zu failed on %llu bytes",
                          a->name, o, (unsigned long long)LONG_BYTES);
                disagree = 1;
            }
        }
        answered = oracle_consensus(answer[0], sizeof answer[0], has,
                                    (size_t)validation.oracle_count, a->digest_len, expected,
                                    &first);
        if (answered < 0) {
            fail_case(&s, VALIDATION_PUBLIC, "%s: oracle %zu disagrees with an earlier oracle "
                      "on %llu bytes", a->name, first, (unsigned long long)LONG_BYTES);
            disagree = 1;
        }
        if (disagree) {
            continue;
        }
        printf("  %s, %llu bytes (bit length 2^32 + %llu): %d of %d oracles answered\n",
               a->name, (unsigned long long)LONG_BYTES,
               (unsigned long long)(LONG_BYTES * 8 - (UINT64_C(1) << 32)), answered,
               validation.oracle_count);
        fflush(stdout);
        if (answered == 0) {
            fail_case(&s, VALIDATION_PUBLIC, "%s: no oracle implements operation 3", a->name);
            continue;
        }

        /* Control: one more oracle, whose answer has one bit flipped. */
        o = (size_t)validation.oracle_count;
        memcpy(answer[o], expected, a->digest_len);
        answer[o][a->digest_len / 2] ^= 0x10;
        has[o] = 1;
        control_record(&s,
                       oracle_consensus(answer[0], sizeof answer[0], has, o + 1, a->digest_len,
                                        wrong, &first) < 0,
                       "%s: an oracle answering a wrong digest", a->name);
        memcpy(wrong, expected, a->digest_len);
        wrong[a->digest_len - 1] ^= 0x01;
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
            if (check_bytes(&s, target, got, expected, a->digest_len, "%s: %llu bytes",
                            a->name, (unsigned long long)LONG_BYTES)) {
                validation_suite c;

                /* Control: the same comparison against a wrong answer. */
                control_begin(&c, &s);
                check_bytes(&c, target, got, wrong, a->digest_len, "%s: %llu bytes", a->name,
                            (unsigned long long)LONG_BYTES);
                control_end(&s, &c, "%s on %s: a digest with one bit flipped", a->name,
                            kernel_label(target));
            }
        }
    }

    free(block);
    for (o = 0; o < (size_t)validation.oracle_count; o++) {
        oracle_stop(oracles[o]);
    }
    return suite_end(&s);
}
