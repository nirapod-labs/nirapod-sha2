(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2X8Vec.ec (x86_64, avx2)
 * ==================================
 *
 * The AVX2 instructions of the 8-way SHA-256 kernel
 * (src/x86_64/avx2/sha256_x8_compress.jinc), read one 32-bit lane at a
 * time. Lane L of a 256-bit word is w \bits32 L, lane 0 lowest; in the
 * kernel, lane L of every state and schedule register belongs to
 * instance L.
 *
 *   vpadd32, vpxor32, vpand32   VPADDD, VPXOR, VPAND
 *   vpsrl32, vpsll32            VPSRLD, VPSLLD by an immediate below 32
 *   vS0, vS1, vs0, vs1          the shift and XOR sequences of the
 *                               kernel's Sigma0, Sigma1, sigma0, sigma1,
 *                               against FIPS 180-4 section 4.1.2
 *   unpckl32E .. perm31E        VPUNPCK{L,H}DQ, VPUNPCK{L,H}QDQ and
 *                               VPERM2I128 (0x20, 0x31) as their eight
 *                               result lanes, for the transpose
 *   vpshufb_bswap8              VPSHUFB with the mask that reverses the
 *                               bytes of each 32-bit lane
 *   X8Lanes.get256_bits32       the lanes of a 256-bit read of an array
 *   loadW256_bits32             and of a 256-bit load from memory
 *
 * No model of the library is needed.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JByte_array JMemory JModel_x86.
require import FIPS180_SHA2 WordSpec Vec Bmi.
import SHA256.

(* The 32-bit lanes of a 256-bit read of a byte array; a proof about a
   model clones this with `theory A <- BArray<n>`. *)
abstract theory X8Lanes.
  clone import ByteArray as A.

  lemma get256_bits32 (t : A.t) i j : 0 <= j < 8 =>
    A.get256 t i \bits32 j = A.get32 t (8 * i + j).
  proof.
  move=> hj; apply W4u8.wordP => k hk.
  rewrite W256_bits32_bits8 // A.get256d_byte 1:/# A.get32d_byte //.
  by congr; ring.
  qed.
end X8Lanes.

(* The 32-bit lanes of a 256-bit load from memory. *)
lemma loadW256_bits32 mem p i : 0 <= i < 8 =>
  loadW256 mem p \bits32 i = loadW32 mem (p + 4 * i).
proof.
move=> hi; apply W4u8.wordP => k hk.
rewrite W256_bits32_bits8 // loadW32_bits8 // /loadW256 pack32bE 1:/# initiE 1:/# /= /loadW8.
by congr; ring.
qed.

(* Eight 32-bit lanes, lane 0 first. *)
op pk8 (a0 a1 a2 a3 a4 a5 a6 a7 : W32.t) : W256.t =
  W8u32.pack8 [a0; a1; a2; a3; a4; a5; a6; a7].

lemma pk8_lane a0 a1 a2 a3 a4 a5 a6 a7 i : 0 <= i < 8 =>
  pk8 a0 a1 a2 a3 a4 a5 a6 a7 \bits32 i = nth W32.zero [a0; a1; a2; a3; a4; a5; a6; a7] i.
proof. by move=> hi; rewrite /pk8 W8u32.get_pack8 1:/#. qed.

(* ------------------------------------------------------------------ *)
(* Lane-wise arithmetic                                               *)

lemma vpadd32 (x y : W256.t) L : 0 <= L < 8 =>
  VPADD_8u32 x y \bits32 L = (x \bits32 L) + (y \bits32 L).
proof. by move=> hL; rewrite /VPADD_8u32 W8u32.map2bE. qed.

lemma vpxor32 (x y : W256.t) L : 0 <= L < 8 =>
  (x +^ y) \bits32 L = (x \bits32 L) +^ (y \bits32 L).
proof. by move=> _; rewrite W8u32.xorb32E. qed.

lemma vpand32 (x y : W256.t) L : 0 <= L < 8 =>
  (x `&` y) \bits32 L = (x \bits32 L) `&` (y \bits32 L).
proof. by move=> _; rewrite W8u32.andb32E. qed.

lemma vpsrl32 (w : W256.t) n L : 0 <= n < 32 => 0 <= L < 8 =>
  VPSRL_8u32 w (W128.of_int n) \bits32 L = (w \bits32 L) `>>>` n.
proof.
move=> hn hL; rewrite /VPSRL_8u32 W8u32.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

lemma vpsll32 (w : W256.t) n L : 0 <= n < 32 => 0 <= L < 8 =>
  VPSLL_8u32 w (W128.of_int n) \bits32 L = (w \bits32 L) `<<<` n.
proof.
move=> hn hL; rewrite /VPSLL_8u32 W8u32.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The four functions of section 4.1.2, as the kernel computes them:  *)
(* ROTR^r as a right shift by r XOR a left shift by 32 - r.           *)

