(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Vec.ec (x86_64)
 * ===============
 *
 * Lane meaning of the 128-bit vector operations the x86-64 kernels use,
 * as eclib/JModel_x86.ec defines them. Every statement is about words
 * only; no model of the library is needed, so this file is checked once.
 *
 * A 128-bit register is written p4 a b c d: four 32-bit lanes, lane 0
 * (the least significant) first. The lemmas name the immediates the
 * kernels use (VPSHUFD 0xb1, 0x1b, 0x0e; VPALIGNR 4, 8; VPBLENDW 0xf0;
 * the PSHUFB mask that reverses the bytes of each lane).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import WordSpec.

(* ------------------------------------------------------------------ *)
(* Four 32-bit lanes                                                   *)

op p4 (a b c d : W32.t) : W128.t = W4u32.pack4 [a; b; c; d].

lemma p4_lane (a b c d : W32.t) (i : int) : 0 <= i < 4 =>
  p4 a b c d \bits32 i = nth W32.zero [a; b; c; d] i.
proof. by move=> hi; rewrite /p4 (W4u32.get_pack4 [a; b; c; d] i) 1:/#. qed.

lemma p4_0 (a b c d : W32.t) : p4 a b c d \bits32 0 = a.
proof. by rewrite p4_lane. qed.
lemma p4_1 (a b c d : W32.t) : p4 a b c d \bits32 1 = b.
proof. by rewrite p4_lane. qed.
lemma p4_2 (a b c d : W32.t) : p4 a b c d \bits32 2 = c.
proof. by rewrite p4_lane. qed.
lemma p4_3 (a b c d : W32.t) : p4 a b c d \bits32 3 = d.
proof. by rewrite p4_lane. qed.

hint simplify p4_0, p4_1, p4_2, p4_3.

(* Every 128-bit word is the p4 of its lanes. *)
lemma p4_eta (x : W128.t) :
  p4 (x \bits32 0) (x \bits32 1) (x \bits32 2) (x \bits32 3) = x.
proof. by apply W4u32.allP. qed.

lemma p4P (x : W128.t) (a b c d : W32.t) :
  x \bits32 0 = a => x \bits32 1 = b => x \bits32 2 = c => x \bits32 3 = d =>
  x = p4 a b c d.
proof. by move=> <- <- <- <-; rewrite p4_eta. qed.

(* ------------------------------------------------------------------ *)
(* Lane-wise addition                                                  *)

lemma vpadd4_pack (a b c d e f g h : W32.t) :
  VPADD_4u32 (p4 a b c d) (p4 e f g h) = p4 (a + e) (b + f) (c + g) (d + h).
proof. by apply W4u32.allP; rewrite /VPADD_4u32 /=. qed.

(* ------------------------------------------------------------------ *)
(* VPSHUFD: lane i of the result is lane (m >> 2i) & 3 of the source   *)

lemma vpshufd_b1 (x : W128.t) :
  VPSHUFD_128 x (W8.of_int 177)
  = p4 (x \bits32 1) (x \bits32 0) (x \bits32 3) (x \bits32 2).
proof. by rewrite /VPSHUFD_128 /VPSHUFD_128_B. qed.

lemma vpshufd_1b (x : W128.t) :
  VPSHUFD_128 x (W8.of_int 27)
  = p4 (x \bits32 3) (x \bits32 2) (x \bits32 1) (x \bits32 0).
proof. by rewrite /VPSHUFD_128 /VPSHUFD_128_B. qed.

(* 0x0e moves lanes 2 and 3 down to lanes 0 and 1. *)
lemma vpshufd_0e_0 (x : W128.t) : VPSHUFD_128 x (W8.of_int 14) \bits32 0 = x \bits32 2.
proof. by rewrite /VPSHUFD_128 /VPSHUFD_128_B. qed.

lemma vpshufd_0e_1 (x : W128.t) : VPSHUFD_128 x (W8.of_int 14) \bits32 1 = x \bits32 3.
proof. by rewrite /VPSHUFD_128 /VPSHUFD_128_B. qed.

(* ------------------------------------------------------------------ *)
(* VPALIGNR: the low 128 bits of [y; x] shifted right by m bytes       *)

(* By 4 bytes: lanes 1 to 3 of the second operand, then lane 0 of the
   first. *)
lemma vpalignr4 (x y : W128.t) :
  VPALIGNR_128 x y (W8.of_int 4) = p4 (y \bits32 1) (y \bits32 2) (y \bits32 3) (x \bits32 0).
proof.
apply W4u32.wordP => i hi; rewrite p4_lane //.
apply W32.wordP => j hj.
rewrite /VPALIGNR_128 /= W4u32.bits32iE // W2u128.bits128iE 1:/# /=.
rewrite W2u128.pack2wE 1:/#.
have: i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
case => [->|[->|[->|->]]] /=.
+ have ->: (j + 32) %/ 128 = 0 by smt().
  have ->: (j + 32) %% 128 = 32 + j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= j < 256) 1:/#.
