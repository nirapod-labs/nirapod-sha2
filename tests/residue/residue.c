/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * tests/residue/residue.c
 * =======================
 *
 * What a call leaves behind on the stack and in registers. nirapod_sha2.h
 * says every export clears the stack it used before it returns and that
 * the C layer clears the registers a Jasmin call may leave holding
 * secret-derived values (capi/clear.c). This program checks both on the
 * linked library, for every operation of the public header, once through
 * the public functions and once per kernel built here through the testing
 * library.
 *
 * Secrets. A random 1100-byte message and a random key, used at two key
 * lengths, 37 and 300 bytes (below and above both block sizes). The
 * secret strings searched for are the message, the key and, for each
 * HMAC, the padded key block K0 and K0 XOR ipad and K0 XOR opad
 * (FIPS 198-1). A string is found when any 8 consecutive bytes of it, or
 * one of its 4-byte or 8-byte words in either byte order, appear where
 * they are looked for. Windows mostly made of one byte value are left out
 * (weak(), below): padding produces them, and they say nothing about the
 * key.
 *
 * Stack. Before each call a region of RESIDUE_AREA bytes below the
 * caller's frame is filled with PATTERN, the call is made from the same
 * frame (the frames of the call land in the region), and the region is
 * copied out after it. Two checks:
 *
 *     the copy holds no secret string, anywhere
 *     every byte that is neither PATTERN nor zero lies within C_REGION
 *     bytes of the top of the region
 *
 * The second holds because the Jasmin frames are the deepest and are
 * cleared to zero by the export, while the C frames above them keep
 * return addresses, saved registers and lengths. It covers values derived
 * from the secrets that no search could recognise (schedule words,
 * working variables, chaining values). The deepest byte the call changed
 * at all is also recorded; it must exceed C_REGION for at least one call,
 * or the region did not reach the Jasmin frames and the second check said
 * nothing.
 *
 * Registers. The call is made through residue_call (regs.S), which
 * records every register a callee may change, before any other code runs:
 *
 *     AArch64   x0-x17 and v0-v31 must hold no secret word; v0-v7 and
 *               v16-v31 must be zero, and so must the upper halves of
 *               v8-v15 (their lower halves are callee-saved and hold the
 *               caller's values)
 *     x86-64    rax, rcx, rdx, rsi, rdi, r8-r11 and the vector registers
 *               must hold no secret word; on a CPU with AVX-512,
 *               zmm0-zmm31 must be zero; otherwise
 *               xmm0-xmm15 must be zero and, after a kernel that uses AVX
 *               (shani, avx2), all of ymm0-ymm15. After the portable
 *               kernel the upper ymm halves are not checked: clear.c does
 *               not clear them there, because that code never writes them.
 *
 * The general registers cannot be held to zero: after the clearing the C
 * layer returns through its own code, which leaves the status and other
 * values of its own there.
 *
 * Negative controls, which must be detected for the run to pass: a C
 * function that copies the key into a local array deeper than C_REGION and
 * returns without clearing it (both stack checks must fire), and
 * residue_leak, which returns with key bytes in a general and a vector
 * register (both register checks must fire).
 *
 * Not covered: the stack and registers of signal handlers or of the
 * operating system, and the mask registers k0-k7 (capi/clear.c).
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "nirapod_sha2.h"
#include "nirapod_sha2_testing.h"

#define RESIDUE_AREA 32768
#define PATTERN 0xa5
#define C_REGION 512
#define RESIDUE_DUMP_BYTES (256 + 32 * 64)
#define MSG_LEN 1100
#define KEY_MAX 300

#define NOINLINE __attribute__((noinline))

typedef void (*any_fn)(void);

void residue_call(any_fn fn, const uint64_t args[6], uint8_t *dump, unsigned mode);
int residue_leak(const uint8_t *p);

/* CPU feature bits of nirapod_sha2_testing_cpu_features (capi/internal.h). */
#define CPU_AVX2 0x01u
#define CPU_SHANI 0x02u
#define CPU_AVX512 0x04u
#define CPU_BMI2 0x100u

static uint8_t msg[MSG_LEN];
static uint8_t key[KEY_MAX];
static uint8_t snapshot[RESIDUE_AREA];

/* ------------------------------------------------------------------ */
/* Secret windows                                                      */
/* ------------------------------------------------------------------ */

static uint64_t *win8;
static size_t win8_n, win8_cap;
static uint32_t *win4;
static size_t win4_n, win4_cap;

static uint64_t load64(const uint8_t *p)
{
    uint64_t v = 0;
    unsigned i;

    for (i = 0; i < 8; i++) {
        v |= (uint64_t)p[i] << (8 * i);
    }
    return v;
}

static uint32_t load32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) |
           ((uint32_t)p[3] << 24);
}

