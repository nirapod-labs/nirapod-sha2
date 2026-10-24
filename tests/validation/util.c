/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * util.c
 * ======
 *
 * Bookkeeping, the algorithm tables, the kernel probes and the helpers
 * shared by the suites.
 */

#define _POSIX_C_SOURCE 200809L

#include "validation.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Public and testing wrappers. The typed context pointers of the header
 * are erased to void * here so that the suites can drive every function
 * through one table.
 */

#define HASH_WRAPPERS(h)                                                       \
    static int p_##h##_init(void *ctx)                                         \
    {                                                                          \
        return nirapod_sha2_##h##_init(ctx);                                   \
    }                                                                          \
    static int p_##h##_update(void *ctx, const uint8_t *in, size_t len)        \
    {                                                                          \
        return nirapod_sha2_##h##_update(ctx, in, len);                        \
    }                                                                          \
    static int p_##h##_final(void *ctx, uint8_t *out)                          \
    {                                                                          \
        return nirapod_sha2_##h##_final(ctx, out);                             \
    }                                                                          \
    static int t_##h##_init(nirapod_sha2_testing_kernel k, void *ctx)          \
    {                                                                          \
        return nirapod_sha2_testing_##h##_init(k, ctx);                        \
    }                                                                          \
    static int t_##h##_update(nirapod_sha2_testing_kernel k, void *ctx,        \
                              const uint8_t *in, size_t len)                   \
    {                                                                          \
        return nirapod_sha2_testing_##h##_update(k, ctx, in, len);             \
    }                                                                          \
    static int t_##h##_final(nirapod_sha2_testing_kernel k, void *ctx,         \
                             uint8_t *out)                                     \
    {                                                                          \
        return nirapod_sha2_testing_##h##_final(k, ctx, out);                  \
    }

HASH_WRAPPERS(sha224)
HASH_WRAPPERS(sha256)
HASH_WRAPPERS(sha384)
HASH_WRAPPERS(sha512)
HASH_WRAPPERS(sha512_224)
HASH_WRAPPERS(sha512_256)

#define HMAC_WRAPPERS(h)                                                       \
    static int p_hmac_##h##_init(void *ctx, const uint8_t *key, size_t key_len) \
    {                                                                          \
        return nirapod_sha2_hmac_##h##_init(ctx, key, key_len);                \
    }                                                                          \
    static int p_hmac_##h##_update(void *ctx, const uint8_t *in, size_t len)   \
    {                                                                          \
        return nirapod_sha2_hmac_##h##_update(ctx, in, len);                   \
    }                                                                          \
    static int p_hmac_##h##_final(void *ctx, uint8_t *out)                     \
    {                                                                          \
        return nirapod_sha2_hmac_##h##_final(ctx, out);                        \
    }                                                                          \
    static int t_hmac_##h##_init(nirapod_sha2_testing_kernel k, void *ctx,     \
                                 const uint8_t *key, size_t key_len)           \
    {                                                                          \
        return nirapod_sha2_testing_hmac_##h##_init(k, ctx, key, key_len);     \
    }                                                                          \
    static int t_hmac_##h##_update(nirapod_sha2_testing_kernel k, void *ctx,   \
                                   const uint8_t *in, size_t len)              \
    {                                                                          \
        return nirapod_sha2_testing_hmac_##h##_update(k, ctx, in, len);        \
    }                                                                          \
    static int t_hmac_##h##_final(nirapod_sha2_testing_kernel k, void *ctx,    \
                                  uint8_t *out)                                \
    {                                                                          \
        return nirapod_sha2_testing_hmac_##h##_final(k, ctx, out);             \
    }

HMAC_WRAPPERS(sha256)
HMAC_WRAPPERS(sha512)

