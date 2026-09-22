/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * cavp.c
 * ======
 *
 * The NIST CAVP byte-oriented response files: SHA-2 ShortMsg, LongMsg and
 * Monte Carlo for the six functions, and the HMAC-SHA-256 and HMAC-SHA-512
 * sections of HMAC.rsp. Every case runs on every kernel this build has and
 * this CPU can run, and again through the public functions.
 *
 * The SHA files carry Len in bits; the message bytes are Len / 8 long. A
 * Len = 0 record comes with a one-byte Msg field, which is ignored. The
 * [L = n] header gives the digest size in bytes, as the byte-oriented
 * files define it. The HMAC file's Mac field may be truncated to Tlen
 * bytes; the comparison is over those Tlen bytes, the prefix of the
 * computed tag.
 */

#define _POSIX_C_SOURCE 200809L

#include "validation.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct rsp {
    FILE *f;
    char path[4096];
    char *line;
    size_t cap;
};

static void rsp_open(struct rsp *r, const char *dir, const char *name)
{
    memset(r, 0, sizeof *r);
    snprintf(r->path, sizeof r->path, "%s/%s", dir, name);
    r->f = fopen(r->path, "r");
    if (r->f == NULL) {
        die("cannot open %s", r->path);
    }
}

static void rsp_close(struct rsp *r)
{
    fclose(r->f);
    free(r->line);
    memset(r, 0, sizeof *r);
}

static void trim(char *s)
{
    size_t n = strlen(s);

    while (n > 0 && (s[n - 1] == ' ' || s[n - 1] == '\t' || s[n - 1] == '\r')) {
        s[--n] = '\0';
    }
}

/* Next key/value pair, or a "[header]" line as key "[" and the text inside
 * the brackets. Returns 0 at end of file. Comments and blank lines are
 * skipped. The pointers live until the next call. */
static int rsp_next(struct rsp *r, char **key, char **val)
{
    for (;;) {
        ssize_t got = getline(&r->line, &r->cap, r->f);
        char *p, *eq;

        if (got < 0) {
            return 0;
        }
        p = r->line;
        if (*p == '\0') {
            continue;
        }
        p[strcspn(p, "\r\n")] = '\0';
        while (*p == ' ' || *p == '\t') {
            p++;
        }
        if (*p == '\0' || *p == '#') {
            continue;
        }
        if (*p == '[') {
            char *end = strchr(p, ']');

            if (end == NULL) {
                die("%s: malformed header", r->path);
            }
            *end = '\0';
            *key = "[";
            *val = p + 1;
            while (**val == ' ') {
                (*val)++;
            }
            trim(*val);
            return 1;
        }
        eq = strchr(p, '=');
        if (eq == NULL) {
            die("%s: malformed line: %s", r->path, p);
        }
        *eq = '\0';
        trim(p);
        *val = eq + 1;
        while (**val == ' ' || **val == '\t') {
            (*val)++;
        }
        trim(*val);
        *key = p;
        return 1;
    }
}

static unsigned long number_or_die(const char *what, const char *s, const char *path)
{
    unsigned long v;

    if (!parse_number(s, &v)) {
        die("%s: bad %s: %s", path, what, s);
    }
    return v;
}

/* The [L = n] header of a byte-oriented response file gives n in bytes. */
static void check_digest_size(const char *path, unsigned long L, size_t digest_len)
{
    if (L != digest_len) {
        die("%s: L=%lu, expected %zu", path, L, digest_len);
    }
}

static void record_hash(validation_suite *s, int kernel, const hash_alg *alg, const char *file,
                        unsigned long len_bits, int rc, const uint8_t *got, const uint8_t *want)
{
    if (rc != NIRAPOD_SHA2_OK) {
        fail_case(s, kernel, "%s: %s Len=%lu returned %d", alg->name, file, len_bits, rc);
        return;
    }
    check_bytes(s, kernel, got, want, alg->digest_len, "%s: %s Len=%lu", alg->name, file,
                len_bits);
}

static const char *cavp_prefix(const hash_alg *alg)
{
    if (strcmp(alg->name, "SHA-224") == 0) {
        return "SHA224";
    }
    if (strcmp(alg->name, "SHA-256") == 0) {
        return "SHA256";
    }
    if (strcmp(alg->name, "SHA-384") == 0) {
        return "SHA384";
    }
    if (strcmp(alg->name, "SHA-512") == 0) {
        return "SHA512";
    }
    if (strcmp(alg->name, "SHA-512/224") == 0) {
        return "SHA512_224";
    }
    return "SHA512_256";
}

