(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2X8.ec (aarch64/sha2)
 * ==================================
 *
 * Functional correctness, lane by lane, of the eight-way entry point
 * _sha256_x8_compress of the AArch64 SHA-256 instruction kernel
 * (src/aarch64/sha2/sha256_x8_compress.jinc, FEAT_SHA256) against FIPS
 * 180-4 section 6.2.2: every lane k ends with compress applied to its own
 * chaining value and its own block. The entry point that reads the blocks
 * from memory is proven in SHA256_A64Sha2X8Lanes.ec.
 *
 * Representation. The eight chaining values are u32[64], word-major:
 * word w of lane k is u32 8w + k (lane8 of lib/Lanes.ec), so the 128-bit
 * slot 2w + f holds word w of lanes 4f .. 4f + 3. Block k is bytes 64k ..
 * 64k + 63 of the 512-byte input (lane_block). The kernel works on half
 * f = 0, 1 (lanes 4f .. 4f + 3) at a time: __sha256_x8_load_half
 * transposes its 4x4 blocks of words (tr4 of Vec.ec) so that st[2l + q]
 * holds words 4q .. 4q + 3 of lane 4f + l, the state layout of the one-way
 * kernel; __sha256_x8_block2 (SHA256_A64Sha2X8Block.ec) runs pairs r = 0,
 * 1 of that half; __sha256_x8_store_half transposes back.
 *
 * Theorems:
 *     sha256_x8_load_half_correct,   the two transposes, slot by slot;
 *     sha256_x8_store_half_correct
 *     sha256_x8_compress_correct     lane k of the result is compress of
 *                                    lane k and block k, for k < 8
 *                                    (partial correctness);
 *     sha256_x8_compress_total       the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Sha2Insn Lanes.
require import SHA256_A64Sha2 SHA256_A64Sha2Blocks SHA256_A64Sha2X8Block.
require Arrays.
import SHA256 A256.

clone Arrays.Words as Arr128 with theory A <= BArray128.
clone Arrays.Words as Arr512 with theory A <= BArray512.

(* ------------------------------------------------------------------ *)
(* Words of a lane as vectors                                         *)

lemma range4i (i : int) : 0 <= i < 4 => i = 0 \/ i = 1 \/ i = 2 \/ i = 3.
proof. smt(). qed.

(* Words 4q .. 4q + 3 of a chaining value. *)
op q4 (L : W32.t list) (q : int) : W128.t =
  p4 (nth W32.zero L (4 * q)) (nth W32.zero L (4 * q + 1))
     (nth W32.zero L (4 * q + 2)) (nth W32.zero L (4 * q + 3)).

lemma q4_a (L : W32.t list) : st4a (to_state L) = q4 L 0.
proof. by rewrite /to_state /q4. qed.

lemma q4_e (L : W32.t list) : st4e (to_state L) = q4 L 1.
proof. by rewrite /to_state /q4. qed.

(* Slot 2w + f of the eight-way state: word w of lanes 4f .. 4f + 3. *)
lemma h8_slot (h : BArray256.t) (w f : int) : 0 <= w < 8 => 0 <= f < 2 =>
  BArray256.get128 h (2 * w + f)
  = p4 (nth W32.zero (lane8 (BArray256.get32 h) (4 * f)) w)
       (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 1)) w)
       (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 2)) w)
       (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 3)) w).
proof.
move=> hw hf; rewrite !nth_lane //.
rewrite {1}(p4_bits (BArray256.get128 h (2 * w + f))) !Arr256.get128d_bits32 //.
by rewrite /=; congr; congr; ring.
qed.

(* A u32 of the eight-way state as a lane of its slot. *)
lemma h8_word (h : BArray256.t) (w f l : int) : 0 <= l < 4 =>
  BArray256.get32 h (8 * w + (4 * f + l)) = BArray256.get128 h (2 * w + f) \bits32 l.
proof. by move=> hl; rewrite Arr256.get128d_bits32 //; congr; ring. qed.

