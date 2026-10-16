(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2X4Vec.ec (x86_64, avx2)
 * ==================================
 *
 * The AVX2 instructions of the 4-way SHA-512 kernel
 * (src/x86_64/avx2/sha512_x4_compress.jinc), read one 64-bit lane at a
 * time (lane L of a 256-bit word is w \bits64 L, lane 0 lowest; lane L of
 * every state and schedule register belongs to instance L). The
 * additions, XORs and shifts are those of Lanes64.ec; this file adds:
 *
 *   vpand64                     VPAND
 *   vpshufb_ror8                VPSHUFB with SHA512_X4_ROR8: ROTR^8 of
 *                               each lane, a byte rotation
 *   vS0x4 .. vs1x4              the kernel's Sigma0, Sigma1, sigma0,
 *                               sigma1 against FIPS 180-4 section 4.1.3
 *   q4_unpcklE .. q4_perm31E    VPUNPCK{L,H}QDQ and VPERM2I128 (0x20,
 *                               0x31) as their four result lanes
 *   vpshufb_bswap4              VPSHUFB with SHA512_X4_BSWAP: the bytes
 *                               of each lane reversed
 *   X4Lanes.get256_bits64       the lanes of a 256-bit read of an array
 *   loadW256_bits64             and of a 256-bit load from memory
 *
 * No model of the library is needed.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JByte_array JMemory JModel_x86.
require import FIPS180_SHA2 WordSpec Bmi Lanes64.
import SHA512.

(* Four 64-bit lanes, lane 0 first. *)
op pk4 (a0 a1 a2 a3 : W64.t) : W256.t = W4u64.pack4 [a0; a1; a2; a3].

lemma pk4_lane a0 a1 a2 a3 i : 0 <= i < 4 =>
  pk4 a0 a1 a2 a3 \bits64 i = nth W64.zero [a0; a1; a2; a3] i.
proof. by move=> hi; rewrite /pk4 W4u64.get_pack4 1:/#. qed.

lemma cases4 k : 0 <= k < 4 => k = 0 \/ k = 1 \/ k = 2 \/ k = 3.
proof. smt(). qed.

(* The 64-bit lanes of a 256-bit read of a byte array. *)
abstract theory X4Lanes.
  clone import ByteArray as A.

  lemma get256_bits64 (t : A.t) i j : 0 <= j < 4 =>
    A.get256 t i \bits64 j = A.get64 t (4 * i + j).
  proof.
  move=> hj; apply W8u8.wordP => k hk.
  rewrite W256_bits64_bits8 // A.get256d_byte 1:/# A.get64d_byte //.
  by congr; ring.
  qed.
end X4Lanes.

lemma loadW256_bits64 mem p i : 0 <= i < 4 =>
  loadW256 mem p \bits64 i = loadW64 mem (p + 8 * i).
proof.
move=> hi; apply W8u8.wordP => k hk.
rewrite W256_bits64_bits8 // loadW64_bits8 // /loadW256 pack32bE 1:/# initiE 1:/# /= /loadW8.
by congr; ring.
qed.

lemma vpand64 (x y : W256.t) L : 0 <= L < 4 =>
  (x `&` y) \bits64 L = (x \bits64 L) `&` (y \bits64 L).
proof. by move=> _; rewrite W4u64.andb64E. qed.

(* ------------------------------------------------------------------ *)
(* ROTR^8 as a byte shuffle                                           *)

(* Byte i of the result is byte i + 1 (mod 8) of the source lane. *)
op ror8_mask4 : W256.t =
  pk4 (W64.of_int 1976943448883713) (W64.of_int 580698326153497097)
      (W64.of_int 1976943448883713) (W64.of_int 580698326153497097).

op rot8 (x : W64.t) : W64.t =
  W8u8.pack8 [x \bits8 1; x \bits8 2; x \bits8 3; x \bits8 4;
              x \bits8 5; x \bits8 6; x \bits8 7; x \bits8 0].

lemma rot8E (x : W64.t) : rot8 x = x `|>>>|` 8.
proof.
apply W8u8.wordP => j hj; rewrite /rot8 W8u8.get_pack8 1:/#.
apply W8.wordP => b hb; rewrite W8u8.bits8iE // rorwE /= (_: 0 <= j * 8 + b < 64) 1:/# /=.
have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 \/ j = 4 \/ j = 5 \/ j = 6 \/ j = 7
  by smt().
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
+ by rewrite /= W8u8.bits8iE // pmod_small /#.
by rewrite /= W8u8.bits8iE // (_: 64 + b = b + 1 * 64) 1:/# modzMDr pmod_small /#.
qed.

lemma vpshufb_ror8 (w : W256.t) :
  VPSHUFB_256 w ror8_mask4
  = pk4 (rot8 (w \bits64 0)) (rot8 (w \bits64 1)) (rot8 (w \bits64 2)) (rot8 (w \bits64 3)).
proof.
apply W32u8.allP; rewrite /VPSHUFB_256 /ror8_mask4 /pk4 /rot8 /=.
by rewrite /VPSHUFB_128 /VPSHUFB_128_B /= !W8u8.of_int_bits8_div // /= !W8.of_uintK.
qed.

(* ------------------------------------------------------------------ *)
(* The four functions of section 4.1.3, as the kernel computes them   *)

op vS0x4 (x : W256.t) : W256.t =
  let r = VPSRL_4u64 x (W128.of_int 28) in
  let s = VPSLL_4u64 x (W128.of_int 36) in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 34) in
  let t = VPSLL_4u64 x (W128.of_int 30) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 39) in
  let t = VPSLL_4u64 x (W128.of_int 25) in
  let s = s +^ t in
  r +^ s.

