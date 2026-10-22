/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * validation.h
 * ============
 *
 * Shared declarations of the validation suite. The suite runs the public
 * functions of nirapod_sha2.h and every kernel of this build through
 * nirapod_sha2_testing.h, and reports PASS, FAIL and SKIP per suite and
 * per kernel.
 *
 * A kernel is named by its nirapod_sha2_testing_kernel value, 0 to
 * NIRAPOD_SHA2_TESTING_KERNELS - 1. VALIDATION_PUBLIC (-1) stands for the
 * public functions, which choose their kernel through dispatch.c.
 */

#ifndef NIRAPOD_SHA2_VALIDATION_H
#define NIRAPOD_SHA2_VALIDATION_H

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "nirapod_sha2.h"
#include "nirapod_sha2_testing.h"

#define VALIDATION_KERNELS NIRAPOD_SHA2_TESTING_KERNELS
#define VALIDATION_PUBLIC (-1)
#define VALIDATION_MAX_ORACLES 4
#define VALIDATION_MAX_DIGEST 64
#define VALIDATION_GUARD 0xa5
#define VALIDATION_FUZZ_SEED UINT64_C(0x5eed5a2e1f0d3c47)

typedef struct validation_counts {
    unsigned long pass;
    unsigned long fail;
    unsigned long skip;
} validation_counts;

typedef struct validation_suite {
    const char *name;
    validation_counts kernel[VALIDATION_KERNELS];
    validation_counts public_api;
} validation_suite;

typedef union validation_ctx {
    nirapod_sha2_sha224_ctx sha224;
    nirapod_sha2_sha256_ctx sha256;
    nirapod_sha2_sha384_ctx sha384;
    nirapod_sha2_sha512_ctx sha512;
    nirapod_sha2_sha512_224_ctx sha512_224;
    nirapod_sha2_sha512_256_ctx sha512_256;
    nirapod_sha2_hmac_sha256_ctx hmac_sha256;
    nirapod_sha2_hmac_sha512_ctx hmac_sha512;
    nirapod_sha2_sha256_x8_ctx sha256_x8;
    nirapod_sha2_sha512_x4_ctx sha512_x4;
    uint64_t words[NIRAPOD_SHA2_SHA256_X8_CTX_BYTES / 8];
    unsigned char raw[NIRAPOD_SHA2_SHA256_X8_CTX_BYTES];
} validation_ctx;

typedef int (*hash_public_fn)(uint8_t *, const uint8_t *, size_t);
typedef int (*hash_testing_fn)(nirapod_sha2_testing_kernel, uint8_t *, const uint8_t *, size_t);
typedef int (*init_public_fn)(void *);
typedef int (*update_public_fn)(void *, const uint8_t *, size_t);
typedef int (*final_public_fn)(void *, uint8_t *);
typedef int (*init_testing_fn)(nirapod_sha2_testing_kernel, void *);
typedef int (*update_testing_fn)(nirapod_sha2_testing_kernel, void *, const uint8_t *, size_t);
typedef int (*final_testing_fn)(nirapod_sha2_testing_kernel, void *, uint8_t *);

typedef struct hash_alg {
    const char *name;
    const char *oracle_name;
    int oracle_id;
    size_t digest_len;
    size_t block_len;
    nirapod_sha2_testing_family family;
    hash_public_fn public_fn;
    hash_testing_fn testing_fn;
    init_public_fn public_init;
    update_public_fn public_update;
    final_public_fn public_final;
    init_testing_fn testing_init;
    update_testing_fn testing_update;
    final_testing_fn testing_final;
    size_t ctx_len;
} hash_alg;

typedef int (*hmac_public_fn)(uint8_t *, const uint8_t *, size_t, const uint8_t *, size_t);
typedef int (*hmac_testing_fn)(nirapod_sha2_testing_kernel, uint8_t *, const uint8_t *, size_t,
                               const uint8_t *, size_t);
typedef int (*hmac_init_public_fn)(void *, const uint8_t *, size_t);
typedef int (*hmac_init_testing_fn)(nirapod_sha2_testing_kernel, void *, const uint8_t *, size_t);

typedef struct hmac_alg {
    const char *name;
    const char *oracle_name;
    int oracle_id;
    size_t digest_len;
    size_t block_len;
    nirapod_sha2_testing_family family;
    hmac_public_fn public_fn;
    hmac_testing_fn testing_fn;
    hmac_init_public_fn public_init;
    hmac_init_testing_fn testing_init;
    update_public_fn public_update;
    final_public_fn public_final;
    update_testing_fn testing_update;
    final_testing_fn testing_final;
    size_t ctx_len;
} hmac_alg;

extern const hash_alg HASH_ALGS[6];
extern const hmac_alg HMAC_ALGS[2];

