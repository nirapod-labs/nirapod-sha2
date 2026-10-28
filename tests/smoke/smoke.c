/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * smoke.c
 * =======
 *
 * Smoke tests of the C API: a small set of checks that every function
 * computes its published known answers and that misuse fails as
 * nirapod/sha2.h says. The full validation (CAVP, Wycheproof, differential
 * tests, every split offset) is a separate suite.
 *
 * Built twice (Makefile, "Checks"):
 *
 *     smoke         SMOKE_TESTING defined, linked with
 *                   libnirapod_sha2_testing.a. Every check runs through
 *                   the public functions and then again on each kernel
 *                   this CPU can run, through nirapod_sha2_testing.h; a
 *                   kernel the CPU cannot run is reported as skipped. The
 *                   dispatch rule is checked for feature sets the host
 *                   does not have.
 *     smoke-public  only nirapod/sha2.h, linked with libnirapod_sha2.a:
 *                   the same checks through the public functions alone.
 *
 * What runs on every kernel:
 *
 *     known answers   every hash on "", "abc" and its two-block FIPS 180-4
 *                     example, one-shot and incremental; SHA-256 of one
 *                     million 'a' in uneven updates; HMAC-SHA-256 and
 *                     HMAC-SHA-512 on RFC 4231 cases 1-4, 6, 7, one-shot
 *                     and incremental
 *     splits          the two-block examples absorbed in two updates at
 *                     every split point, and in single bytes
 *     multi-way       sha256_x8 and sha512_x4 against the one-shot hash
 *                     of each message, for lengths around the block and
 *                     padding boundaries, and against the "abc" answers
 *     exact writes    one-shot, final and multi-way outputs write exactly
 *                     their length: guard bytes after them are unchanged
 *
 * Misuse, through the public functions: NULL pointers, the length limit,
 * overlapping buffers, update and final after final, a context of
 * another function, an all-zero context, and the context total limit
 * checked in Jasmin. Each failure must return its code and leave every
 * output and context byte as it was.
 *
 * The context-limit test writes the total field of a context directly. It
 * relies on the layout of src/context.jinc (total is the second
 * 64-bit word), which is not part of the API; nothing else here looks
 * inside a context.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "nirapod/sha2.h"
#include "vectors.h"
#ifdef SMOKE_TESTING
#include "nirapod_sha2_testing.h"
#endif

static unsigned checks;
static unsigned failures;

static void check(int ok, const char *what, const char *kernel)
{
    checks++;
    if (!ok) {
        failures++;
        printf("FAIL %s [%s]\n", what, kernel);
    }
}

static size_t unhex(uint8_t *out, size_t cap, const char *hex)
{
    size_t n = strlen(hex) / 2;
    size_t i;
    unsigned v;

    if (n > cap) {
        fprintf(stderr, "unhex: %zu bytes do not fit in %zu\n", n, cap);
        exit(2);
    }
    for (i = 0; i < n; i++) {
        if (sscanf(hex + 2 * i, "%2x", &v) != 1) {
            fprintf(stderr, "unhex: bad hex\n");
            exit(2);
        }
        out[i] = (uint8_t)v;
    }
    return n;
}

static int equals_hex(const uint8_t *got, size_t len, const char *hex)
{
    uint8_t want[128];

    return unhex(want, sizeof(want), hex) == len && memcmp(got, want, len) == 0;
}

/*
 * The operations under test, on kernel k: k < 0 is the public function,
 * otherwise the testing entry point for kernel k (testing build only).
 */

typedef struct hash_ops {
    size_t bytes;
    size_t ctx_bytes;
    int (*oneshot)(int k, uint8_t *out, const uint8_t *in, size_t len);
    int (*init)(int k, void *ctx);
    int (*update)(int k, void *ctx, const uint8_t *in, size_t len);
    int (*final)(int k, void *ctx, uint8_t *out);
} hash_ops;

