(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Theorems.ec
 * ===========
 *
 * The theorems a consumer of this library cites, stated once with their
 * preconditions and proved here from the theorems of correctness/. Each
 * is checked against the extracted model of one architecture's portable
 * kernel, aarch64/portable or x86_64/portable, so the same file is
 * checked twice, once per model.
 *
 * The statements are the ones proved today, one for every theorem the
 * correctness proofs claim: the portable compression kernel (its round
 * function, the array form, and one and n blocks from memory), the
 * streaming absorb and finalize, the one-shot function of each of the six
 * hashes, and the two HMAC steps with the FIPS 198-1 value for a key of at
 * most one block.
 *
 * What the caller provides.
 *
 *   - A pointer p and a length l in bytes, with the memory at p holding
 *     l readable bytes for the duration of the call. Where the procedure
 *     advances p past the last byte it reads the bound is strict,
 *     W64.to_uint p + W64.to_uint l < W64.modulus; the one-block entries
 *     state W64.to_uint p + 64 <= W64.modulus (SHA-512: 128) for the
 *     block they read. Absorb also requires size m + W64.to_uint l <
 *     W64.modulus, because it adds l to the absorbed byte count.
 *   - A message or stream below 2^61 bytes wherever the padding writes
 *     the bit length into a 64-bit field: the one-shot entries, finalize
 *     and the HMAC finalize step. The bound keeps 8 |m| below 2^64, as
 *     FIPS 180-4 section 5.1.1 requires.
 *   - An output array of the full digest size: 32 bytes for the SHA-256
 *     procedures and HMAC-SHA-256, 64 for the SHA-512 procedures and
 *     HMAC-SHA-512. A truncated function returns the full array; its
 *     statement fixes only the first 28, 48, 28 or 32 bytes as the
 *     digest.
 *   - Input and output buffers that do not overlap. The model reads the
 *     input through Glob.mem and writes the output array; no statement
 *     covers overlapping buffers.
 *   - For a stream call, a state (h, buf, total) satisfying stream256
 *     (stream512) for the bytes absorbed so far: total = |m|, h the
 *     chaining value after the complete blocks of m, and the first
 *     |m| mod 64 (mod 128) cells of buf holding the pending bytes. The
 *     prefix h0 is H0_256 or H0_224 (H0_512, H0_384, H0_512_224,
 *     H0_512_256) for the one-shot functions, and any chaining value the
 *     caller can justify otherwise.
 *   - For HMAC, the key block K0 of exactly one block, formed by the
 *     caller: K padded with zeros to 64 (128) bytes. hmac_sha256_blocks
 *     and hmac_sha512_blocks give the FIPS 198-1 value the three steps
 *     compute for |K| <= 64 (128).
 *
 * The misspeculation flag. Every procedure takes ms and returns it. A
 * consumer that relies on speculative constant time passes the flag from
 * #init_msf, protects the pointers and lengths it passes (#protect and
 * #protect_ptr), and keeps a value it reloads from the stack transient,
 * as the library's exports do. The theorems below are functional: they
 * do not model speculation, and the constant-time properties of the code
 * are established by jasmin-ct and jasmin-ct --sct, not by this file.
 *
 * What is not here. The incremental context and digest procedures
 * (context.jinc, digest.jinc), HMAC over memory (hmac_mem.jinc), the key
 * block procedure _hmac_sha*_keyblock_mem, the multi-way kernels and the
 * replacement kernels (aarch64/scalar, aarch64/sha2, x86_64/shani,
 * x86_64/avx2) have no theorem. HMAC is stated for keys of at most one
 * block; a longer key, which FIPS 198-1 hashes before forming K0, is not
 * covered. The rounds procedures __sha256_rounds and __sha512_rounds are
 * internal to the kernels; their statements are here for completeness,
 * not as a call a consumer makes. The statements are about the Jasmin
 * procedures; the C wrapper is outside them. The proofs rest on EasyCrypt
 * and its provers, jasmin2ec and the extracted model, the word-helper
 * models in ArchWord, and the axioms the inventory lists;
 * proofs/README.md records the trusted base.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray32 BArray64 BArray128.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 FIPS180_SHA2_Blocks FIPS198_HMAC.
require JWordList.
require SHA256_Compress SHA256_Blocks SHA256_Stream.
require SHA512_Compress SHA512_Blocks SHA512_Stream.
require HMAC_SHA256 HMAC_SHA512.

(* ------------------------------------------------------------------ *)
(* The portable compression kernel, one block from an array           *)
(* ------------------------------------------------------------------ *)

(* The round function of the SHA-256 kernel on its working variables.
   It is internal to _sha256_compress and not an export. *)
lemma sha256_rounds_correct (h0 : W32.t list) (m : W32.t list) :
  hoare [M.__sha256_rounds :
           SHA256_Compress.hwords h = h0 /\ SHA256_Compress.mwords w = m ==>
           SHA256_Compress.hwords res = SHA256.compress h0 m].
proof. exact SHA256_Compress.sha256_rounds_correct. qed.

(* SHA-256 on one 64-byte block: the kernel contract of
   src/sha256_compress.jinc. *)
lemma sha256_compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           SHA256_Compress.hwords h = h0 /\ block = blk ==>
           SHA256_Compress.hwords res.`1
           = SHA256.compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))].
proof. exact SHA256_Compress.sha256_compress_correct. qed.

(* The same statement with termination. *)
lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           SHA256_Compress.hwords h = h0 /\ block = blk ==>
           SHA256_Compress.hwords res.`1
           = SHA256.compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. exact SHA256_Compress.sha256_compress_total. qed.

(* The round function of the SHA-512 kernel, likewise internal. *)
lemma sha512_rounds_correct (h0 : W64.t list) (m : W64.t list) :
  hoare [M.__sha512_rounds :
           SHA512_Compress.hwords h = h0 /\ SHA512_Compress.mwords w = m ==>
           SHA512_Compress.hwords res = SHA512.compress h0 m].
proof. exact SHA512_Compress.sha512_rounds_correct. qed.

(* SHA-512 on one 128-byte block: the kernel contract of
   src/sha512_compress.jinc. *)
lemma sha512_compress_correct (h0 : W64.t list) (blk : BArray128.t) :
  hoare [M._sha512_compress :
           SHA512_Compress.hwords h = h0 /\ block = blk ==>
           SHA512_Compress.hwords res.`1
           = SHA512.compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))].
proof. exact SHA512_Compress.sha512_compress_correct. qed.

(* The same statement with termination. *)
lemma sha512_compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           SHA512_Compress.hwords h = h0 /\ block = blk ==>
           SHA512_Compress.hwords res.`1
           = SHA512.compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))] = 1%r.