(* The four slots q, 2 + q, 4 + q, 6 + q of a half state: words 4q ..
   4q + 3 of its four lanes. *)
op tq (st : BArray128.t) (q : int) : W128.t * W128.t * W128.t * W128.t =
  (BArray128.get128 st q, BArray128.get128 st (2 + q),
   BArray128.get128 st (4 + q), BArray128.get128 st (6 + q)).

(* The four slots of word group q of half f of the eight-way state. *)
op hq (h : BArray256.t) (f q : int) : W128.t * W128.t * W128.t * W128.t =
  (BArray256.get128 h (2 * (4 * q) + f), BArray256.get128 h (2 * (4 * q + 1) + f),
   BArray256.get128 h (2 * (4 * q + 2) + f), BArray256.get128 h (2 * (4 * q + 3) + f)).

lemma tq_set (st : BArray128.t) (q q' : int) (a b c d : W128.t) :
  0 <= q < 2 => 0 <= q' < 2 =>
  tq (BArray128.set128 (BArray128.set128 (BArray128.set128
        (BArray128.set128 st q a) (2 + q) b) (4 + q) c) (6 + q) d) q'
  = if q' = q then (a, b, c, d) else tq st q'.
proof.
move=> hq hq'; rewrite /tq; case: (q' = q) => [->>|ne].
+ by rewrite !BArray128.get_set128E //= /#.
by rewrite !BArray128.get_set128E_neq // /#.
qed.

lemma hq_set (h : BArray256.t) (f q q' : int) (a b c d : W128.t) :
  0 <= f < 2 => 0 <= q < 2 => 0 <= q' < 2 =>
  hq (BArray256.set128 (BArray256.set128 (BArray256.set128
        (BArray256.set128 h (2 * (4 * q) + f) a) (2 * (4 * q + 1) + f) b)
        (2 * (4 * q + 2) + f) c) (2 * (4 * q + 3) + f) d) f q'
  = if q' = q then (a, b, c, d) else hq h f q'.
proof.
move=> hf hq hq'; rewrite /hq; case: (q' = q) => [->>|ne].
+ by rewrite !BArray256.get_set128E //= /#.
by rewrite !BArray256.get_set128E_neq // /#.
qed.

lemma hq_set_other (h : BArray256.t) (f q s : int) (a b c d : W128.t) :
  0 <= f < 2 => s %% 2 <> f =>
  BArray256.get128 (BArray256.set128 (BArray256.set128 (BArray256.set128
        (BArray256.set128 h (2 * (4 * q) + f) a) (2 * (4 * q + 1) + f) b)
        (2 * (4 * q + 2) + f) c) (2 * (4 * q + 3) + f) d) s
  = BArray256.get128 h s.
proof. by move=> hf hs; rewrite !BArray256.get_set128E_neq // /#. qed.

(* ------------------------------------------------------------------ *)
(* The transposes                                                     *)

lemma sha256_x8_tr4_correct (a0 b0 c0 d0 : W128.t) :
  hoare [M.__sha256_x8_tr4 : a = a0 /\ b = b0 /\ c = c0 /\ d = d0 ==>
           res = tr4 a0 b0 c0 d0].
proof. by proc; auto => />; rewrite /tr4. qed.

lemma sha256_x8_load_half_correct (h0 : BArray256.t) (f0 : int) :
  hoare [M.__sha256_x8_load_half : h8 = h0 /\ f = f0 ==>
           forall q, 0 <= q < 2 =>
             tq res q = tr4 (hq h0 f0 q).`1 (hq h0 f0 q).`2 (hq h0 f0 q).`3 (hq h0 f0 q).`4].