const hash_alg HASH_ALGS[6] = {
    { "SHA-224", "sha224", 0, NIRAPOD_SHA2_SHA224_BYTES, 64, NIRAPOD_SHA2_TESTING_FAMILY_SHA256,
      nirapod_sha2_sha224, nirapod_sha2_testing_sha224, p_sha224_init, p_sha224_update,
      p_sha224_final, t_sha224_init, t_sha224_update, t_sha224_final,
      NIRAPOD_SHA2_SHA256_CTX_BYTES },
    { "SHA-256", "sha256", 1, NIRAPOD_SHA2_SHA256_BYTES, 64, NIRAPOD_SHA2_TESTING_FAMILY_SHA256,
      nirapod_sha2_sha256, nirapod_sha2_testing_sha256, p_sha256_init, p_sha256_update,
      p_sha256_final, t_sha256_init, t_sha256_update, t_sha256_final,
      NIRAPOD_SHA2_SHA256_CTX_BYTES },
    { "SHA-384", "sha384", 2, NIRAPOD_SHA2_SHA384_BYTES, 128, NIRAPOD_SHA2_TESTING_FAMILY_SHA512,
      nirapod_sha2_sha384, nirapod_sha2_testing_sha384, p_sha384_init, p_sha384_update,
      p_sha384_final, t_sha384_init, t_sha384_update, t_sha384_final,
      NIRAPOD_SHA2_SHA512_CTX_BYTES },
    { "SHA-512", "sha512", 3, NIRAPOD_SHA2_SHA512_BYTES, 128, NIRAPOD_SHA2_TESTING_FAMILY_SHA512,
      nirapod_sha2_sha512, nirapod_sha2_testing_sha512, p_sha512_init, p_sha512_update,
      p_sha512_final, t_sha512_init, t_sha512_update, t_sha512_final,
      NIRAPOD_SHA2_SHA512_CTX_BYTES },
    { "SHA-512/224", "sha512_224", 4, NIRAPOD_SHA2_SHA512_224_BYTES, 128,
      NIRAPOD_SHA2_TESTING_FAMILY_SHA512, nirapod_sha2_sha512_224,
      nirapod_sha2_testing_sha512_224, p_sha512_224_init, p_sha512_224_update,
      p_sha512_224_final, t_sha512_224_init, t_sha512_224_update, t_sha512_224_final,
      NIRAPOD_SHA2_SHA512_CTX_BYTES },
    { "SHA-512/256", "sha512_256", 5, NIRAPOD_SHA2_SHA512_256_BYTES, 128,
      NIRAPOD_SHA2_TESTING_FAMILY_SHA512, nirapod_sha2_sha512_256,
      nirapod_sha2_testing_sha512_256, p_sha512_256_init, p_sha512_256_update,
      p_sha512_256_final, t_sha512_256_init, t_sha512_256_update, t_sha512_256_final,
      NIRAPOD_SHA2_SHA512_CTX_BYTES },
};

const hmac_alg HMAC_ALGS[2] = {
    { "HMAC-SHA-256", "hmac_sha256", 0, NIRAPOD_SHA2_HMAC_SHA256_BYTES, 64,
      NIRAPOD_SHA2_TESTING_FAMILY_SHA256, nirapod_sha2_hmac_sha256,
      nirapod_sha2_testing_hmac_sha256, p_hmac_sha256_init, t_hmac_sha256_init,
      p_hmac_sha256_update, p_hmac_sha256_final, t_hmac_sha256_update, t_hmac_sha256_final,
      NIRAPOD_SHA2_HMAC_SHA256_CTX_BYTES },
    { "HMAC-SHA-512", "hmac_sha512", 1, NIRAPOD_SHA2_HMAC_SHA512_BYTES, 128,
      NIRAPOD_SHA2_TESTING_FAMILY_SHA512, nirapod_sha2_hmac_sha512,
      nirapod_sha2_testing_hmac_sha512, p_hmac_sha512_init, t_hmac_sha512_init,
      p_hmac_sha512_update, p_hmac_sha512_final, t_hmac_sha512_update, t_hmac_sha512_final,
      NIRAPOD_SHA2_HMAC_SHA512_CTX_BYTES },
};

static int skipping[VALIDATION_KERNELS][4];
static int usable[VALIDATION_KERNELS][4];

void suite_begin(validation_suite *s, const char *name)
{
    memset(s, 0, sizeof *s);
    s->name = name;
    memset(skipping, 0, sizeof skipping);
    memset(usable, 0, sizeof usable);
}

static validation_counts *counts_for(validation_suite *s, int kernel)
{
    if (kernel == VALIDATION_PUBLIC) {
        return &s->public_api;
    }
    if (kernel < 0 || kernel >= VALIDATION_KERNELS) {
        die("suite %s: bad kernel %d", s->name, kernel);
    }
    return &s->kernel[kernel];
}

