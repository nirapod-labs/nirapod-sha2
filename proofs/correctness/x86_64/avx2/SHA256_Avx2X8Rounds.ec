(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2X8Rounds.ec (x86_64, avx2)
 * =====================================
 *
 * Functional correctness of the 8-way SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_x8_compress.jinc) against FIPS 180-4 section
 * 6.2.2, round layer (the schedule and the constants are in
 * SHA256_Avx2X8Sched.ec, the rounds driver in SHA256_Avx2X8Block.ec):
 *
 *   round_x8      one call of __sha256_x8_round: round t of step 3 on
 *                 every lane
 *   step, vars_step  the round on the list of working variables, with
 *                 W_t + K_t given
 *   *_8x_ok       the four logical functions as functions of the model
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256KernelX root is
 * src/x86_64/avx2 (proofs/Makefile).
 *
 * Invariant. Lane L of each register is instance L, and the lanes never
 * mix in the rounds or the schedule, so every statement is per lane. In
 * round t, working variable k (a = 0 ... h = 7) of every lane is in
 * register ix k t = (k + 64 - t) mod 8 of v (rv), the index the kernel
 * computes; the rotation moves the names, not the values.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray256 BArray512 BArray2048.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Vec Bmi Rounds256 SHA256_Avx2X8Vec.
import SHA256.

(* ------------------------------------------------------------------ *)
(* Register of working variable c in round t                         *)

op ix (c t : int) : int = (c + 64 - t) %% 8.

lemma ix_rng c t : 0 <= ix c t < 8.
proof. by rewrite /ix; apply modz_cmp. qed.

