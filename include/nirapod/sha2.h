/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * nirapod/sha2.h
 * ==============
 *
 * SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224 and SHA-512/256 (FIPS
 * 180-4) and HMAC-SHA-256 and HMAC-SHA-512 (FIPS 198-1), computed by the
 * library's Jasmin code. This header is the whole public interface; the
 * library exports no other symbol.
 *
 * The library is under development and not for production use.
 *
 * Results
 *
 *     Every function returns NIRAPOD_SHA2_OK (0) or one of the negative
 *     NIRAPOD_SHA2_E* codes below. On failure no byte of any output or
 *     context is written: a failed call leaves the caller's memory as it
 *     was. The checks run in this order, and the first that fails decides
 *     the code:
 *
 *         NIRAPOD_SHA2_ENULL     a required pointer is NULL; an input
 *                                pointer may be NULL only with length 0
 *         NIRAPOD_SHA2_ELENGTH   a length is at or above its limit, or an
 *                                update would take the context's total
 *                                there (see "Lengths")
 *         NIRAPOD_SHA2_EOVERLAP  an output or context overlaps an input or
 *                                another output
 *         NIRAPOD_SHA2_ESTATE    the context was not initialised for this
 *                                function, or was finalised
 *
 *     The state check comes after the length and overlap checks except for
 *     update's own total limit, which is checked after it.
 *
 * Lengths
 *
 *     Every hash must cover fewer than 2^61 bytes (NIRAPOD_SHA2_MAX_BYTES).
 *     For SHA-224 and SHA-256 that is the FIPS 180-4 limit, set by their
 *     64-bit bit-length field. SHA-384, SHA-512 and SHA-512/t allow up to
 *     2^125 bytes; this library restricts them to the same bound, since it
 *     counts the bytes absorbed in one 64-bit word.
 *
 *         one-shot hash, multi-way    len < 2^61 (per message)
 *         update                      total + len < 2^61, total being the
 *                                     bytes the context has absorbed
 *         HMAC key                    key_len < 2^61
 *         HMAC message                B + msg_len < 2^61, B = 64 for
 *                                     HMAC-SHA-256 and 128 for HMAC-SHA-512;
 *                                     for the incremental form, over every
 *                                     update together
 *
 * Buffers
 *
 *     Outputs are exactly the digest or tag size given by the
 *     NIRAPOD_SHA2_*_BYTES macros, and exactly that many bytes are
 *     written. No alignment is required of any buffer except contexts,
 *     which have the alignment of their type. Inputs may overlap each
 *     other (an HMAC key and its message, for instance), never an output.
 *     Pointers must be valid for the stated number of bytes; the library
 *     cannot check that.
 *
 * Contexts
 *
 *     A context holds a hash or HMAC in progress. Its contents are private
 *     to the library and change in meaning between releases; only its
 *     size, given by sizeof and the NIRAPOD_SHA2_*_CTX_BYTES macros, is
 *     part of this interface. The caller owns the storage: on the stack,
 *     statically or on the heap. A context may be copied with memcpy to
 *     fork a hash; the copy continues independently.
 *
 *         init     makes the context ready, whatever it held before
 *         update   appends bytes; may be called any number of times,
 *                  including with len = 0
 *         final    writes the digest and zeroes the context
 *
 *     Using a context with a function of another type, or after final,
 *     fails with NIRAPOD_SHA2_ESTATE and changes nothing. A context that
 *     was never initialised is caller error: the library detects it unless
 *     its first eight bytes happen to hold a valid tag value, and in that
 *     case the result is a wrong digest, never a write outside the context
 *     or the output.
 *
 * Concurrency
 *
 *     The library allocates nothing. Its only global state is a cache of
 *     the CPU's features, written once on first use with atomic stores
 *     and never changed after; concurrent first calls are safe. Calls on
 *     distinct buffers and contexts may run concurrently; calls that
 *     share a context must be serialised by the caller.
 *
 * Security
 *
 *     Messages, keys, contexts, digests and tags are treated as secret,
 *     lengths and addresses as public. The Jasmin code is written so that
 *     no branch, loop bound or memory address depends on a secret, and
 *     `make ct` checks every export for it with the constant-time and
 *     speculative constant-time type checkers of the Jasmin toolchain.
 *     Running time also needs the CPU to execute the instructions used in
 *     time independent of their operands:
 *
 *         AArch64 with FEAT_DIT   the library sets PSTATE.DIT for the
 *                                 duration of each call that reads a
 *                                 message, key or context, and restores
 *                                 the caller's value before returning;
 *                                 an _init that takes only a context
 *                                 (no key, no source context) writes
 *                                 constants, reads none of them, and
 *                                 leaves PSTATE.DIT alone
 *         AArch64 without it      nothing is set; the caller depends on
 *                                 the CPU
 *         x86-64, Intel           DOITM is controlled by a model-specific
 *                                 register that user code cannot write;
 *                                 where the CPU enumerates it, the caller
 *                                 or the operating system must enable it
 *         x86-64, other CPUs      the caller depends on the CPU
 *
 *     Before returning, each call clears the stack its Jasmin code used
 *     and the caller-saved registers. The stack each call needs is
 *     documented per kernel with the library's sources ("Stack use" in
 *     its README). Contexts hold secret state between calls; final
 *     zeroes them, and a caller that abandons a context should clear it.
 *
 * Kernels
 *
 *     Each call chooses its implementation from the CPU features of the
 *     machine it runs on. The choice never changes a result.
 */

