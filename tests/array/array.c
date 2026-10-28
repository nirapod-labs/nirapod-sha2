/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * array.c
 * =======
 *
 * The exports of the array test unit (array.jazz) against the
 * library's one-shot functions: for every array size, every offset and
 * every length of a slice (sampled offsets for the largest size), the
 * single-way form, and the multi-way forms at lane strides from 0 (every
 * lane the same bytes) through overlapping lanes to lanes one after
 * another, must give the digests of the same bytes hashed from memory.
 */

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "nirapod/sha2.h"

typedef void (*array_fn)(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t len);
typedef void (*lanes_fn)(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t stride,
                         uint64_t len);

#define DECLARE(n)                                                                  \
    void A##n##__sha256(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t len);    \
    void A##n##__sha512(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t len);    \
    void A##n##__sha256_x8(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t stride, \
                           uint64_t len);                                           \
    void A##n##__sha512_x4(uint8_t *out, const uint8_t *a, uint64_t off, uint64_t stride, \
                           uint64_t len);

DECLARE(1)
DECLARE(64)
DECLARE(128)
DECLARE(333)

typedef struct instance {
    size_t size;
    array_fn sha256, sha512;
    lanes_fn sha256_x8, sha512_x4;
} instance;

static const instance instances[] = {
    { 1, A1__sha256, A1__sha512, A1__sha256_x8, A1__sha512_x4 },
    { 64, A64__sha256, A64__sha512, A64__sha256_x8, A64__sha512_x4 },
    { 128, A128__sha256, A128__sha512, A128__sha256_x8, A128__sha512_x4 },
    { 333, A333__sha256, A333__sha512, A333__sha256_x8, A333__sha512_x4 },
};

static unsigned long passed, failed;

static void expect(int ok, const char *what, size_t size, size_t off, size_t stride, size_t len)
{
    if (ok) {
        passed++;
    } else {
        failed++;
        if (failed <= 20) {
            fprintf(stderr, "FAIL: %s, size %zu, offset %zu, stride %zu, length %zu\n", what, size,
                    off, stride, len);
        }
    }
}

static void slice(const instance *in, const uint8_t *a, size_t off, size_t len)
{
    uint8_t got[64], want[64];
    size_t n = in->size;

    in->sha256(got, a, off, len);
    nirapod_sha2_sha256(want, a + off, len);
    expect(memcmp(got, want, 32) == 0, "sha256", n, off, 0, len);

    in->sha512(got, a, off, len);
    nirapod_sha2_sha512(want, a + off, len);
    expect(memcmp(got, want, 64) == 0, "sha512", n, off, 0, len);
}

/* Lane k: the len bytes at off + k stride, for the forms whose lanes fit. */
static void lanes(const instance *in, const uint8_t *a, size_t off, size_t stride, size_t len)
{
    uint8_t got[256], want[64];
    size_t k, n = in->size;

    if (off + 7 * stride + len <= n) {
        in->sha256_x8(got, a, off, stride, len);
        for (k = 0; k < 8; k++) {
            nirapod_sha2_sha256(want, a + off + k * stride, len);
            expect(memcmp(got + 32 * k, want, 32) == 0, "sha256_x8", n, off, stride, len);
        }
    }
    if (off + 3 * stride + len <= n) {
        in->sha512_x4(got, a, off, stride, len);
        for (k = 0; k < 4; k++) {
            nirapod_sha2_sha512(want, a + off + k * stride, len);
            expect(memcmp(got + 64 * k, want, 64) == 0, "sha512_x4", n, off, stride, len);
        }
    }
}

/* Every length from off, single-way and at every stride. */
static void from_offset(const instance *in, const uint8_t *a, size_t off)
{
    static const size_t strides[] = { 0, 1, 7, 8, 16, 33, 41 };
    size_t s, len;

    for (len = 0; off + len <= in->size; len++) {
        slice(in, a, off, len);
        for (s = 0; s < sizeof strides / sizeof strides[0]; s++) {
            lanes(in, a, off, strides[s], len);
        }
    }
}

int main(void)
{
    static uint8_t a[333];
    static const size_t sampled[] = { 0, 1, 7, 8, 63, 64, 100, 127, 128, 200, 300, 332, 333 };
    size_t i, j, off;

    for (i = 0; i < sizeof a; i++) {
        a[i] = (uint8_t)(i * 167 + 13);
    }
    for (i = 0; i < sizeof instances / sizeof instances[0]; i++) {
        const instance *in = &instances[i];

        if (in->size <= 128) {
            for (off = 0; off <= in->size; off++) {
                from_offset(in, a, off);
            }
        } else {
            for (j = 0; j < sizeof sampled / sizeof sampled[0]; j++) {
                from_offset(in, a, sampled[j]);
            }
        }
    }
    printf("array: %lu checks passed, %lu failed\n", passed, failed);
    return failed == 0 ? 0 : 1;
}
