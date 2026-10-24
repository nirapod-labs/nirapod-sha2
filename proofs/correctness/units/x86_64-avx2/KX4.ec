(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * KX4.ec
 * ======
 *
 * The four-way SHA-512 kernel of this unit as the shared correctness proofs see
 * it. The shared layers call a multi-way kernel only through _sha512_x4_compress and
 * _sha512_x4_compress_lanes, and use only the lemmas of this theory, under these
 * names, on every unit:
 *
 *     compress_correct, compress_ll, compress_total
 *         lane k of the result is compress of lane k of the state with
 *         block k of the block array;
 *     compress_lanes_correct, compress_lanes_ll, compress_lanes_total
 *         lane k absorbs the n blocks at in[k] + off.
 *
 * A lane is lane4 of lib/Lanes.ec over the interleaved state. Here the
 * kernel is the AVX2 one (src/x86_64/avx2/sha512_x4_compress.jinc), which
 * holds one lane in each 64-bit element of a 256-bit register, proved in
 * x86_64/avx2/SHA512_X4_Avx2.ec.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray32 BArray256 BArray512 NirapodSha2 FIPS180_SHA2 Lanes.
require JWordList SHA512_X4_Avx2.
import SHA512.

lemma compress_ll : islossless M._sha512_x4_compress.
proof. exact SHA512_X4_Avx2.sha512_x4_compress_ll. qed.

lemma compress_lanes_ll : islossless M._sha512_x4_compress_lanes.
proof. exact SHA512_X4_Avx2.sha512_x4_compress_lanes_ll. qed.

lemma compress_correct (h0 : BArray256.t) (blk : BArray512.t) :
  hoare [M._sha512_x4_compress :
           h4 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k = compress (lane4 (BArray256.get64 h0) k) (map be64 (chunk 8 (lane_block 128 (BArray512.to_list blk) k)))].
proof. exact (SHA512_X4_Avx2.sha512_x4_compress_correct h0 blk). qed.

lemma compress_total (h0 : BArray256.t) (blk : BArray512.t) :
  phoare [M._sha512_x4_compress :
           h4 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k = compress (lane4 (BArray256.get64 h0) k) (map be64 (chunk 8 (lane_block 128 (BArray512.to_list blk) k)))] = 1%r.
proof. exact (SHA512_X4_Avx2.sha512_x4_compress_total h0 blk). qed.

lemma sum_lt (a b c m : int) : 0 <= c => a + b + 128 * c < m => a + b < m.
proof. smt(). qed.

(* The AVX2 proof states lane k's input address as one word sum and its
   domain over that sum; with the sum below 2^64 it is the integer sum
   these statements use. *)
lemma pL_add (in0 : BArray32.t) (off0 n0 : W64.t) (k : int) :
  to_uint (BArray32.get64 in0 k) + to_uint off0 + 128 * to_uint n0 < W64.modulus =>
  SHA512_X4_Avx2.pL in0 off0 k = to_uint (BArray32.get64 in0 k) + to_uint off0.
proof.
move=> h; rewrite /SHA512_X4_Avx2.pL W64.to_uintD_small //.
by have [hn _] := W64.to_uint_cmp n0; exact (sum_lt _ _ _ _ hn h).
qed.

lemma compress_lanes_correct (h0 : BArray256.t) (in0 : BArray32.t) (off0 n0 : W64.t) :
  hoare [M._sha512_x4_compress_lanes :
           h4 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 4 =>
              to_uint (BArray32.get64 in0 q) + to_uint off0 + 128 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = foldl compress (lane4 (BArray256.get64 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray32.get64 in0 k) + to_uint off0)
                           (128 * to_uint n0)))].
proof.
conseq (SHA512_X4_Avx2.sha512_x4_compress_lanes_correct h0 in0 off0 n0).
+ move=> &m [#] 4!-> hd /=; rewrite /SHA512_X4_Avx2.ldom => k hk.
  by rewrite (pL_add _ _ n0 k (hd k hk)); exact (hd k hk).
move=> &m [#] _ _ _ _ hd r hr k hk; have := hr k hk.
by rewrite /SHA512_X4_Avx2Block.hl (pL_add _ _ n0 k (hd k hk)).
qed.

lemma compress_lanes_total (h0 : BArray256.t) (in0 : BArray32.t) (off0 n0 : W64.t) :
  phoare [M._sha512_x4_compress_lanes :
           h4 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 4 =>
              to_uint (BArray32.get64 in0 q) + to_uint off0 + 128 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = foldl compress (lane4 (BArray256.get64 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray32.get64 in0 k) + to_uint off0)
                           (128 * to_uint n0)))] = 1%r.
proof.
conseq (SHA512_X4_Avx2.sha512_x4_compress_lanes_total h0 in0 off0 n0).
+ move=> &m [#] 4!-> hd /=; rewrite /SHA512_X4_Avx2.ldom => k hk.
  by rewrite (pL_add _ _ n0 k (hd k hk)); exact (hd k hk).
move=> &m [#] _ _ _ _ hd r.
by split=> h k hk; have := h k hk; rewrite /SHA512_X4_Avx2Block.hl (pL_add _ _ n0 k (hd k hk)).
qed.