typedef struct validation_rng {
    uint64_t state;
} validation_rng;

typedef struct validation_env {
    const char *vectors;
    size_t iterations;
    size_t large_bytes;
    int require_oracle;
    const char *write_xarch;
    uint64_t seed;
    size_t fuzz_cases;
    int oracle_count;
    const char *oracle[VALIDATION_MAX_ORACLES];
} validation_env;

extern validation_env validation;

/* Bookkeeping. */
void suite_begin(validation_suite *s, const char *name);
int suite_end(validation_suite *s);
void count_pass(validation_suite *s, int kernel);
void count_fail(validation_suite *s, int kernel);
void count_skip(validation_suite *s, int kernel);
void fail_case(validation_suite *s, int kernel, const char *fmt, ...)
    __attribute__((format(printf, 3, 4)));
const char *kernel_label(int kernel);
const char *kernel_base_label(int kernel);
int kernel_built(int kernel);
int validation_usable(validation_suite *s, int kernel, nirapod_sha2_testing_family family);

/* Operations on an explicit target: kernel >= 0 forces that kernel through
 * the testing interface, VALIDATION_PUBLIC uses the public functions. */
int hash_oneshot(const hash_alg *a, int kernel, uint8_t *out, const uint8_t *in, size_t len);
int hash_init(const hash_alg *a, int kernel, void *ctx);
int hash_update(const hash_alg *a, int kernel, void *ctx, const uint8_t *in, size_t len);
int hash_final(const hash_alg *a, int kernel, void *ctx, uint8_t *out);

int hmac_oneshot(const hmac_alg *a, int kernel, uint8_t *out, const uint8_t *key, size_t key_len,
                 const uint8_t *msg, size_t msg_len);
int hmac_init(const hmac_alg *a, int kernel, void *ctx, const uint8_t *key, size_t key_len);
int hmac_update(const hmac_alg *a, int kernel, void *ctx, const uint8_t *in, size_t len);
int hmac_final(const hmac_alg *a, int kernel, void *ctx, uint8_t *out);

/*
 * Multi-way forms. multiway_oneshot takes packed messages, lane m at
 * in + m len (in may be NULL), and builds the lane table; the others take
 * a table. x4 selects sha512_x4, else sha256_x8.
 */
int multiway_oneshot(int x4, int kernel, uint8_t *out, const uint8_t *in, size_t len);
int multiway_lanes(int x4, int kernel, uint8_t *out, const uint8_t *const *in, size_t len);
int multiway_init(int x4, int kernel, void *ctx);
int multiway_init_from(int x4, int kernel, void *ctx, const void *src);
int multiway_update(int x4, int kernel, void *ctx, const uint8_t *const *in, size_t len);
int multiway_final(int x4, int kernel, void *ctx, uint8_t *out);

/* Memory and files. */
void *xmalloc(size_t n);
void *xrealloc(void *p, size_t n);
void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
uint8_t *unhex(const char *s, size_t *n);
char *read_file(const char *path, size_t *len);
void hex_line(FILE *f, const char *label, const uint8_t *p, size_t n);

/* Deterministic randomness. */
void rng_seed(validation_rng *r, uint64_t seed);
uint64_t rng_next(validation_rng *r);
size_t rng_below(validation_rng *r, size_t n);
void rng_bytes(validation_rng *r, uint8_t *p, size_t n);
size_t rng_length(validation_rng *r, size_t block_len, size_t max_blocks);

void fill_pattern(uint8_t *p, size_t n, unsigned seed);
int parse_number(const char *s, unsigned long *out);
int parse_header_number(const char *s, unsigned long *out);

/* Byte lengths around every padding edge of a block size, sorted and
 * unique. Returns the number written; out must have room for 128. */
size_t validation_boundaries(size_t block_len, size_t *out, size_t cap);

int check_bytes(validation_suite *s, int kernel, const uint8_t *got, const uint8_t *want, size_t n,
                const char *fmt, ...) __attribute__((format(printf, 6, 7)));
int check_code(validation_suite *s, int kernel, int got, int want, const char *fmt, ...)
    __attribute__((format(printf, 5, 6)));
int check(validation_suite *s, int kernel, int ok, const char *fmt, ...)
    __attribute__((format(printf, 4, 5)));

void guard_fill(uint8_t *p, size_t n);
int guard_intact(const uint8_t *p, size_t n);

/* Suites. Each returns nonzero when a check failed. */
int suite_cavp(void);
int suite_wycheproof(void);
int suite_bounds(void);
int suite_splits(void);
int suite_cross(void);
int suite_negative(void);
int suite_multiway(void);
int suite_oracle(void);
int suite_xarch(void);
int suite_long(void);
int suite_fuzz(void);

#endif /* NIRAPOD_SHA2_VALIDATION_H */