void count_pass(validation_suite *s, int kernel)
{
    counts_for(s, kernel)->pass++;
}

void count_fail(validation_suite *s, int kernel)
{
    counts_for(s, kernel)->fail++;
}

void count_skip(validation_suite *s, int kernel)
{
    counts_for(s, kernel)->skip++;
}

int suite_end(validation_suite *s)
{
    unsigned long total_pass = s->public_api.pass;
    unsigned long total_fail = s->public_api.fail;
    unsigned long total_skip = s->public_api.skip;
    int k;

    for (k = 0; k < VALIDATION_KERNELS; k++) {
        total_pass += s->kernel[k].pass;
        total_fail += s->kernel[k].fail;
        total_skip += s->kernel[k].skip;
    }

    printf("suite %s\n", s->name);
    for (k = 0; k < VALIDATION_KERNELS; k++) {
        const validation_counts *c = &s->kernel[k];

        if (c->pass == 0 && c->fail == 0 && c->skip == 0) {
            continue;
        }
        /* A kernel that ran no check has no result: say why, without a
         * PASS column that would read as one. */
        if (c->pass == 0 && c->fail == 0) {
            printf("  %-22s SKIP (%s)\n", kernel_base_label(k),
                   kernel_built(k) ? "this CPU cannot run it" : "not built");
            continue;
        }
        printf("  %-22s %s PASS %lu FAIL %lu SKIP %lu\n", kernel_label(k),
               c->fail == 0 ? "PASS" : "FAIL", c->pass, c->fail, c->skip);
    }
    if (s->public_api.pass != 0 || s->public_api.fail != 0 || s->public_api.skip != 0) {
        printf("  %-22s %s PASS %lu FAIL %lu SKIP %lu\n", "public API",
               s->public_api.fail == 0 ? "PASS" : "FAIL", s->public_api.pass,
               s->public_api.fail, s->public_api.skip);
    }
    if (s->controls != 0) {
        printf("  %-22s %s %lu run, %lu rejected\n", "negative controls",
               s->missed == 0 ? "PASS" : "FAIL", s->controls, s->controls - s->missed);
    }
    total_fail += s->missed;
    printf("  %-22s %s PASS %lu FAIL %lu SKIP %lu\n", "suite total",
           total_fail == 0 ? "PASS" : "FAIL", total_pass, total_fail, total_skip);
    fflush(stdout);
    return total_fail != 0;
}

void fail_case(validation_suite *s, int kernel, const char *fmt, ...)
{
    va_list ap;

    count_fail(s, kernel);
    if (s->quiet) {
        return;
    }
    fprintf(stderr, "FAIL %s %s: ", s->name, kernel_label(kernel));
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}

void control_begin(validation_suite *scratch, const validation_suite *s)
{
    memset(scratch, 0, sizeof *scratch);
    scratch->name = s->name;
    scratch->quiet = 1;
}

static int control_note(validation_suite *s, int rejected, const char *fmt, va_list ap)
    __attribute__((format(printf, 3, 0)));

static int control_note(validation_suite *s, int rejected, const char *fmt, va_list ap)
{
    s->controls++;
    if (rejected) {
        return 1;
    }
    s->missed++;
    fprintf(stderr, "FAIL %s control: ", s->name);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ": the check did not reject it\n");
    return 0;
}

int control_end(validation_suite *s, const validation_suite *scratch, const char *fmt, ...)
{
    unsigned long failed = scratch->public_api.fail;
    va_list ap;
    int k, rc;

    for (k = 0; k < VALIDATION_KERNELS; k++) {
        failed += scratch->kernel[k].fail;
    }
    va_start(ap, fmt);
    rc = control_note(s, failed != 0, fmt, ap);
    va_end(ap);
    return rc;
}

int control_record(validation_suite *s, int rejected, const char *fmt, ...)
{
    va_list ap;
    int rc;

    va_start(ap, fmt);
    rc = control_note(s, rejected, fmt, ap);
    va_end(ap);
    return rc;
}

static const char *const kernel_names[VALIDATION_KERNELS] = {
    "portable", "aarch64-scalar", "aarch64-sha2", "x86_64-shani", "x86_64-avx2"
};