static uint64_t swap64(uint64_t v)
{
    uint64_t r = 0;
    unsigned i;

    for (i = 0; i < 8; i++) {
        r = (r << 8) | ((v >> (8 * i)) & 0xff);
    }
    return r;
}

static uint32_t swap32(uint32_t v)
{
    return (v >> 24) | ((v >> 8) & 0xff00u) | ((v << 8) & 0xff0000u) | (v << 24);
}

/*
 * A window says something about a secret only if no byte value fills more
 * than half of it. Windows that are mostly one value come from padding
 * (the zeros after a short or hashed key, and runs of 0x36 or 0x5c), and
 * they also occur in ordinary stack contents: the high byte of a Linux
 * AArch64 stack address followed by zeros matches the end of a hashed key
 * followed by its zero padding.
 */
static int weak(const uint8_t *p, size_t n)
{
    size_t i, j, same;

    for (i = 0; i < n; i++) {
        same = 0;
        for (j = 0; j < n; j++) {
            same += p[j] == p[i];
        }
        if (2 * same > n) {
            return 1;
        }
    }
    return 0;
}

static void add8(uint64_t v)
{
    if (win8_n == win8_cap) {
        win8_cap = win8_cap ? 2 * win8_cap : 4096;
        win8 = realloc(win8, win8_cap * sizeof *win8);
        if (win8 == NULL) {
            exit(2);
        }
    }
    win8[win8_n++] = v;
}

static void add4(uint32_t v)
{
    if (win4_n == win4_cap) {
        win4_cap = win4_cap ? 2 * win4_cap : 4096;
        win4 = realloc(win4, win4_cap * sizeof *win4);
        if (win4 == NULL) {
            exit(2);
        }
    }
    win4[win4_n++] = v;
}

static void add_secret(const uint8_t *s, size_t n)
{
    size_t i;

    for (i = 0; i + 8 <= n; i++) {
        if (!weak(s + i, 8)) {
            add8(load64(s + i));
            if (i % 8 == 0) {
                add8(swap64(load64(s + i)));
            }
        }
    }
    for (i = 0; i + 4 <= n; i += 4) {
        if (!weak(s + i, 4)) {
            add4(load32(s + i));
            add4(swap32(load32(s + i)));
        }
    }
}

static int cmp64(const void *a, const void *b)
{
    uint64_t x = *(const uint64_t *)a, y = *(const uint64_t *)b;

    return x < y ? -1 : x > y;
}

static int cmp32(const void *a, const void *b)
{
    uint32_t x = *(const uint32_t *)a, y = *(const uint32_t *)b;

    return x < y ? -1 : x > y;
}

static int has8(uint64_t v)
{
    return bsearch(&v, win8, win8_n, sizeof *win8, cmp64) != NULL;
}

static int has4(uint32_t v)
{
    return bsearch(&v, win4, win4_n, sizeof *win4, cmp32) != NULL;
}

/* K0 of FIPS 198-1 for a key of len bytes and a block of block bytes,
 * XORed with pad. */
static void key_block(uint8_t *out, size_t block, size_t len, uint8_t pad)
{
    size_t i;

    memset(out, 0, block);
    if (len > block) {
        if (block == 64) {
            nirapod_sha2_sha256(out, key, len);
        } else {
            nirapod_sha2_sha512(out, key, len);
        }
    } else {
        memcpy(out, key, len);
    }
    for (i = 0; i < block; i++) {
        out[i] ^= pad;
    }
}

static void build_secrets(void)
{
    static const size_t key_lens[2] = { 37, 300 };
    static const size_t blocks[2] = { 64, 128 };
    static const uint8_t pads[3] = { 0, 0x36, 0x5c };
    uint8_t k0[128];
    size_t a, b, p;
    uint64_t x = UINT64_C(0x7265736964756521);

    for (a = 0; a < MSG_LEN; a++) {
        x = x * UINT64_C(6364136223846793005) + UINT64_C(1442695040888963407);
        msg[a] = (uint8_t)(x >> 56);
    }
    for (a = 0; a < KEY_MAX; a++) {
        x = x * UINT64_C(6364136223846793005) + UINT64_C(1442695040888963407);
        key[a] = (uint8_t)(x >> 56);
    }
    add_secret(msg, sizeof msg);
    add_secret(key, sizeof key);
    for (a = 0; a < 2; a++) {
        for (b = 0; b < 2; b++) {
            for (p = 0; p < 3; p++) {
                key_block(k0, blocks[b], key_lens[a], pads[p]);
                add_secret(k0, blocks[b]);
            }
        }
    }
    qsort(win8, win8_n, sizeof *win8, cmp64);
    qsort(win4, win4_n, sizeof *win4, cmp32);
}