proof.
proc.
while (0 <= q <= 2 /\ h8 = h0 /\ f = f0 /\
       forall q', 0 <= q' < q =>
         tq st q' = tr4 (hq h0 f0 q').`1 (hq h0 f0 q').`2 (hq h0 f0 q').`3 (hq h0 f0 q').`4).
+ wp; ecall (sha256_x8_tr4_correct a b c d); wp; skip => /> &hr hq0 _ hst hq2.
  split; first smt().
  move=> q' hq'0 hq'1.
  rewrite tq_set 1,2:/#; case: (q' = q{hr}) => [->> /=|ne].
  + by rewrite /hq /tr4.
  by apply hst => /#.
by wp; skip => /> /#.
qed.

lemma sha256_x8_store_half_correct (h0 : BArray256.t) (st0 : BArray128.t) (f0 : int) :
  hoare [M.__sha256_x8_store_half : h8 = h0 /\ st = st0 /\ f = f0 /\ 0 <= f0 < 2 ==>
           (forall q, 0 <= q < 2 =>
              hq res f0 q = tr4 (tq st0 q).`1 (tq st0 q).`2 (tq st0 q).`3 (tq st0 q).`4) /\
           (forall s, s %% 2 <> f0 => BArray256.get128 res s = BArray256.get128 h0 s)].
proof.
proc.
while (0 <= q <= 2 /\ st = st0 /\ f = f0 /\ 0 <= f0 < 2 /\
       (forall q', 0 <= q' < q =>
          hq h8 f0 q' = tr4 (tq st0 q').`1 (tq st0 q').`2 (tq st0 q').`3 (tq st0 q').`4) /\
       (forall s, s %% 2 <> f0 => BArray256.get128 h8 s = BArray256.get128 h0 s)).
+ wp; ecall (sha256_x8_tr4_correct (BArray128.get128 st q) (BArray128.get128 st (2 + q))
               (BArray128.get128 st (4 + q)) (BArray128.get128 st (6 + q))).
  skip => /> &hr hq0 _ hf0 hf1 hst hfr hq2.
  split; first smt().
  split.
  + move=> q' hq'0 hq'1.
    rewrite hq_set 1..3:/#; case: (q' = q{hr}) => [->> /=|ne].
    + by rewrite /tq /tr4.
    by apply hst => /#.
  by move=> s hs; rewrite hq_set_other // hfr.
by wp; skip => /> /#.
qed.

(* ------------------------------------------------------------------ *)
(* The eight blocks                                                   *)

lemma size_lb (B : BArray512.t) k : 0 <= k < 8 =>
  size (lane_block 64 (BArray512.to_list B) k) = 64.
proof.
move=> hk; apply size_lane_block; [done | smt() | by rewrite BArray512.size_to_list /#].
qed.

(* Message word t of block k, read big-endian (section 5.2.1). *)
lemma bswap_get32_lane (B : BArray512.t) (k t : int) : 0 <= k < 8 => 0 <= t < 16 =>
  bswap32 (BArray512.get32 B (16 * k + t))
  = be32 (take 4 (drop (4 * t) (lane_block 64 (BArray512.to_list B) k))).
proof.
move=> hk ht; rewrite /bswap32 /be32 BArray512.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# size_lb // /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray512.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# nth_lane_block // 1,2:/# BArray512.get_to_list.
by rewrite BArray512.nth_sub //; congr; ring.
qed.

(* The block of lane k; k is taken modulo 8 so that every lane index
   names a full block. *)
op bwk (B : BArray512.t) (k : int) : W32.t list =
  blockwords (lane_block 64 (BArray512.to_list B) (k %% 8)).

lemma size_bwk B k : size (bwk B k) = 16.
proof.
by rewrite /bwk size_blockwords // size_lb /#.
qed.

lemma bwk_rec B k : forall t, 16 <= t < 64 => srec (schedule (bwk B k)) t.
proof. by move=> t ht; rewrite /srec (nth_schedule_hi _ _ (size_bwk B k)). qed.

lemma bwkE B k : 0 <= k < 8 =>
  bwk B k = map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)).
proof. by move=> hk; rewrite /bwk modz_small 1:/#. qed.

lemma vrev_lane_block (B : BArray512.t) (k j : int) : 0 <= k < 8 => 0 <= j < 4 =>
  VREV32_16u8 (BArray512.get128 B (4 * k + j)) = wv (schedule (bwk B k)) (4 * j).
