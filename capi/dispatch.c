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
 * Feature cache
 *
 *     The features are read once per process and kept in one word, the
 *     library's only mutable global: reading them costs one to four
 *     system calls on macOS (one per sysctl name), which measurement
 *     showed to cost more than hashing a short message several times over
 *     (the record of the measurement is kept with the library's
 *     benchmarks). The word starts at 0 and is written once with the
 *     features and NIRAPOD_SHA2_FEATURES_VALID set; internal.h holds the
 *     accessor that the call path uses. Every access is an atomic load or
 *     store, so concurrent first calls do not race: each may read the
 *     features itself, and each stores the same value, because the
 *     features of the machine do not change while the process runs. No
 *     lock is taken and nothing is allocated.
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
#define LEAF7_EBX_BMI1     (1u << 3)
#define LEAF7_EBX_AVX2     (1u << 5)
#define LEAF7_EBX_BMI2     (1u << 8)
#define LEAF7_EBX_AVX512F  (1u << 16)
#define LEAF7_EBX_SHA      (1u << 29)
#define LEAF7_EBX_AVX512VL (1u << 31)
#define XCR0_SSE_AVX       0x6u
#define XCR0_AVX512        0xe0u

unsigned nirapod_sha2_read_cpu_features(void)
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
    /*
     * BMI1 and BMI2 act on general registers only and need no state from
     * the operating system; they are reported together, as one feature,
     * and only past the AVX checks above, like everything this function
     * reports.
     */
    if ((b & (LEAF7_EBX_BMI1 | LEAF7_EBX_BMI2)) == (LEAF7_EBX_BMI1 | LEAF7_EBX_BMI2)) {
        features |= NIRAPOD_SHA2_CPU_BMI2;
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
 * and SHA-512 instructions (FEAT_SHA256, FEAT_SHA512); and FEAT_DIT, which
 * timing.c needs before it may touch PSTATE.DIT. User code cannot read the
 * ID registers portably, so the operating system's report is used:
 *
 *     macOS   sysctl hw.optional.arm.AdvSIMD and hw.optional.arm.FEAT_*
 *     Linux   getauxval(AT_HWCAP): HWCAP_ASIMD (bit 1), HWCAP_SHA2 (bit 6),
 *             HWCAP_SHA512 (bit 21), HWCAP_DIT (bit 24)
 */
#if defined(__APPLE__)
#include <sys/sysctl.h>

static int sysctl_flag(const char *name)
{
    int value = 0;
    size_t size = sizeof(value);

    return sysctlbyname(name, &value, &size, NULL, 0) == 0 && value == 1;
}

unsigned nirapod_sha2_read_cpu_features(void)
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
    if (sysctl_flag("hw.optional.arm.FEAT_DIT")) {
        features |= NIRAPOD_SHA2_CPU_DIT;
    }
    return features;
}

#elif defined(__linux__)
#include <sys/auxv.h>

#define HWCAP_BIT_ASIMD  (UINT64_C(1) << 1)
#define HWCAP_BIT_SHA2   (UINT64_C(1) << 6)
#define HWCAP_BIT_SHA512 (UINT64_C(1) << 21)
#define HWCAP_BIT_DIT    (UINT64_C(1) << 24)

unsigned nirapod_sha2_read_cpu_features(void)
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
    if ((hwcap & HWCAP_BIT_DIT) != 0) {
        features |= NIRAPOD_SHA2_CPU_DIT;
    }
    return features;
}

#else

unsigned nirapod_sha2_read_cpu_features(void)
{
    return 0;
}

#endif

#endif

/*
 * The cache word shared by the accessor in internal.h. The initializer
 * makes it a definition in the data of this file rather than a common
 * symbol, so the archive's symbol policy localizes it like any other
 * internal name.
 */
unsigned nirapod_sha2_features_cache = 0;

