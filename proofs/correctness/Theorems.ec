(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Theorems.ec
 * ===========
 *
 * The theorems a consumer of this library cites, stated once with their
 * preconditions and proved here from the theorems of correctness/. The
 * file is checked on the model of every unit: a statement here holds for
 * the kernel the unit builds in.
 *
 * Every statement is written with the specification's own operators only:
 * SHA256.* and SHA512.* of spec/FIPS180_SHA2.ec, hmac_key, hmac_sha256
 * and hmac_sha512 of spec/FIPS198_HMAC.ec, the byte lists of
 * spec/Bytes.ec, and memread of the crypto-specs JWordList theory for the
 * bytes of memory. Where a call carries state between calls (a stream or
 * a context), the state is described here in those same terms (the ops
 * sha256_state, sha512_state, sha256_ctx and sha512_ctx below, and for
 * the multi-way hashes sha256_x8_state, sha512_x4_state, sha256_x8_ctx
 * and sha512_x4_ctx), and each description is proved equal to the one the
 * proofs use.
 *
 * The array forms of src/*_ASIZE.jinc, which read an array of any size
 * in place of memory, are stated in the abstract theory ArrayTheorems
 * over that size; their input is written with take and drop of the
 * array's bytes.
 *
 * The last section states the exports of src/nirapod_sha2.jinc, the
 * procedures the C API calls, at their own arguments.
 *
 * What the caller provides.
 *
 *   - Memory. A pointer p and a length l in bytes, with l readable bytes
 *     at p for the duration of the call and W64.to_uint p +
 *     W64.to_uint l < W64.modulus. The procedures read memory and never
 *     write it.
 *   - Lengths. A message, or the total a stream or a context has absorbed,
 *     below 2^61 bytes, so that the bit length 8 |m| fits the 64-bit
 *     length field of FIPS 180-4 section 5.1.1 (the 128-bit field of
 *     section 5.1.2 is written with its high word zero). HMAC needs the
 *     key below 2^61 bytes and the text below 2^61 - 64 (SHA-512:
 *     2^61 - 128) bytes, the length of the inner hash input.
 *   - Outputs. An output array of the digest size of the function; the
 *     statement fixes all of its bytes.
 *   - Multi-way inputs. An array of eight (SHA-256) or four (SHA-512)
 *     pointers, each with the common length l readable and not wrapping
 *     the address space. Lane k's digest is bytes [32 k, 32 k + 32)
 *     (SHA-512: [64 k, 64 k + 64)) of the output.
 *   - The misspeculation flag. Every procedure takes ms and returns it.
 *     A consumer that relies on speculative constant time passes a flag
 *     from #init_msf, protects the pointers and lengths it passes
 *     (#protect, #protect_ptr) and keeps values reloaded from the stack
 *     transient, as the exports of src/nirapod_sha2.jinc do. The theorems
 *     below are functional and hold for any ms; the constant-time
 *     properties are those of jasmin-ct and jasmin-ct --sct.
 *   - The CPU. A unit builds in one kernel per function, chosen by its
 *     include roots; a kernel on special instructions (SHA-NI, AVX2,
 *     the ARMv8 SHA-2 extensions) must only run on a CPU that has them.
 *     The C layer checks this before it selects a unit's exports; a
 *     Jasmin consumer that includes a unit directly takes on that check.
 *     The portable units need no CPU feature.
 *
 * The statements are about the Jasmin procedures; the C wrapper is
 * outside them. proofs/README.md records the trusted base.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JByte_array.
require import BArray28 BArray32 BArray48 BArray64 BArray112 BArray128 BArray144 BArray208 BArray256.
require import BArray272 BArray512 BArray784.
require import SBArray112_32 SBArray112_64 SBArray144_112 SBArray208_64 SBArray208_128 SBArray272_208.
require import SBArray512_64 SBArray512_128 SBArray784_256 SBArray784_512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 FIPS198_HMAC.
require JWordList.
require StreamSpec State K256 K512 SHA256_Stream SHA512_Stream HMAC_SHA256 HMAC_SHA512 Ctx256 Ctx512 CtxHmac256 CtxHmac512.
require Lanes SHA256_X8 SHA512_X4 CtxX8 CtxX4 Exports ArrayForms StdOrder.

abbrev memread = JWordList.memread.

(* ------------------------------------------------------------------ *)
(* State in the specification's terms                                 *)

(* The chaining value stored in a u32[8] (u64[8]), H_0 first. *)
op words256 (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).
op words512 (h : BArray64.t) : W64.t list = map (BArray64.get64 h) (iota_ 0 8).

(* A stream state (h, buf, total) after m from the chaining value h0:
   total is |m|, h is compress folded over the complete blocks of m, and
   the bytes of m after them are the first cells of buf. *)
op sha256_state (h0 : W32.t list) (m : bytes) (h : BArray32.t) (buf : BArray64.t) (total : W64.t) =
     W64.to_uint total = size m
  /\ words256 h = foldl SHA256.compress h0 (SHA256.parse m)
  /\ forall i, 0 <= i < size m %% 64 => BArray64.get8 buf i = nth W8.zero m (64 * (size m %/ 64) + i).

op sha512_state (h0 : W64.t list) (m : bytes) (h : BArray64.t) (buf : BArray128.t) (total : W64.t) =
     W64.to_uint total = size m
  /\ words512 h = foldl SHA512.compress h0 (SHA512.parse m)
  /\ forall i, 0 <= i < size m %% 128 => BArray128.get8 buf i = nth W8.zero m (128 * (size m %/ 128) + i).

lemma words256E : words256 = State.h256.
proof. by []. qed.

lemma words512E : words512 = State.h512.
proof. by []. qed.

lemma sha256_stateE h0 m h buf total :
  sha256_state h0 m h buf total <=> SHA256_Stream.stream256 h0 m h buf total.
proof.
rewrite /sha256_state /SHA256_Stream.stream256 /SHA256_Stream.pending words256E.
rewrite StreamSpec.size_tail // /StreamSpec.tail.
have h0' : 0 <= 64 * (size m %/ 64) by smt(divz_ge0 size_ge0).
split => -[-> [-> hp]] /=; move=> i hi; [rewrite nth_drop 1,2:/# | rewrite -nth_drop 1,2:/#]; exact hp.
qed.

lemma sha512_stateE h0 m h buf total :
  sha512_state h0 m h buf total <=> SHA512_Stream.stream512 h0 m h buf total.
proof.
rewrite /sha512_state /SHA512_Stream.stream512 /SHA512_Stream.pend512 words512E.
rewrite StreamSpec.size_tail // /StreamSpec.tail.
have h0' : 0 <= 128 * (size m %/ 128) by smt(divz_ge0 size_ge0).
split => -[-> [-> hp]] /=; move=> i hi; [rewrite nth_drop 1,2:/# | rewrite -nth_drop 1,2:/#]; exact hp.
qed.

(* ------------------------------------------------------------------ *)
(* The kernel interface (one block, n blocks from memory)             *)

lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           words256 h = h0 /\ block = blk ==>
           words256 res.`1 = SHA256.compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. exact (K256.compress_total h0 blk). qed.

lemma sha256_compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           words256 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           words256 res.`1
           = foldl SHA256.compress h0 (SHA256.parse (memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. exact (K256.compress_blocks_total h0 p0 n0). qed.

lemma sha512_compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           words512 h = h0 /\ block = blk ==>
           words512 res.`1 = SHA512.compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))] = 1%r.
proof. exact (K512.compress_total h0 blk). qed.

lemma sha512_compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           words512 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           words512 res.`1
           = foldl SHA512.compress h0 (SHA512.parse (memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. exact (K512.compress_blocks_total h0 p0 n0). qed.

(* ------------------------------------------------------------------ *)
(* Streams                                                            *)

lemma sha256_absorb_mem_total (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha256_absorb_mem :
           sha256_state h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq (SHA256_Stream.sha256_absorb_mem_total h0 m p0 l0) => &m; smt(sha256_stateE). qed.

(* ------------------------------------------------------------------ *)
(* Initial values, streams and one-shot hashes                        *)

lemma sha256_init_total : phoare [M.__sha256_init : true ==> words256 res = SHA256.H0_256] = 1%r.
proof. by conseq (SHA256_Stream.sha256_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha224_init_total : phoare [M.__sha224_init : true ==> words256 res = SHA256.H0_224] = 1%r.
proof. by conseq (SHA256_Stream.sha224_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_init_total : phoare [M.__sha512_init : true ==> words512 res = SHA512.H0_512] = 1%r.
proof. by conseq (SHA512_Stream.sha512_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha384_init_total : phoare [M.__sha384_init : true ==> words512 res = SHA512.H0_384] = 1%r.
proof. by conseq (SHA512_Stream.sha384_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_224_init_total : phoare [M.__sha512_224_init : true ==> words512 res = SHA512.H0_512_224] = 1%r.
proof. by conseq (SHA512_Stream.sha512_224_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_256_init_total : phoare [M.__sha512_256_init : true ==> words512 res = SHA512.H0_512_256] = 1%r.
proof. by conseq (SHA512_Stream.sha512_256_init_total) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha256_finalize_total (h0 : W32.t list) (m : bytes) :
  phoare [M._sha256___sha256_finalize :
           sha256_state h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w32_be (SHA256.hash h0 m)))] = 1%r.
proof. by conseq (SHA256_Stream.sha256_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha224_finalize_total (h0 : W32.t list) (m : bytes) :
  phoare [M._sha224___sha256_finalize :
           sha256_state h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w32_be (SHA256.hash h0 m)))] = 1%r.
proof. by conseq (SHA256_Stream.sha224_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_absorb_mem_total (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha512_absorb_mem :
           sha512_state h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\
           size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq (SHA512_Stream.sha512_absorb_mem_total h0 m p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512___sha512_finalize :
           sha512_state h0 m h buf total /\ size m < 2^61 ==>
           BArray64.to_list res.`1 = take 64 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha384_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha384___sha512_finalize :
           sha512_state h0 m h buf total /\ size m < 2^61 ==>
           BArray48.to_list res.`1 = take 48 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq (SHA512_Stream.sha384_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_224_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_224___sha512_finalize :
           sha512_state h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_224_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_256_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_256___sha512_finalize :
           sha512_state h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_256_finalize_total h0 m) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha256_mem_from_total (h0 : W32.t list) (p0 l0 : W64.t) :
  phoare [M._sha256____sha256_mem_from :
           words256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA256_Stream.sha256_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha224_mem_from_total (h0 : W32.t list) (p0 l0 : W64.t) :
  phoare [M._sha224____sha256_mem_from :
           words256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA256_Stream.sha224_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512____sha512_mem_from :
           words512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = take 64 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha384_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha384____sha512_mem_from :
           words512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1
           = take 48 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA512_Stream.sha384_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_224_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512_224____sha512_mem_from :
           words512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_224_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha512_256_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512_256____sha512_mem_from :
           words512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)))))] = 1%r.
proof. by conseq (SHA512_Stream.sha512_256_mem_from_total h0 p0 l0) => &m; rewrite ?words256E ?words512E; smt(sha256_stateE sha512_stateE). qed.

lemma sha256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha256_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA256.sha256 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA256_Stream.sha256_mem_total p0 l0). qed.

lemma sha224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha224_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA256.sha224 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA256_Stream.sha224_mem_total p0 l0). qed.

lemma sha512_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1 = SHA512.sha512 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA512_Stream.sha512_mem_total p0 l0). qed.

lemma sha384_mem_total (p0 l0 : W64.t) :
  phoare [M._sha384_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1 = SHA512.sha384 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA512_Stream.sha384_mem_total p0 l0). qed.

lemma sha512_224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_224_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA512.sha512_224 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA512_Stream.sha512_224_mem_total p0 l0). qed.

lemma sha512_256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_256_mem :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA512.sha512_256 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))]
  = 1%r.
proof. exact (SHA512_Stream.sha512_256_mem_total p0 l0). qed.


(* ------------------------------------------------------------------ *)
(* HMAC over memory, any key length                                   *)

lemma hmac_sha256_keyblock_total (p0 l0 : W64.t) :
  phoare [M._hmac_sha256_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_key SHA256.sha256 64 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. exact (HMAC_SHA256.hmac_sha256_keyblock_total p0 l0). qed.

lemma hmac_sha512_keyblock_total (p0 l0 : W64.t) :
  phoare [M._hmac_sha512_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray128.to_list res.`1
           = hmac_key SHA512.sha512 128 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. exact (HMAC_SHA512.hmac_sha512_keyblock_total p0 l0). qed.

lemma hmac_sha256_mem_total (pk lk pm lm : W64.t) :
  phoare [M._hmac_sha256_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 /\
           W64.to_uint pm + W64.to_uint lm < W64.modulus /\ 64 + W64.to_uint lm < 2^61 ==>
           BArray32.to_list res.`1
           = hmac_sha256 (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk))
                         (memread Glob.mem (W64.to_uint pm) (W64.to_uint lm))] = 1%r.
proof. exact (HMAC_SHA256.hmac_sha256_mem_total pk lk pm lm). qed.

lemma hmac_sha512_mem_total (pk lk pm lm : W64.t) :
  phoare [M._hmac_sha512_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 /\
           W64.to_uint pm + W64.to_uint lm < W64.modulus /\ 128 + W64.to_uint lm < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_sha512 (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk))
                         (memread Glob.mem (W64.to_uint pm) (W64.to_uint lm))] = 1%r.
proof. exact (HMAC_SHA512.hmac_sha512_mem_total pk lk pm lm). qed.

(* ------------------------------------------------------------------ *)
(* Contexts                                                           *)

(* A SHA-224 or SHA-256 context of the function tagged tag, which has
   absorbed m from h0: bytes [0, 8) the tag, [8, 16) the total, [16, 48)
   the chaining value, [48, 112) the pending block. *)
op sha256_ctx (tag : W64.t) (h0 : W32.t list) (m : bytes) (c : BArray112.t) =
     BArray112.get64d c 0 = tag /\ size m < 2^61
  /\ sha256_state h0 m (SBArray112_32.get_sub32 c 4) (SBArray112_64.get_sub8 c 48) (BArray112.get64d c 8).

(* The same for the SHA-512 family over 208 bytes: [16, 80) the chaining
   value, [80, 208) the pending block. *)
op sha512_ctx (tag : W64.t) (h0 : W64.t list) (m : bytes) (c : BArray208.t) =
     BArray208.get64d c 0 = tag /\ size m < 2^61
  /\ sha512_state h0 m (SBArray208_64.get_sub64 c 2) (SBArray208_128.get_sub8 c 80) (BArray208.get64d c 8).

(* An HMAC-SHA-256 context of key k after text: an inner SHA-256 context
   of (K0 xor ipad) ++ text in bytes [0, 112), and the outer chaining value
   after K0 xor opad in [112, 144). *)
op hmac256_ctx (tag : W64.t) (k text : bytes) (c : BArray144.t) =
     sha256_ctx tag SHA256.H0_256 (xorb (hmac_key SHA256.sha256 64 k) (ipad 64) ++ text)
       (SBArray144_112.get_sub8 c 0)
  /\ map (fun i => BArray144.get32d c (112 + 4 * i)) (iota_ 0 8)
     = SHA256.compress SHA256.H0_256 (map be32 (chunk 4 (xorb (hmac_key SHA256.sha256 64 k) (opad 64)))).

op hmac512_ctx (tag : W64.t) (k text : bytes) (c : BArray272.t) =
     sha512_ctx tag SHA512.H0_512 (xorb (hmac_key SHA512.sha512 128 k) (ipad 128) ++ text)
       (SBArray272_208.get_sub8 c 0)
  /\ map (fun i => BArray272.get64d c (208 + 8 * i)) (iota_ 0 8)
     = SHA512.compress SHA512.H0_512 (map be64 (chunk 8 (xorb (hmac_key SHA512.sha512 128 k) (opad 128)))).

op hmac256_tag : W64.t = W64.of_int (1100357333870 + (7 `<<` 32)).
op hmac512_tag : W64.t = W64.of_int (1100357333870 + (8 `<<` 32)).

lemma sha256_ctxE tag h0 m c : sha256_ctx tag h0 m c <=> Ctx256.ctx256 tag h0 m c.
proof. by rewrite /sha256_ctx /Ctx256.ctx256 sha256_stateE. qed.

lemma sha512_ctxE tag h0 m c : sha512_ctx tag h0 m c <=> Ctx512.ctx512 tag h0 m c.
proof. by rewrite /sha512_ctx /Ctx512.ctx512 sha512_stateE. qed.

lemma hmac256_ctxE tag k text c : hmac256_ctx tag k text c <=> CtxHmac256.hctx256 tag k text c.
proof. by rewrite /hmac256_ctx /CtxHmac256.hctx256 sha256_ctxE /HMAC_SHA256.ib256 /HMAC_SHA256.ob256 /CtxHmac256.outer144. qed.

lemma hmac512_ctxE tag k text c : hmac512_ctx tag k text c <=> CtxHmac512.hctx512 tag k text c.
proof. by rewrite /hmac512_ctx /CtxHmac512.hctx512 sha512_ctxE /HMAC_SHA512.ib512 /HMAC_SHA512.ob512 /CtxHmac512.outer272. qed.

lemma hmac256_tagE : hmac256_tag = CtxHmac256.tag256h.
proof. by []. qed.

lemma hmac512_tagE : hmac512_tag = CtxHmac512.tag512h.
proof. by []. qed.

lemma sha256_ctx_init_total (h1 : BArray32.t) (t : W64.t) :
  phoare [M.__sha256_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> sha256_ctx t (words256 h1) [] res] = 1%r.
proof.
conseq (Ctx256.sha256_ctx_init_total h1 t) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha256_ctx_update_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (p0 l0 : W64.t) :
  phoare [M._sha256_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (sha256_ctx tag0 h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha256_ctx tag0 h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (Ctx256.sha256_ctx_update_total c0 tag0 h0 m p0 l0) => // &m _ r.
by rewrite !sha256_ctxE.
qed.

lemma sha224_ctx_final_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray28.t) :
  phoare [M._sha224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx256.sha224_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha256_ctx_final_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray32.t) :
  phoare [M._sha256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx256.sha256_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha512_ctx_init_total (h1 : BArray64.t) (t : W64.t) :
  phoare [M.__sha512_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> sha512_ctx t (words512 h1) [] res] = 1%r.
proof.
conseq (Ctx512.sha512_ctx_init_total h1 t) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha512_ctx_update_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (p0 l0 : W64.t) :
  phoare [M._sha512_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (sha512_ctx tag0 h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_ctx tag0 h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (Ctx512.sha512_ctx_update_total c0 tag0 h0 m p0 l0) => // &m _ r.
by rewrite !sha512_ctxE.
qed.

lemma sha512_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray64.t) :
  phoare [M._sha512_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray64.to_list res.`2 = take 64 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx512.sha512_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha384_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray48.t) :
  phoare [M._sha384_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray48.to_list res.`2 = take 48 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx512.sha384_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha512_224_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray28.t) :
  phoare [M._sha512_224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx512.sha512_224_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma sha512_256_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray32.t) :
  phoare [M._sha512_256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (Ctx512.sha512_256_ctx_final_total c0 tag0 h0 m d0) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma hmac_sha256_ctx_init_total (pk lk : W64.t) :
  phoare [M.__hmac_sha256_ctx_init :
           key = pk /\ keylen = lk /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 ==>
           hmac256_ctx hmac256_tag (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk)) [] res.`1] = 1%r.
proof.
conseq (CtxHmac256.hmac_sha256_ctx_init_total pk lk) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma hmac_sha256_ctx_final_total (c0 : BArray144.t) (o0 : BArray32.t) (k text : bytes) :
  phoare [M.__hmac_sha256_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> hmac256_tag =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hmac256_ctx hmac256_tag k text c0 =>
              res.`3 = W64.zero /\ BArray32.to_list res.`2 = hmac_sha256 k text /\
              forall i, 0 <= i < 144 => BArray144.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (CtxHmac256.hmac_sha256_ctx_final_total c0 o0 k text) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma hmac_sha512_ctx_init_total (pk lk : W64.t) :
  phoare [M.__hmac_sha512_ctx_init :
           key = pk /\ keylen = lk /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 ==>
           hmac512_ctx hmac512_tag (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk)) [] res.`1] = 1%r.
proof.
conseq (CtxHmac512.hmac_sha512_ctx_init_total pk lk) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

lemma hmac_sha512_ctx_final_total (c0 : BArray272.t) (o0 : BArray64.t) (k text : bytes) :
  phoare [M.__hmac_sha512_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> hmac512_tag =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hmac512_ctx hmac512_tag k text c0 =>
              res.`3 = W64.zero /\ BArray64.to_list res.`2 = hmac_sha512 k text /\
              forall i, 0 <= i < 272 => BArray272.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (CtxHmac512.hmac_sha512_ctx_final_total c0 o0 k text) => // &m _ r.
by rewrite ?words256E ?words512E ?hmac256_tagE ?hmac512_tagE ?hmac256_ctxE ?hmac512_ctxE ?sha256_ctxE ?sha512_ctxE.
qed.

(* ------------------------------------------------------------------ *)
(* The multi-way hashes                                               *)

(* Lane k of a lane-major chaining value: word j at cell 8 j + k (u32,
   eight lanes) or 4 j + k (u64, four lanes). *)
op lane256 (h : BArray256.t) (k : int) : W32.t list = map (fun j => BArray256.get32 h (8 * j + k)) (iota_ 0 8).
op lane512 (h : BArray256.t) (k : int) : W64.t list = map (fun j => BArray256.get64 h (4 * j + k)) (iota_ 0 8).

(* An 8-way SHA-256 state after the messages ms 0, ..., ms 7 of one common
   length from h0: total is that length; lane k of h is compress folded
   over the complete blocks of ms k; bytes [64 k, 64 k + 64) of buf begin
   with the bytes of ms k after them. *)
op sha256_x8_state (h0 : W32.t list) (ms : int -> bytes) (h : BArray256.t) (buf : BArray512.t) (total : W64.t) =
  forall k, 0 <= k < 8 =>
     W64.to_uint total = size (ms k)
  /\ lane256 h k = foldl SHA256.compress h0 (SHA256.parse (ms k))
  /\ forall i, 0 <= i < size (ms k) %% 64 =>
       BArray512.get8 buf (64 * k + i) = nth W8.zero (ms k) (64 * (size (ms k) %/ 64) + i).

(* The 4-way SHA-512 state: four lanes of 128-byte blocks. *)
op sha512_x4_state (h0 : W64.t list) (ms : int -> bytes) (h : BArray256.t) (buf : BArray512.t) (total : W64.t) =
  forall k, 0 <= k < 4 =>
     W64.to_uint total = size (ms k)
  /\ lane512 h k = foldl SHA512.compress h0 (SHA512.parse (ms k))
  /\ forall i, 0 <= i < size (ms k) %% 128 =>
       BArray512.get8 buf (128 * k + i) = nth W8.zero (ms k) (128 * (size (ms k) %/ 128) + i).

(* The tag __sha2_tag f writes into a context: f is 1 to 6 for SHA-224,
   SHA-256, SHA-384, SHA-512, SHA-512/224 and SHA-512/256, 7 and 8 for
   HMAC-SHA-256 and HMAC-SHA-512, 9 and 10 for the 8-way and 4-way
   contexts. *)
op sha2_tag (f : int) : W64.t = W64.of_int (1100357333870 + (f `<<` 32)).

(* A multi-way context of 784 bytes: [0, 8) the tag, [8, 16) the common
   length, [16, 272) the chaining values, [272, 784) the pending blocks. *)
op sha256_x8_ctx (h0 : W32.t list) (ms : int -> bytes) (c : BArray784.t) =
     BArray784.get64d c 0 = sha2_tag 9 /\ W64.to_uint (BArray784.get64d c 8) < 2^61
  /\ sha256_x8_state h0 ms (SBArray784_256.get_sub32 c 4) (SBArray784_512.get_sub8 c 272) (BArray784.get64d c 8).

op sha512_x4_ctx (h0 : W64.t list) (ms : int -> bytes) (c : BArray784.t) =
     BArray784.get64d c 0 = sha2_tag 10 /\ W64.to_uint (BArray784.get64d c 8) < 2^61
  /\ sha512_x4_state h0 ms (SBArray784_256.get_sub64 c 2) (SBArray784_512.get_sub8 c 272) (BArray784.get64d c 8).

lemma lane256E h k : lane256 h k = SHA256_X8.l8 h k.
proof. by rewrite /lane256 /Lanes.lane. qed.

lemma lane512E h k : lane512 h k = SHA512_X4.l4 h k.
proof. by rewrite /lane512 /Lanes.lane. qed.

lemma sha256_x8_stateE h0 ms h buf total :
  sha256_x8_state h0 ms h buf total <=> SHA256_X8.stream8 h0 ms h buf total.
proof.
rewrite /sha256_x8_state /SHA256_X8.stream8 /SHA256_X8.lanes8 /SHA256_Stream.pending.
split.
+ move=> H; split => k hk; have [ht [hh hp]] := H k hk => //.
  split; first by rewrite -lane256E.
  move=> i; rewrite StreamSpec.size_tail // => hi.
  rewrite SBArray512_64.get8_get_sub ifT 1:/# hp // /StreamSpec.tail nth_drop //.
  + smt(divz_ge0 size_ge0).
  smt().
move=> [hs hl] k hk; have [hh hp] := hl k hk.
split; first exact (hs k hk).
split; first by rewrite lane256E.
move=> i hi; have := hp i _; first by rewrite StreamSpec.size_tail.
rewrite SBArray512_64.get8_get_sub ifT 1:/# /StreamSpec.tail nth_drop //.
+ smt(divz_ge0 size_ge0).
smt().
qed.

lemma sha512_x4_stateE h0 ms h buf total :
  sha512_x4_state h0 ms h buf total <=> SHA512_X4.stream4 h0 ms h buf total.
proof.
rewrite /sha512_x4_state /SHA512_X4.stream4 /SHA512_X4.lanes4 /SHA512_Stream.pend512.
split.
+ move=> H; split => k hk; have [ht [hh hp]] := H k hk => //.
  split; first by rewrite -lane512E.
  move=> i; rewrite StreamSpec.size_tail // => hi.
  rewrite SBArray512_128.get8_get_sub ifT 1:/# hp // /StreamSpec.tail nth_drop //.
  + smt(divz_ge0 size_ge0).
  smt().
move=> [hs hl] k hk; have [hh hp] := hl k hk.
split; first exact (hs k hk).
split; first by rewrite lane512E.
move=> i hi; have := hp i _; first by rewrite StreamSpec.size_tail.
rewrite SBArray512_128.get8_get_sub ifT 1:/# /StreamSpec.tail nth_drop //.
+ smt(divz_ge0 size_ge0).
smt().
qed.

lemma sha256_x8_ctxE h0 ms c : sha256_x8_ctx h0 ms c <=> CtxX8.ctx8 h0 ms c.
proof. by rewrite /sha256_x8_ctx /CtxX8.ctx8 sha256_x8_stateE. qed.

lemma sha512_x4_ctxE h0 ms c : sha512_x4_ctx h0 ms c <=> CtxX4.ctx4 h0 ms c.
proof. by rewrite /sha512_x4_ctx /CtxX4.ctx4 sha512_x4_stateE. qed.

lemma sha2_tagE f : sha2_tag f = W64.of_int (1100357333870 + (f `<<` 32)).
proof. by []. qed.

lemma tag2E : sha2_tag 2 = CtxX8.tag256.
proof. by rewrite /sha2_tag /CtxX8.tag256. qed.

lemma tag9E : sha2_tag 9 = CtxX8.tagx8.
proof. by rewrite /sha2_tag /CtxX8.tagx8. qed.

lemma tag4E : sha2_tag 4 = CtxX4.tag512.
proof. by rewrite /sha2_tag /CtxX4.tag512. qed.

lemma tag10E : sha2_tag 10 = CtxX4.tagx4.
proof. by rewrite /sha2_tag /CtxX4.tagx4. qed.

(* 8-way SHA-256 *)

lemma sha256_x8_init_total :
  phoare [M.__sha256_x8_init : true ==> forall k, 0 <= k < 8 => lane256 res k = SHA256.H0_256] = 1%r.
proof.
conseq SHA256_X8.sha256_x8_init_total => // &m _ r.
by split => h k hk; [rewrite -lane256E | rewrite lane256E]; exact (h k hk).
qed.

lemma sha256_x8_from_total (hs0 : BArray32.t) (bs0 : BArray64.t) :
  phoare [M.__sha256_x8_from :
           hs = hs0 /\ bs = bs0 ==>
           (forall k, 0 <= k < 8 => lane256 res.`1 k = words256 hs0) /\
           (forall k, 0 <= k < 8 => SBArray512_64.get_sub8 res.`2 (64 * k) = bs0)] = 1%r.
proof.
conseq (SHA256_X8.sha256_x8_from_total hs0 bs0) => // &m _ r; rewrite words256E.
by split => -[h1 h2]; split => // k hk.
qed.

lemma sha256_x8_absorb_total (h0 : W32.t list) (ms0 : int -> bytes) (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M._sha256_x8_absorb_lanes :
           sha256_x8_state h0 ms0 h buf total /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 8 =>
              W64.to_uint (BArray64.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray64.get64 in0 k)) (W64.to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq (SHA256_X8.sha256_x8_absorb_total h0 ms0 in0 l0) => &m; smt(sha256_x8_stateE). qed.

lemma sha256_x8_finalize_total (h0 : W32.t list) (ms0 : int -> bytes) :
  phoare [M._sha256_x8_finalize :
           sha256_x8_state h0 ms0 h buf total /\ W64.to_uint total < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res.`1))
             = flatten (map w32_be (SHA256.hash h0 (ms0 k)))] = 1%r.
proof.
conseq (SHA256_X8.sha256_x8_finalize_total h0 ms0).
+ by move=> &m [hs ht]; rewrite -sha256_x8_stateE.
by move=> &m _ r; rewrite /Lanes.lane_block.
qed.

lemma sha256_x8_lanes_total (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M._sha256_x8_lanes :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 8 =>
              W64.to_uint (BArray64.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res.`1))
             = SHA256.sha256 (memread Glob.mem (W64.to_uint (BArray64.get64 in0 k)) (W64.to_uint l0))] = 1%r.
proof. exact (SHA256_X8.sha256_x8_lanes_total in0 l0). qed.

lemma sha256_x8_ctx_init_total :
  phoare [M.__sha256_x8_ctx_init : true ==> sha256_x8_ctx SHA256.H0_256 (fun _ => []) res] = 1%r.
proof. by conseq CtxX8.sha256_x8_ctx_init_total => &m _ r; rewrite sha256_x8_ctxE. qed.

lemma sha256_x8_ctx_from_total (c0 : BArray784.t) (s0 : BArray112.t) (h0 : W32.t list) (m : bytes) :
  phoare [M._sha256_x8_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray112.get64d s0 0 <> sha2_tag 2 => res.`2 = W64.one /\ res.`1 = c0) /\
           (sha256_ctx (sha2_tag 2) h0 m s0 => res.`2 = W64.zero /\ sha256_x8_ctx h0 (fun _ => m) res.`1)] = 1%r.
proof.
conseq (CtxX8.sha256_x8_ctx_from_total c0 s0 h0 m) => // &m _ r.
by rewrite sha256_x8_ctxE sha256_ctxE tag2E.
qed.

lemma sha256_x8_ctx_update_total (c0 : BArray784.t) (h0 : W32.t list) (ms0 : int -> bytes)
  (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M._sha256_x8_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 8 =>
              W64.to_uint (BArray64.get64 in0 q) + W64.to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> sha2_tag 9 => res.`2 = W64.one) /\
           (sha256_x8_ctx h0 ms0 c0 =>
              if size (ms0 0) + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha256_x8_ctx h0
                     (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray64.get64 in0 k)) (W64.to_uint l0))
                     res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (CtxX8.sha256_x8_ctx_update_total c0 h0 ms0 in0 l0) => // &m _ r.
by rewrite !sha256_x8_ctxE tag9E.
qed.

lemma sha256_x8_ctx_final_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W32.t list) (ms0 : int -> bytes) :
  phoare [M._sha256_x8_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> sha2_tag 9 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_x8_ctx h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 8 =>
                 take 32 (drop (32 * k) (BArray256.to_list res.`2))
                 = flatten (map w32_be (SHA256.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (CtxX8.sha256_x8_ctx_final_total c0 d0 h0 ms0) => // &m _ r.
by rewrite sha256_x8_ctxE tag9E /Lanes.lane_block.
qed.

(* 4-way SHA-512 *)

lemma sha512_x4_init_total :
  phoare [M.__sha512_x4_init : true ==> forall k, 0 <= k < 4 => lane512 res k = SHA512.H0_512] = 1%r.
proof.
conseq SHA512_X4.sha512_x4_init_total => // &m _ r.
by split => h k hk; [rewrite -lane512E | rewrite lane512E]; exact (h k hk).
qed.

lemma sha512_x4_from_total (hs0 : BArray64.t) (bs0 : BArray128.t) :
  phoare [M.__sha512_x4_from :
           hs = hs0 /\ bs = bs0 ==>
           (forall k, 0 <= k < 4 => lane512 res.`1 k = words512 hs0) /\
           (forall k, 0 <= k < 4 => SBArray512_128.get_sub8 res.`2 (128 * k) = bs0)] = 1%r.
proof.
conseq (SHA512_X4.sha512_x4_from_total hs0 bs0) => // &m _ r; rewrite words512E.
by split => -[h1 h2]; split => // k hk.
qed.

lemma sha512_x4_absorb_total (h0 : W64.t list) (ms0 : int -> bytes) (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_absorb_lanes :
           sha512_x4_state h0 ms0 h buf total /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 =>
              W64.to_uint (BArray32.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray32.get64 in0 k)) (W64.to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq (SHA512_X4.sha512_x4_absorb_total h0 ms0 in0 l0) => &m; smt(sha512_x4_stateE). qed.

lemma sha512_x4_finalize_total (h0 : W64.t list) (ms0 : int -> bytes) :
  phoare [M._sha512_x4_finalize :
           sha512_x4_state h0 ms0 h buf total /\ W64.to_uint total < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res.`1))
             = flatten (map w64_be (SHA512.hash h0 (ms0 k)))] = 1%r.
proof.
conseq (SHA512_X4.sha512_x4_finalize_total h0 ms0).
+ by move=> &m [hs ht]; rewrite -sha512_x4_stateE.
by move=> &m _ r; rewrite /Lanes.lane_block.
qed.

lemma sha512_x4_lanes_total (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_lanes :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 4 =>
              W64.to_uint (BArray32.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res.`1))
             = SHA512.sha512 (memread Glob.mem (W64.to_uint (BArray32.get64 in0 k)) (W64.to_uint l0))] = 1%r.
proof. exact (SHA512_X4.sha512_x4_lanes_total in0 l0). qed.

lemma sha512_x4_ctx_init_total :
  phoare [M.__sha512_x4_ctx_init : true ==> sha512_x4_ctx SHA512.H0_512 (fun _ => []) res] = 1%r.
proof. by conseq CtxX4.sha512_x4_ctx_init_total => &m _ r; rewrite sha512_x4_ctxE. qed.

lemma sha512_x4_ctx_from_total (c0 : BArray784.t) (s0 : BArray208.t) (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_x4_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray208.get64d s0 0 <> sha2_tag 4 => res.`2 = W64.one /\ res.`1 = c0) /\
           (sha512_ctx (sha2_tag 4) h0 m s0 => res.`2 = W64.zero /\ sha512_x4_ctx h0 (fun _ => m) res.`1)] = 1%r.
proof.
conseq (CtxX4.sha512_x4_ctx_from_total c0 s0 h0 m) => // &m _ r.
by rewrite sha512_x4_ctxE sha512_ctxE tag4E.
qed.

lemma sha512_x4_ctx_update_total (c0 : BArray784.t) (h0 : W64.t list) (ms0 : int -> bytes)
  (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 =>
              W64.to_uint (BArray32.get64 in0 q) + W64.to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> sha2_tag 10 => res.`2 = W64.one) /\
           (sha512_x4_ctx h0 ms0 c0 =>
              if size (ms0 0) + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_x4_ctx h0
                     (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray32.get64 in0 k)) (W64.to_uint l0))
                     res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (CtxX4.sha512_x4_ctx_update_total c0 h0 ms0 in0 l0) => // &m _ r.
by rewrite !sha512_x4_ctxE tag10E.
qed.

lemma sha512_x4_ctx_final_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W64.t list) (ms0 : int -> bytes) :
  phoare [M._sha512_x4_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> sha2_tag 10 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_x4_ctx h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 4 =>
                 take 64 (drop (64 * k) (BArray256.to_list res.`2))
                 = flatten (map w64_be (SHA512.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof.
conseq (CtxX4.sha512_x4_ctx_final_total c0 d0 h0 ms0) => // &m _ r.
by rewrite sha512_x4_ctxE tag10E /Lanes.lane_block.
qed.

(* ------------------------------------------------------------------ *)
(* The array forms                                                    *)

(* src/fill_ASIZE.jinc and the absorbs of src/sha256_ASIZE.jinc,
   src/sha512_ASIZE.jinc, src/sha256_x8_ASIZE.jinc and
   src/sha512_x4_ASIZE.jinc read their input from an array a of _ASIZE
   bytes, the size a namespace sets when it includes them. The theory
   below states them for any size asize with 0 < asize < 2^64, the side
   condition of a clone, over the procedures of ArrayForms.ArrayForm: the
   instance text with the size left abstract. An instance of size s is
   covered by cloning ArrayTheorems with asize <= s and the s-byte array
   theory, then proving its extracted procedures equivalent to those of
   AF.F, which proc; sim does on the text jasmin2ec extracts.
   correctness/units/<unit>/ArrayInst.ec does so, and states every
   theorem below on the extracted procedures themselves, for the sizes 1,
   64, 128 and 333 of the array test unit tests/array/array.jazz, on the
   portable units.

   What the caller provides: off + len at most asize (off + 7 stride +
   len for 8-way SHA-256, off + 3 stride + len for 4-way SHA-512) and a
   stream length below 2^64 after the call; the finalize theorems above
   then need it below 2^61. The bytes absorbed are take len (drop off
   (to_list a)); lane k of a multi-way form takes those from off + k
   stride on. Lanes may overlap, and stride 0 gives every lane the same
   bytes. *)

abstract theory ArrayTheorems.

op asize : int.

axiom asize_ok : 0 < asize < 18446744073709551616.

clone import ByteArray as BArrayA with op size <= asize.

clone ArrayForms.ArrayForm as AF with op asize <= asize, theory BArrayA <= BArrayA
proof asize_ok by exact asize_ok.

lemma fill64_array_total (b0 : BArray64.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  phoare [AF.F.fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 64 /\ W64.to_uint o0 + W64.to_uint n0 <= asize ==>
           forall i, 0 <= i < 64 =>
             BArray64.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArrayA.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray64.get8 b0 i] = 1%r.
proof. by conseq (AF.fill64_total b0 a0 d0 o0 n0) => // &m _ r; rewrite /AF.fill64a. qed.

lemma fill128_array_total (b0 : BArray128.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  phoare [AF.F.fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 128 /\ W64.to_uint o0 + W64.to_uint n0 <= asize ==>
           forall i, 0 <= i < 128 =>
             BArray128.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArrayA.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray128.get8 b0 i] = 1%r.
proof. by conseq (AF.fill128_total b0 a0 d0 o0 n0) => // &m _ r; rewrite /AF.fill128a. qed.

lemma abytesE (a0 : BArrayA.t) (o0 l0 : W64.t) : W64.to_uint o0 + W64.to_uint l0 <= asize =>
  AF.abytes a0 (W64.to_uint o0) (W64.to_uint l0)
  = take (W64.to_uint l0) (drop (W64.to_uint o0) (BArrayA.to_list a0)).
proof.
move=> h; have := W64.to_uint_cmp o0; have := W64.to_uint_cmp l0.
by move=> [hl _] [ho _]; rewrite AF.abytesE.
qed.

lemma sha256_absorb_array_total (h0 : W32.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [AF.F.sha256_absorb_array :
           sha256_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= asize /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArrayA.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq (AF.sha256_absorb_total h0 m a0 o0 l0).
+ by move=> &m [hs [-> [-> [-> [hpl hml]]]]]; rewrite -sha256_stateE.
by move=> &m [_ [_ [_ [_ [hpl _]]]]] r; rewrite sha256_stateE -abytesE.
qed.

lemma sha512_absorb_array_total (h0 : W64.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [AF.F.sha512_absorb_array :
           sha512_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= asize /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArrayA.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq (AF.sha512_absorb_total h0 m a0 o0 l0).
+ by move=> &m [hs [-> [-> [-> [hpl hml]]]]]; rewrite -sha512_stateE.
by move=> &m [_ [_ [_ [_ [hpl _]]]]] r; rewrite sha512_stateE -abytesE.
qed.

(* Lane k of 8 (4) takes the bytes at off + k stride. *)
lemma lane_abytes (a0 : BArrayA.t) (o0 s0 l0 : W64.t) q k :
  W64.to_uint o0 + (q - 1) * W64.to_uint s0 + W64.to_uint l0 <= asize => 0 <= k < q =>
  AF.abytes a0 (W64.to_uint o0 + k * W64.to_uint s0) (W64.to_uint l0)
  = take (W64.to_uint l0) (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)).
proof.
move=> h hk; have [ho _] := W64.to_uint_cmp o0; have [hs _] := W64.to_uint_cmp s0.
have [hl _] := W64.to_uint_cmp l0.
have hks : k * W64.to_uint s0 <= (q - 1) * W64.to_uint s0 by apply StdOrder.IntOrder.ler_wpmul2r; smt().
rewrite AF.abytesE //; smt().
qed.

lemma x8_state_ext h0 (ms ms' : int -> bytes) h buf total :
  (forall k, 0 <= k < 8 => ms k = ms' k) =>
  sha256_x8_state h0 ms h buf total => sha256_x8_state h0 ms' h buf total.
proof. by move=> he hs k hk; rewrite -(he k hk); exact (hs k hk). qed.

lemma x4_state_ext h0 (ms ms' : int -> bytes) h buf total :
  (forall k, 0 <= k < 4 => ms k = ms' k) =>
  sha512_x4_state h0 ms h buf total => sha512_x4_state h0 ms' h buf total.
proof. by move=> he hs k hk; rewrite -(he k hk); exact (hs k hk). qed.

lemma sha256_x8_absorb_array_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [AF.F.sha256_x8_absorb_array :
           sha256_x8_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= asize /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq (AF.sha256_x8_absorb_total h0 ms0 a0 o0 s0 l0).
+ by move=> &m [hs [-> [-> [-> [-> [hpl htl]]]]]]; rewrite -sha256_x8_stateE.
move=> &m [_ [_ [_ [_ [_ [hpl _]]]]]] r; rewrite -sha256_x8_stateE.
have he : forall k, 0 <= k < 8 =>
  AF.mxl a0 ms0 (W64.to_uint o0) (W64.to_uint s0) (W64.to_uint l0) k
  = ms0 k ++ take (W64.to_uint l0) (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)).
+ by move=> k hk; rewrite /AF.mxl /AF.mx /= (lane_abytes a0 o0 s0 l0 8 k).
by split; apply x8_state_ext => k hk; rewrite he.
qed.

lemma sha512_x4_absorb_array_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [AF.F.sha512_x4_absorb_array :
           sha512_x4_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= asize /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq (AF.sha512_x4_absorb_total h0 ms0 a0 o0 s0 l0).
+ by move=> &m [hs [-> [-> [-> [-> [hpl htl]]]]]]; rewrite -sha512_x4_stateE.
move=> &m [_ [_ [_ [_ [_ [hpl _]]]]]] r; rewrite -sha512_x4_stateE.
have he : forall k, 0 <= k < 4 =>
  AF.mxl a0 ms0 (W64.to_uint o0) (W64.to_uint s0) (W64.to_uint l0) k
  = ms0 k ++ take (W64.to_uint l0) (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)).
+ by move=> k hk; rewrite /AF.mxl /AF.mx /= (lane_abytes a0 o0 s0 l0 4 k).
by split; apply x4_state_ext => k hk; rewrite he.
qed.

(* The one-shot hashes of a slice, as tests/array/array.jazz composes
   them: the initial hash value, the absorb from the array, finalize. *)
lemma sha256_total (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [AF.F.sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= asize /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res
           = SHA256.sha256 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArrayA.to_list a0)))] = 1%r.
proof.
conseq (AF.sha256_total a0 o0 l0) => // &m [_ [_ [_ [hpl _]]]] r.
by rewrite abytesE.
qed.

lemma sha512_total (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [AF.F.sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= asize /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res
           = SHA512.sha512 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArrayA.to_list a0)))] = 1%r.
proof.
conseq (AF.sha512_total a0 o0 l0) => // &m [_ [_ [_ [hpl _]]]] r.
by rewrite abytesE.
qed.

lemma sha256_x8_total (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [AF.F.sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= asize /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)))] = 1%r.
proof.
conseq (AF.sha256_x8_total a0 o0 s0 l0) => // &m [_ [_ [_ [_ [hpl _]]]]] r.
by split => h k hk; have := h k hk; rewrite /Lanes.lane_block (lane_abytes a0 o0 s0 l0 8 k).
qed.

lemma sha512_x4_total (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [AF.F.sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= asize /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArrayA.to_list a0)))] = 1%r.
proof.
conseq (AF.sha512_x4_total a0 o0 s0 l0) => // &m [_ [_ [_ [_ [hpl _]]]]] r.
by split => h k hk; have := h k hk; rewrite /Lanes.lane_block (lane_abytes a0 o0 s0 l0 4 k).
qed.

end ArrayTheorems.

(* ------------------------------------------------------------------ *)
(* The exports of src/nirapod_sha2.jinc                               *)

(* Each export starts the misspeculation flag with #init_msf and makes
   one call to a layer above (two for the initialising ones: the initial
   hash value, then the fresh context). The statements below are those of
   the layers at the export's own arguments; an export of the C API maps
   one to one onto these. Status codes: 0 success, 1 a context of another
   function (or an uninitialised one), 2 a total length that would reach
   2^61 bytes. *)
lemma sha224_export_total (p0 l0 : W64.t) :
  phoare [M.sha224 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res = SHA256.sha224 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha224_mem_total p0 l0); auto. qed.
lemma sha256_export_total (p0 l0 : W64.t) :
  phoare [M.sha256 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res = SHA256.sha256 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha256_mem_total p0 l0); auto. qed.
lemma sha384_export_total (p0 l0 : W64.t) :
  phoare [M.sha384 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray48.to_list res = SHA512.sha384 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha384_mem_total p0 l0); auto. qed.
lemma sha512_export_total (p0 l0 : W64.t) :
  phoare [M.sha512 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res = SHA512.sha512 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha512_mem_total p0 l0); auto. qed.
lemma sha512_224_export_total (p0 l0 : W64.t) :
  phoare [M.sha512_224 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray28.to_list res = SHA512.sha512_224 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha512_224_mem_total p0 l0); auto. qed.
lemma sha512_256_export_total (p0 l0 : W64.t) :
  phoare [M.sha512_256 :
           in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res = SHA512.sha512_256 (memread Glob.mem (W64.to_uint p0) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha512_256_mem_total p0 l0); auto. qed.
lemma sha224_init_export_total :
  phoare [M.sha224_init : true ==> sha256_ctx (sha2_tag 1) SHA256.H0_224 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha256_ctx (sha2_tag 1) SHA256.H0_224 [] res) => //.
+ conseq (: _ ==> Ctx256.ctx256 (sha2_tag 1) SHA256.H0_224 [] res).
  + by move=> &m _ c; rewrite sha256_ctxE.
  proc; ecall (Ctx256.sha256_ctx_init_correct h (sha2_tag 1)).
  wp; ecall (Ctx256.sha2_tag_correct 1).
  by ecall (SHA256_Stream.sha224_init_correct); auto => /> h1 ->.
by proc; call Ctx256.ctx_init256_ll; wp; call Ctx256.sha2_tag_ll; call SHA256_Stream.sha224_init_ll; auto.
qed.

lemma sha224_update_export_total (c0 : BArray112.t) (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha224_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d c0 0 <> sha2_tag 1 => res.`2 = W64.one) /\
           (sha256_ctx (sha2_tag 1) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha256_ctx (sha2_tag 1) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha256_ctx_update_total c0 (sha2_tag 1) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha224_final_export_total (c0 : BArray112.t) (h0 : W32.t list) (m : bytes) (d0 : BArray28.t) :
  phoare [M.sha224_final :
           ctx = c0 /\ out = d0 ==>
           (BArray112.get64d c0 0 <> sha2_tag 1 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_ctx (sha2_tag 1) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha224_ctx_final_total c0 (sha2_tag 1) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma sha256_init_export_total :
  phoare [M.sha256_init : true ==> sha256_ctx (sha2_tag 2) SHA256.H0_256 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha256_ctx (sha2_tag 2) SHA256.H0_256 [] res) => //.
+ conseq (: _ ==> Ctx256.ctx256 (sha2_tag 2) SHA256.H0_256 [] res).
  + by move=> &m _ c; rewrite sha256_ctxE.
  proc; ecall (Ctx256.sha256_ctx_init_correct h (sha2_tag 2)).
  wp; ecall (Ctx256.sha2_tag_correct 2).
  by ecall (SHA256_Stream.sha256_init_correct); auto => /> h1 ->.
by proc; call Ctx256.ctx_init256_ll; wp; call Ctx256.sha2_tag_ll; call SHA256_Stream.sha256_init_ll; auto.
qed.

lemma sha256_update_export_total (c0 : BArray112.t) (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha256_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d c0 0 <> sha2_tag 2 => res.`2 = W64.one) /\
           (sha256_ctx (sha2_tag 2) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha256_ctx (sha2_tag 2) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha256_ctx_update_total c0 (sha2_tag 2) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha256_final_export_total (c0 : BArray112.t) (h0 : W32.t list) (m : bytes) (d0 : BArray32.t) :
  phoare [M.sha256_final :
           ctx = c0 /\ out = d0 ==>
           (BArray112.get64d c0 0 <> sha2_tag 2 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_ctx (sha2_tag 2) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha256_ctx_final_total c0 (sha2_tag 2) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma sha384_init_export_total :
  phoare [M.sha384_init : true ==> sha512_ctx (sha2_tag 3) SHA512.H0_384 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha512_ctx (sha2_tag 3) SHA512.H0_384 [] res) => //.
+ conseq (: _ ==> Ctx512.ctx512 (sha2_tag 3) SHA512.H0_384 [] res).
  + by move=> &m _ c; rewrite sha512_ctxE.
  proc; ecall (Ctx512.sha512_ctx_init_correct h (sha2_tag 3)).
  wp; ecall (Ctx256.sha2_tag_correct 3).
  by ecall (SHA512_Stream.sha384_init_correct); auto => /> h1 ->.
by proc; call Ctx512.ctx_init512_ll; wp; call Ctx256.sha2_tag_ll; call SHA512_Stream.sha384_init_ll; auto.
qed.

lemma sha384_update_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha384_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> sha2_tag 3 => res.`2 = W64.one) /\
           (sha512_ctx (sha2_tag 3) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_ctx (sha2_tag 3) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha512_ctx_update_total c0 (sha2_tag 3) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha384_final_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (d0 : BArray48.t) :
  phoare [M.sha384_final :
           ctx = c0 /\ out = d0 ==>
           (BArray208.get64d c0 0 <> sha2_tag 3 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx (sha2_tag 3) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray48.to_list res.`2 = take 48 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha384_ctx_final_total c0 (sha2_tag 3) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma sha512_init_export_total :
  phoare [M.sha512_init : true ==> sha512_ctx (sha2_tag 4) SHA512.H0_512 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha512_ctx (sha2_tag 4) SHA512.H0_512 [] res) => //.
+ conseq (: _ ==> Ctx512.ctx512 (sha2_tag 4) SHA512.H0_512 [] res).
  + by move=> &m _ c; rewrite sha512_ctxE.
  proc; ecall (Ctx512.sha512_ctx_init_correct h (sha2_tag 4)).
  wp; ecall (Ctx256.sha2_tag_correct 4).
  by ecall (SHA512_Stream.sha512_init_correct); auto => /> h1 ->.
by proc; call Ctx512.ctx_init512_ll; wp; call Ctx256.sha2_tag_ll; call SHA512_Stream.sha512_init_ll; auto.
qed.

lemma sha512_update_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha512_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> sha2_tag 4 => res.`2 = W64.one) /\
           (sha512_ctx (sha2_tag 4) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_ctx (sha2_tag 4) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha512_ctx_update_total c0 (sha2_tag 4) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha512_final_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (d0 : BArray64.t) :
  phoare [M.sha512_final :
           ctx = c0 /\ out = d0 ==>
           (BArray208.get64d c0 0 <> sha2_tag 4 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx (sha2_tag 4) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray64.to_list res.`2 = take 64 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha512_ctx_final_total c0 (sha2_tag 4) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma sha512_224_init_export_total :
  phoare [M.sha512_224_init : true ==> sha512_ctx (sha2_tag 5) SHA512.H0_512_224 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha512_ctx (sha2_tag 5) SHA512.H0_512_224 [] res) => //.
+ conseq (: _ ==> Ctx512.ctx512 (sha2_tag 5) SHA512.H0_512_224 [] res).
  + by move=> &m _ c; rewrite sha512_ctxE.
  proc; ecall (Ctx512.sha512_ctx_init_correct h (sha2_tag 5)).
  wp; ecall (Ctx256.sha2_tag_correct 5).
  by ecall (SHA512_Stream.sha512_224_init_correct); auto => /> h1 ->.
by proc; call Ctx512.ctx_init512_ll; wp; call Ctx256.sha2_tag_ll; call SHA512_Stream.sha512_224_init_ll; auto.
qed.

lemma sha512_224_update_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha512_224_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> sha2_tag 5 => res.`2 = W64.one) /\
           (sha512_ctx (sha2_tag 5) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_ctx (sha2_tag 5) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha512_ctx_update_total c0 (sha2_tag 5) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha512_224_final_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (d0 : BArray28.t) :
  phoare [M.sha512_224_final :
           ctx = c0 /\ out = d0 ==>
           (BArray208.get64d c0 0 <> sha2_tag 5 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx (sha2_tag 5) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha512_224_ctx_final_total c0 (sha2_tag 5) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma sha512_256_init_export_total :
  phoare [M.sha512_256_init : true ==> sha512_ctx (sha2_tag 6) SHA512.H0_512_256 [] res] = 1%r.
proof.
conseq (_ : true ==> true) (_ : true ==> sha512_ctx (sha2_tag 6) SHA512.H0_512_256 [] res) => //.
+ conseq (: _ ==> Ctx512.ctx512 (sha2_tag 6) SHA512.H0_512_256 [] res).
  + by move=> &m _ c; rewrite sha512_ctxE.
  proc; ecall (Ctx512.sha512_ctx_init_correct h (sha2_tag 6)).
  wp; ecall (Ctx256.sha2_tag_correct 6).
  by ecall (SHA512_Stream.sha512_256_init_correct); auto => /> h1 ->.
by proc; call Ctx512.ctx_init512_ll; wp; call Ctx256.sha2_tag_ll; call SHA512_Stream.sha512_256_init_ll; auto.
qed.

lemma sha512_256_update_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M.sha512_256_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> sha2_tag 6 => res.`2 = W64.one) /\
           (sha512_ctx (sha2_tag 6) h0 m c0 =>
              if size m + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_ctx (sha2_tag 6) h0 (m ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha512_ctx_update_total c0 (sha2_tag 6) h0 m p0 l0); inline M.__sha2_tag; auto. qed.

lemma sha512_256_final_export_total (c0 : BArray208.t) (h0 : W64.t list) (m : bytes) (d0 : BArray32.t) :
  phoare [M.sha512_256_final :
           ctx = c0 /\ out = d0 ==>
           (BArray208.get64d c0 0 <> sha2_tag 6 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_ctx (sha2_tag 6) h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha512_256_ctx_final_total c0 (sha2_tag 6) h0 m d0); inline M.__sha2_tag; auto. qed.
lemma hmac_sha256_export_total (pk lk pm lm : W64.t) :
  phoare [M.hmac_sha256 :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 /\
           W64.to_uint pm + W64.to_uint lm < W64.modulus /\ 64 + W64.to_uint lm < 2^61 ==>
           BArray32.to_list res
           = hmac_sha256 (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk))
                  (memread Glob.mem (W64.to_uint pm) (W64.to_uint lm))] = 1%r.
proof. by proc; call (hmac_sha256_mem_total pk lk pm lm); auto. qed.

lemma hmac_sha256_init_export_total (pk lk : W64.t) :
  phoare [M.hmac_sha256_init :
           key = pk /\ keylen = lk /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 ==>
           hmac256_ctx hmac256_tag (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk)) [] res] = 1%r.
proof. by proc; call (hmac_sha256_ctx_init_total pk lk); auto. qed.

lemma hmac_sha256_update_export_total (c0 : BArray144.t) (k text : bytes) (p0 l0 : W64.t) :
  phoare [M.hmac_sha256_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> hmac256_tag => res.`2 = W64.one) /\
           (hmac256_ctx hmac256_tag k text c0 =>
              if size text + W64.to_uint l0 < 2^61 - 64
              then res.`2 = W64.zero /\
                   hmac256_ctx hmac256_tag k (text ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (_ : W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==> true)
       (Exports.hmac_sha256_update_correct c0 k text p0 l0) => //.
+ by move=> &m _ r; rewrite !hmac256_ctxE hmac256_tagE.
proc; wp; call Ctx256.sha256_ctx_update_ll; call Ctx256.sha2_tag_ll; auto.
qed.

lemma hmac_sha256_final_export_total (c0 : BArray144.t) (o0 : BArray32.t) (k text : bytes) :
  phoare [M.hmac_sha256_final :
           ctx = c0 /\ out = o0 ==>
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> hmac256_tag =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hmac256_ctx hmac256_tag k text c0 =>
              res.`3 = W64.zero /\ BArray32.to_list res.`2 = hmac_sha256 k text /\
              forall i, 0 <= i < 144 => BArray144.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (hmac_sha256_ctx_final_total c0 o0 k text); auto. qed.
lemma hmac_sha512_export_total (pk lk pm lm : W64.t) :
  phoare [M.hmac_sha512 :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 /\
           W64.to_uint pm + W64.to_uint lm < W64.modulus /\ 128 + W64.to_uint lm < 2^61 ==>
           BArray64.to_list res
           = hmac_sha512 (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk))
                  (memread Glob.mem (W64.to_uint pm) (W64.to_uint lm))] = 1%r.
proof. by proc; call (hmac_sha512_mem_total pk lk pm lm); auto. qed.

lemma hmac_sha512_init_export_total (pk lk : W64.t) :
  phoare [M.hmac_sha512_init :
           key = pk /\ keylen = lk /\
           W64.to_uint pk + W64.to_uint lk < W64.modulus /\ W64.to_uint lk < 2^61 ==>
           hmac512_ctx hmac512_tag (memread Glob.mem (W64.to_uint pk) (W64.to_uint lk)) [] res] = 1%r.
proof. by proc; call (hmac_sha512_ctx_init_total pk lk); auto. qed.

lemma hmac_sha512_update_export_total (c0 : BArray272.t) (k text : bytes) (p0 l0 : W64.t) :
  phoare [M.hmac_sha512_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\
           W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> hmac512_tag => res.`2 = W64.one) /\
           (hmac512_ctx hmac512_tag k text c0 =>
              if size text + W64.to_uint l0 < 2^61 - 128
              then res.`2 = W64.zero /\
                   hmac512_ctx hmac512_tag k (text ++ memread Glob.mem (W64.to_uint p0) (W64.to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof.
conseq (_ : W64.to_uint p0 + W64.to_uint l0 < W64.modulus ==> true)
       (Exports.hmac_sha512_update_correct c0 k text p0 l0) => //.
+ by move=> &m _ r; rewrite !hmac512_ctxE hmac512_tagE.
proc; wp; call Ctx512.sha512_ctx_update_ll; call Ctx256.sha2_tag_ll; auto.
qed.

lemma hmac_sha512_final_export_total (c0 : BArray272.t) (o0 : BArray64.t) (k text : bytes) :
  phoare [M.hmac_sha512_final :
           ctx = c0 /\ out = o0 ==>
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> hmac512_tag =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hmac512_ctx hmac512_tag k text c0 =>
              res.`3 = W64.zero /\ BArray64.to_list res.`2 = hmac_sha512 k text /\
              forall i, 0 <= i < 272 => BArray272.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (hmac_sha512_ctx_final_total c0 o0 k text); auto. qed.
lemma sha256_x8_export_total (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M.sha256_x8 :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 8 =>
              W64.to_uint (BArray64.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (memread Glob.mem (W64.to_uint (BArray64.get64 in0 k)) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha256_x8_lanes_total in0 l0); auto. qed.

lemma sha256_x8_init_export_total :
  phoare [M.sha256_x8_init : true ==> sha256_x8_ctx SHA256.H0_256 (fun _ => []) res] = 1%r.
proof. by proc; call sha256_x8_ctx_init_total; auto. qed.

lemma sha256_x8_init_from_export_total (c0 : BArray784.t) (s0 : BArray112.t) (h0 : W32.t list) (m : bytes) :
  phoare [M.sha256_x8_init_from :
           ctx = c0 /\ src = s0 ==>
           (BArray112.get64d s0 0 <> sha2_tag 2 => res.`2 = W64.one /\ res.`1 = c0) /\
           (sha256_ctx (sha2_tag 2) h0 m s0 => res.`2 = W64.zero /\ sha256_x8_ctx h0 (fun _ => m) res.`1)] = 1%r.
proof. by proc; call (sha256_x8_ctx_from_total c0 s0 h0 m); auto. qed.

lemma sha256_x8_update_export_total (c0 : BArray784.t) (h0 : W32.t list) (ms0 : int -> bytes)
  (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M.sha256_x8_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 8 =>
              W64.to_uint (BArray64.get64 in0 q) + W64.to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> sha2_tag 9 => res.`2 = W64.one) /\
           (sha256_x8_ctx h0 ms0 c0 =>
              if size (ms0 0) + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha256_x8_ctx h0
                     (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray64.get64 in0 k)) (W64.to_uint l0))
                     res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha256_x8_ctx_update_total c0 h0 ms0 in0 l0); auto. qed.

lemma sha256_x8_final_export_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W32.t list) (ms0 : int -> bytes) :
  phoare [M.sha256_x8_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> sha2_tag 9 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha256_x8_ctx h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 8 =>
                 take 32 (drop (32 * k) (BArray256.to_list res.`2))
                 = flatten (map w32_be (SHA256.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha256_x8_ctx_final_total c0 d0 h0 ms0); auto. qed.
lemma sha512_x4_export_total (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M.sha512_x4 :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 4 =>
              W64.to_uint (BArray32.get64 in0 q) + W64.to_uint l0 < W64.modulus) /\
           W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (memread Glob.mem (W64.to_uint (BArray32.get64 in0 k)) (W64.to_uint l0))] = 1%r.
proof. by proc; call (sha512_x4_lanes_total in0 l0); auto. qed.

lemma sha512_x4_init_export_total :
  phoare [M.sha512_x4_init : true ==> sha512_x4_ctx SHA512.H0_512 (fun _ => []) res] = 1%r.
proof. by proc; call sha512_x4_ctx_init_total; auto. qed.

lemma sha512_x4_init_from_export_total (c0 : BArray784.t) (s0 : BArray208.t) (h0 : W64.t list) (m : bytes) :
  phoare [M.sha512_x4_init_from :
           ctx = c0 /\ src = s0 ==>
           (BArray208.get64d s0 0 <> sha2_tag 4 => res.`2 = W64.one /\ res.`1 = c0) /\
           (sha512_ctx (sha2_tag 4) h0 m s0 => res.`2 = W64.zero /\ sha512_x4_ctx h0 (fun _ => m) res.`1)] = 1%r.
proof. by proc; call (sha512_x4_ctx_from_total c0 s0 h0 m); auto. qed.

lemma sha512_x4_update_export_total (c0 : BArray784.t) (h0 : W64.t list) (ms0 : int -> bytes)
  (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M.sha512_x4_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 =>
              W64.to_uint (BArray32.get64 in0 q) + W64.to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> sha2_tag 10 => res.`2 = W64.one) /\
           (sha512_x4_ctx h0 ms0 c0 =>
              if size (ms0 0) + W64.to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   sha512_x4_ctx h0
                     (fun k => ms0 k ++ memread Glob.mem (W64.to_uint (BArray32.get64 in0 k)) (W64.to_uint l0))
                     res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by proc; call (sha512_x4_ctx_update_total c0 h0 ms0 in0 l0); auto. qed.

lemma sha512_x4_final_export_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W64.t list) (ms0 : int -> bytes) :
  phoare [M.sha512_x4_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> sha2_tag 10 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (sha512_x4_ctx h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 4 =>
                 take 64 (drop (64 * k) (BArray256.to_list res.`2))
                 = flatten (map w64_be (SHA512.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof. by proc; call (sha512_x4_ctx_final_total c0 d0 h0 ms0); auto. qed.