op vS0 (x : W256.t) : W256.t =
  let r = VPSRL_8u32 x (W128.of_int 2) in
  let s = VPSLL_8u32 x (W128.of_int 30) in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 13) in
  let t = VPSLL_8u32 x (W128.of_int 19) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 22) in
  let t = VPSLL_8u32 x (W128.of_int 10) in
  let s = s +^ t in
  r +^ s.

op vS1 (x : W256.t) : W256.t =
  let r = VPSRL_8u32 x (W128.of_int 6) in
  let s = VPSLL_8u32 x (W128.of_int 26) in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 11) in
  let t = VPSLL_8u32 x (W128.of_int 21) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 25) in
  let t = VPSLL_8u32 x (W128.of_int 7) in
  let s = s +^ t in
  r +^ s.

op vs0 (x : W256.t) : W256.t =
  let r = VPSRL_8u32 x (W128.of_int 7) in
  let s = VPSLL_8u32 x (W128.of_int 25) in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 18) in
  let t = VPSLL_8u32 x (W128.of_int 14) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 3) in
  r +^ s.

op vs1 (x : W256.t) : W256.t =
  let r = VPSRL_8u32 x (W128.of_int 17) in
  let s = VPSLL_8u32 x (W128.of_int 15) in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 19) in
  let t = VPSLL_8u32 x (W128.of_int 13) in
  let s = s +^ t in
  let r = r +^ s in
  let s = VPSRL_8u32 x (W128.of_int 10) in
  r +^ s.

lemma vS0_lane (x : W256.t) L : 0 <= L < 8 => vS0 x \bits32 L = bsig0 (x \bits32 L).
proof.
move=> hL; rewrite /vS0 /= ?vpxor32 // ?vpsrl32 // ?vpsll32 //.
by rewrite /bsig0 !ror_xor32 //=; apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

lemma vS1_lane (x : W256.t) L : 0 <= L < 8 => vS1 x \bits32 L = bsig1 (x \bits32 L).
proof.
move=> hL; rewrite /vS1 /= ?vpxor32 // ?vpsrl32 // ?vpsll32 //.
by rewrite /bsig1 !ror_xor32 //=; apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

lemma vs0_lane (x : W256.t) L : 0 <= L < 8 => vs0 x \bits32 L = ssig0 (x \bits32 L).
proof.
move=> hL; rewrite /vs0 /= ?vpxor32 // ?vpsrl32 // ?vpsll32 //.
by rewrite /ssig0 !ror_xor32 //=; apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

lemma vs1_lane (x : W256.t) L : 0 <= L < 8 => vs1 x \bits32 L = ssig1 (x \bits32 L).
proof.
move=> hL; rewrite /vs1 /= ?vpxor32 // ?vpsrl32 // ?vpsll32 //.
by rewrite /ssig1 !ror_xor32 //=; apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The transpose instructions, lane by lane                           *)

(* VPUNPCKLDQ: in each 128-bit half, dwords 0 and 1 of both sources,
   interleaved. *)
lemma unpckl32E (a b : W256.t) : VPUNPCKL_8u32 a b =
  pk8 (a \bits32 0) (b \bits32 0) (a \bits32 1) (b \bits32 1)
      (a \bits32 4) (b \bits32 4) (a \bits32 5) (b \bits32 5).
