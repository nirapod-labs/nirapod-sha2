/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * dispatch.c
 * ==========
 *
 * Reads the CPU features of the running machine and chooses, per
 * operation family, the unit an operation runs on.
 *
 * The portable unit exists on both architectures and runs on every
 * supported CPU (ARMv8.0-A, x86-64 baseline). The other units need
 * instruction-set extensions for some families (units.c); a unit is
 * chosen for a family only when the CPU reports every extension that
 * family's code uses in it and, on x86-64, the operating system has
 * enabled the register state it uses. All units compute the same
 * functions; the tests run every unit this CPU supports, through the
 * testing library, and check the choice for combinations of features
 * the host does not have (nirapod_sha2_select_for).
 *
 * The library keeps no global state, so the features are read on the
 * call that needs them, and only when the family has an admitted unit
 * besides the portable one.
 */

#include "internal.h"

#if defined(__x86_64__)
#include <cpuid.h>

/*
 * CPUID and XCR0 bits (Intel SDM vol. 2A, CPUID; vol. 1, sections 13.3,
 * 14.3 and 15.2): an AVX-encoded instruction may run only when the CPU
 * reports AVX and OSXSAVE and the operating system has set XCR0 bits 1
 * (SSE state) and 2 (AVX state); an AVX-512 instruction only when it has
 * also set bits 5, 6 and 7 (opmask, the upper halves of zmm0-zmm15, and
 * zmm16-zmm31).
 */
#define LEAF1_ECX_OSXSAVE  (1u << 27)
#define LEAF1_ECX_AVX      (1u << 28)
#define LEAF7_EBX_AVX2     (1u << 5)
#define LEAF7_EBX_AVX512F  (1u << 16)
#define LEAF7_EBX_SHA      (1u << 29)
#define LEAF7_EBX_AVX512VL (1u << 31)
#define XCR0_SSE_AVX       0x6u
#define XCR0_AVX512        0xe0u

unsigned nirapod_sha2_cpu_features(void)
{
    unsigned int a, b, c, d;
    unsigned int xcr0_lo, xcr0_hi;
    unsigned features = 0;

    if (__get_cpuid_max(0, NULL) < 7 || !__get_cpuid(1, &a, &b, &c, &d)) {
        return 0;
    }
    if ((c & (LEAF1_ECX_OSXSAVE | LEAF1_ECX_AVX)) != (LEAF1_ECX_OSXSAVE | LEAF1_ECX_AVX)) {
        return 0;
    }
    /* XGETBV with ECX = 0 reads XCR0; it is defined once OSXSAVE is set. */
    __asm__ volatile("xgetbv" : "=a"(xcr0_lo), "=d"(xcr0_hi) : "c"(0));
    (void)xcr0_hi;
    if ((xcr0_lo & XCR0_SSE_AVX) != XCR0_SSE_AVX) {
        return 0;
    }

    __cpuid_count(7, 0, a, b, c, d);
    if ((b & LEAF7_EBX_AVX2) != 0) {
        features |= NIRAPOD_SHA2_CPU_AVX2;
    }
    if ((b & LEAF7_EBX_SHA) != 0) {
        features |= NIRAPOD_SHA2_CPU_SHANI;
    }
    if ((b & LEAF7_EBX_AVX512F) != 0 && (xcr0_lo & XCR0_AVX512) == XCR0_AVX512) {
        features |= NIRAPOD_SHA2_CPU_AVX512;
        if ((b & LEAF7_EBX_AVX512VL) != 0) {
            features |= NIRAPOD_SHA2_CPU_AVX512VL;
        }
    }
    return features;
}

#elif defined(__aarch64__)

/*
 * AArch64 extensions a unit may require: Advanced SIMD and the SHA-256
 * and SHA-512 instructions (FEAT_SHA256, FEAT_SHA512). User code cannot
 * read the ID registers portably, so the operating system's report is
 * used:
 *
 *     macOS   sysctl hw.optional.arm.AdvSIMD and hw.optional.arm.FEAT_*
 *     Linux   getauxval(AT_HWCAP): HWCAP_ASIMD (bit 1), HWCAP_SHA2 (bit 6),
 *             HWCAP_SHA512 (bit 21)
 */
#if defined(__APPLE__)
#include <sys/sysctl.h>

static int sysctl_flag(const char *name)
{
    int value = 0;
    size_t size = sizeof(value);

    return sysctlbyname(name, &value, &size, NULL, 0) == 0 && value == 1;
}

