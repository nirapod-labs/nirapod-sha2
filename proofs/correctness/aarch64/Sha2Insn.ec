(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Sha2Insn.ec (aarch64)
 * =====================
 *
 * The ARMv8-A SHA-2 instructions (FEAT_SHA256, FEAT_SHA512), as the Jasmin
 * model JModel_armv8a defines them, compute the rounds and the message
 * schedule of FIPS 180-4 as spec/FIPS180_SHA2.ec states them. Each lemma
 * is stated in the operand order the AArch64 kernels issue the
 * instruction in, so a kernel proof applies it without unfolding the
 * model:
 *
 *     sha256h_rounds4    SHA256H, SHA256H2: rounds t .. t+3 (6.2.2 step 3)
 *                        on (a, b, c, d), (e, f, g, h), from K + W
 *     sha256su_sched4    SHA256SU1 (SHA256SU0 ..): W_t+16 .. W_t+19
 *                        (6.2.2 step 1)
 *     sha512h_rounds2    SHA512H, SHA512H2 with VEXT #8 and VADD: rounds
 *                        t, t+1 (6.4.2 step 3) on [a; b], [c; d], [e; f],
 *                        [g; h]
 *     sha512su_sched2    SHA512SU1 (SHA512SU0 ..) with VEXT #8: W_t+16,
 *                        W_t+17 (6.4.2 step 1)
 *
 * The schedule lemmas hold for any word list satisfying the recurrence of
 * step 1 at the four (two) indices they produce (srec); the kernel proofs
 * instantiate them with the schedule of the specification.
 *
 * SHA512H2 computes Maj in the form (x AND y) OR ((x OR y) AND z) of the
 * Arm pseudocode; majorityE proves it equal to Maj of section 4.1.2.
 *
 * Model-free: checked once (proofs/Makefile, check-lib).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_armv8a.
require import FIPS180_SHA2 Vec.

(* ------------------------------------------------------------------ *)
(* SHA-256 (FEAT_SHA256)                                              *)

theory A256.
import SHA256.

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

(* One iteration of the SHA256hash loop is one round of section 6.2.2
   step 3, on (a, b, c, d), (e, f, g, h). *)
lemma hash_step_round (w : W32.t list) (t : int) (s : state) :
  sha256hash_step ((s.`1, s.`2, s.`3, s.`4), (s.`5, s.`6, s.`7, s.`8))
                  (nth W32.zero K256 t + nth W32.zero w t)
  = (((round w s t).`1, (round w s t).`2, (round w s t).`3, (round w s t).`4),
     ((round w s t).`5, (round w s t).`6, (round w s t).`7, (round w s t).`8)).
proof.
case: s => a b c d e f g h.
rewrite /sha256hash_step /round /= !SHA_chE !SHA_majE !SHA_sum0E !SHA_sum1E.
by split; ring.
qed.

lemma range4 (w : W32.t list) (t : int) (s : state) :
  foldl (round w) s (range t (t + 4))
  = round w (round w (round w (round w s t) (t + 1)) (t + 2)) (t + 3).
proof. by rewrite range_ltn 1:/# range_ltn 1:/# range_ltn 1:/# range_ltn 1:/# range_geq 1:/# /=. qed.

(* K_t + W_t of group t / 4, as __sha256_block_a64 forms it. *)
op wk4 (w : W32.t list) (t : int) : W128.t =
  VADD_4u32
    (p4 (nth W32.zero K256 t) (nth W32.zero K256 (t + 1))
        (nth W32.zero K256 (t + 2)) (nth W32.zero K256 (t + 3)))
    (p4 (nth W32.zero w t) (nth W32.zero w (t + 1)) (nth W32.zero w (t + 2)) (nth W32.zero w (t + 3))).

(* Rounds t .. t+3 as the kernel issues them:
     abcd' = SHA256H(abcd, efgh, wk);  efgh' = SHA256H2(efgh, abcd, wk) *)
lemma sha256h_rounds4 (w : W32.t list) (t : int) (s : state) :
  SHA256H (p4 s.`1 s.`2 s.`3 s.`4) (p4 s.`5 s.`6 s.`7 s.`8) (wk4 w t)
  = p4 (foldl (round w) s (range t (t + 4))).`1 (foldl (round w) s (range t (t + 4))).`2
       (foldl (round w) s (range t (t + 4))).`3 (foldl (round w) s (range t (t + 4))).`4
  /\ SHA256H2 (p4 s.`5 s.`6 s.`7 s.`8) (p4 s.`1 s.`2 s.`3 s.`4) (wk4 w t)
  = p4 (foldl (round w) s (range t (t + 4))).`5 (foldl (round w) s (range t (t + 4))).`6
       (foldl (round w) s (range t (t + 4))).`7 (foldl (round w) s (range t (t + 4))).`8.
proof.
rewrite range4 /SHA256H /SHA256H2 /sha256hash /wk4 vadd4_pack /=.
by rewrite !p4_0 !p4_1 !p4_2 !p4_3 !hash_step_round /= /p4.
qed.

(* Four consecutive words W_k .. W_k+3 of a schedule ws as one vector. *)
op wv (ws : W32.t list) (k : int) : W128.t =
  p4 (nth W32.zero ws k) (nth W32.zero ws (k + 1))
     (nth W32.zero ws (k + 2)) (nth W32.zero ws (k + 3)).

lemma su0_spec (d n : W128.t) :
  SHA256SU0 d n
  = p4 (ssig0 (d \bits32 1) + (d \bits32 0)) (ssig0 (d \bits32 2) + (d \bits32 1))
       (ssig0 (d \bits32 3) + (d \bits32 2)) (ssig0 (n \bits32 0) + (d \bits32 3)).
proof. by rewrite /SHA256SU0 iota04 /= /p4 !SHA_sigma0E. qed.

lemma su1_spec (d n m : W128.t) :
  SHA256SU1 d n m
  = let r0 = ssig1 (m \bits32 2) + (d \bits32 0) + (n \bits32 1) in
    let r1 = ssig1 (m \bits32 3) + (d \bits32 1) + (n \bits32 2) in
    p4 r0 r1 (ssig1 r0 + (d \bits32 2) + (n \bits32 3)) (ssig1 r1 + (d \bits32 3) + (m \bits32 0)).
proof. by rewrite /SHA256SU1 /= /p4 !SHA_sigma1E. qed.

(* The recurrence of section 6.2.2 step 1 for W_j. *)
op srec (ws : W32.t list) (j : int) : bool =
  nth W32.zero ws j
  = ssig1 (nth W32.zero ws (j - 2)) + nth W32.zero ws (j - 7)
  + ssig0 (nth W32.zero ws (j - 15)) + nth W32.zero ws (j - 16).

(* W_t+16 .. W_t+19 as the kernel forms them, for any word list that
   satisfies the recurrence there:
     SHA256SU1(SHA256SU0(W_t.., W_t+4..), W_t+8.., W_t+12..) *)
lemma sha256su_sched4 (ws : W32.t list) (t : int) :
  srec ws (t + 16) => srec ws (t + 17) => srec ws (t + 18) => srec ws (t + 19) =>
  SHA256SU1 (SHA256SU0 (wv ws t) (wv ws (t + 4))) (wv ws (t + 8)) (wv ws (t + 12))
  = wv ws (t + 16).
proof.
rewrite /srec /= => h16 h17 h18 h19.
rewrite su0_spec su1_spec /wv /= !p4_0 !p4_1 !p4_2 !p4_3.
have e0 : ssig1 (nth W32.zero ws (t + 14))
          + (ssig0 (nth W32.zero ws (t + 1)) + nth W32.zero ws t)
          + nth W32.zero ws (t + 9)
          = nth W32.zero ws (t + 16).
+ by rewrite h16 /=; ring.
have e1 : ssig1 (nth W32.zero ws (t + 15))
          + (ssig0 (nth W32.zero ws (t + 2)) + nth W32.zero ws (t + 1))
          + nth W32.zero ws (t + 10)
          = nth W32.zero ws (t + 17).
+ by rewrite h17 /=; ring.
rewrite e0 e1; apply p4_eq => //.
+ by rewrite h18 /=; ring.
by rewrite h19 /=; ring.
qed.

end A256.

(* ------------------------------------------------------------------ *)
(* SHA-512 (FEAT_SHA512)                                              *)

theory A512.
import SHA512.

lemma Sigma0E (x : W64.t) : SHA512Sigma0 x = bsig0 x.
proof. by rewrite /SHA512Sigma0 /bsig0. qed.
lemma Sigma1E (x : W64.t) : SHA512Sigma1 x = bsig1 x.
proof. by rewrite /SHA512Sigma1 /bsig1. qed.
lemma sigma0E (x : W64.t) : sha512sigma0 x = ssig0 x.
proof. by rewrite /sha512sigma0 /ssig0. qed.
lemma sigma1E (x : W64.t) : sha512sigma1 x = ssig1 x.
proof. by rewrite /sha512sigma1 /ssig1. qed.
lemma chE (x y z : W64.t) : (x `&` y) +^ (invw x `&` z) = ch x y z.
proof. by rewrite /ch. qed.

(* The majority of the Arm pseudocode, (x AND y) OR ((x OR y) AND z), is
   Maj of section 4.1.3; Maj is symmetric. *)
lemma majorityE (x y z : W64.t) : SHAmajority64 x y z = maj x y z.
proof.
apply W64.wordP => i hi; rewrite /SHAmajority64 /maj /=.
by case: (x.[i]); case: (y.[i]); case: (z.[i]).
qed.

lemma maj_rev (x y z : W64.t) : maj z y x = maj x y z.
proof.
apply W64.wordP => i hi; rewrite /maj /=.
by case: (x.[i]); case: (y.[i]); case: (z.[i]).
qed.

lemma range2 (w : W64.t list) (t : int) (s : state) :
  foldl (round w) s (range t (t + 2)) = round w (round w s t) (t + 1).
proof. by rewrite range_ltn 1:/# range_ltn 1:/# range_geq 1:/# /=. qed.

(* [K_t+1 + W_t+1; K_t + W_t], as __sha512_block_a64 forms it:
     wk = VADD_2u64(K, W); wk = VEXT(wk, wk, 8) *)
op kw2 (w : W64.t list) (t : int) : W128.t =
  VEXT (VADD_2u64 (p2 (nth W64.zero K512 t) (nth W64.zero K512 (t + 1)))
                  (p2 (nth W64.zero w t) (nth W64.zero w (t + 1))))
       (VADD_2u64 (p2 (nth W64.zero K512 t) (nth W64.zero K512 (t + 1)))
                  (p2 (nth W64.zero w t) (nth W64.zero w (t + 1))))
       (W8.of_int 8).

(* The SHA512H result of rounds t and t+1, as the kernel forms it from
   [a; b], [c; d], [e; f], [g; h]. *)
op h512 (w : W64.t list) (t : int) (s : state) : W128.t =
  SHA512H (VADD_2u64 (p2 s.`7 s.`8) (kw2 w t))
          (VEXT (p2 s.`5 s.`6) (p2 s.`7 s.`8) (W8.of_int 8))
          (VEXT (p2 s.`3 s.`4) (p2 s.`5 s.`6) (W8.of_int 8)).

(* Rounds t and t+1 (section 6.4.2 step 3) as the kernel issues them:
     x  = SHA512H([g; h] + wk, EXT([e; f], [g; h], 8), EXT([c; d], [e; f], 8))
     ef = [c; d] + x
     ab = SHA512H2(x, [c; d], [a; b])
   and the old [a; b] and [e; f] are the new [c; d] and [g; h]. *)
lemma sha512h_rounds2 (w : W64.t list) (t : int) (s : state) :
  VADD_2u64 (p2 s.`3 s.`4) (h512 w t s)
    = p2 (foldl (round w) s (range t (t + 2))).`5 (foldl (round w) s (range t (t + 2))).`6
  /\ SHA512H2 (h512 w t s) (p2 s.`3 s.`4) (p2 s.`1 s.`2)
    = p2 (foldl (round w) s (range t (t + 2))).`1 (foldl (round w) s (range t (t + 2))).`2
  /\ p2 s.`1 s.`2
    = p2 (foldl (round w) s (range t (t + 2))).`3 (foldl (round w) s (range t (t + 2))).`4
  /\ p2 s.`5 s.`6
    = p2 (foldl (round w) s (range t (t + 2))).`7 (foldl (round w) s (range t (t + 2))).`8.
proof.
rewrite range2; case: s => a b c d e f g h.
rewrite /h512 /kw2 /= !vadd2_pack !vext8 vadd2_pack.
rewrite /SHA512H /SHA512H2 /= !p2_0 !p2_1 vadd2_pack /round /=.
rewrite !Sigma0E !Sigma1E !chE !majorityE.
have he : ch e f g + bsig1 e + (h + (nth W64.zero K512 t + nth W64.zero w t)) + d
          = d + (h + bsig1 e + ch e f g + nth W64.zero K512 t + nth W64.zero w t).
+ by ring.
have ha : maj c b a + bsig0 a + (ch e f g + bsig1 e + (h + (nth W64.zero K512 t + nth W64.zero w t)))
          = h + bsig1 e + ch e f g + nth W64.zero K512 t + nth W64.zero w t + (bsig0 a + maj a b c).
+ by rewrite maj_rev; ring.
rewrite he ha; split; apply p2_eq; ring.
qed.

(* Two consecutive words W_k, W_k+1 of a schedule ws as one vector. *)
op wv2 (ws : W64.t list) (k : int) : W128.t =
  p2 (nth W64.zero ws k) (nth W64.zero ws (k + 1)).

(* The recurrence of section 6.4.2 step 1 for W_j. *)
op srec (ws : W64.t list) (j : int) : bool =
  nth W64.zero ws j
  = ssig1 (nth W64.zero ws (j - 2)) + nth W64.zero ws (j - 7)
  + ssig0 (nth W64.zero ws (j - 15)) + nth W64.zero ws (j - 16).

(* W_t+16, W_t+17 as the kernel forms them:
     SHA512SU1(SHA512SU0(W_t.., W_t+2..), W_t+14.., EXT(W_t+8.., W_t+10.., 8)) *)
lemma sha512su_sched2 (ws : W64.t list) (t : int) :
  srec ws (t + 16) => srec ws (t + 17) =>
  SHA512SU1 (SHA512SU0 (wv2 ws t) (wv2 ws (t + 2))) (wv2 ws (t + 14))
            (VEXT (wv2 ws (t + 8)) (wv2 ws (t + 10)) (W8.of_int 8))
  = wv2 ws (t + 16).
proof.
rewrite /srec /= => h16 h17.
rewrite /wv2 vext8 /SHA512SU0 /SHA512SU1 /= !p2_0 !p2_1 !sigma0E !sigma1E.
apply p2_eq.
+ by rewrite h16 /=; ring.
by rewrite h17 /=; ring.
qed.

end A512.
