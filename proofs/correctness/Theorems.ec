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
 * sha256_state, sha512_state, sha256_ctx and sha512_ctx below), and each
 * description is proved equal to the one the proofs use.
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
from Jasmin require import JWord JUtils JMemory.
require import BArray28 BArray32 BArray48 BArray64 BArray112 BArray128 BArray144 BArray208 BArray272.
require import SBArray112_32 SBArray112_64 SBArray144_112 SBArray208_64 SBArray208_128 SBArray272_208.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 FIPS198_HMAC.
require JWordList.
require StreamSpec State K256 K512 SHA256_Stream SHA512_Stream HMAC_SHA256 HMAC_SHA512 Ctx256 Ctx512 CtxHmac256 CtxHmac512.

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