+ have ->: (64 + j) %/ 128 = 0 by smt().
  have ->: (64 + j) %% 128 = 64 + j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= 32 + j < 256) 1:/#.
+ have ->: (96 + j) %/ 128 = 0 by smt().
  have ->: (96 + j) %% 128 = 96 + j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= 64 + j < 256) 1:/#.
have ->: (128 + j) %/ 128 = 1 by smt().
have ->: (128 + j) %% 128 = j by smt().
by rewrite W4u32.bits32iE // (_: 0 <= 96 + j < 256) 1:/#.
qed.

(* By 8 bytes: lanes 2 and 3 of the second operand, then lanes 0 and 1
   of the first. *)
lemma vpalignr8 (x y : W128.t) :
  VPALIGNR_128 x y (W8.of_int 8) = p4 (y \bits32 2) (y \bits32 3) (x \bits32 0) (x \bits32 1).
proof.
apply W4u32.wordP => i hi; rewrite p4_lane //.
apply W32.wordP => j hj.
rewrite /VPALIGNR_128 /= W4u32.bits32iE // W2u128.bits128iE 1:/# /=.
rewrite W2u128.pack2wE 1:/#.
have: i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
case => [->|[->|[->|->]]] /=.
+ have ->: (j + 64) %/ 128 = 0 by smt().
  have ->: (j + 64) %% 128 = 64 + j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= j < 256) 1:/#.
+ have ->: (96 + j) %/ 128 = 0 by smt().
  have ->: (96 + j) %% 128 = 96 + j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= 32 + j < 256) 1:/#.
+ have ->: (128 + j) %/ 128 = 1 by smt().
  have ->: (128 + j) %% 128 = j by smt().
  by rewrite W4u32.bits32iE // (_: 0 <= 64 + j < 256) 1:/#.
have ->: (160 + j) %/ 128 = 1 by smt().
have ->: (160 + j) %% 128 = 32 + j by smt().
by rewrite W4u32.bits32iE // (_: 0 <= 96 + j < 256) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* VPBLENDW 0xf0: 16-bit words 0 to 3 from x, 4 to 7 from y            *)

lemma vpblendw_f0 (x y : W128.t) :
  VPBLEND_8u16 x y (W8.of_int 240) = p4 (x \bits32 0) (x \bits32 1) (y \bits32 2) (y \bits32 3).
proof.
apply W16u8.allP; rewrite /VPBLENDW_128 /p4 /=.
by rewrite !W8.of_intwE /int_bit.
qed.

(* ------------------------------------------------------------------ *)
(* Two 64-bit halves                                                   *)

(* VMOV_64 of each half, then VPUNPCKLQDQ, is the pair [a; b]. *)
lemma vpunpckl_vmov64 (a b : W64.t) :
  VPUNPCKL_2u64 (VMOV_64 a) (VMOV_64 b) = W2u64.pack2 [a; b].
proof. by rewrite /VPUNPCKL_2u64 /interleave_gen /get_lo_2u64 /VMOV_64 /=. qed.

(* The 32-bit lanes of a pair of 64-bit words. *)
lemma pack2_bits32 (a b : W64.t) :
  W2u64.pack2 [a; b] = p4 (a \bits32 0) (a \bits32 1) (b \bits32 0) (b \bits32 1).
proof.
by apply W16u8.allP; rewrite /p4.
qed.

(* ------------------------------------------------------------------ *)
(* VPSHUFB with the mask that reverses the bytes of each 32-bit lane   *)

(* As little-endian 32-bit lanes, lane i selects source bytes 4i+3,
   4i+2, 4i+1, 4i. *)
op bswap_mask32 : W128.t =
  p4 (W32.of_int 66051) (W32.of_int 67438087) (W32.of_int 134810123) (W32.of_int 202182159).

lemma vpshufb_bswap32 (x : W128.t) :
  VPSHUFB_128 x bswap_mask32
  = p4 (bswap32 (x \bits32 0)) (bswap32 (x \bits32 1)) (bswap32 (x \bits32 2)) (bswap32 (x \bits32 3)).
proof.
apply W16u8.allP; rewrite /VPSHUFB_128 /bswap_mask32 /p4 /=.
by rewrite /VPSHUFB_128_B !W4u8.of_int_bits8_div // /= !W8.of_uintK /= /bswap32.
qed.
