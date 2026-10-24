/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * api.c
 * =====
 *
 * The public functions of nirapod_sha2.h and the checks they make. Their
 * contracts are in that header; this file is the boundary between them
 * and the Jasmin exports (jasmin.h).
 *
 * Responsibilities
 *
 *     argument checks that need the caller's pointers and lengths: NULL
 *     pointers, length limits, overlapping buffers
 *     the unit of the operation's family (dispatch.c)
 *     the timing mode around every export that reads a secret (timing.c),
 *     and clearing of the registers after every export (clear.c)
 *     mapping of the export's status to the error codes
 *
 * Everything that touches message bytes, keys, digests or contexts is
 * Jasmin: this file passes pointers and lengths and never reads or writes
 * a byte behind them. The checks that need a context's contents, its tag
 * and its stored total, are made by the export (src/context.jinc).
 *
 * Check order
 *
 *     NULL pointers, then lengths, then overlap, then the export. A check
 *     that fails returns before anything is written, so every failure
 *     leaves outputs and contexts as they were. Lengths come before
 *     overlap so that the overlap test only adds lengths already known to
 *     be below 2^61, and the multi-way input size 8 len or 4 len cannot
 *     wrap.
 *
 * Overlap
 *
 *     Two buffers overlap when they share a byte; a buffer of length 0
 *     overlaps nothing. The test compares addresses as integers, which is
 *     what the platforms supported here make meaningful. Inputs may overlap
 *     each other.
 */

#include "internal.h"

static int overlaps(const void *a, size_t a_len, const void *b, size_t b_len)
{
    uintptr_t pa = (uintptr_t)a;
    uintptr_t pb = (uintptr_t)b;

    if (a_len == 0 || b_len == 0) {
        return 0;
    }
    return pa < pb + b_len && pb < pa + a_len;
}

/* The export's status (jasmin.h) as an error code of nirapod_sha2.h. */
static int status_code(uint64_t status)
{
    switch (status) {
    case NIRAPOD_SHA2_JZ_STATUS_OK:
        return NIRAPOD_SHA2_OK;
    case NIRAPOD_SHA2_JZ_STATUS_LENGTH:
        return NIRAPOD_SHA2_ELENGTH;
    default:
        return NIRAPOD_SHA2_ESTATE;
    }
}

