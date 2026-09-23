/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * xarch.c
 * =======
 *
 * Equality across architectures. A fixed set of cases, the same on every
 * host and independent of --iterations, runs on every kernel this build
 * has and through the public functions: every hash one-shot and in three
 * updates, every HMAC over a grid of key and message lengths, and the two
 * multi-way forms one-shot and in two updates. Within the build all
 * results must agree, as in the cross suite. The agreed outputs of each
 * function are concatenated in case order and hashed with SHA-256, and
 * that value must equal the one recorded for the function in
 * VECTORS/xarch/manifest.txt. The manifest is one file for every
 * architecture, so two hosts that pass computed byte-identical outputs
 * for every case.
 *
 * `validation --write-xarch FILE` writes the values of this build to FILE
 * instead of checking them; the manifest is written that way once and
 * then only checked.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "validation.h"

/* Messages up to two blocks and a half of SHA-512, then a few long ones. */
#define XARCH_SHORT 320
static const size_t long_lengths[] = { 1000, 4095, 4096, 4097, 65539 };
static const size_t hmac_keys[] = { 0, 1, 31, 32, 63, 64, 65, 127, 128, 129, 300 };
static const size_t hmac_msgs[] = { 0, 1, 55, 56, 63, 64, 65, 111, 112, 127, 128, 129, 1000 };

typedef struct xarch_out {
    const char *name;
    size_t cases;
    uint8_t *bytes;
    size_t len, cap;
} xarch_out;

static void out_add(xarch_out *o, const uint8_t *p, size_t n)
{
    if (o->len + n > o->cap) {
        o->cap = (o->len + n) * 2;
        o->bytes = xrealloc(o->bytes, o->cap);
    }
    memcpy(o->bytes + o->len, p, n);
    o->len += n;
    o->cases++;
}

static size_t usable(validation_suite *s, nirapod_sha2_testing_family family, int *kernels)
{
    size_t n = 0;
    int k;

    for (k = 0; k < VALIDATION_KERNELS; k++) {
        if (validation_usable(s, k, family)) {
            kernels[n++] = k;
        }
    }
    kernels[n++] = VALIDATION_PUBLIC;
    return n;
}

/* The message of a case: seeded by the function and the length. */
static void message(uint8_t *p, size_t len, uint64_t seed)
{
    validation_rng r;

    rng_seed(&r, seed);
    rng_bytes(&r, p, len);
}

static size_t hash_lengths(size_t *out)
{
    size_t n = 0, i;

    for (i = 0; i <= XARCH_SHORT; i++) {
        out[n++] = i;
    }
    for (i = 0; i < sizeof long_lengths / sizeof long_lengths[0]; i++) {
        out[n++] = long_lengths[i];
    }
    return n;
}

static void xarch_hash(validation_suite *s, const hash_alg *a, xarch_out *o, uint8_t *msg)
{
    int kernels[VALIDATION_KERNELS + 1];
    size_t nk = usable(s, a->family, kernels);
    size_t lengths[XARCH_SHORT + 16], nl = hash_lengths(lengths), i, t;
    uint8_t ref[64], one[64], inc[64];
    validation_ctx c;

    for (i = 0; i < nl; i++) {
        size_t len = lengths[i], cut1 = len / 3, cut2 = 2 * len / 3;
        const uint8_t *in = len == 0 ? NULL : msg;

        message(msg, len, UINT64_C(0x78617263) + 1000 * (uint64_t)(a - HASH_ALGS) + len);
        for (t = 0; t < nk; t++) {
            int k = kernels[t];

            if (hash_oneshot(a, k, one, in, len) != NIRAPOD_SHA2_OK ||
                hash_init(a, k, &c) != NIRAPOD_SHA2_OK ||
                hash_update(a, k, &c, in, cut1) != NIRAPOD_SHA2_OK ||
                hash_update(a, k, &c, len == 0 ? NULL : msg + cut1, cut2 - cut1) !=
                    NIRAPOD_SHA2_OK ||
                hash_update(a, k, &c, len == 0 ? NULL : msg + cut2, len - cut2) !=
                    NIRAPOD_SHA2_OK ||
                hash_final(a, k, &c, inc) != NIRAPOD_SHA2_OK) {
                fail_case(s, k, "%s: length %zu returned an error", a->name, len);
                continue;
            }
            if (t == 0) {
                memcpy(ref, one, a->digest_len);
            }
            check_bytes(s, k, one, ref, a->digest_len, "%s: length %zu one-shot", a->name, len);
            check_bytes(s, k, inc, ref, a->digest_len, "%s: length %zu incremental", a->name,
                        len);
        }
        out_add(o, ref, a->digest_len);
    }
}

