/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * backend_sphincs.c
 * =================
 *
 * The backend for the multi-buffer SHA-2 of the SPHINCS+ reference code
 * (directory sha2-avx2/, pinned in toolchain/baselines/PIN), with one
 * variant:
 *
 *     sha2-avx2    sha256x8, eight SHA-256 lanes in the 32-bit lanes of
 *                  AVX2 registers, and sha512x4_seeded, four SHA-512
 *                  lanes in the 64-bit lanes.
 *
 * This is the multi-way code the SPHINCS+ signature scheme runs. It
 * offers the two multi-way workloads and nothing else. Its single-way
 * hash, sha2.c, is portable C and is not the code being compared here.
 *
 * Both entry points hash a whole message per lane in one call, so the
 * workload is one-shot. sha256x8 starts from the FIPS 180-4 initial hash
 * value. The SHA-512 code has only a seeded form, which starts from a
 * given chaining value and a count of bits already hashed; given the
 * FIPS 180-4 initial hash value and a count of zero it is SHA-512 of the
 * message. Every output is still checked against the known answers before
 * a workload is timed, so a wrong reading of either entry point shows as a
 * failure, not as a number.
 *
 * Like HACL*'s multi-way forms these take one pointer per lane, and this
 * library's take one packed buffer. The lanes here point into the packed
 * buffer, so both hash the same bytes. The code needs AVX2 at run time;
 * on a CPU without it, nothing is offered.
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "sha256x8.h"
#include "sha512x4.h"

#include "bench.h"

#ifndef BENCH_VERSION
#define BENCH_VERSION "unknown"
#endif
#ifndef BENCH_REVISION
#define BENCH_REVISION "unknown"
#endif

#define SPHINCS_LIBRARY "sphincsplus"

/* FIPS 180-4, 5.3.5: the initial hash value H(0) of SHA-512. */
static const uint64_t sha512_h0[8] = {
    0x6a09e667f3bcc908ULL, 0xbb67ae8584caa73bULL,
    0x3c6ef372fe94f82bULL, 0xa54ff53a5f1d36f1ULL,
    0x510e527fade682d1ULL, 0x9b05688c2b3e6c1fULL,
    0x1f83d9abfb41bd6bULL, 0x5be0cd19137e2179ULL
};

/* H(0) as sha512x4_seeded reads its seed: eight big-endian words. */
static unsigned char sha512_seed[64];

static int have_avx2;

static void spx_sha256_x8(uint8_t *out, const uint8_t *in, size_t len)
{
    sha256x8(out, out + 32, out + 64, out + 96,
             out + 128, out + 160, out + 192, out + 224,
             in, in + len, in + 2 * len, in + 3 * len,
             in + 4 * len, in + 5 * len, in + 6 * len, in + 7 * len,
             (unsigned long long)len);
}

static void spx_sha512_x4(uint8_t *out, const uint8_t *in, size_t len)
{
    sha512x4_seeded(out, out + 64, out + 128, out + 192,
                    sha512_seed, 0,
                    in, in + len, in + 2 * len, in + 3 * len,
                    (unsigned long long)len);
}

static int sphincs_supports(const bench_variant *v, const bench_workload *w)
{
    (void)v;
    if (!have_avx2) {
        return 0;
    }
    return w->fn == BENCH_SHA256_X8 || w->fn == BENCH_SHA512_X4;
}

static int sphincs_run(const bench_variant *v, const bench_workload *w, uint8_t *out)
{
    (void)v;
    switch (w->fn) {
    case BENCH_SHA256_X8:
        spx_sha256_x8(out, bench_msg(), w->len);
        return 0;
    case BENCH_SHA512_X4:
        spx_sha512_x4(out, bench_msg(), w->len);
        return 0;
    default:
        return -1;
    }
}

static const bench_variant variants[] = {
    { SPHINCS_LIBRARY, BENCH_VERSION, BENCH_REVISION, "sha2-avx2", 0,
      sphincs_supports, sphincs_run },
};

void bench_backend_init(void)
{
    size_t i, j;

    for (i = 0; i < 8; i++) {
        for (j = 0; j < 8; j++) {
            sha512_seed[8 * i + j] = (unsigned char)(sha512_h0[i] >> (56 - 8 * j));
        }
    }
    __builtin_cpu_init();
    have_avx2 = __builtin_cpu_supports("avx2");
    if (!have_avx2) {
        fprintf(stderr, "bench: %s: this CPU has no AVX2, nothing to run\n",
                SPHINCS_LIBRARY);
    }

    bench_variants = variants;
    bench_variant_count = sizeof(variants) / sizeof(variants[0]);
}
