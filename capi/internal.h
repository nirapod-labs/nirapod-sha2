/*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * internal.h
 * ==========
 *
 * Declarations shared by the C files of the library. Nothing here is part
 * of the public API, and every symbol carries the library prefix.
 *
 *     units.c     one record per compiled unit: its Jasmin exports and the
 *                 CPU features each operation family needs
 *     dispatch.c  CPU features of the running machine, choice of unit
 *     timing.c    the data-independent-timing mode around each call
 *     clear.c     clearing of the registers a Jasmin call leaves behind
 *     api.c       argument checks and the calls; the public functions
 *
 * Two libraries
 *
 *     libnirapod_sha2.a links these objects and every unit of the host
 *     architecture into one object in which only the functions of
 *     nirapod_sha2.h stay global (Makefile, "Libraries"); the functions
 *     declared here and the Jasmin exports become local symbols.
 *     libnirapod_sha2_testing.a holds the same objects with their symbols
 *     as compiled, plus capi/testing/testing.c, the per-kernel entry points
 *     of nirapod_sha2_testing.h. Both run the same C code: the testing
 *     functions differ from the public ones only in taking the unit as an
 *     argument instead of asking dispatch.c for it.
 */

#ifndef NIRAPOD_SHA2_INTERNAL_H
#define NIRAPOD_SHA2_INTERNAL_H

#include <stddef.h>
#include <stdint.h>

#include "nirapod_sha2.h"
#include "jasmin.h"

/*
 * CPU features a unit may need, as nirapod_sha2_cpu_features reports them
 * for the running architecture. No unit needs the AVX-512 bits:
 * nirapod_sha2_clear_registers reads them to clear the registers AVX-512
 * adds, and timing.c reads DIT.
 */
#define NIRAPOD_SHA2_CPU_AVX2     0x01u  /* x86-64: AVX2, YMM state enabled */
#define NIRAPOD_SHA2_CPU_SHANI    0x02u  /* x86-64: SHA extensions and AVX */
#define NIRAPOD_SHA2_CPU_AVX512   0x04u  /* x86-64: AVX-512F, ZMM state enabled */
#define NIRAPOD_SHA2_CPU_AVX512VL 0x08u  /* x86-64: AVX512VL as well */
#define NIRAPOD_SHA2_CPU_ASIMD    0x10u  /* AArch64: Advanced SIMD */
#define NIRAPOD_SHA2_CPU_SHA256   0x20u  /* AArch64: FEAT_SHA256 */
#define NIRAPOD_SHA2_CPU_SHA512   0x40u  /* AArch64: FEAT_SHA512 */
#define NIRAPOD_SHA2_CPU_DIT      0x80u  /* AArch64: FEAT_DIT */

/*
 * Operation families. Within a family every operation runs the same
 * compression kernel, so one feature test covers the family:
 *
 *     SHA256   SHA-224, SHA-256, HMAC-SHA-256 (single-way SHA-256 kernel)
 *     SHA512   SHA-384, SHA-512, SHA-512/224, SHA-512/256, HMAC-SHA-512
 *     X8       sha256_x8, one-shot and incremental (multi-way SHA-256 kernel)
 *     X4       sha512_x4, one-shot and incremental (multi-way SHA-512 kernel)
 */
typedef enum nirapod_sha2_family {
    NIRAPOD_SHA2_FAMILY_SHA256 = 0,
    NIRAPOD_SHA2_FAMILY_SHA512 = 1,
    NIRAPOD_SHA2_FAMILY_X8 = 2,
    NIRAPOD_SHA2_FAMILY_X4 = 3
} nirapod_sha2_family;

#define NIRAPOD_SHA2_FAMILIES 4

/*
 * One compiled unit (Makefile, "Units"). needs[f] is the set of CPU
 * features that the code of family f in this unit executes; it is what
 * dispatch.c and the testing entry points require of the CPU before they
 * run that family, and what clear.c is told after the call. A unit's
 * other families may need nothing: the shani unit's SHA-512 code is the
 * portable kernel. Records are const data.
 */
typedef struct nirapod_sha2_unit {
    const char *name;
    unsigned needs[NIRAPOD_SHA2_FAMILIES];

    nirapod_sha2_jz_hash sha224, sha256, sha384, sha512, sha512_224, sha512_256;
    nirapod_sha2_jz_init sha224_init, sha256_init, sha384_init, sha512_init,
                         sha512_224_init, sha512_256_init;
    nirapod_sha2_jz_update sha224_update, sha256_update, sha384_update, sha512_update,
                           sha512_224_update, sha512_256_update;
    nirapod_sha2_jz_final sha224_final, sha256_final, sha384_final, sha512_final,
                          sha512_224_final, sha512_256_final;
    nirapod_sha2_jz_hmac hmac_sha256, hmac_sha512;
    nirapod_sha2_jz_hmac_init hmac_sha256_init, hmac_sha512_init;
    nirapod_sha2_jz_update hmac_sha256_update, hmac_sha512_update;
    nirapod_sha2_jz_final hmac_sha256_final, hmac_sha512_final;
    nirapod_sha2_jz_lanes sha256_x8;
    nirapod_sha2_jz_init sha256_x8_init;
    nirapod_sha2_jz_lanes_from sha256_x8_init_from;
    nirapod_sha2_jz_lanes_update sha256_x8_update;
    nirapod_sha2_jz_final sha256_x8_final;
    nirapod_sha2_jz_lanes sha512_x4;
    nirapod_sha2_jz_init sha512_x4_init;
    nirapod_sha2_jz_lanes_from sha512_x4_init_from;
    nirapod_sha2_jz_lanes_update sha512_x4_update;
    nirapod_sha2_jz_final sha512_x4_final;
} nirapod_sha2_unit;

