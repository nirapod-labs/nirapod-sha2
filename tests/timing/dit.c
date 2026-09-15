/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * dit.c
 * =====
 *
 * The data-independent timing mode of capi/timing.c as the caller sees it:
 * every call leaves PSTATE.DIT as it found it, set or clear. The other
 * half of the guarantee, that the mode is on while an export runs, is not
 * observable from outside the library.
 *
 * Enter scripts and error returns take the same path: the token records
 * what the call did, and a caller that already had DIT set costs no write.
 * Those are the two cases this test pins down. It runs on AArch64; on
 * x86-64 the mode is DOITM, which user code cannot write, and the test
 * reports NOT APPLICABLE (nirapod_sha2.h, "Security").
 */

#include <stdio.h>

#include "internal.h"

#if defined(__aarch64__)

#define DIT_FLAG (UINT64_C(1) << 24)

static uint64_t read_dit(void)
{
    uint64_t v;

    __asm__ __volatile__("mrs %0, s3_3_c4_c2_5" : "=r"(v));
    return v & DIT_FLAG;
}

static void write_dit(int on)
{
    uint64_t v = on ? DIT_FLAG : 0;

    __asm__ __volatile__("msr s3_3_c4_c2_5, %0" : : "r"(v) : "memory");
}

#endif

int main(void)
{
#if defined(__aarch64__)
    nirapod_sha2_sha256_ctx ctx;
    uint8_t out[64];
    unsigned failures = 0;

    if ((nirapod_sha2_cpu_features() & NIRAPOD_SHA2_CPU_DIT) == 0) {
        printf("dit: NOT APPLICABLE (the CPU reports no FEAT_DIT)\n");
        return 0;
    }

    /* The caller's DIT is clear: a call must not leave it set. */
    write_dit(0);
    if (nirapod_sha2_sha256(out, NULL, 0) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() != 0) {
        printf("FAIL: one-shot left DIT set\n");
        failures++;
    }
    if (nirapod_sha2_sha256_init(&ctx) != NIRAPOD_SHA2_OK ||
        nirapod_sha2_sha256_update(&ctx, NULL, 0) != NIRAPOD_SHA2_OK ||
        nirapod_sha2_sha256_final(&ctx, out) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() != 0) {
        printf("FAIL: incremental calls left DIT set\n");
        failures++;
    }
    if (nirapod_sha2_hmac_sha256(out, NULL, 0, NULL, 0) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() != 0) {
        printf("FAIL: HMAC left DIT set\n");
        failures++;
    }

    /* A failing call must not change it either. */
    if (nirapod_sha2_sha256(NULL, NULL, 0) != NIRAPOD_SHA2_ENULL) {
        failures++;
    }
    if (read_dit() != 0) {
        printf("FAIL: a rejected call left DIT set\n");
        failures++;
    }

    /* The caller's DIT is set: calls keep it set and still do their work. */
    write_dit(1);
    if (nirapod_sha2_sha256(out, NULL, 0) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() == 0) {
        printf("FAIL: one-shot cleared the caller's DIT\n");
        failures++;
    }
    if (nirapod_sha2_sha256_init(&ctx) != NIRAPOD_SHA2_OK ||
        nirapod_sha2_sha256_update(&ctx, (const uint8_t *)"abc", 3) != NIRAPOD_SHA2_OK ||
        nirapod_sha2_sha256_final(&ctx, out) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() == 0) {
        printf("FAIL: incremental calls cleared the caller's DIT\n");
        failures++;
    }
    if (nirapod_sha2_hmac_sha256(out, NULL, 0, NULL, 0) != NIRAPOD_SHA2_OK) {
        failures++;
    }
    if (read_dit() == 0) {
        printf("FAIL: HMAC cleared the caller's DIT\n");
        failures++;
    }

    write_dit(0);
    printf("dit: %s\n", failures == 0 ? "PASS" : "FAIL");
    return failures == 0 ? 0 : 1;
#else
    printf("dit: NOT APPLICABLE (x86-64 has no user-writable DIT)\n");
    return 0;
#endif
}