static void xarch_hmac(validation_suite *s, const hmac_alg *a, xarch_out *o, uint8_t *msg,
                       uint8_t *key)
{
    int kernels[VALIDATION_KERNELS + 1];
    size_t nk = usable(s, a->family, kernels);
    size_t ki, mi, t;
    uint8_t ref[64], one[64], inc[64];
    validation_ctx c;

    for (ki = 0; ki < sizeof hmac_keys / sizeof hmac_keys[0]; ki++) {
        for (mi = 0; mi < sizeof hmac_msgs / sizeof hmac_msgs[0]; mi++) {
            size_t kl = hmac_keys[ki], len = hmac_msgs[mi], cut = len / 2;
            const uint8_t *in = len == 0 ? NULL : msg, *kp = kl == 0 ? NULL : key;
            uint64_t seed = UINT64_C(0x686d6163) + 100000 * (uint64_t)(a - HMAC_ALGS) +
                            1000 * (uint64_t)kl + len;

            message(key, kl, seed);
            message(msg, len, seed + 7);
            for (t = 0; t < nk; t++) {
                int k = kernels[t];

                if (hmac_oneshot(a, k, one, kp, kl, in, len) != NIRAPOD_SHA2_OK ||
                    hmac_init(a, k, &c, kp, kl) != NIRAPOD_SHA2_OK ||
                    hmac_update(a, k, &c, in, cut) != NIRAPOD_SHA2_OK ||
                    hmac_update(a, k, &c, len == 0 ? NULL : msg + cut, len - cut) !=
                        NIRAPOD_SHA2_OK ||
                    hmac_final(a, k, &c, inc) != NIRAPOD_SHA2_OK) {
                    fail_case(s, k, "%s: key %zu, length %zu returned an error", a->name, kl,
                              len);
                    continue;
                }
                if (t == 0) {
                    memcpy(ref, one, a->digest_len);
                }
                check_bytes(s, k, one, ref, a->digest_len, "%s: key %zu, length %zu one-shot",
                            a->name, kl, len);
                check_bytes(s, k, inc, ref, a->digest_len,
                            "%s: key %zu, length %zu incremental", a->name, kl, len);
            }
            out_add(o, ref, a->digest_len);
        }
    }
}

static void xarch_multiway(validation_suite *s, int x4, xarch_out *o, uint8_t *buf)
{
    size_t ways = x4 ? 4 : 8;
    size_t out_len = x4 ? NIRAPOD_SHA2_SHA512_X4_BYTES : NIRAPOD_SHA2_SHA256_X8_BYTES;
    const char *name = x4 ? "sha512_x4" : "sha256_x8";
    int kernels[VALIDATION_KERNELS + 1];
    size_t nk = usable(s, x4 ? NIRAPOD_SHA2_TESTING_FAMILY_X4 : NIRAPOD_SHA2_TESTING_FAMILY_X8,
                       kernels);
    size_t lengths[XARCH_SHORT + 16], nl = hash_lengths(lengths), i, t, m;
    uint8_t ref[256], one[256], inc[256];
    validation_ctx c;

    for (i = 0; i < nl; i++) {
        size_t len = lengths[i], cut = len / 2;
        const uint8_t *lane[8], *rest[8];

        message(buf, len * ways, UINT64_C(0x6d776179) + 1000 * (uint64_t)x4 + len);
        for (m = 0; m < ways; m++) {
            lane[m] = len == 0 ? NULL : buf + m * len;
            rest[m] = len == 0 ? NULL : buf + m * len + cut;
        }
        for (t = 0; t < nk; t++) {
            int k = kernels[t];

            if (multiway_lanes(x4, k, one, lane, len) != NIRAPOD_SHA2_OK ||
                multiway_init(x4, k, &c) != NIRAPOD_SHA2_OK ||
                multiway_update(x4, k, &c, lane, cut) != NIRAPOD_SHA2_OK ||
                multiway_update(x4, k, &c, rest, len - cut) != NIRAPOD_SHA2_OK ||
                multiway_final(x4, k, &c, inc) != NIRAPOD_SHA2_OK) {
                fail_case(s, k, "%s: length %zu returned an error", name, len);
                continue;
            }
            if (t == 0) {
                memcpy(ref, one, out_len);
            }
            check_bytes(s, k, one, ref, out_len, "%s: length %zu one-shot", name, len);
            check_bytes(s, k, inc, ref, out_len, "%s: length %zu incremental", name, len);
        }
        out_add(o, ref, out_len);
    }
}