/*
 * The units of this architecture, index 0 the portable unit, which runs
 * on every CPU of the architecture. units.c. The dispatch holds their
 * addresses in its candidate tables, so it needs no index or bounds check
 * per call.
 */
extern const nirapod_sha2_unit nirapod_sha2_units[];

/* The unit at index, NULL past the last. units.c. */
const nirapod_sha2_unit *nirapod_sha2_unit_at(size_t index);

/*
 * The NIRAPOD_SHA2_CPU_* features of the running CPU, read from the CPU
 * or the operating system on the first call and kept in one write-once
 * word (dispatch.c, "Feature cache"). The usual path is the load, the
 * test and the mask below; the read itself is out of line.
 */
#define NIRAPOD_SHA2_FEATURES_VALID 0x80000000u

extern unsigned nirapod_sha2_features_cache;

unsigned nirapod_sha2_read_cpu_features(void);

static inline unsigned nirapod_sha2_cpu_features(void)
{
    unsigned f = __atomic_load_n(&nirapod_sha2_features_cache, __ATOMIC_RELAXED);

    if ((f & NIRAPOD_SHA2_FEATURES_VALID) == 0) {
        f = nirapod_sha2_read_cpu_features() | NIRAPOD_SHA2_FEATURES_VALID;
        __atomic_store_n(&nirapod_sha2_features_cache, f, __ATOMIC_RELAXED);
    }
    return f & ~NIRAPOD_SHA2_FEATURES_VALID;
}

/*
 * The unit that family f runs on a CPU with features cpu. With gated = 1
 * only the units admitted to the default dispatch are candidates
 * (dispatch.c, "Default dispatch"); with gated = 0 every unit is, which
 * is the selection the library will make once all gates have passed.
 * Never NULL for a valid family. dispatch.c.
 */
const nirapod_sha2_unit *nirapod_sha2_select_for(nirapod_sha2_family f, unsigned cpu, int gated);

/* The unit the public functions use for family f on this CPU. dispatch.c. */
const nirapod_sha2_unit *nirapod_sha2_select(nirapod_sha2_family f);

/*
 * Data-independent timing around each Jasmin call. enter returns a token
 * holding the previous mode; leave restores it. On targets without such a
 * mode both do nothing. timing.c.
 */
uint64_t nirapod_sha2_timing_enter(void);
void nirapod_sha2_timing_leave(uint64_t token);

/*
 * Zero the registers the platform ABI lets a callee leave changed, after
 * a Jasmin export. used_features is the needs[] entry of the family that
 * ran; on x86-64 the function also reads the CPU's AVX-512 bits itself.
 * clear.c.
 */
void nirapod_sha2_clear_registers(unsigned used_features);

/*
 * The operations of api.c on an explicit unit and family. They check the
 * arguments as nirapod_sha2.h says, in its order, then run the export
 * with the timing mode set and clear the registers after it. The public
 * functions pass nirapod_sha2_select(f); capi/testing passes the unit it
 * was asked for. u must be non-NULL. api.c.
 *
 *     out_len, ctx_len  the digest and context sizes of the function
 *     limit             the largest message length plus one: 2^61, or
 *                       2^61 - B for an HMAC message
 *     ways              the lanes of a multi-way form, 8 or 4: in is a table
 *                       of that many pointers to len bytes each
 */
int nirapod_sha2_run_hash(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_hash op,
                          uint8_t *out, size_t out_len, const uint8_t *in, size_t len);
int nirapod_sha2_run_init(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_init op, void *ctx);
int nirapod_sha2_run_update(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                            nirapod_sha2_jz_update op, void *ctx, size_t ctx_len,
                            const uint8_t *in, size_t len);
int nirapod_sha2_run_final(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                           nirapod_sha2_jz_final op, void *ctx, size_t ctx_len,
                           uint8_t *out, size_t out_len);
int nirapod_sha2_run_hmac(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                          nirapod_sha2_jz_hmac op, uint64_t limit,
                          uint8_t *out, size_t out_len,
                          const uint8_t *key, size_t key_len,
                          const uint8_t *msg, size_t msg_len);
int nirapod_sha2_run_hmac_init(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                               nirapod_sha2_jz_hmac_init op, void *ctx, size_t ctx_len,
                               const uint8_t *key, size_t key_len);
int nirapod_sha2_run_lanes(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                           nirapod_sha2_jz_lanes op, size_t ways,
                           uint8_t *out, size_t out_len,
                           const uint8_t *const *in, size_t len);
int nirapod_sha2_run_lanes_from(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                                nirapod_sha2_jz_lanes_from op, void *ctx, size_t ctx_len,
                                const void *src, size_t src_len);
int nirapod_sha2_run_lanes_update(const nirapod_sha2_unit *u, nirapod_sha2_family f,
                                  nirapod_sha2_jz_lanes_update op, size_t ways,
                                  void *ctx, size_t ctx_len,
                                  const uint8_t *const *in, size_t len);

#endif /* NIRAPOD_SHA2_INTERNAL_H */