#ifdef SMOKE_TESTING
#define PICK(k, pub, test) ((k) < 0 ? (pub) : (test))
#define TK(k) ((nirapod_sha2_testing_kernel)(k))
#define HASH_OPS(h)                                                            \
    static int h##_oneshot(int k, uint8_t *out, const uint8_t *in, size_t len) \
    {                                                                          \
        return PICK(k, nirapod_sha2_##h(out, in, len),                         \
                    nirapod_sha2_testing_##h(TK(k), out, in, len));            \
    }                                                                          \
    static int h##_init(int k, void *ctx)                                      \
    {                                                                          \
        return PICK(k, nirapod_sha2_##h##_init(ctx),                           \
                    nirapod_sha2_testing_##h##_init(TK(k), ctx));              \
    }                                                                          \
    static int h##_update(int k, void *ctx, const uint8_t *in, size_t len)     \
    {                                                                          \
        return PICK(k, nirapod_sha2_##h##_update(ctx, in, len),                \
                    nirapod_sha2_testing_##h##_update(TK(k), ctx, in, len));   \
    }                                                                          \
    static int h##_final(int k, void *ctx, uint8_t *out)                       \
    {                                                                          \
        return PICK(k, nirapod_sha2_##h##_final(ctx, out),                     \
                    nirapod_sha2_testing_##h##_final(TK(k), ctx, out));        \
    }
#else
#define HASH_OPS(h)                                                            \
    static int h##_oneshot(int k, uint8_t *out, const uint8_t *in, size_t len) \
    {                                                                          \
        (void)k;                                                               \
        return nirapod_sha2_##h(out, in, len);                                 \
    }                                                                          \
    static int h##_init(int k, void *ctx)                                      \
    {                                                                          \
        (void)k;                                                               \
        return nirapod_sha2_##h##_init(ctx);                                   \
    }                                                                          \
    static int h##_update(int k, void *ctx, const uint8_t *in, size_t len)     \
    {                                                                          \
        (void)k;                                                               \
        return nirapod_sha2_##h##_update(ctx, in, len);                        \
    }                                                                          \
    static int h##_final(int k, void *ctx, uint8_t *out)                       \
    {                                                                          \
        (void)k;                                                               \
        return nirapod_sha2_##h##_final(ctx, out);                             \
    }
#endif

HASH_OPS(sha224)
HASH_OPS(sha256)
HASH_OPS(sha384)
HASH_OPS(sha512)
HASH_OPS(sha512_224)
HASH_OPS(sha512_256)

static const hash_ops hashes[6] = {
    { 28, NIRAPOD_SHA2_SHA256_CTX_BYTES, sha224_oneshot, sha224_init, sha224_update, sha224_final },
    { 32, NIRAPOD_SHA2_SHA256_CTX_BYTES, sha256_oneshot, sha256_init, sha256_update, sha256_final },
    { 48, NIRAPOD_SHA2_SHA512_CTX_BYTES, sha384_oneshot, sha384_init, sha384_update, sha384_final },
    { 64, NIRAPOD_SHA2_SHA512_CTX_BYTES, sha512_oneshot, sha512_init, sha512_update, sha512_final },
    { 28, NIRAPOD_SHA2_SHA512_CTX_BYTES, sha512_224_oneshot, sha512_224_init, sha512_224_update,
      sha512_224_final },
    { 32, NIRAPOD_SHA2_SHA512_CTX_BYTES, sha512_256_oneshot, sha512_256_init, sha512_256_update,
      sha512_256_final },
};

/* Storage for any context, aligned as the context types are. */
typedef union any_ctx {
    uint64_t words[NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES / 8];
    nirapod_sha2_sha256_ctx sha256;
    nirapod_sha2_sha512_ctx sha512;
    nirapod_sha2_hmac_sha256_ctx hmac256;
    nirapod_sha2_hmac_sha512_ctx hmac512;
} any_ctx;

static int hmac_oneshot(int k, int h512, uint8_t *out, const uint8_t *key, size_t key_len,
                        const uint8_t *msg, size_t msg_len)
{
#ifdef SMOKE_TESTING
    if (k >= 0) {
        return h512 ? nirapod_sha2_testing_hmac_sha512(TK(k), out, key, key_len, msg, msg_len)
                    : nirapod_sha2_testing_hmac_sha256(TK(k), out, key, key_len, msg, msg_len);
    }
#endif
    (void)k;
    return h512 ? nirapod_sha2_hmac_sha512(out, key, key_len, msg, msg_len)
                : nirapod_sha2_hmac_sha256(out, key, key_len, msg, msg_len);
}

static int hmac_init(int k, int h512, any_ctx *c, const uint8_t *key, size_t key_len)
{
#ifdef SMOKE_TESTING
    if (k >= 0) {
        return h512 ? nirapod_sha2_testing_hmac_sha512_init(TK(k), &c->hmac512, key, key_len)
                    : nirapod_sha2_testing_hmac_sha256_init(TK(k), &c->hmac256, key, key_len);
    }
#endif
    (void)k;
    return h512 ? nirapod_sha2_hmac_sha512_init(&c->hmac512, key, key_len)
                : nirapod_sha2_hmac_sha256_init(&c->hmac256, key, key_len);
}

static int hmac_update(int k, int h512, any_ctx *c, const uint8_t *in, size_t len)
{
#ifdef SMOKE_TESTING
    if (k >= 0) {
        return h512 ? nirapod_sha2_testing_hmac_sha512_update(TK(k), &c->hmac512, in, len)
                    : nirapod_sha2_testing_hmac_sha256_update(TK(k), &c->hmac256, in, len);
    }
#endif
    (void)k;
    return h512 ? nirapod_sha2_hmac_sha512_update(&c->hmac512, in, len)
                : nirapod_sha2_hmac_sha256_update(&c->hmac256, in, len);
}

static int hmac_final(int k, int h512, any_ctx *c, uint8_t *out)
{
#ifdef SMOKE_TESTING
    if (k >= 0) {
        return h512 ? nirapod_sha2_testing_hmac_sha512_final(TK(k), &c->hmac512, out)
                    : nirapod_sha2_testing_hmac_sha256_final(TK(k), &c->hmac256, out);
    }
#endif
    (void)k;
    return h512 ? nirapod_sha2_hmac_sha512_final(&c->hmac512, out)
                : nirapod_sha2_hmac_sha256_final(&c->hmac256, out);
}

/* The multi-way one-shot on packed messages: lane m reads in + m len. */
static int multiway(int k, int x4, uint8_t *out, const uint8_t *in, size_t len)
{
    const uint8_t *t[8];
    size_t m;

    for (m = 0; m < 8; m++) {
        t[m] = in == NULL ? NULL : in + m * len;
    }
#ifdef SMOKE_TESTING
    if (k >= 0) {
        return x4 ? nirapod_sha2_testing_sha512_x4(TK(k), out, t, len)
                  : nirapod_sha2_testing_sha256_x8(TK(k), out, t, len);
    }
#endif
    (void)k;
    return x4 ? nirapod_sha2_sha512_x4(out, t, len) : nirapod_sha2_sha256_x8(out, t, len);
}

/*
 * The same digests through a multi-way context: init, then the messages
 * in two updates split at cut, then final.
 */
static int multiway_ctx(int k, int x4, uint8_t *out, const uint8_t *in, size_t len, size_t cut)
{
    nirapod_sha2_sha256_x8_ctx c8;
    nirapod_sha2_sha512_x4_ctx c4;
    const uint8_t *a[8], *b[8];
    size_t m;
    int rc;

    for (m = 0; m < 8; m++) {
        a[m] = in + m * len;
        b[m] = in + m * len + cut;
    }
#ifdef SMOKE_TESTING
    if (k >= 0) {
        if (x4) {
            rc = nirapod_sha2_testing_sha512_x4_init(TK(k), &c4);
            rc = rc ? rc : nirapod_sha2_testing_sha512_x4_update(TK(k), &c4, a, cut);
            rc = rc ? rc : nirapod_sha2_testing_sha512_x4_update(TK(k), &c4, b, len - cut);
            return rc ? rc : nirapod_sha2_testing_sha512_x4_final(TK(k), &c4, out);
        }
        rc = nirapod_sha2_testing_sha256_x8_init(TK(k), &c8);
        rc = rc ? rc : nirapod_sha2_testing_sha256_x8_update(TK(k), &c8, a, cut);
        rc = rc ? rc : nirapod_sha2_testing_sha256_x8_update(TK(k), &c8, b, len - cut);
        return rc ? rc : nirapod_sha2_testing_sha256_x8_final(TK(k), &c8, out);
    }
#endif
    (void)k;
    if (x4) {
        rc = nirapod_sha2_sha512_x4_init(&c4);
        rc = rc ? rc : nirapod_sha2_sha512_x4_update(&c4, a, cut);
        rc = rc ? rc : nirapod_sha2_sha512_x4_update(&c4, b, len - cut);
        return rc ? rc : nirapod_sha2_sha512_x4_final(&c4, out);
    }
    rc = nirapod_sha2_sha256_x8_init(&c8);
    rc = rc ? rc : nirapod_sha2_sha256_x8_update(&c8, a, cut);
    rc = rc ? rc : nirapod_sha2_sha256_x8_update(&c8, b, len - cut);
    return rc ? rc : nirapod_sha2_sha256_x8_final(&c8, out);
}

/*
 * Every lane continuing one single-way context that has absorbed the
 * prefix pre of plen bytes; lane m then gets in + m len.
 */
static int multiway_from(int k, int x4, uint8_t *out, const uint8_t *pre, size_t plen,
                         const uint8_t *in, size_t len)
{
    nirapod_sha2_sha256_x8_ctx c8;
    nirapod_sha2_sha512_x4_ctx c4;
    nirapod_sha2_sha256_ctx s8;
    nirapod_sha2_sha512_ctx s4;
    const uint8_t *a[8];
    size_t m;
    int rc;

    for (m = 0; m < 8; m++) {
        a[m] = in + m * len;
    }
#ifdef SMOKE_TESTING
    if (k >= 0) {
        if (x4) {
            rc = nirapod_sha2_testing_sha512_init(TK(k), &s4);
            rc = rc ? rc : nirapod_sha2_testing_sha512_update(TK(k), &s4, pre, plen);
            rc = rc ? rc : nirapod_sha2_testing_sha512_x4_init_from(TK(k), &c4, &s4);
            rc = rc ? rc : nirapod_sha2_testing_sha512_x4_update(TK(k), &c4, a, len);
            return rc ? rc : nirapod_sha2_testing_sha512_x4_final(TK(k), &c4, out);
        }
        rc = nirapod_sha2_testing_sha256_init(TK(k), &s8);
        rc = rc ? rc : nirapod_sha2_testing_sha256_update(TK(k), &s8, pre, plen);
        rc = rc ? rc : nirapod_sha2_testing_sha256_x8_init_from(TK(k), &c8, &s8);
        rc = rc ? rc : nirapod_sha2_testing_sha256_x8_update(TK(k), &c8, a, len);
        return rc ? rc : nirapod_sha2_testing_sha256_x8_final(TK(k), &c8, out);
    }
#endif
    (void)k;
    if (x4) {
        rc = nirapod_sha2_sha512_init(&s4);
        rc = rc ? rc : nirapod_sha2_sha512_update(&s4, pre, plen);
        rc = rc ? rc : nirapod_sha2_sha512_x4_init_from(&c4, &s4);
        rc = rc ? rc : nirapod_sha2_sha512_x4_update(&c4, a, len);
        return rc ? rc : nirapod_sha2_sha512_x4_final(&c4, out);
    }
    rc = nirapod_sha2_sha256_init(&s8);
    rc = rc ? rc : nirapod_sha2_sha256_update(&s8, pre, plen);
    rc = rc ? rc : nirapod_sha2_sha256_x8_init_from(&c8, &s8);
    rc = rc ? rc : nirapod_sha2_sha256_x8_update(&c8, a, len);
    return rc ? rc : nirapod_sha2_sha256_x8_final(&c8, out);
}

#define GUARD 0xa5

static int guard_intact(const uint8_t *p, size_t len)
{
    size_t i;

    for (i = 0; i < len; i++) {
        if (p[i] != GUARD) {
            return 0;
        }
    }
    return 1;
}

/* Known answers and splits of the six hashes on kernel k. */
static void test_hashes(int k, const char *kn)
{
    uint8_t out[64 + 16];
    any_ctx c;
    size_t i, j, len;
    char what[96];

    for (i = 0; i < 6; i++) {
        const hash_ops *h = &hashes[i];
        const hash_kat *v = &hash_kats[i];
        const uint8_t *two = (const uint8_t *)v->two_block_msg;
        size_t two_len = strlen(v->two_block_msg);

        memset(out, GUARD, sizeof(out));
        snprintf(what, sizeof(what), "%s one-shot empty", v->name);
        check(h->oneshot(k, out, NULL, 0) == NIRAPOD_SHA2_OK && equals_hex(out, h->bytes, v->empty) &&
              guard_intact(out + h->bytes, sizeof(out) - h->bytes), what, kn);

        snprintf(what, sizeof(what), "%s one-shot abc", v->name);
        check(h->oneshot(k, out, (const uint8_t *)msg_abc, 3) == NIRAPOD_SHA2_OK &&
              equals_hex(out, h->bytes, v->abc), what, kn);

        snprintf(what, sizeof(what), "%s one-shot two-block example", v->name);
        check(h->oneshot(k, out, two, two_len) == NIRAPOD_SHA2_OK &&
              equals_hex(out, h->bytes, v->two_block), what, kn);

        memset(out, GUARD, sizeof(out));
        snprintf(what, sizeof(what), "%s incremental empty", v->name);
        check(h->init(k, &c) == NIRAPOD_SHA2_OK && h->final(k, &c, out) == NIRAPOD_SHA2_OK &&
              equals_hex(out, h->bytes, v->empty) &&
              guard_intact(out + h->bytes, sizeof(out) - h->bytes), what, kn);

        /* Two updates, split at every point of the two-block example. */
        for (j = 0; j <= two_len; j++) {
            snprintf(what, sizeof(what), "%s split at %zu", v->name, j);
            check(h->init(k, &c) == NIRAPOD_SHA2_OK &&
                  h->update(k, &c, two, j) == NIRAPOD_SHA2_OK &&
                  h->update(k, &c, two + j, two_len - j) == NIRAPOD_SHA2_OK &&
                  h->final(k, &c, out) == NIRAPOD_SHA2_OK &&
                  equals_hex(out, h->bytes, v->two_block), what, kn);
        }

        /* One byte per update, with an empty update between. */
        snprintf(what, sizeof(what), "%s byte by byte", v->name);
        {
            int ok = h->init(k, &c) == NIRAPOD_SHA2_OK;

            for (len = 0; len < two_len; len++) {
                ok = ok && h->update(k, &c, two + len, 1) == NIRAPOD_SHA2_OK;
                ok = ok && h->update(k, &c, NULL, 0) == NIRAPOD_SHA2_OK;
            }
            ok = ok && h->final(k, &c, out) == NIRAPOD_SHA2_OK && equals_hex(out, h->bytes, v->two_block);
            check(ok, what, kn);
        }
    }

    /* One million 'a' in updates of 997 bytes (a prime, not a block multiple). */
    {
        static uint8_t a[1000000];
        size_t off = 0;
        int ok;

        memset(a, 'a', sizeof(a));
        check(hashes[1].oneshot(k, out, a, sizeof(a)) == NIRAPOD_SHA2_OK &&
              equals_hex(out, 32, sha256_million_a), "SHA-256 one million a, one-shot", kn);

        ok = hashes[1].init(k, &c) == NIRAPOD_SHA2_OK;
        while (off < sizeof(a)) {
            size_t n = sizeof(a) - off < 997 ? sizeof(a) - off : 997;

            ok = ok && hashes[1].update(k, &c, a + off, n) == NIRAPOD_SHA2_OK;
            off += n;
        }
        ok = ok && hashes[1].final(k, &c, out) == NIRAPOD_SHA2_OK && equals_hex(out, 32, sha256_million_a);
        check(ok, "SHA-256 one million a, incremental", kn);
    }
}

/* RFC 4231 on kernel k, one-shot and incremental. */
static void test_hmac(int k, const char *kn)
{
    uint8_t key[256], data[256], out[64 + 16];
    any_ctx c;
    size_t i, key_len, data_len, half, j;
    int h512;
    char what[96];

    for (i = 0; i < 6; i++) {
        const hmac_kat *v = &hmac_kats[i];

        key_len = unhex(key, sizeof(key), v->key);
        data_len = unhex(data, sizeof(data), v->data);
        for (h512 = 0; h512 <= 1; h512++) {
            size_t tag = h512 ? 64 : 32;
            const char *want = h512 ? v->sha512 : v->sha256;
            const char *name = h512 ? "HMAC-SHA-512" : "HMAC-SHA-256";

            memset(out, GUARD, sizeof(out));
            snprintf(what, sizeof(what), "%s RFC 4231 case %d one-shot", name, v->rfc_case);
            check(hmac_oneshot(k, h512, out, key, key_len, data, data_len) == NIRAPOD_SHA2_OK &&
                  equals_hex(out, tag, want) && guard_intact(out + tag, sizeof(out) - tag), what, kn);

            half = data_len / 2;
            memset(out, GUARD, sizeof(out));
            snprintf(what, sizeof(what), "%s RFC 4231 case %d incremental", name, v->rfc_case);
            check(hmac_init(k, h512, &c, key, key_len) == NIRAPOD_SHA2_OK &&
                  hmac_update(k, h512, &c, data, half) == NIRAPOD_SHA2_OK &&
                  hmac_update(k, h512, &c, data + half, data_len - half) == NIRAPOD_SHA2_OK &&
                  hmac_final(k, h512, &c, out) == NIRAPOD_SHA2_OK &&
                  equals_hex(out, tag, want) && guard_intact(out + tag, sizeof(out) - tag), what, kn);

            snprintf(what, sizeof(what), "%s RFC 4231 case %d byte by byte", name, v->rfc_case);
            {
                int ok = hmac_init(k, h512, &c, key, key_len) == NIRAPOD_SHA2_OK;

                for (j = 0; j < data_len; j++) {
                    ok = ok && hmac_update(k, h512, &c, data + j, 1) == NIRAPOD_SHA2_OK;
                }
                ok = ok && hmac_final(k, h512, &c, out) == NIRAPOD_SHA2_OK && equals_hex(out, tag, want);
                check(ok, what, kn);
            }
        }
    }
}

/*
 * Multi-way forms against the one-shot hash of each message (itself
 * checked against known answers above), on lengths at the block and
 * padding boundaries of both block sizes.
 */
static void test_multiway(int k, const char *kn)
{
    static const size_t lens[] = { 0, 1, 3, 55, 56, 63, 64, 65, 111, 112, 127, 128, 129, 300 };
    static uint8_t in[8 * 300];
    uint8_t out[256 + 16], one[64];
    size_t i, m, len;
    int x4, ok;
    char what[96];

    for (i = 0; i < sizeof(in); i++) {
        in[i] = (uint8_t)(i * 131 + 7);
    }

    for (x4 = 0; x4 <= 1; x4++) {
        size_t ways = x4 ? 4 : 8;
        size_t bytes = x4 ? 64 : 32;
        const hash_ops *h = &hashes[x4 ? 3 : 1];

        for (i = 0; i < sizeof(lens) / sizeof(lens[0]); i++) {
            len = lens[i];
            memset(out, GUARD, sizeof(out));
            ok = multiway(k, x4, out, len == 0 ? NULL : in, len) == NIRAPOD_SHA2_OK &&
                 guard_intact(out + 256, 16);
            for (m = 0; m < ways && ok; m++) {
                ok = h->oneshot(-1, one, in + m * len, len) == NIRAPOD_SHA2_OK &&
                     memcmp(out + m * bytes, one, bytes) == 0;
            }
            snprintf(what, sizeof(what), "%s length %zu", x4 ? "sha512_x4" : "sha256_x8", len);
            check(ok, what, kn);

            if (len > 0) {
                uint8_t ref[256], pre_one[64];
                size_t plen = len < 70 ? len : 70;

                memcpy(ref, out, 256);
                ok = multiway_ctx(k, x4, out, in, len, len / 3) == NIRAPOD_SHA2_OK &&
                     memcmp(out, ref, 256) == 0;
                snprintf(what, sizeof(what), "%s context length %zu split at %zu",
                         x4 ? "sha512_x4" : "sha256_x8", len, len / 3);
                check(ok, what, kn);

                /* Lane m's message: the first plen bytes of in, then lane m's own. */
                ok = multiway_from(k, x4, out, in, plen, in, len) == NIRAPOD_SHA2_OK;
                for (m = 0; m < ways && ok; m++) {
                    static uint8_t joined[70 + 300];

                    memcpy(joined, in, plen);
                    memcpy(joined + plen, in + m * len, len);
                    ok = h->oneshot(-1, pre_one, joined, plen + len) == NIRAPOD_SHA2_OK &&
                         memcmp(out + m * bytes, pre_one, bytes) == 0;
                }
                snprintf(what, sizeof(what), "%s from a context of %zu bytes, length %zu",
                         x4 ? "sha512_x4" : "sha256_x8", plen, len);
                check(ok, what, kn);
            }
        }

        /* The "abc" answer in every lane. */
        {
            uint8_t abc8[8 * 3];

            for (m = 0; m < ways; m++) {
                memcpy(abc8 + 3 * m, msg_abc, 3);
            }
            ok = multiway(k, x4, out, abc8, 3) == NIRAPOD_SHA2_OK;
            for (m = 0; m < ways && ok; m++) {
                ok = equals_hex(out + m * bytes, bytes, hash_kats[x4 ? 3 : 1].abc);
            }
            check(ok, x4 ? "sha512_x4 abc in every lane" : "sha256_x8 abc in every lane", kn);
        }
    }
}

/* Misuse through the public functions (nirapod/sha2.h, "Results"). */
static void test_misuse(void)
{
    const char *kn = "public";
    uint8_t buf[512] = { 0 }, out[64], snap[64];
    any_ctx c, before;
    size_t i;

    /* NULL pointers. */
    check(nirapod_sha2_sha256(NULL, buf, 1) == NIRAPOD_SHA2_ENULL, "NULL out", kn);
    memset(out, GUARD, sizeof(out));
    check(nirapod_sha2_sha256(out, NULL, 1) == NIRAPOD_SHA2_ENULL && guard_intact(out, sizeof(out)),
          "NULL in with length 1", kn);
    check(nirapod_sha2_sha256_init(NULL) == NIRAPOD_SHA2_ENULL, "NULL context to init", kn);
    check(nirapod_sha2_sha256_update(NULL, buf, 1) == NIRAPOD_SHA2_ENULL, "NULL context to update", kn);
    check(nirapod_sha2_sha256_final(NULL, out) == NIRAPOD_SHA2_ENULL, "NULL context to final", kn);
    nirapod_sha2_sha256_init(&c.sha256);
    check(nirapod_sha2_sha256_final(&c.sha256, NULL) == NIRAPOD_SHA2_ENULL, "NULL out to final", kn);
    check(nirapod_sha2_hmac_sha256(out, NULL, 1, buf, 1) == NIRAPOD_SHA2_ENULL, "NULL HMAC key", kn);
    check(nirapod_sha2_hmac_sha256(out, NULL, 0, NULL, 0) == NIRAPOD_SHA2_OK &&
          nirapod_sha2_hmac_sha512(out, NULL, 0, NULL, 0) == NIRAPOD_SHA2_OK,
          "HMAC with empty key and message accepted", kn);
    check(nirapod_sha2_sha256_x8(buf, NULL, 1) == NIRAPOD_SHA2_ENULL, "NULL multi-way table", kn);
    {
        const uint8_t *t[8] = { buf, buf, buf, NULL, buf, buf, buf, buf };
        uint8_t o8[256];

        check(nirapod_sha2_sha256_x8(o8, t, 1) == NIRAPOD_SHA2_ENULL, "NULL multi-way lane", kn);
        check(nirapod_sha2_sha256_x8(o8, t, 0) == NIRAPOD_SHA2_OK,
              "NULL multi-way lane accepted at length 0", kn);
    }

    /* Length limit, checked before any byte is read. */
    memset(out, GUARD, sizeof(out));
    check(nirapod_sha2_sha256(out, buf, (size_t)NIRAPOD_SHA2_MAX_BYTES) == NIRAPOD_SHA2_ELENGTH &&
          guard_intact(out, sizeof(out)), "one-shot length 2^61", kn);
    {
        const uint8_t *t[4] = { buf + 256, buf + 256, buf + 256, buf + 256 };

        check(nirapod_sha2_sha512_x4(buf, t, (size_t)NIRAPOD_SHA2_MAX_BYTES) ==
              NIRAPOD_SHA2_ELENGTH, "multi-way length 2^61", kn);
    }
    check(nirapod_sha2_hmac_sha256(out, buf, 1, buf, (size_t)(NIRAPOD_SHA2_MAX_BYTES - 64)) ==
          NIRAPOD_SHA2_ELENGTH, "HMAC-SHA-256 message 2^61 - 64", kn);
    check(nirapod_sha2_hmac_sha512(out, buf, 1, buf, (size_t)(NIRAPOD_SHA2_MAX_BYTES - 128)) ==
          NIRAPOD_SHA2_ELENGTH, "HMAC-SHA-512 message 2^61 - 128", kn);
    nirapod_sha2_sha256_init(&c.sha256);
    before = c;
    check(nirapod_sha2_sha256_update(&c.sha256, buf, (size_t)NIRAPOD_SHA2_MAX_BYTES) ==
          NIRAPOD_SHA2_ELENGTH && memcmp(&c, &before, sizeof(c)) == 0, "update length 2^61", kn);

    /* Overlap. */
    memcpy(buf, "abc", 3);
    memset(buf + 3, GUARD, sizeof(buf) - 3);
    check(nirapod_sha2_sha256(buf + 2, buf, 3) == NIRAPOD_SHA2_EOVERLAP &&
          memcmp(buf, "abc", 3) == 0 && guard_intact(buf + 3, 64), "one-shot out overlaps in", kn);
    check(nirapod_sha2_sha256(buf + 3, buf, 3) == NIRAPOD_SHA2_OK, "adjacent buffers accepted", kn);
    nirapod_sha2_sha256_init(&c.sha256);
    before = c;
    check(nirapod_sha2_sha256_update(&c.sha256, (const uint8_t *)&c + 8, 16) == NIRAPOD_SHA2_EOVERLAP &&
          memcmp(&c, &before, sizeof(c)) == 0, "update input overlaps context", kn);
    check(nirapod_sha2_sha256_final(&c.sha256, (uint8_t *)&c + 100) == NIRAPOD_SHA2_EOVERLAP &&
          memcmp(&c, &before, sizeof(c)) == 0, "final output overlaps context", kn);
    check(nirapod_sha2_hmac_sha256(buf, buf + 16, 16, buf + 100, 4) == NIRAPOD_SHA2_EOVERLAP,
          "HMAC out overlaps key", kn);
    check(nirapod_sha2_hmac_sha256_init(&c.hmac256, (const uint8_t *)&c, 8) == NIRAPOD_SHA2_EOVERLAP,
          "HMAC init key overlaps context", kn);
    {
        const uint8_t *t[8] = { buf + 300, buf + 300, buf + 300, buf + 300,
                                buf + 300, buf + 300, buf + 300, buf + 250 };
        nirapod_sha2_sha256_x8_ctx c8;

        check(nirapod_sha2_sha256_x8(buf, t, 8) == NIRAPOD_SHA2_EOVERLAP,
              "multi-way out overlaps the eighth lane", kn);
        t[7] = buf + 300;
        check(nirapod_sha2_sha256_x8(buf, t, 8) == NIRAPOD_SHA2_OK,
              "multi-way lanes sharing one buffer accepted", kn);
        nirapod_sha2_sha256_x8_init(&c8);
        t[2] = (const uint8_t *)&c8 + 700;
        check(nirapod_sha2_sha256_x8_update(&c8, t, 8) == NIRAPOD_SHA2_EOVERLAP,
              "multi-way update lane overlaps the context", kn);
        check(nirapod_sha2_sha256_x8_final(&c8, (uint8_t *)&c8 + 600) == NIRAPOD_SHA2_EOVERLAP,
              "multi-way final output overlaps the context", kn);
        check(nirapod_sha2_sha256_x8_init_from(&c8, (const nirapod_sha2_sha256_ctx *)&c8) ==
              NIRAPOD_SHA2_EOVERLAP, "multi-way init_from source is the context", kn);
    }

    /* Update and final after final. */
    nirapod_sha2_sha256_init(&c.sha256);
    nirapod_sha2_sha256_update(&c.sha256, buf, 3);
    check(nirapod_sha2_sha256_final(&c.sha256, out) == NIRAPOD_SHA2_OK, "final", kn);
    for (i = 0; i < sizeof(c.sha256.opaque) / 8; i++) {
        check(c.sha256.opaque[i] == 0, "final zeroes the context", kn);
    }
    before = c;
    memcpy(snap, out, sizeof(out));
    check(nirapod_sha2_sha256_update(&c.sha256, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "update after final", kn);
    check(nirapod_sha2_sha256_final(&c.sha256, out) == NIRAPOD_SHA2_ESTATE &&
          memcmp(out, snap, sizeof(out)) == 0, "final after final", kn);

    /* Contexts of another function, and an all-zero context. */
    memset(&c, 0, sizeof(c));
    nirapod_sha2_sha256_init(&c.sha256);
    before = c;
    memset(out, GUARD, sizeof(out));
    check(nirapod_sha2_sha224_update((nirapod_sha2_sha224_ctx *)&c, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "SHA-224 update on a SHA-256 context", kn);
    check(nirapod_sha2_sha224_final((nirapod_sha2_sha224_ctx *)&c, out) == NIRAPOD_SHA2_ESTATE &&
          guard_intact(out, sizeof(out)) && memcmp(&c, &before, sizeof(c)) == 0,
          "SHA-224 final on a SHA-256 context", kn);
    check(nirapod_sha2_sha512_update(&c.sha512, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "SHA-512 update on a SHA-256 context", kn);
    check(nirapod_sha2_hmac_sha256_update(&c.hmac256, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "HMAC-SHA-256 update on a SHA-256 context", kn);
    nirapod_sha2_hmac_sha256_init(&c.hmac256, buf, 20);
    before = c;
    check(nirapod_sha2_sha256_update(&c.sha256, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "SHA-256 update on an HMAC-SHA-256 context", kn);
    check(nirapod_sha2_hmac_sha512_final(&c.hmac512, out) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "HMAC-SHA-512 final on an HMAC-SHA-256 context", kn);
    memset(&c, 0, sizeof(c));
    before = c;
    check(nirapod_sha2_sha256_update(&c.sha256, buf, 3) == NIRAPOD_SHA2_ESTATE &&
          memcmp(&c, &before, sizeof(c)) == 0, "update on an all-zero context", kn);

    /*
     * The total limit checked in Jasmin: a context whose total is set to
     * 2^61 - 10 accepts 9 more bytes and refuses 10, writing nothing.
     */
    nirapod_sha2_sha256_init(&c.sha256);
    c.sha256.opaque[1] = NIRAPOD_SHA2_MAX_BYTES - 10;
    before = c;
    check(nirapod_sha2_sha256_update(&c.sha256, buf, 10) == NIRAPOD_SHA2_ELENGTH &&
          memcmp(&c, &before, sizeof(c)) == 0, "update to total 2^61 refused", kn);
    check(nirapod_sha2_sha256_update(&c.sha256, buf, 9) == NIRAPOD_SHA2_OK &&
          c.sha256.opaque[1] == NIRAPOD_SHA2_MAX_BYTES - 1, "update to total 2^61 - 1 accepted", kn);
    nirapod_sha2_hmac_sha512_init(&c.hmac512, buf, 20);
    c.hmac512.opaque[1] = NIRAPOD_SHA2_MAX_BYTES - 1;
    before = c;
    check(nirapod_sha2_hmac_sha512_update(&c.hmac512, buf, 1) == NIRAPOD_SHA2_ELENGTH &&
          memcmp(&c, &before, sizeof(c)) == 0, "HMAC update to total 2^61 refused", kn);
}

#ifdef SMOKE_TESTING
/*
 * The dispatch rule (capi/dispatch.c) for feature sets other than the
 * host's. Every candidate there is admitted, so the default dispatch
 * (gated) is the target selection (ungated) on every set of the nine
 * feature bits in use; the target follows the table there.
 */
static void test_dispatch(void)
{
    const char *kn = "dispatch";
    unsigned s;
    int f;

    for (f = 0; f < 4; f++) {
        nirapod_sha2_testing_family fam = (nirapod_sha2_testing_family)f;
        int same = 1;

        for (s = 0; s < 0x200u; s++) {
            same &= nirapod_sha2_testing_select_for(fam, s, 1) ==
                    nirapod_sha2_testing_select_for(fam, s, 0);
        }
        check(same, "default dispatch is the target selection", kn);
        check(nirapod_sha2_testing_select_for(fam, 0, 0) ==
              NIRAPOD_SHA2_TESTING_PORTABLE, "no features: portable", kn);
    }
#if defined(__aarch64__)
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA256, 0x30u, 0) ==
          NIRAPOD_SHA2_TESTING_AARCH64_SHA2, "target: SHA-256 family on FEAT_SHA256", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA512, 0x30u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: SHA-512 family without FEAT_SHA512", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA512, 0x50u, 0) ==
          NIRAPOD_SHA2_TESTING_AARCH64_SHA2, "target: SHA-512 family on FEAT_SHA512", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X8, 0x50u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: x8 without FEAT_SHA256", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X4, 0x70u, 0) ==
          NIRAPOD_SHA2_TESTING_AARCH64_SHA2, "target: x4 on FEAT_SHA512", kn);
#elif defined(__x86_64__)
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA256, 0x02u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: SHA-256 family on SHA-NI without AVX2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA256, 0x03u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_SHANI, "target: SHA-256 family on SHA-NI and AVX2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X8, 0x02u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: x8 on SHA-NI without AVX2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA256, 0x101u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_AVX2, "target: SHA-256 family on AVX2 and BMI2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA512, 0x03u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: SHA-512 family without BMI2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_SHA512, 0x103u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_AVX2, "target: SHA-512 family on AVX2 and BMI2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X8, 0x03u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_SHANI, "target: x8 on SHA-NI", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X8, 0x01u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_AVX2, "target: x8 on AVX2 without SHA-NI", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X4, 0x02u, 0) ==
          NIRAPOD_SHA2_TESTING_PORTABLE, "target: x4 without AVX2", kn);
    check(nirapod_sha2_testing_select_for(NIRAPOD_SHA2_TESTING_FAMILY_X4, 0x01u, 0) ==
          NIRAPOD_SHA2_TESTING_X86_64_AVX2, "target: x4 on AVX2", kn);

    /*
     * The single-way AVX2 kernels (and the shani unit's SHA-512 code, which
     * is the AVX2 SHA-512 kernel) need AVX2 and BMI1/BMI2 (0x101), and the
     * shani unit's SHA-256 and 8-way code SHA-NI and AVX2 (0x03), for its
     * 256-bit stack clearing: the testing interface offers each exactly
     * when this CPU reports all it needs.
     */
    {
        unsigned cpu = nirapod_sha2_testing_cpu_features();
        int bmi = (cpu & 0x101u) == 0x101u;

        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_AVX2,
                                             NIRAPOD_SHA2_TESTING_FAMILY_SHA256) == bmi,
              "avx2 SHA-256 needs AVX2 and BMI2", kn);
        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_AVX2,
                                             NIRAPOD_SHA2_TESTING_FAMILY_SHA512) == bmi,
              "avx2 SHA-512 needs AVX2 and BMI2", kn);
        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_SHANI,
                                             NIRAPOD_SHA2_TESTING_FAMILY_SHA512) == bmi,
              "shani SHA-512 needs AVX2 and BMI2", kn);
        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_SHANI,
                                             NIRAPOD_SHA2_TESTING_FAMILY_X4) == bmi,
              "shani x4 needs AVX2 and BMI2", kn);
        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_SHANI,
                                             NIRAPOD_SHA2_TESTING_FAMILY_SHA256) ==
                  ((cpu & 0x03u) == 0x03u),
              "shani SHA-256 needs SHA-NI and AVX2", kn);
        check(nirapod_sha2_testing_available(NIRAPOD_SHA2_TESTING_X86_64_SHANI,
                                             NIRAPOD_SHA2_TESTING_FAMILY_X8) ==
                  ((cpu & 0x03u) == 0x03u),
              "shani x8 needs SHA-NI and AVX2", kn);
    }
