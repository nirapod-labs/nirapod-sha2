(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64NeonBlock.ec (aarch64/neon)
 * ========================================
 *
 * Functional correctness, lane by lane, of _sha256_x8_block of the AArch64
 * Advanced SIMD 8-way SHA-256 kernel
 * (src/aarch64/neon/sha256_x8_compress.jinc) against FIPS 180-4 section
 * 6.2.2: from the eight chaining values in h8 and the sixteen message
 * words of each lane in w, every lane k ends with compress of its own
 * chaining value and its own message words.
 *
 * Representation. h8 is u32[64], word-major: word j of lane k is u32
 * 8j + k (lane8 of lib/Lanes.ec), so the 128-bit slot 2j + x holds word j
 * of lanes 4x .. 4x + 3. w[16x + j] holds message word j of the same four
 * lanes, lane 4x + c in 32-bit lane c (wok), and is the 16-word schedule
 * window of half x during the rounds (winv). The working variables of
 * half x rotate over v[9x .. 9x + 8] as SHA256_X8_A64NeonRound.ec
 * describes (vat); ab[2x + (t + 1) mod 2] holds b ^ c, the selector of
 * Maj, at the head of round t (abinv).
 *
 * Every loop over the halves x = 0, 1 is unrolled. A round is cut by
 * `seq` after each of its steps: W_t (and the store into the window),
 * h + K_t + W_t, g + K_{t+1}, Sigma1(e), T1, the new e; the last step
 * makes the new a and moves on to round t + 1 (vat_next). Each cut states
 * the slots as a slot map (f0, fB, fC, fE, fG) over the vectors of
 * SHA256_X8_A64NeonRound.ec, so no cut sees more than one step's writes.
 * The indices the simplifier produces, ((c + 576) - t) mod 9 and
 * 9 + ((c + 576) - t) mod 9, are folded back into sv (n8_sv0, n8_sv1)
 * before any read is resolved (n8_vgs).
 *
 * Theorems:
 *     n8_block_correct   lane k of the result is compress of lane k of h8
 *                        with the message words of lane k, for k < 8
 *                        (partial correctness);
 *     n8_block_ll        termination.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray64 BArray256 BArray288 BArray512.
require import NirapodSha2 WordSpec.
require import FIPS180_SHA2 Rounds256 Vec Lanes SHA256_X8_A64NeonRound.
require Arrays.
import SHA256 N256.

clone Arrays.Words as N8A256 with theory A <= BArray256.

(* ------------------------------------------------------------------ *)
(* The vector functions                                               *)

lemma n8_rotr_h (a b : W128.t) (r0 : int) :
  hoare [M.__rotr_x2 : x0 = a /\ x1 = b /\ r = r0 ==> res = (rotv a r0, rotv b r0)].
proof. by proc; wp; skip; rewrite /rotv => />. qed.

lemma n8_S0_h (a b : W128.t) :
  hoare [M.__Sigma0_x2 : x0 = a /\ x1 = b ==> res = (S0v a, S0v b)].
proof. by proc; inline *; wp; skip; rewrite /S0v /rotv => />. qed.

lemma n8_S1_h (a b : W128.t) :
  hoare [M.__Sigma1_x2 : x0 = a /\ x1 = b ==> res = (S1v a, S1v b)].
proof. by proc; inline *; wp; skip; rewrite /S1v /rotv => />. qed.

lemma n8_s0_h (a b : W128.t) :
  hoare [M.__sigma0_x2 : x0 = a /\ x1 = b ==> res = (s0v a, s0v b)].
proof. by proc; inline *; wp; skip; rewrite /s0v /rotv => />. qed.

lemma n8_s1_h (a b : W128.t) :
  hoare [M.__sigma1_x2 : x0 = a /\ x1 = b ==> res = (s1v a, s1v b)].
proof. by proc; inline *; wp; skip; rewrite /s1v /rotv => />. qed.

(* ------------------------------------------------------------------ *)
(* The round constants, K_t in every lane                             *)

lemma n8_K256 t : 0 <= t < 64 =>
  BArray256.get32 sHA256_K t = nth W32.zero K256 t.
proof.
move=> ht; rewrite BArray256.get32_of_list32 1://.
by congr; rewrite /K256 /=.
qed.

lemma n8_kd t : 0 <= t < 64 =>
  VDUPE_4u32 (BArray256.get128 sHA256_K (t %/ 4)) (W8.of_int (t %% 4)) = kx t.
proof.
move=> ht; apply W4u32.wordP => c hc.
rewrite n8_kx // /VDUPE_4u32 W4u32.pack4bE // W4u32.Pack.initiE //=.
rewrite W8.to_uint_small 1:/# N8A256.get128d_bits32 1:/#.
by rewrite -n8_K256 // (_: 16 * (t %/ 4) + 4 * (t %% 4) = 4 * t) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* Slots of v                                                         *)

lemma n8_vgs (v : BArray288.t) t x i x' i' y : 0 <= x' < 2 => 0 <= i' < 9 =>
  0 <= x < 2 => 0 <= i < 9 =>
  BArray288.get128 (BArray288.set128 v (sv x' t i') y) (sv x t i)
  = if x' = x /\ i' = i then y else BArray288.get128 v (sv x t i).
proof.
move=> hx' hi' hx hi; have [h0 h1] := sv_rng x' t i' hx'.
rewrite BArray288.get_set128E //.
by rewrite (sv_inj x' t i' x i).
qed.

(* The forms the simplifier gives 9x + ((i + 576) - t) mod 9 for x = 0, 1. *)
lemma n8_sv0 t :
  (576 - t) %% 9 = sv 0 t 0 /\ (577 - t) %% 9 = sv 0 t 1 /\ (578 - t) %% 9 = sv 0 t 2 /\
  (579 - t) %% 9 = sv 0 t 3 /\ (580 - t) %% 9 = sv 0 t 4 /\ (581 - t) %% 9 = sv 0 t 5 /\
  (582 - t) %% 9 = sv 0 t 6 /\ (583 - t) %% 9 = sv 0 t 7 /\ (584 - t) %% 9 = sv 0 t 8.
proof. by rewrite /sv. qed.

lemma n8_sv1 t :
  9 + (576 - t) %% 9 = sv 1 t 0 /\ 9 + (577 - t) %% 9 = sv 1 t 1 /\ 9 + (578 - t) %% 9 = sv 1 t 2 /\
  9 + (579 - t) %% 9 = sv 1 t 3 /\ 9 + (580 - t) %% 9 = sv 1 t 4 /\ 9 + (581 - t) %% 9 = sv 1 t 5 /\
  9 + (582 - t) %% 9 = sv 1 t 6 /\ 9 + (583 - t) %% 9 = sv 1 t 7 /\ 9 + (584 - t) %% 9 = sv 1 t 8.
proof. by rewrite /sv. qed.

(* A slot map: slot sv x t i of v holds f x i for every i with P i. *)
op vat (v : BArray288.t) (t : int) (f : int -> int -> W128.t) (P : int -> bool) =
  forall x i, 0 <= x < 2 => 0 <= i < 9 => P i => BArray288.get128 v (sv x t i) = f x i.

lemma vat_get v t f P x i : vat v t f P => 0 <= x < 2 => 0 <= i < 9 => P i =>
  BArray288.get128 v (sv x t i) = f x i.
proof. by move=> h; apply h. qed.

lemma vat_weaken v t f P f' P' : vat v t f P =>
  (forall x i, 0 <= x < 2 => 0 <= i < 9 => P' i => P i /\ f x i = f' x i) =>
  vat v t f' P'.
proof. by move=> h h' x i hx hi hp; have [hp' <-] := h' x i hx hi hp; apply h. qed.