proof.
move=> hk hj; rewrite {1}(p4_bits (VREV32_16u8 (BArray512.get128 B (4 * k + j)))) /wv.
rewrite !vrev32_lane // !Arr512.get128d_bits32 //.
have e : forall i, 0 <= i < 4 =>
  bswap32 (BArray512.get32d B (16 * (4 * k + j) + 4 * i))
  = nth W32.zero (schedule (bwk B k)) (4 * j + i).
+ move=> i hi; rewrite (nth_schedule_lo _ _ (size_bwk B k)) 1:/#.
  rewrite /bwk modz_small 1:/# (nth_blockwords _ _ (size_lb B k hk)) 1:/#.
  rewrite -(bswap_get32_lane B k (4 * j + i)) 1,2:/#.
  by congr; congr; ring.
by rewrite (e 0) // (e 1) // (e 2) // (e 3).
qed.

(* ------------------------------------------------------------------ *)
(* One pair of lanes                                                  *)

(* The states and schedules of the two lanes of pair r of half f. *)
op Sx (H : BArray256.t) (f r : int) : int -> state =
  fun l => to_state (lane8 (BArray256.get32 H) (4 * f + (2 * r + l))).

op Wx (B : BArray512.t) (f r : int) : int -> W32.t list =
  fun l => schedule (bwk B (4 * f + (2 * r + l))).

