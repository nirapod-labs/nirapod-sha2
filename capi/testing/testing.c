/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * testing.c
 * =========
 *
 * The functions of nirapod_sha2_testing.h. Each one finds the unit of the
 * kernel it was given, refuses it when this CPU cannot run the family's
 * code in it, and otherwise runs the same checks and the same call as the
 * public function (api.c, nirapod_sha2_run_*). Only the choice of unit
 * differs, so a test through this interface exercises the production C
 * path on a kernel of its choosing.
 */

#include "internal.h"
#include "nirapod_sha2_testing.h"

/* Unit index of each kernel on this architecture (units.c), -1 if absent. */
#if defined(__aarch64__)
static const int kernel_unit[NIRAPOD_SHA2_TESTING_KERNELS] = { 0, 1, 2, -1, -1 };
#elif defined(__x86_64__)
static const int kernel_unit[NIRAPOD_SHA2_TESTING_KERNELS] = { 0, -1, -1, 1, 2 };
#endif

static const nirapod_sha2_unit *kernel_to_unit(nirapod_sha2_testing_kernel k)
{
    if ((unsigned)k >= NIRAPOD_SHA2_TESTING_KERNELS || kernel_unit[k] < 0) {
        return NULL;
    }
    return nirapod_sha2_unit_at((size_t)kernel_unit[k]);
}

/* The unit of k if this CPU can run family f on it, else NULL. */
static const nirapod_sha2_unit *runnable(nirapod_sha2_testing_kernel k, nirapod_sha2_family f)
{
    const nirapod_sha2_unit *u = kernel_to_unit(k);

    if (u == NULL || (u->needs[f] & ~nirapod_sha2_cpu_features()) != 0) {
        return NULL;
    }
    return u;
}

const char *nirapod_sha2_testing_kernel_name(nirapod_sha2_testing_kernel k)
{
    const nirapod_sha2_unit *u = kernel_to_unit(k);

    return u != NULL ? u->name : NULL;
}

int nirapod_sha2_testing_available(nirapod_sha2_testing_kernel k, nirapod_sha2_testing_family f)
{
    if ((unsigned)f >= NIRAPOD_SHA2_FAMILIES) {
        return 0;
    }
    return runnable(k, (nirapod_sha2_family)f) != NULL;
}

unsigned nirapod_sha2_testing_cpu_features(void)
{
    return nirapod_sha2_cpu_features();
}

nirapod_sha2_testing_kernel nirapod_sha2_testing_select_for(nirapod_sha2_testing_family f,
                                                            unsigned cpu, int gated)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select_for((nirapod_sha2_family)f, cpu, gated);
    int k;

    for (k = 0; k < NIRAPOD_SHA2_TESTING_KERNELS; k++) {
        if (kernel_to_unit((nirapod_sha2_testing_kernel)k) == u) {
            return (nirapod_sha2_testing_kernel)k;
        }
    }
    return NIRAPOD_SHA2_TESTING_PORTABLE;
}

#define FAMILY_sha224     NIRAPOD_SHA2_FAMILY_SHA256
#define FAMILY_sha256     NIRAPOD_SHA2_FAMILY_SHA256
#define FAMILY_sha384     NIRAPOD_SHA2_FAMILY_SHA512
#define FAMILY_sha512     NIRAPOD_SHA2_FAMILY_SHA512
#define FAMILY_sha512_224 NIRAPOD_SHA2_FAMILY_SHA512
#define FAMILY_sha512_256 NIRAPOD_SHA2_FAMILY_SHA512

#define CTX_sha224     NIRAPOD_SHA2_SHA256_CTX_BYTES
#define CTX_sha256     NIRAPOD_SHA2_SHA256_CTX_BYTES
#define CTX_sha384     NIRAPOD_SHA2_SHA512_CTX_BYTES
#define CTX_sha512     NIRAPOD_SHA2_SHA512_CTX_BYTES
#define CTX_sha512_224 NIRAPOD_SHA2_SHA512_CTX_BYTES
#define CTX_sha512_256 NIRAPOD_SHA2_SHA512_CTX_BYTES