#ifndef NIRAPOD_SHA2_H
#define NIRAPOD_SHA2_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NIRAPOD_SHA2_OK         0
#define NIRAPOD_SHA2_ENULL     -1
#define NIRAPOD_SHA2_ELENGTH   -2
#define NIRAPOD_SHA2_EOVERLAP  -3
#define NIRAPOD_SHA2_ESTATE    -4

/* Every hash covers fewer than this many bytes (2^61). */
#define NIRAPOD_SHA2_MAX_BYTES (UINT64_C(1) << 61)

#define NIRAPOD_SHA2_SHA224_BYTES      28
#define NIRAPOD_SHA2_SHA256_BYTES      32
#define NIRAPOD_SHA2_SHA384_BYTES      48
#define NIRAPOD_SHA2_SHA512_BYTES      64
#define NIRAPOD_SHA2_SHA512_224_BYTES  28
#define NIRAPOD_SHA2_SHA512_256_BYTES  32
#define NIRAPOD_SHA2_HMAC_SHA256_BYTES 32
#define NIRAPOD_SHA2_HMAC_SHA512_BYTES 64

/* Multi-way outputs: 8 SHA-256 digests, 4 SHA-512 digests. */
#define NIRAPOD_SHA2_SHA256_X8_BYTES  (8 * NIRAPOD_SHA2_SHA256_BYTES)
#define NIRAPOD_SHA2_SHA512_X4_BYTES  (4 * NIRAPOD_SHA2_SHA512_BYTES)

#define NIRAPOD_SHA2_SHA256_CTX_BYTES      112
#define NIRAPOD_SHA2_SHA512_CTX_BYTES      208
#define NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES 144
#define NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES 272
#define NIRAPOD_SHA2_SHA256_X8_CTX_BYTES   784
#define NIRAPOD_SHA2_SHA512_X4_CTX_BYTES   784

/*
 * Context types. Each function has its own type, so that passing a
 * context to a function of another type is a compile-time error; the
 * library also rejects it at run time. Sizes are the *_CTX_BYTES above,
 * alignment that of uint64_t.
 */
typedef struct nirapod_sha2_sha224_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA256_CTX_BYTES / 8];
} nirapod_sha2_sha224_ctx;

typedef struct nirapod_sha2_sha256_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA256_CTX_BYTES / 8];
} nirapod_sha2_sha256_ctx;

typedef struct nirapod_sha2_sha384_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA512_CTX_BYTES / 8];
} nirapod_sha2_sha384_ctx;

typedef struct nirapod_sha2_sha512_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA512_CTX_BYTES / 8];
} nirapod_sha2_sha512_ctx;

typedef struct nirapod_sha2_sha512_224_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA512_CTX_BYTES / 8];
} nirapod_sha2_sha512_224_ctx;

typedef struct nirapod_sha2_sha512_256_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA512_CTX_BYTES / 8];
} nirapod_sha2_sha512_256_ctx;

typedef struct nirapod_sha2_hmac_sha256_ctx {
    uint64_t opaque[NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES / 8];
} nirapod_sha2_hmac_sha256_ctx;

typedef struct nirapod_sha2_hmac_sha512_ctx {
    uint64_t opaque[NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES / 8];
} nirapod_sha2_hmac_sha512_ctx;

typedef struct nirapod_sha2_sha256_x8_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA256_X8_CTX_BYTES / 8];
} nirapod_sha2_sha256_x8_ctx;

