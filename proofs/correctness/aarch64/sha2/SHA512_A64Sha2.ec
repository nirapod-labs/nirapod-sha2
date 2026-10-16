(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Sha2.ec (aarch64/sha2)
 * ================================
 *
 * Functional correctness of the one-block entry point _sha512_compress of
 * the AArch64 SHA-512 instruction kernel (src/aarch64/sha2/
 * sha512_compress.jinc, FEAT_SHA512) against FIPS 180-4 section 6.4.2 as
 * specified in spec/FIPS180_SHA2.ec. The entry point that reads blocks
 * from memory, _sha512_compress_blocks, is proven in
 * SHA512_A64Sha2Blocks.ec.
 *
 * Model. NirapodSha2 is the jasmin2ec model of a unit; this file is
 * checked on every unit whose Sha512Kernel root is src/aarch64/sha2
 * (proofs/Makefile). The instructions are used through the lemmas of
 * Sha2Insn (SHA512H, SHA512H2 with VEXT #8 and VADD: two rounds;
 * SHA512SU0, SHA512SU1: two schedule words) and Vec (VREV64_16u8).
 *
 * Representation. The chaining value h is u64[8], H_0 .. H_7 as native
 * words (hwords). The kernel keeps the working variables as four pairs
 * [a; b], [c; d], [e; f], [g; h] in four of the five slots of s; slot
 * i0 holds [a; b], i1 [c; d], i2 [e; f], i3 [g; h], and i4 is free. Each
 * pair of rounds writes the new [e; f] into the free slot and the new
 * [a; b] over the old [g; h], then renames the slots, so the slot
 * indices of pair g depend only on g mod 5 (pi0 .. pi4). The message is
 * a window of eight vectors m[0 .. 7]; pair g reads W_2g, W_2g+1 from
 * m[g mod 8] and, for g < 32, replaces them by W_2g+16, W_2g+17. At the
 * head of pair g, m[j] holds the words of pair g + ((j - g) mod 8).
 *
 * Theorems:
 *     sha512_block_a64_correct  __sha512_block_a64 computes the 80 rounds
 *                               and the feed-forward on a state held in
 *                               s[0 .. 3], for any schedule that satisfies
 *                               the recurrence of step 1 (partial
 *                               correctness);
 *     sha512_compress_correct   _sha512_compress computes compress on the
 *                               big-endian words of the 128-byte block
 *                               (partial correctness);
 *     sha512_compress_total     the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray64 BArray80 BArray128 BArray640.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds512 Vec Sha2Insn Arrays.
import SHA512 A512.

clone Arrays.Words as Arr64 with theory A <= BArray64.
clone Arrays.Words as Arr80 with theory A <= BArray80.
clone Arrays.Words as Arr128 with theory A <= BArray128.
clone Arrays.Words as Arr640 with theory A <= BArray640.

op hwords (h : BArray64.t) : W64.t list = map (BArray64.get64 h) (iota_ 0 8).

lemma nth_hwords h k : 0 <= k < 8 => nth W64.zero (hwords h) k = BArray64.get64 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

lemma range8 (k : int) : 0 <= k < 8 =>
  k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7.
proof. smt(). qed.

(* ------------------------------------------------------------------ *)
(* The round-constant table, two constants per 128-bit read           *)

lemma K512_kernel t : 0 <= t < 80 =>
  BArray640.get64 sHA512_K t = nth W64.zero K512 t.
proof.
move=> ht; rewrite BArray640.get64_of_list64 1://.
by congr; rewrite /K512 /=.
qed.

lemma kvec g : 0 <= g < 40 =>
  BArray640.get128 sHA512_K g
  = p2 (nth W64.zero K512 (2 * g)) (nth W64.zero K512 (2 * g + 1)).
proof.
move=> hg; rewrite {1}(p2_bits (BArray640.get128 sHA512_K g)).
rewrite !Arr640.get128d_bits64 //.
have e : forall i, 0 <= i < 2 =>
  BArray640.get64d sHA512_K (16 * g + 8 * i) = nth W64.zero K512 (2 * g + i).
+ move=> i hi; rewrite -K512_kernel 1:/#.
  by congr; ring.
by rewrite (e 0) // (e 1).
qed.

(* ------------------------------------------------------------------ *)
(* The slot names of pair g                                           *)

op pi0 (r : int) : int = nth 0 [0; 3; 2; 4; 1] r.
op pi1 (r : int) : int = nth 0 [1; 0; 3; 2; 4] r.
op pi2 (r : int) : int = nth 0 [2; 4; 1; 0; 3] r.
op pi3 (r : int) : int = nth 0 [3; 2; 4; 1; 0] r.
op pi4 (r : int) : int = nth 0 [4; 1; 0; 3; 2] r.

(* The renaming t = i0; i0 = i3; i3 = i2; i2 = i4; i4 = i1; i1 = t. *)
lemma pi_step g : 0 <= g =>
  pi0 ((g + 1) %% 5) = pi3 (g %% 5) /\ pi1 ((g + 1) %% 5) = pi0 (g %% 5) /\
  pi2 ((g + 1) %% 5) = pi4 (g %% 5) /\ pi3 ((g + 1) %% 5) = pi2 (g %% 5) /\
  pi4 ((g + 1) %% 5) = pi1 (g %% 5).
proof.
move=> hg; rewrite -modzDml.
have : g %% 5 = 0 \/ g %% 5 = 1 \/ g %% 5 = 2 \/ g %% 5 = 3 \/ g %% 5 = 4 by smt().
by case=> [->|[->|[->|[->|->]]]].
qed.

(* The five slots of every pair are distinct, and in range. *)
lemma pi_slots r : 0 <= r < 5 =>
  0 <= pi0 r < 5 /\ 0 <= pi1 r < 5 /\ 0 <= pi2 r < 5 /\ 0 <= pi3 r < 5 /\ 0 <= pi4 r < 5 /\
  pi0 r <> pi1 r /\ pi0 r <> pi2 r /\ pi0 r <> pi3 r /\ pi0 r <> pi4 r /\
  pi1 r <> pi2 r /\ pi1 r <> pi3 r /\ pi1 r <> pi4 r /\
  pi2 r <> pi3 r /\ pi2 r <> pi4 r /\ pi3 r <> pi4 r.
proof.
move=> hr; have : r = 0 \/ r = 1 \/ r = 2 \/ r = 3 \/ r = 4 by smt().
by case=> [->|[->|[->|[->|->]]]].
qed.

(* ------------------------------------------------------------------ *)
(* One pair of rounds on the slots                                    *)

(* The four statements of a pair on s, with [a; b], [c; d], [e; f],
   [g; h] in slots i0, i1, i2, i3 and wk = [K_t+1 + W_t+1; K_t + W_t]:
   afterwards slot i3 holds the new [a; b], i0 the new [c; d], i4 the new
   [e; f] and i2 the new [g; h] (sha512h_rounds2). *)
lemma pair_step (s : BArray80.t) (i0 i1 i2 i3 i4 : int) (S : state)
                (ws : W64.t list) (t : int) (wk : W128.t) :
  0 <= i0 < 5 => 0 <= i1 < 5 => 0 <= i2 < 5 => 0 <= i3 < 5 => 0 <= i4 < 5 =>
  i0 <> i1 => i0 <> i2 => i0 <> i3 => i0 <> i4 => i1 <> i2 => i1 <> i3 =>
  i1 <> i4 => i2 <> i3 => i2 <> i4 => i3 <> i4 =>
  BArray80.get128 s i0 = p2 S.`1 S.`2 => BArray80.get128 s i1 = p2 S.`3 S.`4 =>
  BArray80.get128 s i2 = p2 S.`5 S.`6 => BArray80.get128 s i3 = p2 S.`7 S.`8 =>
  wk = kw2 ws t =>
  let s1 = BArray80.set128 s i3 (VADD_2u64 (BArray80.get128 s i3) wk) in
  let s2 = BArray80.set128 s1 i3
             (SHA512H (BArray80.get128 s1 i3)
                (VEXT (BArray80.get128 s i2) (BArray80.get128 s i3) (W8.of_int 8))
                (VEXT (BArray80.get128 s i1) (BArray80.get128 s i2) (W8.of_int 8))) in
  let s3 = BArray80.set128 s2 i4
             (VADD_2u64 (BArray80.get128 s2 i1) (BArray80.get128 s2 i3)) in
  let s4 = BArray80.set128 s3 i3
             (SHA512H2 (BArray80.get128 s3 i3) (BArray80.get128 s3 i1)
                (BArray80.get128 s3 i0)) in
  BArray80.get128 s4 i3 = p2 (rounds ws S t (t + 2)).`1 (rounds ws S t (t + 2)).`2 /\
  BArray80.get128 s4 i0 = p2 (rounds ws S t (t + 2)).`3 (rounds ws S t (t + 2)).`4 /\
  BArray80.get128 s4 i4 = p2 (rounds ws S t (t + 2)).`5 (rounds ws S t (t + 2)).`6 /\
  BArray80.get128 s4 i2 = p2 (rounds ws S t (t + 2)).`7 (rounds ws S t (t + 2)).`8.
proof.
move=> r0 r1 r2 r3 r4 d01 d02 d03 d04 d12 d13 d14 d23 d24 d34 h0 h1 h2 h3 hwk /=.
have [e1 [e2 [e3 e4]]] := sha512h_rounds2 ws t S.
move: e1 e2; rewrite /h512 => e1 e2.
have g3 : forall (u : BArray80.t) y w,
  BArray80.get128 (BArray80.set128 u i3 w) y = if y = i3 then w else BArray80.get128 u y.
+ by move=> u y w; rewrite BArray80.get_set128E 1,2:/# (eq_sym y).
have g4 : forall (u : BArray80.t) y w,
  BArray80.get128 (BArray80.set128 u i4 w) y = if y = i4 then w else BArray80.get128 u y.
+ by move=> u y w; rewrite BArray80.get_set128E 1,2:/# (eq_sym y).
have [n43 [n23 [n13 [n14 n24]]]] :
  i4 <> i3 /\ i2 <> i3 /\ i1 <> i3 /\ i1 <> i4 /\ i2 <> i4 by smt().
rewrite !g3 ?g4 ?g3 ?g4 ?g3 /= ?d03 ?d04 ?d34 ?n43 ?n23 ?n13 ?n14 ?n24 /=.
by rewrite h0 h1 h2 h3 hwk /rounds -e1 -e2 -e3 -e4.
qed.

lemma rounds_g (ws : W64.t list) (s : state) (g : int) : 0 <= g =>
  rounds ws s 0 (2 * (g + 1)) = rounds ws (rounds ws s 0 (2 * g)) (2 * g) (2 * g + 2).
proof.
move=> hg; rewrite (_ : 2 * (g + 1) = 2 * g + 2) 1:/#.
by rewrite (rounds_cat ws s 0 (2 * g) (2 * g + 2)) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The message window                                                 *)

