(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4_A64Sha2.ec (aarch64/sha2)
 * ==================================
 *
 * Functional correctness, lane by lane, of the four-way entry point
 * _sha512_x4_compress of the AArch64 SHA-512 instruction kernel
 * (src/aarch64/sha2/sha512_x4_compress.jinc, FEAT_SHA512) against FIPS
 * 180-4 section 6.4.2: every lane k ends with compress applied to its own
 * chaining value and its own block. The entry point that reads the blocks
 * from memory is proven in SHA512_X4_A64Sha2Lanes.ec.
 *
 * Representation. The four chaining values are u64[32], word-major: word
 * w of lane k is u64 4w + k (lane4 of lib/Lanes.ec), so the 128-bit slot
 * 2w + i holds word w of lanes 2i and 2i + 1. Block k is bytes 128k ..
 * 128k + 127 of the 512-byte input (lane_block). The kernel works on the
 * pair of lanes 2i, 2i + 1 at a time: __sha512_x4_load_pair transposes
 * its 2x2 blocks of words (VTRN1, VTRN2 on 64-bit lanes) so that s[5l +
 * q] holds words 2q, 2q + 1 of lane 2i + l, the state layout of the
 * one-way kernel; __sha512_x4_block2 (SHA512_X4_A64Sha2Block.ec) runs the
 * block; __sha512_x4_store_pair transposes back.
 *
 * Theorems:
 *     sha512_x4_load_pair_correct,   the two transposes, slot by slot;
 *     sha512_x4_store_pair_correct
 *     sha512_x4_compress_correct     lane k of the result is compress of
 *                                    lane k and block k, for k < 4
 *                                    (partial correctness);
 *     sha512_x4_compress_total       the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray128 BArray160 BArray256 BArray512 BArray640.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds512 Vec Sha2Insn Lanes.
require import SHA512_A64Sha2 SHA512_A64Sha2Blocks SHA512_X4_A64Sha2Block.
require Arrays.
import SHA512 A512.

clone Arrays.Words as Arr256 with theory A <= BArray256.
clone Arrays.Words as Arr512 with theory A <= BArray512.

(* ------------------------------------------------------------------ *)
(* Words of a lane as vectors                                         *)

(* Slot 2w + i of the four-way state: word w of lanes 2i and 2i + 1. *)
lemma h4_slot (h : BArray256.t) (w i : int) : 0 <= w < 8 => 0 <= i < 2 =>
  BArray256.get128 h (2 * w + i)
  = p2 (nth W64.zero (lane4 (BArray256.get64 h) (2 * i)) w)
       (nth W64.zero (lane4 (BArray256.get64 h) (2 * i + 1)) w).
proof.
move=> hw hi; rewrite !nth_lane //.
rewrite {1}(p2_bits (BArray256.get128 h (2 * w + i))) !Arr256.get128d_bits64 //.
by rewrite /=; congr; congr; ring.
qed.

(* A u64 of the four-way state as a lane of its slot. *)
lemma h4_word (h : BArray256.t) (w i b : int) : 0 <= b < 2 =>
  BArray256.get64 h (4 * w + (2 * i + b)) = BArray256.get128 h (2 * w + i) \bits64 b.
proof. by move=> hb; rewrite Arr256.get128d_bits64 //; congr; ring. qed.

lemma spair_nth (L : W64.t list) (q : int) : 0 <= q < 4 =>
  spair (to_state L) q = p2 (nth W64.zero L (2 * q)) (nth W64.zero L (2 * q + 1)).
proof.
move=> hq; have := range4 q _ _; 1,2: smt().
by case=> [->>|[->>|[->>|->>]]]; rewrite /spair /to_state.
qed.

(* The transposed pair: lane 2i + l in s[5l .. 5l + 3]. *)
lemma load_lanes (h : BArray256.t) (i q : int) : 0 <= i < 2 => 0 <= q < 4 =>
  VTRN1_2u64 (BArray256.get128 h (2 * (2 * q) + i)) (BArray256.get128 h (2 * (2 * q + 1) + i))
  = spair (to_state (lane4 (BArray256.get64 h) (2 * i))) q /\
  VTRN2_2u64 (BArray256.get128 h (2 * (2 * q) + i)) (BArray256.get128 h (2 * (2 * q + 1) + i))
  = spair (to_state (lane4 (BArray256.get64 h) (2 * i + 1))) q.
proof.
move=> hi hq; rewrite (h4_slot h (2 * q) i) 1,2:/# (h4_slot h (2 * q + 1) i) 1,2:/#.
by rewrite vtrn1_2u64_p2 vtrn2_2u64_p2 !spair_nth.
qed.

lemma store_lanes (N0 N1 : W64.t list) (q : int) : 0 <= q < 4 =>
  VTRN1_2u64 (spair (to_state N0) q) (spair (to_state N1) q)
  = p2 (nth W64.zero N0 (2 * q)) (nth W64.zero N1 (2 * q)) /\
  VTRN2_2u64 (spair (to_state N0) q) (spair (to_state N1) q)
  = p2 (nth W64.zero N0 (2 * q + 1)) (nth W64.zero N1 (2 * q + 1)).
proof. by move=> hq; rewrite !spair_nth // vtrn1_2u64_p2 vtrn2_2u64_p2. qed.

(* ------------------------------------------------------------------ *)
(* The transposes                                                     *)

lemma sha512_x4_load_pair_correct (h0 : BArray256.t) (i0 : int) :
  hoare [M.__sha512_x4_load_pair : h4 = h0 /\ i = i0 ==>
           forall q, 0 <= q < 4 =>
             BArray160.get128 res q
             = VTRN1_2u64 (BArray256.get128 h0 (2 * (2 * q) + i0))
                          (BArray256.get128 h0 (2 * (2 * q + 1) + i0)) /\
             BArray160.get128 res (5 + q)
             = VTRN2_2u64 (BArray256.get128 h0 (2 * (2 * q) + i0))
                          (BArray256.get128 h0 (2 * (2 * q + 1) + i0))].
proof.
proc.
while (0 <= q <= 4 /\ h4 = h0 /\ i = i0 /\
       forall q', 0 <= q' < q =>
         BArray160.get128 s q'
         = VTRN1_2u64 (BArray256.get128 h0 (2 * (2 * q') + i0))
                      (BArray256.get128 h0 (2 * (2 * q' + 1) + i0)) /\
         BArray160.get128 s (5 + q')
         = VTRN2_2u64 (BArray256.get128 h0 (2 * (2 * q') + i0))
                      (BArray256.get128 h0 (2 * (2 * q' + 1) + i0))).
+ wp; skip => /> &hr hq0 _ hs hq4.
  split; first smt().
  move=> q' h0' h1'; case: (q' = q{hr}) => [->>|ne].
  + by rewrite BArray160.get_set128E_neq 1:/# !BArray160.get_set128E_eq 1..6:/#.
  rewrite !BArray160.get_set128E_neq 1..4:/#.
  by apply hs => /#.
by wp; skip => /> /#.
qed.

lemma sha512_x4_store_pair_correct (h0 : BArray256.t) (s0 : BArray160.t) (i0 : int) :
  hoare [M.__sha512_x4_store_pair : h4 = h0 /\ s = s0 /\ i = i0 /\ 0 <= i0 < 2 ==>
           (forall q, 0 <= q < 4 =>
              BArray256.get128 res (2 * (2 * q) + i0)
              = VTRN1_2u64 (BArray160.get128 s0 q) (BArray160.get128 s0 (5 + q)) /\
              BArray256.get128 res (2 * (2 * q + 1) + i0)
              = VTRN2_2u64 (BArray160.get128 s0 q) (BArray160.get128 s0 (5 + q))) /\
           (forall t, t %% 2 <> i0 => BArray256.get128 res t = BArray256.get128 h0 t)].
proof.
proc.
while (0 <= q <= 4 /\ s = s0 /\ i = i0 /\ 0 <= i0 < 2 /\
       (forall q', 0 <= q' < q =>
          BArray256.get128 h4 (2 * (2 * q') + i0)
          = VTRN1_2u64 (BArray160.get128 s0 q') (BArray160.get128 s0 (5 + q')) /\
          BArray256.get128 h4 (2 * (2 * q' + 1) + i0)
          = VTRN2_2u64 (BArray160.get128 s0 q') (BArray160.get128 s0 (5 + q'))) /\
       (forall t, t %% 2 <> i0 => BArray256.get128 h4 t = BArray256.get128 h0 t)).
+ wp; skip => /> &hr hq0 _ hi0 hi1 hs hfr hq4.
  split; first smt().
  split.
  + move=> q' h0' h1'; case: (q' = q{hr}) => [->>|ne].
    + by rewrite BArray256.get_set128E_neq 1:/# !BArray256.get_set128E_eq 1..6:/#.
    rewrite !BArray256.get_set128E_neq 1..4:/#.
    by apply hs => /#.
  by move=> t ht; rewrite !BArray256.get_set128E_neq 1,2:/# hfr.
by wp; skip => /> /#.
qed.

(* ------------------------------------------------------------------ *)
(* The four blocks                                                    *)

lemma size_lb4 (B : BArray512.t) k : 0 <= k < 4 =>
  size (lane_block 128 (BArray512.to_list B) k) = 128.
proof.
move=> hk; apply size_lane_block; [done | smt() | by rewrite BArray512.size_to_list /#].
qed.

(* Message word t of block k, read big-endian (section 5.2.1). *)
lemma bswap_get64_lane (B : BArray512.t) (k t : int) : 0 <= k < 4 => 0 <= t < 16 =>
  bswap64 (BArray512.get64 B (16 * k + t))
  = be64 (take 8 (drop (8 * t) (lane_block 128 (BArray512.to_list B) k))).
proof.
move=> hk ht; rewrite /bswap64 /be64 BArray512.get64dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W8u8.size_to_list size_take // size_drop 1:/# size_lb4 // /#.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list W8u8.get_pack8 1:BArray512.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# nth_lane_block // 1,2:/# BArray512.get_to_list.
by rewrite BArray512.nth_sub //; congr; ring.
qed.

(* The block of lane k; k is taken modulo 4 so that every lane index
   names a full block. *)
op bw4 (B : BArray512.t) (k : int) : W64.t list =
  blockwords (lane_block 128 (BArray512.to_list B) (k %% 4)).

lemma size_bw4 B k : size (bw4 B k) = 16.
proof. by rewrite /bw4 size_blockwords // size_lb4 /#. qed.

lemma bw4_rec B k : forall t, 16 <= t < 80 => srec (schedule (bw4 B k)) t.
proof. by move=> t ht; rewrite /srec (nth_schedule_hi _ _ (size_bw4 B k)). qed.

lemma bw4E B k : 0 <= k < 4 =>
  bw4 B k = map be64 (chunk 8 (lane_block 128 (BArray512.to_list B) k)).
proof. by move=> hk; rewrite /bw4 modz_small 1:/#. qed.

lemma vrev_lane_block4 (B : BArray512.t) (k j : int) : 0 <= k < 4 => 0 <= j < 8 =>
  VREV64_16u8 (BArray512.get128 B (8 * k + j)) = wv2 (schedule (bw4 B k)) (2 * j).
proof.
move=> hk hj; rewrite {1}(p2_bits (VREV64_16u8 (BArray512.get128 B (8 * k + j)))) /wv2.
rewrite !vrev64_lane // !Arr512.get128d_bits64 //.
have e : forall i, 0 <= i < 2 =>
  bswap64 (BArray512.get64d B (16 * (8 * k + j) + 8 * i))
  = nth W64.zero (schedule (bw4 B k)) (2 * j + i).
+ move=> i hi; rewrite (nth_schedule_lo _ _ (size_bw4 B k)) 1:/#.
  rewrite /bw4 modz_small 1:/# (nth_blockwords _ _ (size_lb4 B k hk)) 1:/#.
  rewrite -(bswap_get64_lane B k (2 * j + i)) 1,2:/#.
  by congr; congr; ring.
by rewrite (e 0) // (e 1).
qed.

(* ------------------------------------------------------------------ *)
(* The pairs of lanes                                                 *)

(* The four-way state after pairs 0 .. i - 1. *)
op hfin4 (h H : BArray256.t) (Rf : int -> W64.t list) (i : int) =
  forall w i', 0 <= w < 8 => 0 <= i' < 2 =>
    BArray256.get128 h (2 * w + i')
    = if i' < i then p2 (nth W64.zero (Rf (2 * i')) w) (nth W64.zero (Rf (2 * i' + 1)) w)
      else BArray256.get128 H (2 * w + i').

lemma hfin4_0 H Rf : hfin4 H H Rf 0.
proof. by move=> w i' hw hi'; rewrite ifF 1:/#. qed.

lemma hfin4_pair h H Rf i : 0 <= i < 2 => hfin4 h H Rf i =>
  forall q, 0 <= q < 4 =>
    BArray256.get128 h (2 * (2 * q) + i) = BArray256.get128 H (2 * (2 * q) + i) /\
    BArray256.get128 h (2 * (2 * q + 1) + i) = BArray256.get128 H (2 * (2 * q + 1) + i).
proof.
by move=> hi hh q hq; rewrite !hh 1..4:/# !ltzz.
qed.

lemma hfin4_step h h' H Rf i : 0 <= i < 2 => hfin4 h H Rf i =>
  (forall q, 0 <= q < 4 =>
     BArray256.get128 h' (2 * (2 * q) + i)
     = p2 (nth W64.zero (Rf (2 * i)) (2 * q)) (nth W64.zero (Rf (2 * i + 1)) (2 * q)) /\
     BArray256.get128 h' (2 * (2 * q + 1) + i)
     = p2 (nth W64.zero (Rf (2 * i)) (2 * q + 1)) (nth W64.zero (Rf (2 * i + 1)) (2 * q + 1))) =>
  (forall t, t %% 2 <> i => BArray256.get128 h' t = BArray256.get128 h t) =>
  hfin4 h' H Rf (i + 1).
proof.
move=> hi hh hn ho w i' hw hi'.
case: (i' = i) => [->>|ne].
+ rewrite ifT 1:/#.
  have [q0 b0 [hq0 [hb0 ->>]]] : exists q0 b0, 0 <= q0 < 4 /\ 0 <= b0 < 2 /\ w = 2 * q0 + b0.
  + by exists (w %/ 2) (w %% 2); smt().
  have [e0 e1] := hn q0 hq0.
  have := x4_range2 b0 hb0.
  by case=> ->> /=; [rewrite e0 | rewrite e1].
rewrite ho 1:/# hh //.
by rewrite (_ : (i' < i + 1) = (i' < i)) 1:/#.
qed.

lemma hfin4_lanes h H Rf : (forall k, 0 <= k < 4 => size (Rf k) = 8) => hfin4 h H Rf 2 =>
  forall k, 0 <= k < 4 => lane4 (BArray256.get64 h) k = Rf k.
proof.
move=> hs hh k hk.
apply (eq_from_nth W64.zero); first by rewrite size_lane hs.
move=> j; rewrite size_lane => hj; rewrite nth_lane //.
have [i b [hi [hb ->>]]] : exists i b, 0 <= i < 2 /\ 0 <= b < 2 /\ k = 2 * i + b.
+ by exists (k %/ 2) (k %% 2); smt().
rewrite /= h4_word // hh // ifT 1:/#.
have := x4_range2 b hb.
by case=> ->> /=; rewrite ?p2_0 ?p2_1.
qed.

(* Lane k's result. *)
op R4 (H : BArray256.t) (B : BArray512.t) (k : int) : W64.t list =
  compress (lane4 (BArray256.get64 H) k) (bw4 B k).

(* The states and schedules of lanes 2i, 2i + 1. *)
op S4 (H : BArray256.t) (i : int) : int -> state =
  fun l => to_state (lane4 (BArray256.get64 H) (2 * i + l)).

op W4 (B : BArray512.t) (i : int) : int -> W64.t list =
  fun l => schedule (bw4 B (2 * i + l)).

lemma sha512_x4_block2_blocks (H : BArray256.t) (B : BArray512.t) (i0 : int) :
  hoare [M.__sha512_x4_block2 :
           k = sHA512_K /\
           (forall l, 0 <= l < 2 =>
              (forall j, 0 <= j < 4 => BArray160.get128 s (5 * l + j) = spair (S4 H i0 l) j) /\
              (forall j, 0 <= j < 8 => BArray256.get128 m (8 * l + j) = wv2 (W4 B i0 l) (2 * j))) ==>
           forall l, 0 <= l < 2 => forall j, 0 <= j < 4 =>
             BArray160.get128 res.`1 (5 * l + j)
             = VADD_2u64 (spair (rounds (W4 B i0 l) (S4 H i0 l) 0 80) j) (spair (S4 H i0 l) j)].
proof.
apply (sha512_x4_block2_correct (S4 H i0) (W4 B i0)).
by move=> l hl t ht; rewrite /W4 /=; apply bw4_rec.
qed.

(* Filling the windows: slots j and 8 + j. *)
lemma mfill4 (m : BArray256.t) (i i' : int) (x y : W128.t) : 0 <= i < 8 => 0 <= i' < 8 =>
  let m1 = BArray256.set128 (BArray256.set128 m i x) i
             (VREV64_16u8 (BArray256.get128 (BArray256.set128 m i x) i)) in
  let m2 = BArray256.set128 (BArray256.set128 m1 (8 + i) y) (8 + i)
             (VREV64_16u8 (BArray256.get128 (BArray256.set128 m1 (8 + i) y) (8 + i))) in
  BArray256.get128 m2 i' = (if i' = i then VREV64_16u8 x else BArray256.get128 m i') /\
  BArray256.get128 m2 (8 + i') = (if i' = i then VREV64_16u8 y else BArray256.get128 m (8 + i')).
proof.
move=> hi hi' /=.
have h1 : forall t (a : int) w, 0 <= a < 16 => BArray256.get128 (BArray256.set128 t a w) a = w.
+ by move=> t a w ha; rewrite BArray256.get_set128E_eq // /#.
rewrite !h1 1,2:/#.
case: (i' = i) => [->>|ne] /=.
+ split; last by rewrite h1 1:/#.
  rewrite (BArray256.get_set128E_neq _ (8 + i) i) 1:/#.
  by rewrite (BArray256.get_set128E_neq _ (8 + i) i) 1:/# h1 1:/#.
split.
+ rewrite (BArray256.get_set128E_neq _ (8 + i) i') 1:/#.
  rewrite (BArray256.get_set128E_neq _ (8 + i) i') 1:/#.
  rewrite (BArray256.get_set128E_neq _ i i') 1:/#.
  by rewrite (BArray256.get_set128E_neq _ i i') 1:/#.
rewrite (BArray256.get_set128E_neq _ (8 + i) (8 + i')) 1:/#.
rewrite (BArray256.get_set128E_neq _ (8 + i) (8 + i')) 1:/#.
rewrite (BArray256.get_set128E_neq _ i (8 + i')) 1:/#.
by rewrite (BArray256.get_set128E_neq _ i (8 + i')) 1:/#.
qed.

(* The pair's state after the load. *)
lemma pair_pre (s : BArray160.t) (h H : BArray256.t) Rf (i : int) : 0 <= i < 2 =>
  hfin4 h H Rf i =>
  (forall q, 0 <= q < 4 =>
     BArray160.get128 s q
     = VTRN1_2u64 (BArray256.get128 h (2 * (2 * q) + i)) (BArray256.get128 h (2 * (2 * q + 1) + i)) /\
     BArray160.get128 s (5 + q)
     = VTRN2_2u64 (BArray256.get128 h (2 * (2 * q) + i)) (BArray256.get128 h (2 * (2 * q + 1) + i))) =>
  forall l j, 0 <= l < 2 => 0 <= j < 4 => BArray160.get128 s (5 * l + j) = spair (S4 H i l) j.
proof.
move=> hi hh hs l j hl hj.
have [ea eb] := hs j hj.
have [fa fb] := hfin4_pair h H Rf i hi hh j hj.
have [ga gb] := load_lanes H i j hi hj.
move: ea eb; rewrite fa fb ga gb => ea eb.
have := x4_range2 l hl.
by case=> ->> /=; rewrite /S4 /= ?ea ?eb.
qed.

(* The pair's windows after the fill. *)
lemma pair_win (m : BArray256.t) B (i : int) : 0 <= i < 2 =>
  (forall j, 0 <= j < 8 =>
     BArray256.get128 m j = VREV64_16u8 (BArray512.get128 B (8 * (2 * i) + j)) /\
     BArray256.get128 m (8 + j) = VREV64_16u8 (BArray512.get128 B (8 * (2 * i + 1) + j))) =>
  forall l j, 0 <= l < 2 => 0 <= j < 8 => BArray256.get128 m (8 * l + j) = wv2 (W4 B i l) (2 * j).
proof.
move=> hi hm l j hl hj.
have [e0 e1] := hm j hj.
have := x4_range2 l hl.
case=> ->> /=; rewrite /W4 /=.
+ by rewrite e0 vrev_lane_block4 // /#.
by rewrite e1 vrev_lane_block4 // /#.
qed.

(* The pair's result in the store's form. *)
lemma pair_post (s : BArray160.t) H B (i : int) : 0 <= i < 2 =>
  (forall l, 0 <= l < 2 => forall j, 0 <= j < 4 =>
     BArray160.get128 s (5 * l + j)
     = VADD_2u64 (spair (rounds (W4 B i l) (S4 H i l) 0 80) j) (spair (S4 H i l) j)) =>
  forall q, 0 <= q < 4 =>
    BArray160.get128 s q = spair (to_state (R4 H B (2 * i))) q /\
    BArray160.get128 s (5 + q) = spair (to_state (R4 H B (2 * i + 1))) q.
proof.
move=> hi hs q hq.
have e0 := hs 0 _ q hq; 1: done.
have e1 := hs 1 _ q hq; 1: done.
by move: e0 e1; rewrite /S4 /W4 /= !st_step ?size_lane // 1..4:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on four 128-byte blocks                     *)

lemma sha512_x4_compress_correct (H : BArray256.t) (B : BArray512.t) :
  hoare [M._sha512_x4_compress :
           h4 = H /\ blocks = B ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = compress (lane4 (BArray256.get64 H) k)
                        (map be64 (chunk 8 (lane_block 128 (BArray512.to_list B) k)))].
proof.
proc.
wp.
while (0 <= i <= 2 /\ k = sHA512_K /\ blocks = B /\ hfin4 h4 H (R4 H B) i).
+ wp; ecall (sha512_x4_store_pair_correct h4 s i).
  ecall (sha512_x4_block2_blocks H B i).
  while (0 <= j <= 8 /\ 0 <= i < 2 /\ k = sHA512_K /\ blocks = B /\ hfin4 h4 H (R4 H B) i /\
         (forall l j', 0 <= l < 2 => 0 <= j' < 4 =>
            BArray160.get128 s (5 * l + j') = spair (S4 H i l) j') /\
         (forall j', 0 <= j' < j =>
            BArray256.get128 m j' = VREV64_16u8 (BArray512.get128 B (8 * (2 * i) + j')) /\
            BArray256.get128 m (8 + j')
            = VREV64_16u8 (BArray512.get128 B (8 * (2 * i + 1) + j')))).
  + wp; skip => /> &hr hj0 _ hi0 hi2 hh hs hm hj8.
    split; first smt().
    move=> j' hj'0 hj'1.
    have /= [e0 e1] := mfill4 m{hr} j{hr} j'
      (BArray512.get128 B (8 * (2 * i{hr}) + j{hr}))
      (BArray512.get128 B (8 * (2 * i{hr} + 1) + j{hr})) _ _; 1,2: smt().
    rewrite e0 e1; case: (j' = j{hr}) => [->> //|ne].
    by apply hm => /#.
  wp; ecall (sha512_x4_load_pair_correct h4 i); skip => />.
  move=> &hr hi0 hi2 hh hi s1 hs1.
  have hir : 0 <= i{hr} < 2 by smt().
  split.
  + split; last smt().
    by move=> l j' h0 h1 h2 h3; apply (pair_pre s1 h4{hr} H (R4 H B) i{hr} hir hh hs1) => /#.
  move=> j0 m0 hj hj0 hj8 hs' hm.
  have ->> : j0 = 8 by smt().
  split.
  + move=> l hl0 hl1; split.
    + by move=> j' h0 h1; apply hs' => /#.
    by move=> j' h0 h1; apply (pair_win m0 B i{hr} hir hm) => /#.
  move=> _ o hpost h' hn ho.
  have hp := pair_post o.`1 H B i{hr} hir hpost.
  split; first smt().
  apply (hfin4_step h4{hr} h' H (R4 H B) i{hr} hir hh _ ho) => q hq.
  have [ea eb] := hp q hq.
  have [sa sb] := store_lanes (R4 H B (2 * i{hr})) (R4 H B (2 * i{hr} + 1)) q hq.
  by have [-> ->] := hn q hq; rewrite ea eb sa sb.
wp; skip => />.
split; first exact hfin4_0.
move=> h40 i0 hi hi0 hi2 hh k0 hk0 hk4.
have ->> : i0 = 2 by smt().
have hs : forall k, 0 <= k < 4 => size (R4 H B k) = 8.
+ by move=> k hk; rewrite /R4 size_compress // size_lane.
by rewrite (hfin4_lanes h40 H (R4 H B) hs hh k0 _) 1:/# /R4 bw4E.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha512_x4_load_pair_ll : islossless M.__sha512_x4_load_pair.
proof. by proc; while (0 <= q <= 4) (4 - q); auto => /#. qed.

lemma sha512_x4_store_pair_ll : islossless M.__sha512_x4_store_pair.
proof. by proc; while (0 <= q <= 4) (4 - q); auto => /#. qed.

lemma sha512_x4_compress_ll : islossless M._sha512_x4_compress.
proof.
proc; wp; while (0 <= i <= 2) (2 - i).
+ move=> z; wp; call sha512_x4_store_pair_ll; call sha512_x4_block2_ll.
  while (0 <= j <= 8) (8 - j); first by auto => /#.
  by wp; call sha512_x4_load_pair_ll; auto => /#.
by auto => /#.
qed.

lemma sha512_x4_compress_total (H : BArray256.t) (B : BArray512.t) :
  phoare [M._sha512_x4_compress :
           h4 = H /\ blocks = B ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = compress (lane4 (BArray256.get64 H) k)
                        (map be64 (chunk 8 (lane_block 128 (BArray512.to_list B) k)))] = 1%r.
proof. by conseq sha512_x4_compress_ll (sha512_x4_compress_correct H B). qed.