typedef struct nirapod_sha2_sha512_x4_ctx {
    uint64_t opaque[NIRAPOD_SHA2_SHA512_X4_CTX_BYTES / 8];
} nirapod_sha2_sha512_x4_ctx;

/*
 * One-shot hashes: out receives the digest of the len bytes at in.
 *
 *     out  NIRAPOD_SHA2_<HASH>_BYTES bytes, not overlapping in
 *     in   len bytes; NULL allowed when len = 0
 *     len  < NIRAPOD_SHA2_MAX_BYTES
 *
 * Errors: ENULL, ELENGTH, EOVERLAP.
 */
int nirapod_sha2_sha224(uint8_t *out, const uint8_t *in, size_t len);
int nirapod_sha2_sha256(uint8_t *out, const uint8_t *in, size_t len);
int nirapod_sha2_sha384(uint8_t *out, const uint8_t *in, size_t len);
int nirapod_sha2_sha512(uint8_t *out, const uint8_t *in, size_t len);
int nirapod_sha2_sha512_224(uint8_t *out, const uint8_t *in, size_t len);
int nirapod_sha2_sha512_256(uint8_t *out, const uint8_t *in, size_t len);

/*
 * Incremental hashes.
 *
 * init:   ctx becomes a new hash of the empty message. Errors: ENULL.
 *
 * update: appends the len bytes at in. in may be NULL when len = 0; in
 *         must not overlap ctx. Errors: ENULL, ELENGTH (len at or above
 *         NIRAPOD_SHA2_MAX_BYTES, or the context's total would reach it),
 *         EOVERLAP, ESTATE. On error the context is unchanged and may be
 *         used further.
 *
 * final:  writes the digest of everything absorbed to out
 *         (NIRAPOD_SHA2_<HASH>_BYTES bytes, not overlapping ctx), then
 *         zeroes ctx, which must be initialised again before reuse.
 *         Errors: ENULL, EOVERLAP, ESTATE; on error neither ctx nor out
 *         is written.
 */