int nirapod_sha2_run_hash(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_hash op,
                          uint8_t *out, size_t out_len, const uint8_t *in, size_t len)
{
    uint64_t token;

    if (out == NULL || (in == NULL && len != 0)) {
        return NIRAPOD_SHA2_ENULL;
    }
    if ((uint64_t)len >= NIRAPOD_SHA2_MAX_BYTES) {
        return NIRAPOD_SHA2_ELENGTH;
    }
    if (overlaps(out, out_len, in, len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    op(out, in, (uint64_t)len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return NIRAPOD_SHA2_OK;
}

/*
 * The init of a hash or of a multi-way hash reads nothing: it writes the
 * initial hash values, a zero total and the context's tag, all constants
 * of the function, over whatever the context held. No instruction it runs
 * has a secret operand, so it runs without the timing mode (timing.c),
 * whose two writes would cost more than the export. The registers are
 * cleared after it as after every call. HMAC init reads the key and is
 * not one of these.
 */
int nirapod_sha2_run_init(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_init op, void *ctx)
{
    if (ctx == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }

    op((uint8_t *)ctx);
    nirapod_sha2_clear_registers(u->needs[f]);
    return NIRAPOD_SHA2_OK;
}

int nirapod_sha2_run_update(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                            nirapod_sha2_jz_update op, void *ctx, size_t ctx_len,
                            const uint8_t *in, size_t len)
{
    uint64_t token;
    uint64_t status;

    if (ctx == NULL || (in == NULL && len != 0)) {
        return NIRAPOD_SHA2_ENULL;
    }
    if ((uint64_t)len >= NIRAPOD_SHA2_MAX_BYTES) {
        return NIRAPOD_SHA2_ELENGTH;
    }
    if (overlaps(ctx, ctx_len, in, len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    status = op((uint8_t *)ctx, in, (uint64_t)len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return status_code(status);
}

int nirapod_sha2_run_final(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                           nirapod_sha2_jz_final op, void *ctx, size_t ctx_len,
                           uint8_t *out, size_t out_len)
{
    uint64_t token;
    uint64_t status;

    if (ctx == NULL || out == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }
    if (overlaps(ctx, ctx_len, out, out_len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    status = op((uint8_t *)ctx, out);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return status_code(status);
}

int nirapod_sha2_run_hmac(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_hmac op, uint64_t limit,
                          uint8_t *out, size_t out_len,
                          const uint8_t *key, size_t key_len,
                          const uint8_t *msg, size_t msg_len)
{
    uint64_t token;

    if (out == NULL || (key == NULL && key_len != 0) || (msg == NULL && msg_len != 0)) {
        return NIRAPOD_SHA2_ENULL;
    }
    if ((uint64_t)key_len >= NIRAPOD_SHA2_MAX_BYTES || (uint64_t)msg_len >= limit) {
        return NIRAPOD_SHA2_ELENGTH;
    }
    if (overlaps(out, out_len, key, key_len) || overlaps(out, out_len, msg, msg_len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    op(out, key, (uint64_t)key_len, msg, (uint64_t)msg_len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return NIRAPOD_SHA2_OK;
}

int nirapod_sha2_run_hmac_init(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                               nirapod_sha2_jz_hmac_init op, void *ctx, size_t ctx_len,
                               const uint8_t *key, size_t key_len)
{
    uint64_t token;

    if (ctx == NULL || (key == NULL && key_len != 0)) {
        return NIRAPOD_SHA2_ENULL;
    }
    if ((uint64_t)key_len >= NIRAPOD_SHA2_MAX_BYTES) {
        return NIRAPOD_SHA2_ELENGTH;
    }
    if (overlaps(ctx, ctx_len, key, key_len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    op((uint8_t *)ctx, key, (uint64_t)key_len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return NIRAPOD_SHA2_OK;
}

/*
 * The lane table of a multi-way call: every pointer checked, then copied
 * into table, the array the export reads. The copy means the export's
 * table can overlap no argument and cannot change between these checks
 * and its use. Copying the pointers reads no message or state byte.
 *
 * Returns 0, or the error code of the first failing check: ENULL for a
 * NULL table or a NULL lane when len > 0, EOVERLAP for a lane that
 * overlaps the writable buffer w of w_len bytes.
 */
static int lane_table(uint64_t *table, size_t ways, const uint8_t *const *in, size_t len,
                      const void *w, size_t w_len)
{
    size_t k;

    if (in == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }
    for (k = 0; k < ways; k++) {
        if (in[k] == NULL && len != 0) {
            return NIRAPOD_SHA2_ENULL;
        }
    }
    if ((uint64_t)len >= NIRAPOD_SHA2_MAX_BYTES) {
        return NIRAPOD_SHA2_ELENGTH;
    }
    for (k = 0; k < ways; k++) {
        if (overlaps(w, w_len, in[k], len)) {
            return NIRAPOD_SHA2_EOVERLAP;
        }
    }
    for (k = 0; k < ways; k++) {
        table[k] = (uint64_t)(uintptr_t)in[k];
    }
    return NIRAPOD_SHA2_OK;
}

int nirapod_sha2_run_lanes(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                           nirapod_sha2_jz_lanes op, size_t ways,
                           uint8_t *out, size_t out_len,
                           const uint8_t *const *in, size_t len)
{
    uint64_t table[8];
    uint64_t token;
    int rc;

    if (out == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }
    rc = lane_table(table, ways, in, len, out, out_len);
    if (rc != NIRAPOD_SHA2_OK) {
        return rc;
    }

    token = nirapod_sha2_timing_enter();
    op(out, table, (uint64_t)len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return NIRAPOD_SHA2_OK;
}

int nirapod_sha2_run_lanes_from(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                                nirapod_sha2_jz_lanes_from op, void *ctx, size_t ctx_len,
                                const void *src, size_t src_len)
{
    uint64_t token;
    uint64_t status;

    if (ctx == NULL || src == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }
    if (overlaps(ctx, ctx_len, src, src_len)) {
        return NIRAPOD_SHA2_EOVERLAP;
    }

    token = nirapod_sha2_timing_enter();
    status = op((uint8_t *)ctx, (const uint8_t *)src);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return status_code(status);
}

int nirapod_sha2_run_lanes_update(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                                  nirapod_sha2_jz_lanes_update op, size_t ways,
                                  void *ctx, size_t ctx_len,
                                  const uint8_t *const *in, size_t len)
{
    uint64_t table[8];
    uint64_t token;
    uint64_t status;
    int rc;

    if (ctx == NULL) {
        return NIRAPOD_SHA2_ENULL;
    }
    rc = lane_table(table, ways, in, len, ctx, ctx_len);
    if (rc != NIRAPOD_SHA2_OK) {
        return rc;
    }

    token = nirapod_sha2_timing_enter();
    status = op((uint8_t *)ctx, table, (uint64_t)len);
    nirapod_sha2_clear_registers(u->needs[f]);
    nirapod_sha2_timing_leave(token);
    return status_code(status);
}

/*
 * The public functions
 * --------------------
 *
 * Each one asks dispatch.c for the unit of its family and hands the
 * operation to the runner of its shape above. The macros only spell out
 * that pairing; the contracts are in nirapod_sha2.h.
 */

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

#define PUBLIC_HASH(h)                                                         \
    int nirapod_sha2_##h(uint8_t *out, const uint8_t *in, size_t len)          \
    {                                                                          \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY_##h);          \
        return nirapod_sha2_run_hash(u, FAMILY_##h, u->h, out, BYTES_##h, in, len); \
    }                                                                          \
    int nirapod_sha2_##h##_init(nirapod_sha2_##h##_ctx *ctx)                   \
    {                                                                          \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY_##h);          \
        return nirapod_sha2_run_init(u, FAMILY_##h, u->h##_init, ctx);         \
    }                                                                          \
    int nirapod_sha2_##h##_update(nirapod_sha2_##h##_ctx *ctx, const uint8_t *in, size_t len) \
    {                                                                          \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY_##h);          \
        return nirapod_sha2_run_update(u, FAMILY_##h, u->h##_update, ctx, CTX_##h, in, len); \
    }                                                                          \
    int nirapod_sha2_##h##_final(nirapod_sha2_##h##_ctx *ctx, uint8_t *out)    \
    {                                                                          \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY_##h);          \
        return nirapod_sha2_run_final(u, FAMILY_##h, u->h##_final, ctx, CTX_##h, out, BYTES_##h); \
    }

PUBLIC_HASH(sha224)
PUBLIC_HASH(sha256)
PUBLIC_HASH(sha384)
PUBLIC_HASH(sha512)
PUBLIC_HASH(sha512_224)
PUBLIC_HASH(sha512_256)

/* B + msg_len < 2^61 for the HMAC message (nirapod_sha2.h, "Lengths"). */
#define HMAC_SHA256_MSG_LIMIT (NIRAPOD_SHA2_MAX_BYTES - 64)
#define HMAC_SHA512_MSG_LIMIT (NIRAPOD_SHA2_MAX_BYTES - 128)

int nirapod_sha2_hmac_sha256(uint8_t *out, const uint8_t *key, size_t key_len,
                             const uint8_t *msg, size_t msg_len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA256);

    return nirapod_sha2_run_hmac(u, NIRAPOD_SHA2_FAMILY_SHA256, u->hmac_sha256,
                                 HMAC_SHA256_MSG_LIMIT, out, NIRAPOD_SHA2_HMAC_SHA256_BYTES,
                                 key, key_len, msg, msg_len);
}

int nirapod_sha2_hmac_sha512(uint8_t *out, const uint8_t *key, size_t key_len,
                             const uint8_t *msg, size_t msg_len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA512);

    return nirapod_sha2_run_hmac(u, NIRAPOD_SHA2_FAMILY_SHA512, u->hmac_sha512,
                                 HMAC_SHA512_MSG_LIMIT, out, NIRAPOD_SHA2_HMAC_SHA512_BYTES,
                                 key, key_len, msg, msg_len);
}

int nirapod_sha2_hmac_sha256_init(nirapod_sha2_hmac_sha256_ctx *ctx,
                                  const uint8_t *key, size_t key_len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA256);

    return nirapod_sha2_run_hmac_init(u, NIRAPOD_SHA2_FAMILY_SHA256, u->hmac_sha256_init,
                                      ctx, NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES, key, key_len);
}

int nirapod_sha2_hmac_sha256_update(nirapod_sha2_hmac_sha256_ctx *ctx,
                                    const uint8_t *in, size_t len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA256);

    return nirapod_sha2_run_update(u, NIRAPOD_SHA2_FAMILY_SHA256, u->hmac_sha256_update,
                                   ctx, NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES, in, len);
}

int nirapod_sha2_hmac_sha256_final(nirapod_sha2_hmac_sha256_ctx *ctx, uint8_t *out)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA256);

    return nirapod_sha2_run_final(u, NIRAPOD_SHA2_FAMILY_SHA256, u->hmac_sha256_final,
                                  ctx, NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES,
                                  out, NIRAPOD_SHA2_HMAC_SHA256_BYTES);
}

int nirapod_sha2_hmac_sha512_init(nirapod_sha2_hmac_sha512_ctx *ctx,
                                  const uint8_t *key, size_t key_len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA512);

    return nirapod_sha2_run_hmac_init(u, NIRAPOD_SHA2_FAMILY_SHA512, u->hmac_sha512_init,
                                      ctx, NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES, key, key_len);
}

int nirapod_sha2_hmac_sha512_update(nirapod_sha2_hmac_sha512_ctx *ctx,
                                    const uint8_t *in, size_t len)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA512);

    return nirapod_sha2_run_update(u, NIRAPOD_SHA2_FAMILY_SHA512, u->hmac_sha512_update,
                                   ctx, NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES, in, len);
}

int nirapod_sha2_hmac_sha512_final(nirapod_sha2_hmac_sha512_ctx *ctx, uint8_t *out)
{
    const nirapod_sha2_unit *u = nirapod_sha2_select(NIRAPOD_SHA2_FAMILY_SHA512);

    return nirapod_sha2_run_final(u, NIRAPOD_SHA2_FAMILY_SHA512, u->hmac_sha512_final,
                                  ctx, NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES,
                                  out, NIRAPOD_SHA2_HMAC_SHA512_BYTES);
}

#define LANES_FUNCTIONS(h, FAMILY, WAYS, OUT, CTX, SRC_CTX, SRC_BYTES)                  \
    int nirapod_sha2_##h(uint8_t *out, const uint8_t *const in[WAYS], size_t len)  \
    {                                                                              \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY);                  \
        return nirapod_sha2_run_lanes(u, FAMILY, u->h, WAYS, out, OUT, in, len);   \
    }                                                                              \
    int nirapod_sha2_##h##_init(CTX *ctx)                                          \
    {                                                                              \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY);                  \
        return nirapod_sha2_run_init(u, FAMILY, u->h##_init, ctx);                 \
    }                                                                              \
    int nirapod_sha2_##h##_init_from(CTX *ctx, const SRC_CTX *src)                 \
    {                                                                              \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY);                  \
        return nirapod_sha2_run_lanes_from(u, FAMILY, u->h##_init_from, ctx,       \
                                           sizeof(CTX), src, SRC_BYTES);           \
    }                                                                              \
    int nirapod_sha2_##h##_update(CTX *ctx, const uint8_t *const in[WAYS], size_t len) \
    {                                                                              \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY);                  \
        return nirapod_sha2_run_lanes_update(u, FAMILY, u->h##_update, WAYS, ctx,  \
                                             sizeof(CTX), in, len);                \
    }                                                                              \
    int nirapod_sha2_##h##_final(CTX *ctx, uint8_t *out)                           \
    {                                                                              \
        const nirapod_sha2_unit *u = nirapod_sha2_select(FAMILY);                  \
        return nirapod_sha2_run_final(u, FAMILY, u->h##_final, ctx, sizeof(CTX),   \
                                      out, OUT);                                   \
    }

LANES_FUNCTIONS(sha256_x8, NIRAPOD_SHA2_FAMILY_X8, 8, NIRAPOD_SHA2_SHA256_X8_BYTES,
                nirapod_sha2_sha256_x8_ctx,
                nirapod_sha2_sha256_ctx, NIRAPOD_SHA2_SHA256_CTX_BYTES)
LANES_FUNCTIONS(sha512_x4, NIRAPOD_SHA2_FAMILY_X4, 4, NIRAPOD_SHA2_SHA512_X4_BYTES,
                nirapod_sha2_sha512_x4_ctx,
                nirapod_sha2_sha512_ctx, NIRAPOD_SHA2_SHA512_CTX_BYTES)
