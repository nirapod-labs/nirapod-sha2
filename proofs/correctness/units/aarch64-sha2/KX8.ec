(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * KX8.ec
 * ======
 *
 * The eight-way SHA-256 kernel of this unit as the shared correctness proofs see
 * it. The shared layers call a multi-way kernel only through _sha256_x8_compress and
 * _sha256_x8_compress_lanes, and use only the lemmas of this theory, under these
 * names, on every unit:
 *
 *     compress_correct, compress_ll, compress_total
 *         lane k of the result is compress of lane k of the state with
 *         block k of the block array;
 *     compress_lanes_correct, compress_lanes_ll, compress_lanes_total
 *         lane k absorbs the n blocks at in[k] + off.
 *
 * A lane is lane8 of lib/Lanes.ec over the interleaved state. Here the
 * kernel is the FEAT_SHA256 one (src/aarch64/sha2/sha256_x8_compress.jinc),
 * proven in correctness/aarch64/sha2/SHA256_A64Sha2X8.ec and
 * SHA256_A64Sha2X8Lanes.ec. The precondition on in[k] + off here, without
 * wrap-around, gives the one of those files.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray64 BArray256 BArray512 NirapodSha2 FIPS180_SHA2 Lanes.
require JWordList SHA256_A64Sha2X8 SHA256_A64Sha2X8Lanes.
import SHA256.

lemma compress_ll : islossless M._sha256_x8_compress.
proof. exact SHA256_A64Sha2X8.sha256_x8_compress_ll. qed.

lemma compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof. exact SHA256_A64Sha2X8Lanes.sha256_x8_compress_lanes_ll. qed.

lemma compress_correct (h0 : BArray256.t) (blk : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k = compress (lane8 (BArray256.get32 h0) k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))].
proof. exact (SHA256_A64Sha2X8.sha256_x8_compress_correct h0 blk). qed.

lemma compress_total (h0 : BArray256.t) (blk : BArray512.t) :
  phoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k = compress (lane8 (BArray256.get32 h0) k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))] = 1%r.
proof. exact (SHA256_A64Sha2X8.sha256_x8_compress_total h0 blk). qed.

lemma compress_lanes_correct (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0)
                           (64 * to_uint n0)))].
proof.
case: (forall q, 0 <= q < 8 =>
         to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) => hb.
+ have ha : forall k, 0 <= k < 8 =>
    to_uint (BArray64.get64 in0 k + off0) = to_uint (BArray64.get64 in0 k) + to_uint off0.
  + move=> k hk; rewrite W64.to_uintD_small //.
    by have := hb k hk; smt(W64.to_uint_cmp).
  have hbnd : SHA256_A64Sha2X8Lanes.bnd in0 off0 n0.
  + by move=> k hk; rewrite /addr ha // hb.
  conseq (SHA256_A64Sha2X8Lanes.sha256_x8_compress_lanes_correct h0 in0 off0 n0) => //.
  by move=> &m _ r h k hk; rewrite -ha // h.
by exfalso.
qed.

lemma compress_lanes_total (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0)
                           (64 * to_uint n0)))] = 1%r.
proof. by conseq compress_lanes_ll (compress_lanes_correct h0 in0 off0 n0). qed.
