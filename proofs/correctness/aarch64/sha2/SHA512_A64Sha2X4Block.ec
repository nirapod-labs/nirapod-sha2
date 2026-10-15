(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Sha2X4Block.ec (aarch64/sha2)
 * =======================================
 *
 * The two-lane block of the four-way AArch64 SHA-512 instruction kernel
 * (src/aarch64/sha2/sha512_x4_compress.jinc, FEAT_SHA512):
 * __sha512_x4_block2 s m k runs the 80 rounds and the feed-forward of
 * section 6.4.2 on two lanes at once, interleaved pair of rounds by pair
 * of rounds.
 *
 * Representation. Lane l (0 or 1) keeps the one-way kernel's layout
 * (SHA512_A64Sha2.ec) in the five slots s[5l .. 5l + 4]: at the head of
 * pair g, [a; b], [c; d], [e; f], [g; h] are in s[5l + pi0 (g mod 5)] ..
 * s[5l + pi3 (g mod 5)]. Its message window is m[8l .. 8l + 7]; at the
 * head of pair g, m[8l + j] holds the schedule words of pair wg8 g j.
 * Both lanes share the slot names i0 .. i4 and the constant vector, so
 * the renaming at the end of a pair serves both.
 *
 * The proof is lane by lane: each lane meets the invariant of the one-way
 * kernel, discharged by the same lemmas, and the other lane's slots are
 * untouched.
 *
 * Theorems:
 *     sha512_x4_block2_correct  both lanes end with rounds 0 .. 79 plus
 *                               the feed-forward (partial correctness);
 *     sha512_x4_block2_ll       termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray128 BArray160 BArray256 BArray640.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds512 Vec Sha2Insn SHA512_A64Sha2.
import SHA512 A512.

(* ------------------------------------------------------------------ *)
(* Index facts                                                        *)

lemma addK_eq (o a b : int) : (o + a = o + b) = (a = b).
proof. smt(). qed.

lemma x4_range2 (l : int) : 0 <= l < 2 => l = 0 \/ l = 1.
proof. smt(). qed.

lemma x4_lt_succ (a b : int) : (a < b + 1) = (a <= b).
proof. smt(). qed.

lemma x4_le_ne (a b : int) : a <> b => (a <= b) = (a < b).
proof. smt(). qed.

lemma x4_other5 (l l' x : int) : 0 <= l < 2 => 0 <= l' < 2 => l' <> l => 0 <= x < 5 =>
  5 * l' + x < 5 * l \/ 5 * l + 5 <= 5 * l' + x.
proof. smt(). qed.

lemma x4_other8 (l l' x : int) : 0 <= l < 2 => 0 <= l' < 2 => l' <> l => 0 <= x < 8 =>
  8 * l' + x < 8 * l \/ 8 * l + 8 <= 8 * l' + x.
proof. smt(). qed.

lemma x4_out5 (o y i : int) : 0 <= i < 5 => (y < o \/ o + 5 <= y) => (y = o + i) = false.
proof. smt(). qed.

lemma x4_ne4 (l l' j j' : int) : l' <> l => 0 <= j < 4 => 0 <= j' < 4 =>
  4 * l + j <> 4 * l' + j'.
proof. smt(). qed.

lemma x4_ne5 (l l' j j' : int) : l' <> l => 0 <= j < 5 => 0 <= j' < 5 =>
  5 * l + j <> 5 * l' + j'.
proof. smt(). qed.

lemma pi_range r : 0 <= pi0 (r %% 5) < 5 /\ 0 <= pi1 (r %% 5) < 5 /\
  0 <= pi2 (r %% 5) < 5 /\ 0 <= pi3 (r %% 5) < 5.
proof. by have [h0 [h1 [h2 [h3 _]]]] := pi_slots (r %% 5) _; 1: smt(). qed.

(* ------------------------------------------------------------------ *)
(* One pair of rounds on the slots of one lane                        *)

(* pair_step of SHA512_A64Sha2.ec on the slots s[o .. o + 4]; the slots
   outside are unchanged. *)
lemma pair_step160 (s : BArray160.t) (o i0 i1 i2 i3 i4 : int) (S : state)
                   (ws : W64.t list) (t : int) (wk : W128.t) :
  0 <= o <= 5 =>
  0 <= i0 < 5 => 0 <= i1 < 5 => 0 <= i2 < 5 => 0 <= i3 < 5 => 0 <= i4 < 5 =>
  i0 <> i1 => i0 <> i2 => i0 <> i3 => i0 <> i4 => i1 <> i2 => i1 <> i3 =>
  i1 <> i4 => i2 <> i3 => i2 <> i4 => i3 <> i4 =>
  BArray160.get128 s (o + i0) = p2 S.`1 S.`2 => BArray160.get128 s (o + i1) = p2 S.`3 S.`4 =>
  BArray160.get128 s (o + i2) = p2 S.`5 S.`6 => BArray160.get128 s (o + i3) = p2 S.`7 S.`8 =>
  wk = kw2 ws t =>
  let s1 = BArray160.set128 s (o + i3) (VADD_2u64 (BArray160.get128 s (o + i3)) wk) in
  let s2 = BArray160.set128 s1 (o + i3)
             (SHA512H (BArray160.get128 s1 (o + i3))
                (VEXT (BArray160.get128 s (o + i2)) (BArray160.get128 s (o + i3)) (W8.of_int 8))
                (VEXT (BArray160.get128 s (o + i1)) (BArray160.get128 s (o + i2)) (W8.of_int 8))) in
  let s3 = BArray160.set128 s2 (o + i4)
             (VADD_2u64 (BArray160.get128 s2 (o + i1)) (BArray160.get128 s2 (o + i3))) in
  let s4 = BArray160.set128 s3 (o + i3)
             (SHA512H2 (BArray160.get128 s3 (o + i3)) (BArray160.get128 s3 (o + i1))
                (BArray160.get128 s3 (o + i0))) in
  (BArray160.get128 s4 (o + i3) = p2 (rounds ws S t (t + 2)).`1 (rounds ws S t (t + 2)).`2 /\
   BArray160.get128 s4 (o + i0) = p2 (rounds ws S t (t + 2)).`3 (rounds ws S t (t + 2)).`4 /\
   BArray160.get128 s4 (o + i4) = p2 (rounds ws S t (t + 2)).`5 (rounds ws S t (t + 2)).`6 /\
   BArray160.get128 s4 (o + i2) = p2 (rounds ws S t (t + 2)).`7 (rounds ws S t (t + 2)).`8) /\
  (forall y, (y < o \/ o + 5 <= y) => BArray160.get128 s4 y = BArray160.get128 s y).
proof.
move=> ho r0 r1 r2 r3 r4 d01 d02 d03 d04 d12 d13 d14 d23 d24 d34 h0 h1 h2 h3 hwk /=.
have [e1 [e2 [e3 e4]]] := sha512h_rounds2 ws t S.
move: e1 e2; rewrite /h512 => e1 e2.
have g3 : forall (u : BArray160.t) y w,
  BArray160.get128 (BArray160.set128 u (o + i3) w) y
  = if y = o + i3 then w else BArray160.get128 u y.
+ by move=> u y w; rewrite BArray160.get_set128E 1,2:/# (eq_sym y).
have g4 : forall (u : BArray160.t) y w,
  BArray160.get128 (BArray160.set128 u (o + i4) w) y
  = if y = o + i4 then w else BArray160.get128 u y.
+ by move=> u y w; rewrite BArray160.get_set128E 1,2:/# (eq_sym y).
have [n43 [n23 [n13 [n14 n24]]]] :
  i4 <> i3 /\ i2 <> i3 /\ i1 <> i3 /\ i1 <> i4 /\ i2 <> i4 by smt().
split.
+ rewrite !g3 ?g4 ?g3 ?g4 ?g3 /= !addK_eq ?d03 ?d04 ?d34 ?n43 ?n23 ?n13 ?n14 ?n24 /=.
  by rewrite h0 h1 h2 h3 hwk /rounds -e1 -e2 -e3 -e4.
move=> y hy.
have f3 := x4_out5 o y i3 r3 hy; have f4 := x4_out5 o y i4 r4 hy.
by do 4! (rewrite ?g3 ?g4 ?f3 ?f4 /=).
qed.

(* ------------------------------------------------------------------ *)
(* The message window                                                 *)

(* Pair of schedule words held by window slot j at the head of pair g. *)
op wg8 (g j : int) : int = if g <= 32 then g + (j - g) %% 8 else 32 + (j - 32) %% 8.

lemma wg8_0 j : 0 <= j < 8 => wg8 0 j = j.
proof. by move=> hj; rewrite /wg8 /= modz_small 1:/#. qed.

lemma wg8_rd g i : 0 <= g <= 32 => 0 <= i < 8 => wg8 g ((g %% 8 + i) %% 8) = g + i.
proof. by move=> hg hi; rewrite /wg8 ifT 1:/# win_idx. qed.

lemma wg8_cur g : 0 <= g < 40 => wg8 g (g %% 8) = g.
proof.
move=> hg; case: (g <= 32) => h.
+ by rewrite /wg8 ifT // (_ : (g %% 8 - g) %% 8 = 0) 1:/#.
by rewrite /wg8 ifF 1:/# win_last /#.
qed.

lemma wg8_hi g j : 32 <= g < 40 => wg8 (g + 1) j = wg8 g j.
proof.
move=> hg; rewrite /wg8 ifF 1:/#.
by case: (g <= 32) => h //; have ->> : g = 32 by smt().
qed.

lemma wg8_other g j : 0 <= g < 32 => 0 <= j < 8 => g %% 8 <> j =>
  wg8 (g + 1) j = wg8 g j.
proof. by move=> hg hj hne; rewrite /wg8 ifT 1:/# ifT 1:/# (win_other g j). qed.

lemma wg8_next g : 0 <= g < 32 => wg8 (g + 1) (g %% 8) = g + 8.
proof.
move=> hg; rewrite /wg8 ifT 1:/#.
have -> : g %% 8 - (g + 1) = (-1) + (- (g %/ 8)) * 8 by smt(divz_eq).
by rewrite modzMDr.
qed.

lemma mod8_ne7 g : g %% 8 <> (g %% 8 + 7) %% 8.
proof. smt(). qed.

lemma slot8_ok (o i : int) : 0 <= o <= 8 => 0 <= i < 8 =>
  0 <= o + i /\ 16 * (o + i + 1) <= 256.
proof. smt(). qed.

lemma add_ne8 (o a b : int) : a <> b => o + a <> o + b.
proof. smt(). qed.

(* Pair g < 32 of the lane whose window is m[o .. o + 7] replaces m[o +
   g mod 8] by the words of pair g + 8; the rest of m is unchanged. *)
lemma win_step256 (m : BArray256.t) (ws : W64.t list) (g o : int) :
  0 <= g < 32 => 0 <= o <= 8 => (forall t, 16 <= t < 80 => srec ws t) =>
  (forall j, 0 <= j < 8 => BArray256.get128 m (o + j) = wv2 ws (2 * wg8 g j)) =>
  let m1 = BArray256.set128 m (o + g %% 8)
             (SHA512SU0 (BArray256.get128 m (o + g %% 8))
                        (BArray256.get128 m (o + (g %% 8 + 1) %% 8))) in
  let m2 = BArray256.set128 m1 (o + g %% 8)
             (SHA512SU1 (BArray256.get128 m1 (o + g %% 8))
                        (BArray256.get128 m1 (o + (g %% 8 + 7) %% 8))
                        (VEXT (BArray256.get128 m (o + (g %% 8 + 4) %% 8))
                              (BArray256.get128 m (o + (g %% 8 + 5) %% 8)) (W8.of_int 8))) in
  (forall j, 0 <= j < 8 => BArray256.get128 m2 (o + j) = wv2 ws (2 * wg8 (g + 1) j)) /\
  (forall i, (i < o \/ o + 8 <= i) => BArray256.get128 m2 i = BArray256.get128 m i).
proof.
move=> hg ho hrec hm /=.
have hi : 0 <= g %% 8 < 8 by smt().
have [hb1 hb2] := slot8_ok o (g %% 8) ho hi.
have hn7 := mod8_ne7 g.
have hw : forall i, 0 <= i < 8 =>
  BArray256.get128 m (o + (g %% 8 + i) %% 8) = wv2 ws (2 * (g + i)).
+ by move=> i hi'; rewrite hm 1:/# wg8_rd 1,2:/#.
have hw0 : BArray256.get128 m (o + g %% 8) = wv2 ws (2 * g).
+ by have := hw 0 _; rewrite //= modz_mod.
split; last first.
+ move=> i hio.
  by rewrite BArray256.get_set128E_neq 1:/# BArray256.get_set128E_neq 1:/#.
move=> j hj.
case: (g %% 8 = j) => hj'.
+ rewrite (BArray256.get_set128E_eq _ (o + g %% 8) (o + j) _ hb1 hb2); 1: by rewrite hj'.
  rewrite (BArray256.get_set128E_eq _ (o + g %% 8) (o + g %% 8) _ hb1 hb2) //.
  rewrite (BArray256.get_set128E_neq _ (o + g %% 8) (o + (g %% 8 + 7) %% 8)); 1: exact add_ne8.
  rewrite hw0 (hw 1) // (hw 4) // (hw 5) // (hw 7) //.
  rewrite (_ : 2 * (g + 1) = 2 * g + 2) 1:/# (_ : 2 * (g + 4) = 2 * g + 8) 1:/#.
  rewrite (_ : 2 * (g + 5) = 2 * g + 10) 1:/# (_ : 2 * (g + 7) = 2 * g + 14) 1:/#.
  rewrite sha512su_sched2 1,2:hrec 1,2:/#.
  by rewrite -hj' wg8_next //; congr; ring.
rewrite (BArray256.get_set128E_neq _ (o + g %% 8) (o + j)); 1: exact add_ne8.
rewrite (BArray256.get_set128E_neq _ (o + g %% 8) (o + j)); 1: exact add_ne8.
by rewrite hm // wg8_other.
qed.

(* ------------------------------------------------------------------ *)
(* Lane invariants                                                    *)

(* Lane l has run pairs 0 .. g - 1. *)
op lst (S : int -> state) (WS : int -> W64.t list) (s : BArray160.t) (l g : int) =
  BArray160.get128 s (5 * l + pi0 (g %% 5))
    = p2 (rounds (WS l) (S l) 0 (2 * g)).`1 (rounds (WS l) (S l) 0 (2 * g)).`2 /\
  BArray160.get128 s (5 * l + pi1 (g %% 5))
    = p2 (rounds (WS l) (S l) 0 (2 * g)).`3 (rounds (WS l) (S l) 0 (2 * g)).`4 /\
  BArray160.get128 s (5 * l + pi2 (g %% 5))
    = p2 (rounds (WS l) (S l) 0 (2 * g)).`5 (rounds (WS l) (S l) 0 (2 * g)).`6 /\
  BArray160.get128 s (5 * l + pi3 (g %% 5))
    = p2 (rounds (WS l) (S l) 0 (2 * g)).`7 (rounds (WS l) (S l) 0 (2 * g)).`8.

op lwin (WS : int -> W64.t list) (m : BArray256.t) (l g : int) =
  forall j, 0 <= j < 8 => BArray256.get128 m (8 * l + j) = wv2 (WS l) (2 * wg8 g j).

(* The saved input state of both lanes. *)
op saved (S : int -> state) (save : BArray128.t) =
  forall l j, 0 <= l < 2 => 0 <= j < 4 => BArray128.get128 save (4 * l + j) = spair (S l) j.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

lemma sha512_x4_block2_correct (S : int -> state) (WS : int -> W64.t list) :
  (forall l, 0 <= l < 2 => forall t, 16 <= t < 80 => srec (WS l) t) =>
  hoare [M.__sha512_x4_block2 :
           k = sHA512_K /\
           (forall l, 0 <= l < 2 =>
              (forall j, 0 <= j < 4 => BArray160.get128 s (5 * l + j) = spair (S l) j) /\
              (forall j, 0 <= j < 8 => BArray256.get128 m (8 * l + j) = wv2 (WS l) (2 * j))) ==>
           forall l, 0 <= l < 2 => forall j, 0 <= j < 4 =>
             BArray160.get128 res.`1 (5 * l + j)
             = VADD_2u64 (spair (rounds (WS l) (S l) 0 80) j) (spair (S l) j)].
proof.
move=> hrec; proc.
(* feed-forward *)
while (0 <= l <= 2 /\ saved S save /\
       (forall l' j', 0 <= l' < l => 0 <= j' < 4 =>
          BArray160.get128 s (5 * l' + j')
          = VADD_2u64 (spair (rounds (WS l') (S l') 0 80) j') (spair (S l') j')) /\
       (forall l' j', l <= l' < 2 => 0 <= j' < 4 =>
          BArray160.get128 s (5 * l' + j') = spair (rounds (WS l') (S l') 0 80) j')).
+ wp.
  while (0 <= j <= 4 /\ 0 <= l < 2 /\ saved S save /\
         (forall l' j', 0 <= l' < l => 0 <= j' < 4 =>
            BArray160.get128 s (5 * l' + j')
            = VADD_2u64 (spair (rounds (WS l') (S l') 0 80) j') (spair (S l') j')) /\
         (forall j', 0 <= j' < j =>
            BArray160.get128 s (5 * l + j')
            = VADD_2u64 (spair (rounds (WS l) (S l) 0 80) j') (spair (S l) j')) /\
         (forall j', j <= j' < 4 =>
            BArray160.get128 s (5 * l + j') = spair (rounds (WS l) (S l) 0 80) j') /\
         (forall l' j', l < l' < 2 => 0 <= j' < 4 =>
            BArray160.get128 s (5 * l' + j') = spair (rounds (WS l') (S l') 0 80) j')).
  + wp; skip => /> &hr hj0 _ hl0 hl2 hsv hdone hcur htodo hrest hj4.
    have hne : forall l' j', l' <> l{hr} => 0 <= j' < 4 =>
      BArray160.get128 (BArray160.set128 s{hr} (5 * l{hr} + j{hr})
        (VADD_2u64 (BArray160.get128 s{hr} (5 * l{hr} + j{hr}))
                   (BArray128.get128 save{hr} (4 * l{hr} + j{hr})))) (5 * l' + j')
      = BArray160.get128 s{hr} (5 * l' + j').
    + move=> l' j' hne hj'; rewrite BArray160.get_set128E_neq //.
      by apply x4_ne5 => /#.
    split; first smt().
    split; first by move=> l' j' h0 h1 h2 h3; rewrite hne 1,2:/#; apply hdone.
    split.
    + move=> j' h0 h1; case: (j' = j{hr}) => [->>|ne].
      + rewrite BArray160.get_set128E_eq 1..3:/#.
        by rewrite htodo 1:/# hsv 1,2:/#.
      by rewrite BArray160.get_set128E_neq 1:/#; apply hcur => /#.
    split.
    + by move=> j' h0 h1; rewrite BArray160.get_set128E_neq 1:/#; apply htodo => /#.
    by move=> l' j' h0 h1 h2 h3; rewrite hne 1,2:/#; apply hrest.
  wp; skip => /> &hr hl0 _ hsv hdone htodo hl2.
  split.
  + do! split; first 2 smt().
    by move=> l' j' h0 h1 h2 h3; apply htodo => /#.
  move=> j0 s0 hj hj0 hj4 hdone' hcur htodo' hrest.
  have ->> : j0 = 4 by smt().
  split; first smt().
  split.
  + move=> l' j' h0 h1 h2 h3.
    by case: (l' = l{hr}) => [->>|ne]; [apply hcur | apply hdone' => /#].
  by move=> l' j' h0 h1 h2 h3; apply hrest => /#.
(* the 40 pairs *)
wp.
while (0 <= g <= 40 /\ k = sHA512_K /\ saved S save /\
       i0 = pi0 (g %% 5) /\ i1 = pi1 (g %% 5) /\ i2 = pi2 (g %% 5) /\
       i3 = pi3 (g %% 5) /\ i4 = pi4 (g %% 5) /\
       (forall l, 0 <= l < 2 => lst S WS s l g /\ lwin WS m l g)).
+ wp.
  while (0 <= l <= 2 /\ 0 <= g < 40 /\ k = sHA512_K /\ saved S save /\
         i0 = pi0 (g %% 5) /\ i1 = pi1 (g %% 5) /\ i2 = pi2 (g %% 5) /\
         i3 = pi3 (g %% 5) /\ i4 = pi4 (g %% 5) /\ j = g %% 8 /\
         kv = BArray640.get128 sHA512_K g /\
         (forall l', 0 <= l' < 2 =>
            lst S WS s l' (if l' < l then g + 1 else g) /\
            lwin WS m l' (if l' < l then g + 1 else g))).
  + swap 6 3.
    wp; skip => /> &hr hl0 _ hg0 hg40 hsv hln hl2.
    have [hst hw] := hln l{hr} _; 1: smt().
    move: hst hw; rewrite ifF 1:/# /lst /lwin => [#] h0 h1 h2 h3 hw.
    have hG : 0 <= g{hr} %% 5 < 5 by smt().
    have [r0 [r1 [r2 [r3 [r4 [d01 [d02 [d03 [d04 [d12 [d13 [d14 [d23 [d24 d34]]]]]]]]]]]]]] :=
      pi_slots (g{hr} %% 5) hG.
    have [e0 [e1 [e2 [e3 e4]]]] := pi_step g{hr} hg0.
    have hw0 : BArray256.get128 m{hr} (8 * l{hr} + g{hr} %% 8) = wv2 (WS l{hr}) (2 * g{hr}).
    + by rewrite hw 1:/# wg8_cur 1:/#.
    have hwk : VEXT (VADD_2u64 (BArray640.get128 sHA512_K g{hr})
                               (BArray256.get128 m{hr} (8 * l{hr} + g{hr} %% 8)))
                    (VADD_2u64 (BArray640.get128 sHA512_K g{hr})
                               (BArray256.get128 m{hr} (8 * l{hr} + g{hr} %% 8)))
                    (W8.of_int 8) = kw2 (WS l{hr}) (2 * g{hr}).
    + by rewrite kvec 1:/# hw0.
    have /= [[q0 [q1 [q2 q3]]] hfr] := pair_step160 s{hr} (5 * l{hr}) _ _ _ _ _ _ (WS l{hr})
      (2 * g{hr}) _ _ r0 r1 r2 r3 r4 d01 d02 d03 d04 d12 d13 d14 d23 d24 d34 h0 h1 h2 h3 hwk;
      1: smt().
    have hlane : forall l', 0 <= l' < 2 => l' <> l{hr} =>
      forall x, 0 <= x < 5 => 5 * l' + x < 5 * l{hr} \/ 5 * l{hr} + 5 <= 5 * l' + x.
    + by move=> l' hl' ne x hx; apply x4_other5 => //; smt().
    split.
    + move=> hlt.
      have /= [hA hB] := win_step256 m{hr} (WS l{hr}) g{hr} (8 * l{hr}) _ _ (hrec l{hr} _) hw;
        1..3: smt().
      split; first smt().
      move=> l' hl'0 hl'1.
      case: (l' = l{hr}) => [->>|ne].
      + rewrite ifT 1:/# e0 e1 e2 e3 q0 q1 q2 q3 rounds_g 1:/# /=.
        by move=> j' hj'; apply hA.
      rewrite x4_lt_succ x4_le_ne //.
      have [hs' hw'] := hln l' _; 1: smt().
      have [p0 [p1 [p2 p3]]] := pi_range (if l' < l{hr} then g{hr} + 1 else g{hr}).
      move: hs'; rewrite /lst => [#] <- <- <- <-.
      rewrite !hfr; 1..4: by apply hlane.
      split; first done.
      move: hw'; rewrite /lwin => hw' j' hj'.
      by rewrite hB; [apply x4_other8 => // /# | apply hw'].
    move=> hge.
    split; first smt().
    move=> l' hl'0 hl'1.
    case: (l' = l{hr}) => [->>|ne].
    + rewrite ifT 1:/# e0 e1 e2 e3 q0 q1 q2 q3 rounds_g 1:/# /=.
      by move=> j' hj'; rewrite hw // wg8_hi 1:/#.
    rewrite x4_lt_succ x4_le_ne //.
    have [hs' hw'] := hln l' _; 1: smt().
    have [p0 [p1 [p2 p3]]] := pi_range (if l' < l{hr} then g{hr} + 1 else g{hr}).
    move: hs'; rewrite /lst => [#] <- <- <- <-.
    rewrite !hfr; 1..4: by apply hlane.
    by split.
  wp; skip => /> &hr hg0 _ hsv hln hg40.
  split.
  + move=> l' h0 h1; rewrite ifF 1:/#.
    by have := hln l' _; [smt() | rewrite /lst].
  move=> l0 m0 s0 hl hl0 hl2 hln'.
  have ->> : l0 = 2 by smt().
  have [e0 [e1 [e2 [e3 e4]]]] := pi_step g{hr} _; 1: smt().
  split; first smt().
  rewrite e0 e1 e2 e3 e4 /=.
  move=> l1 h0 h1; have := hln' l1 _; 1: smt().
  by rewrite ifT 1:/# /lst e0 e1 e2 e3.
(* the saved state *)
wp.
while (0 <= l <= 2 /\ k = sHA512_K /\
       (forall l', 0 <= l' < 2 =>
          (forall j, 0 <= j < 4 => BArray160.get128 s (5 * l' + j) = spair (S l') j) /\
          (forall j, 0 <= j < 8 => BArray256.get128 m (8 * l' + j) = wv2 (WS l') (2 * j))) /\
       (forall l' j', 0 <= l' < l => 0 <= j' < 4 =>
          BArray128.get128 save (4 * l' + j') = spair (S l') j')).
+ wp.
  while (0 <= j <= 4 /\ 0 <= l < 2 /\ k = sHA512_K /\
         (forall l', 0 <= l' < 2 =>
            (forall j, 0 <= j < 4 => BArray160.get128 s (5 * l' + j) = spair (S l') j) /\
            (forall j, 0 <= j < 8 => BArray256.get128 m (8 * l' + j) = wv2 (WS l') (2 * j))) /\
         (forall l' j', 0 <= l' < l => 0 <= j' < 4 =>
            BArray128.get128 save (4 * l' + j') = spair (S l') j') /\
         (forall j', 0 <= j' < j => BArray128.get128 save (4 * l + j') = spair (S l) j')).
  + wp; skip => /> &hr hj0 _ hl0 hl2 hpre hdone hcur hj4.
    split; first smt().
    split.
    + move=> l' j' h0 h1 h2 h3.
      rewrite BArray128.get_set128E_neq; 1: by apply x4_ne4 => /#.
      by apply hdone.
    move=> j' h0 h1; case: (j' = j{hr}) => [->>|ne].
    + rewrite BArray128.get_set128E_eq 1..3:/#.
      by have [hs _] := hpre l{hr} _; [smt() | apply hs => /#].
    by rewrite BArray128.get_set128E_neq 1:/#; apply hcur => /#.
  wp; skip => /> &hr hl0 _ hpre hdone hl2.
  split; first smt().
  move=> j0 save0 hj hj0 hj4 hdone' hcur.
  have ->> : j0 = 4 by smt().
  split; first smt().
  move=> l' j' h0 h1 h2 h3.
  case: (l' = l{hr}) => [->>|ne]; first by apply hcur.
  by apply hdone' => /#.
wp; skip => /> &hr hpre.
split; first smt().
move=> l0 save0 hl hl0 hl2 hsv.
have ->> : l0 = 2 by smt().
have hsaved : saved S save0 by move=> l j hl' hj; apply hsv.
split.
+ split; first exact hsaved.
  move=> l1 h0 h1; have [hs hm] := hpre l1 _; 1: smt().
  rewrite (rounds_nil _ _ 0 0) //.
  split; last by rewrite /lwin => j hj; rewrite hm // wg8_0.
  have e0 := hs 0 _; 1: done.
  have e1 := hs 1 _; 1: done.
  have e2 := hs 2 _; 1: done.
  have e3 := hs 3 _; 1: done.
  move: e0 e1 e2 e3; rewrite /pi0 /pi1 /pi2 /pi3 /spair /= => -> -> -> -> //.
move=> g0 m0 s0 hg hg0 hg40 _ hln.
have ->> : g0 = 40 by smt().
split.
+ split; first smt().
  move=> l' j' h0 h1 h2 h3.
  have [hst _] := hln l' _; 1: smt().
  move: hst; rewrite /lst /pi0 /pi1 /pi2 /pi3 /= => [#] e0 e1 e2 e3.
  have := range4 j' h2 h3.
  by case=> [->>|[->>|[->>|->>]]]; rewrite /spair /= ?e0 ?e1 ?e2 ?e3.
move=> l1 s1 hl1 hl10 hl12 hdone _ l2 h0 h1 j0 h2 h3.
have ->> : l1 = 2 by smt().
by apply hdone => /#.
qed.

(* Every loop runs over a constant range. *)
lemma sha512_x4_block2_ll : islossless M.__sha512_x4_block2.
proof.
proc.
while (0 <= l <= 2) (2 - l).
+ move=> z; wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
  by auto => /#.
wp; while (0 <= g <= 40) (40 - g).
+ move=> z; wp; while (0 <= l <= 2) (2 - l); first by auto => /#.
  by auto => /#.
wp; while (0 <= l <= 2) (2 - l).
+ move=> z; wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
  by auto => /#.
by auto => /#.
qed.