int nirapod_sha2_sha224_init(nirapod_sha2_sha224_ctx *ctx);
int nirapod_sha2_sha224_update(nirapod_sha2_sha224_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha224_final(nirapod_sha2_sha224_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha256_init(nirapod_sha2_sha256_ctx *ctx);
int nirapod_sha2_sha256_update(nirapod_sha2_sha256_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha256_final(nirapod_sha2_sha256_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha384_init(nirapod_sha2_sha384_ctx *ctx);
int nirapod_sha2_sha384_update(nirapod_sha2_sha384_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha384_final(nirapod_sha2_sha384_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha512_init(nirapod_sha2_sha512_ctx *ctx);
int nirapod_sha2_sha512_update(nirapod_sha2_sha512_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha512_final(nirapod_sha2_sha512_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha512_224_init(nirapod_sha2_sha512_224_ctx *ctx);
int nirapod_sha2_sha512_224_update(nirapod_sha2_sha512_224_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha512_224_final(nirapod_sha2_sha512_224_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha512_256_init(nirapod_sha2_sha512_256_ctx *ctx);
int nirapod_sha2_sha512_256_update(nirapod_sha2_sha512_256_ctx *ctx, const uint8_t *in, size_t len);
int nirapod_sha2_sha512_256_final(nirapod_sha2_sha512_256_ctx *ctx, uint8_t *out);

/*
 * One-shot HMAC: out receives HMAC(key, msg).
 *
 *     out      NIRAPOD_SHA2_HMAC_<HASH>_BYTES bytes, overlapping neither
 *              key nor msg
 *     key      key_len bytes, any length below NIRAPOD_SHA2_MAX_BYTES;
 *              NULL allowed when key_len = 0
 *     msg      msg_len bytes, msg_len < NIRAPOD_SHA2_MAX_BYTES - B;
 *              NULL allowed when msg_len = 0
 *
 * Errors: ENULL, ELENGTH, EOVERLAP.
 */
int nirapod_sha2_hmac_sha256(uint8_t *out, const uint8_t *key, size_t key_len,
                             const uint8_t *msg, size_t msg_len);
int nirapod_sha2_hmac_sha512(uint8_t *out, const uint8_t *key, size_t key_len,
                             const uint8_t *msg, size_t msg_len);

/*
 * Incremental HMAC, with the context rules of the incremental hashes.
 *
 * init:   ctx becomes an HMAC under key (key_len bytes as for the
 *         one-shot form; key must not overlap ctx). The key is not
 *         retained: ctx holds the two hash states derived from it, which
 *         are as sensitive as the key. Errors: ENULL, ELENGTH, EOVERLAP.
 *
 * update, final: as for the hashes. The message limit counts every update
 *         together with the key block B.
 */
int nirapod_sha2_hmac_sha256_init(nirapod_sha2_hmac_sha256_ctx *ctx,
                                  const uint8_t *key, size_t key_len);
int nirapod_sha2_hmac_sha256_update(nirapod_sha2_hmac_sha256_ctx *ctx,
                                    const uint8_t *in, size_t len);
int nirapod_sha2_hmac_sha256_final(nirapod_sha2_hmac_sha256_ctx *ctx, uint8_t *out);

int nirapod_sha2_hmac_sha512_init(nirapod_sha2_hmac_sha512_ctx *ctx,
                                  const uint8_t *key, size_t key_len);
int nirapod_sha2_hmac_sha512_update(nirapod_sha2_hmac_sha512_ctx *ctx,
                                    const uint8_t *in, size_t len);
int nirapod_sha2_hmac_sha512_final(nirapod_sha2_hmac_sha512_ctx *ctx, uint8_t *out);

/*
 * Multi-way hashes: 8 SHA-256 or 4 SHA-512 hashes of messages of equal
 * length, computed together. Lane k's message is the len bytes at in[k],
 * and its digest is written at out + k * NIRAPOD_SHA2_SHA256_BYTES
 * (SHA-512: NIRAPOD_SHA2_SHA512_BYTES). The result is that of the one-shot
 * function on each message.
 *
 *     out  NIRAPOD_SHA2_SHA256_X8_BYTES (SHA512_X4) bytes, overlapping no
 *          lane
 *     in   a table of 8 (4) pointers; lanes may overlap each other and may
 *          be NULL when len = 0. The table is an array of const uint8_t *;
 *          an array of uint8_t * needs a cast.
 *     len  < NIRAPOD_SHA2_MAX_BYTES
 *
 * Errors: ENULL, ELENGTH, EOVERLAP.
 */
int nirapod_sha2_sha256_x8(uint8_t *out, const uint8_t *const in[8], size_t len);
int nirapod_sha2_sha512_x4(uint8_t *out, const uint8_t *const in[4], size_t len);

/*
 * Incremental multi-way hashes, with the context rules of the incremental
 * hashes; every update appends len bytes to every lane.
 *
 * init:      every lane becomes a new hash of the empty message.
 *            Errors: ENULL.
 *
 * init_from: every lane continues the hash in src, a SHA-256 (SHA-512)
 *            context: its message so far becomes the first bytes of every
 *            lane's message. src is not changed and may be used further.
 *            ctx and src must not overlap. Errors: ENULL, EOVERLAP, ESTATE
 *            (src is not an initialised SHA-256 (SHA-512) context, or was
 *            finalised); on error ctx is not written.
 *
 * update:    appends the len bytes at in[k] to lane k. No lane may overlap
 *            ctx. Errors: ENULL, ELENGTH, EOVERLAP, ESTATE; on error the
 *            context is unchanged.
 *
 * final:     writes the 8 (4) digests to out as the one-shot form does,
 *            then zeroes ctx. Errors: ENULL, EOVERLAP, ESTATE; on error
 *            neither ctx nor out is written.
 */
int nirapod_sha2_sha256_x8_init(nirapod_sha2_sha256_x8_ctx *ctx);
int nirapod_sha2_sha256_x8_init_from(nirapod_sha2_sha256_x8_ctx *ctx,
                                     const nirapod_sha2_sha256_ctx *src);
int nirapod_sha2_sha256_x8_update(nirapod_sha2_sha256_x8_ctx *ctx,
                                  const uint8_t *const in[8], size_t len);
int nirapod_sha2_sha256_x8_final(nirapod_sha2_sha256_x8_ctx *ctx, uint8_t *out);

int nirapod_sha2_sha512_x4_init(nirapod_sha2_sha512_x4_ctx *ctx);
int nirapod_sha2_sha512_x4_init_from(nirapod_sha2_sha512_x4_ctx *ctx,
                                     const nirapod_sha2_sha512_ctx *src);
int nirapod_sha2_sha512_x4_update(nirapod_sha2_sha512_x4_ctx *ctx,
                                  const uint8_t *const in[4], size_t len);
int nirapod_sha2_sha512_x4_final(nirapod_sha2_sha512_x4_ctx *ctx, uint8_t *out);

#ifdef __cplusplus
}
#endif

#endif /* NIRAPOD_SHA2_H */
