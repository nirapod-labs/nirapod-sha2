(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Lanes64.ec (x86_64)
 * ===================
 *
 * The AVX2 instructions of the SHA-512 message schedule, read one 64-bit
 * lane at a time (lane k of a 256-bit word is w \bits64 k, lane 0 lowest):
 *
 *   vpsrl64, vpsll64   VPSRLQ, VPSLLQ by an immediate below 64
 *   vpadd64            VPADDQ
 *   vpalignr8_64       VPALIGNR by 8 bytes: in each 128-bit half, the
 *                      upper lane of the second source, then the lower
 *                      lane of the first
 *   ssig0_v, ssig1_v   the shift and XOR sequences of the kernel against
 *                      sigma0 and sigma1 of FIPS 180-4 section 4.1.3
 *
 * No model of the library is needed; this file is checked once.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import Bytes FIPS180_SHA2 Bmi.

lemma bits128_bits64 (w : W256.t) i j : 0 <= j < 2 =>
  w \bits128 i \bits64 j = w \bits64 (2 * i + j).
proof.
move=> hj; apply W8u8.wordP => k hk.
rewrite W128_bits64_bits8 // W256_bits128_bits8 1:/# W256_bits64_bits8 //.
by congr; ring.
qed.

lemma vpsrl64 (w : W256.t) n k : 0 <= n < 64 => 0 <= k < 4 =>
  VPSRL_4u64 w (W128.of_int n) \bits64 k = (w \bits64 k) `>>>` n.
proof.
move=> hn hk; rewrite /VPSRL_4u64 W4u64.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

lemma vpsll64 (w : W256.t) n k : 0 <= n < 64 => 0 <= k < 4 =>
  VPSLL_4u64 w (W128.of_int n) \bits64 k = (w \bits64 k) `<<<` n.
proof.
move=> hn hk; rewrite /VPSLL_4u64 W4u64.mapbE //=.
by rewrite W128.of_uintK (pmod_small n) 1:/# W64.of_uintK pmod_small 1:/#.
qed.

lemma vpadd64 (w1 w2 : W256.t) k : 0 <= k < 4 =>
  VPADD_4u64 w1 w2 \bits64 k = (w1 \bits64 k) + (w2 \bits64 k).
proof. by move=> hk; rewrite /VPADD_4u64 W4u64.map2bE. qed.

lemma vpbroadcast64 (w : W128.t) k : 0 <= k < 4 =>
  VPBROADCAST_2u128 w \bits64 k = w \bits64 (k %% 2).
proof.
move=> hk; have := bits128_bits64 (VPBROADCAST_2u128 w) (k %/ 2) (k %% 2) _; 1: smt().
rewrite (_: 2 * (k %/ 2) + k %% 2 = k) 1:/# => <-.
rewrite /VPBROADCAST_2u128 W2u128.pack2bE 1:/# /=.
have [->|->] : k %/ 2 = 0 \/ k %/ 2 = 1 by smt().
+ by rewrite -iotaredE /= ?W2u128.Pack.get_of_list.
by rewrite -iotaredE /= ?W2u128.Pack.get_of_list.
qed.

lemma vpxor64 (w1 w2 : W256.t) k : 0 <= k < 4 =>
  (w1 +^ w2) \bits64 k = (w1 \bits64 k) +^ (w2 \bits64 k).
proof. by move=> _; rewrite W4u64.xorb64E. qed.

lemma valignr8_lo (x y : W128.t) : VPALIGNR_128 x y (W8.of_int 8) \bits64 0 = y \bits64 1.
proof.
apply W64.wordP => j hj.
rewrite /VPALIGNR_128 /= W2u64.bits64iE // W4u64.bits64iE // W256.shrwE /=.
rewrite (_: 0 <= j < 256) 1:/# /= W2u128.pack2wE 1:/#.
by rewrite (_: (j + 64) %/ 128 = 0) 1:/# (_: (j + 64) %% 128 = 64 + j) 1:/#.
qed.

lemma valignr8_hi (x y : W128.t) : VPALIGNR_128 x y (W8.of_int 8) \bits64 1 = x \bits64 0.
proof.
apply W64.wordP => j hj.
rewrite /VPALIGNR_128 /= W2u64.bits64iE // W4u64.bits64iE // W256.shrwE /=.
rewrite (_: 0 <= 64 + j < 256) 1:/# /= W2u128.pack2wE 1:/#.
by rewrite (_: (64 + j + 64) %/ 128 = 1) 1:/# (_: (64 + j + 64) %% 128 = j) 1:/#.
qed.

lemma vpalignr8_64 (x y : W256.t) k : 0 <= k < 4 =>
  VPALIGNR_256 x y (W8.of_int 8) \bits64 k
  = if k %% 2 = 0 then y \bits64 (k + 1) else x \bits64 (k - 1).
proof.
move=> hk; have := bits128_bits64 (VPALIGNR_256 x y (W8.of_int 8)) (k %/ 2) (k %% 2) _; 1: smt().
rewrite (_: 2 * (k %/ 2) + k %% 2 = k) 1:/# => <-.
rewrite /VPALIGNR_256 W2u128.map2bE 1:/# /=.
case: (k %% 2 = 0) => h.
+ rewrite h valignr8_lo bits128_bits64 //; congr; smt().
rewrite (_: k %% 2 = 1) 1:/# valignr8_hi bits128_bits64 //; congr; smt().
qed.

(* sigma0 of each lane, as the kernel computes it (ROTR 1 and ROTR 8 as
   two shifts each, the shift by 7 shared). *)
op vsig0 (vs : W256.t) : W256.t =
  let vt = VPSRL_4u64 vs (W128.of_int 1) in
  let vu = VPSRL_4u64 vs (W128.of_int 7) in
  let vw = VPSLL_4u64 vs (W128.of_int 56) in
  let vu = vu +^ vt in
  let vt = VPSRL_4u64 vt (W128.of_int 7) in
  let vu = vu +^ vw in
  let vw = VPSLL_4u64 vw (W128.of_int 7) in
  let vu = vu +^ vt in
  vu +^ vw.

(* sigma1 of each lane (ROTR 19 and ROTR 61, then SHR 6). *)
op vsig1 (x : W256.t) : W256.t =
  let vu = VPSRL_4u64 x (W128.of_int 6) in
  let vw = VPSLL_4u64 x (W128.of_int 3) in
  let vt = VPSRL_4u64 x (W128.of_int 19) in
  let vu = vu +^ vw in
  let vw = VPSLL_4u64 vw (W128.of_int 42) in
  let vu = vu +^ vt in
  let vt = VPSRL_4u64 vt (W128.of_int 42) in
  let vu = vu +^ vw in
  vu +^ vt.

lemma ssig0_v (vs : W256.t) k : 0 <= k < 4 =>
  vsig0 vs \bits64 k = SHA512.ssig0 (vs \bits64 k).
proof.
move=> hk; rewrite /vsig0 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 //.
rewrite W64.shrw_add // W64.shlw_add // /SHA512.ssig0 !ror_xor64 //=.
by apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.

lemma ssig1_v (x : W256.t) k : 0 <= k < 4 =>
  vsig1 x \bits64 k = SHA512.ssig1 (x \bits64 k).
proof.
move=> hk; rewrite /vsig1 /= ?vpxor64 // ?vpsrl64 // ?vpsll64 //.
rewrite W64.shrw_add // W64.shlw_add // /SHA512.ssig1 !ror_xor64 //=.
by apply W64.wordP => i hi; rewrite !W64.xorwE; smt().
qed.