#define BYTES_sha224     NIRAPOD_SHA2_SHA224_BYTES
#define BYTES_sha256     NIRAPOD_SHA2_SHA256_BYTES
#define BYTES_sha384     NIRAPOD_SHA2_SHA384_BYTES
#define BYTES_sha512     NIRAPOD_SHA2_SHA512_BYTES
#define BYTES_sha512_224 NIRAPOD_SHA2_SHA512_224_BYTES
#define BYTES_sha512_256 NIRAPOD_SHA2_SHA512_256_BYTES

#define UNIT_OR_FAIL(k, f)                                                     \
    const nirapod_sha2_unit *u = runnable(k, f);                               \
    if (u == NULL) {                                                           \
        return NIRAPOD_SHA2_TESTING_EUNAVAILABLE;                              \
    }

#define TESTING_HASH(h)                                                        \
    int nirapod_sha2_testing_##h(nirapod_sha2_testing_kernel k, uint8_t *out,  \
                                 const uint8_t *in, size_t len)                \
    {                                                                          \
        UNIT_OR_FAIL(k, FAMILY_##h)                                            \
        return nirapod_sha2_run_hash(u, FAMILY_##h, u->h, out, BYTES_##h, in, len);    \
    }                                                                          \
    int nirapod_sha2_testing_##h##_init(nirapod_sha2_testing_kernel k,         \
                                        nirapod_sha2_##h##_ctx *ctx)           \
    {                                                                          \
        UNIT_OR_FAIL(k, FAMILY_##h)                                            \
        return nirapod_sha2_run_init(u, FAMILY_##h, u->h##_init, ctx);         \
    }                                                                          \
    int nirapod_sha2_testing_##h##_update(nirapod_sha2_testing_kernel k,       \
                                          nirapod_sha2_##h##_ctx *ctx,         \
                                          const uint8_t *in, size_t len)       \
    {                                                                          \
        UNIT_OR_FAIL(k, FAMILY_##h)                                            \
        return nirapod_sha2_run_update(u, FAMILY_##h, u->h##_update, ctx, CTX_##h, in, len); \
    }                                                                          \
    int nirapod_sha2_testing_##h##_final(nirapod_sha2_testing_kernel k,        \
                                         nirapod_sha2_##h##_ctx *ctx, uint8_t *out) \
    {                                                                          \
        UNIT_OR_FAIL(k, FAMILY_##h)                                            \
        return nirapod_sha2_run_final(u, FAMILY_##h, u->h##_final, ctx, CTX_##h, out, BYTES_##h); \
    }

TESTING_HASH(sha224)
TESTING_HASH(sha256)
TESTING_HASH(sha384)
TESTING_HASH(sha512)
TESTING_HASH(sha512_224)
TESTING_HASH(sha512_256)

#define HMAC_BYTES_sha256 NIRAPOD_SHA2_HMAC_SHA256_BYTES
#define HMAC_BYTES_sha512 NIRAPOD_SHA2_HMAC_SHA512_BYTES
#define HMAC_CTX_sha256   NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES
#define HMAC_CTX_sha512   NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES
#define HMAC_FAMILY_sha256 NIRAPOD_SHA2_FAMILY_SHA256
#define HMAC_FAMILY_sha512 NIRAPOD_SHA2_FAMILY_SHA512
#define HMAC_BLOCK_sha256 64
#define HMAC_BLOCK_sha512 128

#define TESTING_HMAC_OPS(h)                                                    \
    int nirapod_sha2_testing_hmac_##h(nirapod_sha2_testing_kernel k, uint8_t *out, \
                                      const uint8_t *key, size_t key_len,      \
                                      const uint8_t *msg, size_t msg_len)      \
    {                                                                          \
        UNIT_OR_FAIL(k, HMAC_FAMILY_##h)                                       \
        return nirapod_sha2_run_hmac(u, HMAC_FAMILY_##h, u->hmac_##h,          \
                                     NIRAPOD_SHA2_MAX_BYTES - HMAC_BLOCK_##h,  \
                                     out, HMAC_BYTES_##h, key, key_len, msg, msg_len); \
    }                                                                          \
    int nirapod_sha2_testing_hmac_##h##_init(nirapod_sha2_testing_kernel k,    \
                                             nirapod_sha2_hmac_##h##_ctx *ctx, \
                                             const uint8_t *key, size_t key_len) \
    {                                                                          \
        UNIT_OR_FAIL(k, HMAC_FAMILY_##h)                                       \
        return nirapod_sha2_run_hmac_init(u, HMAC_FAMILY_##h, u->hmac_##h##_init, \
                                          ctx, HMAC_CTX_##h, key, key_len);    \
    }                                                                          \
    int nirapod_sha2_testing_hmac_##h##_update(nirapod_sha2_testing_kernel k,  \
                                               nirapod_sha2_hmac_##h##_ctx *ctx, \
                                               const uint8_t *in, size_t len)  \
    {                                                                          \
        UNIT_OR_FAIL(k, HMAC_FAMILY_##h)                                       \
        return nirapod_sha2_run_update(u, HMAC_FAMILY_##h, u->hmac_##h##_update, \
                                       ctx, HMAC_CTX_##h, in, len);            \
    }                                                                          \
    int nirapod_sha2_testing_hmac_##h##_final(nirapod_sha2_testing_kernel k,   \
                                              nirapod_sha2_hmac_##h##_ctx *ctx, \
                                              uint8_t *out)                    \
    {                                                                          \
        UNIT_OR_FAIL(k, HMAC_FAMILY_##h)                                       \
        return nirapod_sha2_run_final(u, HMAC_FAMILY_##h, u->hmac_##h##_final, \
                                      ctx, HMAC_CTX_##h, out, HMAC_BYTES_##h); \
    }

TESTING_HMAC_OPS(sha256)
TESTING_HMAC_OPS(sha512)

#define TESTING_LANES_OPS(h, FAMILY, WAYS, CTX, SRC_CTX, SRC_BYTES)                \
    int nirapod_sha2_testing_##h(nirapod_sha2_testing_kernel k, uint8_t *out,      \
                                 const uint8_t *const in[WAYS], size_t len)        \
    {                                                                              \
        UNIT_OR_FAIL(k, FAMILY)                                                    \
        return nirapod_sha2_run_lanes(u, FAMILY, u->h, WAYS, out, 256, in, len);   \
    }                                                                              \
    int nirapod_sha2_testing_##h##_init(nirapod_sha2_testing_kernel k, CTX *ctx)   \
    {                                                                              \
        UNIT_OR_FAIL(k, FAMILY)                                                    \
        return nirapod_sha2_run_init(u, FAMILY, u->h##_init, ctx);                 \
    }                                                                              \
    int nirapod_sha2_testing_##h##_init_from(nirapod_sha2_testing_kernel k, CTX *ctx, \
                                             const SRC_CTX *src)                   \
    {                                                                              \
        UNIT_OR_FAIL(k, FAMILY)                                                    \
        return nirapod_sha2_run_lanes_from(u, FAMILY, u->h##_init_from, ctx,       \
                                           sizeof(CTX), src, SRC_BYTES);           \
    }                                                                              \
    int nirapod_sha2_testing_##h##_update(nirapod_sha2_testing_kernel k, CTX *ctx, \
                                          const uint8_t *const in[WAYS], size_t len) \
    {                                                                              \
        UNIT_OR_FAIL(k, FAMILY)                                                    \
        return nirapod_sha2_run_lanes_update(u, FAMILY, u->h##_update, WAYS, ctx,  \
                                             sizeof(CTX), in, len);                \
    }                                                                              \
    int nirapod_sha2_testing_##h##_final(nirapod_sha2_testing_kernel k, CTX *ctx,  \
                                         uint8_t *out)                             \
    {                                                                              \
        UNIT_OR_FAIL(k, FAMILY)                                                    \
        return nirapod_sha2_run_final(u, FAMILY, u->h##_final, ctx, sizeof(CTX),   \
                                      out, 256);                                   \
    }

TESTING_LANES_OPS(sha256_x8, NIRAPOD_SHA2_FAMILY_X8, 8, nirapod_sha2_sha256_x8_ctx,
                  nirapod_sha2_sha256_ctx, NIRAPOD_SHA2_SHA256_CTX_BYTES)
TESTING_LANES_OPS(sha512_x4, NIRAPOD_SHA2_FAMILY_X4, 4, nirapod_sha2_sha512_x4_ctx,
                  nirapod_sha2_sha512_ctx, NIRAPOD_SHA2_SHA512_CTX_BYTES)