(* m[(g + i) mod 8] holds pair g + i at the head of pair g. *)
lemma win_idx g i : 0 <= i < 8 => g + ((g %% 8 + i) %% 8 - g) %% 8 = g + i.
proof.
move=> hi; rewrite modzDml (_ : g %% 8 + i - g = g %% 8 + (i - g)) 1:/# modzDml.
by rewrite (_ : g + (i - g) = i) 1:/# modz_small 1:/#.
qed.

(* A slot other than m[g mod 8] keeps its pair when the window moves. *)
lemma win_other g j : 0 <= j < 8 => g %% 8 <> j =>
  g + (j - g) %% 8 = g + 1 + (j - (g + 1)) %% 8.
proof.
move=> hj hne.
have e1 : (j - g) %% 8 = (j - g %% 8) %% 8.
+ rewrite {1}(divz_eq g 8).
  by rewrite (_ : j - (g %/ 8 * 8 + g %% 8) = (j - g %% 8) + (- (g %/ 8)) * 8) 1:/# modzMDr.
have e2 : (j - (g + 1)) %% 8 = (j - g %% 8 - 1) %% 8.
+ rewrite {1}(divz_eq g 8).
  by rewrite (_ : j - (g %/ 8 * 8 + g %% 8 + 1) = (j - g %% 8 - 1) + (- (g %/ 8)) * 8) 1:/# modzMDr.
