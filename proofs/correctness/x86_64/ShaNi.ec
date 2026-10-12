(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * ShaNi.ec (x86_64)
 * =================
 *
 * The x86 SHA extensions as eclib/JModel_x86.ec models them (SHA256RNDS2,
 * SHA256MSG1, SHA256MSG2, defined through eclib/SHA.ec) against FIPS
 * 180-4 section 6.2.2 as spec/FIPS180_SHA2.ec writes it. Once these hold,
 * no kernel proof unfolds an instruction model again.
 *
 *   rnds2_state   SHA256RNDS2 is rounds t and t+1 on the ABEF/CDGH
 *                 packing, given W_t + K_t and W_t+1 + K_t+1 in lanes 0, 1
 *   shani_rounds4 the four-round group of the kernels (two SHA256RNDS2
 *                 around a VPSHUFD 0x0e) is rounds t .. t+3
 *   shani_sched4  SHA256MSG1, VPALIGNR 4, VPADD and SHA256MSG2 give
 *                 W_t .. W_t+3 of the schedule from the four groups before
 *
 * The models are trusted (they are validated against the instructions on
 * native hardware in tests/insn/).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import Bytes FIPS180_SHA2 Vec SpecRounds.
import SHA256 R256.

(* The functions of section 4.1.2 in SHA.ec are those of the spec. *)
lemma SHA_chE (x y z : W32.t) : SHA.ch x y z = ch x y z.
proof. by rewrite /SHA.ch /ch. qed.
lemma SHA_majE (x y z : W32.t) : SHA.maj x y z = maj x y z.
proof. by rewrite /SHA.maj /maj. qed.
lemma SHA_sum0E (x : W32.t) : SHA.sum0 x = bsig0 x.
proof. by rewrite /SHA.sum0 /bsig0. qed.
lemma SHA_sum1E (x : W32.t) : SHA.sum1 x = bsig1 x.
proof. by rewrite /SHA.sum1 /bsig1. qed.
lemma SHA_sigma0E (x : W32.t) : SHA.sigma0 x = ssig0 x.
proof. by rewrite /SHA.sigma0 /ssig0. qed.
lemma SHA_sigma1E (x : W32.t) : SHA.sigma1 x = ssig1 x.
proof. by rewrite /SHA.sigma1 /ssig1. qed.

lemma pack4_eq (a b c d a' b' c' d' : W32.t) :
  a = a' => b = b' => c = c' => d = d' =>
  W4u32.pack4 [a; b; c; d] = W4u32.pack4 [a'; b'; c'; d'].
proof. by move=> -> -> -> ->. qed.

(* ------------------------------------------------------------------ *)
(* SHA256RNDS2: two rounds of section 6.2.2 step 3                     *)

(* The state registers: abef holds F E B A and cdgh holds H G D C, lane 0
   first. *)
op abef (s : state) : W128.t = p4 s.`6 s.`5 s.`2 s.`1.
op cdgh (s : state) : W128.t = p4 s.`8 s.`7 s.`4 s.`3.

lemma rnds2_spec (w : W32.t list) (t : int) (a b c d e f g h : W32.t) (z : W128.t) :
  z \bits32 0 = nth W32.zero w t + nth W32.zero K256 t =>
  z \bits32 1 = nth W32.zero w (t + 1) + nth W32.zero K256 (t + 1) =>
  let s2 = round w (round w (a, b, c, d, e, f, g, h) t) (t + 1) in
  SHA256RNDS2 (p4 h g d c) (p4 f e b a) z = p4 s2.`6 s2.`5 s2.`2 s2.`1
  /\ p4 f e b a = p4 s2.`8 s2.`7 s2.`4 s2.`3.
proof.
move=> z0 z1 /=; split; last by rewrite /round.
rewrite /SHA256RNDS2 /rnds2 /round /= z0 z1.
pose k0 := nth W32.zero w t + nth W32.zero K256 t.
pose k1 := nth W32.zero w (t + 1) + nth W32.zero K256 (t + 1).
have he : SHA.ch e f g + SHA.sum1 e + k0 + h + d
          = d + (h + bsig1 e + ch e f g + nth W32.zero K256 t + nth W32.zero w t).
+ by rewrite SHA_chE SHA_sum1E /k0; ring.
have ha : SHA.ch e f g + SHA.sum1 e + k0 + h + SHA.maj a b c + SHA.sum0 a
          = h + bsig1 e + ch e f g + nth W32.zero K256 t + nth W32.zero w t + (bsig0 a + maj a b c).
+ by rewrite SHA_chE SHA_sum1E SHA_majE SHA_sum0E /k0; ring.
rewrite he ha !SHA_chE !SHA_majE !SHA_sum0E !SHA_sum1E /p4 /k1.
by apply pack4_eq; ring.
qed.

lemma rnds2_state (w : W32.t list) (t : int) (s : state) (z : W128.t) :
  z \bits32 0 = nth W32.zero w t + nth W32.zero K256 t =>
  z \bits32 1 = nth W32.zero w (t + 1) + nth W32.zero K256 (t + 1) =>
  SHA256RNDS2 (cdgh s) (abef s) z = abef (round w (round w s t) (t + 1))
  /\ abef s = cdgh (round w (round w s t) (t + 1)).
proof.
case: s => a b c d e f g h /= z0 z1.
by have /= := rnds2_spec w t a b c d e f g h z z0 z1.
qed.

(* ------------------------------------------------------------------ *)
(* SHA256MSG1 and SHA256MSG2, lane by lane                            *)

lemma msg1_spec (x y : W128.t) :
  SHA256MSG1 x y
  = p4 ((x \bits32 0) + ssig0 (x \bits32 1)) ((x \bits32 1) + ssig0 (x \bits32 2))
       ((x \bits32 2) + ssig0 (x \bits32 3)) ((x \bits32 3) + ssig0 (y \bits32 0)).
proof. by rewrite /SHA256MSG1 /msg1 /= /p4 !SHA_sigma0E. qed.

lemma msg2_spec (x y : W128.t) :
  SHA256MSG2 x y
  = let w16 = (x \bits32 0) + ssig1 (y \bits32 2) in
    let w17 = (x \bits32 1) + ssig1 (y \bits32 3) in
    p4 w16 w17 ((x \bits32 2) + ssig1 w16) ((x \bits32 3) + ssig1 w17).
proof. by rewrite /SHA256MSG2 /msg2 /= /p4 !SHA_sigma1E. qed.

(* ------------------------------------------------------------------ *)
(* The kernels' four-round group                                       *)

(* W_t + K_t .. W_t+3 + K_t+3, as the kernels form them with one
   VPADD_4u32 of four schedule words and four constants. *)
op wk4 (w : W32.t list) (t : int) : W128.t =
  VPADD_4u32
    (p4 (nth W32.zero w t) (nth W32.zero w (t + 1)) (nth W32.zero w (t + 2)) (nth W32.zero w (t + 3)))
    (p4 (nth W32.zero K256 t) (nth W32.zero K256 (t + 1))
        (nth W32.zero K256 (t + 2)) (nth W32.zero K256 (t + 3))).

(* Rounds t .. t+3 as the kernels issue them:
     wk   = VPADD_4u32(W, K)
     cdgh = SHA256RNDS2(cdgh, abef, wk)
     wk   = VPSHUFD_128(wk, 0x0e)
     abef = SHA256RNDS2(abef, cdgh, wk)
   The two registers end in their own roles, four rounds later. *)
lemma shani_rounds4 (w : W32.t list) (t : int) (s : state) :
  let s4 = foldl (round w) s (range t (t + 4)) in
  SHA256RNDS2 (abef s) (SHA256RNDS2 (cdgh s) (abef s) (wk4 w t))
    (VPSHUFD_128 (wk4 w t) (W8.of_int 14)) = abef s4
  /\ SHA256RNDS2 (cdgh s) (abef s) (wk4 w t) = cdgh s4.
proof.
rewrite /= range4.
have [h1 h2] := rnds2_state w t s (wk4 w t) _ _.
+ by rewrite /wk4 vpadd4_pack.
+ by rewrite /wk4 vpadd4_pack.
have [h3 h4] := rnds2_state w (t + 2) (round w (round w s t) (t + 1))
                  (VPSHUFD_128 (wk4 w t) (W8.of_int 14)) _ _.
+ by rewrite vpshufd_0e_0 /wk4 vpadd4_pack.
+ by rewrite vpshufd_0e_1 /wk4 vpadd4_pack (_: t + 2 + 1 = t + 3) 1:/#.
rewrite h1 h2 h3 (_: t + 2 + 1 = t + 3) 1:/# /=.
by rewrite h4 (_: t + 2 + 1 = t + 3) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The kernels' four-word schedule step                                *)

(* Schedule words W_k .. W_k+3 as one register. *)
op wv (m : W32.t list) (k : int) : W128.t =
  p4 (nth W32.zero (schedule m) k) (nth W32.zero (schedule m) (k + 1))
     (nth W32.zero (schedule m) (k + 2)) (nth W32.zero (schedule m) (k + 3)).

(* W_t .. W_t+3 (section 6.2.2 step 1) as the kernels form them:
     SHA256MSG2(VPADD_4u32(SHA256MSG1(w[t-16], w[t-12]),
                           VPALIGNR_128(w[t-4], w[t-8], 4)), w[t-4]) *)
lemma shani_sched4 (m : W32.t list) (t : int) :
  size m = 16 => 16 <= t => t + 3 < 64 =>
  SHA256MSG2
    (VPADD_4u32 (SHA256MSG1 (wv m (t - 16)) (wv m (t - 12)))
                (VPALIGNR_128 (wv m (t - 4)) (wv m (t - 8)) (W8.of_int 4)))
    (wv m (t - 4))
  = wv m t.
proof.
move=> hm ht1 ht2.
rewrite msg1_spec vpalignr4 /wv /= vpadd4_pack msg2_spec /=.
have e0 : nth W32.zero (schedule m) (t - 16) + ssig0 (nth W32.zero (schedule m) (t - 15))
          + nth W32.zero (schedule m) (t - 7) + ssig1 (nth W32.zero (schedule m) (t - 2))
          = nth W32.zero (schedule m) t.
+ by rewrite (nth_schedule_hi m t) // 1:/#; ring.
have e1 : nth W32.zero (schedule m) (t - 15) + ssig0 (nth W32.zero (schedule m) (t - 14))
          + nth W32.zero (schedule m) (t - 6) + ssig1 (nth W32.zero (schedule m) (t - 1))
          = nth W32.zero (schedule m) (t + 1).
+ by rewrite (nth_schedule_hi m (t + 1)) // 1:/# /=; ring.
rewrite e0 e1 /p4; apply pack4_eq => //.
+ by rewrite (nth_schedule_hi m (t + 2)) // 1:/# /=; ring.
by rewrite (nth_schedule_hi m (t + 3)) // 1:/# /=; ring.
qed.
