/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * units.c
 * =======
 *
 * One record per compiled unit of this architecture (Makefile, "Units"):
 * the unit's Jasmin exports and, per operation family, the CPU features
 * the family's code executes in that unit.
 *
 * A unit's kernels come from its include roots: Sha256Kernel and
 * Sha512Kernel for the single-way families and, through
 * src/sha256_x8_compress.jinc and src/sha512_x4_compress.jinc, for the
 * multi-way ones too unless the unit names a multi-way kernel of its own
 * (Sha256KernelX, Sha512KernelX). The needs below
 * follow from that:
 *
 *     unit               SHA256        SHA512        X8            X4
 *     aarch64 portable   -             -             -             -
 *     aarch64 scalar     -             -             ASIMD         -
 *     aarch64 sha2       ASIMD SHA256  ASIMD SHA512  ASIMD SHA256  ASIMD SHA512
 *     x86_64 portable    -             -             -             -
 *     x86_64 shani       SHANI AVX2    AVX2 BMI2     SHANI AVX2    AVX2 BMI2
 *     x86_64 avx2        AVX2 BMI2     AVX2 BMI2     AVX2          AVX2
 *
 * The scalar unit's 8-way kernel is in Advanced SIMD (src/aarch64/neon),
 * which every ARMv8-A CPU has; the need is stated all the same. The
 * shani unit's 8-way kernel runs two lanes at a time on the SHA
 * extensions (src/x86_64/shani); its 4-way form runs the unit's
 * single-way SHA-512 kernel, the AVX2 one, once per message, since the
 * portable multi-way kernel calls it. Both x86 units with AVX kernels
 * clear their stack with 256-bit stores (Makefile, unit_flags), and
 * VPXOR on ymm registers is an AVX2 instruction, so every family of both
 * units needs AVX2: the shani unit's SHA-256 and 8-way families need it
 * beside the SHA extensions, though their kernels use only AVX encodings.
 * BMI2 stands for BMI1 and
 * BMI2 together (ANDN, RORX). Index 0 is the portable unit on both
 * architectures.
 */

#include "internal.h"

#define UNIT_OPS(u)                                                            \
    nirapod_sha2_jz_##u##__sha224, nirapod_sha2_jz_##u##__sha256,              \
    nirapod_sha2_jz_##u##__sha384, nirapod_sha2_jz_##u##__sha512,              \
    nirapod_sha2_jz_##u##__sha512_224, nirapod_sha2_jz_##u##__sha512_256,      \
    nirapod_sha2_jz_##u##__sha224_init, nirapod_sha2_jz_##u##__sha256_init,    \
    nirapod_sha2_jz_##u##__sha384_init, nirapod_sha2_jz_##u##__sha512_init,    \
    nirapod_sha2_jz_##u##__sha512_224_init, nirapod_sha2_jz_##u##__sha512_256_init, \
    nirapod_sha2_jz_##u##__sha224_update, nirapod_sha2_jz_##u##__sha256_update, \
    nirapod_sha2_jz_##u##__sha384_update, nirapod_sha2_jz_##u##__sha512_update, \
    nirapod_sha2_jz_##u##__sha512_224_update, nirapod_sha2_jz_##u##__sha512_256_update, \
    nirapod_sha2_jz_##u##__sha224_final, nirapod_sha2_jz_##u##__sha256_final,  \
    nirapod_sha2_jz_##u##__sha384_final, nirapod_sha2_jz_##u##__sha512_final,  \
    nirapod_sha2_jz_##u##__sha512_224_final, nirapod_sha2_jz_##u##__sha512_256_final, \
    nirapod_sha2_jz_##u##__hmac_sha256, nirapod_sha2_jz_##u##__hmac_sha512,    \
    nirapod_sha2_jz_##u##__hmac_sha256_init, nirapod_sha2_jz_##u##__hmac_sha512_init, \
    nirapod_sha2_jz_##u##__hmac_sha256_update, nirapod_sha2_jz_##u##__hmac_sha512_update, \
    nirapod_sha2_jz_##u##__hmac_sha256_final, nirapod_sha2_jz_##u##__hmac_sha512_final, \
    nirapod_sha2_jz_##u##__sha256_x8, nirapod_sha2_jz_##u##__sha256_x8_init,       \
    nirapod_sha2_jz_##u##__sha256_x8_init_from, nirapod_sha2_jz_##u##__sha256_x8_update, \
    nirapod_sha2_jz_##u##__sha256_x8_final,                                       \
    nirapod_sha2_jz_##u##__sha512_x4, nirapod_sha2_jz_##u##__sha512_x4_init,       \
    nirapod_sha2_jz_##u##__sha512_x4_init_from, nirapod_sha2_jz_##u##__sha512_x4_update, \
    nirapod_sha2_jz_##u##__sha512_x4_final

#if defined(__aarch64__)

#define A64_SHA256 (NIRAPOD_SHA2_CPU_ASIMD | NIRAPOD_SHA2_CPU_SHA256)
#define A64_SHA512 (NIRAPOD_SHA2_CPU_ASIMD | NIRAPOD_SHA2_CPU_SHA512)

const nirapod_sha2_unit nirapod_sha2_units[] = {
    { "aarch64-portable", { 0, 0, 0, 0 }, UNIT_OPS(aarch64_portable) },
    { "aarch64-scalar", { 0, 0, NIRAPOD_SHA2_CPU_ASIMD, 0 }, UNIT_OPS(aarch64_scalar) },
    { "aarch64-sha2", { A64_SHA256, A64_SHA512, A64_SHA256, A64_SHA512 }, UNIT_OPS(aarch64_sha2) },
};

#elif defined(__x86_64__)

#define X86_AVX2_BMI2 (NIRAPOD_SHA2_CPU_AVX2 | NIRAPOD_SHA2_CPU_BMI2)
#define X86_SHANI_AVX2 (NIRAPOD_SHA2_CPU_SHANI | NIRAPOD_SHA2_CPU_AVX2)

const nirapod_sha2_unit nirapod_sha2_units[] = {
    { "x86_64-portable", { 0, 0, 0, 0 }, UNIT_OPS(x86_64_portable) },
    { "x86_64-shani", { X86_SHANI_AVX2, X86_AVX2_BMI2, X86_SHANI_AVX2, X86_AVX2_BMI2 }, UNIT_OPS(x86_64_shani) },
    { "x86_64-avx2", { X86_AVX2_BMI2, X86_AVX2_BMI2, NIRAPOD_SHA2_CPU_AVX2, NIRAPOD_SHA2_CPU_AVX2 }, UNIT_OPS(x86_64_avx2) },
};

#else
#error "units.c: unsupported architecture"
#endif

const nirapod_sha2_unit *nirapod_sha2_unit_at(size_t index)
{
    return index < sizeof(nirapod_sha2_units) / sizeof(nirapod_sha2_units[0])
               ? &nirapod_sha2_units[index]
               : NULL;
}