lemma sha256_x8_block2_blocks (H : BArray256.t) (B : BArray512.t) (f0 : int)
                              (st0 : BArray128.t) (r0 : int) :
  hoare [M.__sha256_x8_block2 :
           st = st0 /\ r = r0 /\ 0 <= r0 < 2 /\ k = sHA256_K /\
           (forall l, 0 <= l < 2 =>
              lane_st (Sx H f0 r0) (Wx B f0 r0) st0 r0 l 0 /\ lane_win (Wx B f0 r0) m l 0) ==>
           (forall l, 0 <= l < 2 => lane_fin (Sx H f0 r0) (Wx B f0 r0) res.`1 r0 l) /\
           frame st0 res.`1 r0].
proof.
apply (sha256_x8_block2_correct (Sx H f0 r0) (Wx B f0 r0) st0 r0).
by move=> l hl t ht; rewrite /Wx /=; apply bwk_rec.
qed.

(* Lane k's result. *)
op R (H : BArray256.t) (B : BArray512.t) (k : int) : W32.t list =
  compress (lane8 (BArray256.get32 H) k) (bwk B k).

(* The half state after pairs 0 .. r - 1. *)
op rinv (st : BArray128.t) (H : BArray256.t) (Rf : int -> W32.t list) (f r : int) =
  forall l q, 0 <= l < 4 => 0 <= q < 2 =>
    BArray128.get128 st (2 * l + q)
    = q4 (if l %/ 2 < r then Rf (4 * f + l) else lane8 (BArray256.get32 H) (4 * f + l)) q.

(* The eight-way state after halves 0 .. f - 1. *)
op hfin (h H : BArray256.t) (Rf : int -> W32.t list) (f : int) =
  forall w f', 0 <= w < 8 => 0 <= f' < 2 =>
    BArray256.get128 h (2 * w + f')
    = if f' < f
      then p4 (nth W32.zero (Rf (4 * f')) w) (nth W32.zero (Rf (4 * f' + 1)) w)
              (nth W32.zero (Rf (4 * f' + 2)) w) (nth W32.zero (Rf (4 * f' + 3)) w)
      else BArray256.get128 H (2 * w + f').

lemma size_lane8 (h : BArray256.t) k : size (lane8 (BArray256.get32 h) k) = 8.
proof. exact size_lane. qed.

(* Pair r of the half: its two lanes' states before the block. *)
lemma rinv_pre st H B f r : 0 <= f < 2 => 0 <= r < 2 => rinv st H (R H B) f r =>
  forall l, 0 <= l < 2 => lane_st (Sx H f r) (Wx B f r) st r l 0.
proof.
move=> hf hr hst l hl; rewrite /lane_st /Sx /= !rounds_nil //.
rewrite q4_a q4_e.
have e0 := hst (2 * r + l) 0 _ _; 1,2: smt().
have e1 := hst (2 * r + l) 1 _ _; 1,2: smt().
move: e0 e1; rewrite (_ : (2 * r + l) %/ 2 < r <=> false) 1:/# /=.
by rewrite (_ : 2 * (2 * r + l) = 4 * r + 2 * l) 1:/# => -> ->.
qed.

(* After the block: pair r is done, the other pairs are unchanged. *)
lemma rinv_step st st' H B f r : 0 <= f < 2 => 0 <= r < 2 => rinv st H (R H B) f r =>
  (forall l, 0 <= l < 2 => lane_fin (Sx H f r) (Wx B f r) st' r l) =>
  frame st st' r => rinv st' H (R H B) f (r + 1).
proof.
move=> hf hr hst hfin hfr l q hl hq.
case: (l %/ 2 = r) => hlr.
+ rewrite ifT 1:/#.
  have [l0 [hl0 ->>]] : exists l0, 0 <= l0 < 2 /\ l = 2 * r + l0 by exists (l %% 2); smt().
  have [ea ee] := hfin l0 hl0.
  have [sa se] := st_step (lane8 (BArray256.get32 H) (4 * f + (2 * r + l0)))
                    (bwk B (4 * f + (2 * r + l0))) (size_lane8 H _).
  move: ea ee; rewrite /Sx /Wx /= sa se q4_a q4_e => ea ee.
  have : q = 0 \/ q = 1 by smt().
  case=> ->> /=.
  + by rewrite (_ : 2 * (2 * r + l0) = 4 * r + 2 * l0) 1:/# ea /R.
  by rewrite (_ : 2 * (2 * r + l0) + 1 = 4 * r + 2 * l0 + 1) 1:/# ee /R.
rewrite hfr 1:/# hst //.
by rewrite (_ : (l %/ 2 < r + 1) = (l %/ 2 < r)) 1:/#.
qed.

(* The message window of pair r of half f before the block. *)
lemma minv_win (m : BArray128.t) B f r : 0 <= f < 2 => 0 <= r < 2 =>
  (forall i, 0 <= i < 4 =>
     BArray128.get128 m i = VREV32_16u8 (BArray512.get128 B (4 * (4 * f + 2 * r) + i)) /\
     BArray128.get128 m (4 + i) = VREV32_16u8 (BArray512.get128 B (4 * (4 * f + 2 * r + 1) + i))) =>
  forall l, 0 <= l < 2 => lane_win (Wx B f r) m l 0.
proof.
move=> hf hr hm l hl j hj; rewrite /Wx /= wg0 //.
have [e0 e1] := hm j hj.
have : l = 0 \/ l = 1 by smt().
case=> ->> /=.
+ by rewrite e0 vrev_lane_block // /#.
by rewrite e1 vrev_lane_block 1:/# // addzA.
qed.

(* Filling the window: slots i and 4 + i. *)
lemma mfill (m : BArray128.t) (i i' : int) (x y : W128.t) : 0 <= i < 4 => 0 <= i' < 4 =>
  let m1 = BArray128.set128 (BArray128.set128 m i x) i
             (VREV32_16u8 (BArray128.get128 (BArray128.set128 m i x) i)) in
  let m2 = BArray128.set128 (BArray128.set128 m1 (4 + i) y) (4 + i)
             (VREV32_16u8 (BArray128.get128 (BArray128.set128 m1 (4 + i) y) (4 + i))) in
  BArray128.get128 m2 i' = (if i' = i then VREV32_16u8 x else BArray128.get128 m i') /\
  BArray128.get128 m2 (4 + i') = (if i' = i then VREV32_16u8 y else BArray128.get128 m (4 + i')).
proof.
move=> hi hi' /=.
have h1 : forall t (a : int) w, 0 <= a < 8 => BArray128.get128 (BArray128.set128 t a w) a = w.
+ by move=> t a w ha; rewrite BArray128.get_set128E_eq // /#.
rewrite !h1 1,2:/#.
case: (i' = i) => [->>|ne] /=.
+ split; last by rewrite h1 1:/#.
  rewrite (BArray128.get_set128E_neq _ (4 + i) i) 1:/#.
  by rewrite (BArray128.get_set128E_neq _ (4 + i) i) 1:/# h1 1:/#.
split.
+ rewrite (BArray128.get_set128E_neq _ (4 + i) i') 1:/#.
  rewrite (BArray128.get_set128E_neq _ (4 + i) i') 1:/#.
  rewrite (BArray128.get_set128E_neq _ i i') 1:/#.
  by rewrite (BArray128.get_set128E_neq _ i i') 1:/#.
rewrite (BArray128.get_set128E_neq _ (4 + i) (4 + i')) 1:/#.
rewrite (BArray128.get_set128E_neq _ (4 + i) (4 + i')) 1:/#.
rewrite (BArray128.get_set128E_neq _ i (4 + i')) 1:/#.
by rewrite (BArray128.get_set128E_neq _ i (4 + i')) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The halves                                                         *)

lemma hfin0 H Rf : hfin H H Rf 0.
proof. by move=> w f' hw hf'; rewrite ifF 1:/#. qed.

lemma hq_lanes (h : BArray256.t) f q : 0 <= f < 2 => 0 <= q < 2 =>
  hq h f q
  = (p4 (nth W32.zero (lane8 (BArray256.get32 h) (4 * f)) (4 * q))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 1)) (4 * q))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 2)) (4 * q))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 3)) (4 * q)),
     p4 (nth W32.zero (lane8 (BArray256.get32 h) (4 * f)) (4 * q + 1))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 1)) (4 * q + 1))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 2)) (4 * q + 1))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 3)) (4 * q + 1)),
     p4 (nth W32.zero (lane8 (BArray256.get32 h) (4 * f)) (4 * q + 2))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 1)) (4 * q + 2))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 2)) (4 * q + 2))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 3)) (4 * q + 2)),
     p4 (nth W32.zero (lane8 (BArray256.get32 h) (4 * f)) (4 * q + 3))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 1)) (4 * q + 3))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 2)) (4 * q + 3))
        (nth W32.zero (lane8 (BArray256.get32 h) (4 * f + 3)) (4 * q + 3))).
