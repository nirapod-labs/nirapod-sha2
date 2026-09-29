/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * nirapod_sha2_testing.h
 * ======================
 *
 * The testing interface: every function of nirapod_sha2.h run on a kernel
 * the caller names, instead of the one the library would choose. It is
 * declared only in this header, which is not installed, and defined only
 * in libnirapod_sha2_testing.a; libnirapod_sha2.a has none of it. It
 * exists so that tests can run each kernel the build contains, including
 * kernels that are not in the default dispatch yet, and so that the
 * dispatch rule can be checked for CPUs the host is not.
 *
 * Each function takes the kernel first and otherwise has the contract of
 * the public function of the same name. When the kernel is not built for
 * this architecture, or the CPU lacks a feature the kernel's code for
 * that function needs, it returns NIRAPOD_SHA2_TESTING_EUNAVAILABLE and
 * does nothing else, before any argument check.
 */

#ifndef NIRAPOD_SHA2_TESTING_H
#define NIRAPOD_SHA2_TESTING_H

#include <stddef.h>
#include <stdint.h>

#include "nirapod_sha2.h"

#ifdef __cplusplus
extern "C" {
#endif

#define NIRAPOD_SHA2_TESTING_EUNAVAILABLE -100

typedef enum nirapod_sha2_testing_kernel {
    NIRAPOD_SHA2_TESTING_PORTABLE = 0,        /* both architectures */
    NIRAPOD_SHA2_TESTING_AARCH64_SCALAR = 1,
    NIRAPOD_SHA2_TESTING_AARCH64_SHA2 = 2,    /* FEAT_SHA256, FEAT_SHA512 */
    NIRAPOD_SHA2_TESTING_X86_64_SHANI = 3,    /* SHA extensions, AVX2; SHA-512 forms AVX2, BMI1, BMI2 */
    NIRAPOD_SHA2_TESTING_X86_64_AVX2 = 4      /* AVX2; single-way forms also BMI1, BMI2 */
} nirapod_sha2_testing_kernel;

#define NIRAPOD_SHA2_TESTING_KERNELS 5

/* Operation families, as capi/internal.h numbers them. */
typedef enum nirapod_sha2_testing_family {
    NIRAPOD_SHA2_TESTING_FAMILY_SHA256 = 0,   /* SHA-224, SHA-256, HMAC-SHA-256 */
    NIRAPOD_SHA2_TESTING_FAMILY_SHA512 = 1,   /* SHA-384, SHA-512, SHA-512/t, HMAC-SHA-512 */
    NIRAPOD_SHA2_TESTING_FAMILY_X8 = 2,       /* sha256_x8, one-shot and incremental */
    NIRAPOD_SHA2_TESTING_FAMILY_X4 = 3        /* sha512_x4, one-shot and incremental */
} nirapod_sha2_testing_family;

/* The unit name of a kernel ("aarch64-sha2"), or NULL if it is not built here. */
const char *nirapod_sha2_testing_kernel_name(nirapod_sha2_testing_kernel k);

/* 1 if kernel k can run family f on this CPU, else 0. */
int nirapod_sha2_testing_available(nirapod_sha2_testing_kernel k, nirapod_sha2_testing_family f);

/* The CPU features the library reads on this machine (capi/internal.h bits). */
unsigned nirapod_sha2_testing_cpu_features(void);

/*
 * The kernel the library chooses for family f on a CPU with features cpu:
 * with gated = 1 the default dispatch, with gated = 0 the target order of
 * capi/dispatch.c with every unit a candidate. A family out of range
 * gives the portable kernel.
 */
nirapod_sha2_testing_kernel nirapod_sha2_testing_select_for(nirapod_sha2_testing_family f,
                                                            unsigned cpu, int gated);

int nirapod_sha2_testing_sha224(nirapod_sha2_testing_kernel k, uint8_t *out,
                                const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha224_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha224_ctx *ctx);
int nirapod_sha2_testing_sha224_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha224_ctx *ctx,
                                       const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha224_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha224_ctx *ctx,
                                      uint8_t *out);

int nirapod_sha2_testing_sha256(nirapod_sha2_testing_kernel k, uint8_t *out,
                                const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha256_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha256_ctx *ctx);
int nirapod_sha2_testing_sha256_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha256_ctx *ctx,
                                       const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha256_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha256_ctx *ctx,
                                      uint8_t *out);

int nirapod_sha2_testing_sha384(nirapod_sha2_testing_kernel k, uint8_t *out,
                                const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha384_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha384_ctx *ctx);
int nirapod_sha2_testing_sha384_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha384_ctx *ctx,
                                       const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha384_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha384_ctx *ctx,
                                      uint8_t *out);

int nirapod_sha2_testing_sha512(nirapod_sha2_testing_kernel k, uint8_t *out,
                                const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_ctx *ctx);
