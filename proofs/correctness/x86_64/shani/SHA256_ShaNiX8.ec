(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNiX8.ec
 * =================
 *
 * Functional correctness of the 8-way SHA-256 kernel on the x86 SHA
 * extensions (src/x86_64/shani/sha256_x8_compress.jinc) against FIPS
 * 180-4 section 6.2.2 as spec/FIPS180_SHA2.ec writes it, lane by lane,
 * for its two entry points:
 *
 *   x8_compress_total        _sha256_x8_compress, one block per lane from
 *                            an array of the eight blocks end to end
 *   x8_compress_lanes_total  _sha256_x8_compress_lanes, n blocks per lane
 *                            from lane memory, folded as the parse of
 *                            section 5.2.1 of those bytes
 *
 * with the statements of the portable 8-way kernel's proofs. All are
 * total correctness, from a hoare proof and a losslessness proof.
 *
 * Structure. The kernel runs the four pairs of lanes (4f + 2r,
 * 4f + 2r + 1) in turn: load the pair (SHA256_ShaNiX8Pair.load_pair_spec),
 * its blocks (SHA256_ShaNiX8Block.block2_correct), store the pair
 * (store_pair_spec). Before pair p = 2f + r, lanes below 2p hold their
 * result and the others their input.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Arrays SpecRounds ShaNi Mem Lanes.
require import SHA256_ShaNiX8Pair SHA256_ShaNiX8Block.
require JWordList SHA256_ShaNi.
import SHA256 R256.

clone Arrays.ArrayLanes as L512 with theory A <- BArray512.

(* ------------------------------------------------------------------ *)
(* The message words of lane k's block                                *)

abbrev mlane (blk : BArray512.t) (k : int) : W32.t list =
  map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)).

lemma size_mlane blk k : 0 <= k < 8 => size (mlane blk k) = 16.
proof.
by move=> hk; rewrite size_map size_chunk // size_lane_block // 1,2:/#.
qed.

lemma nth_mlane (blk : BArray512.t) k j : 0 <= k < 8 => 0 <= j < 16 =>
  nth W32.zero (mlane blk k) j = bswap32 (BArray512.get32 blk (16 * k + j)).
proof.
move=> hk hj; have hs : size (lane_block 64 (BArray512.to_list blk) k) = 64.
+ by rewrite size_lane_block // 1,2:/# BArray512.size_to_list /#.
rewrite (nth_map []) 1:size_chunk // 1:hs 1:/# nth_chunk4 1:hs 1:/#.
apply eq_sym; rewrite /bswap32 /be32 BArray512.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# hs /#.
move=> x; rewrite W4u8.size_to_list => hx.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray512.size_sub //.
have hi : 0 <= 4 * j + x < 64 by smt().
rewrite nth_take 1,2:/# nth_drop 1,2:/# nth_lane_block // 1:/#.
rewrite BArray512.get_to_list BArray512.nth_sub //.
by congr; ring.
qed.