rewrite e1 e2; move: hne.
have : 0 <= g %% 8 < 8 by smt().
move: (g %% 8) => r hr hne.
have := range8 j hj; have := range8 r hr.
by move=> hrv hjv; smt().
qed.

lemma win_last g : 32 <= g < 40 => 32 + (g %% 8 - 32) %% 8 = g.
proof.
move=> hg; have : g = 32 \/ g = 33 \/ g = 34 \/ g = 35 \/ g = 36 \/ g = 37 \/ g = 38 \/ g = 39 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

lemma mod8_ne (r k : int) : 0 <= r < 8 => 0 < k < 8 => (r = (r + k) %% 8) = false.
proof.
move=> hr hk; have := range8 r hr; have : k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|->]]]]]] [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

(* Pair g < 32 replaces its own words, in m[g mod 8], by those of pair
   g + 8 (SHA512SU0, then SHA512SU1); the window moves by one pair. *)
lemma win_step (m : BArray128.t) (ws : W64.t list) (g : int) :
  0 <= g < 32 => (forall t, 16 <= t < 80 => srec ws t) =>
  (forall j, 0 <= j < 8 => BArray128.get128 m j = wv2 ws (2 * (g + (j - g) %% 8))) =>
  forall j, 0 <= j < 8 =>
    BArray128.get128
      (BArray128.set128
        (BArray128.set128 m (g %% 8)
          (SHA512SU0 (BArray128.get128 m (g %% 8)) (BArray128.get128 m ((g %% 8 + 1) %% 8))))
        (g %% 8)
        (SHA512SU1
          (BArray128.get128 (BArray128.set128 m (g %% 8)
            (SHA512SU0 (BArray128.get128 m (g %% 8)) (BArray128.get128 m ((g %% 8 + 1) %% 8))))
            (g %% 8))
          (BArray128.get128 (BArray128.set128 m (g %% 8)
            (SHA512SU0 (BArray128.get128 m (g %% 8)) (BArray128.get128 m ((g %% 8 + 1) %% 8))))
            ((g %% 8 + 7) %% 8))
          (VEXT (BArray128.get128 m ((g %% 8 + 4) %% 8))
                (BArray128.get128 m ((g %% 8 + 5) %% 8)) (W8.of_int 8))))
      j
    = wv2 ws (2 * (g + 1 + (j - (g + 1)) %% 8)).
proof.
move=> hg hrec hm j hj.
have hw : forall i, 0 <= i < 8 =>
  BArray128.get128 m ((g %% 8 + i) %% 8) = wv2 ws (2 * (g + i)).
+ by move=> i hi; rewrite hm 1:/# win_idx.
have hw0 : BArray128.get128 m (g %% 8) = wv2 ws (2 * g).
+ by have := hw 0 _; rewrite //= modz_mod.
have hi : 0 <= g %% 8 < 8 by smt().
rewrite BArray128.get_set128E 1,2:/#.
case: (g %% 8 = j) => hj'.
+ rewrite !BArray128.get_set128E 1..4:/# /=.
  rewrite (mod8_ne (g %% 8) 7) // /=.
  rewrite hw0 (hw 1) // (hw 4) // (hw 5) // (hw 7) //.
  rewrite (_ : 2 * (g + 1) = 2 * g + 2) 1:/# (_ : 2 * (g + 4) = 2 * g + 8) 1:/#.
  rewrite (_ : 2 * (g + 5) = 2 * g + 10) 1:/# (_ : 2 * (g + 7) = 2 * g + 14) 1:/#.
  rewrite sha512su_sched2 1,2:hrec 1,2:/#.
  by congr; rewrite -hj' /#.
rewrite BArray128.get_set128E 1,2:/# ifF 1:/# hm //.
by rewrite win_other.
qed.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

lemma range4 (k : int) : 0 <= k => k < 4 => k = 0 \/ k = 1 \/ k = 2 \/ k = 3.
proof. smt(). qed.

(* Pair j of a state: [a; b], [c; d], [e; f], [g; h] for j = 0 .. 3. *)
op spair (S : state) (j : int) : W128.t =
  if j = 0 then p2 S.`1 S.`2 else if j = 1 then p2 S.`3 S.`4
  else if j = 2 then p2 S.`5 S.`6 else p2 S.`7 S.`8.

lemma sha512_block_a64_correct (S : state) (ws : W64.t list) :
  (forall t, 16 <= t < 80 => srec ws t) =>
  hoare [M.__sha512_block_a64 :
           k = sHA512_K /\
           (forall j, 0 <= j < 4 => BArray80.get128 s j = spair S j) /\
           (forall j, 0 <= j < 8 => BArray128.get128 m j = wv2 ws (2 * j)) ==>
           forall j, 0 <= j < 4 =>
             BArray80.get128 res.`1 j = VADD_2u64 (spair (rounds ws S 0 80) j) (spair S j)].
proof.
move=> hrec; proc.
while (0 <= j <= 4 /\
       (forall i, 0 <= i < 4 => BArray64.get128 s0 i = spair S i) /\
       (forall i, 0 <= i < j =>
          BArray80.get128 s i = VADD_2u64 (spair (rounds ws S 0 80) i) (spair S i)) /\
       (forall i, j <= i < 4 => BArray80.get128 s i = spair (rounds ws S 0 80) i)).
+ wp; skip => /> &hr hj0 _ hs0 hdone htodo hj4.
  split; first smt().
  split.
  + move=> i hi0 hi1; rewrite BArray80.get_set128E 1,2:/#.
    case: (j{hr} = i) => [<-|ne]; first by rewrite hs0 1:/# htodo /#.
    by rewrite hdone /#.
  by move=> i hi0 hi1; rewrite BArray80.get_set128E 1,2:/# ifF 1:/# htodo /#.
wp.
while (32 <= g <= 40 /\ k = sHA512_K /\
       (forall i, 0 <= i < 4 => BArray64.get128 s0 i = spair S i) /\
       i0 = pi0 (g %% 5) /\ i1 = pi1 (g %% 5) /\ i2 = pi2 (g %% 5) /\
       i3 = pi3 (g %% 5) /\ i4 = pi4 (g %% 5) /\
       BArray80.get128 s i0 = p2 (rounds ws S 0 (2 * g)).`1 (rounds ws S 0 (2 * g)).`2 /\
       BArray80.get128 s i1 = p2 (rounds ws S 0 (2 * g)).`3 (rounds ws S 0 (2 * g)).`4 /\
       BArray80.get128 s i2 = p2 (rounds ws S 0 (2 * g)).`5 (rounds ws S 0 (2 * g)).`6 /\
       BArray80.get128 s i3 = p2 (rounds ws S 0 (2 * g)).`7 (rounds ws S 0 (2 * g)).`8 /\
       (forall j, 0 <= j < 8 => BArray128.get128 m j = wv2 ws (2 * (32 + (j - 32) %% 8)))).
+ wp; skip => /> &hr hg32 _ hs0 hs_0 hs_1 hs_2 hs_3 hm hg40.
  have [r0 [r1 [r2 [r3 [r4 [d01 [d02 [d03 [d04 [d12 [d13 [d14 [d23 [d24 d34]]]]]]]]]]]]]] :=
    pi_slots (g{hr} %% 5) _; 1: smt().
  have [e0 [e1 [e2 [e3 e4]]]] := pi_step g{hr} _; 1: smt().
  have hw0 : BArray128.get128 m{hr} (g{hr} %% 8) = wv2 ws (2 * g{hr}).
  + by rewrite hm 1:/# win_last 1:/#.
  have hwk : VEXT (VADD_2u64 (BArray640.get128 sHA512_K g{hr}) (BArray128.get128 m{hr} (g{hr} %% 8)))
                  (VADD_2u64 (BArray640.get128 sHA512_K g{hr}) (BArray128.get128 m{hr} (g{hr} %% 8)))
                  (W8.of_int 8) = kw2 ws (2 * g{hr}).
  + by rewrite kvec 1:/# hw0.
  have := pair_step s{hr} _ _ _ _ _ _ ws (2 * g{hr}) _ r0 r1 r2 r3 r4
            d01 d02 d03 d04 d12 d13 d14 d23 d24 d34 hs_0 hs_1 hs_2 hs_3 hwk.
  move=> /= [q0 [q1 [q2 q3]]].
  rewrite e0 e1 e2 e3 e4 rounds_g 1:/# /= q0 q1 q2 q3 /=.
  smt().
wp.
while (0 <= g <= 32 /\ k = sHA512_K /\
       (forall i, 0 <= i < 4 => BArray64.get128 s0 i = spair S i) /\
       i0 = pi0 (g %% 5) /\ i1 = pi1 (g %% 5) /\ i2 = pi2 (g %% 5) /\
       i3 = pi3 (g %% 5) /\ i4 = pi4 (g %% 5) /\
       BArray80.get128 s i0 = p2 (rounds ws S 0 (2 * g)).`1 (rounds ws S 0 (2 * g)).`2 /\
       BArray80.get128 s i1 = p2 (rounds ws S 0 (2 * g)).`3 (rounds ws S 0 (2 * g)).`4 /\
       BArray80.get128 s i2 = p2 (rounds ws S 0 (2 * g)).`5 (rounds ws S 0 (2 * g)).`6 /\
       BArray80.get128 s i3 = p2 (rounds ws S 0 (2 * g)).`7 (rounds ws S 0 (2 * g)).`8 /\
       (forall j, 0 <= j < 8 => BArray128.get128 m j = wv2 ws (2 * (g + (j - g) %% 8)))).
+ wp; skip => /> &hr hg0 _ hs0 hs_0 hs_1 hs_2 hs_3 hm hg32.
  have [r0 [r1 [r2 [r3 [r4 [d01 [d02 [d03 [d04 [d12 [d13 [d14 [d23 [d24 d34]]]]]]]]]]]]]] :=
    pi_slots (g{hr} %% 5) _; 1: smt().
  have [e0 [e1 [e2 [e3 e4]]]] := pi_step g{hr} _; 1: smt().
  have hw0 : BArray128.get128 m{hr} (g{hr} %% 8) = wv2 ws (2 * g{hr}).
  + have -> := hm (g{hr} %% 8) _; 1: smt().
    by rewrite (_ : (g{hr} %% 8 - g{hr}) %% 8 = 0) 1:/#.
  have hwk : VEXT (VADD_2u64 (BArray640.get128 sHA512_K g{hr}) (BArray128.get128 m{hr} (g{hr} %% 8)))
                  (VADD_2u64 (BArray640.get128 sHA512_K g{hr}) (BArray128.get128 m{hr} (g{hr} %% 8)))
                  (W8.of_int 8) = kw2 ws (2 * g{hr}).
  + by rewrite kvec 1:/# hw0.
  have hwin := win_step m{hr} ws g{hr} _ hrec hm; 1: smt().
  have := pair_step s{hr} _ _ _ _ _ _ ws (2 * g{hr}) _ r0 r1 r2 r3 r4
            d01 d02 d03 d04 d12 d13 d14 d23 d24 d34 hs_0 hs_1 hs_2 hs_3 hwk.
  move=> /= [q0 [q1 [q2 q3]]].
  rewrite e0 e1 e2 e3 e4 rounds_g 1:/# /= q0 q1 q2 q3 /=.
  smt().
wp.
while (0 <= j <= 4 /\ k = sHA512_K /\
       (forall i, 0 <= i < 4 => BArray80.get128 s i = spair S i) /\
       (forall i, 0 <= i < 8 => BArray128.get128 m i = wv2 ws (2 * i)) /\
       (forall i, 0 <= i < j => BArray64.get128 s0 i = spair S i)).
+ wp; skip => /> &hr hj0 _ hs hm hs0 hj4.
  split; first smt().
  move=> i hi0 hi1; rewrite BArray64.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite hs 1:/#.
  by rewrite hs0 /#.
wp; skip => /> &hr hs hm.
have hs0 : BArray80.get128 s{hr} 0 = p2 S.`1 S.`2 by rewrite hs // /spair.
have hs1 : BArray80.get128 s{hr} 1 = p2 S.`3 S.`4 by rewrite hs // /spair.
have hs2 : BArray80.get128 s{hr} 2 = p2 S.`5 S.`6 by rewrite hs // /spair.
have hs3 : BArray80.get128 s{hr} 3 = p2 S.`7 S.`8 by rewrite hs // /spair.
split; first smt().
move=> j0 s00 hjn hj0 hj4 H.
have hs00 : forall i, 0 <= i < 4 => BArray64.get128 s00 i = spair S i by smt().
split.
+ rewrite /= rounds_nil //= hs0 hs1 hs2 hs3 /=; split; first smt().
  by move=> j hj0' hj8; rewrite hm // modz_small /#.
move=> g0 m0 s1 hgn hg0 hg32 hs01 hb0 hb1 hb2 hb3 hbm.
have ->> : g0 = 32 by smt().
split.
+ move: hb0 hb1 hb2 hb3 hbm; rewrite (_ : 32 %% 5 = 2) 1:// /= => hb0 hb1 hb2 hb3 hbm.
  by rewrite hb0 hb1 hb2 hb3 /= => j hj0' hj8; apply hbm.
move=> g1 s2 hgn' hg1 hg40 hc0 hc1 hc2 hc3 _.
have ->> : g1 = 40 by smt().
move: hc0 hc1 hc2 hc3; rewrite (_ : 40 %% 5 = 0) 1:// /pi0 /pi1 /pi2 /pi3 /= => hc0 hc1 hc2 hc3.
split.
+ split; first smt().
  move=> i hi0 hi4; have := range4 i hi0 hi4.
  by case=> [->>|[->>|[->>|->>]]]; rewrite /spair /= ?hc0 ?hc1 ?hc2 ?hc3.
move=> j1 s3 hjn1 hj10 hj14 hd _ jj hjj0 hjj4.
by rewrite hd /#.
qed.

(* ------------------------------------------------------------------ *)
(* The state and the message in q registers                           *)

lemma get128_lanes (h : BArray64.t) (o : int) :
  BArray64.get128 h o = p2 (BArray64.get64 h (2 * o)) (BArray64.get64 h (2 * o + 1)).
proof.
rewrite {1}(p2_bits (BArray64.get128 h o)) !Arr64.get128d_bits64 //.
by congr; congr; ring.
qed.

lemma get64_of128 (h : BArray64.t) (k : int) : 0 <= k < 8 =>
  BArray64.get64 h k = BArray64.get128 h (k %/ 2) \bits64 (k %% 2).
proof. by move=> hk; rewrite Arr64.get128d_bits64 1:/#; congr; smt(). qed.

lemma spair_h (h : BArray64.t) (j : int) : 0 <= j => j < 4 =>
  spair (to_state (hwords h)) j = BArray64.get128 h j.
proof.
move=> hj0 hj4; have := range4 j hj0 hj4.
by case=> [->>|[->>|[->>|->>]]]; rewrite get128_lanes /spair /to_state /= !nth_hwords.
qed.

lemma div2_range (k : int) : 0 <= k < 8 => 0 <= k %/ 2 < 4.
proof. smt(). qed.

(* Message word k of the block, read big-endian (section 5.2.1). *)
lemma bswap_get64 (blk : BArray128.t) k : 0 <= k < 16 =>
  bswap64 (BArray128.get64 blk k) = be64 (take 8 (drop (8 * k) (BArray128.to_list blk))).
proof.
move=> hk; rewrite /bswap64 /be64 BArray128.get64dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W8u8.size_to_list size_take // size_drop 1:/# BArray128.size_to_list /#.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list W8u8.get_pack8 1:BArray128.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray128.get_to_list.
by rewrite BArray128.nth_sub.
qed.

lemma msg_word (blk : BArray128.t) (k : int) : 0 <= k < 16 =>
  bswap64 (BArray128.get64 blk k)
  = nth W64.zero (schedule (blockwords (BArray128.to_list blk))) k.
proof.
move=> hk; rewrite nth_schedule_lo 1:size_blockwords 1:BArray128.size_to_list //.
by rewrite nth_blockwords 1:BArray128.size_to_list // bswap_get64.
qed.

lemma vrev_block (blk : BArray128.t) (j : int) : 0 <= j < 8 =>
  VREV64_16u8 (BArray128.get128 blk j)
  = wv2 (schedule (blockwords (BArray128.to_list blk))) (2 * j).
proof.
move=> hj; rewrite {1}(p2_bits (VREV64_16u8 (BArray128.get128 blk j))) /wv2.
rewrite !vrev64_lane // !Arr128.get128d_bits64 //.
have e : forall i, 0 <= i < 2 =>
  bswap64 (BArray128.get64d blk (16 * j + 8 * i))
  = nth W64.zero (schedule (blockwords (BArray128.to_list blk))) (2 * j + i).
+ by move=> i hi; rewrite -msg_word 1:/#; congr; congr; ring.
by rewrite (e 0) // (e 1).
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on a 128-byte block                         *)

lemma sha512_compress_correct (h0 : W64.t list) (blk : BArray128.t) :
  hoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))].
proof.
have hsz : size (blockwords (BArray128.to_list blk)) = 16.
+ by rewrite size_blockwords // BArray128.size_to_list.
have hrec : forall t, 16 <= t < 80 => srec (schedule (blockwords (BArray128.to_list blk))) t.
+ by move=> t ht; rewrite /srec (nth_schedule_hi _ _ hsz).
proc.
while (0 <= j <= 4 /\
       (forall i, 0 <= i < 4 =>
          BArray80.get128 s i
          = VADD_2u64 (spair (rounds (schedule (blockwords (BArray128.to_list blk)))
                                     (to_state h0) 0 80) i)
                      (spair (to_state h0) i)) /\
       (forall i, 0 <= i < j =>
          BArray64.get128 h i
          = VADD_2u64 (spair (rounds (schedule (blockwords (BArray128.to_list blk)))
                                     (to_state h0) 0 80) i)
                      (spair (to_state h0) i))).
+ wp; skip => /> &hr hj0 _ hs hdone hj4; split; first smt().
  move=> i hi0 hi1; rewrite BArray64.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite hs /#.
  by rewrite hdone /#.
wp.
ecall (sha512_block_a64_correct (to_state h0) (schedule (blockwords (BArray128.to_list blk))) hrec).
wp.
while (0 <= j <= 8 /\ block = blk /\
       (forall i, 0 <= i < 4 => BArray80.get128 s i = spair (to_state h0) i) /\
       forall i, 0 <= i < j => BArray128.get128 m i = VREV64_16u8 (BArray128.get128 blk i)).
+ wp; skip => /> &hr hj0 _ hs hi hj8; split; first smt().
  move=> i hi0 hi1.
  rewrite BArray128.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite BArray128.get_set128E 1,2:/#.
  by rewrite BArray128.get_set128E 1,2:/# ne /= hi /#.
wp.
while (0 <= j <= 4 /\ hwords h = h0 /\ block = blk /\
       forall i, 0 <= i < j => BArray80.get128 s i = spair (to_state h0) i).
+ wp; skip => /> &hr hj0 _ hi hj4; split; first smt().
  move=> i hi0 hi1; rewrite BArray80.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite spair_h /#.
  by rewrite hi /#.
wp; skip => /> &hr.
split; first smt().
move=> j0 s00 hjn hj0 hj4 hs.
have hs4 : forall i, 0 <= i < 4 =>
  BArray80.get128 s00 i = spair (to_state (hwords h{hr})) i by smt().
split; first by split; smt().
move=> j1 m0 hjn1 hj10 hj18 _ hm.
have hm8 : forall j2, 0 <= j2 < 8 =>
  BArray128.get128 m0 j2 = wv2 (schedule (blockwords (BArray128.to_list blk))) (2 * j2).
+ by move=> j2 hj; rewrite hm 1:/# vrev_block.
split; first by move=> j2 h0' h1'; apply hm8.
move=> _ r hr.
split; first smt().
move=> h1 j2 hjn2 hj20 hj24 hh.
have ->> : j2 = 4 by smt().
rewrite (_ : map be64 (chunk 8 (BArray128.to_list blk)) = blockwords (BArray128.to_list blk)) //.
apply (eq_from_nth W64.zero); first by rewrite size_hwords size_compress // size_hwords.
move=> k; rewrite size_hwords => hk.
rewrite nth_hwords // get64_of128 // hh; 1: exact (div2_range k hk).
rewrite nth_compress ?size_hwords // /vars.
move: (rounds (schedule (blockwords (BArray128.to_list blk))) (to_state (hwords h{hr})) 0 80) => S.
case: S => a b c d e f g hh' /=.
rewrite /to_state /spair /of_state /=.
have := range8 k hk.
by case=> [|[|[|[|[|[|[|]]]]]]] ->> /=; rewrite vadd2_pack ?p2_0 ?p2_1 !nth_hwords.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range. *)
lemma sha512_block_a64_ll : islossless M.__sha512_block_a64.
proof.
proc; wp.
while (0 <= j <= 4) (4 - j); first by auto => /#.
wp; while (32 <= g <= 40) (40 - g); first by auto => /#.
wp; while (0 <= g <= 32) (32 - g); first by auto => /#.
wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
by auto => /#.
qed.

lemma sha512_compress_ll : islossless M._sha512_compress.
proof.
proc; wp.
while (0 <= j <= 4) (4 - j); first by auto => /#.
wp; call sha512_block_a64_ll; wp.
while (0 <= j <= 8) (8 - j); first by auto => /#.
wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
by auto => /#.
qed.

lemma sha512_compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))] = 1%r.
proof. by conseq sha512_compress_ll (sha512_compress_correct h0 blk). qed.