/* ------------------------------------------------------------------ */
/* Stack                                                               */
/* ------------------------------------------------------------------ */

/*
 * probe(0) fills the region; probe(1), called from the same frame, has
 * the same frame and so the same region, and copies it to snapshot. The
 * accesses go through a volatile pointer, so neither is optimised away.
 */
static NOINLINE void probe(int scan)
{
    unsigned char area[RESIDUE_AREA];
    volatile unsigned char *p = area;
    size_t i;

    if (!scan) {
        for (i = 0; i < RESIDUE_AREA; i++) {
            p[i] = PATTERN;
        }
        return;
    }
    for (i = 0; i < RESIDUE_AREA; i++) {
        snapshot[i] = p[i];
    }
}

struct stack_result {
    size_t secret_at;  /* depth of a secret window, 0 if none */
    size_t nonzero;    /* deepest byte neither PATTERN nor zero */
    size_t touched;    /* deepest byte that is not PATTERN */
};

static struct stack_result scan_stack(void)
{
    struct stack_result r = { 0, 0, 0 };
    size_t i;

    for (i = 0; i < RESIDUE_AREA; i++) {
        size_t depth = RESIDUE_AREA - i;

        if (snapshot[i] != PATTERN) {
            if (depth > r.touched) {
                r.touched = depth;
            }
            if (snapshot[i] != 0 && depth > r.nonzero) {
                r.nonzero = depth;
            }
        }
        if (r.secret_at == 0 && i + 8 <= RESIDUE_AREA && has8(load64(snapshot + i))) {
            r.secret_at = depth;
        }
        if (r.secret_at == 0 && i % 4 == 0 && i + 4 <= RESIDUE_AREA) {
            uint32_t w = load32(snapshot + i);

            if (w != 0 && w != 0xa5a5a5a5u && has4(w)) {
                r.secret_at = depth;
            }
        }
    }
    return r;
}

/* The stack negative control: the key, left in a local array. */
static NOINLINE int leaky(const uint8_t *k)
{
    volatile uint8_t local[2048];
    size_t i;

    for (i = 0; i < sizeof local; i++) {
        local[i] = k[i % 64];
    }
    return local[5];
}

/* ------------------------------------------------------------------ */
/* Registers                                                           */
/* ------------------------------------------------------------------ */

static uint8_t dump[RESIDUE_DUMP_BYTES];

static unsigned vector_mode(void)
{
#if defined(__x86_64__)
    unsigned cpu = nirapod_sha2_testing_cpu_features();

    if (cpu & CPU_AVX512) {
        return 2;
    }
    if (cpu & (CPU_AVX2 | CPU_SHANI | CPU_BMI2)) {
        return 1;
    }
#endif
    return 0;
}

struct reg_result {
    int gpr_secret;    /* index + 1 of a general register holding a secret word */
    int vec_secret;    /* index + 1 of a vector register holding a secret window */
    int vec_nonzero;   /* index + 1 of a vector register not cleared */
};

static int holds_secret(const uint8_t *p, size_t n)
{
    size_t b;

    for (b = 0; b + 8 <= n; b += 4) {
        if (has8(load64(p + b))) {
            return 1;
        }
    }
    return 0;
}

/* avx_kernel: the call ran AVX code, so the whole ymm registers count. */
static struct reg_result scan_regs(unsigned mode, int avx_kernel)
{
    struct reg_result r = { 0, 0, 0 };
    const uint8_t *v = dump + 256;
    int i;
    size_t b;
#if defined(__aarch64__)
    const int gprs = 18;
#else
    const int gprs = 9;
#endif