#endif
}
#endif

int main(void)
{
#ifdef SMOKE_TESTING
    int k, f, all;
    const char *name;
#endif

    test_hashes(-1, "public");
    test_hmac(-1, "public");
    test_multiway(-1, "public");
    test_misuse();

#ifdef SMOKE_TESTING
    test_dispatch();
    printf("cpu features: 0x%x\n", nirapod_sha2_testing_cpu_features());
    for (k = 0; k < NIRAPOD_SHA2_TESTING_KERNELS; k++) {
        name = nirapod_sha2_testing_kernel_name((nirapod_sha2_testing_kernel)k);
        if (name == NULL) {
            continue;
        }
        all = 1;
        for (f = 0; f < 4; f++) {
            all = all && nirapod_sha2_testing_available((nirapod_sha2_testing_kernel)k,
                                                        (nirapod_sha2_testing_family)f);
        }
        if (!all) {
            /* Not every family runs here: only kernels whose code the CPU can run are tested. */
            printf("kernel %s: SKIPPED (the CPU lacks a feature it needs)\n", name);
            continue;
        }
        test_hashes(k, name);
        test_hmac(k, name);
        test_multiway(k, name);
        printf("kernel %s: tested\n", name);
    }
#endif

    printf("smoke%s: %u checks, %u failures\n",
#ifdef SMOKE_TESTING
           "",
#else
           " (public library)",
#endif
           checks, failures);
    return failures == 0 ? 0 : 1;
}
