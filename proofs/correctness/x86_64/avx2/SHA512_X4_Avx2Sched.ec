(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4_Avx2Sched.ec (x86_64, avx2)
 * ====================================
 *
 * Functional correctness of the 4-way SHA-512 AVX2 kernel
 * (src/x86_64/avx2/sha512_x4_compress.jinc) against FIPS 180-4 section
 * 6.4.2, message schedule and round constants:
 *
 *   schedule_x4   one call of __sha512_x4_schedule: W_t of step 1 on
 *                 every lane, into slot t mod 16 of the 16-word window
 *   K4_kernel     the table SHA512_X4_K holds K_t (section 4.2.3) in
 *                 every lane of its 256-bit word t
 *   ror8E         the shuffle mask SHA512_X4_ROR8 is ror8_mask4
 *
 * The kernel runs rounds 16 to 79 as four passes of a loop whose round
 * counter t goes from 16 to 31, so the round R of the specification is
 * t + 16 p in pass p. The window is indexed modulo 16, so the kernel's
 * slots are those of round R (wins).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray32 BArray512 BArray2560.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Lanes64 Rounds512 SHA512_X4_Avx2Vec SHA512_X4_Avx2Rounds.
import SHA512.

clone SHA512_X4_Avx2Vec.X4Lanes as A2560 with theory A <- BArray2560.
clone SHA512_X4_Avx2Vec.X4Lanes as A32 with theory A <- BArray32.

(* ------------------------------------------------------------------ *)
(* The round constants                                                *)

op rep4 (x : 'a) : 'a list = [x; x; x; x].

lemma K4_list i : BArray2560.get64 sHA512_X4_K i = nth W64.zero (flatten (map rep4 K512)) i.
proof.
rewrite BArray2560.get64_of_list64 1://.
by congr; rewrite /K512 /rep4 /flatten /=.
qed.

lemma nth_rep4 (s : 'a list) (x0 : 'a) R L : 0 <= R => 0 <= L < 4 =>
  nth x0 (flatten (map rep4 s)) (4 * R + L) = nth x0 s R.
proof.
elim: s R => [|y s ih] R hR hL; first by rewrite /= flatten_nil.
rewrite /= flatten_cons nth_cat {1}/rep4 /=.
case: (R = 0) => [->> /=|hR0].
+ by rewrite (_: 4 * 0 + L < 4) 1:/# /=; have [->|[->|[->|->]]] := cases4 L hL.
rewrite (_: !(4 * R + L < 4)) 1:/# /= (_: 4 * R + L - 4 = 4 * (R - 1) + L) 1:/#.
by rewrite ih /#.
qed.

lemma K4_kernel R L : 0 <= R < 80 => 0 <= L < 4 =>
  BArray2560.get256 sHA512_X4_K R \bits64 L = nth W64.zero K512 R.
proof.
move=> hR hL; rewrite A2560.get256_bits64 // K4_list.
by rewrite nth_rep4 /#.
qed.

(* The ROTR^8 shuffle mask. *)
lemma ror8E : BArray32.get256 sHA512_X4_ROR8 0 = ror8_mask4.
proof.
apply W4u64.wordP => j hj.
by rewrite A32.get256_bits64 // BArray32.get64_of_list64 // /ror8_mask4 pk4_lane.
qed.

(* ------------------------------------------------------------------ *)
(* __sha512_x4_schedule                                               *)

(* Lane L of the 16-word window. *)
op wg (w : BArray512.t) (L : int) : int -> W64.t = fun j => BArray512.get256 w j \bits64 L.

(* The window of every lane holds the schedule ws L of that lane's block.
   The schedules are a parameter rather than schedule (ms L): simplifying
   a goal that holds schedule unrolls its 64 steps. *)
op wins (w : BArray512.t) (ws : int -> W64.t list) (R : int) =
  forall L, 0 <= L < 4 => window_ok (wg w L) (ws L) R.

lemma mod16_sub t R c : t %% 16 = R %% 16 => (t - c) %% 16 = (R - c) %% 16.
proof. by move=> h; rewrite -modzDml h modzDml. qed.

lemma schedule_x4 (t0 R : int) (w0 : BArray512.t) (ms ws : int -> W64.t list) :
  (forall L, 0 <= L < 4 => size (ms L) = 16 /\ ws L = schedule (ms L)) =>
  hoare [M.__sha512_x4_schedule :
    t = t0 /\ w = w0 /\ ror8 = ror8_mask4 /\ t0 %% 16 = R %% 16 /\ 16 <= R < 80 /\ wins w0 ws R ==>
    wins res.`1 ws (R + 1) /\
    (forall L, 0 <= L < 4 => res.`2 \bits64 L = nth W64.zero (ws L) R)].
proof.
move=> hms; proc.
wp; ecall (sigma1_4x_ok s); wp; ecall (sigma0_4x_ok s ror8); wp.
skip => &hr /= [#] -> -> -> htR hR1 hR2 hw r0 -> r1 ->.
have hR : 16 <= R < 80 by done.
have h15 := mod16_sub _ _ 15 htR; have h7 := mod16_sub _ _ 7 htR; have h2 := mod16_sub _ _ 2 htR.
have [ht0 ht1] : 0 <= t0 %% 16 < 16 by apply modz_cmp.
have hwt : forall L, 0 <= L < 4 =>
  (VPADD_4u64 (VPADD_4u64 (VPADD_4u64 (vs0x4 (BArray512.get256 w0 ((t0 - 15) %% 16)) ror8_mask4)
     (BArray512.get256 w0 (t0 %% 16))) (BArray512.get256 w0 ((t0 - 7) %% 16)))
     (vs1x4 (BArray512.get256 w0 ((t0 - 2) %% 16)))) \bits64 L
  = nth W64.zero (ws L) R.
+ move=> L hL; have [hs hws] := hms L hL.
  have := hw L hL; rewrite hws => hwL.
  rewrite !vpadd64 // vs0x4_lane // vs1x4_lane // h15 h7 h2 htR.
  rewrite -(window_wt (wg w0 L) (ms L) R hs hR hwL) /wg /=.
  by ring.
split; last by exact hwt.
move=> L hL; apply (window_set (wg w0 L)); 1,2: by [] || exact (hw L hL).
+ rewrite /wg /= BArray512.get_set256E // 1:/# -htR /=.
  exact (hwt L hL).
move=> k hk hkR; rewrite /wg /= BArray512.get_set256E // 1:/#.
by rewrite htR (eq_sym (R %% 16)) hkR.
qed.