int nirapod_sha2_testing_sha512_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_ctx *ctx,
                                       const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_ctx *ctx,
                                      uint8_t *out);

int nirapod_sha2_testing_sha512_224(nirapod_sha2_testing_kernel k, uint8_t *out,
                                    const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_224_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_224_ctx *ctx);
int nirapod_sha2_testing_sha512_224_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_224_ctx *ctx,
                                           const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_224_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_224_ctx *ctx,
                                          uint8_t *out);

int nirapod_sha2_testing_sha512_256(nirapod_sha2_testing_kernel k, uint8_t *out,
                                    const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_256_init(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_256_ctx *ctx);
int nirapod_sha2_testing_sha512_256_update(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_256_ctx *ctx,
                                           const uint8_t *in, size_t len);
int nirapod_sha2_testing_sha512_256_final(nirapod_sha2_testing_kernel k, nirapod_sha2_sha512_256_ctx *ctx,
                                          uint8_t *out);
int nirapod_sha2_testing_hmac_sha256(nirapod_sha2_testing_kernel k, uint8_t *out,
                                     const uint8_t *key, size_t key_len,
                                     const uint8_t *msg, size_t msg_len);
int nirapod_sha2_testing_hmac_sha256_init(nirapod_sha2_testing_kernel k,
                                          nirapod_sha2_hmac_sha256_ctx *ctx,
                                          const uint8_t *key, size_t key_len);
int nirapod_sha2_testing_hmac_sha256_update(nirapod_sha2_testing_kernel k,
                                            nirapod_sha2_hmac_sha256_ctx *ctx,
                                            const uint8_t *in, size_t len);
int nirapod_sha2_testing_hmac_sha256_final(nirapod_sha2_testing_kernel k,
                                           nirapod_sha2_hmac_sha256_ctx *ctx, uint8_t *out);

int nirapod_sha2_testing_hmac_sha512(nirapod_sha2_testing_kernel k, uint8_t *out,
                                     const uint8_t *key, size_t key_len,
                                     const uint8_t *msg, size_t msg_len);
int nirapod_sha2_testing_hmac_sha512_init(nirapod_sha2_testing_kernel k,
                                          nirapod_sha2_hmac_sha512_ctx *ctx,
                                          const uint8_t *key, size_t key_len);
int nirapod_sha2_testing_hmac_sha512_update(nirapod_sha2_testing_kernel k,
                                            nirapod_sha2_hmac_sha512_ctx *ctx,
                                            const uint8_t *in, size_t len);
int nirapod_sha2_testing_hmac_sha512_final(nirapod_sha2_testing_kernel k,
                                           nirapod_sha2_hmac_sha512_ctx *ctx, uint8_t *out);

int nirapod_sha2_testing_sha256_x8(nirapod_sha2_testing_kernel k, uint8_t *out,
                                   const uint8_t *const in[8], size_t len);
int nirapod_sha2_testing_sha256_x8_init(nirapod_sha2_testing_kernel k,
                                        nirapod_sha2_sha256_x8_ctx *ctx);
int nirapod_sha2_testing_sha256_x8_init_from(nirapod_sha2_testing_kernel k,
                                             nirapod_sha2_sha256_x8_ctx *ctx,
                                             const nirapod_sha2_sha256_ctx *src);
int nirapod_sha2_testing_sha256_x8_update(nirapod_sha2_testing_kernel k,
                                          nirapod_sha2_sha256_x8_ctx *ctx,
                                          const uint8_t *const in[8], size_t len);
int nirapod_sha2_testing_sha256_x8_final(nirapod_sha2_testing_kernel k,
                                         nirapod_sha2_sha256_x8_ctx *ctx, uint8_t *out);

int nirapod_sha2_testing_sha512_x4(nirapod_sha2_testing_kernel k, uint8_t *out,
                                   const uint8_t *const in[4], size_t len);
int nirapod_sha2_testing_sha512_x4_init(nirapod_sha2_testing_kernel k,
                                        nirapod_sha2_sha512_x4_ctx *ctx);
int nirapod_sha2_testing_sha512_x4_init_from(nirapod_sha2_testing_kernel k,
                                             nirapod_sha2_sha512_x4_ctx *ctx,
                                             const nirapod_sha2_sha512_ctx *src);
int nirapod_sha2_testing_sha512_x4_update(nirapod_sha2_testing_kernel k,
                                          nirapod_sha2_sha512_x4_ctx *ctx,
                                          const uint8_t *const in[4], size_t len);
int nirapod_sha2_testing_sha512_x4_final(nirapod_sha2_testing_kernel k,
                                         nirapod_sha2_sha512_x4_ctx *ctx, uint8_t *out);

#ifdef __cplusplus
}
#endif

#endif /* NIRAPOD_SHA2_TESTING_H */
