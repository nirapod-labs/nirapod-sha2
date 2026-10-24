/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * timing.c
 * ========
 *
 * Data-independent timing mode around each Jasmin call that reads a
 * message, a key or a context, all secret. That is every export except the
 * init of a hash or of a multi-way hash, which only writes constants
 * (api.c, nirapod_sha2_run_init) and runs without it.
 *
 * AArch64
 *
 *     FEAT_DIT (Armv8.4) adds PSTATE.DIT. While it is set, the instructions
 *     the Arm architecture lists as data-independent-time execute in time
 *     independent of their data operands. EL0 can read and write it as the
 *     system register DIT (op0 3, op1 3, CRn 4, CRm 2, op2 5; the flag is
 *     bit 24). The read and the writes are named by the register's
 *     encoding so that the code assembles without an Armv8.4 target flag:
 *     the immediate form of the write does not, on a target whose
 *     architecture is still Armv8.0-A.
 *
 *     enter() checks that the CPU reports FEAT_DIT, reads DIT, and sets it
 *     only when it is clear; leave() clears it only when enter() set it.
 *     A caller that already has DIT set keeps it without either write, so
 *     its calls pay for the read alone. The caller's value is restored in
 *     every case. Writing DIT on a CPU without FEAT_DIT is undefined,
 *     hence the check, on the features dispatch.c reads once per process:
 *
 *         macOS   sysctl hw.optional.arm.FEAT_DIT
 *         Linux   getauxval(AT_HWCAP) & HWCAP_DIT (bit 24)
 *
 *     Without FEAT_DIT nothing is changed and the instruction-timing
 *     assumption rests on the CPU (nirapod_sha2.h, "Security").
 *
 * x86-64
 *
 *     Intel's DOITM mode is enabled through a model-specific register that
 *     user code cannot write. Enabling it is the caller's or the platform's
 *     obligation, and CPUs without DOITM give no such control;
 *     enter() and leave() do nothing (nirapod_sha2.h, "Security").
 */

#include "internal.h"


#if defined(__aarch64__)

#define DIT_FLAG (UINT64_C(1) << 24)

/*
 * The token says only what this call did, so the common paths skip the
 * writes: no FEAT_DIT, DIT already set by the caller, or DIT set here.
 * The caller's value is what it was in every case.
 */
#define TOKEN_NOTHING 0u  /* no FEAT_DIT: nothing was written, nothing to restore */
#define TOKEN_SET     1u  /* DIT was clear and this call set it */
#define TOKEN_ALREADY 2u  /* the caller had DIT set: it was left alone */

static int cpu_has_dit(void)
{
    return (nirapod_sha2_cpu_features() & NIRAPOD_SHA2_CPU_DIT) != 0;
}

uint64_t nirapod_sha2_timing_enter(void)
{
    uint64_t saved;

    if (!cpu_has_dit()) {
        return TOKEN_NOTHING;
    }

    __asm__ __volatile__("mrs %0, s3_3_c4_c2_5" : "=r"(saved));
    if ((saved & DIT_FLAG) != 0) {
        return TOKEN_ALREADY;
    }

    /*
     * The numeric encoding of the register form assembles without an
     * Armv8.4 target flag, like the read above.
     */
    __asm__ __volatile__("msr s3_3_c4_c2_5, %0" : : "r"(DIT_FLAG) : "memory");
    return TOKEN_SET;
}

void nirapod_sha2_timing_leave(uint64_t token)
{
    if (token != TOKEN_SET) {
        return;
    }
    __asm__ __volatile__("msr s3_3_c4_c2_5, %0" : : "r"(UINT64_C(0)) : "memory");
}

#else

uint64_t nirapod_sha2_timing_enter(void)
{
    return 0;
}

void nirapod_sha2_timing_leave(uint64_t token)
{
    (void)token;
}

#endif
