(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2X8Sched.ec (x86_64, avx2)
 * ====================================
 *
 * Functional correctness of the 8-way SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_x8_compress.jinc) against FIPS 180-4 section
 * 6.2.2, message schedule and round constants:
 *
 *   schedule_x8   one call of __sha256_x8_schedule: W_t of step 1 on
 *                 every lane, into slot t mod 16 of the 16-word window
 *   K8_kernel     the table SHA256_X8_K holds K_t (section 4.2.2) in
 *                 every lane of its 256-bit word t
 *
 * The kernel runs rounds 16 to 63 as three passes of a loop whose round
 * counter t goes from 16 to 31, so the round R of the specification is
 * t + 16 p in pass p. The window is indexed modulo 16, so the kernel's
 * slots are those of round R (wins).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray512 BArray2048.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Rounds256 SHA256_Avx2X8Vec SHA256_Avx2X8Rounds.
import SHA256.

clone SHA256_Avx2X8Vec.X8Lanes as A2048 with theory A <- BArray2048.

(* ------------------------------------------------------------------ *)
(* The round constants                                                *)

op rep8 (x : 'a) : 'a list = [x; x; x; x; x; x; x; x].

lemma K8_list i : BArray2048.get32 sHA256_X8_K i = nth W32.zero (flatten (map rep8 K256)) i.
proof.
rewrite BArray2048.get32_of_list32 1://.
by congr; rewrite /K256 /rep8 /flatten /=.
qed.

lemma nth_rep8 (s : 'a list) (x0 : 'a) R L : 0 <= R => 0 <= L < 8 =>
  nth x0 (flatten (map rep8 s)) (8 * R + L) = nth x0 s R.
proof.
elim: s R => [|y s ih] R hR hL; first by rewrite /= flatten_nil.
rewrite /= flatten_cons nth_cat {1}/rep8 /=.
case: (R = 0) => [->> /=|hR0].
+ by rewrite (_: 8 * 0 + L < 8) 1:/# /=; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL.
rewrite (_: !(8 * R + L < 8)) 1:/# /= (_: 8 * R + L - 8 = 8 * (R - 1) + L) 1:/#.
by rewrite ih /#.
qed.

lemma K8_kernel R L : 0 <= R < 64 => 0 <= L < 8 =>
  BArray2048.get256 sHA256_X8_K R \bits32 L = nth W32.zero K256 R.
proof.
move=> hR hL; rewrite A2048.get256_bits32 // K8_list.
by rewrite nth_rep8 /#.
qed.

(* ------------------------------------------------------------------ *)
(* __sha256_x8_schedule                                               *)

(* Lane L of the 16-word window. *)
op wg (w : BArray512.t) (L : int) : int -> W32.t = fun j => BArray512.get256 w j \bits32 L.

(* The window of every lane holds the schedule ws L of that lane's block.
   The schedules are a parameter rather than schedule (ms L): simplifying
   a goal that holds schedule unrolls its 48 steps. *)
op wins (w : BArray512.t) (ws : int -> W32.t list) (R : int) =
  forall L, 0 <= L < 8 => window_ok (wg w L) (ws L) R.

lemma mod16_sub t R c : t %% 16 = R %% 16 => (t - c) %% 16 = (R - c) %% 16.
proof. by move=> h; rewrite -modzDml h modzDml. qed.

lemma schedule_x8 (t0 R : int) (w0 : BArray512.t) (ms ws : int -> W32.t list) :
  (forall L, 0 <= L < 8 => size (ms L) = 16 /\ ws L = schedule (ms L)) =>
  hoare [M.__sha256_x8_schedule :
    t = t0 /\ w = w0 /\ t0 %% 16 = R %% 16 /\ 16 <= R < 64 /\ wins w0 ws R ==>
    wins res.`1 ws (R + 1) /\
    (forall L, 0 <= L < 8 => res.`2 \bits32 L = nth W32.zero (ws L) R)].
proof.
move=> hms; proc.
wp; ecall (sigma1_8x_ok s); wp; ecall (sigma0_8x_ok s); wp.
skip => &hr /= [#] -> -> htR hR1 hR2 hw r0 -> r1 ->.
have hR : 16 <= R < 64 by done.
have h15 := mod16_sub _ _ 15 htR; have h7 := mod16_sub _ _ 7 htR; have h2 := mod16_sub _ _ 2 htR.
have [ht0 ht1] : 0 <= t0 %% 16 < 16 by apply modz_cmp.
have hwt : forall L, 0 <= L < 8 =>
  (VPADD_8u32 (VPADD_8u32 (VPADD_8u32 (vs0 (BArray512.get256 w0 ((t0 - 15) %% 16)))
     (BArray512.get256 w0 (t0 %% 16))) (BArray512.get256 w0 ((t0 - 7) %% 16)))
     (vs1 (BArray512.get256 w0 ((t0 - 2) %% 16)))) \bits32 L
  = nth W32.zero (ws L) R.
+ move=> L hL; have [hs hws] := hms L hL.
  have := hw L hL; rewrite hws => hwL.
  rewrite !vpadd32 // vs0_lane // vs1_lane // h15 h7 h2 htR.
  rewrite -(window_wt (wg w0 L) (ms L) R hs hR hwL) /wg /=.
  by ring.
split; last by exact hwt.
move=> L hL; apply (window_set (wg w0 L)); 1,2: by [] || exact (hw L hL).
+ rewrite /wg /= BArray512.get_set256E // 1:/# -htR /=.
  exact (hwt L hL).
move=> k hk hkR; rewrite /wg /= BArray512.get_set256E // 1:/#.
by rewrite htR (eq_sym (R %% 16)) hkR.
qed.
