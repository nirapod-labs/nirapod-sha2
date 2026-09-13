/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * clear.c
 * =======
 *
 * Clearing of the registers a Jasmin call may leave holding secret-derived
 * values. The C layer has no buffers of its own that hold secrets: it
 * never copies a message, key, digest or context, so registers are all
 * there is to clear here. The stack the Jasmin code used is cleared by the
 * export itself (Makefile, -stack-zero), and a context by final.
 *
 * Registers
 *
 *     A Jasmin export restores the callee-saved registers of the platform
 *     ABI and leaves the others as its last instructions set them, which
 *     may be values derived from the message, the key or the state. The
 *     library calls nirapod_sha2_clear_registers right after each export,
 *     before control returns towards the application. It zeroes every
 *     register the ABI lets a callee change:
 *
 *         AArch64 (AAPCS64)  x0-x17 and v0-v31, except the low 64 bits of
 *                            v8-v15, which are callee-saved and are
 *                            restored by this function's own epilogue
 *         x86-64 (SysV)      rax, rcx, rdx, rsi, rdi, r8-r11, and
 *                            xmm0-xmm15, or all of ymm0-ymm15 with VZEROALL
 *                            after a unit that used AVX; on a CPU with
 *                            AVX-512, all of zmm0-zmm31, whatever the
 *                            unit
 *
 *     The Jasmin code never uses the registers AVX-512 adds, but other code
 *     in the process can leave secrets there before the export runs: the C
 *     library's memcpy has variants that copy through zmm16-zmm31 (or their
 *     ymm halves). The AVX-512 mask registers k0-k7 are not cleared, nor is
 *     the register state of later extensions (APX r16-r31).
 *
 *     x18 is left alone: macOS reserves it, as do Linux systems that keep
 *     a shadow call stack there, so writing it is not safe everywhere. The
 *     Jasmin code never uses it (make asm-policy rejects it on the
 *     AArch64 units). Flags are not cleared. Registers saved by the operating system on a context switch
 *     are outside this file's reach.
 */

#include "internal.h"

#if defined(__aarch64__)

/*
 * The clobber list makes the compiler save and restore d8-d15 around the
 * block; restoring a d register also zeroes the upper half of its v
 * register, so v8-v15 end with the caller's low halves and zero upper
 * halves.
 */
__attribute__((noinline))
void nirapod_sha2_clear_registers(unsigned used_features)
{
    (void)used_features;
    __asm__ __volatile__(
        "mov x0, xzr\n\t"  "mov x1, xzr\n\t"  "mov x2, xzr\n\t"  "mov x3, xzr\n\t"
        "mov x4, xzr\n\t"  "mov x5, xzr\n\t"  "mov x6, xzr\n\t"  "mov x7, xzr\n\t"
        "mov x8, xzr\n\t"  "mov x9, xzr\n\t"  "mov x10, xzr\n\t" "mov x11, xzr\n\t"
        "mov x12, xzr\n\t" "mov x13, xzr\n\t" "mov x14, xzr\n\t" "mov x15, xzr\n\t"
        "mov x16, xzr\n\t" "mov x17, xzr\n\t"
        "movi v0.16b, #0\n\t"  "movi v1.16b, #0\n\t"  "movi v2.16b, #0\n\t"  "movi v3.16b, #0\n\t"
        "movi v4.16b, #0\n\t"  "movi v5.16b, #0\n\t"  "movi v6.16b, #0\n\t"  "movi v7.16b, #0\n\t"
        "movi v8.16b, #0\n\t"  "movi v9.16b, #0\n\t"  "movi v10.16b, #0\n\t" "movi v11.16b, #0\n\t"
        "movi v12.16b, #0\n\t" "movi v13.16b, #0\n\t" "movi v14.16b, #0\n\t" "movi v15.16b, #0\n\t"
        "movi v16.16b, #0\n\t" "movi v17.16b, #0\n\t" "movi v18.16b, #0\n\t" "movi v19.16b, #0\n\t"
        "movi v20.16b, #0\n\t" "movi v21.16b, #0\n\t" "movi v22.16b, #0\n\t" "movi v23.16b, #0\n\t"
        "movi v24.16b, #0\n\t" "movi v25.16b, #0\n\t" "movi v26.16b, #0\n\t" "movi v27.16b, #0\n\t"
        "movi v28.16b, #0\n\t" "movi v29.16b, #0\n\t" "movi v30.16b, #0\n\t" "movi v31.16b, #0"
        :
        :
        : "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7", "x8", "x9", "x10", "x11",
          "x12", "x13", "x14", "x15", "x16", "x17",
          "v0", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11",
          "v12", "v13", "v14", "v15", "v16", "v17", "v18", "v19", "v20", "v21", "v22",
          "v23", "v24", "v25", "v26", "v27", "v28", "v29", "v30", "v31", "memory");
}

#elif defined(__x86_64__)