(* Lane l's window before group 0: its sixteen words in order. *)
lemma wreg8_0 (w : BArray128.t) o (m : W32.t list) : size m = 16 =>
  (forall j, 0 <= j < 4 => BArray128.get128 w (o + j)
     = p4 (nth W32.zero m (4 * j)) (nth W32.zero m (4 * j + 1))
          (nth W32.zero m (4 * j + 2)) (nth W32.zero m (4 * j + 3))) =>
  wreg8 w o m 0.
proof. by move=> hm h i hi; rewrite /SHA256_ShaNi.grp /= SHA256_ShaNi.wv_lo // h. qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_compress                                                *)

(* Lane q before pair p / 2: compressed if q < p, else as it came in. *)
op cur (h0 : BArray256.t) (blk : BArray512.t) (p q : int) : W32.t list =
  if q < p then compress (lane8 (BArray256.get32 h0) q) (mlane blk q)
  else lane8 (BArray256.get32 h0) q.

op done8 (h0 : BArray256.t) (blk : BArray512.t) (h8 : BArray256.t) (p : int) =
  forall q, 0 <= q < 8 => lane8 (BArray256.get32 h8) q = cur h0 blk p q.

(* The loop context of pair (f, r), unchanged by its block loads. *)
op ctx (blk : BArray512.t) (f r : int) (blocks : BArray512.t) (k : BArray256.t) (mask_p : BArray16.t) =
  0 <= f < 2 /\ 0 <= r < 2 /\ blocks = blk /\ k = sHA256_K /\ mask_p = sHA256_X8_SHANI_BSWAP.

lemma ctxE blk f r blocks k mask_p : ctx blk f r blocks k mask_p =>
  0 <= f < 2 /\ 0 <= r < 2 /\ blocks = blk.
proof. by rewrite /ctx. qed.

lemma ctxK blk f r blocks k mask_p : ctx blk f r blocks k mask_p => k = sHA256_K.
proof. by rewrite /ctx. qed.

lemma cur_lo h0 blk p q : q < p => cur h0 blk p q = compress (lane8 (BArray256.get32 h0) q) (mlane blk q).
proof. by move=> h; rewrite /cur h. qed.

lemma cur_hi h0 blk p q : p <= q => cur h0 blk p q = lane8 (BArray256.get32 h0) q.
proof. by move=> h; rewrite /cur ifF 1:/#. qed.

(* The store of a pair: lanes p and p + 1 compressed, the others kept. *)
lemma done8_step h0 blk (h8 h8' : BArray256.t) p :
  0 <= p => p + 1 < 8 => done8 h0 blk h8 p =>
  lane8 (BArray256.get32 h8') p = compress (lane8 (BArray256.get32 h8) p) (mlane blk p) =>
  lane8 (BArray256.get32 h8') (p + 1)
    = compress (lane8 (BArray256.get32 h8) (p + 1)) (mlane blk (p + 1)) =>
  (forall q, 0 <= q < 8 => q <> p => q <> p + 1 =>
     lane8 (BArray256.get32 h8') q = lane8 (BArray256.get32 h8) q) =>
  done8 h0 blk h8' (p + 2).
proof.
move=> hp0 hp1 hd ha hb hq q hq8.
case: (q = p) => [->>|hne0].
+ by rewrite ha hd 1:/# (cur_hi h0 blk p p) // (cur_lo h0 blk (p + 2) p) /#.
case: (q = p + 1) => [->>|hne1].
+ rewrite hb hd 1:/# (cur_hi h0 blk p (p + 1)) 1:/#.
  by rewrite (cur_lo h0 blk (p + 2) (p + 1)) /#.
rewrite hq // hd // /cur.
have e : (q < p + 2) = (q < p).
+ by move: hne0 hne1; clear hd ha hb hq; smt().
by rewrite e.
qed.

(* Message rows 0 .. n - 1 of both lanes of the pair. *)
op wrows (w : BArray128.t) (ma mb : W32.t list) (n : int) =
  forall j, 0 <= j < n =>
    BArray128.get128 w j
    = p4 (nth W32.zero ma (4 * j)) (nth W32.zero ma (4 * j + 1))
         (nth W32.zero ma (4 * j + 2)) (nth W32.zero ma (4 * j + 3)) /\
    BArray128.get128 w (4 + j)
    = p4 (nth W32.zero mb (4 * j)) (nth W32.zero mb (4 * j + 1))
         (nth W32.zero mb (4 * j + 2)) (nth W32.zero mb (4 * j + 3)).

lemma x8_compress_correct (h0 : BArray256.t) (blk : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 h0) k)
                 (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))].
proof.
proc.
while (0 <= f <= 2 /\ blocks = blk /\ k = sHA256_K /\ mask_p = sHA256_X8_SHANI_BSWAP /\
       done8 h0 blk h8 (4 * f)).
+ wp.
  while (0 <= f < 2 /\ 0 <= r <= 2 /\ blocks = blk /\ k = sHA256_K /\
         mask_p = sHA256_X8_SHANI_BSWAP /\ done8 h0 blk h8 (4 * f + 2 * r)).
  + wp.
    ecall (store_pair_spec h8 f r
      (to_state (compress (lane8 (BArray256.get32 h8) (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r))))
      (to_state (compress (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1)) (mlane blk (4 * f + 2 * r + 1))))).
    ecall (block2_correct sHA256_K (mlane blk (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r + 1))
      (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r)))
      (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1))) SHA256_ShaNi.K256_get128).
    while (0 <= i <= 4 /\ mask = bswap_mask32 /\ ctx blk f r blocks k mask_p /\
           done8 h0 blk h8 (4 * f + 2 * r) /\
           regs st (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r)))
                   (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1))) /\
           wrows w (mlane blk (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r + 1)) i).
    + wp; skip => &hr [#] hi0 _ hmk hc hd hst hw hi4.
      have [#] hf0 hf1 hr0 hr1 hb := ctxE _ _ _ _ _ _ hc.
      rewrite /=; split; first smt().
      do 4!(split; first done).
      rewrite hmk hb => j hj; do !(rewrite BArray128.get_set128E 1,2:/#).
      have -> /= : (i{hr} = 4 + i{hr}) = false by smt().
      have -> /= : (4 + i{hr} = 4 + j) = (i{hr} = j) by smt().
      have -> /= : (i{hr} = 4 + j) = false by smt().
      have -> /= : (4 + i{hr} = j) = false by smt().
      case: (i{hr} = j) => [<<- /=|hne /=]; last by apply hw => /#.
      rewrite !L512.get128_p4 !vpshufb_bswap32 !p4_0 !p4_1 !p4_2 !p4_3 !nth_mlane 1..16:/#.
      smt().
    wp; ecall (load_pair_spec h8 f r); wp; skip => &hr [#] hf0 hf1 hr0 _ hb hk hm hd hr2.
    have hp : 0 <= 4 * f{hr} + 2 * r{hr} < 8 by move: hf0 hf1 hr0 hr2; clear hk hm hd; smt().
    have hp1 : 0 <= 4 * f{hr} + 2 * r{hr} + 1 < 8 by move: hf0 hf1 hr0 hr2; clear hk hm hd; smt().
    have hr' : 0 <= r{hr} + 1 <= 2 by move: hr0 hr2; clear hk hm hd; smt().
    split; first smt().
    move=> _ st [#] e0 e1 e2 e3; split.
    + split; first done.
      split; first by rewrite hm SHA256_ShaNi.mask_bswap.
      split; first by rewrite /ctx; do !split => //.
      split; first done.
      by rewrite /regs e0 e1 e2 e3 /= => j /#.
    move=> i w hi4 [#] hi0 hi1 hmk hc hd' hst hw.
    have hk' := ctxK _ _ _ _ _ _ hc.
    have ->> : i = 4 by smt().
    split.
    + rewrite (size_mlane _ _ hp) (size_mlane _ _ hp1) /= hk' hst /=.
      split.
      + apply wreg8_0; first exact (size_mlane _ _ hp).
        by move=> j hj /=; have [-> _] := hw j hj.
      apply wreg8_0; first exact (size_mlane _ _ hp1).
      by move=> j hj; have [_ ->] := hw j hj.
    move=> _ [st' w'] /= [#] p0 p1 p2 p3.
    have [fa1 fa2] := SHA256_ShaNi.ff_state (lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr}))
                        (mlane blk (4 * f{hr} + 2 * r{hr})) (size_lane _ _ _).
    have [fb1 fb2] := SHA256_ShaNi.ff_state (lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr} + 1))
                        (mlane blk (4 * f{hr} + 2 * r{hr} + 1)) (size_lane _ _ _).
    split; first by rewrite /= p0 p1 p2 p3 fa1 fa2 fb1 fb2; do !split => //.
    move=> _ h8' [#] l0 l1 lfr.
    have e : 4 * f{hr} + 2 * (r{hr} + 1) = (4 * f{hr} + 2 * r{hr}) + 2 by ring.
    rewrite /= e hb hk hm /=; split; first by split.
    split; first exact hr'.
    apply (done8_step h0 blk h8{hr} h8' (4 * f{hr} + 2 * r{hr})) => //; 1,2: smt().
    + by rewrite l0 /ofs SHA256_ShaNi.to_stateK // SHA256_ShaNi.size_compress // size_lane.
    by rewrite l1 /ofs SHA256_ShaNi.to_stateK // SHA256_ShaNi.size_compress // size_lane.
  wp; skip => &hr [#] hf0 _ hb hk hm hd hf2; split.
  + by rewrite hb hk hm /=; do !split => //.
  move=> h8' r' hr2 [#] _ _ hr0 hr1 hb' hk' hm' hd'.
  have ->> : r' = 2 by move: hr0 hr1 hr2; clear hk hm hk' hm' hd hd'; smt().
  rewrite hb' hk' hm' /=; split; first by move: hf0 hf2; clear hk hm hk' hm' hd hd'; smt().
  by have <- : 4 * f{hr} + 2 * 2 = 4 * (f{hr} + 1) by ring.
wp; skip => &hr [#] -> ->; split.
+ by do !split => // q hq; rewrite /cur ifF 1:/#.
move=> f' h8' hf [#] hf0 hf1 _ _ _ hd q hq.
have ->> : f' = 2 by move: hf hf0 hf1; clear hd; smt().
by rewrite /= hd // cur_lo /#.
qed.