const char *kernel_base_label(int kernel)
{
    const char *name;

    if (kernel == VALIDATION_PUBLIC) {
        return "public API";
    }
    if (kernel < 0 || kernel >= VALIDATION_KERNELS) {
        return "kernel-?";
    }
    name = nirapod_sha2_testing_kernel_name((nirapod_sha2_testing_kernel)kernel);
    return name != NULL ? name : kernel_names[kernel];
}

const char *kernel_label(int kernel)
{
    static char not_built[VALIDATION_KERNELS][48];
    const char *name;

    if (kernel == VALIDATION_PUBLIC) {
        return "public API";
    }
    if (kernel < 0 || kernel >= VALIDATION_KERNELS) {
        return "kernel-?";
    }
    name = nirapod_sha2_testing_kernel_name((nirapod_sha2_testing_kernel)kernel);
    if (name != NULL) {
        return name;
    }
    snprintf(not_built[kernel], sizeof not_built[kernel], "%s (not built)",
             kernel_names[kernel]);
    return not_built[kernel];
}

int kernel_built(int kernel)
{
    if (kernel < 0 || kernel >= VALIDATION_KERNELS) {
        return 0;
    }
    return nirapod_sha2_testing_kernel_name((nirapod_sha2_testing_kernel)kernel) != NULL;
}

static int probe_unavailable(int kernel, nirapod_sha2_testing_family family)
{
    uint8_t out[256];
    const uint8_t *t[8] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };

    switch (family) {
    case NIRAPOD_SHA2_TESTING_FAMILY_SHA256:
        return nirapod_sha2_testing_sha256((nirapod_sha2_testing_kernel)kernel, out, NULL, 0);
    case NIRAPOD_SHA2_TESTING_FAMILY_SHA512:
        return nirapod_sha2_testing_sha512((nirapod_sha2_testing_kernel)kernel, out, NULL, 0);
    case NIRAPOD_SHA2_TESTING_FAMILY_X8:
        return nirapod_sha2_testing_sha256_x8((nirapod_sha2_testing_kernel)kernel, out, t, 0);
    default:
        return nirapod_sha2_testing_sha512_x4((nirapod_sha2_testing_kernel)kernel, out, t, 0);
    }
}

int validation_usable(validation_suite *s, int kernel, nirapod_sha2_testing_family family)
{
    int f = (int)family;

    if (kernel == VALIDATION_PUBLIC) {
        return 1;
    }
    if (kernel < 0 || kernel >= VALIDATION_KERNELS || f < 0 || f >= 4) {
        die("suite %s: bad kernel or family", s->name);
    }
    if (skipping[kernel][f]) {
        return 0;
    }
    if (usable[kernel][f]) {
        return 1;
    }
    if (!kernel_built(kernel)) {
        skipping[kernel][f] = 1;
        count_skip(s, kernel);
        return 0;
    }
    if (nirapod_sha2_testing_available((nirapod_sha2_testing_kernel)kernel, family)) {
        usable[kernel][f] = 1;
        return 1;
    }
    if (probe_unavailable(kernel, family) != NIRAPOD_SHA2_TESTING_EUNAVAILABLE) {
        fail_case(s, kernel, "unavailable kernel did not return EUNAVAILABLE");
        skipping[kernel][f] = 1;
        return 0;
    }
    skipping[kernel][f] = 1;
    count_skip(s, kernel);
    return 0;
}

int hash_oneshot(const hash_alg *a, int kernel, uint8_t *out, const uint8_t *in, size_t len)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_fn(out, in, len);
    }
    return a->testing_fn((nirapod_sha2_testing_kernel)kernel, out, in, len);
}

int hash_init(const hash_alg *a, int kernel, void *ctx)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_init(ctx);
    }
    return a->testing_init((nirapod_sha2_testing_kernel)kernel, ctx);
}

int hash_update(const hash_alg *a, int kernel, void *ctx, const uint8_t *in, size_t len)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_update(ctx, in, len);
    }
    return a->testing_update((nirapod_sha2_testing_kernel)kernel, ctx, in, len);
}

int hash_final(const hash_alg *a, int kernel, void *ctx, uint8_t *out)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_final(ctx, out);
    }
    return a->testing_final((nirapod_sha2_testing_kernel)kernel, ctx, out);
}