(* Both halves write slot i' (the unrolled loop over x). *)
lemma vat_set2 v t f P i' y0 y1 : 0 <= i' < 9 => vat v t f P =>
  vat (BArray288.set128 (BArray288.set128 v (sv 0 t i') y0) (sv 1 t i') y1) t
      (fun x i => if i = i' then (if x = 0 then y0 else y1) else f x i)
      (fun i => i = i' \/ P i).
proof.
move=> hi' h x i hx hi hp /=.
rewrite (n8_vgs _ t x i 1 i') //= (n8_vgs _ t x i 0 i') //=.
case: (i = i') => [->> /=|hne /=]; first by case: (x = 0) => /#.
by rewrite (_: i' = i <=> false) 1:/# /=; apply h => /#.
qed.

(* The slots of round t + 1 are those of round t, moved by one. *)
lemma vat_next v t f P : vat v t f P =>
  vat v (t + 1) (fun x i => f x (if i = 0 then 8 else i - 1)) (fun i => P (if i = 0 then 8 else i - 1)).
proof.
move=> h x i hx hi hp /=; case: (i = 0) => [->>|h0].
+ by rewrite sv_next0; apply h => //.
by rewrite sv_next 1:/#; apply h => /#.
qed.

(* The second half reads past the write of the first. *)
lemma n8_vgs01 (v : BArray288.t) t i i' y : 0 <= i < 9 => 0 <= i' < 9 =>
  BArray288.get128 (BArray288.set128 v (sv 0 t i') y) (sv 1 t i) = BArray288.get128 v (sv 1 t i).
proof. by move=> hi hi'; rewrite n8_vgs. qed.

lemma n8_c2 (x : int) : 0 <= x < 2 => x = 0 \/ x = 1.
proof. smt(). qed.

lemma n8_x0 : 0 <= 0 < 2 by done.
lemma n8_x1 : 0 <= 1 < 2 by done.

lemma n8_c8 (i : int) : 0 <= i < 8 =>
  i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7.
proof. smt(). qed.

lemma n8_c9 (i : int) : 0 <= i < 9 =>
  i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 \/ i = 8.
proof. smt(). qed.

(* Ch of round t in the form the kernel uses. *)
op chx (L Ms : int -> W32.t list) (x t : int) : W128.t =
  if t < 63 then VBIT (vx L Ms x t 6) (vx L Ms x t 5) (vx L Ms x t 4)
  else (vx L Ms x t 4 `&` vx L Ms x t 5) +^ (vx L Ms x t 6 `&` invw (vx L Ms x t 4)).

lemma n8_chx L Ms x t : forall c, 0 <= c < 4 =>
  chx L Ms x t \bits32 c
  = ch (vx L Ms x t 4 \bits32 c) (vx L Ms x t 5 \bits32 c) (vx L Ms x t 6 \bits32 c).
proof. by move=> c hc; rewrite /chx; case: (t < 63) => _; [apply n8_ch_bit | apply n8_ch_andn]. qed.

(* ------------------------------------------------------------------ *)
(* The schedule window of w                                           *)

op winv (w : BArray512.t) (Ms : int -> W32.t list) (t : int) =
  forall x c, 0 <= x < 2 => 0 <= c < 4 =>
    window_ok (fun j => BArray512.get128 w (16 * x + j) \bits32 c) (schedule (Ms (4 * x + c))) (min t 62).

lemma n8_sum_w (a b c d : W32.t) : ((a + b) + c) + d = b + c + d + a.
proof. by ring. qed.

(* W_t of half x from the window, in the order the kernel adds. *)
lemma n8_wt (w : BArray512.t) Ms x t : 0 <= x < 2 => 16 <= t < 64 =>
  (forall k, 0 <= k < 8 => size (Ms k) = 16) => winv w Ms t =>
  ((BArray512.get128 w (16 * x + t %% 16)
    \vadd32u128 s1v (BArray512.get128 w (16 * x + (t - 2) %% 16)))
    \vadd32u128 s0v (BArray512.get128 w (16 * x + (t - 15) %% 16)))
    \vadd32u128 BArray512.get128 w (16 * x + (t - 7) %% 16)
  = wx Ms x t.
proof.
move=> hx ht hMs hw; apply W4u32.wordP => c hc.
rewrite (n8_wx Ms x t c hc) !(n8_vadd _ _ c hc) /s1v /s0v (vssig1 _ c hc) (vssig0 _ c hc).
rewrite n8_sum_w.
have hk : 0 <= 4 * x + c < 8 by smt().
have hu : t - 1 <= min t 62 <= t by smt().
have := window_wt_lag (fun j => BArray512.get128 w (16 * x + j) \bits32 c)
          (Ms (4 * x + c)) t (min t 62) (hMs _ hk) ht hu (hw x c hx hc).
by move=> /=.
qed.

(* W_t of half x in rounds 0 .. 15. *)
lemma n8_wt_lo (w : BArray512.t) Ms x t : 0 <= x < 2 => 0 <= t < 16 =>
  (forall k, 0 <= k < 8 => size (Ms k) = 16) => winv w Ms t =>
  BArray512.get128 w (16 * x + t) = wx Ms x t.
proof.
move=> hx ht hMs hw; apply W4u32.wordP => c hc.
rewrite (n8_wx Ms x t c hc).
have hw' : window_ok (fun j => BArray512.get128 w (16 * x + j) \bits32 c)
            (schedule (Ms (4 * x + c))) t.
+ by have := hw x c hx hc; rewrite /min ifT 1:/#.
have := window_lo (fun j => BArray512.get128 w (16 * x + j) \bits32 c)
          (schedule (Ms (4 * x + c))) t ht hw'.
by move=> /=.
qed.

lemma n8_win_lo w Ms t : 0 <= t < 16 => winv w Ms t => winv w Ms (t + 1).
proof.
move=> ht hw x c hx hc; have := hw x c hx hc.
rewrite (_: min t 62 = t) 1:/# (_: min (t + 1) 62 = t + 1) 1:/#.
exact (window_lo_next _ _ t ht).
qed.

lemma n8_win_hi w Ms t : 62 <= t => winv w Ms t => winv w Ms (t + 1).
proof.
move=> ht hw x c hx hc; have := hw x c hx hc.
by rewrite (_: min t 62 = 62) 1:/# (_: min (t + 1) 62 = 62) 1:/#.
qed.

(* The store of W_t into slot t mod 16 of both halves, 16 <= t < 62. *)
lemma n8_win_set (w : BArray512.t) Ms t y0 y1 : 16 <= t < 62 => winv w Ms t =>
  y0 = wx Ms 0 t => y1 = wx Ms 1 t =>
  winv (BArray512.set128 (BArray512.set128 w (t %% 16) y0) (16 + t %% 16) y1) Ms (t + 1).
proof.
move=> ht hw h0 h1 x c hx hc.
have hm := modz_ge0 t 16 _; first done.
have hl := ltz_pmod t 16 _; first done.
have e1 : min t 62 = t by smt().
have e2 : min (t + 1) 62 = t + 1 by smt().
have hwx := hw x c hx hc; rewrite e1 in hwx; rewrite e2.
apply (window_set (fun j => BArray512.get128 w (16 * x + j) \bits32 c)) => //=; first by case: ht.
+ rewrite !BArray512.get_set128E 1..4:/#.
  case: (n8_c2 x hx) => ->> /=; [rewrite ifF 1:/# | idtac].
  + by rewrite h0 (n8_wx Ms 0 t c hc).
  by rewrite h1 (n8_wx Ms 1 t c hc).
move=> j hj hne; clear hw hwx h0 h1.
rewrite !BArray512.get_set128E 1..4:/#.
by rewrite ifF 1:/# ifF 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The chaining values                                                *)

op LH (H : BArray256.t) (k : int) : W32.t list = lane8 (BArray256.get32 H) k.

lemma n8_h8lane (h : BArray256.t) x j c : 0 <= x < 2 => 0 <= j < 8 => 0 <= c < 4 =>
  BArray256.get128 h (2 * j + x) \bits32 c = nth W32.zero (lane8 (BArray256.get32 h) (4 * x + c)) j.
proof.
move=> hx hj hc; rewrite N8A256.get128d_bits32 // nth_lane //.
by rewrite (_: 16 * (2 * j + x) + 4 * c = 4 * (8 * j + (4 * x + c))) 1:/#.
qed.

lemma n8_h8vx (H : BArray256.t) Ms x j : 0 <= x < 2 => 0 <= j < 8 =>
  BArray256.get128 H (2 * j + x) = vx (LH H) Ms x 0 j.
proof.
move=> hx hj; apply W4u32.wordP => c hc.
by rewrite n8_vx // /VL /LH vars0 1:size_lane // n8_h8lane.
qed.

(* Lane k of a result whose slots are the feed-forward of round 64. *)
lemma n8_lanes (h' H : BArray256.t) Ms :
  (forall x j, 0 <= x < 2 => 0 <= j < 8 =>
     BArray256.get128 h' (2 * j + x) = BArray256.get128 H (2 * j + x) \vadd32u128 vx (LH H) Ms x 64 j) =>
  forall k, 0 <= k < 8 => lane8 (BArray256.get32 h') k = compress (lane8 (BArray256.get32 H) k) (Ms k).
proof.
move=> h k hk; apply (eq_from_nth W32.zero).
+ by rewrite size_lane size_compress // size_lane.
move=> j; rewrite size_lane => hj.
have hx : 0 <= k %/ 4 < 2 by smt().
have hc : 0 <= k %% 4 < 4 by smt().
have ek : k = 4 * (k %/ 4) + k %% 4 by smt().
rewrite nth_compress 1:size_lane //.
rewrite {1}ek -(n8_h8lane h' _ _ _ hx hj hc) (h _ _ hx hj).
rewrite (n8_vadd _ _ _ hc) (n8_h8lane H _ _ _ hx hj hc) (n8_vx _ _ _ _ _ _ hc) -ek /VL /LH.
by rewrite addrC.
qed.

(* ------------------------------------------------------------------ *)
(* The state at the head of round t                                   *)

op rinv (H : BArray256.t) (Ms : int -> W32.t list) (v : BArray288.t) (ab : BArray64.t)
        (w : BArray512.t) (kq : W128.t) (t : int) =
  0 <= t <= 64 /\
  vat v t (fun x i => if i = 8 then vx (LH H) Ms x t 7 \vadd32u128 kx t else vx (LH H) Ms x t i)
          (fun i => if t < 64 then i <> 7 else i < 8) /\
  (t < 64 => forall x, 0 <= x < 2 =>
     BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
  (t < 64 => kq = BArray256.get128 sHA256_K (t %/ 4)) /\
  (t < 64 => winv w Ms t).

(* ------------------------------------------------------------------ *)
(* The slots of v inside round t                                      *)

(* At the head of the round, and after h + K_t + W_t (B). *)
op f0 (H : BArray256.t) (Ms : int -> W32.t list) (t : int) : int -> int -> W128.t =
  fun x i => if i = 8 then vx (LH H) Ms x t 7 \vadd32u128 kx t else vx (LH H) Ms x t i.

op fB (H : BArray256.t) (Ms : int -> W32.t list) (t : int) : int -> int -> W128.t =
  fun x i => if i = 8 then (vx (LH H) Ms x t 7 \vadd32u128 kx t) \vadd32u128 wx Ms x t
             else vx (LH H) Ms x t i.

(* After g + K_{t+1} into the free slot (C), rounds t < 63. *)
op fC (H : BArray256.t) (Ms : int -> W32.t list) (t : int) : int -> int -> W128.t =
  fun x i => if i = 7 then vx (LH H) Ms x t 6 \vadd32u128 kx (t + 1) else fB H Ms t x i.

op PC (t : int) : int -> bool = fun i => i <> 7 \/ t < 63.

(* After T1 (E): BIT overwrites g in rounds t < 63. *)
op fE (H : BArray256.t) (Ms : int -> W32.t list) (t : int) : int -> int -> W128.t =
  fun x i => if i = 8 then T1v (LH H) Ms (chx (LH H) Ms x t) x t else fC H Ms t x i.

op PE (t : int) : int -> bool = fun i => if t < 63 then i <> 6 else i <> 7.

(* After the new e (G). *)
op fG (H : BArray256.t) (Ms : int -> W32.t list) (t : int) : int -> int -> W128.t =
  fun x i => if i = 3 then vx (LH H) Ms x (t + 1) 4 else fE H Ms t x i.

(* rinv inside a round, t < 64. *)
lemma n8_qa H Ms v ab w kq t : t < 64 => rinv H Ms v ab w kq t =>
  0 <= t < 64 /\ vat v t (f0 H Ms t) (fun i => i <> 7) /\
  (forall x, 0 <= x < 2 =>
     BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
  kq = BArray256.get128 sHA256_K (t %/ 4) /\ winv w Ms t.
proof.
move=> ht [[h0 _] [hv [hab [hkq hw]]]]; split; first done.
split.
+ apply (vat_weaken _ _ _ _ _ _ hv) => x i hx hi hp /=.
  by rewrite ht /= hp /f0.
by split; [exact (hab ht) | split; [exact (hkq ht) | exact (hw ht)]].
qed.

lemma n8_div4 t : 0 <= t => (t + 1) %% 4 <> 0 => (t + 1) %/ 4 = t %/ 4.
proof. smt(). qed.

lemma n8_par t : (t %% 2 = 0 /\ (t + 1) %% 2 = 1) \/ (t %% 2 = 1 /\ (t + 1) %% 2 = 0).
proof. smt(). qed.

lemma n8_par2 t : (t + 1 + 1) %% 2 = t %% 2.
proof. by rewrite -addzA (_: 1 + 1 = 2) // modzDr. qed.

lemma n8_lt63 t : (t + 1 < 64) = (t < 63).
proof. smt(). qed.

(* Arithmetic on the round counter, closed so that no SMT call sees the
   large contexts of the round proof. *)
lemma n8_r16 t : 16 <= t => t < 64 => 0 <= t < 64 by smt().
lemma n8_ge62 t : !(t < 62) => 62 <= t by smt().
lemma n8_lo16 t : 0 <= t => !(16 <= t) => 0 <= t < 16 by smt().
lemma n8_s1 t : 0 <= t => t < 63 => 0 <= t + 1 < 64 by smt().
lemma n8_lt64 t : t < 63 => t < 64 by smt().
lemma n8_s2 t : 0 <= t => t < 64 => 0 <= t + 1 <= 64 by smt().

lemma n8_block_correct (H : BArray256.t) (Ms : int -> W32.t list) :
  (forall k, 0 <= k < 8 => size (Ms k) = 16) =>
  hoare [M._sha256_x8_block :
           h8 = H /\
           (forall x j c, 0 <= x < 2 => 0 <= j < 16 => 0 <= c < 4 =>
              BArray512.get128 w (16 * x + j) \bits32 c = nth W32.zero (Ms (4 * x + c)) j) ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k = compress (lane8 (BArray256.get32 H) k) (Ms k)].
proof.
move=> hMs; proc.
seq 15 : (rinv H Ms v ab w kq t /\ h8 = H /\ k = sHA256_K).
+ unroll for 14; unroll for 9; unroll for 12; unroll for 9.
  wp; skip => &hr [] -> hw /=.
  have /= hk0 := n8_kd 0 _; first done.
  rewrite /rinv /=; do! split.
  + move=> x i hx hi hp; rewrite sv_0 //.
    have hx2 := n8_c2 x hx; have hi9 := n8_c9 i hi.
    case: hi9 => [|[|[|[|[|[|[|[|]]]]]]]] ->>; case: hx2 => ->> //=;
      rewrite -?n8_h8vx //= ?hk0 //.
  + move=> x hx; case: (n8_c2 x hx) => ->> /=; rewrite -!n8_h8vx //=.
  move=> x c hx hc; rewrite /min /=; apply window_init; first by apply hMs => /#.
  by move=> j hj /=; have /= := hw x j c hx hj hc.
seq 1 : (rinv H Ms v ab w kq 64 /\ h8 = H).
+ while (rinv H Ms v ab w kq t /\ h8 = H /\ k = sHA256_K).
  + seq 1 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (f0 H Ms t) (fun i => i <> 7) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             kq = BArray256.get128 sHA256_K (t %/ 4) /\ winv w Ms (t + 1) /\
             (forall x, 0 <= x < 2 => BArray32.get128 wt x = wx Ms x t)).
    + if.
      + seq 20 : (0 <= t < 64 /\ 16 <= t /\ h8 = H /\ k = sHA256_K /\ rinv H Ms v ab w kq t /\
                  (forall x, 0 <= x < 2 => BArray32.get128 wt x = wx Ms x t)).
        + unroll for 20; unroll for 18; unroll for 16; unroll for 11; unroll for 9.
          unroll for 4; unroll for 2.
          wp; ecall (n8_s0_h (BArray32.get128 c 0) (BArray32.get128 c 1)).
          wp; ecall (n8_s1_h (BArray32.get128 c 0) (BArray32.get128 c 1)).
          wp; skip => &hr [#] hr -> -> ht h16 /=.
          move=> r -> r' -> /=.
          have [_ [_ [_ [_ hw]]]] := hr; have {hw} hw := hw ht.
          have h16' : 16 <= t{hr} < 64 by split.
          split; first exact (n8_r16 _ h16 ht). split; first done. split; first exact hr.
          move=> x hx; case: (n8_c2 x hx) => ->> /=.
          + by have /= := n8_wt w{hr} Ms 0 t{hr} n8_x0 h16' hMs hw.
          by have /= := n8_wt w{hr} Ms 1 t{hr} n8_x1 h16' hMs hw.
        if.
        + unroll for 2; wp; skip => &hr [#] ht0 ht1 h16 -> -> hr hwt hlt /=.
          have [#] _ _ hv hab hkq hw := n8_qa _ _ _ _ _ _ _ ht1 hr.
          have /= hw0 := hwt 0 n8_x0; have /= hw1 := hwt 1 n8_x1.
          have hlt' : 16 <= t{hr} < 62 by split.
          do! split => //.
          exact (n8_win_set w{hr} Ms t{hr} _ _ hlt' hw hw0 hw1).
        skip => &hr [#] ht0 ht1 h16 -> -> hr hwt hlt /=.
        have [#] _ _ hv hab hkq hw := n8_qa _ _ _ _ _ _ _ ht1 hr.
        do! split => //.
        by apply n8_win_hi => //; exact (n8_ge62 _ hlt).
      unroll for 2; wp; skip => &hr [#] hr -> -> ht hlt /=.
      have [#] ht0 ht1 hv hab hkq hw := n8_qa _ _ _ _ _ _ _ ht hr.
      have hlo := n8_lo16 _ ht0 hlt.
      do! split => //; first exact (n8_win_lo _ _ _ hlo hw).
      move=> x hx; case: (n8_c2 x hx) => ->> /=.
      + by have /= := n8_wt_lo w{hr} Ms 0 t{hr} n8_x0 hlo hMs hw.
      by have /= := n8_wt_lo w{hr} Ms 1 t{hr} n8_x1 hlo hMs hw.
    seq 2 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (fB H Ms t) (fun i => i <> 7) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             kq = BArray256.get128 sHA256_K (t %/ 4) /\ winv w Ms (t + 1)).
    + unroll for 2; wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hwt /=.
      have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
      have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
      rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
      rewrite !n8_vgs //=.
      do! split => //.
      apply (vat_weaken _ _ _ _ _ _ (vat_set2 _ _ _ _ 8 _ _ _ hv)) => // x i hx hi hp /=.
      case: (i = 8) => [->> /=|h8 /=]; last by rewrite /f0 /fB /= h8 /= hp.
      have /= hw0 := hwt 0 n8_x0; have /= hw1 := hwt 1 n8_x1.
      by case: (n8_c2 x hx) => ->> /=; rewrite (vat_get _ _ _ _ _ 8 hv) // /f0 /fB /= ?hw0 ?hw1.
    seq 1 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (fC H Ms t) (PC t) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             (t < 63 => kq = BArray256.get128 sHA256_K ((t + 1) %/ 4)) /\ winv w Ms (t + 1)).
    + if.
      + seq 1 : (0 <= t < 63 /\ h8 = H /\ k = sHA256_K /\ vat v t (fB H Ms t) (fun i => i <> 7) /\
                 (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
                 kq = BArray256.get128 sHA256_K ((t + 1) %/ 4) /\ winv w Ms (t + 1)).
        + if.
          + by wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hlt h4 /=.
          skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hlt h4 /=.
          by do! split => //; rewrite n8_div4.
        unroll for 3; wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw /=.
        have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
        have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
        rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
        rewrite !n8_vgs //=.
        have /= hkd := n8_kd (t{hr} + 1) (n8_s1 _ ht0 ht1).
        do! split => //; first by move=> _; exact (n8_lt64 _ ht1).
        apply (vat_weaken _ _ _ _ _ _ (vat_set2 _ _ _ _ 7 _ _ _ hv)) => // x i hx hi hp /=.
        case: (i = 7) => [->> /=|h7 /=]; last by rewrite /fC /= h7 /=.
        by case: (n8_c2 x hx) => ->> /=; rewrite (vat_get _ _ _ _ _ 6 hv) // /fB /fC /= hkq hkd.
      skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hlt /=.
      do! split => //.
      apply (vat_weaken _ _ _ _ _ _ hv) => x i hx hi hp /=.
      have h7 : i <> 7 by move: hp; rewrite /PC /#.
      by rewrite h7 /fC /= h7.
    seq 3 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (fC H Ms t) (PC t) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             (t < 63 => kq = BArray256.get128 sHA256_K ((t + 1) %/ 4)) /\ winv w Ms (t + 1) /\
             (forall x, 0 <= x < 2 => BArray32.get128 s x = S1v (vx (LH H) Ms x t 4))).
    + wp; ecall (n8_S1_h (BArray288.get128 v (((4 + 576) - t) %% 9))
                        (BArray288.get128 v (9 + ((4 + 576) - t) %% 9))).
      skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw /= r -> /=.
      have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
      have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
      rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
      do! split => //.
      by move=> x hx; case: (n8_c2 x hx) => ->> /=; rewrite (vat_get _ _ _ _ _ 4 hv) // /fC /fB /=.
    seq 1 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (fE H Ms t) (PE t) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             (t < 63 => kq = BArray256.get128 sHA256_K ((t + 1) %/ 4)) /\ winv w Ms (t + 1)).
    + if.
      + unroll for 6; unroll for 4; unroll for 2.
        wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hs hlt /=.
        have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
        have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
        rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
        rewrite !n8_vgs //=.
        do! split => //.
        apply (vat_weaken _ _ _ _ _ _ (vat_set2 _ _ _ _ 8 _ _ _ (vat_set2 _ _ _ _ 8 _ _ _
                 (vat_set2 _ _ _ _ 6 _ _ _ hv)))) => // x i hx hi hp /=.
        move: hp; rewrite /PE /PC hlt /= => hp.
        case: (i = 8) => [->> /=|h8 /=]; last by rewrite hp /= /fE h8.
        have /= hs0 := hs 0 n8_x0; have /= hs1 := hs 1 n8_x1.
        by case: (n8_c2 x hx) => ->> /=;
          rewrite !(vat_get _ _ _ _ _ _ hv) // /fC /fB /fE /T1v /chx /= ?hs0 ?hs1 hlt.
      unroll for 10; unroll for 8; unroll for 6; unroll for 4; unroll for 2.
      wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw hs hlt /=.
      have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
      have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
      rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
      rewrite !n8_vgs //=.
      do! split => //.
      apply (vat_weaken _ _ _ _ _ _ (vat_set2 _ _ _ _ 8 _ _ _ (vat_set2 _ _ _ _ 8 _ _ _ hv)))
        => // x i hx hi hp /=.
      move: hp; rewrite /PE /PC hlt /= => hp.
      case: (i = 8) => [->> /=|h8 /=]; last by rewrite hp /= /fE h8.
      have /= hs0 := hs 0 n8_x0; have /= hs1 := hs 1 n8_x1.
      by case: (n8_c2 x hx) => ->> /=;
        rewrite !(vat_get _ _ _ _ _ _ hv) // /fC /fB /fE /T1v /chx /= ?hs0 ?hs1 hlt.
    seq 2 : (0 <= t < 64 /\ h8 = H /\ k = sHA256_K /\ vat v t (fG H Ms t) (PE t) /\
             (forall x, 0 <= x < 2 =>
                BArray64.get128 ab (2 * x + (t + 1) %% 2) = vx (LH H) Ms x t 1 +^ vx (LH H) Ms x t 2) /\
             (t < 63 => kq = BArray256.get128 sHA256_K ((t + 1) %/ 4)) /\ winv w Ms (t + 1)).
    + unroll for 2; wp; skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw /=.
      have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
      have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
      rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
      rewrite !n8_vgs //=.
      do! split => //.
      apply (vat_weaken _ _ _ _ _ _ (vat_set2 _ _ _ _ 3 _ _ _ hv)) => // x i hx hi hp /=.
      case: (i = 3) => [->> /=|h3 /=]; last by rewrite hp /= /fG h3.
      have e := n8_vx_e (LH H) Ms (chx (LH H) Ms x t{hr}) x t{hr} _ (n8_chx _ _ _ _); first done.
      case: (n8_c2 x hx) => ->> /=;
        rewrite !(vat_get _ _ _ _ _ _ hv) // /PE /fG /fE /fC /fB /=; exact e.
    unroll for 11; unroll for 9; unroll for 7; unroll for 5.
    wp; ecall (n8_S0_h (BArray288.get128 v (((0 + 576) - t) %% 9))
                      (BArray288.get128 v (9 + ((0 + 576) - t) %% 9))).
    skip => &hr [#] ht0 ht1 -> -> hv hab hkq hw /= r -> /=.
    have [#] f10 f11 f12 f13 f14 f15 f16 f17 f18 := n8_sv1 t{hr}.
    have [#] f00 f01 f02 f03 f04 f05 f06 f07 f08 := n8_sv0 t{hr}.
    rewrite ?f10 ?f11 ?f12 ?f13 ?f14 ?f15 ?f16 ?f17 ?f18 ?f00 ?f01 ?f02 ?f03 ?f04 ?f05 ?f06 ?f07 ?f08.
    rewrite !n8_vgs //=.
    have /= hab0 := hab 0 n8_x0; have /= hab1 := hab 1 n8_x1.
    rewrite /rinv n8_par2 n8_lt63 /=.
    case: (n8_par t{hr}) => [[hp hp1] | [hp hp1]]; (move: hab0 hab1; rewrite hp hp1 /= => hab0 hab1;
      (split; first exact (n8_s2 _ ht0 ht1)); split; [
        apply (vat_weaken _ _ _ _ _ _ (vat_next _ _ _ _ (vat_set2 _ _ _ _ 8 _ _ _ hv)))
          => // x i hx hi hp' /=;
        case: (n8_c9 i hi) => [|[|[|[|[|[|[|[|]]]]]]]] ->> /=;
        [ by case: (n8_c2 x hx) => ->> /=;
             rewrite !(vat_get _ _ _ _ _ _ hv) // /fG /fE /= ?hab0 ?hab1
                     (n8_vx_a _ _ _ _ _ ht0 (n8_chx _ _ _ _))
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv
        | by rewrite /PE ?hp' /fG /fE /fC /fB /= ?n8_vx_mv ]
      | split; [ move=> _ x hx; case: (n8_c2 x hx) => ->> /=;
                 rewrite !(vat_get _ _ _ _ _ _ hv) // /fG /fE /fC /fB /= n8_vx_bc //
               | split; [ exact hkq | by move=> _; exact hw ] ] ]).
  skip => &hr hpre; split; first done.
  move=> ab0 kq0 t0 v0 w0 hnt [hr [hh _]]; split; last done.
  have ht : t0 = 64 by move: hr; rewrite /rinv => /#.
  by rewrite -ht.
unroll for 2; unroll for 7; unroll for 2.
wp; skip => &hr [hr ->] /=; apply (n8_lanes _ H Ms).
have hvat : vat v{hr} 64 (fun x i => if i = 8 then vx (LH H) Ms x 64 7 \vadd32u128 kx 64 else vx (LH H) Ms x 64 i)
              (fun i => if 64 < 64 then i <> 7 else i < 8) by move: hr; rewrite /rinv => [#].
move=> x j hx hj; have := vat_get _ _ _ _ x j hvat hx; rewrite /sv /=.
case: (n8_c8 j hj) => [|[|[|[|[|[|[|]]]]]]] ->>; case: (n8_c2 x hx) => ->> /= hv; by rewrite hv.
qed.

(* ------------------------------------------------------------------ *)
(* Termination                                                        *)

lemma n8_S0_ll : islossless M.__Sigma0_x2 by proc; inline *; auto.
lemma n8_S1_ll : islossless M.__Sigma1_x2 by proc; inline *; auto.
lemma n8_s0_ll : islossless M.__sigma0_x2 by proc; inline *; auto.
lemma n8_s1_ll : islossless M.__sigma1_x2 by proc; inline *; auto.

lemma n8_block_ll : islossless M._sha256_x8_block.
proof.
proc.
while (0 <= x <= 2) (2 - x).
+ move=> z; wp; while (0 <= j <= 7) (7 - j); first by auto => /#.
  by auto => /#.
wp; while (0 <= t <= 64) (64 - t).
+ move=> z; conseq (_ : _ ==> true) (_ : _ ==> _) => //.
  + seq 1 : (0 <= t < 64 /\ 64 - t = z).
    + if.
      + seq 20 : (0 <= t < 64 /\ 64 - t = z); first by inline *; do! (wp; while (true); first by auto); auto => /#.
        by if; [do! (wp; while (true); first by auto); auto => /# | auto].
      by do! (wp; while (true); first by auto); auto => /#.
    seq 2 : (0 <= t < 64 /\ 64 - t = z); first by do! (wp; while (true); first by auto); auto => /#.
    seq 1 : (0 <= t < 64 /\ 64 - t = z).
    + if; last by auto.
      seq 1 : (0 <= t < 64 /\ 64 - t = z); first by if; auto.
      by do! (wp; while (true); first by auto); auto => /#.
    seq 3 : (0 <= t < 64 /\ 64 - t = z); first by inline *; auto.
    seq 1 : (0 <= t < 64 /\ 64 - t = z); first by if; do! (wp; while (true); first by auto); auto => /#.
    by inline *; do! (wp; while (true); first by auto); auto => /#.
  seq 1 : true 1%r 1%r 0%r 0%r => //.
  + if.
    + seq 20 : true 1%r 1%r 0%r 0%r => //; first by inline *; do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
      by if; [do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /# | auto].
    by do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
  seq 2 : true 1%r 1%r 0%r 0%r => //; first by do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
  seq 1 : true 1%r 1%r 0%r 0%r => //.
  + if; last by auto.
    seq 1 : true 1%r 1%r 0%r 0%r => //; first by if; auto.
    by do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
  seq 3 : true 1%r 1%r 0%r 0%r => //; first by inline *; auto.
  seq 1 : true 1%r 1%r 0%r 0%r => //; first by if; do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
  by inline *; do! (wp; while (0 <= x <= 2) (2 - x); first by auto => /#); auto => /#.
wp; while (0 <= x <= 2) (2 - x); first by auto => /#.
wp; while (0 <= x <= 2) (2 - x).
+ move=> z; wp; while (0 <= j <= 7) (7 - j); first by auto => /#.
  by auto => /#.
by auto => /#.
qed.