op vS1x4 (x : W256.t) : W256.t =
  let r = VPSRL_4u64 x (W128.of_int 14) in
  let s = VPSLL_4u64 x (W128.of_int 50) in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 18) in
  let t = VPSLL_4u64 x (W128.of_int 46) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 41) in
  let t = VPSLL_4u64 x (W128.of_int 23) in
  let s = s +^ t in
  r +^ s.

op vs0x4 (x m : W256.t) : W256.t =
  let r = VPSRL_4u64 x (W128.of_int 1) in
  let s = VPSLL_4u64 x (W128.of_int 63) in
  let r = r +^ s in
  let s = VPSHUFB_256 x m in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 7) in
  r +^ s.

op vs1x4 (x : W256.t) : W256.t =
  let r = VPSRL_4u64 x (W128.of_int 19) in
  let s = VPSLL_4u64 x (W128.of_int 45) in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 61) in
  let t = VPSLL_4u64 x (W128.of_int 3) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_4u64 x (W128.of_int 6) in
  r +^ s.

lemma vS0x4_lane (x : W256.t) L : 0 <= L < 4 => vS0x4 x \bits64 L = bsig0 (x \bits64 L).
proof.
move=> hL; rewrite /vS0x4 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 //.
by rewrite /bsig0 !ror_xor64 //=; apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.

lemma vS1x4_lane (x : W256.t) L : 0 <= L < 4 => vS1x4 x \bits64 L = bsig1 (x \bits64 L).
proof.
move=> hL; rewrite /vS1x4 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 //.
by rewrite /bsig1 !ror_xor64 //=; apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.

lemma vs0x4_lane (x : W256.t) L : 0 <= L < 4 => vs0x4 x ror8_mask4 \bits64 L = ssig0 (x \bits64 L).
proof.
move=> hL; rewrite /vs0x4 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 // vpshufb_ror8 pk4_lane //.
have -> : nth W64.zero [rot8 (x \bits64 0); rot8 (x \bits64 1); rot8 (x \bits64 2); rot8 (x \bits64 3)] L
          = rot8 (x \bits64 L) by have [->|[->|[->|->]]] := cases4 L hL.
by rewrite rot8E /ssig0 !ror_xor64 //=; apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.

lemma vs1x4_lane (x : W256.t) L : 0 <= L < 4 => vs1x4 x \bits64 L = ssig1 (x \bits64 L).
proof.
move=> hL; rewrite /vs1x4 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 //.
by rewrite /ssig1 !ror_xor64 //=; apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The transpose instructions, lane by lane                           *)

lemma q4_unpcklE (a b : W256.t) : VPUNPCKL_4u64 a b =
  pk4 (a \bits64 0) (b \bits64 0) (a \bits64 2) (b \bits64 2).
proof. by apply W32u8.allP; rewrite /VPUNPCKL_4u64 /VPUNPCKL_2u64 /interleave_gen /get_lo_2u64 /pk4 /=. qed.

lemma q4_unpckhE (a b : W256.t) : VPUNPCKH_4u64 a b =
  pk4 (a \bits64 1) (b \bits64 1) (a \bits64 3) (b \bits64 3).
proof. by apply W32u8.allP; rewrite /VPUNPCKH_4u64 /VPUNPCKH_2u64 /interleave_gen /get_hi_2u64 /pk4 /=. qed.

lemma q4_perm20E (a b : W256.t) : VPERM2I128 a b (W8.of_int 32) =
  pk4 (a \bits64 0) (a \bits64 1) (b \bits64 0) (b \bits64 1).
proof. by apply W32u8.allP; rewrite /VPERM2I128 /= !W8.of_intwE /int_bit /pk4 /=. qed.

lemma q4_perm31E (a b : W256.t) : VPERM2I128 a b (W8.of_int 49) =
  pk4 (a \bits64 2) (a \bits64 3) (b \bits64 2) (b \bits64 3).
proof. by apply W32u8.allP; rewrite /VPERM2I128 /= !W8.of_intwE /int_bit /pk4 /=. qed.

(* ------------------------------------------------------------------ *)
(* VPSHUFB with the byte-reversal mask of each 64-bit lane            *)

op bswap_mask4 : W256.t =
  pk4 (W64.of_int 283686952306183) (W64.of_int 579005069656919567)
      (W64.of_int 283686952306183) (W64.of_int 579005069656919567).

lemma vpshufb_bswap4 (w : W256.t) :
  VPSHUFB_256 w bswap_mask4
  = pk4 (bswap64 (w \bits64 0)) (bswap64 (w \bits64 1)) (bswap64 (w \bits64 2)) (bswap64 (w \bits64 3)).
proof.
apply W32u8.allP; rewrite /VPSHUFB_256 /bswap_mask4 /pk4 /=.
by rewrite /VPSHUFB_128 /VPSHUFB_128_B /= !W8u8.of_int_bits8_div // /= !W8.of_uintK /= /bswap64.
qed.
