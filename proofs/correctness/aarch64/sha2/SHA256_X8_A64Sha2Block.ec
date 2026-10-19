(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64Sha2Block.ec (aarch64/sha2)
 * =======================================
 *
 * The two-lane block of the eight-way AArch64 SHA-256 instruction kernel
 * (src/aarch64/sha2/sha256_x8_compress.jinc, FEAT_SHA256):
 * __sha256_x8_block2 st r m k runs the 64 rounds and the feed-forward of
 * section 6.2.2 on two lanes at once, interleaved group by group.
 *
 * Representation. st holds four lanes' states, two vectors each: lane l of
 * the pair r has abcd in st[4r + 2l] and efgh in st[4r + 2l + 1], as the
 * one-way kernel holds them. m holds the two lanes' message windows,
 * lane l in m[4l .. 4l + 3]; at the head of group g, m[4l + j] holds the
 * four schedule words of group wg g j, the window of the one-way kernel
 * (SHA256_A64Sha2.ec) with the last four groups merged into one formula.
 *
 * The proof is lane by lane: each lane meets the invariant of the one-way
 * kernel, discharged by the same lemmas (group4, the window lemmas), and
 * the other lane's slots are untouched.
 *
 * Theorem:
 *     sha256_x8_block2_correct  both lanes of the pair end with
 *                               rounds 0 .. 63 plus the feed-forward;
 *                               the other pair's slots are unchanged
 *                               (partial correctness);
 *     sha256_x8_block2_ll       termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray64 BArray128 BArray256.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Sha2Insn SHA256_A64Sha2.
import SHA256 A256.

(* ------------------------------------------------------------------ *)
(* The message window                                                 *)

(* Group held by window slot j at the head of group g. Up to group 12
   every group is followed by the one four ahead; from 12 on the window
   no longer moves. *)
op wg (g j : int) : int = if g <= 12 then g + (j - g) %% 4 else 12 + (j - 12) %% 4.

lemma wg0 j : 0 <= j < 4 => wg 0 j = j.
proof. by move=> hj; rewrite /wg /= modz_small 1:/#. qed.

lemma wg_rd g i : 0 <= g <= 12 => 0 <= i < 4 => wg g ((g + i) %% 4) = g + i.
proof. by move=> hg hi; rewrite /wg ifT 1:/# win_idx. qed.

lemma wg_cur g : 0 <= g < 16 => wg g (g %% 4) = g.
proof.
move=> hg; case: (g <= 12) => h.
+ by have := wg_rd g 0 _ _ => //= /#.
by rewrite /wg ifF 1:/# win_last /#.
qed.

lemma wg_hi g j : 12 <= g < 16 => wg (g + 1) j = wg g j.
proof.
move=> hg; rewrite /wg ifF 1:/#.
by case: (g <= 12) => h //; have ->> : g = 12 by smt().
qed.

lemma wg_other g j : 0 <= g < 12 => 0 <= j < 4 => g %% 4 <> j =>
  wg (g + 1) j = wg g j.
proof. by move=> hg hj hne; rewrite /wg ifT 1:/# ifT 1:/# (win_other g j). qed.

lemma wg_next g : 0 <= g < 12 => wg (g + 1) (g %% 4) = g + 4.
proof.
move=> hg; rewrite /wg ifT 1:/#.
have -> : g %% 4 - (g + 1) = (-1) + (- (g %/ 4)) * 4 by smt(divz_eq).
by rewrite modzMDr.
qed.

lemma mod4_ne g : g %% 4 <> (g + 2) %% 4 /\ g %% 4 <> (g + 3) %% 4.
proof. smt(). qed.

lemma add_ne (o a b : int) : a <> b => o + a <> o + b.
proof. smt(). qed.

lemma slot_ok (o i : int) : 0 <= o <= 4 => 0 <= i < 4 =>
  0 <= o + i /\ 16 * (o + i + 1) <= 128.
proof. smt(). qed.

lemma slot_other (l l' j : int) : 0 <= l => l < 2 => 0 <= l' => l' < 2 => l' <> l =>
  0 <= j => j < 4 => 4 * l' + j < 4 * l \/ 4 * l + 4 <= 4 * l' + j.
proof. smt(). qed.

lemma le_ne (a b : int) : a <> b => (a <= b) = (a < b).
proof. smt(). qed.

lemma ne_succ (a : int) : a <> a + 1 /\ a + 1 <> a.
proof. smt(). qed.

lemma lt_succ (a b : int) : (a < b + 1) = (a <= b).
proof. smt(). qed.

lemma lt_succ_ne (a b : int) : a <> b => (a < b + 1) = (a < b).
proof. smt(). qed.

lemma pair_ok (r l : int) : 0 <= r < 2 => 0 <= l < 2 =>
  (0 <= 4 * r + 2 * l /\ 16 * (4 * r + 2 * l + 1) <= 128) /\
  (0 <= 4 * r + 2 * l + 1 /\ 16 * (4 * r + 2 * l + 1 + 1) <= 128).
proof. smt(). qed.

lemma pair_other (r l l' : int) : l' <> l =>
  4 * r + 2 * l <> 4 * r + 2 * l' /\ 4 * r + 2 * l + 1 <> 4 * r + 2 * l' /\
  4 * r + 2 * l <> 4 * r + 2 * l' + 1 /\ 4 * r + 2 * l + 1 <> 4 * r + 2 * l' + 1.
proof. smt(). qed.

lemma pair_frame (r l i : int) : 0 <= l < 2 => (i < 4 * r \/ 4 * r + 4 <= i) =>
  4 * r + 2 * l <> i /\ 4 * r + 2 * l + 1 <> i.
proof. smt(). qed.

(* Group g < 12 of the lane whose window is m[o .. o + 3] replaces m[o +
   g mod 4] by the words of group g + 4; the rest of m is unchanged. *)
lemma win_step8 (m : BArray128.t) (ws : W32.t list) (g o : int) :
  0 <= g < 12 => 0 <= o <= 4 => (forall t, 16 <= t < 64 => srec ws t) =>
  (forall j, 0 <= j < 4 => BArray128.get128 m (o + j) = wv ws (4 * wg g j)) =>
  let m1 = BArray128.set128 m (o + g %% 4)
             (SHA256SU0 (BArray128.get128 m (o + g %% 4))
                        (BArray128.get128 m (o + (g + 1) %% 4))) in
  let m2 = BArray128.set128 m1 (o + g %% 4)
             (SHA256SU1 (BArray128.get128 m1 (o + g %% 4))
                        (BArray128.get128 m1 (o + (g + 2) %% 4))
                        (BArray128.get128 m1 (o + (g + 3) %% 4))) in
  (forall j, 0 <= j < 4 => BArray128.get128 m2 (o + j) = wv ws (4 * wg (g + 1) j)) /\
  (forall i, (i < o \/ o + 4 <= i) => BArray128.get128 m2 i = BArray128.get128 m i).
proof.
move=> hg ho hrec hm /=.
have hi : 0 <= g %% 4 < 4 by smt().
have [hb1 hb2] := slot_ok o (g %% 4) ho hi.
have [hn2 hn3] := mod4_ne g.
have hw : forall i, 0 <= i < 4 =>
  BArray128.get128 m (o + (g + i) %% 4) = wv ws (4 * (g + i)).
+ by move=> i hi'; rewrite hm 1:/# wg_rd 1,2:/#.
split; last first.
+ move=> i hio.
  by rewrite BArray128.get_set128E_neq 1:/# BArray128.get_set128E_neq 1:/#.
move=> j hj.
case: (g %% 4 = j) => hj'.
+ rewrite (BArray128.get_set128E_eq _ (o + g %% 4) (o + j) _ hb1 hb2); 1: by rewrite hj'.
  rewrite (BArray128.get_set128E_eq _ (o + g %% 4) (o + g %% 4) _ hb1 hb2) //.
  rewrite (BArray128.get_set128E_neq _ (o + g %% 4) (o + (g + 2) %% 4)); 1: exact add_ne.
  rewrite (BArray128.get_set128E_neq _ (o + g %% 4) (o + (g + 3) %% 4)); 1: exact add_ne.
  have := hw 0 _; 1: done; rewrite /= => ->.
  rewrite (hw 1) // (hw 2) // (hw 3) //.
  rewrite (_ : 4 * (g + 1) = 4 * g + 4) 1:/# (_ : 4 * (g + 2) = 4 * g + 8) 1:/#.
  rewrite (_ : 4 * (g + 3) = 4 * g + 12) 1:/#.
  rewrite sha256su_sched4 1..4:hrec 1..4:/#.
  by rewrite -hj' wg_next //; congr; ring.
rewrite (BArray128.get_set128E_neq _ (o + g %% 4) (o + j)); 1: exact add_ne.
rewrite (BArray128.get_set128E_neq _ (o + g %% 4) (o + j)); 1: exact add_ne.
by rewrite hm // wg_other.
qed.

(* ------------------------------------------------------------------ *)
(* Lane invariants                                                    *)

(* Lane l of pair r has run groups 0 .. g - 1. *)
op lane_st (S : int -> state) (WS : int -> W32.t list) (st : BArray128.t) (r l g : int) =
  BArray128.get128 st (4 * r + 2 * l) = st4a (rounds (WS l) (S l) 0 (4 * g)) /\
  BArray128.get128 st (4 * r + 2 * l + 1) = st4e (rounds (WS l) (S l) 0 (4 * g)).

op lane_win (WS : int -> W32.t list) (m : BArray128.t) (l g : int) =
  forall j, 0 <= j < 4 => BArray128.get128 m (4 * l + j) = wv (WS l) (4 * wg g j).

(* Lane l of pair r after the feed-forward. *)
op lane_fin (S : int -> state) (WS : int -> W32.t list) (st : BArray128.t) (r l : int) =
  BArray128.get128 st (4 * r + 2 * l)
  = VADD_4u32 (st4a (rounds (WS l) (S l) 0 64)) (st4a (S l)) /\
  BArray128.get128 st (4 * r + 2 * l + 1)
  = VADD_4u32 (st4e (rounds (WS l) (S l) 0 64)) (st4e (S l)).

(* Only the slots of pair r change. *)
op frame (st0 st : BArray128.t) (r : int) =
  forall i, (i < 4 * r \/ 4 * r + 4 <= i) => BArray128.get128 st i = BArray128.get128 st0 i.

(* Slot i of the pair after g groups, as one function of i. *)
op rs (S : int -> state) (WS : int -> W32.t list) (g i : int) : W128.t =
  if i %% 2 = 0 then st4a (rounds (WS (i %/ 2)) (S (i %/ 2)) 0 (4 * g))
  else st4e (rounds (WS (i %/ 2)) (S (i %/ 2)) 0 (4 * g)).

lemma rs_lane S WS st r g :
  (forall l, 0 <= l < 2 => lane_st S WS st r l g) =>
  forall i, 0 <= i < 4 => BArray128.get128 st (4 * r + i) = rs S WS g i.
proof.
move=> h i hi; have [h0 h1] := h 0 _; 1: done.
have [h2 h3] := h 1 _; 1: done.
move: h0 h1 h2 h3; rewrite /rs /= => h0 h1 h2 h3.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
by case=> [->|[->|[->|->]]] /=; rewrite ?h0 ?h1 ?h2 ?h3.
qed.

lemma rs_fin S WS st r :
  (forall i, 0 <= i < 4 =>
     BArray128.get128 st (4 * r + i) = VADD_4u32 (rs S WS 16 i) (rs S WS 0 i)) =>
  forall l, 0 <= l < 2 => lane_fin S WS st r l.
proof.
move=> h l hl; rewrite /lane_fin.
have : l = 0 \/ l = 1 by smt().
case=> ->> /=.
+ by rewrite (h 0) // (h 1) // /rs /= !(rounds_nil _ _ 0 0).
by rewrite (h 2) // (h 3) // /rs /= !(rounds_nil _ _ 0 0).
qed.

abbrev kq (g : int) =
  p4 (nth W32.zero K256 (4 * g)) (nth W32.zero K256 (4 * g + 1))
     (nth W32.zero K256 (4 * g + 2)) (nth W32.zero K256 (4 * g + 3)).

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

lemma sha256_x8_block2_correct (S : int -> state) (WS : int -> W32.t list)
                               (st0 : BArray128.t) (r0 : int) :
  (forall l, 0 <= l < 2 => forall t, 16 <= t < 64 => srec (WS l) t) =>
  hoare [M.__sha256_x8_block2 :
           st = st0 /\ r = r0 /\ 0 <= r0 < 2 /\ k = sHA256_K /\
           (forall l, 0 <= l < 2 => lane_st S WS st0 r0 l 0 /\ lane_win WS m l 0) ==>
           (forall l, 0 <= l < 2 => lane_fin S WS res.`1 r0 l) /\ frame st0 res.`1 r0].
proof.
move=> hrec; proc.
(* feed-forward *)
wp.
while (0 <= j <= 4 /\ 0 <= r0 < 2 /\ r = r0 /\ frame st0 st r0 /\
       (forall i, 0 <= i < 4 => BArray64.get128 s0 i = rs S WS 0 i) /\
       (forall i, 0 <= i < 4 => BArray128.get128 st (4 * r0 + i)
          = if i < j then VADD_4u32 (rs S WS 16 i) (rs S WS 0 i) else rs S WS 16 i)).
+ wp; skip => /> &hr hj0 _ hr0 hr1 hfr hs0 hst hj4.
  have [hb1 hb2] := slot_ok (4 * r0) j{hr} _ _; 1,2: smt().
  split; first smt().
  split.
  + move=> i hio; rewrite BArray128.get_set128E_neq 1:/#.
    by apply hfr.
  move=> i hi0 hi4.
  case: (i = j{hr}) => [->>|ne].
  + rewrite (BArray128.get_set128E_eq _ (4 * r0 + j{hr}) (4 * r0 + j{hr}) _ hb1 hb2) //.
    by rewrite hst // hs0 // ifF 1:/# ifT 1:/#.
  rewrite BArray128.get_set128E_neq 1:/# hst //.
  by case: (i < j{hr}) => h; [rewrite ifT 1:/# | rewrite ifF 1:/#].
(* the 16 groups *)
wp.
while (0 <= g <= 16 /\ 0 <= r0 < 2 /\ r = r0 /\ k = sHA256_K /\ frame st0 st r0 /\
       (forall i, 0 <= i < 4 => BArray64.get128 s0 i = rs S WS 0 i) /\
       (forall l, 0 <= l < 2 => lane_st S WS st r0 l g /\ lane_win WS m l g)).
+ wp.
  while (0 <= l <= 2 /\ 0 <= g < 16 /\ 0 <= r0 < 2 /\ r = r0 /\ k = sHA256_K /\
         kv = kq g /\ frame st0 st r0 /\
         (forall i, 0 <= i < 4 => BArray64.get128 s0 i = rs S WS 0 i) /\
         (forall l', 0 <= l' < 2 =>
            lane_st S WS st r0 l' (if l' < l then g + 1 else g) /\
            lane_win WS m l' (if l' < l then g + 1 else g))).
  + seq 2 : (0 <= l < 2 /\ 0 <= g < 16 /\ 0 <= r0 < 2 /\ r = r0 /\ k = sHA256_K /\
             kv = kq g /\ frame st0 st r0 /\
             (forall i, 0 <= i < 4 => BArray64.get128 s0 i = rs S WS 0 i) /\
             (forall l', 0 <= l' < 2 => lane_st S WS st r0 l' (if l' < l then g + 1 else g)) /\
             (forall l', 0 <= l' < 2 => lane_win WS m l' (if l' <= l then g + 1 else g)) /\
             BArray32.get128 wk l = VADD_4u32 (kq g) (wv (WS l) (4 * g))).
    + seq 1 : (0 <= l < 2 /\ 0 <= g < 16 /\ 0 <= r0 < 2 /\ r = r0 /\ k = sHA256_K /\
               kv = kq g /\ frame st0 st r0 /\
               (forall i, 0 <= i < 4 => BArray64.get128 s0 i = rs S WS 0 i) /\
               (forall l', 0 <= l' < 2 => lane_st S WS st r0 l' (if l' < l then g + 1 else g)) /\
               (forall l', 0 <= l' < 2 => lane_win WS m l' (if l' < l then g + 1 else g)) /\
               BArray32.get128 wk l = VADD_4u32 (kq g) (wv (WS l) (4 * g))).
      + wp; skip => /> &hr hl0 _ hg0 hg16 hr0 hr1 hfr hs0 hln hl2.
        have [_ hw] := hln l{hr} _; 1: smt().
        move: hw; rewrite ifF 1:/# /lane_win => hw.
        split.
        + move=> l' h0 h1; have [h _] := hln l' _; 1: smt().
          by move: h; rewrite /lane_st.
        split.
        + move=> l' h0 h1; have [_ h] := hln l' _; 1: smt().
          exact h.
        rewrite BArray32.get_set128E_eq 1..3:/#.
        by rewrite (hw (g{hr} %% 4)) 1:/# wg_cur.
      if.
      + wp; skip => /> &hr hl0 hl2 hg0 hg16 hr0 hr1 hfr hs0 hst hwin hwk hg12 l' hl'0 hl'2.
        have hw := hwin l{hr} _; 1: smt().
        move: hw; rewrite ifF 1:/# => hw.
        have /= [hA hB] := win_step8 m{hr} (WS l{hr}) g{hr} (4 * l{hr}) _ _ (hrec l{hr} _) hw;
          1..3: smt().
        rewrite /lane_win => j [hj0 hj4].
        case: (l' = l{hr}) => [->>|ne].
        + by rewrite (_ : (l{hr} <= l{hr}) = true) 1:/# /= hA.
        rewrite hB; 1: exact (slot_other _ _ _ hl0 hl2 hl'0 hl'2 ne hj0 hj4).
        rewrite le_ne //.
        have := hwin l' _; 1: by split.
        by rewrite /lane_win => h; apply h.
      skip => /> &hr hl0 hl2 hg0 hg16 hr0 hr1 hfr hs0 hst hwin hwk hg12 l' hl'0 hl'2.
      have := hwin l' _; 1: smt().
      rewrite /lane_win => h j hj.
      rewrite h //; case: (l' = l{hr}) => [->>|ne].
      + rewrite (_ : (l{hr} < l{hr}) = false) 1:/# (_ : (l{hr} <= l{hr}) = true) 1:/# /=.
        by rewrite wg_hi 1:/#.
      by rewrite le_ne.
    wp; skip => /> &hr hl0 hl2 hg0 hg16 hr0 hr1 hfr hs0 hst hwin hwk.
    have [[hb0 hb1] [hb2 hb3]] := pair_ok r0 l{hr} _ _; 1,2: by split.
    have [hn1 hn2] := ne_succ (4 * r0 + 2 * l{hr}).
    have [ha he] := hst l{hr} _; 1: by split.
    move: ha he; rewrite ifF 1:/# => ha he.
    have [g1 g2] := group4 (WS l{hr}) (rounds (WS l{hr}) (S l{hr}) 0 (4 * g{hr})) (4 * g{hr}).
    rewrite (BArray128.get_set128E_neq _ (4 * r0 + 2 * l{hr}) (4 * r0 + 2 * l{hr} + 1)) //.
    rewrite (BArray32.get_set128E_eq _ l{hr} l{hr}) 1..3:/#.
    rewrite hwk ha he g1 g2 -rounds_g 1:/#.
    split; first smt().
    split.
    + move=> i hi.
      have [hi1 hi2] := pair_frame r0 l{hr} i _ hi; 1: by split.
      by rewrite !BArray128.get_set128E_neq // hfr.
    move=> l' hl'0 hl'2.
    case: (l' = l{hr}) => [->>|ne].
    + rewrite (BArray128.get_set128E_neq _ (4 * r0 + 2 * l{hr} + 1) (4 * r0 + 2 * l{hr})) //.
      rewrite (BArray128.get_set128E_eq _ (4 * r0 + 2 * l{hr}) (4 * r0 + 2 * l{hr})) //.
      rewrite (BArray128.get_set128E_eq _ (4 * r0 + 2 * l{hr} + 1) (4 * r0 + 2 * l{hr} + 1)) //.
      rewrite ifT 1:/# /=.
      have := hwin l{hr} _; 1: by split.
      by rewrite (_ : (l{hr} <= l{hr}) = true) 1:/#.
    have [o1 [o2 [o3 o4]]] := pair_other r0 l{hr} l' ne.
    rewrite !BArray128.get_set128E_neq //.
    rewrite lt_succ_ne //.
    have [] := hst l' _; 1: by split.
    move=> -> -> /=.
    have := hwin l' _; 1: by split.
    by rewrite le_ne.
  wp; skip => /> &hr hg0 _ hr0 hr1 hfr hs0 hln hg16.
  split.
  + split; first by rewrite kvec 1:/#.
    by move=> l' hl0 hl2; rewrite ifF 1:/#; apply hln.
  move=> l0 m0 st1 hl hl0 hl2 _ hfr1 hln1.
  have ->> : l0 = 2 by smt().
  split; first smt().
  move=> l1 hl10 hl12; have := hln1 l1 _; 1: smt().
  by rewrite ifT 1:/#.
(* the saved state *)
wp.
while (0 <= j <= 4 /\ st = st0 /\ r = r0 /\
       forall i, 0 <= i < j => BArray64.get128 s0 i = BArray128.get128 st0 (4 * r0 + i)).
+ wp; skip => /> &hr hj0 _ hi hj4; split; first smt().
  move=> i hi0 hi1; rewrite BArray64.get_set128E 1,2:/#.
  by case: (j{hr} = i) => [<-//|ne]; rewrite hi /#.
wp; skip => /> &hr hr0 hr1 hpre.
split; first smt().
move=> j0 s00 hj hj0 hj4 hs0.
split.
+ move=> i hi0 hi4; rewrite hs0 1:/#.
  by apply (rs_lane S WS st0 r0 0) => // l hl; have [] := hpre l hl.
move=> g0 m0 st1 hg hg0 hg16 hfr _ hln.
split.
+ move=> i hi0 hi4; rewrite ifF 1:/#.
  have ->> : g0 = 16 by smt().
  by apply (rs_lane S WS st1 r0 16) => // l hl; have [] := hln l hl.
move=> j1 st2 hj1 hj10 hj14 hfr2 hst2 l0 hl0 hl02.
have hfin : forall i, 0 <= i < 4 =>
  BArray128.get128 st2 (4 * r0 + i) = VADD_4u32 (rs S WS 16 i) (rs S WS 0 i).
+ by move=> i hi; rewrite hst2 1:/# ifT 1:/#.
have := rs_fin S WS st2 r0 hfin l0 _; 1: smt().
by rewrite /lane_fin.
qed.

(* Every loop runs over a constant range. *)
lemma sha256_x8_block2_ll : islossless M.__sha256_x8_block2.
proof.
proc; wp.
while (0 <= j <= 4) (4 - j); first by auto => /#.
wp; while (0 <= g <= 16) (16 - g).
+ move=> z; wp; while (0 <= l <= 2) (2 - l); first by auto => /#.
  by auto => /#.
wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
by auto => /#.
qed.