/*
 * Default dispatch
 * ----------------
 *
 * Per family, the candidate units in order of preference; the first whose
 * needs the CPU has is chosen, and the portable unit, last in every list,
 * needs nothing. The order is the library's target, fastest kernel the CPU
 * has first: on AArch64 the sha2 unit for every family; on x86-64 the
 * shani unit, then the avx2 unit, for single-way SHA-256 and SHA-256 x8,
 * and the avx2 unit for single-way SHA-512 and SHA-512 x4 (the shani unit
 * runs the same AVX2 code for those two, so it adds nothing there). The
 * aarch64 scalar unit is in no list: it is built and tested, and
 * selectable through the testing library only.
 *
 * A unit enters the default dispatch only when all its checks have passed:
 * a correctness proof of its kernels against FIPS 180-4, a proof of the
 * safety contracts of its code, the constant-time and speculative
 * constant-time checks, and native tests. admitted marks the candidates
 * that have. Every unit in the lists below has passed them, so every
 * candidate is admitted. A kernel added later enters a list with admitted
 * 0 and is selectable through the testing library until its own checks
 * pass.
 *
 * The candidates hold the units' addresses, not their indices: the usual
 * call then needs no bounds check and no call into units.c, and it walks
 * the list once, reading the features only when an admitted candidate
 * actually needs one.
 */
typedef struct candidate {
    const nirapod_sha2_unit *unit;
    int admitted;    /* in the default dispatch */
} candidate;

#define UNIT(i) { &nirapod_sha2_units[i], 1 }

#define PORTABLE UNIT(0)

/* A list shorter than a row ends in the portable unit, repeated to fill it. */

#if defined(__aarch64__)
static const candidate candidates[NIRAPOD_SHA2_FAMILIES][3] = {
    /* SHA256 */ { UNIT(2), PORTABLE, PORTABLE },
    /* SHA512 */ { UNIT(2), PORTABLE, PORTABLE },
    /* X8     */ { UNIT(2), PORTABLE, PORTABLE },
    /* X4     */ { UNIT(2), PORTABLE, PORTABLE },
};
#elif defined(__x86_64__)
static const candidate candidates[NIRAPOD_SHA2_FAMILIES][3] = {
    /* SHA256 */ { UNIT(1), UNIT(2), PORTABLE },
    /* SHA512 */ { UNIT(2), PORTABLE, PORTABLE },
    /* X8     */ { UNIT(1), UNIT(2), PORTABLE },
    /* X4     */ { UNIT(2), PORTABLE, PORTABLE },
};
#endif

#define CANDIDATES (sizeof(candidates[0]) / sizeof(candidates[0][0]))

const nirapod_sha2_unit *nirapod_sha2_select_for(nirapod_sha2_family f, unsigned cpu, int gated)
{
    size_t i;

    for (i = 0; i < CANDIDATES; i++) {
        const candidate *c = &candidates[f][i];

        if (gated && !c->admitted) {
            continue;
        }
        if ((c->unit->needs[f] & ~cpu) == 0) {
            return c->unit;
        }
    }
    return &nirapod_sha2_units[0];
}

const nirapod_sha2_unit *nirapod_sha2_select(nirapod_sha2_family f)
{
    unsigned cpu = 0;
    int have_cpu = 0;
    size_t i;

    /*
     * One pass. The features are read only when an admitted candidate of
     * the family needs one; with the portable unit alone they are not read
     * here at all.
     */
    for (i = 0; i < CANDIDATES; i++) {
        const candidate *c = &candidates[f][i];

        if (!c->admitted) {
            continue;
        }
        if (c->unit->needs[f] == 0) {
            return c->unit;
        }
        if (!have_cpu) {
            cpu = nirapod_sha2_cpu_features();
            have_cpu = 1;
        }
        if ((c->unit->needs[f] & ~cpu) == 0) {
            return c->unit;
        }
    }
    return &nirapod_sha2_units[0];
}
