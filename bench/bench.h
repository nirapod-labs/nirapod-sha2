/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * bench.h
 * =======
 *
 * The interface between the benchmark driver (bench.c), the known-answer
 * data (bench_kat.c) and one backend per library (backend_*.c). A backend
 * presents the library's operations as workloads of the same shape, so
 * that one driver verifies and times every library the same way.
 *
 * Workloads
 *
 *     A workload is a function, a message length and a mode, and for an
 *     HMAC also a key length. Workloads of the six hashes and the two
 *     HMACs name the message length; a
 *     multi-way workload names the length of each message, and its
 *     work_bytes is the total over all lanes. The *_REF workloads do the
 *     work of a multi-way call as 8 (or 4) one-shot single-way calls: they
 *     are the "same number of single calls" the multi-way forms are
 *     compared against, timed as one unit.
 *
 *     Message bytes follow bench_fill_msg and the HMAC key bench_fill_key;
 *     an HMAC workload with key length k uses the first k bytes of the key
 *     buffer. bench_kat returns the digest of each workload; a backend's
 *     output must equal it before the workload is timed.
 */

#ifndef NIRAPOD_SHA2_BENCH_H
#define NIRAPOD_SHA2_BENCH_H

#include <stddef.h>
#include <stdint.h>

/*
 * HMAC key lengths: one shorter than both block sizes, and one longer than
 * both (131 bytes, the long key of RFC 4231 test cases 6 and 7), which
 * makes HMAC hash the key first.
 */
#define BENCH_HMAC_KEY_SHORT 32
#define BENCH_HMAC_KEY_LONG 131
#define BENCH_HMAC_KEY_MAX BENCH_HMAC_KEY_LONG
#define BENCH_MAX_OUT 256
#define BENCH_MAX_LEN 1048576
#define BENCH_MAX_WORK_BYTES (8 * BENCH_MAX_LEN)

typedef enum bench_fn {
    BENCH_SHA224 = 0,
    BENCH_SHA256 = 1,
    BENCH_SHA384 = 2,
    BENCH_SHA512 = 3,
    BENCH_SHA512_224 = 4,
    BENCH_SHA512_256 = 5,
    BENCH_HMAC_SHA256 = 6,
    BENCH_HMAC_SHA512 = 7,
    BENCH_SHA256_X8 = 8,
    BENCH_SHA512_X4 = 9,
    BENCH_SHA256_X8_REF = 10,
    BENCH_SHA512_X4_REF = 11,
    BENCH_FN_COUNT = 12
} bench_fn;

typedef struct bench_workload {
    bench_fn fn;
    int incremental;
    size_t len;
    size_t key_len;    /* HMAC only; 0 for the other functions */
} bench_workload;

/*
 * One library path under test. id is private to the backend and selects,
 * for example, a kernel of this library; the driver never reads it.
 */
typedef struct bench_variant {
    const char *library;
    const char *version;
    const char *revision;
    const char *variant;
    int id;
    int (*supports)(const struct bench_variant *v, const bench_workload *w);
    int (*run)(const struct bench_variant *v, const bench_workload *w, uint8_t *out);
} bench_variant;

/* Filled by the backend before the driver enumerates it. */
extern const bench_variant *bench_variants;
extern size_t bench_variant_count;
void bench_backend_init(void);

/* bench.c; available to backends. */
void bench_fill_msg(uint8_t *p, size_t n);
void bench_fill_key(uint8_t *p);
const uint8_t *bench_msg(void);
const uint8_t *bench_key(void);
size_t bench_fn_out_len(bench_fn fn);
size_t bench_work_bytes(const bench_workload *w);
const char *bench_fn_name(bench_fn fn);
const char *bench_workload_name(const bench_workload *w);

/* bench_kat.c, generated. */
const unsigned char *bench_kat(bench_fn fn, size_t len, size_t key_len, size_t *out_len);

#endif /* NIRAPOD_SHA2_BENCH_H */
