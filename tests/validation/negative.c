/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * negative.c
 * ==========
 *
 * Negative and misuse tests of the C API, against nirapod_sha2.h,
 * "Results", "Lengths" and "Contexts": NULL pointers, every overlapping
 * placement of an output and an input, a context and an input, update and
 * final after final, contexts of another function, uninitialised
 * contexts, the length limits, and the state of every output and context
 * after a failure.
 *
 * The context total limit is tested by writing the total field of a
 * context directly, at byte offset 8 as src/context.jinc lays it out.
 * That field is not part of the API; this is the only place the suite
 * looks inside a context, and it looks only at the total.
 */

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OVERLAP_BUFFER 2048
#define OVERLAP_CTX_OFF 512

static void misuse_hash(validation_suite *s, const hash_alg *a, int kernel)
{
    uint8_t buf[OVERLAP_BUFFER];
    uint8_t snap[OVERLAP_BUFFER];
    uint8_t out[64 + 16], ref[64];
    validation_ctx c, before;
    size_t in_len, d;
    const size_t digest_len = a->digest_len;
    int rc;

    /* NULL pointers. */
    guard_fill(out, sizeof out);
    check_code(s, kernel, hash_oneshot(a, kernel, NULL, buf, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL output", a->name);
    check_code(s, kernel, hash_oneshot(a, kernel, out, NULL, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL input with length 1", a->name);
    check(s, kernel, guard_intact(out, sizeof out), "%s: failed call wrote output", a->name);
    check_code(s, kernel, hash_oneshot(a, kernel, out, NULL, 0), NIRAPOD_SHA2_OK,
               "%s: NULL input with length 0", a->name);
    check_code(s, kernel, hash_init(a, kernel, NULL), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to init", a->name);
    check_code(s, kernel, hash_update(a, kernel, NULL, buf, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to update", a->name);
    check_code(s, kernel, hash_final(a, kernel, NULL, out), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to final", a->name);

    memset(&c, 0, sizeof c);
    check_code(s, kernel, hash_init(a, kernel, &c), NIRAPOD_SHA2_OK, "%s: init", a->name);
    before = c;
    guard_fill(out, sizeof out);
    check_code(s, kernel, hash_final(a, kernel, &c, NULL), NIRAPOD_SHA2_ENULL,
               "%s: NULL output to final", a->name);
    check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0, "%s: NULL final changed the context",
          a->name);

    /* Length limits. The checks run before any byte of the input is read. */
    guard_fill(out, sizeof out);
    check_code(s, kernel, hash_oneshot(a, kernel, out, buf, (size_t)NIRAPOD_SHA2_MAX_BYTES),
               NIRAPOD_SHA2_ELENGTH, "%s: one-shot length 2^61", a->name);
    check(s, kernel, guard_intact(out, sizeof out), "%s: length failure wrote output", a->name);
    hash_init(a, kernel, &c);
    before = c;
    check_code(s, kernel,
               hash_update(a, kernel, &c, buf, (size_t)NIRAPOD_SHA2_MAX_BYTES),
               NIRAPOD_SHA2_ELENGTH, "%s: update length 2^61", a->name);
    check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
          "%s: length failure changed the context", a->name);

    /* The context total limit, checked inside the export. */
    hash_init(a, kernel, &c);
    c.words[1] = NIRAPOD_SHA2_MAX_BYTES - 10;
    before = c;
    check_code(s, kernel, hash_update(a, kernel, &c, buf, 10), NIRAPOD_SHA2_ELENGTH,
               "%s: update to total 2^61", a->name);
    check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
          "%s: total failure changed the context", a->name);
    check_code(s, kernel, hash_update(a, kernel, &c, buf, 9), NIRAPOD_SHA2_OK,
               "%s: update to total 2^61 - 1", a->name);
    check(s, kernel, c.words[1] == NIRAPOD_SHA2_MAX_BYTES - 1, "%s: total after accepted update",
          a->name);

    /* One-shot overlap: every placement of out over in, and the two
     * adjacent placements. */
    fill_pattern(buf, sizeof buf, 71);
    in_len = 0;
    for (d = 0; d < 4; d++) {
        static const size_t lens[] = { 1, 3, 32, 64 };

        in_len = lens[d] < digest_len ? lens[d] : digest_len;
        {
            uint8_t *in = buf + 1024;
            uint8_t *outp;
            long long delta;

            hash_oneshot(a, kernel, ref, in, in_len);
            for (delta = -(long long)(digest_len - 1); delta <= (long long)in_len - 1; delta++) {
                outp = in + delta;
                memcpy(snap, buf, sizeof buf);
                rc = hash_oneshot(a, kernel, outp, in, in_len);
                if (rc != NIRAPOD_SHA2_EOVERLAP) {
                    check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                               "%s: one-shot overlap at %lld (length %zu)", a->name, delta,
                               in_len);
                } else {
                    count_pass(s, kernel);
                }
                if (memcmp(buf, snap, sizeof buf) != 0) {
                    fail_case(s, kernel, "%s: failed one-shot overlap at %lld wrote memory",
                              a->name, delta);
                }
            }
            for (delta = -(long long)digest_len; delta <= (long long)in_len; delta +=
                 (long long)digest_len + (long long)in_len) {
                memcpy(out, snap, sizeof out);
                rc = hash_oneshot(a, kernel, in + delta, in, in_len);
                if (rc != NIRAPOD_SHA2_OK) {
                    fail_case(s, kernel, "%s: adjacent one-shot at %lld returned %d", a->name,
                              delta, rc);
                } else {
                    check_bytes(s, kernel, in + delta, ref, digest_len,
                                "%s: adjacent one-shot at %lld", a->name, delta);
                }
            }
        }
    }

    /* Update overlap: every placement of the input over the context. */
    for (d = 0; d < 3; d++) {
        static const size_t lens[] = { 1, 3, 64 };

        in_len = lens[d];
        {
            uint8_t *ctx = buf + OVERLAP_CTX_OFF;
            uint8_t *in;
            long long delta;

            hash_init(a, kernel, &c);
            memcpy(ctx, &c, a->ctx_len);
            for (delta = -(long long)(in_len - 1); delta <= (long long)a->ctx_len - 1; delta++) {
                in = ctx + delta;
                memcpy(snap, buf, sizeof buf);
                rc = hash_update(a, kernel, ctx, in, in_len);
                if (rc != NIRAPOD_SHA2_EOVERLAP) {
                    check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                               "%s: update overlap at %lld (length %zu)", a->name, delta,
                               in_len);
                } else {
                    count_pass(s, kernel);
                }
                if (memcmp(buf, snap, sizeof buf) != 0) {
                    fail_case(s, kernel, "%s: failed update overlap at %lld wrote memory",
                              a->name, delta);
                }
            }
            for (delta = -(long long)in_len; delta <= (long long)a->ctx_len;
                 delta += (long long)in_len + (long long)a->ctx_len) {
                hash_oneshot(a, kernel, ref, ctx + delta, in_len);
                check_code(s, kernel, hash_init(a, kernel, ctx), NIRAPOD_SHA2_OK,
                           "%s: adjacent update init", a->name);
                rc = hash_update(a, kernel, ctx, ctx + delta, in_len);
                if (rc != NIRAPOD_SHA2_OK) {
                    fail_case(s, kernel, "%s: adjacent update at %lld returned %d", a->name,
                              delta, rc);
                } else {
                    rc = hash_final(a, kernel, ctx, out);
                    if (rc != NIRAPOD_SHA2_OK) {
                        fail_case(s, kernel, "%s: adjacent update final returned %d", a->name,
                                  rc);
                    } else {
                        check_bytes(s, kernel, out, ref, digest_len,
                                    "%s: adjacent update at %lld", a->name, delta);
                    }
                }
            }
        }
    }

    /* Final overlap: every placement of the output over the context. */
    {
        uint8_t *ctx = buf + OVERLAP_CTX_OFF;
        uint8_t *outp;
        long long delta;

        for (delta = -(long long)(digest_len - 1); delta <= (long long)a->ctx_len - 1; delta++) {
            outp = ctx + delta;
            hash_init(a, kernel, ctx);
            memcpy(snap, buf, sizeof buf);
            rc = hash_final(a, kernel, ctx, outp);
            if (rc != NIRAPOD_SHA2_EOVERLAP) {
                check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                           "%s: final overlap at %lld", a->name, delta);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed final overlap at %lld wrote memory", a->name,
                          delta);
            }
        }
        /* The two adjacent placements: out ends where the context starts,
         * or starts where the context ends. */
        hash_oneshot(a, kernel, ref, NULL, 0);
        for (delta = -(long long)digest_len; delta <= (long long)a->ctx_len;
             delta += (long long)digest_len + (long long)a->ctx_len) {
            hash_init(a, kernel, ctx);
            memset(out, VALIDATION_GUARD, sizeof out);
            rc = hash_final(a, kernel, ctx, ctx + delta);
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: adjacent final at %lld returned %d", a->name, delta,
                          rc);
            } else if (memcmp(ctx + delta, ref, digest_len) != 0) {
                fail_case(s, kernel, "%s: adjacent final at %lld wrote the wrong digest",
                          a->name, delta);
            } else {
                count_pass(s, kernel);
            }
        }
    }

    /* Update and final after final, and the clearing of the context. */
    {
        size_t i;
        int zeroed = 1;

        memset(&c, 0, sizeof c);
        hash_init(a, kernel, &c);
        hash_update(a, kernel, &c, buf, 3);
        guard_fill(out, sizeof out);
        check_code(s, kernel, hash_final(a, kernel, &c, out), NIRAPOD_SHA2_OK,
                   "%s: final", a->name);
        for (i = 0; i < a->ctx_len / 8; i++) {
            zeroed = zeroed && c.words[i] == 0;
        }
        check(s, kernel, zeroed, "%s: final did not zero the context", a->name);
        before = c;
        memcpy(snap, out, sizeof out);
        check_code(s, kernel, hash_update(a, kernel, &c, buf, 3), NIRAPOD_SHA2_ESTATE,
                   "%s: update after final", a->name);
        check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
              "%s: update after final changed the context", a->name);
        check_code(s, kernel, hash_final(a, kernel, &c, out), NIRAPOD_SHA2_ESTATE,
                   "%s: final after final", a->name);
        check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
              "%s: final after final changed the context", a->name);
        check(s, kernel, memcmp(out, snap, sizeof out) == 0,
              "%s: final after final wrote output", a->name);
    }

    /* Uninitialised contexts must fail with ESTATE and change nothing. */
    {
        static const uint64_t patterns[] = { 0, UINT64_MAX, UINT64_C(0x000001003268736e) ^ 1 };
        size_t p;

        for (p = 0; p < sizeof patterns / sizeof patterns[0]; p++) {
            memset(&c, 0, sizeof c);
            c.words[0] = patterns[p];
            before = c;
            guard_fill(out, sizeof out);
            check_code(s, kernel, hash_update(a, kernel, &c, buf, 3), NIRAPOD_SHA2_ESTATE,
                       "%s: update on uninitialised context %zu", a->name, p);
            check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
                  "%s: uninitialised update changed the context", a->name);
            check_code(s, kernel, hash_final(a, kernel, &c, out), NIRAPOD_SHA2_ESTATE,
                       "%s: final on uninitialised context %zu", a->name, p);
            check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
                  "%s: uninitialised final changed the context", a->name);
            check(s, kernel, guard_intact(out, sizeof out),
                  "%s: uninitialised final wrote output", a->name);
        }
    }

    /* init accepts a context holding anything. */
    {
        memset(&c, 0xaa, sizeof c);
        check_code(s, kernel, hash_init(a, kernel, &c), NIRAPOD_SHA2_OK,
                   "%s: init on garbage", a->name);
        check_code(s, kernel, hash_final(a, kernel, &c, out), NIRAPOD_SHA2_OK,
                   "%s: final after init on garbage", a->name);
        check_code(s, kernel, hash_oneshot(a, kernel, ref, NULL, 0), NIRAPOD_SHA2_OK,
                   "%s: empty reference", a->name);
        check_bytes(s, kernel, out, ref, digest_len, "%s: init on garbage is the empty hash",
                    a->name);
    }
}

