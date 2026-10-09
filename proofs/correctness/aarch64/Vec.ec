(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Vec.ec (aarch64)
 * ================
 *
 * Lane meanings of the Advanced SIMD instructions the AArch64 kernels use,
 * as the Jasmin model JModel_armv8a defines them. A 128-bit register is
 * read as four 32-bit or two 64-bit lanes, lane 0 the least significant
 * (\bits32 0, \bits64 0); p4 and p2 build a register from its lanes in that
 * order. Every lemma states one instruction once, so the kernel proofs
 * never unfold an instruction model.
 *
 *     VADD_4u32, VADD_2u64   lane-wise addition
 *     VEXT #8                upper lane of the first pair, lower lane of
 *                            the second
 *     VREV32_16u8,           byte reversal of each 32-bit (64-bit) lane,
 *     VREV64_16u8            the big-endian load of the message words
 *     VSRI_4u32 after SHL    rotation right of each 32-bit lane
 *     VBIT, VBSL, AND/BIC    Ch and Maj of FIPS 180-4 section 4.1.2, lane
 *                            by lane
 *
 * The model-free statements here are checked once (proofs/Makefile,
 * check-lib).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_armv8a.
require import WordSpec FIPS180_SHA2.

(* ------------------------------------------------------------------ *)
(* Packing, lane 0 lowest                                             *)

op p4 (a b c d : W32.t) : W128.t = W4u32.pack4 [a; b; c; d].
op p2 (a b : W64.t) : W128.t = W2u64.pack2 [a; b].

lemma iota04 : iota_ 0 4 = [0; 1; 2; 3].
proof.
by rewrite (iotaS_minus 0 4) // (iotaS_minus 1 3) // (iotaS_minus 2 2) //
           (iotaS_minus 3 1) // iota0.
qed.

lemma p4_lane (a b c d : W32.t) (i : int) : 0 <= i < 4 =>
  p4 a b c d \bits32 i = nth W32.zero [a; b; c; d] i.
proof. by move=> hi; rewrite /p4 (W4u32.get_pack4 [a; b; c; d] i) 1:/#. qed.

lemma p4_0 (a b c d : W32.t) : p4 a b c d \bits32 0 = a by rewrite p4_lane.
lemma p4_1 (a b c d : W32.t) : p4 a b c d \bits32 1 = b by rewrite p4_lane.
lemma p4_2 (a b c d : W32.t) : p4 a b c d \bits32 2 = c by rewrite p4_lane.
lemma p4_3 (a b c d : W32.t) : p4 a b c d \bits32 3 = d by rewrite p4_lane.

lemma p2_lane (a b : W64.t) (i : int) : 0 <= i < 2 =>
  p2 a b \bits64 i = nth W64.zero [a; b] i.
proof. by move=> hi; rewrite /p2 (W2u64.get_pack2 [a; b] i) 1:/#. qed.

lemma p2_0 (a b : W64.t) : p2 a b \bits64 0 = a by rewrite p2_lane.
lemma p2_1 (a b : W64.t) : p2 a b \bits64 1 = b by rewrite p2_lane.

(* Every register is the pack of its lanes. *)
lemma p4_bits (x : W128.t) :
  x = p4 (x \bits32 0) (x \bits32 1) (x \bits32 2) (x \bits32 3).
proof.
apply (W4u32.wordP x (p4 (x \bits32 0) (x \bits32 1) (x \bits32 2) (x \bits32 3))) => i hi.
rewrite p4_lane //.
have: i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
by case=> [->|[->|[->|->]]].
qed.

lemma p2_bits (x : W128.t) : x = p2 (x \bits64 0) (x \bits64 1).
proof.
apply (W2u64.wordP x (p2 (x \bits64 0) (x \bits64 1))) => i hi.
rewrite p2_lane //.
have: i = 0 \/ i = 1 by smt().
by case=> [->|->].
qed.

lemma p4_eq (a b c d a' b' c' d' : W32.t) :
  a = a' => b = b' => c = c' => d = d' => p4 a b c d = p4 a' b' c' d'.
proof. by move=> -> -> -> ->. qed.

lemma p2_eq (a b a' b' : W64.t) : a = a' => b = b' => p2 a b = p2 a' b'.
proof. by move=> -> ->. qed.

(* ------------------------------------------------------------------ *)
(* Addition and EXT                                                   *)

lemma vadd4_pack (a b c d e f g h : W32.t) :
  VADD_4u32 (p4 a b c d) (p4 e f g h) = p4 (a + e) (b + f) (c + g) (d + h).
proof.
apply W4u32.wordP => i hi.
rewrite /VADD_4u32 /VPADD_4u32 W4u32.map2bE 1:// !p4_lane //.
have: i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
by case=> [->|[->|[->|->]]].
qed.

lemma vadd2_pack (a b c d : W64.t) :
  VADD_2u64 (p2 a b) (p2 c d) = p2 (a + c) (b + d).
proof.
apply W2u64.wordP => i hi.
rewrite /VADD_2u64 /VPADD_2u64 W2u64.map2bE 1:// !p2_lane //.
have: i = 0 \/ i = 1 by smt().
by case=> [->|->].
qed.

(* EXT #8 on two pairs: the upper lane of the first, the lower lane of the
   second. *)
lemma vext8 (a b c d : W64.t) :
  VEXT (p2 a b) (p2 c d) (W8.of_int 8) = p2 b c.
proof.
apply W16u8.wordP => k hk.
rewrite /VEXT W16u8.pack16bE 1:// W16u8.Pack.initiE 1:// /=.
rewrite /p2; case: (k < 8) => hk8.
+ rewrite ifT 1:/# !bits8_W2u64_red 1,2:/#.
  have ->: (k + 8) %/ 8 = 1 by smt().
  have ->: (k + 8) %% 8 = k by smt().
  have ->: k %/ 8 = 0 by smt().
  by have ->: k %% 8 = k by smt().
rewrite ifF 1:/# ifT 1:/# !bits8_W2u64_red 1,2:/#.
have ->: (k - 8) %/ 8 = 0 by smt().
have ->: (k - 8) %% 8 = k - 8 by smt().
have ->: k %/ 8 = 1 by smt().
by have ->: k %% 8 = k - 8 by smt().
qed.


(* ------------------------------------------------------------------ *)
(* Byte reversal of each lane                                         *)

lemma vrev32_lane (x : W128.t) (i : int) : 0 <= i < 4 =>
  VREV32_16u8 x \bits32 i = bswap32 (x \bits32 i).
proof.
move=> hi; rewrite /VREV32_16u8 bits32_W16u8_red // /bswap32.
rewrite !W16u8.Pack.initiE 1..4:/# /= /rev /=.
have e0 : 4 * i %/ 4 * 4 + (3 - 4 * i %% 4) = 4 * i + 3 by smt().
have e1 : (4 * i + 1) %/ 4 * 4 + (3 - (4 * i + 1) %% 4) = 4 * i + 2 by smt().
have e2 : (4 * i + 2) %/ 4 * 4 + (3 - (4 * i + 2) %% 4) = 4 * i + 1 by smt().
have e3 : (4 * i + 3) %/ 4 * 4 + (3 - (4 * i + 3) %% 4) = 4 * i by smt().
by rewrite e0 e1 e2 e3.
qed.

lemma vrev64_lane (x : W128.t) (i : int) : 0 <= i < 2 =>
  VREV64_16u8 x \bits64 i = bswap64 (x \bits64 i).
proof.
move=> hi; rewrite /VREV64_16u8 bits64_W16u8_red // /bswap64.
rewrite !W16u8.Pack.initiE 1..8:/# /= /rev /=.
have e : forall j, 0 <= j < 8 =>
  (8 * i + j) %/ 8 * 8 + (7 - (8 * i + j) %% 8) = 8 * i + (7 - j) by smt().
have e0 : 8 * i %/ 8 * 8 + (7 - 8 * i %% 8) = 8 * i + 7 by smt().
by rewrite e0 !e //.
qed.

(* ------------------------------------------------------------------ *)
(* SHA-256 functions of section 4.1.2, four lanes at a time           *)

theory N256.
import SHA256.

(* Rotation right of each 32-bit lane by SHL #(32 - r), then SRI #r:
   y = x << (32 - r); y = SRI(y, x, r). *)
op rotv (x : W128.t) (r : int) : W128.t =
  VSRI_4u32 (x \vshl32u128 (W128.of_int (32 - r))) x (W8.of_int r).

lemma rotv_lane (x : W128.t) (r i : int) : 0 < r < 32 => 0 <= i < 4 =>
  rotv x r \bits32 i = (x \bits32 i) `|>>>|` r.
proof.
move=> hr hi; rewrite /rotv /VSRI_4u32 W4u32.map2bE // /(\vshl32u128) W4u32.mapbE // /=.
rewrite W128.to_uint_small 1:/# W8.to_uint_small 1:/#.
apply W32.wordP => j hj; rewrite /=.
case: (j + r < 32) => hjr.
+ by rewrite (W32.get_out _ (j - (32 - r))) 1:/# /= modz_small 1:/#.
rewrite (W32.get_out _ (j + r)) 1:/# /=.
by rewrite (_: (j + r) %% 32 = j - (32 - r)) 1:/#; smt().
qed.

(* __Sigma0_x2, __Sigma1_x2, __sigma0_x2, __sigma1_x2, lane by lane. *)
lemma vbsig0 (x : W128.t) (i : int) : 0 <= i < 4 =>
  (rotv x 2 +^ rotv x 13 +^ rotv x 22) \bits32 i = bsig0 (x \bits32 i).
proof. by move=> hi; rewrite !W4u32.xorb32E !rotv_lane // /bsig0. qed.

lemma vbsig1 (x : W128.t) (i : int) : 0 <= i < 4 =>
  (rotv x 6 +^ rotv x 11 +^ rotv x 25) \bits32 i = bsig1 (x \bits32 i).
proof. by move=> hi; rewrite !W4u32.xorb32E !rotv_lane // /bsig1. qed.

lemma vssig0 (x : W128.t) (i : int) : 0 <= i < 4 =>
  (rotv x 7 +^ rotv x 18 +^ (x \vshr32u128 (W128.of_int 3))) \bits32 i = ssig0 (x \bits32 i).
proof.
by move=> hi; rewrite !W4u32.xorb32E !rotv_lane // /(\vshr32u128) W4u32.mapbE //= /ssig0.
qed.

lemma vssig1 (x : W128.t) (i : int) : 0 <= i < 4 =>
  (rotv x 17 +^ rotv x 19 +^ (x \vshr32u128 (W128.of_int 10))) \bits32 i = ssig1 (x \bits32 i).
proof.
by move=> hi; rewrite !W4u32.xorb32E !rotv_lane // /(\vshr32u128) W4u32.mapbE //= /ssig1.
qed.

(* Ch(e, f, g) by BIT, which overwrites g: g = BIT(g, f, e). *)
lemma vbit_ch (e f g : W128.t) (i : int) : 0 <= i < 4 =>
  VBIT g f e \bits32 i = ch (e \bits32 i) (f \bits32 i) (g \bits32 i).
proof.
move=> hi; rewrite /VBIT !W4u32.xorb32E W4u32.andb32E W4u32.xorb32E /ch.
apply W32.wordP => j hj /=.
by case: ((e \bits32 i).[j]); case: ((f \bits32 i).[j]); case: ((g \bits32 i).[j]); rewrite hj.
qed.

(* Maj(a, b, c) by BSL with b XOR c as the selector: BSL(b ^ c, a, b). *)
lemma vbsl_maj (a b c : W128.t) (i : int) : 0 <= i < 4 =>
  VBSL (b +^ c) a b \bits32 i = maj (a \bits32 i) (b \bits32 i) (c \bits32 i).
proof.
move=> hi; rewrite /VBSL !W4u32.xorb32E W4u32.andb32E !W4u32.xorb32E /maj.
apply W32.wordP => j hj /=.
by case: ((a \bits32 i).[j]); case: ((b \bits32 i).[j]); case: ((c \bits32 i).[j]).
qed.

(* Ch of the last round, which has no BIT: (e AND f) XOR (g AND NOT e). *)
lemma vandn_ch (e f g : W128.t) (i : int) : 0 <= i < 4 =>
  ((e `&` f) +^ (g `&` invw e)) \bits32 i = ch (e \bits32 i) (f \bits32 i) (g \bits32 i).
proof.
move=> hi; rewrite W4u32.xorb32E !W4u32.andb32E W4u32.invw32E // /ch.
apply W32.wordP => j hj /=.
by case: ((e \bits32 i).[j]); case: ((f \bits32 i).[j]); case: ((g \bits32 i).[j]); rewrite hj.
qed.

end N256.