static void cavp_msg(validation_suite *s, int kernel, const hash_alg *alg, const char *dir,
                     const char *kind)
{
    struct rsp r;
    char name[64];
    char *key, *val;
    unsigned long L = 0, len = 0;
    int have_L = 0, have_len = 0, have_msg = 0;
    uint8_t *msg = NULL;
    size_t msglen = 0;
    unsigned long cases = 0;

    snprintf(name, sizeof name, "%s%s.rsp", cavp_prefix(alg), kind);
    rsp_open(&r, dir, name);
    while (rsp_next(&r, &key, &val)) {
        if (strcmp(key, "[") == 0) {
            unsigned long v;

            if (!parse_header_number(val, &v)) {
                die("%s: bad header: %s", r.path, val);
            }
            L = v;
            have_L = 1;
        } else if (strcmp(key, "Len") == 0) {
            len = number_or_die("Len", val, r.path);
            if ((len % 8) != 0) {
                die("%s: Len=%lu is not a byte length", r.path, len);
            }
            have_len = 1;
        } else if (strcmp(key, "Msg") == 0) {
            free(msg);
            msg = unhex(val, &msglen);
            have_msg = 1;
        } else if (strcmp(key, "MD") == 0) {
            uint8_t *want;
            size_t wantlen;
            uint8_t got[64];
            size_t effective;
            int rc;

            if (!have_L) {
                die("%s: MD before [L]", r.path);
            }
            check_digest_size(r.path, L, alg->digest_len);
            if (!have_len) {
                die("%s: MD before Len", r.path);
            }
            want = unhex(val, &wantlen);
            if (wantlen != alg->digest_len) {
                die("%s: MD is %zu bytes, expected %zu", r.path, wantlen, alg->digest_len);
            }
            effective = (size_t)(len / 8);
            if (effective != 0 && (!have_msg || msglen != effective)) {
                die("%s: Len=%lu does not match Msg (%zu bytes)", r.path, len, msglen);
            }
            rc = hash_oneshot(alg, kernel, got, effective != 0 ? msg : NULL, effective);
            record_hash(s, kernel, alg, name, len, rc, got, want);
            free(want);
            cases++;
            have_len = 0;
            have_msg = 0;
            free(msg);
            msg = NULL;
            msglen = 0;
        }
    }
    rsp_close(&r);
    free(msg);
    if (!have_L) {
        die("%s: no [L] header", name);
    }
    if (cases == 0) {
        die("%s/%s: no test cases", dir, name);
    }
}

static void cavp_monte(validation_suite *s, int kernel, const hash_alg *alg, const char *dir)
{
    struct rsp r;
    char name[64];
    char *key, *val;
    unsigned long L = 0, count = 0, expected_count = 0;
    int have_L = 0, have_seed = 0, have_count = 0;
    uint8_t seed[64];
    uint8_t md[3][64], m[3 * 64], out[64];
    unsigned long cases = 0;

    snprintf(name, sizeof name, "%sMonte.rsp", cavp_prefix(alg));
    rsp_open(&r, dir, name);
    while (rsp_next(&r, &key, &val)) {
        if (strcmp(key, "[") == 0) {
            unsigned long v;

            if (!parse_header_number(val, &v)) {
                die("%s: bad header: %s", r.path, val);
            }
            L = v;
            have_L = 1;
        } else if (strcmp(key, "Seed") == 0) {
            uint8_t *seed_bytes;
            size_t n;

            if (!have_L) {
                die("%s: Seed before [L]", r.path);
            }
            check_digest_size(r.path, L, alg->digest_len);
            seed_bytes = unhex(val, &n);
            if (n != alg->digest_len) {
                die("%s: seed is %zu bytes, expected %zu", r.path, n, alg->digest_len);
            }
            memcpy(seed, seed_bytes, n);
            free(seed_bytes);
            have_seed = 1;
        } else if (strcmp(key, "COUNT") == 0) {
            count = number_or_die("COUNT", val, r.path);
            have_count = 1;
        } else if (strcmp(key, "MD") == 0) {
            uint8_t *want;
            size_t wantlen;
            unsigned long i;
            int failed = 0;

            if (!have_seed || !have_count) {
                die("%s: MD without Seed or COUNT", r.path);
            }
            if (count != expected_count) {
                die("%s: COUNT=%lu, expected %lu", r.path, count, expected_count);
            }
            want = unhex(val, &wantlen);
            if (wantlen != alg->digest_len) {
                die("%s: MD is %zu bytes, expected %zu", r.path, wantlen, alg->digest_len);
            }
            memcpy(md[0], seed, alg->digest_len);
            memcpy(md[1], seed, alg->digest_len);
            memcpy(md[2], seed, alg->digest_len);
            for (i = 0; i < 1000; i++) {
                int rc;

                memcpy(m, md[0], alg->digest_len);
                memcpy(m + alg->digest_len, md[1], alg->digest_len);
                memcpy(m + 2 * alg->digest_len, md[2], alg->digest_len);
                rc = hash_oneshot(alg, kernel, out, m, 3 * alg->digest_len);
                if (rc != NIRAPOD_SHA2_OK) {
                    fail_case(s, kernel, "%s: %s COUNT=%lu iteration %lu returned %d", alg->name,
                              name, count, i, rc);
                    failed = 1;
                    break;
                }
                memcpy(md[0], md[1], alg->digest_len);
                memcpy(md[1], md[2], alg->digest_len);
                memcpy(md[2], out, alg->digest_len);
            }
            if (!failed) {
                memcpy(seed, md[2], alg->digest_len);
                check_bytes(s, kernel, seed, want, alg->digest_len, "%s: %s COUNT=%lu",
                            alg->name, name, count);
            }
            free(want);
            expected_count++;
            have_count = 0;
            cases++;
        }
    }
    rsp_close(&r);
    if (cases != 100) {
        die("%s/%s: %lu Monte Carlo checkpoints, expected 100", dir, name, cases);
    }
}