proof.
move=> hf hq; rewrite /hq (h8_slot h (4 * q) f) 1,2:/# (h8_slot h (4 * q + 1) f) 1,2:/#.
by rewrite (h8_slot h (4 * q + 2) f) 1,2:/# (h8_slot h (4 * q + 3) f) 1,2:/#.
qed.

(* Half f of the state, transposed: lane 4f + l in st[2l], st[2l + 1]. *)
lemma rinv0 st H Rf f : 0 <= f < 2 =>
  (forall q, 0 <= q < 2 =>
     tq st q = tr4 (hq H f q).`1 (hq H f q).`2 (hq H f q).`3 (hq H f q).`4) =>
  rinv st H Rf f 0.
proof.
move=> hf h l q hl hq; rewrite ifF 1:/#.
have := h q hq; rewrite hq_lanes // /= tr4_p4 /tq /= => [#] e0 e1 e2 e3.
have := range4i l hl.
by case=> [->>|[->>|[->>|->>]]] /=; rewrite /q4 ?e0 ?e1 ?e2 ?e3.
qed.

lemma hfin_half h H Rf f : 0 <= f < 2 => hfin h H Rf f =>
  forall q, 0 <= q < 2 => hq h f q = hq H f q.
proof.
move=> hf hh q hq; rewrite /hq.
rewrite (hh (4 * q) f) 1,2:/# (hh (4 * q + 1) f) 1,2:/#.
by rewrite (hh (4 * q + 2) f) 1,2:/# (hh (4 * q + 3) f) 1,2:/# !ltzz.
qed.

