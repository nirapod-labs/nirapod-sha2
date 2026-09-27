/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * jasmin.h
 * ========
 *
 * C declarations of the Jasmin exports, one group per unit. The Jasmin
 * source of every export, with its contract, is src/nirapod_sha2.jinc;
 * this file only restates the ABI.
 *
 * Symbol scheme
 *
 *     nirapod_sha2_jz_<arch>_<variant>__<op>
 *
 * The build compiles src/nirapod_sha2.jinc once per unit inside the Jasmin
 * namespace nirapod_sha2_jz_<arch>_<variant>, and Jasmin prints the
 * namespace separator as a double underscore. These symbols are internal:
 * no public header declares them, and libnirapod_sha2.a holds them as
 * local symbols (Makefile, "Libraries").
 *
 * ABI (both architectures, from the Jasmin calling convention for exports)
 *
 *     Arguments in order in the platform's integer argument registers. An
 *     array argument is a pointer to exactly that many bytes, with no
 *     alignment requirement. An export returns its mutable arrays in
 *     place, so C sees void or the one scalar result:
 *
 *     hash        (out[D], in, len)
 *     init        (ctx[C])
 *     update      (ctx[C], in, len)          -> status
 *     final       (ctx[C], out[D])           -> status
 *     hmac        (out[D], key, key_len, msg, msg_len)
 *     hmac_init   (ctx[C], key, key_len)
 *     x8, x4      (out[256], in, len)
 *
 *     status: 0 success, 1 context state, 2 length (src/context.jinc,
 *     SHA2_STATUS_*). D and C are the digest and context sizes of
 *     nirapod_sha2.h.
 */

#ifndef NIRAPOD_SHA2_JASMIN_H
#define NIRAPOD_SHA2_JASMIN_H

#include <stdint.h>

#define NIRAPOD_SHA2_JZ_STATUS_OK     0
#define NIRAPOD_SHA2_JZ_STATUS_STATE  1
#define NIRAPOD_SHA2_JZ_STATUS_LENGTH 2

typedef void (*nirapod_sha2_jz_hash)(uint8_t *out, const uint8_t *in, uint64_t len);
typedef void (*nirapod_sha2_jz_init)(uint8_t *ctx);
typedef uint64_t (*nirapod_sha2_jz_update)(uint8_t *ctx, const uint8_t *in, uint64_t len);
typedef uint64_t (*nirapod_sha2_jz_final)(uint8_t *ctx, uint8_t *out);
typedef void (*nirapod_sha2_jz_hmac)(uint8_t *out, const uint8_t *key, uint64_t key_len,
                                     const uint8_t *msg, uint64_t msg_len);
typedef void (*nirapod_sha2_jz_hmac_init)(uint8_t *ctx, const uint8_t *key, uint64_t key_len);
typedef void (*nirapod_sha2_jz_lanes)(uint8_t *out, const uint64_t *in, uint64_t len);
typedef uint64_t (*nirapod_sha2_jz_lanes_from)(uint8_t *ctx, const uint8_t *src);
typedef uint64_t (*nirapod_sha2_jz_lanes_update)(uint8_t *ctx, const uint64_t *in, uint64_t len);

#define NIRAPOD_SHA2_JZ_HASH_OPS(unit, h)                                         \
  void nirapod_sha2_jz_##unit##__##h(uint8_t *out, const uint8_t *in, uint64_t len); \
  void nirapod_sha2_jz_##unit##__##h##_init(uint8_t *ctx);                        \
  uint64_t nirapod_sha2_jz_##unit##__##h##_update(uint8_t *ctx, const uint8_t *in, \
                                                  uint64_t len);                 \
  uint64_t nirapod_sha2_jz_##unit##__##h##_final(uint8_t *ctx, uint8_t *out);

#define NIRAPOD_SHA2_JZ_HMAC_OPS(unit, h)                                         \
  void nirapod_sha2_jz_##unit##__hmac_##h(uint8_t *out, const uint8_t *key,      \
                                          uint64_t key_len, const uint8_t *msg,  \
                                          uint64_t msg_len);                     \
  void nirapod_sha2_jz_##unit##__hmac_##h##_init(uint8_t *ctx, const uint8_t *key, \
                                                 uint64_t key_len);              \
  uint64_t nirapod_sha2_jz_##unit##__hmac_##h##_update(uint8_t *ctx, const uint8_t *in, \
                                                       uint64_t len);            \
  uint64_t nirapod_sha2_jz_##unit##__hmac_##h##_final(uint8_t *ctx, uint8_t *out);

/*
 * Multi-way exports: in is a table of lane pointers (8 for sha256_x8, 4 for
 * sha512_x4), as 64-bit integers.
 */
#define NIRAPOD_SHA2_JZ_LANES_OPS(unit, h)                                        \
  void nirapod_sha2_jz_##unit##__##h(uint8_t *out, const uint64_t *in, uint64_t len); \
  void nirapod_sha2_jz_##unit##__##h##_init(uint8_t *ctx);                        \
  uint64_t nirapod_sha2_jz_##unit##__##h##_init_from(uint8_t *ctx, const uint8_t *src); \
  uint64_t nirapod_sha2_jz_##unit##__##h##_update(uint8_t *ctx, const uint64_t *in, \
                                                  uint64_t len);                 \
  uint64_t nirapod_sha2_jz_##unit##__##h##_final(uint8_t *ctx, uint8_t *out);

#define NIRAPOD_SHA2_JZ_DECLARE(unit)                                             \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha224)                                          \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha256)                                          \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha384)                                          \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha512)                                          \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha512_224)                                      \
  NIRAPOD_SHA2_JZ_HASH_OPS(unit, sha512_256)                                      \
  NIRAPOD_SHA2_JZ_HMAC_OPS(unit, sha256)                                          \
  NIRAPOD_SHA2_JZ_HMAC_OPS(unit, sha512)                                          \
  NIRAPOD_SHA2_JZ_LANES_OPS(unit, sha256_x8)                                      \
  NIRAPOD_SHA2_JZ_LANES_OPS(unit, sha512_x4)

#if defined(__aarch64__)
NIRAPOD_SHA2_JZ_DECLARE(aarch64_portable)
NIRAPOD_SHA2_JZ_DECLARE(aarch64_scalar)
NIRAPOD_SHA2_JZ_DECLARE(aarch64_sha2)
#elif defined(__x86_64__)
NIRAPOD_SHA2_JZ_DECLARE(x86_64_portable)
NIRAPOD_SHA2_JZ_DECLARE(x86_64_shani)
NIRAPOD_SHA2_JZ_DECLARE(x86_64_avx2)
#else
#error "jasmin.h: unsupported architecture"
#endif

#endif /* NIRAPOD_SHA2_JASMIN_H */
