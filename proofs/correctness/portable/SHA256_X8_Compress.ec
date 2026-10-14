(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_Compress.ec
 * =====================
 *
 * Functional correctness of the portable eight-way SHA-256 kernel
 * (src/sha256_x8_compress.jinc), lane by lane against FIPS 180-4 section
 * 6.2.2. The kernel keeps the eight chaining values interleaved in a
 * u32[64], H_j of lane k at index 8 j + k (lane8 of lib/Lanes.ec), and runs
 * the unit's single-way kernel once per lane: it gathers lane k into a
 * u32[8], compresses it, and scatters the result back. The proofs use the
 * single-way kernel only through K256, so this text holds on every unit
 * whose single-way SHA-256 kernel K256 states.
 *
 * Theorems (total correctness):
 *     x8_compress_total        every lane k is compressed with block k of
 *                              the 512-byte block array;
 *     x8_compress_lanes_total  every lane k absorbs the n blocks at
 *                              in[k] + off, for in[k] + off + 64 n < 2^64.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray32 BArray64 BArray256 BArray512 SBArray512_64.
require import NirapodSha2 FIPS180_SHA2 Lanes State.
require JWordList K256.
import SHA256.

abbrev l8 (h8 : BArray256.t) (k : int) : W32.t list = lane8 (BArray256.get32 h8) k.

(* Block k of the block array. *)
lemma sub_block (blk : BArray512.t) k : 0 <= k < 8 =>
  BArray64.to_list (SBArray512_64.get_sub8 blk (64 * k))
  = lane_block 64 (BArray512.to_list blk) k.
proof.
move=> hk; apply (eq_from_nth W8.zero).
+ by rewrite BArray64.size_to_list size_lane_block // 1:/# BArray512.size_to_list /#.
move=> i; rewrite BArray64.size_to_list => hi.
rewrite BArray64.get_to_list SBArray512_64.get8_get_sub hi /=.
by rewrite nth_lane_block // 1:/# BArray512.get_to_list.
qed.

(* Writing one index of lane k leaves every other lane as it was. *)
lemma l8_set (t : BArray256.t) j k w k' :
  0 <= j < 8 => 0 <= k < 8 => 0 <= k' < 8 => k' <> k =>
  l8 (BArray256.set32 t (8 * j + k) w) k' = l8 t k'.
proof.
move=> hj hk hk' hne; apply lane_eq => j' hj'.
rewrite /= BArray256.get_set32E 1,2:/# ifF //.
by apply/negP => heq; have := lane_inj 8 j k j' k' _ _ heq => /#.
qed.

(* The gather: h holds lane k. *)
lemma gather (h : BArray32.t) (t : BArray256.t) k :
  (forall j, 0 <= j < 8 => BArray32.get32 h j = BArray256.get32 t (8 * j + k)) =>
  h256 h = l8 t k.
proof.
move=> hj; apply (eq_from_nth W32.zero); first by rewrite size_h256 size_lane.
by move=> j; rewrite size_h256 => hj'; rewrite nth_h256 // nth_lane // hj.
qed.

(* The scatter: lane k holds h. *)
lemma scatter (h : BArray32.t) (t : BArray256.t) k :
  (forall j, 0 <= j < 8 => BArray256.get32 t (8 * j + k) = BArray32.get32 h j) =>
  l8 t k = h256 h.
proof. by move=> hj; rewrite (gather h t k) // => j hj'; rewrite hj. qed.

(* ------------------------------------------------------------------ *)
(* One block per lane                                                 *)

lemma x8_compress_correct (h0 : BArray256.t) (blk : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             l8 res.`1 k
             = compress (l8 h0 k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))].
proof.
proc.
while (0 <= k <= 8 /\ blocks = blk /\
       (forall k', 0 <= k' < k =>
          l8 h8 k' = compress (l8 h0 k') (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k')))) /\
       (forall k', k <= k' < 8 => l8 h8 k' = l8 h0 k')).
+ seq 2 : (0 <= k < 8 /\ blocks = blk /\
           (forall k', 0 <= k' < k =>
              l8 h8 k' = compress (l8 h0 k') (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k')))) /\
           (forall k', k <= k' < 8 => l8 h8 k' = l8 h0 k') /\
           h256 h = l8 h8 k).
  + while (0 <= k < 8 /\ 0 <= j <= 8 /\
           (forall j', 0 <= j' < j => BArray32.get32 h j' = BArray256.get32 h8 (8 * j' + k))).
    + auto => /> &hr hk0 hk8 hj0 hj8 hh hlt; split; first smt().
      move=> j' hj0' hj1'; rewrite BArray32.get_set32E 1,2:/#.
      by case: (j{hr} = j') => [<-|ne] //; apply hh => /#.
    auto => /> &hr hk0 _ hlo hhi hk8; split; first smt().
    move=> h1 j1 hn hj0 hj8 hh.
    by apply gather => j hj; apply hh => /#.
  seq 1 : (0 <= k < 8 /\ blocks = blk /\
           (forall k', 0 <= k' < k =>
              l8 h8 k' = compress (l8 h0 k') (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k')))) /\
           (forall k', k < k' < 8 => l8 h8 k' = l8 h0 k') /\
           h256 h = compress (l8 h0 k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))).
  + ecall (K256.compress_correct (h256 h) (SBArray512_64.get_sub8 blocks (64 * k))).
    auto => /> &hr hk0 hk8 hlo hhi hh r hr'.
    split; first by move=> k' hk1 hk2; apply hhi => /#.
    by rewrite hr' sub_block // hh hhi.
  wp; while (0 <= k < 8 /\ 0 <= j <= 8 /\ blocks = blk /\
             (forall k', 0 <= k' < k =>
                l8 h8 k' = compress (l8 h0 k') (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k')))) /\
             (forall k', k < k' < 8 => l8 h8 k' = l8 h0 k') /\
             h256 h = compress (l8 h0 k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k))) /\
             (forall j', 0 <= j' < j => BArray256.get32 h8 (8 * j' + k) = BArray32.get32 h j')).
  + auto => /> &hr hk0 hk8 hj0 hj8 hlo hhi hh hs hlt.
    do !split; 1,2: smt().
    + move=> k' hk1 hk2; rewrite l8_set; 1..4: smt().
      by apply hlo.
    + move=> k' hk1 hk2; rewrite l8_set; 1..4: smt().
      by apply hhi.
    move=> j' hj1 hj2; rewrite BArray256.get_set32E 1,2:/#.
    case: (j' = j{hr}) => [->|ne] /=; first done.
    rewrite ifF 1:/#; apply hs; smt().
  auto => /> &hr hk0 hk8 hlo hhi hh; rewrite /Jslh.SLH64.protect_ptr /=.
  split; first by split; [smt() | split; smt()].
  move=> h1 j1 hn hj0 hj8 _ hlo1 hhi1 hs.
  split; first smt().
  split.
  + move=> k' hk1 hk2; case: (k' = k{hr}) => [->|ne]; last by apply hlo1 => /#.
    by rewrite -hh; apply scatter => j hj; apply hs => /#.
  by move=> k' hk1 hk2; apply hhi1 => /#.
auto => />; split; first smt().
move=> h1 k1 hn hk0 hk8 hlo hhi k' hk1 hk2.
by apply hlo => /#.
qed.

lemma x8_compress_lanes_correct (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             l8 res.`1 k
             = foldl compress (l8 h0 k) (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0) (64 * to_uint n0)))].