(* After the store: half f holds the results of its four lanes. *)
lemma hfin_step h h' H Rf f : 0 <= f < 2 => hfin h H Rf f =>
  (forall q, 0 <= q < 2 =>
     hq h' f q = tr4 (q4 (Rf (4 * f)) q) (q4 (Rf (4 * f + 1)) q)
                     (q4 (Rf (4 * f + 2)) q) (q4 (Rf (4 * f + 3)) q)) =>
  (forall s, s %% 2 <> f => BArray256.get128 h' s = BArray256.get128 h s) =>
  hfin h' H Rf (f + 1).
proof.
move=> hf hh hn ho w f' hw hf'.
case: (f' = f) => [->>|ne].
+ rewrite ifT 1:/#.
  have [q0 i0 [hq0 [hi0 ->>]]] : exists q0 i0, 0 <= q0 < 2 /\ 0 <= i0 < 4 /\ w = 4 * q0 + i0.
  + by exists (w %/ 4) (w %% 4); smt().
  have := hn q0 hq0; rewrite /hq /q4 tr4_p4 /= => [#] e0 e1 e2 e3.
  have := range4i i0 hi0.
  by case=> [->>|[->>|[->>|->>]]] /=; rewrite ?e0 ?e1 ?e2 ?e3.
rewrite ho 1:/# hh //.
by rewrite (_ : (f' < f + 1) = (f' < f)) 1:/#.
qed.

lemma hfin_lanes h H Rf : (forall k, 0 <= k < 8 => size (Rf k) = 8) => hfin h H Rf 2 =>
  forall k, 0 <= k < 8 => lane8 (BArray256.get32 h) k = Rf k.
proof.
move=> hs hh k hk.
apply (eq_from_nth W32.zero); first by rewrite size_lane hs.
move=> j; rewrite size_lane => hj; rewrite nth_lane //.
have [f l [hf [hl ->>]]] : exists f l, 0 <= f < 2 /\ 0 <= l < 4 /\ k = 4 * f + l.
+ by exists (k %/ 4) (k %% 4); smt().
rewrite /= h8_word // hh // ifT 1:/#.
have := range4i l hl.
by case=> [->>|[->>|[->>|->>]]] /=; rewrite ?p4_0 ?p4_1 ?p4_2 ?p4_3.
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on eight 64-byte blocks                     *)

lemma sha256_x8_compress_correct (H : BArray256.t) (B : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = H /\ blocks = B ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 H) k)
                        (map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)))].