static void cavp_hmac(validation_suite *s, int kernel, const hmac_alg *alg, const char *dir)
{
    struct rsp r;
    char *key, *val;
    unsigned long L = 0, count = 0, klen = 0, tlen = 0;
    int have_L = 0, have_count = 0, have_klen = 0, have_tlen = 0, have_msg = 0;
    uint8_t *keybuf = NULL, *msgbuf = NULL;
    size_t keylen = 0, msglen = 0;
    unsigned long cases = 0, skipped = 0;

    rsp_open(&r, dir, "HMAC.rsp");
    while (rsp_next(&r, &key, &val)) {
        if (strcmp(key, "[") == 0) {
            unsigned long v;

            if (!parse_header_number(val, &v)) {
                die("%s: bad header: %s", r.path, val);
            }
            L = v;
            have_L = 1;
        } else if (strcmp(key, "Count") == 0) {
            count = number_or_die("Count", val, r.path);
            have_count = 1;
        } else if (strcmp(key, "Klen") == 0) {
            klen = number_or_die("Klen", val, r.path);
            have_klen = 1;
        } else if (strcmp(key, "Tlen") == 0) {
            tlen = number_or_die("Tlen", val, r.path);
            have_tlen = 1;
        } else if (strcmp(key, "Key") == 0) {
            free(keybuf);
            keybuf = unhex(val, &keylen);
        } else if (strcmp(key, "Msg") == 0) {
            free(msgbuf);
            msgbuf = unhex(val, &msglen);
            have_msg = 1;
        } else if (strcmp(key, "Mac") == 0) {
            uint8_t *want;
            size_t wantlen;
            uint8_t got[64];
            int rc;

            if (!have_L || !have_count || !have_klen || !have_tlen || !have_msg) {
                die("%s: Mac before its header fields", r.path);
            }
            if (keylen != klen) {
                die("%s: Klen=%lu, Key is %zu bytes", r.path, klen, keylen);
            }
            want = unhex(val, &wantlen);
            if (wantlen != tlen) {
                die("%s: Tlen=%lu, Mac is %zu bytes", r.path, tlen, wantlen);
            }
            if (tlen > L) {
                die("%s: Tlen=%lu exceeds L=%lu", r.path, tlen, L);
            }
            if (L == alg->digest_len) {
                rc = hmac_oneshot(alg, kernel, got, keybuf, keylen, msgbuf, msglen);
                if (rc != NIRAPOD_SHA2_OK) {
                    fail_case(s, kernel, "%s: HMAC.rsp L=%lu Count=%lu returned %d", alg->name,
                              L, count, rc);
                } else {
                    check_bytes(s, kernel, got, want, wantlen,
                                "%s: HMAC.rsp L=%lu Count=%lu", alg->name, L, count);
                }
                cases++;
            } else {
                skipped++;
            }
            free(want);
            have_count = 0;
            have_klen = 0;
            have_tlen = 0;
            have_msg = 0;
        }
    }
    rsp_close(&r);
    free(keybuf);
    free(msgbuf);
    if (cases == 0) {
        die("%s/HMAC.rsp: no HMAC cases for %s", dir, alg->name);
    }
    if (skipped != 0 && kernel == 0) {
        printf("  %s: HMAC.rsp %lu cases run, %lu records of other hashes not applicable\n",
               alg->name, cases, skipped);
    }
}

int suite_cavp(void)
{
    validation_suite s;
    char dir[2048];
    int k;
    size_t i;

    snprintf(dir, sizeof dir, "%s/cavp", validation.vectors);
    suite_begin(&s, "cavp");
    for (k = 0; k <= VALIDATION_KERNELS; k++) {
        int target = k == VALIDATION_KERNELS ? VALIDATION_PUBLIC : k;

        for (i = 0; i < sizeof HASH_ALGS / sizeof HASH_ALGS[0]; i++) {
            const hash_alg *a = &HASH_ALGS[i];

            if (!validation_usable(&s, target, a->family)) {
                continue;
            }
            cavp_msg(&s, target, a, dir, "ShortMsg");
            cavp_msg(&s, target, a, dir, "LongMsg");
            cavp_monte(&s, target, a, dir);
        }
        for (i = 0; i < sizeof HMAC_ALGS / sizeof HMAC_ALGS[0]; i++) {
            const hmac_alg *a = &HMAC_ALGS[i];

            if (!validation_usable(&s, target, a->family)) {
                continue;
            }
            cavp_hmac(&s, target, a, dir);
        }
    }
    return suite_end(&s);
}