static void misuse_hmac(validation_suite *s, const hmac_alg *a, int kernel)
{
    uint8_t buf[OVERLAP_BUFFER];
    uint8_t snap[OVERLAP_BUFFER];
    uint8_t out[64 + 16], ref[64], ref2[64];
    uint8_t key[512], msg[512];
    validation_ctx c, before;
    size_t key_len, msg_len;
    const size_t digest_len = a->digest_len;
    int rc;

    fill_pattern(key, sizeof key, 83);
    fill_pattern(msg, sizeof msg, 97);

    guard_fill(out, sizeof out);
    check_code(s, kernel, hmac_oneshot(a, kernel, NULL, key, 1, msg, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL output", a->name);
    check_code(s, kernel, hmac_oneshot(a, kernel, out, NULL, 1, msg, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL key with length 1", a->name);
    check_code(s, kernel, hmac_oneshot(a, kernel, out, key, 1, NULL, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL message with length 1", a->name);
    check(s, kernel, guard_intact(out, sizeof out), "%s: failed call wrote output", a->name);
    check_code(s, kernel, hmac_oneshot(a, kernel, out, NULL, 0, NULL, 0), NIRAPOD_SHA2_OK,
               "%s: NULL key and message with length 0", a->name);
    check_code(s, kernel, hmac_init(a, kernel, NULL, key, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to init", a->name);
    check_code(s, kernel, hmac_update(a, kernel, NULL, msg, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to update", a->name);
    check_code(s, kernel, hmac_final(a, kernel, NULL, out), NIRAPOD_SHA2_ENULL,
               "%s: NULL context to final", a->name);

    memset(&c, 0, sizeof c);
    check_code(s, kernel, hmac_init(a, kernel, &c, key, 20), NIRAPOD_SHA2_OK, "%s: init",
               a->name);
    before = c;
    guard_fill(out, sizeof out);
    check_code(s, kernel, hmac_final(a, kernel, &c, NULL), NIRAPOD_SHA2_ENULL,
               "%s: NULL output to final", a->name);
    check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0, "%s: NULL final changed the context",
          a->name);

    guard_fill(out, sizeof out);
    check_code(s, kernel, hmac_oneshot(a, kernel, out, key, (size_t)NIRAPOD_SHA2_MAX_BYTES, msg,
                                       0),
               NIRAPOD_SHA2_ELENGTH, "%s: key length 2^61", a->name);
    check(s, kernel, guard_intact(out, sizeof out), "%s: key length failure wrote output",
          a->name);
    check_code(s, kernel,
               hmac_oneshot(a, kernel, out, key, 0, msg,
                            (size_t)(NIRAPOD_SHA2_MAX_BYTES - a->block_len)),
               NIRAPOD_SHA2_ELENGTH, "%s: message limit", a->name);
    hmac_init(a, kernel, &c, key, 20);
    c.words[1] = NIRAPOD_SHA2_MAX_BYTES - 1;
    before = c;
    check_code(s, kernel, hmac_update(a, kernel, &c, msg, 1), NIRAPOD_SHA2_ELENGTH,
               "%s: update to total 2^61", a->name);
    check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
          "%s: total failure changed the context", a->name);

    /* One-shot overlap of the output with the key and with the message. */
    {
        uint8_t *in = buf + 1024;
        long long delta;

        key_len = 32;
        msg_len = 48;
        hmac_oneshot(a, kernel, ref, key, key_len, msg, msg_len);
        for (delta = -(long long)(digest_len - 1); delta <= (long long)key_len - 1; delta++) {
            memcpy(snap, buf, sizeof buf);
            rc = hmac_oneshot(a, kernel, in + delta, in, key_len, msg, msg_len);
            if (rc != NIRAPOD_SHA2_EOVERLAP) {
                check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                           "%s: output over key at %lld", a->name, delta);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed output/key overlap at %lld wrote memory",
                          a->name, delta);
            }
        }
        for (delta = -(long long)(digest_len - 1);
             delta <= (long long)msg_len - 1; delta++) {
            memcpy(snap, buf, sizeof buf);
            rc = hmac_oneshot(a, kernel, in + delta, key, key_len, in, msg_len);
            if (rc != NIRAPOD_SHA2_EOVERLAP) {
                check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                           "%s: output over message at %lld", a->name, delta);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed output/message overlap at %lld wrote memory",
                          a->name, delta);
            }
        }
        /* The key and the message may overlap each other. The message
         * starts inside the key, so its first 16 bytes are key bytes; the
         * separate call uses the same bytes at separate addresses. */
        {
            uint8_t both[64 + 16];

            memcpy(both, key, key_len);
            memcpy(both + 16, msg, msg_len);
            check_code(s, kernel,
                       hmac_oneshot(a, kernel, out, both, key_len, both + 16, msg_len),
                       NIRAPOD_SHA2_OK, "%s: overlapping key and message", a->name);
            memcpy(buf, both, key_len);
            memcpy(buf + 512, both + 16, msg_len);
            rc = hmac_oneshot(a, kernel, ref2, buf, key_len, buf + 512, msg_len);
            if (rc != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: separate key and message returned %d", a->name, rc);
            } else {
                check_bytes(s, kernel, out, ref2, digest_len,
                            "%s: overlapping key and message agree", a->name);
            }
        }
        (void)ref;
    }

    /* Init overlap: every placement of the key over the context. */
    {
        uint8_t *ctx = buf + OVERLAP_CTX_OFF;
        long long delta;

        for (key_len = 0; key_len < 3; key_len++) {
            size_t kl = key_len == 0 ? 1 : key_len * a->block_len;

            fill_pattern(buf, sizeof buf, 101);
            memset(ctx, 0, a->ctx_len);
            for (delta = -(long long)(kl - 1); delta <= (long long)a->ctx_len - 1; delta++) {
                memcpy(snap, buf, sizeof buf);
                rc = hmac_init(a, kernel, ctx, ctx + delta, kl);
                if (rc != NIRAPOD_SHA2_EOVERLAP) {
                    check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                               "%s: init key overlap at %lld (length %zu)", a->name, delta, kl);
                } else {
                    count_pass(s, kernel);
                }
                if (memcmp(buf, snap, sizeof buf) != 0) {
                    fail_case(s, kernel, "%s: failed init overlap at %lld wrote memory", a->name,
                              delta);
                }
            }
            for (delta = -(long long)kl; delta <= (long long)a->ctx_len;
                 delta += (long long)kl + (long long)a->ctx_len) {
                check_code(s, kernel, hmac_init(a, kernel, ctx, ctx + delta, kl), NIRAPOD_SHA2_OK,
                           "%s: adjacent init key at %lld", a->name, delta);
            }
        }
    }

    /* Update object overlap and final output overlap reuse the hash layout. */
    {
        uint8_t *ctx = buf + OVERLAP_CTX_OFF;
        long long delta;

        fill_pattern(buf, sizeof buf, 103);
        hmac_init(a, kernel, ctx, key, 20);
        for (delta = 0; delta <= (long long)a->ctx_len - 1; delta++) {
            memcpy(snap, buf, sizeof buf);
            rc = hmac_update(a, kernel, ctx, ctx + delta, 3);
            if (rc != NIRAPOD_SHA2_EOVERLAP) {
                check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                           "%s: update overlap at %lld", a->name, delta);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed update overlap at %lld wrote memory", a->name,
                          delta);
            }
        }
        for (delta = 0; delta <= (long long)a->ctx_len - 1; delta++) {
            hmac_init(a, kernel, ctx, key, 20);
            memcpy(snap, buf, sizeof buf);
            rc = hmac_final(a, kernel, ctx, ctx + delta);
            if (rc != NIRAPOD_SHA2_EOVERLAP) {
                check_code(s, kernel, rc, NIRAPOD_SHA2_EOVERLAP,
                           "%s: final overlap at %lld", a->name, delta);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed final overlap at %lld wrote memory", a->name,
                          delta);
            }
        }
    }

    /* State after final, uninitialised contexts, init on garbage. */
    {
        size_t i;
        int zeroed = 1;

        memset(&c, 0, sizeof c);
        hmac_init(a, kernel, &c, key, 20);
        hmac_update(a, kernel, &c, msg, 5);
        check_code(s, kernel, hmac_final(a, kernel, &c, out), NIRAPOD_SHA2_OK, "%s: final",
                   a->name);
        for (i = 0; i < a->ctx_len / 8; i++) {
            zeroed = zeroed && c.words[i] == 0;
        }
        check(s, kernel, zeroed, "%s: final did not zero the context", a->name);
        before = c;
        check_code(s, kernel, hmac_update(a, kernel, &c, msg, 1), NIRAPOD_SHA2_ESTATE,
                   "%s: update after final", a->name);
        check_code(s, kernel, hmac_final(a, kernel, &c, out), NIRAPOD_SHA2_ESTATE,
                   "%s: final after final", a->name);
        check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
              "%s: state failures changed the context", a->name);

        memset(&c, 0, sizeof c);
        before = c;
        check_code(s, kernel, hmac_update(a, kernel, &c, msg, 1), NIRAPOD_SHA2_ESTATE,
                   "%s: update on uninitialised context", a->name);
        check_code(s, kernel, hmac_final(a, kernel, &c, out), NIRAPOD_SHA2_ESTATE,
                   "%s: final on uninitialised context", a->name);
        check(s, kernel, memcmp(&c, &before, a->ctx_len) == 0,
              "%s: uninitialised failures changed the context", a->name);

        memset(&c, 0x5a, sizeof c);
        check_code(s, kernel, hmac_init(a, kernel, &c, key, 20), NIRAPOD_SHA2_OK,
                   "%s: init on garbage", a->name);
        check_code(s, kernel, hmac_final(a, kernel, &c, out), NIRAPOD_SHA2_OK,
                   "%s: final after init on garbage", a->name);
        check_code(s, kernel, hmac_oneshot(a, kernel, ref, key, 20, NULL, 0), NIRAPOD_SHA2_OK,
                   "%s: empty reference", a->name);
        check_bytes(s, kernel, out, ref, digest_len, "%s: init on garbage is the empty tag",
                    a->name);
    }
}