    for (i = 0; i < gprs && r.gpr_secret == 0; i++) {
        uint64_t g = load64(dump + 8 * i);

        if (has8(g) || has4((uint32_t)g) || has4((uint32_t)(g >> 32))) {
            r.gpr_secret = i + 1;
        }
    }
#if defined(__aarch64__)
    (void)mode;
    (void)avx_kernel;
    for (i = 0; i < 32 && r.vec_secret == 0; i++) {
        if (holds_secret(v + 16 * i, 16)) {
            r.vec_secret = i + 1;
        }
    }
    for (i = 0; i < 32 && r.vec_nonzero == 0; i++) {
        b = (i >= 8 && i < 16) ? 8 : 0;
        for (; b < 16; b++) {
            if (v[16 * i + b] != 0) {
                r.vec_nonzero = i + 1;
                break;
            }
        }
    }
#else
    {
        int count = mode == 2 ? 32 : 16;
        size_t width = mode == 2 ? 64 : mode == 1 ? 32 : 16;
        size_t checked = mode == 1 && !avx_kernel ? 16 : width;

        for (i = 0; i < count && r.vec_secret == 0; i++) {
            if (holds_secret(v + width * (size_t)i, width)) {
                r.vec_secret = i + 1;
            }
        }
        for (i = 0; i < count && r.vec_nonzero == 0; i++) {
            for (b = 0; b < checked; b++) {
                if (v[width * (size_t)i + b] != 0) {
                    r.vec_nonzero = i + 1;
                    break;
                }
            }
        }
    }
#endif
    return r;
}

/* ------------------------------------------------------------------ */
/* Operations                                                          */
/* ------------------------------------------------------------------ */

enum kind { ONESHOT, INIT, UPDATE, FINAL, HMAC_ONESHOT, HMAC_INIT, X_ONESHOT, X_INIT,
            X_INIT_FROM, X_UPDATE, X_FINAL };

struct op {
    const char *name;
    nirapod_sha2_testing_family family;
    enum kind kind;
    any_fn public_fn;
    any_fn testing_fn;
};

#define F256 NIRAPOD_SHA2_TESTING_FAMILY_SHA256
#define F512 NIRAPOD_SHA2_TESTING_FAMILY_SHA512
#define FX8 NIRAPOD_SHA2_TESTING_FAMILY_X8
#define FX4 NIRAPOD_SHA2_TESTING_FAMILY_X4