unsigned nirapod_sha2_cpu_features(void)
{
    unsigned features = 0;

    if (sysctl_flag("hw.optional.arm.AdvSIMD")) {
        features |= NIRAPOD_SHA2_CPU_ASIMD;
    }
    if (sysctl_flag("hw.optional.arm.FEAT_SHA256")) {
        features |= NIRAPOD_SHA2_CPU_SHA256;
    }
    if (sysctl_flag("hw.optional.arm.FEAT_SHA512")) {
        features |= NIRAPOD_SHA2_CPU_SHA512;
    }
    return features;
}

#elif defined(__linux__)
#include <sys/auxv.h>

#define HWCAP_BIT_ASIMD  (UINT64_C(1) << 1)
#define HWCAP_BIT_SHA2   (UINT64_C(1) << 6)
#define HWCAP_BIT_SHA512 (UINT64_C(1) << 21)

unsigned nirapod_sha2_cpu_features(void)
{
    uint64_t hwcap = getauxval(AT_HWCAP);
    unsigned features = 0;

    if ((hwcap & HWCAP_BIT_ASIMD) != 0) {
        features |= NIRAPOD_SHA2_CPU_ASIMD;
    }
    if ((hwcap & HWCAP_BIT_SHA2) != 0) {
        features |= NIRAPOD_SHA2_CPU_SHA256;
    }
    if ((hwcap & HWCAP_BIT_SHA512) != 0) {
        features |= NIRAPOD_SHA2_CPU_SHA512;
    }
    return features;
}

#else

unsigned nirapod_sha2_cpu_features(void)
{
    return 0;
}

#endif

#endif

/*
 * Default dispatch
 * ----------------
 *
 * Per family, the candidate units in order of preference; the first whose
 * needs the CPU has is chosen, and the portable unit, last in every list,
 * needs nothing. The order is the library's target (accelerated kernel
 * where the CPU has it): on AArch64 the sha2 unit for every family, on
 * x86-64 SHA-NI for single-way SHA-256 and AVX2 for the multi-way forms.
 * The aarch64 scalar unit is in no list: it is built and tested, and
 * selectable through the testing library only.
 *
 * A unit enters the default dispatch only when all its gates have passed:
 * a correctness proof of its kernel against FIPS 180-4, a safety-checker
 * verdict, the constant-time and speculative constant-time checks, and
 * native tests. admitted marks the candidates that have. The portable unit
 * is admitted on other grounds: it is the fallback every CPU needs, and its
 * kernels are the only ones with a correctness proof so far; its remaining
 * gates are open like the others'. Today it is the only admitted unit, so
 * the public functions run the portable kernels on every CPU and read no
 * CPU features. Admitting a unit is a change of one admitted flag below,
 * made with the evidence for it.
 */
typedef struct candidate {
    size_t unit;     /* index into units.c */
    int admitted;    /* in the default dispatch */
} candidate;

#define PORTABLE { 0, 1 }

#if defined(__aarch64__)
static const candidate candidates[NIRAPOD_SHA2_FAMILIES][2] = {
    /* SHA256 */ { { 2, 0 }, PORTABLE },
    /* SHA512 */ { { 2, 0 }, PORTABLE },
    /* X8     */ { { 2, 0 }, PORTABLE },
    /* X4     */ { { 2, 0 }, PORTABLE },
};
#elif defined(__x86_64__)
static const candidate candidates[NIRAPOD_SHA2_FAMILIES][2] = {
    /* SHA256 */ { { 1, 0 }, PORTABLE },
    /* SHA512 */ { PORTABLE, PORTABLE },    /* no x86-64 SHA-512 kernel besides it */
    /* X8     */ { { 2, 0 }, PORTABLE },
    /* X4     */ { { 2, 0 }, PORTABLE },
};
#endif

#define CANDIDATES (sizeof(candidates[0]) / sizeof(candidates[0][0]))

const nirapod_sha2_unit *nirapod_sha2_select_for(nirapod_sha2_family f, unsigned cpu, int gated)
{
    const nirapod_sha2_unit *u;
    size_t i;

    for (i = 0; i < CANDIDATES; i++) {
        if (gated && !candidates[f][i].admitted) {
            continue;
        }
        u = nirapod_sha2_unit_at(candidates[f][i].unit);
        if ((u->needs[f] & ~cpu) == 0) {
            return u;
        }
    }
    return nirapod_sha2_unit_at(0);
}

const nirapod_sha2_unit *nirapod_sha2_select(nirapod_sha2_family f)
{
    unsigned cpu = 0;
    size_t i;

    /*
     * The features are read only when an admitted candidate of the family
     * needs one; with the portable unit alone they are not read at all.
     */
    for (i = 0; i < CANDIDATES; i++) {
        if (candidates[f][i].admitted &&
            nirapod_sha2_unit_at(candidates[f][i].unit)->needs[f] != 0) {
            cpu = nirapod_sha2_cpu_features();
            break;
        }
    }
    return nirapod_sha2_select_for(f, cpu, 1);
}