int hmac_oneshot(const hmac_alg *a, int kernel, uint8_t *out, const uint8_t *key, size_t key_len,
                 const uint8_t *msg, size_t msg_len)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_fn(out, key, key_len, msg, msg_len);
    }
    return a->testing_fn((nirapod_sha2_testing_kernel)kernel, out, key, key_len, msg, msg_len);
}

int hmac_init(const hmac_alg *a, int kernel, void *ctx, const uint8_t *key, size_t key_len)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_init(ctx, key, key_len);
    }
    return a->testing_init((nirapod_sha2_testing_kernel)kernel, ctx, key, key_len);
}

int hmac_update(const hmac_alg *a, int kernel, void *ctx, const uint8_t *in, size_t len)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_update(ctx, in, len);
    }
    return a->testing_update((nirapod_sha2_testing_kernel)kernel, ctx, in, len);
}

int hmac_final(const hmac_alg *a, int kernel, void *ctx, uint8_t *out)
{
    if (kernel == VALIDATION_PUBLIC) {
        return a->public_final(ctx, out);
    }
    return a->testing_final((nirapod_sha2_testing_kernel)kernel, ctx, out);
}

int multiway_lanes(int x4, int kernel, uint8_t *out, const uint8_t *const *in, size_t len)
{
    nirapod_sha2_testing_kernel k = (nirapod_sha2_testing_kernel)kernel;

    if (kernel == VALIDATION_PUBLIC) {
        return x4 ? nirapod_sha2_sha512_x4(out, in, len) : nirapod_sha2_sha256_x8(out, in, len);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4(k, out, in, len)
              : nirapod_sha2_testing_sha256_x8(k, out, in, len);
}

int multiway_oneshot(int x4, int kernel, uint8_t *out, const uint8_t *in, size_t len)
{
    const uint8_t *t[8];
    size_t m;

    for (m = 0; m < 8; m++) {
        t[m] = in == NULL ? NULL : in + m * len;
    }
    return multiway_lanes(x4, kernel, out, t, len);
}

int multiway_init(int x4, int kernel, void *ctx)
{
    nirapod_sha2_testing_kernel k = (nirapod_sha2_testing_kernel)kernel;

    if (kernel == VALIDATION_PUBLIC) {
        return x4 ? nirapod_sha2_sha512_x4_init(ctx) : nirapod_sha2_sha256_x8_init(ctx);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4_init(k, ctx)
              : nirapod_sha2_testing_sha256_x8_init(k, ctx);
}

int multiway_init_from(int x4, int kernel, void *ctx, const void *src)
{
    nirapod_sha2_testing_kernel k = (nirapod_sha2_testing_kernel)kernel;

    if (kernel == VALIDATION_PUBLIC) {
        return x4 ? nirapod_sha2_sha512_x4_init_from(ctx, src)
                  : nirapod_sha2_sha256_x8_init_from(ctx, src);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4_init_from(k, ctx, src)
              : nirapod_sha2_testing_sha256_x8_init_from(k, ctx, src);
}

int multiway_update(int x4, int kernel, void *ctx, const uint8_t *const *in, size_t len)
{
    nirapod_sha2_testing_kernel k = (nirapod_sha2_testing_kernel)kernel;

    if (kernel == VALIDATION_PUBLIC) {
        return x4 ? nirapod_sha2_sha512_x4_update(ctx, in, len)
                  : nirapod_sha2_sha256_x8_update(ctx, in, len);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4_update(k, ctx, in, len)
              : nirapod_sha2_testing_sha256_x8_update(k, ctx, in, len);
}

int multiway_final(int x4, int kernel, void *ctx, uint8_t *out)
{
    nirapod_sha2_testing_kernel k = (nirapod_sha2_testing_kernel)kernel;

    if (kernel == VALIDATION_PUBLIC) {
        return x4 ? nirapod_sha2_sha512_x4_final(ctx, out) : nirapod_sha2_sha256_x8_final(ctx, out);
    }
    return x4 ? nirapod_sha2_testing_sha512_x4_final(k, ctx, out)
              : nirapod_sha2_testing_sha256_x8_final(k, ctx, out);
}

void *xmalloc(size_t n)
{
    void *p = malloc(n ? n : 1);

    if (p == NULL) {
        die("out of memory");
    }
    return p;
}

void *xrealloc(void *p, size_t n)
{
    void *q = realloc(p, n ? n : 1);

    if (q == NULL) {
        die("out of memory");
    }
    return q;
}

void die(const char *fmt, ...)
{
    va_list ap;

    fprintf(stderr, "validation: ");
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    exit(2);
}

static int hex_digit(int c)
{
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    return -1;
}

uint8_t *unhex(const char *s, size_t *n)
{
    size_t len = strlen(s), i;
    uint8_t *out;

    if ((len % 2) != 0) {
        die("odd-length hex string");
    }
    out = xmalloc(len / 2);
    for (i = 0; i < len / 2; i++) {
        int hi = hex_digit((unsigned char)s[2 * i]);
        int lo = hex_digit((unsigned char)s[2 * i + 1]);

        if (hi < 0 || lo < 0) {
            die("bad hex digit in %s", s);
        }
        out[i] = (uint8_t)((hi << 4) | lo);
    }
    *n = len / 2;
    return out;
}

char *read_file(const char *path, size_t *len)
{
    FILE *f = fopen(path, "rb");
    char *buf = NULL;
    size_t cap = 0, used = 0;

    if (f == NULL) {
        die("cannot open %s", path);
    }
    for (;;) {
        size_t got;

        if (used + 4096 + 1 > cap) {
            cap = cap ? cap * 2 : 8192;
            buf = xrealloc(buf, cap);
        }
        got = fread(buf + used, 1, cap - used - 1, f);
        used += got;
        if (got == 0) {
            break;
        }
    }
    if (ferror(f)) {
        die("cannot read %s", path);
    }
    fclose(f);
    buf[used] = '\0';
    *len = used;
    return buf;
}

void hex_line(FILE *f, const char *label, const uint8_t *p, size_t n)
{
    size_t i, shown = n < 128 ? n : 128;

    fprintf(f, "  %s (%zu bytes): ", label, n);
    for (i = 0; i < shown; i++) {
        fprintf(f, "%02x", p[i]);
    }
    if (shown != n) {
        fprintf(f, "...");
    }
    fputc('\n', f);
}

void rng_seed(validation_rng *r, uint64_t seed)
{
    r->state = seed;
}

uint64_t rng_next(validation_rng *r)
{
    uint64_t z = (r->state += UINT64_C(0x9e3779b97f4a7c15));

    z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
    z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb);
    return z ^ (z >> 31);
}

size_t rng_below(validation_rng *r, size_t n)
{
    return n ? (size_t)(rng_next(r) % n) : 0;
}

void rng_bytes(validation_rng *r, uint8_t *p, size_t n)
{
    size_t i;

    for (i = 0; i < n; i++) {
        p[i] = (uint8_t)rng_next(r);
    }
}

size_t rng_length(validation_rng *r, size_t block_len, size_t max_blocks)
{
    static const size_t small[] = { 0, 1, 2, 3, 55, 56, 57, 63, 64, 65, 111, 112, 113,
                                    127, 128, 129, 191, 192, 193, 255, 256, 257, 511, 512,
                                    513, 1023, 1024, 1025, 2047, 2048, 2049 };
    size_t limit = max_blocks * block_len + 7;
    size_t v;

    switch (rng_below(r, 5)) {
    case 0:
        v = small[rng_below(r, sizeof small / sizeof small[0])];
        break;
    case 1:
        v = block_len * (1 + rng_below(r, 4)) + rng_below(r, 3);
        break;
    case 2:
        v = rng_below(r, block_len * 2 + 3);
        break;
    case 3:
        v = rng_below(r, block_len * 8 + 9);
        break;
    default:
        v = rng_below(r, limit + 1);
        break;
    }
    return v > limit ? limit : v;
}

void fill_pattern(uint8_t *p, size_t n, unsigned seed)
{
    size_t i;

    for (i = 0; i < n; i++) {
        p[i] = (uint8_t)(seed + i * 131u + (i >> 8) * 17u);
    }
}

int parse_number(const char *s, unsigned long *out)
{
    char *end;
    unsigned long v;

    if (*s == '\0' || *s == '-' || *s == '+') {
        return 0;
    }
    v = strtoul(s, &end, 10);
    if (*end != '\0') {
        return 0;
    }
    *out = v;
    return 1;
}

int parse_header_number(const char *s, unsigned long *out)
{
    const char *eq = strchr(s, '=');

    return eq != NULL && parse_number(eq + 1, out);
}

size_t validation_boundaries(size_t block_len, size_t *out, size_t cap)
{
    size_t cand[128];
    size_t n = 0, i, j, out_n = 0;
    static const size_t small[] = { 0, 1, 2, 3 };

    for (i = 0; i < sizeof small / sizeof small[0] && n < 128; i++) {
        cand[n++] = small[i];
    }
    for (i = 0; i <= 3 && n + 8 < 128; i++) {
        long long base = (long long)i * (long long)block_len;

        for (j = 0; j < 7; j++) {
            long long v = base + (long long)j - 3;

            if (v >= 0) {
                cand[n++] = (size_t)v;
            }
        }
    }
    /* The length field takes 8 bytes (SHA-256) or 16 (SHA-512), so the
     * last message byte that fits in one block is block_len - 9 or
     * block_len - 17; the padding crosses a block at the next byte. */
    for (i = 0; i <= 3 && n + 4 < 128; i++) {
        long long base = (long long)i * (long long)block_len;
        long long edges[2];

        edges[0] = base - 9;
        edges[1] = base - 17;
        for (j = 0; j < 2; j++) {
            long long e;

            for (e = edges[j] - 2; e <= edges[j] + 2; e++) {
                if (e >= 0 && n < 128) {
                    cand[n++] = (size_t)e;
                }
            }
        }
    }

    for (i = 1; i < n; i++) {
        size_t v = cand[i];

        for (j = i; j > 0 && cand[j - 1] > v; j--) {
            cand[j] = cand[j - 1];
        }
        cand[j] = v;
    }
    for (i = 0; i < n && out_n < cap; i++) {
        if (out_n == 0 || cand[i] != out[out_n - 1]) {
            out[out_n++] = cand[i];
        }
    }
    return out_n;
}

void guard_fill(uint8_t *p, size_t n)
{
    memset(p, VALIDATION_GUARD, n);
}

int guard_intact(const uint8_t *p, size_t n)
{
    size_t i;

    for (i = 0; i < n; i++) {
        if (p[i] != VALIDATION_GUARD) {
            return 0;
        }
    }
    return 1;
}

int check_bytes(validation_suite *s, int kernel, const uint8_t *got, const uint8_t *want, size_t n,
                const char *fmt, ...)
{
    va_list ap;
    char what[512];

    va_start(ap, fmt);
    vsnprintf(what, sizeof what, fmt, ap);
    va_end(ap);
    if (memcmp(got, want, n) == 0) {
        count_pass(s, kernel);
        return 1;
    }
    count_fail(s, kernel);
    if (s->quiet) {
        return 0;
    }
    fprintf(stderr, "FAIL %s %s: %s\n", s->name, kernel_label(kernel), what);
    hex_line(stderr, "got ", got, n);
    hex_line(stderr, "want", want, n);
    return 0;
}

int check_code(validation_suite *s, int kernel, int got, int want, const char *fmt, ...)
{
    va_list ap;
    char what[512];

    va_start(ap, fmt);
    vsnprintf(what, sizeof what, fmt, ap);
    va_end(ap);
    if (got == want) {
        count_pass(s, kernel);
        return 1;
    }
    count_fail(s, kernel);
    if (s->quiet) {
        return 0;
    }
    fprintf(stderr, "FAIL %s %s: %s: got %d, want %d\n", s->name, kernel_label(kernel), what, got,
            want);
    return 0;
}

int check(validation_suite *s, int kernel, int ok, const char *fmt, ...)
{
    va_list ap;
    char what[512];

    va_start(ap, fmt);
    vsnprintf(what, sizeof what, fmt, ap);
    va_end(ap);
    if (ok) {
        count_pass(s, kernel);
        return 1;
    }
    count_fail(s, kernel);
    if (s->quiet) {
        return 0;
    }
    fprintf(stderr, "FAIL %s %s: %s\n", s->name, kernel_label(kernel), what);
    return 0;
}