#define HASH(h, f)                                                                             \
    { #h, f, ONESHOT, (any_fn)nirapod_sha2_##h, (any_fn)nirapod_sha2_testing_##h },            \
    { #h "_init", f, INIT, (any_fn)nirapod_sha2_##h##_init,                                    \
      (any_fn)nirapod_sha2_testing_##h##_init },                                               \
    { #h "_update", f, UPDATE, (any_fn)nirapod_sha2_##h##_update,                              \
      (any_fn)nirapod_sha2_testing_##h##_update },                                             \
    { #h "_final", f, FINAL, (any_fn)nirapod_sha2_##h##_final,                                 \
      (any_fn)nirapod_sha2_testing_##h##_final }

#define HMAC(h, f)                                                                             \
    { "hmac_" #h, f, HMAC_ONESHOT, (any_fn)nirapod_sha2_hmac_##h,                              \
      (any_fn)nirapod_sha2_testing_hmac_##h },                                                 \
    { "hmac_" #h "_init", f, HMAC_INIT, (any_fn)nirapod_sha2_hmac_##h##_init,                  \
      (any_fn)nirapod_sha2_testing_hmac_##h##_init },                                          \
    { "hmac_" #h "_update", f, UPDATE, (any_fn)nirapod_sha2_hmac_##h##_update,                 \
      (any_fn)nirapod_sha2_testing_hmac_##h##_update },                                        \
    { "hmac_" #h "_final", f, FINAL, (any_fn)nirapod_sha2_hmac_##h##_final,                    \
      (any_fn)nirapod_sha2_testing_hmac_##h##_final }

#define MULTI(h, f)                                                                            \
    { #h, f, X_ONESHOT, (any_fn)nirapod_sha2_##h, (any_fn)nirapod_sha2_testing_##h },          \
    { #h "_init", f, X_INIT, (any_fn)nirapod_sha2_##h##_init,                                  \
      (any_fn)nirapod_sha2_testing_##h##_init },                                               \
    { #h "_init_from", f, X_INIT_FROM, (any_fn)nirapod_sha2_##h##_init_from,                   \
      (any_fn)nirapod_sha2_testing_##h##_init_from },                                          \
    { #h "_update", f, X_UPDATE, (any_fn)nirapod_sha2_##h##_update,                            \
      (any_fn)nirapod_sha2_testing_##h##_update },                                             \
    { #h "_final", f, X_FINAL, (any_fn)nirapod_sha2_##h##_final,                               \
      (any_fn)nirapod_sha2_testing_##h##_final }

static const struct op ops[] = {
    HASH(sha224, F256), HASH(sha256, F256), HASH(sha384, F512), HASH(sha512, F512),
    HASH(sha512_224, F512), HASH(sha512_256, F512), HMAC(sha256, F256), HMAC(sha512, F512),
    MULTI(sha256_x8, FX8), MULTI(sha512_x4, FX4),
};

#define OPS (sizeof ops / sizeof ops[0])

static uint64_t ctx[NIRAPOD_SHA2_SHA256_X8_CTX_BYTES / 8];
static uint64_t src256[NIRAPOD_SHA2_SHA256_CTX_BYTES / 8];
static uint64_t src512[NIRAPOD_SHA2_SHA512_CTX_BYTES / 8];
static uint8_t out[256];
static const uint8_t *lanes[8];

static unsigned failures, calls;
static size_t deepest_touched, deepest_nonzero;

/* The arguments of op for the target (kernel, or -1 for the public
 * functions), after the kernel argument where there is one. */
static void arguments(const struct op *o, size_t key_len, uint64_t *a)
{
    switch (o->kind) {
    case ONESHOT:
        a[0] = (uintptr_t)out; a[1] = (uintptr_t)msg; a[2] = MSG_LEN; break;
    case INIT:
    case X_INIT:
        a[0] = (uintptr_t)ctx; break;
    case UPDATE:
        a[0] = (uintptr_t)ctx; a[1] = (uintptr_t)msg; a[2] = MSG_LEN; break;
    case FINAL:
    case X_FINAL:
        a[0] = (uintptr_t)ctx; a[1] = (uintptr_t)out; break;
    case HMAC_ONESHOT:
        a[0] = (uintptr_t)out; a[1] = (uintptr_t)key; a[2] = key_len;
        a[3] = (uintptr_t)msg; a[4] = MSG_LEN; break;
    case HMAC_INIT:
        a[0] = (uintptr_t)ctx; a[1] = (uintptr_t)key; a[2] = key_len; break;
    case X_ONESHOT:
    case X_UPDATE:
        a[0] = (o->kind == X_ONESHOT) ? (uintptr_t)out : (uintptr_t)ctx;
        a[1] = (uintptr_t)lanes; a[2] = 1000; break;
    case X_INIT_FROM:
        a[0] = (uintptr_t)ctx;
        a[1] = (uintptr_t)(o->family == FX8 ? (void *)src256 : (void *)src512); break;
    }
}

/*
 * One call: paint, call through the trampoline, copy the region, all
 * from this frame. A macro so that the call is made at the depth probe()
 * runs at.
 */
#define TRACED_CALL(fn, args, mode)                                                         \
    do {                                                                                     \
        probe(0);                                                                            \
        residue_call((fn), (args), dump, (mode));                                            \
        probe(1);                                                                            \
    } while (0)

static void report(const char *target, const char *name, size_t key_len,
                   struct stack_result s, struct reg_result r, int status)
{
    calls++;
    if (s.touched > deepest_touched) {
        deepest_touched = s.touched;
    }
    if (s.nonzero > deepest_nonzero) {
        deepest_nonzero = s.nonzero;
    }
    if (status != NIRAPOD_SHA2_OK || s.secret_at != 0 || s.nonzero > C_REGION ||
        r.gpr_secret != 0 || r.vec_secret != 0 || r.vec_nonzero != 0) {
        failures++;
        printf("FAIL %s %s key %zu: status %d, secret on the stack at depth %zu, "
               "deepest nonzero %zu (limit %d), secret in general register %d, "
               "in vector register %d, vector register %d not cleared (-1: none)\n",
               target, name, key_len, status, s.secret_at, s.nonzero, C_REGION,
               r.gpr_secret - 1, r.vec_secret - 1, r.vec_nonzero - 1);
    }
}

static NOINLINE void run_target(int kernel, const char *target)
{
    unsigned mode = vector_mode();
    int avx_kernel = kernel == NIRAPOD_SHA2_TESTING_X86_64_SHANI ||
                     kernel == NIRAPOD_SHA2_TESTING_X86_64_AVX2;
    static const size_t key_lens[2] = { 37, 300 };
    size_t k, i;

    for (k = 0; k < 2; k++) {
        for (i = 0; i < OPS; i++) {
            const struct op *o = &ops[i];
            uint64_t a[6] = { 0, 0, 0, 0, 0, 0 };
            uint64_t args[6];
            size_t j;

            if (kernel >= 0 &&
                !nirapod_sha2_testing_available((nirapod_sha2_testing_kernel)kernel, o->family)) {
                continue;
            }
            arguments(o, key_lens[k], a);
            if (o->kind == X_INIT_FROM) {
                /* A source context with some input, made outside the trace. */
                if (kernel >= 0) {
                    nirapod_sha2_testing_kernel kk = (nirapod_sha2_testing_kernel)kernel;

                    nirapod_sha2_testing_sha256_init(kk, (nirapod_sha2_sha256_ctx *)src256);
                    nirapod_sha2_testing_sha256_update(kk, (nirapod_sha2_sha256_ctx *)src256,
                                                       msg, 100);
                    nirapod_sha2_testing_sha512_init(kk, (nirapod_sha2_sha512_ctx *)src512);
                    nirapod_sha2_testing_sha512_update(kk, (nirapod_sha2_sha512_ctx *)src512,
                                                       msg, 100);
                } else {
                    nirapod_sha2_sha256_init((nirapod_sha2_sha256_ctx *)src256);
                    nirapod_sha2_sha256_update((nirapod_sha2_sha256_ctx *)src256, msg, 100);
                    nirapod_sha2_sha512_init((nirapod_sha2_sha512_ctx *)src512);
                    nirapod_sha2_sha512_update((nirapod_sha2_sha512_ctx *)src512, msg, 100);
                }
            }
            if (kernel >= 0) {
                args[0] = (uint64_t)kernel;
                for (j = 1; j < 6; j++) {
                    args[j] = a[j - 1];
                }
                TRACED_CALL(o->testing_fn, args, mode);
            } else {
                for (j = 0; j < 6; j++) {
                    args[j] = a[j];
                }
                TRACED_CALL(o->public_fn, args, mode);
            }
            report(target, o->name, key_lens[k], scan_stack(),
                   scan_regs(mode, avx_kernel),
                   (int)(int32_t)load64(dump));
        }
    }
}

static NOINLINE int controls(void)
{
    uint64_t args[6] = { 0, 0, 0, 0, 0, 0 };
    struct stack_result s;
    struct reg_result r;
    int ok = 1;

    probe(0);
    (void)leaky(key);
    probe(1);
    s = scan_stack();
    if (s.secret_at == 0 || s.nonzero <= C_REGION) {
        printf("FAIL control: a key left on the stack was not detected (secret at %zu, "
               "deepest nonzero %zu)\n", s.secret_at, s.nonzero);
        ok = 0;
    } else {
        printf("control: a key left on the stack was detected (depth %zu)\n", s.secret_at);
    }

    args[0] = (uintptr_t)key;
    residue_call((any_fn)residue_leak, args, dump, vector_mode());
    r = scan_regs(vector_mode(), 1);
    if (r.gpr_secret == 0 || r.vec_secret == 0) {
        printf("FAIL control: key bytes left in registers were not detected\n");
        ok = 0;
    } else {
        printf("control: key bytes left in registers were detected (general register %d, "
               "vector register %d)\n", r.gpr_secret - 1, r.vec_secret - 1);
    }
    return ok;
}

int main(void)
{
    unsigned k;
    size_t m;
    int ok;

    build_secrets();
    for (m = 0; m < 8; m++) {
        lanes[m] = msg + 7 * m;
    }
    printf("residue: %zu secret windows of 8 bytes, %zu words of 4, vector mode %u\n", win8_n,
           win4_n, vector_mode());
    ok = controls();

    run_target(-1, "public");
    for (k = 0; k < NIRAPOD_SHA2_TESTING_KERNELS; k++) {
        const char *name = nirapod_sha2_testing_kernel_name((nirapod_sha2_testing_kernel)k);

        if (name != NULL) {
            run_target((int)k, name);
        }
    }
    if (deepest_touched <= C_REGION) {
        printf("FAIL residue: no call changed the stack deeper than %d bytes, so the region "
               "did not reach the Jasmin frames\n", C_REGION);
        ok = 0;
    }
    printf("residue: %u calls, %u failures, deepest change %zu bytes, deepest nonzero byte "
           "%zu (limit %d)\n", calls, failures, deepest_touched, deepest_nonzero, C_REGION);
    if (!ok || failures != 0 || calls == 0) {
        printf("residue: FAIL\n");
        return 1;
    }
    printf("residue: PASS\n");
    return 0;
}