proof. by apply W32u8.allP; rewrite /VPUNPCKL_8u32 /VPUNPCKL_4u32 /interleave_gen /get_lo_2u64 /pk8 /=. qed.

(* VPUNPCKHDQ: the same with dwords 2 and 3. *)
lemma unpckh32E (a b : W256.t) : VPUNPCKH_8u32 a b =
  pk8 (a \bits32 2) (b \bits32 2) (a \bits32 3) (b \bits32 3)
      (a \bits32 6) (b \bits32 6) (a \bits32 7) (b \bits32 7).
proof. by apply W32u8.allP; rewrite /VPUNPCKH_8u32 /VPUNPCKH_4u32 /interleave_gen /get_hi_2u64 /pk8 /=. qed.

(* VPUNPCKLQDQ: in each half, qword 0 of both sources. *)
lemma unpckl64E (a b : W256.t) : VPUNPCKL_4u64 a b =
  pk8 (a \bits32 0) (a \bits32 1) (b \bits32 0) (b \bits32 1)
      (a \bits32 4) (a \bits32 5) (b \bits32 4) (b \bits32 5).
proof. by apply W32u8.allP; rewrite /VPUNPCKL_4u64 /VPUNPCKL_2u64 /interleave_gen /get_lo_2u64 /pk8 /=. qed.

(* VPUNPCKHQDQ: in each half, qword 1 of both sources. *)
lemma unpckh64E (a b : W256.t) : VPUNPCKH_4u64 a b =
  pk8 (a \bits32 2) (a \bits32 3) (b \bits32 2) (b \bits32 3)
      (a \bits32 6) (a \bits32 7) (b \bits32 6) (b \bits32 7).
proof. by apply W32u8.allP; rewrite /VPUNPCKH_4u64 /VPUNPCKH_2u64 /interleave_gen /get_hi_2u64 /pk8 /=. qed.

(* VPERM2I128 with 0x20: the low halves of both sources. *)
lemma perm20E (a b : W256.t) : VPERM2I128 a b (W8.of_int 32) =
  pk8 (a \bits32 0) (a \bits32 1) (a \bits32 2) (a \bits32 3)
      (b \bits32 0) (b \bits32 1) (b \bits32 2) (b \bits32 3).
proof. by apply W32u8.allP; rewrite /VPERM2I128 /= !W8.of_intwE /int_bit /pk8 /=. qed.

(* VPERM2I128 with 0x31: the high halves of both sources. *)
lemma perm31E (a b : W256.t) : VPERM2I128 a b (W8.of_int 49) =
  pk8 (a \bits32 4) (a \bits32 5) (a \bits32 6) (a \bits32 7)
      (b \bits32 4) (b \bits32 5) (b \bits32 6) (b \bits32 7).
proof. by apply W32u8.allP; rewrite /VPERM2I128 /= !W8.of_intwE /int_bit /pk8 /=. qed.

(* ------------------------------------------------------------------ *)
(* VPSHUFB with the byte-reversal mask of each 32-bit lane            *)

op bswap_mask8 : W256.t = W2u128.pack2 [bswap_mask32; bswap_mask32].

lemma vpshufb_bswap8 (w : W256.t) :
  VPSHUFB_256 w bswap_mask8
  = pk8 (bswap32 (w \bits32 0)) (bswap32 (w \bits32 1)) (bswap32 (w \bits32 2)) (bswap32 (w \bits32 3))
        (bswap32 (w \bits32 4)) (bswap32 (w \bits32 5)) (bswap32 (w \bits32 6)) (bswap32 (w \bits32 7)).
proof.
apply W32u8.allP; rewrite /VPSHUFB_256 /bswap_mask8 /bswap_mask32 /p4 /pk8 /=.
by rewrite /VPSHUFB_128 /VPSHUFB_128_B /= !W4u8.of_int_bits8_div // /= !W8.of_uintK /= /bswap32.
qed.