proof.
proc.
while (0 <= k <= 8 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ (forall q, 0 <= q < 8 => to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) /\
       (forall k', 0 <= k' < k =>
          l8 h8 k' = foldl compress (l8 h0 k') (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k') + to_uint off0) (64 * to_uint n0)))) /\
       (forall k', k <= k' < 8 => l8 h8 k' = l8 h0 k')).
+ seq 2 : (0 <= k < 8 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ (forall q, 0 <= q < 8 => to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) /\
           (forall k', 0 <= k' < k =>
              l8 h8 k' = foldl compress (l8 h0 k') (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k') + to_uint off0) (64 * to_uint n0)))) /\
           (forall k', k <= k' < 8 => l8 h8 k' = l8 h0 k') /\
           h256 h = l8 h8 k).
  + while (0 <= k < 8 /\ 0 <= j <= 8 /\
           (forall j', 0 <= j' < j => BArray32.get32 h j' = BArray256.get32 h8 (8 * j' + k))).
    + auto => /> &hr hk0 hk8 hj0 hj8 hh hlt; split; first smt().
      move=> j' hj0' hj1'; rewrite BArray32.get_set32E 1,2:/#.
      by case: (j{hr} = j') => [<-|ne] //; apply hh => /#.
    auto => /> &hr hk0 _ hb hlo hhi hk8; split; first smt().
    move=> h1 j1 hn hj0 hj8 hh.
    by apply gather => j hj; apply hh => /#.
  seq 4 : (0 <= k < 8 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ (forall q, 0 <= q < 8 => to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) /\
           (forall k', 0 <= k' < k =>
              l8 h8 k' = foldl compress (l8 h0 k') (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k') + to_uint off0) (64 * to_uint n0)))) /\
           (forall k', k < k' < 8 => l8 h8 k' = l8 h0 k') /\
           h256 h = foldl compress (l8 h0 k) (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0) (64 * to_uint n0)))).
  + ecall (K256.compress_blocks_correct (h256 h) p n); auto => /> &hr hk0 hk8 hb hlo hhi hh.
    have hpk := hb k{hr} _; 1: done.
    have hp : to_uint (BArray64.get64 in0 k{hr} + off0)
              = to_uint (BArray64.get64 in0 k{hr}) + to_uint off0.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite /Jslh.SLH64.protect_64 hp; split; first smt().
    move=> _ r hr'; split; first by move=> k' hk1 hk2; apply hhi => /#.
    by rewrite hr' hh hhi.
  wp; while (0 <= k < 8 /\ 0 <= j <= 8 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ (forall q, 0 <= q < 8 => to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) /\
             (forall k', 0 <= k' < k =>
                l8 h8 k' = foldl compress (l8 h0 k') (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k') + to_uint off0) (64 * to_uint n0)))) /\
             (forall k', k < k' < 8 => l8 h8 k' = l8 h0 k') /\
             h256 h = foldl compress (l8 h0 k) (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0) (64 * to_uint n0))) /\
             (forall j', 0 <= j' < j => BArray256.get32 h8 (8 * j' + k) = BArray32.get32 h j')).
  + auto => /> &hr hk0 hk8 hj0 hj8 hb hlo hhi hh hs hlt.
    do !split; 1,2: smt().
    + move=> k' hk1 hk2; rewrite l8_set; 1..4: smt().
      by apply hlo.
    + move=> k' hk1 hk2; rewrite l8_set; 1..4: smt().
      by apply hhi.
    move=> j' hj1 hj2; rewrite BArray256.get_set32E 1,2:/#.
    case: (j' = j{hr}) => [->|ne] /=; first done.
    rewrite ifF 1:/#; apply hs; smt().
  auto => /> &hr hk0 hk8 hb hlo hhi hh; rewrite /Jslh.SLH64.protect_ptr /Jslh.SLH64.protect_64 /=.
  split; first by split; [smt() | split; smt()].
  move=> h1 j1 hn hj0 hj8 _ hlo1 hhi1 hs.
  split; first smt().
  split.
  + move=> k' hk1 hk2; case: (k' = k{hr}) => [->|ne]; last by apply hlo1 => /#.
    by rewrite -hh; apply scatter => j hj; apply hs => /#.
  by move=> k' hk1 hk2; apply hhi1 => /#.
auto => /> &hr hb; split; first smt().
move=> h1 k1 hn hk0 hk8 hlo hhi k' hk1 hk2.
by apply hlo => /#.
qed.

lemma x8_compress_ll : islossless M._sha256_x8_compress.
proof.
proc; while (true) (8 - k).
+ move=> z; wp; while (true) (8 - j); first by auto => /#.
  wp; call K256.compress_ll; wp; while (true) (8 - j); first by auto => /#.
  by auto => /#.
by auto => /#.
qed.

lemma x8_compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof.
proc; while (true) (8 - k).
+ move=> z; wp; while (true) (8 - j); first by auto => /#.
  wp; call K256.compress_blocks_ll; wp; while (true) (8 - j); first by auto => /#.
  by auto => /#.
by auto => /#.
qed.

lemma x8_compress_total (h0 : BArray256.t) (blk : BArray512.t) :
  phoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             l8 res.`1 k
             = compress (l8 h0 k) (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))]
  = 1%r.
proof. by conseq x8_compress_ll (x8_compress_correct h0 blk). qed.

lemma x8_compress_lanes_total (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             l8 res.`1 k
             = foldl compress (l8 h0 k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0)
                           (64 * to_uint n0)))] = 1%r.
proof. by conseq x8_compress_lanes_ll (x8_compress_lanes_correct h0 in0 off0 n0). qed.