/*
 * zmm16-zmm31 exist only with AVX-512 and only EVEX instructions reach
 * them. Writing the xmm form zeroes the whole zmm register; that form
 * needs AVX512VL, so a CPU with AVX-512F alone gets the zmm form. The
 * compiler is told about the registers only when it may allocate them
 * itself; otherwise it never holds a value there.
 */
#if defined(__AVX512F__)
#define CLEAR_HI16_CLOBBERS                                                    \
    , "xmm16", "xmm17", "xmm18", "xmm19", "xmm20", "xmm21", "xmm22", "xmm23",  \
    "xmm24", "xmm25", "xmm26", "xmm27", "xmm28", "xmm29", "xmm30", "xmm31"
#else
#define CLEAR_HI16_CLOBBERS
#endif

#define CLEAR_HI16_ONE(w, i) "vpxord %%" w #i ", %%" w #i ", %%" w #i "\n\t"
#define CLEAR_HI16(w)                                                          \
    CLEAR_HI16_ONE(w, 16) CLEAR_HI16_ONE(w, 17) CLEAR_HI16_ONE(w, 18)         \
    CLEAR_HI16_ONE(w, 19) CLEAR_HI16_ONE(w, 20) CLEAR_HI16_ONE(w, 21)         \
    CLEAR_HI16_ONE(w, 22) CLEAR_HI16_ONE(w, 23) CLEAR_HI16_ONE(w, 24)         \
    CLEAR_HI16_ONE(w, 25) CLEAR_HI16_ONE(w, 26) CLEAR_HI16_ONE(w, 27)         \
    CLEAR_HI16_ONE(w, 28) CLEAR_HI16_ONE(w, 29) CLEAR_HI16_ONE(w, 30)         \
    CLEAR_HI16_ONE(w, 31)

/*
 * VZEROALL needs AVX, which every family that needs AVX2 or SHA-NI implies
 * (units.c, dispatch.c), as does AVX-512; it also zeroes the upper halves
 * of zmm0-zmm15. The portable code runs on CPUs without AVX and uses no
 * upper ymm halves, so for it, on a CPU without AVX-512, the
 * legacy-encoded XORPS of the low halves is enough.
 */
__attribute__((noinline))
void nirapod_sha2_clear_registers(unsigned used_features)
{
    unsigned cpu = nirapod_sha2_cpu_features();

    __asm__ __volatile__(
        "xorl %%eax, %%eax\n\t" "xorl %%ecx, %%ecx\n\t" "xorl %%edx, %%edx\n\t"
        "xorl %%esi, %%esi\n\t" "xorl %%edi, %%edi\n\t" "xorl %%r8d, %%r8d\n\t"
        "xorl %%r9d, %%r9d\n\t" "xorl %%r10d, %%r10d\n\t" "xorl %%r11d, %%r11d"
        :
        :
        : "rax", "rcx", "rdx", "rsi", "rdi", "r8", "r9", "r10", "r11", "memory");

    if ((cpu & NIRAPOD_SHA2_CPU_AVX512VL) != 0) {
        __asm__ __volatile__(CLEAR_HI16("xmm") : : : "memory" CLEAR_HI16_CLOBBERS);
    } else if ((cpu & NIRAPOD_SHA2_CPU_AVX512) != 0) {
        __asm__ __volatile__(CLEAR_HI16("zmm") : : : "memory" CLEAR_HI16_CLOBBERS);
    }

    if ((used_features & (NIRAPOD_SHA2_CPU_AVX2 | NIRAPOD_SHA2_CPU_SHANI)) != 0 ||
        (cpu & NIRAPOD_SHA2_CPU_AVX512) != 0) {
        __asm__ __volatile__("vzeroall" : : :
            "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7", "xmm8",
            "xmm9", "xmm10", "xmm11", "xmm12", "xmm13", "xmm14", "xmm15", "memory");
    } else {
        __asm__ __volatile__(
            "xorps %%xmm0, %%xmm0\n\t"   "xorps %%xmm1, %%xmm1\n\t"   "xorps %%xmm2, %%xmm2\n\t"
            "xorps %%xmm3, %%xmm3\n\t"   "xorps %%xmm4, %%xmm4\n\t"   "xorps %%xmm5, %%xmm5\n\t"
            "xorps %%xmm6, %%xmm6\n\t"   "xorps %%xmm7, %%xmm7\n\t"   "xorps %%xmm8, %%xmm8\n\t"
            "xorps %%xmm9, %%xmm9\n\t"   "xorps %%xmm10, %%xmm10\n\t" "xorps %%xmm11, %%xmm11\n\t"
            "xorps %%xmm12, %%xmm12\n\t" "xorps %%xmm13, %%xmm13\n\t" "xorps %%xmm14, %%xmm14\n\t"
            "xorps %%xmm15, %%xmm15"
            : : :
            "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7", "xmm8",
            "xmm9", "xmm10", "xmm11", "xmm12", "xmm13", "xmm14", "xmm15", "memory");
    }
}

#else
#error "clear.c: unsupported architecture"
#endif