static void hex(char *dst, const uint8_t *p, size_t n)
{
    static const char digits[] = "0123456789abcdef";
    size_t i;

    for (i = 0; i < n; i++) {
        dst[2 * i] = digits[p[i] >> 4];
        dst[2 * i + 1] = digits[p[i] & 15];
    }
    dst[2 * n] = '\0';
}

/* The recorded line for name, or NULL. */
static const char *manifest_value(const char *manifest, const char *name, size_t *cases)
{
    const char *p = manifest;
    size_t nlen = strlen(name);

    while (p && *p) {
        if (strncmp(p, name, nlen) == 0 && p[nlen] == ' ') {
            unsigned long c;
            const char *q = p + nlen + 1;

            c = strtoul(q, (char **)&q, 10);
            *cases = (size_t)c;
            while (*q == ' ') {
                q++;
            }
            return q;
        }
        p = strchr(p, '\n');
        if (p) {
            p++;
        }
    }
    return NULL;
}

int suite_xarch(void)
{
    validation_suite s;
    xarch_out outs[10];
    size_t no = 0, i;
    uint8_t *msg = xmalloc(65539 * 8);
    uint8_t *key = xmalloc(512);
    char path[1024];
    char *manifest = NULL;
    size_t mlen;
    FILE *w = NULL;

    suite_begin(&s, "xarch");
    memset(outs, 0, sizeof outs);
    for (i = 0; i < 6; i++) {
        outs[no].name = HASH_ALGS[i].name;
        xarch_hash(&s, &HASH_ALGS[i], &outs[no++], msg);
    }
    for (i = 0; i < 2; i++) {
        outs[no].name = HMAC_ALGS[i].name;
        xarch_hmac(&s, &HMAC_ALGS[i], &outs[no++], msg, key);
    }
    outs[no].name = "sha256_x8";
    xarch_multiway(&s, 0, &outs[no++], msg);
    outs[no].name = "sha512_x4";
    xarch_multiway(&s, 1, &outs[no++], msg);

    if (validation.write_xarch) {
        w = fopen(validation.write_xarch, "w");
        if (!w) {
            die("xarch: cannot write %s", validation.write_xarch);
        }
    } else {
        snprintf(path, sizeof path, "%s/xarch/manifest.txt", validation.vectors);
        manifest = read_file(path, &mlen);
    }
    for (i = 0; i < no; i++) {
        uint8_t d[32];
        char got[65];

        if (nirapod_sha2_sha256(d, outs[i].bytes, outs[i].len) != NIRAPOD_SHA2_OK) {
            die("xarch: hashing the outputs of %s failed", outs[i].name);
        }
        hex(got, d, 32);
        if (w) {
            fprintf(w, "%s %zu %s\n", outs[i].name, outs[i].cases, got);
        } else {
            size_t cases = 0;
            const char *want = manifest_value(manifest, outs[i].name, &cases);
            int ok = want && cases == outs[i].cases && strncmp(want, got, 64) == 0;

            check(&s, VALIDATION_PUBLIC, ok, "%s: %zu cases, outputs hash to %s, manifest %.64s",
                  outs[i].name, outs[i].cases, got, want ? want : "(missing)");
        }
        free(outs[i].bytes);
    }
    if (w) {
        fclose(w);
        printf("xarch: wrote %s\n", validation.write_xarch);
    }
    free(manifest);
    free(msg);
    free(key);
    return suite_end(&s);
}