lemma ix_eq c1 c2 t : 0 <= c1 < 8 => 0 <= c2 < 8 => (ix c1 t = ix c2 t) = (c1 = c2).
proof.
move=> h1 h2; rewrite /ix eq_iff; split => [|-> //].
have := divz_eq (c1 + 64 - t) 8; have := divz_eq (c2 + 64 - t) 8.
by have := modz_cmp (c1 + 64 - t) 8; have := modz_cmp (c2 + 64 - t) 8; smt().
qed.

(* Round t + 1 finds variable c where round t had variable c - 1. *)
lemma ixS c t : 0 <= c < 8 => ix c (t + 1) = ix ((c + 7) %% 8) t.
proof.
move=> hc; rewrite /ix; case: (c = 0) => [->|hc0] /=.
+ by rewrite (_: 64 - (t + 1) = (71 - t) + (-1) * 8) 1:/# modzMDr.
have -> : (c + 7) %% 8 = c - 1 by rewrite (_: c + 7 = (c - 1) + 1 * 8) 1:/# modzMDr pmod_small /#.
by congr; smt().
qed.

(* Sixteen rounds bring every variable back to its register. *)
lemma ix16 c t : ix c (t + 16) = ix c t.
proof. by rewrite /ix (_: c + 64 - (t + 16) = (c + 64 - t) + (-2) * 8) 1:/# modzMDr. qed.

lemma cases8 k : 0 <= k < 8 =>
  k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7.
proof. smt(). qed.

lemma ix0 c : 0 <= c < 8 => ix c 0 = c.
proof. by move=> hc; rewrite /ix /= (_: c + 64 = c + 8 * 8) 1:/# modzMDr pmod_small. qed.

(* A write to the register of variable c, read back at index j. *)
lemma gs (v : BArray256.t) c t j x :
  BArray256.get256 (BArray256.set256 v (ix c t) x) j
  = if ix c t = j then x else BArray256.get256 v j.
proof. by have [h0 h1] := ix_rng c t; rewrite BArray256.get_set256E // /#. qed.

(* ------------------------------------------------------------------ *)
(* One round on the list of working variables                          *)

(* Round of step 3 with W_t + K_t given as wk. *)
op step (vs : W32.t list) (wk : W32.t) : W32.t list =
  let t1 = nth W32.zero vs 7 + bsig1 (nth W32.zero vs 4)
         + ch (nth W32.zero vs 4) (nth W32.zero vs 5) (nth W32.zero vs 6) + wk in
  let t2 = bsig0 (nth W32.zero vs 0) + maj (nth W32.zero vs 0) (nth W32.zero vs 1) (nth W32.zero vs 2) in
  [t1 + t2; nth W32.zero vs 0; nth W32.zero vs 1; nth W32.zero vs 2;
   nth W32.zero vs 3 + t1; nth W32.zero vs 4; nth W32.zero vs 5; nth W32.zero vs 6].

lemma vars_step hv w t : 0 <= t =>
  vars hv w (t + 1) = step (vars hv w t) (nth W32.zero K256 t + nth W32.zero w t).
proof. by move=> ht; rewrite varsS // /step /T1 /T2 /= !addrA. qed.

(* The state of every lane: variable k of lane L in register ix k t. *)
op rv (v : BArray256.t) (t : int) (vs : int -> W32.t list) =
  forall L k, 0 <= L < 8 => 0 <= k < 8 =>
    BArray256.get256 v (ix k t) \bits32 L = nth W32.zero (vs L) k.

(* b XOR c of every lane, the form the kernel carries into Maj. *)
op bc (vs : W32.t list) : W32.t = nth W32.zero vs 1 +^ nth W32.zero vs 2.

(* ------------------------------------------------------------------ *)
(* The logical functions                                              *)

lemma Sigma0_8x_ok x0 : hoare [M.__Sigma0_8x : x = x0 ==> res = vS0 x0].
proof. by proc; auto => />; rewrite /vS0. qed.

lemma Sigma1_8x_ok x0 : hoare [M.__Sigma1_8x : x = x0 ==> res = vS1 x0].
proof. by proc; auto => />; rewrite /vS1. qed.

lemma sigma0_8x_ok x0 : hoare [M.__sigma0_8x : x = x0 ==> res = vs0 x0].
proof. by proc; auto => />; rewrite /vs0. qed.

lemma sigma1_8x_ok x0 : hoare [M.__sigma1_8x : x = x0 ==> res = vs1 x0].
proof. by proc; auto => />; rewrite /vs1. qed.

(* ------------------------------------------------------------------ *)
(* __sha256_x8_round                                                  *)

(* Registers outside cs still hold what v0 held. *)
op same (v v0 : BArray256.t) (t : int) (cs : int list) =
  forall c, 0 <= c < 8 => !(c \in cs) =>
    BArray256.get256 v (ix c t) = BArray256.get256 v0 (ix c t).

(* Every lane L of the register of variable c holds f L. *)
op lane_is (v : BArray256.t) (c t : int) (f : int -> W32.t) =
  forall L, 0 <= L < 8 => BArray256.get256 v (ix c t) \bits32 L = f L.

(* What a round knows of its arguments and of the registers it names. *)
op rfr (t0 : int) (vs : int -> W32.t list) (wv : int -> W32.t) (v0 : BArray256.t)
       (t : int) (wk : W256.t) (a b d e f g h : int) =
  t = t0 /\ rv v0 t0 vs /\ (forall L, 0 <= L < 8 => wk \bits32 L = wv L) /\
  a = ix 0 t0 /\ b = ix 1 t0 /\ d = ix 3 t0 /\ e = ix 4 t0 /\ f = ix 5 t0 /\ g = ix 6 t0 /\ h = ix 7 t0.

abbrev vk (vs : int -> W32.t list) L k = nth W32.zero (vs L) k.

lemma round_x8 (t0 : int) (v0 : BArray256.t) (vs : int -> W32.t list) (wv : int -> W32.t) :
  hoare [M.__sha256_x8_round :
    t = t0 /\ v = v0 /\ rv v t0 vs /\
    (forall L, 0 <= L < 8 => wk \bits32 L = wv L) /\
    (forall L, 0 <= L < 8 => cc \bits32 L = bc (vs L)) ==>
    rv res.`1 (t0 + 1) (fun L => step (vs L) (wv L)) /\
    (forall L, 0 <= L < 8 => res.`2 \bits32 L = vk vs L 0 +^ vk vs L 1)].
proof.
proc.
seq 7 : (rfr t0 vs wv v0 t wk a b d e f g h /\ v = v0 /\
         forall L, 0 <= L < 8 => cc \bits32 L = bc (vs L)).