proof.
proc.
wp.
while (0 <= f <= 2 /\ k = sHA256_K /\ blocks = B /\ hfin h8 H (R H B) f).
+ wp; ecall (sha256_x8_store_half_correct h8 st f).
  while (0 <= r <= 2 /\ 0 <= f < 2 /\ k = sHA256_K /\ blocks = B /\
         hfin h8 H (R H B) f /\ rinv st H (R H B) f r).
  + wp; ecall (sha256_x8_block2_blocks H B f st r).
    while (0 <= i <= 4 /\ 0 <= r < 2 /\ 0 <= f < 2 /\ k = sHA256_K /\ blocks = B /\
           hfin h8 H (R H B) f /\ rinv st H (R H B) f r /\
           forall i', 0 <= i' < i =>
             BArray128.get128 m i'
             = VREV32_16u8 (BArray512.get128 B (4 * (4 * f + 2 * r) + i')) /\
             BArray128.get128 m (4 + i')
             = VREV32_16u8 (BArray512.get128 B (4 * (4 * f + 2 * r + 1) + i'))).
    + wp; skip => /> &hr hi0 _ hr0 hr2 hf0 hf2 hh hrv hm hi4.
      split; first smt().
      move=> i' hi'0 hi'1.
      have /= [e0 e1] := mfill m{hr} i{hr} i'
        (BArray512.get128 B (4 * (4 * f{hr} + 2 * r{hr}) + i{hr}))
        (BArray512.get128 B (4 * (4 * f{hr} + 2 * r{hr} + 1) + i{hr})) _ _; 1,2: smt().
      rewrite e0 e1; case: (i' = i{hr}) => [->> //|ne].
      by apply hm => /#.
    wp; skip => /> &hr hr0 hr2 hf0 hf2 hh hrv hr.
    have hfr : 0 <= f{hr} < 2 by smt().
    have hrr : 0 <= r{hr} < 2 by smt().
    split; first smt().
    move=> i0 m0 hi hi0 hi4 hm.
    have ->> : i0 = 4 by smt().
    have hw := minv_win m0 B f{hr} r{hr} hfr hrr hm.
    have hs := rinv_pre st{hr} H B f{hr} r{hr} hfr hrr hrv.
    split.
    + move=> l hl0 hl2; split; last by apply hw.
      have := hs l _; 1: smt().
      by rewrite /lane_st.
    move=> _ o hfin hfr'.
    split; first smt().
    exact (rinv_step st{hr} o.`1 H B f{hr} r{hr} hfr hrr hrv hfin hfr').
  wp; ecall (sha256_x8_load_half_correct h8 f); skip => />.
  move=> &hr hf0 hf2 hh hf st1 hst1.
  have hfr : 0 <= f{hr} < 2 by smt().
  split.
  + apply (rinv0 st1 H (R H B) f{hr} hfr) => q hq.
    by rewrite hst1 // (hfin_half h8{hr} H (R H B) f{hr} hfr hh q hq).
  move=> r0 st0 hr hr0 hr2 hrv h' hn ho.
  have ->> : r0 = 2 by smt().
  split; first smt().
  apply (hfin_step h8{hr} h' H (R H B) f{hr} hfr hh _ ho) => q hq.
  have e0 := hrv 0 q _ hq; 1: done.
  have e1 := hrv 1 q _ hq; 1: done.
  have e2 := hrv 2 q _ hq; 1: done.
  have e3 := hrv 3 q _ hq; 1: done.
  move: e0 e1 e2 e3; rewrite /= => e0 e1 e2 e3.
  by rewrite hn // /tq /= e0 e1 e2 e3.
wp; skip => />.
split; first exact hfin0.
move=> f0 h80 hf hf0 hf2 hh k0 hk0 hk8.
have ->> : f0 = 2 by smt().
have hs : forall k, 0 <= k < 8 => size (R H B k) = 8.
+ by move=> k hk; rewrite /R size_compress // size_lane.
by rewrite (hfin_lanes h80 H (R H B) hs hh k0 _) 1:/# /R bwkE.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha256_x8_tr4_ll : islossless M.__sha256_x8_tr4.
proof. by proc; auto. qed.

lemma sha256_x8_load_half_ll : islossless M.__sha256_x8_load_half.
proof.
proc; while (0 <= q <= 2) (2 - q).
+ by move=> z; wp; call sha256_x8_tr4_ll; auto => /#.
by auto => /#.
qed.

lemma sha256_x8_store_half_ll : islossless M.__sha256_x8_store_half.
proof.
proc; while (0 <= q <= 2) (2 - q).
+ by move=> z; wp; call sha256_x8_tr4_ll; auto => /#.
by auto => /#.
qed.

lemma sha256_x8_compress_ll : islossless M._sha256_x8_compress.
proof.
proc; wp; while (0 <= f <= 2) (2 - f).
+ move=> z; wp; call sha256_x8_store_half_ll.
  while (0 <= r <= 2) (2 - r).
  + move=> z'; wp; call sha256_x8_block2_ll.
    while (0 <= i <= 4) (4 - i); first by auto => /#.
    by auto => /#.
  by wp; call sha256_x8_load_half_ll; auto => /#.
by auto => /#.
qed.

lemma sha256_x8_compress_total (H : BArray256.t) (B : BArray512.t) :
  phoare [M._sha256_x8_compress :
           h8 = H /\ blocks = B ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 H) k)
                        (map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)))] = 1%r.
proof. by conseq sha256_x8_compress_ll (sha256_x8_compress_correct H B). qed.