static void misuse_multiway(validation_suite *s, int x4, int kernel)
{
    size_t ways = x4 ? 4 : 8;
    size_t out_len = x4 ? NIRAPOD_SHA2_SHA512_X4_BYTES : NIRAPOD_SHA2_SHA256_X8_BYTES;
    static const size_t lens[] = { 1, 3, 8, 55, 56, 64, 111, 112, 128 };
    uint8_t buf[4096];
    uint8_t snap[4096];
    uint8_t out[256 + 16];
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    size_t i;

    guard_fill(out, sizeof out);
    check_code(s, kernel, multiway_oneshot(x4, kernel, NULL, buf, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL output", name);
    check_code(s, kernel, multiway_oneshot(x4, kernel, out, NULL, 1), NIRAPOD_SHA2_ENULL,
               "%s: NULL input with length 1", name);
    check_code(s, kernel, multiway_oneshot(x4, kernel, out, NULL, 0), NIRAPOD_SHA2_OK,
               "%s: NULL input with length 0", name);
    check_code(s, kernel, multiway_oneshot(x4, kernel, out, buf, (size_t)NIRAPOD_SHA2_MAX_BYTES),
               NIRAPOD_SHA2_ELENGTH, "%s: length 2^61", name);
    check(s, kernel, guard_intact(out + out_len, sizeof out - out_len),
          "%s: multi-way wrote past the output", name);

    fill_pattern(buf, sizeof buf, 107);
    for (i = 0; i < sizeof lens / sizeof lens[0]; i++) {
        size_t len = lens[i];
        size_t in_len = ways * len;
        uint8_t *in = buf + 512;
        long long delta;

        if (in_len > sizeof buf - 512) {
            die("negative: multi-way length %zu does not fit", len);
        }
        for (delta = -(long long)(out_len - 1); delta <= (long long)in_len - 1; delta++) {
            memcpy(snap, buf, sizeof buf);
            if (multiway_oneshot(x4, kernel, in + delta, in, len) != NIRAPOD_SHA2_EOVERLAP) {
                fail_case(s, kernel, "%s: overlap at %lld (length %zu) not rejected", name,
                          delta, len);
            } else {
                count_pass(s, kernel);
            }
            if (memcmp(buf, snap, sizeof buf) != 0) {
                fail_case(s, kernel, "%s: failed overlap at %lld wrote memory", name, delta);
            }
        }
        for (delta = -(long long)out_len; delta <= (long long)in_len;
             delta += (long long)out_len + (long long)in_len) {
            guard_fill(out, sizeof out);
            if (multiway_oneshot(x4, kernel, out, in + delta, len) != NIRAPOD_SHA2_OK) {
                fail_case(s, kernel, "%s: adjacent placement at %lld failed", name, delta);
            } else if (!guard_intact(out + out_len, sizeof out - out_len)) {
                fail_case(s, kernel, "%s: adjacent placement at %lld overran the output", name,
                          delta);
            } else {
                count_pass(s, kernel);
            }
        }
    }
}

/*
 * A context of one function used with every other function. nirapod_sha2.h
 * says this fails with ESTATE and changes nothing; after all the failures
 * the original context must still finish normally.
 */

static int call_init(int kind, int index, int kernel, void *ctx, const uint8_t *key,
                     size_t key_len)
{
    if (kind == 0) {
        return hash_init(&HASH_ALGS[index], kernel, ctx);
    }
    return hmac_init(&HMAC_ALGS[index], kernel, ctx, key, key_len);
}

static int call_update(int kind, int index, int kernel, void *ctx, const uint8_t *in, size_t len)
{
    if (kind == 0) {
        return hash_update(&HASH_ALGS[index], kernel, ctx, in, len);
    }
    return hmac_update(&HMAC_ALGS[index], kernel, ctx, in, len);
}

static int call_final(int kind, int index, int kernel, void *ctx, uint8_t *out)
{
    if (kind == 0) {
        return hash_final(&HASH_ALGS[index], kernel, ctx, out);
    }
    return hmac_final(&HMAC_ALGS[index], kernel, ctx, out);
}

static size_t call_digest_len(int kind, int index)
{
    return kind == 0 ? HASH_ALGS[index].digest_len : HMAC_ALGS[index].digest_len;
}

static void cross_contexts(validation_suite *s, int kernel)
{
    static const uint8_t abc[3] = { 'a', 'b', 'c' };
    uint8_t key[20];
    uint8_t out[64], want[64], other[64 + 16];
    int kinds[8], ids[8], n = 0;
    validation_ctx c, before;
    size_t i, j;

    fill_pattern(key, sizeof key, 113);
    for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
        if (validation_usable(s, kernel, HASH_ALGS[i].family)) {
            kinds[n] = 0;
            ids[n++] = (int)i;
        }
    }
    for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
        if (validation_usable(s, kernel, HMAC_ALGS[i].family)) {
            kinds[n] = 1;
            ids[n++] = (int)i;
        }
    }

    for (i = 0; i < (size_t)n; i++) {
        memset(&c, 0, sizeof c);
        if (call_init(kinds[i], ids[i], kernel, &c, key, sizeof key) != NIRAPOD_SHA2_OK) {
            fail_case(s, kernel, "cross-context: init %zu failed", i);
            continue;
        }
        for (j = 0; j < (size_t)n; j++) {
            if (j == i) {
                continue;
            }
            before = c;
            memset(other, VALIDATION_GUARD, sizeof other);
            check_code(s, kernel, call_update(kinds[j], ids[j], kernel, &c, abc, 3),
                       NIRAPOD_SHA2_ESTATE, "cross-context: update %zu on a context of %zu", j,
                       i);
            check(s, kernel, memcmp(&c, &before, sizeof c) == 0,
                  "cross-context: update %zu changed a context of %zu", j, i);
            check_code(s, kernel, call_final(kinds[j], ids[j], kernel, &c, other),
                       NIRAPOD_SHA2_ESTATE, "cross-context: final %zu on a context of %zu", j,
                       i);
            check(s, kernel, memcmp(&c, &before, sizeof c) == 0,
                  "cross-context: final %zu changed a context of %zu", j, i);
            check(s, kernel, guard_intact(other, sizeof other),
                  "cross-context: final %zu wrote output on a context of %zu", j, i);
        }
        check_code(s, kernel, call_update(kinds[i], ids[i], kernel, &c, abc, 3), NIRAPOD_SHA2_OK,
                   "cross-context: the original context still updates");
        check_code(s, kernel, call_final(kinds[i], ids[i], kernel, &c, out), NIRAPOD_SHA2_OK,
                   "cross-context: the original context still finishes");
        if (kinds[i] == 0) {
            hash_oneshot(&HASH_ALGS[ids[i]], kernel, want, abc, 3);
        } else {
            hmac_oneshot(&HMAC_ALGS[ids[i]], kernel, want, key, sizeof key, abc, 3);
        }
        check_bytes(s, kernel, out, want, call_digest_len(kinds[i], ids[i]),
                    "cross-context: the original context still computes the right answer");
    }
}

int suite_negative(void)
{
    validation_suite s;
    int k;
    size_t i;

    suite_begin(&s, "negative");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
            if (validation_usable(&s, target, HASH_ALGS[i].family)) {
                misuse_hash(&s, &HASH_ALGS[i], target);
            }
        }
        for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
            if (validation_usable(&s, target, HMAC_ALGS[i].family)) {
                misuse_hmac(&s, &HMAC_ALGS[i], target);
            }
        }
        if (validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_X8)) {
            misuse_multiway(&s, 0, target);
        }
        if (validation_usable(&s, target, NIRAPOD_SHA2_TESTING_FAMILY_X4)) {
            misuse_multiway(&s, 1, target);
        }
        cross_contexts(&s, target);
    }
    return suite_end(&s);
}
