(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64NeonRound.ec (aarch64/neon)
 * ========================================
 *
 * One round of FIPS 180-4 section 6.2.2 step 3 on four lanes at a time, as
 * the AArch64 Advanced SIMD 8-way SHA-256 kernel
 * (src/aarch64/neon/sha256_x8_compress.jinc) computes it. A 128-bit vector
 * holds one working variable, or one schedule word, of the four lanes
 * 4x .. 4x + 3 of half x, lane 4x + c in 32-bit lane c.
 *
 * L k is the chaining value and M k the sixteen message words of lane k.
 * vx L M x t i is variable i (a = 0 .. h = 7) of half x at the head of
 * round t, wx M x t the schedule word W_t, kx t the constant K_t in every
 * lane. The lemmas give the variables at the head of round t + 1 in the
 * vector operations of the kernel: the new e and a from T1 and T2, the
 * others moved down by one. Every identity is proven lane by lane against
 * vars of lib/Rounds256.ec.
 *
 * The working variables rotate over nine slots per half: at the head of
 * round t, variable i is in slot sv x t i = 9x + ((i + 576) - t) mod 9 of
 * the kernel's array, and slot sv x t 8 holds h + K_t. 576 = 64 * 9 keeps
 * the operand of mod non-negative for t <= 64; the slot of variable i in
 * round t + 1 is that of variable i - 1 in round t (sv_next).
 *
 * The schedule window: window_wt_lag is window_wt of lib/Rounds256.ec when
 * the window was last moved on in round t - 1 or t; the kernel stops
 * storing W_t from t = 62, the first word no later round reads.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_armv8a.
require import WordSpec FIPS180_SHA2 Rounds256 Vec.
import SHA256 N256.

(* ------------------------------------------------------------------ *)
(* Lanes of the vector operations                                     *)

lemma n8_vadd (a b : W128.t) (c : int) : 0 <= c < 4 =>
  (a \vadd32u128 b) \bits32 c = (a \bits32 c) + (b \bits32 c).
proof. by move=> hc; rewrite /VPADD_4u32 W4u32.map2bE. qed.

lemma n8_xor (a b : W128.t) (c : int) : 0 <= c < 4 =>
  (a +^ b) \bits32 c = (a \bits32 c) +^ (b \bits32 c).
proof. by move=> hc; rewrite W4u32.xorb32E. qed.

lemma n8_p4 (a0 a1 a2 a3 : W32.t) (c : int) : 0 <= c < 4 =>
  p4 a0 a1 a2 a3 \bits32 c = nth W32.zero [a0; a1; a2; a3] c.
proof. exact p4_lane. qed.

lemma n8_c4 (c : int) : 0 <= c < 4 => c = 0 \/ c = 1 \/ c = 2 \/ c = 3.
proof. smt(). qed.

(* The functions of section 4.1.2 as __Sigma0_x2 .. __sigma1_x2 compute
   them on one vector. *)
op S0v (x : W128.t) : W128.t = rotv x 2 +^ rotv x 13 +^ rotv x 22.
op S1v (x : W128.t) : W128.t = rotv x 6 +^ rotv x 11 +^ rotv x 25.
op s0v (x : W128.t) : W128.t = rotv x 7 +^ rotv x 18 +^ (x \vshr32u128 (W128.of_int 3)).
op s1v (x : W128.t) : W128.t = rotv x 17 +^ rotv x 19 +^ (x \vshr32u128 (W128.of_int 10)).

(* ------------------------------------------------------------------ *)
(* The working variables of four lanes                                *)

op VL (L M : int -> W32.t list) (k t : int) : W32.t list =
  vars (L k) (schedule (M k)) t.

op vx (L M : int -> W32.t list) (x t i : int) : W128.t =
  p4 (nth W32.zero (VL L M (4 * x) t) i) (nth W32.zero (VL L M (4 * x + 1) t) i)
     (nth W32.zero (VL L M (4 * x + 2) t) i) (nth W32.zero (VL L M (4 * x + 3) t) i).

op wx (M : int -> W32.t list) (x t : int) : W128.t =
  p4 (nth W32.zero (schedule (M (4 * x))) t) (nth W32.zero (schedule (M (4 * x + 1))) t)
     (nth W32.zero (schedule (M (4 * x + 2))) t) (nth W32.zero (schedule (M (4 * x + 3))) t).

op kx (t : int) : W128.t =
  p4 (nth W32.zero K256 t) (nth W32.zero K256 t) (nth W32.zero K256 t) (nth W32.zero K256 t).

lemma n8_vx L M x t i c : 0 <= c < 4 =>
  vx L M x t i \bits32 c = nth W32.zero (VL L M (4 * x + c) t) i.
proof. by move=> hc; rewrite /vx n8_p4 //; case: (n8_c4 c hc) => [->|[->|[->|->]]]. qed.

lemma n8_wx M x t c : 0 <= c < 4 =>
  wx M x t \bits32 c = nth W32.zero (schedule (M (4 * x + c))) t.
proof. by move=> hc; rewrite /wx n8_p4 //; case: (n8_c4 c hc) => [->|[->|[->|->]]]. qed.

lemma n8_kx t c : 0 <= c < 4 => kx t \bits32 c = nth W32.zero K256 t.
proof. by move=> hc; rewrite /kx n8_p4 //; case: (n8_c4 c hc) => [->|[->|[->|->]]]. qed.

(* Variable i of a lane after round t, for 0 <= i < 8. *)
lemma n8_VLS L M k t i : 0 <= t => 0 <= i < 8 =>
  nth W32.zero (VL L M k (t + 1)) i
  = let v = VL L M k t in
    if i = 0 then T1 v (schedule (M k)) t + T2 v
    else if i = 4 then nth W32.zero v 3 + T1 v (schedule (M k)) t
    else nth W32.zero v (i - 1).
proof.
move=> ht hi; rewrite /VL varsS //=.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

(* Variables b, c, d, f, g, h of round t + 1 are a, b, c, e, f, g of round t. *)
lemma n8_vx_mv L M x t i : 0 <= t => 0 < i < 8 => i <> 4 =>
  vx L M x (t + 1) i = vx L M x t (i - 1).
proof.
move=> ht hi h4; have hi' : 0 <= i < 8 by smt().
apply W4u32.wordP => c hc.
rewrite !n8_vx // n8_VLS //=.
by rewrite ifF 1:/# ifF 1:/#.
qed.

(* The sums of T1 and of the new a, in the order the kernel adds. *)
lemma n8_sum_t1 (h k w c s : W32.t) : (((h + k) + w) + c) + s = h + s + c + k + w.
proof. by ring. qed.

(* T1 as the kernel sums it: h + K_t, then W_t, then Ch, then Sigma1. *)
op T1v (L M : int -> W32.t list) (ch_ : W128.t) (x t : int) : W128.t =
  (((vx L M x t 7 \vadd32u128 kx t) \vadd32u128 wx M x t) \vadd32u128 ch_) \vadd32u128 S1v (vx L M x t 4).

lemma n8_T1v L M ch_ x t c : 0 <= c < 4 =>
  ch_ \bits32 c = ch (vx L M x t 4 \bits32 c) (vx L M x t 5 \bits32 c) (vx L M x t 6 \bits32 c) =>
  T1v L M ch_ x t \bits32 c = T1 (VL L M (4 * x + c) t) (schedule (M (4 * x + c))) t.
proof.
move=> hc hch; rewrite /T1v.
rewrite (n8_vadd _ _ c hc) (n8_vadd _ _ c hc) (n8_vadd _ _ c hc) (n8_vadd _ _ c hc).
rewrite hch (n8_kx t c hc) (n8_wx M x t c hc) /S1v (vbsig1 _ c hc).
rewrite (n8_vx L M x t 7 c hc) (n8_vx L M x t 4 c hc) (n8_vx L M x t 5 c hc) (n8_vx L M x t 6 c hc).
rewrite n8_sum_t1 /T1.
reflexivity.
qed.

(* The new e: d + T1. *)
lemma n8_vx_e L M ch_ x t : 0 <= t =>
  (forall c, 0 <= c < 4 =>
     ch_ \bits32 c = ch (vx L M x t 4 \bits32 c) (vx L M x t 5 \bits32 c) (vx L M x t 6 \bits32 c)) =>
  vx L M x t 3 \vadd32u128 T1v L M ch_ x t = vx L M x (t + 1) 4.
proof.
move=> ht hch; apply W4u32.wordP => c hc.
rewrite (n8_vadd _ _ c hc) (n8_T1v L M ch_ x t c hc (hch c hc)).
rewrite (n8_vx L M x t 3 c hc) (n8_vx L M x (t + 1) 4 c hc) (n8_VLS L M (4 * x + c) t 4 ht _) //.
qed.

(* The new a: T1 + (Sigma0(a) + Maj(a, b, c)), Maj by BSL on b ^ c. *)
lemma n8_vx_a L M ch_ x t : 0 <= t =>
  (forall c, 0 <= c < 4 =>
     ch_ \bits32 c = ch (vx L M x t 4 \bits32 c) (vx L M x t 5 \bits32 c) (vx L M x t 6 \bits32 c)) =>
  T1v L M ch_ x t
  \vadd32u128 (S0v (vx L M x t 0) \vadd32u128 VBSL (vx L M x t 1 +^ vx L M x t 2) (vx L M x t 0) (vx L M x t 1))
  = vx L M x (t + 1) 0.
proof.
move=> ht hch; apply W4u32.wordP => c hc.
rewrite (n8_vadd (T1v L M ch_ x t) _ c hc) (n8_T1v L M ch_ x t c hc (hch c hc)).
rewrite (n8_vadd (S0v _) _ c hc) /S0v (vbsig0 _ c hc) (vbsl_maj _ _ _ c hc).
rewrite (n8_vx L M x t 0 c hc) (n8_vx L M x t 1 c hc) (n8_vx L M x t 2 c hc).
by rewrite (n8_vx L M x (t + 1) 0 c hc) (n8_VLS L M (4 * x + c) t 0 ht _) //= /T2.
qed.

(* The free slot gets g + K_{t+1}, which is h + K_{t+1} of round t + 1. *)
lemma n8_vx_hk L M x t : 0 <= t =>
  vx L M x t 6 \vadd32u128 kx (t + 1) = vx L M x (t + 1) 7 \vadd32u128 kx (t + 1).
proof. by move=> ht; rewrite n8_vx_mv. qed.

(* b ^ c of round t + 1 is a ^ b of round t. *)
lemma n8_vx_bc L M x t : 0 <= t =>
  vx L M x t 0 +^ vx L M x t 1 = vx L M x (t + 1) 1 +^ vx L M x (t + 1) 2.
proof. by move=> ht; rewrite !n8_vx_mv. qed.

(* Before round 0 the variables are the chaining value. *)
lemma n8_vx0 L M x i : size (L (4 * x)) = 8 => size (L (4 * x + 1)) = 8 =>
  size (L (4 * x + 2)) = 8 => size (L (4 * x + 3)) = 8 =>
  vx L M x 0 i
  = p4 (nth W32.zero (L (4 * x)) i) (nth W32.zero (L (4 * x + 1)) i)
       (nth W32.zero (L (4 * x + 2)) i) (nth W32.zero (L (4 * x + 3)) i).
proof. by move=> h0 h1 h2 h3; rewrite /vx /VL !vars0. qed.

(* ------------------------------------------------------------------ *)
(* Ch in the two forms of the kernel                                  *)

lemma n8_ch_bit L M x t c : 0 <= c < 4 =>
  VBIT (vx L M x t 6) (vx L M x t 5) (vx L M x t 4) \bits32 c
  = ch (vx L M x t 4 \bits32 c) (vx L M x t 5 \bits32 c) (vx L M x t 6 \bits32 c).
proof. by move=> hc; rewrite vbit_ch. qed.

lemma n8_ch_andn L M x t c : 0 <= c < 4 =>
  ((vx L M x t 4 `&` vx L M x t 5) +^ (vx L M x t 6 `&` invw (vx L M x t 4))) \bits32 c
  = ch (vx L M x t 4 \bits32 c) (vx L M x t 5 \bits32 c) (vx L M x t 6 \bits32 c).
proof. by move=> hc; rewrite vandn_ch. qed.

(* ------------------------------------------------------------------ *)
(* Slots                                                              *)

op sv (x t i : int) : int = 9 * x + ((i + 576) - t) %% 9.

lemma sv_rng x t i : 0 <= x < 2 => 0 <= sv x t i /\ 16 * (sv x t i + 1) <= 288.
proof. by move=> hx; rewrite /sv; smt(modz_ge0 ltz_pmod). qed.

lemma sv_inj x t i x' i' : 0 <= x < 2 => 0 <= i < 9 => 0 <= x' < 2 => 0 <= i' < 9 =>
  sv x t i = sv x' t i' <=> (x = x' /\ i = i').
proof.
move=> hx hi hx' hi'; rewrite /sv; split; last by move=> [-> ->].
move=> h.
have hr := modz_ge0 ((i + 576) - t) 9 _; first done.
have hr' := modz_ge0 ((i' + 576) - t) 9 _; first done.
have hl := ltz_pmod ((i + 576) - t) 9 _; first done.
have hl' := ltz_pmod ((i' + 576) - t) 9 _; first done.
have ex : x = x' by smt().
split; first done.
have e : ((i + 576) - t) %% 9 = ((i' + 576) - t) %% 9 by smt().
smt(modzDl modzDr).
qed.

lemma sv_next x t i : 1 <= i < 9 => sv x (t + 1) i = sv x t (i - 1).
proof. by move=> hi; rewrite /sv (_: (i + 576) - (t + 1) = ((i - 1) + 576) - t) 1:/#. qed.

lemma sv_next0 x t : sv x (t + 1) 0 = sv x t 8.
proof.
rewrite /sv; congr.
by rewrite (_: (8 + 576) - t = ((0 + 576) - (t + 1)) + 1 * 9) 1:/# modzMDr.
qed.

lemma sv_0 x i : 0 <= i < 9 => sv x 0 i = 9 * x + i.
proof. by move=> hi; rewrite /sv /= (_: i + 576 = i + 64 * 9) 1:/# modzMDr modz_small /#. qed.

(* ------------------------------------------------------------------ *)
(* The schedule window when its last store was in round t - 1         *)

lemma window_wt_lag (get : int -> W32.t) m t u :
  size m = 16 => 16 <= t < 64 => t - 1 <= u <= t => window_ok get (schedule m) u =>
  ssig1 (get ((t - 2) %% 16)) + ssig0 (get ((t - 15) %% 16))
  + get ((t - 7) %% 16) + get (t %% 16)
  = nth W32.zero (schedule m) t.
proof.
move=> hm ht hu hw.
have hmod : (t - 16) %% 16 = t %% 16.
+ by rewrite (_: t - 16 = t + (-1) * 16) 1:/# modzMDr.
have hb : forall d, 2 <= d <= 16 => max 0 (u - 16) <= t - d < max 16 u.
+ by move=> d hd; rewrite /max /#.
have e2  := hw (t - 2) (hb 2 _); first done.
have e15 := hw (t - 15) (hb 15 _); first done.
have e7  := hw (t - 7) (hb 7 _); first done.
have e16 := hw (t - 16) (hb 16 _); first done.
rewrite hmod in e16.
by rewrite e2 e15 e7 e16 (nth_schedule_hi m t hm ht); ring.
qed.