+ by wp; skip => &hr /= [#] -> -> hrv hwk hcc; rewrite /rfr /ix /=; do ?split => //.
(* T1 without Sigma1(e): h + W_t + K_t + Ch(e, f, g) *)
seq 5 : (rfr t0 vs wv v0 t wk a b d e f g h /\ same v v0 t0 [7] /\
         lane_is v 7 t0 (fun L => vk vs L 7 + wv L + ch (vk vs L 4) (vk vs L 5) (vk vs L 6)) /\
         forall L, 0 <= L < 8 => cc \bits32 L = bc (vs L)).
+ wp; skip => &hr [hfr [-> hcc]]; split; 1: exact hfr.
  have := hfr; rewrite /rfr => -[#] _ hrv hwk ha hb hd he hf hg hh.
  rewrite ?ha ?hb ?hd ?he ?hf ?hg ?hh.
  split; 2: (split; 2: exact hcc).
  + by move=> c hc hc7; rewrite !gs /= ?ix_eq //=; smt().
  move=> L hL; rewrite !gs /= ?ix_eq //=.
  by rewrite !(vpadd32, vpxor32, vpand32) // !hrv // hwk // ch_kernel.
(* T1, then e' = d + T1 *)
seq 3 : (rfr t0 vs wv v0 t wk a b d e f g h /\ same v v0 t0 [3; 7] /\
         lane_is v 7 t0 (fun L => vk vs L 7 + wv L + ch (vk vs L 4) (vk vs L 5) (vk vs L 6)
                                  + bsig1 (vk vs L 4)) /\
         lane_is v 3 t0 (fun L => vk vs L 3 + (vk vs L 7 + wv L + ch (vk vs L 4) (vk vs L 5) (vk vs L 6)
                                  + bsig1 (vk vs L 4))) /\
         forall L, 0 <= L < 8 => cc \bits32 L = bc (vs L)).
+ wp; ecall (Sigma1_8x_ok (BArray256.get256 v e)).
  skip => &hr [hfr [hsm [hl hcc]]] /= r ->; split; 1: exact hfr.
  have := hfr; rewrite /rfr => -[#] _ hrv hwk ha hb hd he hf hg hh.
  rewrite ?ha ?hb ?hd ?he ?hf ?hg ?hh.
  split; 2: (split; 2: (split; 2: exact hcc)).
  + move=> c hc hcn; rewrite !gs !ix_eq // ifF 1:/# ifF 1:/#; apply hsm => // /#.
  + move=> L hL; rewrite !gs /= ?ix_eq //=.
    by rewrite !(vpadd32, vS1_lane) // hl // hsm // hrv.
  move=> L hL; rewrite !gs /= ?ix_eq //=.
  by rewrite !(vpadd32, vS1_lane) // hl // !hsm // !hrv.
(* T1 + Sigma0(a) *)
seq 2 : (rfr t0 vs wv v0 t wk a b d e f g h /\ same v v0 t0 [3; 7] /\
         lane_is v 7 t0 (fun L => vk vs L 7 + wv L + ch (vk vs L 4) (vk vs L 5) (vk vs L 6)
                                  + bsig1 (vk vs L 4) + bsig0 (vk vs L 0)) /\
         lane_is v 3 t0 (fun L => vk vs L 3 + (vk vs L 7 + wv L + ch (vk vs L 4) (vk vs L 5) (vk vs L 6)
                                  + bsig1 (vk vs L 4))) /\
         forall L, 0 <= L < 8 => cc \bits32 L = bc (vs L)).
+ wp; ecall (Sigma0_8x_ok (BArray256.get256 v a)).
  skip => &hr [hfr [hsm [hl [hl3 hcc]]]] /= r ->; split; 1: exact hfr.
  have := hfr; rewrite /rfr => -[#] _ hrv hwk ha hb hd he hf hg hh.
  rewrite ?ha ?hb ?hd ?he ?hf ?hg ?hh.
  split; 2: (split; 2: (split; 2: exact hcc)).
  + move=> c hc hcn; rewrite !gs !ix_eq // ifF 1:/#; exact (hsm c hc hcn).
  + move=> L hL; rewrite !gs /= ?ix_eq //=.
    by rewrite !(vpadd32, vS0_lane) // hl // hsm // hrv.
  by move=> L hL; rewrite !gs /= ?ix_eq //= hl3.
(* Maj, and the a ^ b the next round needs *)
wp; skip => &hr [hfr [hsm [hl [hl3 hcc]]]] /=.
have := hfr; rewrite /rfr => -[#] _ hrv hwk ha hb hd he hf hg hh.
rewrite ?ha ?hb ?hd ?he ?hf ?hg ?hh.
split.
+ move=> L k hL hk.
  have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 k hk;
  rewrite ixS //= !gs /= ?ix_eq //= /step /= ?(vpadd32, vpxor32, vpand32) // ?hl // ?hl3 // ?hcc // ?hsm // ?hrv //;
  by (try rewrite /bc maj_bmi32); ring.
by move=> L hL; rewrite !hsm // !hrv.
qed.
