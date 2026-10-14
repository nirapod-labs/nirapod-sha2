(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Lanes32.ec (x86_64)
 * ===================
 *
 * The AVX2 instructions of the SHA-256 message schedule, read one 32-bit
 * lane at a time (lane k of a 256-bit word is w \bits32 k, lane 0
 * lowest; lanes 0 to 3 form the low 128-bit half):
 *
 *   vpadd32, vpsrl32, vpsll32   VPADDD, VPSRLD, VPSLLD
 *   vpbroadcast32               VBROADCASTI128
 *   vpalignr4_32                VPALIGNR by 4 bytes: in each half, lanes
 *                               1 to 3 of the second source, then lane 0
 *                               of the first
 *   vpshufd_fa, vpshufd_50      VPSHUFD 0xfa and 0x50: each of two lanes
 *                               copied into both halves of a 64-bit lane
 *   ssig0_w                     the shift and XOR sequence of the kernel
 *                               against sigma0 of FIPS 180-4 section 4.1.2
 *   ssig1_w                     the 64-bit shift sequence against sigma1,
 *                               valid in the even lanes when each 64-bit
 *                               lane holds one word twice
 *   vpshufb_lo, vpshufb_hi      VPSHUFB with the kernel's masks that gather
 *                               the even lanes of each half into lanes 0, 1
 *                               (lo) or 2, 3 (hi) and clear the others
 *   vpshufb_bswap32w            VPSHUFB with the byte-reversal mask of each
 *                               32-bit lane
 *   vinserti128_32              VINSERTI128 into the upper half
 *
 * No model of the library is needed; this file is checked once.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import Bytes FIPS180_SHA2 Bmi WordSpec Vec Lanes64.

lemma b32 (w : W256.t) k : 0 <= k < 8 => w \bits32 k = w \bits128 (k %/ 4) \bits32 (k %% 4).
proof. by move=> hk; rewrite W256_bits128_bits32 1:/#; congr; smt(). qed.

lemma vpadd32 (w1 w2 : W256.t) k : 0 <= k < 8 =>
  VPADD_8u32 w1 w2 \bits32 k = (w1 \bits32 k) + (w2 \bits32 k).
proof. by move=> hk; rewrite /VPADD_8u32 W8u32.map2bE. qed.

lemma vpsrl32 (w : W256.t) n k : 0 <= n < 32 => 0 <= k < 8 =>
  VPSRL_8u32 w (W128.of_int n) \bits32 k = (w \bits32 k) `>>>` n.
proof.
move=> hn hk; rewrite /VPSRL_8u32 W8u32.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

lemma vpsll32 (w : W256.t) n k : 0 <= n < 32 => 0 <= k < 8 =>
  VPSLL_8u32 w (W128.of_int n) \bits32 k = (w \bits32 k) `<<<` n.
proof.
move=> hn hk; rewrite /VPSLL_8u32 W8u32.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

lemma vpxor32 (w1 w2 : W256.t) k : 0 <= k < 8 =>
  (w1 +^ w2) \bits32 k = (w1 \bits32 k) +^ (w2 \bits32 k).
proof. by move=> _; rewrite W8u32.xorb32E. qed.

lemma vpbroadcast32 (w : W128.t) k : 0 <= k < 8 =>
  VPBROADCAST_2u128 w \bits32 k = w \bits32 (k %% 4).
proof.
move=> hk; rewrite (b32 _ k hk) /VPBROADCAST_2u128 W2u128.pack2bE 1:/# /=.
have [->|->] : k %/ 4 = 0 \/ k %/ 4 = 1 by smt().
+ by rewrite -iotaredE /= ?W2u128.Pack.get_of_list.
by rewrite -iotaredE /= ?W2u128.Pack.get_of_list.
qed.

lemma vpalignr4_32 (x y : W256.t) k : 0 <= k < 8 =>
  VPALIGNR_256 x y (W8.of_int 4) \bits32 k
  = if k %% 4 < 3 then y \bits32 (k + 1) else x \bits32 (k - 3).
proof.
move=> hk; rewrite (b32 _ k hk) /VPALIGNR_256 W2u128.map2bE 1:/# /= vpalignr4.
have hd := divz_eq k 4.
have [h|[h|[h|h]]] : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
+ by rewrite h /=; congr; smt().
+ by rewrite h /=; congr; smt().
+ by rewrite h /=; congr; smt().
by rewrite h /=; congr; smt().
qed.

lemma vpshufd_fa (w : W256.t) k : 0 <= k < 8 =>
  VPSHUFD_256 w (W8.of_int 250) \bits32 k = w \bits32 (4 * (k %/ 4) + 2 + (k %% 4) %/ 2).
proof.
move=> hk; have hd := divz_eq k 4; rewrite (b32 _ k hk) /VPSHUFD_256 W2u128.mapbE 1:/# /=.
have [h|[h|[h|h]]] : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
qed.

lemma vpshufd_50 (w : W256.t) k : 0 <= k < 8 =>
  VPSHUFD_256 w (W8.of_int 80) \bits32 k = w \bits32 (4 * (k %/ 4) + (k %% 4) %/ 2).
proof.
move=> hk; have hd := divz_eq k 4; rewrite (b32 _ k hk) /VPSHUFD_256 W2u128.mapbE 1:/# /=.
have [h|[h|[h|h]]] : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
+ by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
by rewrite h /VPSHUFD_128 /VPSHUFD_128_B /=.
qed.

(* sigma0 of each lane, as the kernel computes it (ROTR 7 and ROTR 18 as
   two shifts each, the shift by 7 shared with the one by 18). *)
op vsig0w (vs : W256.t) : W256.t =
  let vt = VPSRL_8u32 vs (W128.of_int 7) in
  let vu = VPSRL_8u32 vs (W128.of_int 3) in
  let vw = VPSLL_8u32 vs (W128.of_int 14) in
  let vu = vu +^ vt in
  let vt = VPSRL_8u32 vt (W128.of_int 11) in
  let vu = vu +^ vw in
  let vw = VPSLL_8u32 vw (W128.of_int 11) in
  let vu = vu +^ vt in
  vu +^ vw.

lemma ssig0_w (vs : W256.t) k : 0 <= k < 8 =>
  vsig0w vs \bits32 k = SHA256.ssig0 (vs \bits32 k).
proof.
move=> hk; rewrite /vsig0w /= ?vpxor32 // ?vpsrl32 // ?vpsll32 //.
rewrite W32.shrw_add // W32.shlw_add // /SHA256.ssig0 !ror_xor32 //=.
by apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

(* A 64-bit word holding a twice, shifted right by n < 32: its low half
   is a rotated right by n. *)
lemma dup_ror (y : W64.t) (a : W32.t) n : 0 < n < 32 =>
  y \bits32 0 = a => y \bits32 1 = a => (y `>>>` n) \bits32 0 = a `|>>>|` n.
proof.
move=> hn h0 h1; apply W32.wordP => i hi.
rewrite W2u32.bits32iE // W64.shrwE W32.rorwE hi /=.
rewrite (_: 0 <= i < 64) 1:/# /=.
case: (i + n < 32) => hin.
+ by rewrite -h0 W2u32.bits32iE 1:/# /= pmod_small 1:/#.
rewrite -h1 W2u32.bits32iE 1:/#; congr; smt().
qed.

(* sigma1 of each even lane, as the kernel computes it on 64-bit lanes
   that hold one word twice (ROTR 17 and ROTR 19 as one 64-bit shift each,
   the shift by 17 shared). The odd lanes are not used. *)
op vsig1w (vs : W256.t) : W256.t =
  let vu = VPSRL_8u32 vs (W128.of_int 10) in
  let vs = VPSRL_4u64 vs (W128.of_int 17) in
  let vu = vu +^ vs in
  let vs = VPSRL_4u64 vs (W128.of_int 2) in
  vu +^ vs.

lemma ssig1_w (vs : W256.t) q : 0 <= q < 4 => vs \bits32 (2 * q) = vs \bits32 (2 * q + 1) =>
  vsig1w vs \bits32 (2 * q) = SHA256.ssig1 (vs \bits32 (2 * q)).
proof.
move=> hq he; have hk : 0 <= 2 * q < 8 by smt().
rewrite /vsig1w /=.
rewrite (vpsrl32 _ 10 _ _ hk) //.
have e : forall (w : W256.t), w \bits32 (2 * q) = w \bits64 q \bits32 0.
+ by move=> w; rewrite W256_bits64_bits32.
rewrite !(e (VPSRL_4u64 _ _)) !vpsrl64 // W64.shrw_add //=.
have h0 : vs \bits64 q \bits32 0 = vs \bits32 (2 * q) by rewrite W256_bits64_bits32.
have h1 : vs \bits64 q \bits32 1 = vs \bits32 (2 * q) by rewrite W256_bits64_bits32; smt().
rewrite (dup_ror _ _ 17 _ h0 h1) // (dup_ror _ _ 19 _ h0 h1) //.
rewrite /SHA256.ssig1; apply W32.wordP => i hi; rewrite !W32.xorwE; smt().
qed.

(* ------------------------------------------------------------------ *)
(* VPSHUFB with the kernel's masks                                     *)

(* As little-endian 32-bit lanes of each half: lo gathers source lanes 0
   and 2 into lanes 0 and 1 and clears lanes 2 and 3 (a mask byte with its
   top bit set gives zero); hi does the same into lanes 2 and 3. *)
op lo_mask128 : W128.t = p4 (W32.of_int 50462976) (W32.of_int 185207048) (W32.of_int (-1)) (W32.of_int (-1)).
op hi_mask128 : W128.t = p4 (W32.of_int (-1)) (W32.of_int (-1)) (W32.of_int 50462976) (W32.of_int 185207048).

lemma vpshufb128_lo (x : W128.t) :
  VPSHUFB_128 x lo_mask128 = p4 (x \bits32 0) (x \bits32 2) W32.zero W32.zero.
proof.
apply W16u8.allP; rewrite /VPSHUFB_128 /lo_mask128 /p4 /=.
by rewrite /VPSHUFB_128_B !W4u8.of_int_bits8_div // /= !W8.of_uintK /=.
qed.

lemma vpshufb128_hi (x : W128.t) :
  VPSHUFB_128 x hi_mask128 = p4 W32.zero W32.zero (x \bits32 0) (x \bits32 2).
proof.
apply W16u8.allP; rewrite /VPSHUFB_128 /hi_mask128 /p4 /=.
by rewrite /VPSHUFB_128_B !W4u8.of_int_bits8_div // /= !W8.of_uintK /=.
qed.

(* A 256-bit mask with the 128-bit mask m in both halves. *)
op twice (w : W256.t) (m : W128.t) = forall i, 0 <= i < 8 => w \bits32 i = m \bits32 (i %% 4).

lemma twiceE (w : W256.t) m i : twice w m => 0 <= i < 2 => w \bits128 i = m.
proof.
move=> hw hi; apply W4u32.wordP => j hj; rewrite W256_bits128_bits32 // hw 1:/#.
by congr; smt().
qed.

lemma vpshufb_lo (w m : W256.t) k : 0 <= k < 8 => twice m lo_mask128 =>
  VPSHUFB_256 w m \bits32 k
  = if k %% 4 < 2 then w \bits32 (4 * (k %/ 4) + 2 * (k %% 4)) else W32.zero.
proof.
move=> hk hm; rewrite (b32 _ k hk) /VPSHUFB_256 W2u128.map2bE 1:/# (twiceE _ _ _ hm) 1:/# vpshufb128_lo.
have [h|[h|[h|h]]] : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
+ by rewrite h /=.
+ by rewrite h /=.
+ by rewrite h /=.
by rewrite h /=.
qed.

lemma vpshufb_hi (w m : W256.t) k : 0 <= k < 8 => twice m hi_mask128 =>
  VPSHUFB_256 w m \bits32 k
  = if 2 <= k %% 4 then w \bits32 (4 * (k %/ 4) + 2 * (k %% 4 - 2)) else W32.zero.
proof.
move=> hk hm; rewrite (b32 _ k hk) /VPSHUFB_256 W2u128.map2bE 1:/# (twiceE _ _ _ hm) 1:/# vpshufb128_hi.
have hc : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
by case: hc => [h|[h|[h|h]]]; rewrite h /=.
qed.

lemma vpshufb_bswap32w (w m : W256.t) k : 0 <= k < 8 => twice m bswap_mask32 =>
  VPSHUFB_256 w m \bits32 k = WordSpec.bswap32 (w \bits32 k).
proof.
move=> hk hm; rewrite (b32 _ k hk) (b32 w k hk) /VPSHUFB_256 W2u128.map2bE 1:/#.
rewrite (twiceE _ _ _ hm) 1:/# vpshufb_bswap32.
have hc : k %% 4 = 0 \/ k %% 4 = 1 \/ k %% 4 = 2 \/ k %% 4 = 3 by smt().
by case: hc => [h|[h|[h|h]]]; rewrite h /=.
qed.

lemma vinserti128_32 (w : W256.t) (x : W128.t) k : 0 <= k < 8 =>
  VINSERTI128 w x (W8.of_int 1) \bits32 k = if k < 4 then w \bits32 k else x \bits32 (k - 4).
proof.
move=> hk; rewrite (b32 _ k hk) /VINSERTI128 W8.of_uintK /=.
case: (k < 4) => h.
+ by rewrite (_: k %/ 4 = 0) 1:/# /= (b32 w k hk) (_: k %/ 4 = 0) 1:/#.
by rewrite (_: k %/ 4 = 1) 1:/# /=; congr; smt().
qed.