proof. exact SHA512_Compress.sha512_compress_total. qed.

(* ------------------------------------------------------------------ *)
(* Blocks from memory                                                 *)
(* ------------------------------------------------------------------ *)

(* One 64-byte block at p, with p + 64 <= 2^64. *)
lemma sha256_compress_one_total (h0 : W32.t list) (p0 : W64.t) :
  phoare [M._sha256_compress_one :
           SHA256_Compress.hwords h = h0 /\ p = p0 /\
           W64.to_uint p0 + 64 <= W64.modulus ==>
           SHA256_Compress.hwords res.`1
           = SHA256.compress h0
               (map be32 (chunk 4 (JWordList.memread Glob.mem (W64.to_uint p0) 64)))]
  = 1%r.
proof. exact SHA256_Blocks.sha256_compress_one_total. qed.

(* n blocks of 64 bytes at p, with p + 64 n < 2^64. *)
lemma sha256_compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           SHA256_Compress.hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           SHA256_Compress.hwords res.`1
           = foldl SHA256.compress h0
               (SHA256.parse
                 (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. exact SHA256_Blocks.sha256_compress_blocks_total. qed.

(* One 128-byte block at p, with p + 128 <= 2^64. *)
lemma sha512_compress_one_total (h0 : W64.t list) (p0 : W64.t) :
  phoare [M._sha512_compress_one :
           SHA512_Compress.hwords h = h0 /\ p = p0 /\
           W64.to_uint p0 + 128 <= W64.modulus ==>
           SHA512_Compress.hwords res.`1
           = SHA512.compress h0
               (map be64 (chunk 8 (JWordList.memread Glob.mem (W64.to_uint p0) 128)))]
  = 1%r.
proof. exact SHA512_Blocks.sha512_compress_one_total. qed.

(* n blocks of 128 bytes at p, with p + 128 n < 2^64. *)
lemma sha512_compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           SHA512_Compress.hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           SHA512_Compress.hwords res.`1
           = foldl SHA512.compress h0
               (SHA512.parse
                 (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. exact SHA512_Blocks.sha512_compress_blocks_total. qed.

(* ------------------------------------------------------------------ *)
(* Streaming absorb and finalize                                      *)
(* ------------------------------------------------------------------ *)

(* l bytes at p, with p + l < 2^64 and |m| + l < 2^64, extend the stream
   m to m || mem. *)
lemma sha256_absorb_mem_total (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha256_absorb_mem :
           SHA256_Stream.stream256 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           size m + W64.to_uint l0 < W64.modulus ==>
           SHA256_Stream.stream256 h0
             (m ++ JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))
             res.`1 res.`2 res.`3]
  = 1%r.
proof. exact SHA256_Stream.sha256_absorb_mem_total. qed.

(* The FIPS 180-4 hash of the absorbed m, for |m| < 2^61. *)
lemma sha256_finalize_total (h0 : W32.t list) (m : bytes) :
  phoare [M._sha256_finalize :
           SHA256_Stream.stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = flatten (map w32_be (SHA256.hash h0 m))]
  = 1%r.
proof. exact SHA256_Stream.sha256_finalize_total. qed.

(* l bytes at p, with p + l < 2^64 and |m| + l < 2^64, extend the stream
   m to m || mem. *)
lemma sha512_absorb_mem_total (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha512_absorb_mem :
           SHA512_Stream.stream512 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           size m + W64.to_uint l0 < W64.modulus ==>
           SHA512_Stream.stream512 h0
             (m ++ JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))
             res.`1 res.`2 res.`3]
  = 1%r.
proof. exact SHA512_Stream.sha512_absorb_mem_total. qed.

(* The FIPS 180-4 hash of the absorbed m, for |m| < 2^61. *)
lemma sha512_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_finalize :
           SHA512_Stream.stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray64.to_list res.`1 = flatten (map w64_be (SHA512.hash h0 m))]
  = 1%r.
proof. exact SHA512_Stream.sha512_finalize_total. qed.

(* ------------------------------------------------------------------ *)
(* One-shot functions of a memory buffer                              *)
(* ------------------------------------------------------------------ *)

(* l bytes at p, with p + l < 2^64 and l < 2^61. *)
lemma sha256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha256_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = SHA256.sha256 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA256_Stream.sha256_mem_total. qed.

(* The first 28 output bytes are SHA-224. *)
lemma sha224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha224_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           take 28 (BArray32.to_list res.`1)
           = SHA256.sha224 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA256_Stream.sha224_mem_total. qed.

lemma sha512_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = SHA512.sha512 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA512_Stream.sha512_mem_total. qed.

(* The first 48 output bytes are SHA-384. *)
lemma sha384_mem_total (p0 l0 : W64.t) :
  phoare [M._sha384_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           take 48 (BArray64.to_list res.`1)
           = SHA512.sha384 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA512_Stream.sha384_mem_total. qed.

(* The first 28 output bytes are SHA-512/224. *)
lemma sha512_224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_224_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           take 28 (BArray64.to_list res.`1)
           = SHA512.sha512_224 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA512_Stream.sha512_224_mem_total. qed.

(* The first 32 output bytes are SHA-512/256. *)
lemma sha512_256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_256_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           W64.to_uint l0 < 2^61 ==>
           take 32 (BArray64.to_list res.`1)
           = SHA512.sha512_256 (JWordList.memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact SHA512_Stream.sha512_256_mem_total. qed.

(* ------------------------------------------------------------------ *)
(* HMAC for a key of at most one block                                *)
(* ------------------------------------------------------------------ *)

(* FIPS 198-1 with K0 = K || zeros, for |K| <= 64: the value the three
   HMAC-SHA-256 steps compute. *)
lemma hmac_sha256_blocks (k text : bytes) : size k <= 64 =>
  hmac_sha256 k text
  = SHA256.sha256 (xorb (k ++ zeros (64 - size k)) (opad 64)
                  ++ SHA256.sha256 (xorb (k ++ zeros (64 - size k)) (ipad 64) ++ text)).
proof. exact HMAC_SHA256.hmac_sha256_blocks. qed.

(* FIPS 198-1 steps 4, 5, 7 and 8 from the caller's K0 of 64 bytes:
   the chaining values after K0 xor ipad and K0 xor opad. *)
lemma hmac_sha256_init_total (K : BArray64.t) :
  phoare [M.__hmac_sha256_init :
           k0 = K ==>
           SHA256_Compress.hwords res.`1
           = SHA256.compress SHA256.H0_256
               (words256 (xorb (BArray64.to_list K) (ipad 64))) /\
           SHA256_Compress.hwords res.`2
           = SHA256.compress SHA256.H0_256
               (words256 (xorb (BArray64.to_list K) (opad 64)))]
  = 1%r.
proof. exact HMAC_SHA256.hmac_sha256_init_total. qed.

(* FIPS 198-1 step 9: the inner digest, then the outer hash of
   ob || inner, for a 64-byte ob and |ib| + |text| < 2^61. *)
lemma hmac_sha256_finalize_total (ib ob text : bytes) : size ob = 64 =>
  phoare [M.__hmac_sha256_finalize :
           SHA256_Stream.stream256 SHA256.H0_256 (ib ++ text) inner buf total /\
           SHA256_Compress.hwords outer
             = SHA256.compress SHA256.H0_256 (words256 ob) /\
           size (ib ++ text) < 2^61 ==>
           BArray32.to_list res.`1 = SHA256.sha256 (ob ++ SHA256.sha256 (ib ++ text))]
  = 1%r.
proof. exact HMAC_SHA256.hmac_sha256_finalize_total. qed.

(* FIPS 198-1 with K0 = K || zeros, for |K| <= 128. *)
lemma hmac_sha512_blocks (k text : bytes) : size k <= 128 =>
  hmac_sha512 k text
  = SHA512.sha512 (xorb (k ++ zeros (128 - size k)) (opad 128)
                  ++ SHA512.sha512 (xorb (k ++ zeros (128 - size k)) (ipad 128) ++ text)).
proof. exact HMAC_SHA512.hmac_sha512_blocks. qed.

(* FIPS 198-1 steps 4, 5, 7 and 8 from the caller's K0 of 128 bytes. *)
lemma hmac_sha512_init_total (K : BArray128.t) :
  phoare [M.__hmac_sha512_init :
           k0 = K ==>
           SHA512_Compress.hwords res.`1
           = SHA512.compress SHA512.H0_512
               (words512 (xorb (BArray128.to_list K) (ipad 128))) /\
           SHA512_Compress.hwords res.`2
           = SHA512.compress SHA512.H0_512
               (words512 (xorb (BArray128.to_list K) (opad 128)))]
  = 1%r.
proof. exact HMAC_SHA512.hmac_sha512_init_total. qed.

(* FIPS 198-1 step 9 for a 128-byte ob and |ib| + |text| < 2^61. *)
lemma hmac_sha512_finalize_total (ib ob text : bytes) : size ob = 128 =>
  phoare [M.__hmac_sha512_finalize :
           SHA512_Stream.stream512 SHA512.H0_512 (ib ++ text) inner buf total /\
           SHA512_Compress.hwords outer
             = SHA512.compress SHA512.H0_512 (words512 ob) /\
           size (ib ++ text) < 2^61 ==>
           BArray64.to_list res.`1 = SHA512.sha512 (ob ++ SHA512.sha512 (ib ++ text))]
  = 1%r.
proof. exact HMAC_SHA512.hmac_sha512_finalize_total. qed.
