(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2.ec
 * ==============
 *
 * Functional correctness of the SHA-512 AVX2 kernel
 * (src/x86_64/avx2/sha512_compress.jinc) against FIPS 180-4 section
 * 6.4.2 as spec/FIPS180_SHA2.ec writes it. This file holds the round and
 * schedule layers:
 *
 *   round_rst      one call of __sha512_avx2_round, scalar part: round t of
 *                  section 6.4.2 step 3 on the rotating slots of v
 *   round_v0, v1   its schedule half-steps (ph = 0, 1) on x[j mod 8]
 *   round_full     both, for ph in {0, 1, 2}
 *   half0_win,     the two half-steps move the schedule window from group
 *   half1_win      j to group j + 1 (section 6.4.2 step 1)
 *   wk_set, wk_get the W_t + K_t table on the stack
 *
 * Model. NirapodSha2 is the model of a unit whose Sha512Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *
 * Invariants. Working variable k (a = 0 ... h = 7) of round t is in slot
 * (k + 80 - t) mod 8 of v (vis). Between rounds the slot of a lacks the
 * deferred Sigma0, held in s, and m[t mod 2] holds b XOR c (rst). Each
 * 256-bit word of x and wk holds one group of two schedule words per
 * 128-bit half, the low half for the first block and the high half for
 * the second (lane). Before group g, x[r] holds group g + ((r - g) mod 8)
 * (win).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray64 BArray256 BArray640 BArray1280.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes64 Arrays Rounds512.
import SHA512.

clone Arrays.ArrayLanes as L640 with theory A <- BArray640.
clone Arrays.ArrayLanes as L1280 with theory A <- BArray1280.

(* ------------------------------------------------------------------ *)
(* Rotating working variables                                          *)

(* Working variable k (a = 0 ... h = 7) of round t is in slot
   (k + 80 - t) mod 8 of v; the terms are written as the model writes
   them so that hypotheses rewrite the model's reads directly. *)
op vis (v : BArray64.t) (t : int) (a b c d e f g h : W64.t) =
  BArray64.get64 v (((0 + 80) - t) %% 8) = a /\
  BArray64.get64 v (((1 + 80) - t) %% 8) = b /\
  BArray64.get64 v (((2 + 80) - t) %% 8) = c /\
  BArray64.get64 v (((3 + 80) - t) %% 8) = d /\
  BArray64.get64 v (((4 + 80) - t) %% 8) = e /\
  BArray64.get64 v (((5 + 80) - t) %% 8) = f /\
  BArray64.get64 v (((6 + 80) - t) %% 8) = g /\
  BArray64.get64 v (((7 + 80) - t) %% 8) = h.

lemma sl_get (v : BArray64.t) t k k' x : 0 <= k < 8 => 0 <= k' < 8 =>
  BArray64.get64 (BArray64.set64 v (((k + 80) - t) %% 8) x) (((k' + 80) - t) %% 8)
  = if k = k' then x else BArray64.get64 v (((k' + 80) - t) %% 8).
proof.
move=> hk hk'; rewrite BArray64.get_set64E 1,2:/#.
by congr; apply eq_iff; smt().
qed.

lemma vis_set0 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray64.set64 v (((0 + 80) - t) %% 8) x) t x b c d e f g h.
proof. by rewrite /vis !sl_get. qed.

lemma vis_set3 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray64.set64 v (((3 + 80) - t) %% 8) x) t a b c x e f g h.
proof. by rewrite /vis !sl_get. qed.

lemma vis_set7 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray64.set64 v (((7 + 80) - t) %% 8) x) t a b c d e f g x.
proof. by rewrite /vis !sl_get. qed.

(* The next round sees the same slots one name further on. *)
lemma vis_next v t a b c d e f g h : vis v t a b c d e f g h =>
  vis v (t + 1) h a b c d e f g.
proof.
rewrite /vis => [#] <- <- <- <- <- <- <- <-.
by do !split; congr; smt().
qed.

lemma m_get (m : BArray16.t) t x :
  BArray16.get64 (BArray16.set64 m (t %% 2) x) ((t + 1) %% 2) = BArray16.get64 m ((t + 1) %% 2).
proof. by rewrite BArray16.get_set64E 1,2:/#; smt(). qed.

lemma m_get' (m : BArray16.t) t x :
  BArray16.get64 (BArray16.set64 m ((t + 1) %% 2) x) (t %% 2) = BArray16.get64 m (t %% 2).
proof. by rewrite BArray16.get_set64E 1,2:/#; smt(). qed.

lemma m_setp (m : BArray16.t) t x : BArray16.get64 (BArray16.set64 m (t %% 2) x) (t %% 2) = x.
proof. by rewrite BArray16.get_set64E 1,2:/#. qed.

lemma m_setq (m : BArray16.t) t x :
  BArray16.get64 (BArray16.set64 m ((t + 1) %% 2) x) ((t + 1) %% 2) = x.
proof. by rewrite BArray16.get_set64E 1,2:/#. qed.

(* ------------------------------------------------------------------ *)
(* Scalar round                                                        *)

lemma round_scalar (a0 b c d e f g h0 s0 mp : W64.t) (t0 : int) :
  hoare [M.__sha512_avx2_round :
    t = t0 /\ s = s0 /\ vis v t a0 b c d e f g h0 /\ BArray16.get64 m (t %% 2) = mp ==>
    let a = a0 + s0 in
    let t1 = h0 + (f `&` e) + (ANDN_64 e g).`6
             + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14)) in
    vis res.`1 t0 a b c (d + t1) e f g (t1 + ((mp `&` (a +^ b)) +^ b)) /\
    res.`3 = RORX_64 a (W8.of_int 34) +^ RORX_64 a (W8.of_int 39) +^ RORX_64 a (W8.of_int 28) /\
    BArray16.get64 res.`2 ((t0 + 1) %% 2) = a +^ b].
proof.
proc.
seq 3 : (t = t0 /\ vis v t (a0 + s0) b c d e f g h0 /\ BArray16.get64 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> -> hv hm.
  have := vis_set0 _ _ _ _ _ _ _ _ _ _ (a0 + s0) hv.
  have -> : BArray64.get64 v{hr} (((0 + 80) - t0) %% 8) = a0 by move: hv => @/vis [#].
  smt().
seq 7 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e)) /\
         z = RORX_64 e (W8.of_int 41) /\ w = RORX_64 e (W8.of_int 18) /\
         BArray16.get64 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e)) hv.
  move: hv => @/vis [#] _ _ _ _ -> -> _ ->.
  smt().
seq 8 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e) + (ANDN_64 e g).`6) /\
         z = RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) /\
         w = RORX_64 e (W8.of_int 14) /\ BArray16.get64 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv -> -> hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e) + (ANDN_64 e g).`6) hv.
  move: hv => @/vis [#] _ _ _ _ -> _ -> ->.
  smt().
seq 6 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14))) /\
         BArray16.get64 m ((t + 1) %% 2) = (a0 + s0) /\ y = RORX_64 (a0 + s0) (W8.of_int 39) /\
         BArray16.get64 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv -> -> hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14))) hv.
  move: hv => @/vis [#] -> _ _ _ _ _ _ ->.
  rewrite m_setq m_get' hm; smt().
seq 6 : (t = t0 /\ vis v t (a0 + s0) b c (d + (h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14)))) e f g (h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14))) /\
         BArray16.get64 m ((t + 1) %% 2) = (a0 + s0) +^ b /\ y = RORX_64 (a0 + s0) (W8.of_int 39) /\
         s = RORX_64 (a0 + s0) (W8.of_int 34) /\ z = RORX_64 (a0 + s0) (W8.of_int 28) /\
         BArray16.get64 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv hq -> hm.
  have := vis_set3 _ _ _ _ _ _ _ _ _ _ (d + (h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14)))) hv.
  move: hv => @/vis [#] -> -> _ -> _ _ _ ->.
  rewrite m_setq hq m_get' hm; smt().
wp; skip => &hr /= [#] -> hv hq -> -> -> hm.
have := vis_set7 _ _ _ _ _ _ _ _ _ _ ((h0 + (f `&` e) + (ANDN_64 e g).`6 + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14))) + ((mp `&` ((a0 + s0) +^ b)) +^ b)) hv.
move: hv => @/vis [#] _ -> _ _ _ _ _ ->.
rewrite !m_setp !m_get hm hq; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The round against section 6.4.2, step 3                            *)

(* Between rounds: the slot of a lacks the deferred Sigma0 s, and
   m[t mod 2] holds b XOR c for the next Maj. *)
op rst (v : BArray64.t) (m : BArray16.t) (s : W64.t) (st : state) (t : int) =
  vis v t (st.`1 - s) st.`2 st.`3 st.`4 st.`5 st.`6 st.`7 st.`8 /\
  BArray16.get64 m (t %% 2) = st.`2 +^ st.`3.

(* The same after the driver's addition of W_t + K_t to the slot of h. *)
op rinw (v : BArray64.t) (m : BArray16.t) (s : W64.t) (w : W64.t list) (st : state) (t : int) =
  vis v t (st.`1 - s) st.`2 st.`3 st.`4 st.`5 st.`6 st.`7
      (st.`8 + nth W64.zero K512 t + nth W64.zero w t) /\
  BArray16.get64 m (t %% 2) = st.`2 +^ st.`3.

lemma vis_eq v t a b c d e f g h a' e' : a = a' => e = e' =>
  vis v t a b c d e f g h => vis v t a' b c d e' f g h.
proof. by move=> -> ->. qed.

lemma xor3r (a b c : W64.t) : a +^ b +^ c = c +^ b +^ a.
proof. by rewrite W64.xorwC (W64.xorwC a) W64.xorwA. qed.

lemma xor3l (a b c : W64.t) : a +^ b +^ c = c +^ a +^ b.
proof. by rewrite W64.xorwC W64.xorwA. qed.

lemma t1E (h e f g : W64.t) :
  h + (f `&` e) + (ANDN_64 e g).`6
  + (RORX_64 e (W8.of_int 41) +^ RORX_64 e (W8.of_int 18) +^ RORX_64 e (W8.of_int 14))
  = h + bsig1 e + ch e f g.
proof. by rewrite ANDN_64E !RORX_64E // /bsig1 xor3r -ch_bmi64; ring. qed.

lemma s0E (a : W64.t) :
  RORX_64 a (W8.of_int 34) +^ RORX_64 a (W8.of_int 39) +^ RORX_64 a (W8.of_int 28) = bsig0 a.
proof. by rewrite !RORX_64E // /bsig0 xor3l. qed.

lemma round_rst (w : W64.t list) (st : state) (t0 : int) :
  hoare [M.__sha512_avx2_round :
    t = t0 /\ rinw v m s w st t ==> rst res.`1 res.`2 res.`3 (round w st t0) (t0 + 1)].
proof.
case: st => a b c d e f g h.
exlim s => s0.
conseq (round_scalar (a - s0) b c d e f g (h + nth W64.zero K512 t0 + nth W64.zero w t0)
          s0 (b +^ c) t0).
+ by move=> &hr; rewrite /rinw /=; smt().
move=> &hr _ [v' m' s' x'] /=.
have -> : a - s0 + s0 = a by ring.
move=> [#] hv -> hq; rewrite /rst /round /=; split; last by rewrite hq.
apply (vis_eq _ _ _ _ _ _ _ _ _ _ _ _ _ _ (vis_next _ _ _ _ _ _ _ _ _ _ hv)).
+ by rewrite maj_bmi64 t1E s0E; ring.
by rewrite t1E; ring.
qed.

(* ------------------------------------------------------------------ *)
(* Schedule half-steps                                                 *)

lemma gs256 (x : BArray256.t) j a r :
  BArray256.get256 (BArray256.set256 x (j %% 8) a) r
  = if j %% 8 = r then a else BArray256.get256 x r.
proof. by rewrite BArray256.get_set256E 1,2:/#. qed.

lemma ss256 (x : BArray256.t) j a b :
  BArray256.set256 (BArray256.set256 x (j %% 8) a) (j %% 8) b = BArray256.set256 x (j %% 8) b.
proof. by apply BArray256.ext_eq => r hr; rewrite !BArray256.get8_set256dE; smt(). qed.

(* ph = 0: x[j] gains W_{t-7} and sigma0 of W_{t-15}, two lanes per half. *)
op half0 (x : BArray256.t) (j : int) : W256.t =
  VPADD_4u64
    (VPADD_4u64 (BArray256.get256 x (j %% 8))
       (VPALIGNR_256 (BArray256.get256 x ((j + 5) %% 8)) (BArray256.get256 x ((j + 4) %% 8))
          (W8.of_int 8)))
    (vsig0 (VPALIGNR_256 (BArray256.get256 x ((j + 1) %% 8)) (BArray256.get256 x (j %% 8))
          (W8.of_int 8))).

(* ph = 1: x[j] gains sigma1 of x[j + 7]. *)
op half1 (x : BArray256.t) (j : int) : W256.t =
  VPADD_4u64 (BArray256.get256 x (j %% 8)) (vsig1 (BArray256.get256 x ((j + 7) %% 8))).

lemma round_v0 (x0 : BArray256.t) (j0 : int) :
  hoare [M.__sha512_avx2_round : ph = 0 /\ x = x0 /\ j = j0 ==>
    res.`4 = BArray256.set256 x0 (j0 %% 8) (half0 x0 j0)].
proof.
proc.
do 6!((rcondt ^if; first by auto); (rcondf ^if; first by auto)).
rcondt ^if; first by auto.
wp; skip => &hr /= [#] _ -> ->.
by rewrite ss256 gs256 /= /half0 /vsig0.
qed.

lemma round_v1 (x0 : BArray256.t) (j0 : int) :
  hoare [M.__sha512_avx2_round : ph = 1 /\ x = x0 /\ j = j0 ==>
    res.`4 = BArray256.set256 x0 (j0 %% 8) (half1 x0 j0)].
proof.
proc.
do 6!((rcondf ^if; first by auto); (rcondt ^if; first by auto)).
rcondf ^if; first by auto.
wp; skip => &hr /= [#] _ -> ->.
by rewrite /half1 /vsig1.
qed.

lemma round_v2 (x0 : BArray256.t) :
  hoare [M.__sha512_avx2_round : ph = 2 /\ x = x0 ==> res.`4 = x0].
proof.
proc.
do 13!(rcondf ^if; first by auto).
by wp; skip => &hr /= [#] _ ->.
qed.

op xnext (x : BArray256.t) (j ph : int) : BArray256.t =
  if ph = 0 then BArray256.set256 x (j %% 8) (half0 x j)
  else if ph = 1 then BArray256.set256 x (j %% 8) (half1 x j) else x.

lemma round_full (w : W64.t list) (st : state) (t0 : int) (x0 : BArray256.t) (j0 p0 : int) :
  p0 = 0 \/ p0 = 1 \/ p0 = 2 =>
  hoare [M.__sha512_avx2_round :
    t = t0 /\ rinw v m s w st t /\ x = x0 /\ j = j0 /\ ph = p0 ==>
    rst res.`1 res.`2 res.`3 (round w st t0) (t0 + 1) /\ res.`4 = xnext x0 j0 p0].
proof.
move=> [hp|[hp|hp]].
+ proc*.
  conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
         (_: ph = 0 /\ x = x0 /\ j = j0 ==> r.`4 = BArray256.set256 x0 (j0 %% 8) (half0 x0 j0)).
  + by move=> &hr /= [#] -> hr -> hj hph; rewrite hph hp /= hr ?hj.
  + by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
  + by call (round_v0 x0 j0); auto.
  by call (round_rst w st t0); auto.
+ proc*.
  conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
         (_: ph = 1 /\ x = x0 /\ j = j0 ==> r.`4 = BArray256.set256 x0 (j0 %% 8) (half1 x0 j0)).
  + by move=> &hr /= [#] -> hr -> hj hph; rewrite hph hp /= hr ?hj.
  + by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
  + by call (round_v1 x0 j0); auto.
  by call (round_rst w st t0); auto.
proc*.
conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
       (_: ph = 2 /\ x = x0 ==> r.`4 = x0).
+ by move=> &hr /= [#] -> hr -> hj hph; rewrite hph hp /= hr ?hj.
+ by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
+ by call (round_v2 x0); auto.
by call (round_rst w st t0); auto.
qed.

(* ------------------------------------------------------------------ *)
(* The schedule window and the W + K table                             *)

op W (m : W64.t list) (t : int) : W64.t = nth W64.zero (schedule m) t.

(* 128-bit half L of every vector belongs to block L. *)
op lane (L : int) (m0 m1 : W64.t list) : W64.t list = if L = 0 then m0 else m1.

lemma Wrec m t : size m = 16 => 16 <= t < 80 =>
  W m t = ssig1 (W m (t - 2)) + W m (t - 7) + ssig0 (W m (t - 15)) + W m (t - 16).
proof. by move=> hm ht; rewrite /W nth_schedule_hi. qed.

(* Before group g: x[r] holds group g + ((r - g) mod 8), the pair
   W_{2i}, W_{2i+1} of that group i in each half. *)
op win (x : BArray256.t) (m0 m1 : W64.t list) (g : int) =
  forall r L c, 0 <= r < 8 => 0 <= L < 2 => 0 <= c < 2 =>
    BArray256.get256 x r \bits64 (2 * L + c) = W (lane L m0 m1) (2 * (g + (r - g) %% 8) + c).

(* After the first half-step of group j + 8, in x[j mod 8]. *)
op winp (x : BArray256.t) (m0 m1 : W64.t list) (j : int) =
  (forall r L c, 0 <= r < 8 => r <> j %% 8 => 0 <= L < 2 => 0 <= c < 2 =>
     BArray256.get256 x r \bits64 (2 * L + c) = W (lane L m0 m1) (2 * (j + (r - j) %% 8) + c)) /\
  (forall L c, 0 <= L < 2 => 0 <= c < 2 =>
     BArray256.get256 x (j %% 8) \bits64 (2 * L + c)
     = W (lane L m0 m1) (2 * j + c) + W (lane L m0 m1) (2 * j + 9 + c)
       + ssig0 (W (lane L m0 m1) (2 * j + 1 + c))).

lemma winE x m0 m1 g r k : win x m0 m1 g => 0 <= r < 8 => 0 <= k < 4 =>
  BArray256.get256 x r \bits64 k = W (lane (k %/ 2) m0 m1) (2 * (g + (r - g) %% 8) + k %% 2).
proof.
move=> hw hr hk; have := hw r (k %/ 2) (k %% 2) hr _ _; 1,2: smt().
by rewrite (_: 2 * (k %/ 2) + k %% 2 = k) 1:/#.
qed.

lemma half0_win x m0 m1 j : win x m0 m1 j =>
  winp (BArray256.set256 x (j %% 8) (half0 x j)) m0 m1 j.
proof.
move=> hw; split.
+ move=> r L c hr hne hL hc; rewrite gs256 ifF 1:/#; exact hw.
move=> L c hL hc; rewrite gs256 /= /half0 vpadd64 1:/# vpadd64 1:/# ssig0_v 1:/#.
rewrite !vpalignr8_64 1,2:/# (_: (2 * L + c) %% 2 = c) 1:/#.
rewrite (winE _ _ _ _ (j %% 8) (2 * L + c) hw) 1,2:/#.
case: (c = 0) => hc0 /=.
+ rewrite (winE _ _ _ _ ((j + 4) %% 8) (2 * L + c + 1) hw) 1,2:/#.
  rewrite (winE _ _ _ _ (j %% 8) (2 * L + c + 1) hw) 1,2:/#.
  rewrite (_: (2 * L + c + 1) %/ 2 = L) 1:/# (_: (2 * L + c) %/ 2 = L) 1:/#.
  rewrite (_: 2 * (j + (j %% 8 - j) %% 8) + (2 * L + c) %% 2 = 2 * j + c) 1:/#.
  rewrite (_: 2 * (j + ((j + 4) %% 8 - j) %% 8) + (2 * L + c + 1) %% 2 = 2 * j + 9 + c) 1:/#.
  by rewrite (_: 2 * (j + (j %% 8 - j) %% 8) + (2 * L + c + 1) %% 2 = 2 * j + 1 + c) 1:/#.
rewrite (winE _ _ _ _ ((j + 5) %% 8) (2 * L + c - 1) hw) 1,2:/#.
rewrite (winE _ _ _ _ ((j + 1) %% 8) (2 * L + c - 1) hw) 1,2:/#.
rewrite (_: (2 * L + c - 1) %/ 2 = L) 1:/# (_: (2 * L + c) %/ 2 = L) 1:/#.
rewrite (_: 2 * (j + (j %% 8 - j) %% 8) + (2 * L + c) %% 2 = 2 * j + c) 1:/#.
rewrite (_: 2 * (j + ((j + 5) %% 8 - j) %% 8) + (2 * L + c - 1) %% 2 = 2 * j + 9 + c) 1:/#.
by rewrite (_: 2 * (j + ((j + 1) %% 8 - j) %% 8) + (2 * L + c - 1) %% 2 = 2 * j + 1 + c) 1:/#.
qed.

lemma size_lane L m0 m1 : size m0 = 16 => size m1 = 16 => size (lane L m0 m1) = 16.
proof. by rewrite /lane; case: (L = 0). qed.

(* Every slot but j mod 8 keeps its group when the window moves on. *)
lemma grpS j r : 0 <= r < 8 => r <> j %% 8 =>
  j + 1 + (r - (j + 1)) %% 8 = j + (r - j) %% 8.
proof.
move=> hr hne.
have := divz_eq (r - j) 8; have := divz_eq (r - (j + 1)) 8; have := divz_eq j 8.
have : 0 <= (r - j) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
have : 0 <= (r - (j + 1)) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
have : 0 <= j %% 8 < 8 by smt(modz_ge0 ltz_pmod).
smt().
qed.

lemma half1_win x m0 m1 j : winp x m0 m1 j => 0 <= j < 32 => size m0 = 16 => size m1 = 16 =>
  win (BArray256.set256 x (j %% 8) (half1 x j)) m0 m1 (j + 1).
proof.
move=> [ho hp] hj hs0 hs1 r L c hr hL hc.
rewrite gs256; case: (j %% 8 = r) => hjr.
+ rewrite /half1 vpadd64 1:/# ssig1_v 1:/# hp //.
  rewrite (ho ((j + 7) %% 8) L c) 1..4:/#.
  rewrite (_: 2 * (j + ((j + 7) %% 8 - j) %% 8) + c = 2 * j + 16 + c - 2) 1:/#.
  rewrite (_: 2 * (j + 1 + (r - (j + 1)) %% 8) + c = 2 * j + 16 + c) 1:/#.
  rewrite (Wrec _ (2 * j + 16 + c)) 1:size_lane // 1:/#.
  rewrite (_: 2 * j + 16 + c - 7 = 2 * j + 9 + c) 1:/#.
  rewrite (_: 2 * j + 16 + c - 15 = 2 * j + 1 + c) 1:/#.
  by rewrite (_: 2 * j + 16 + c - 16 = 2 * j + c) 1:/#; ring.
by rewrite grpS 1,2:/#; apply ho => // /#.
qed.

(* Group i of the stack table: W_{2i+c} + K_{2i+c} in each half. *)
op wkinv (wk : BArray1280.t) (m0 m1 : W64.t list) (n : int) =
  forall i L c, 0 <= i < n => 0 <= L < 2 => 0 <= c < 2 =>
    BArray1280.get256 wk i \bits64 (2 * L + c)
    = W (lane L m0 m1) (2 * i + c) + nth W64.zero K512 (2 * i + c).

lemma K512_kernel t : 0 <= t < 80 =>
  BArray640.get64 sHA512_K t = nth W64.zero K512 t.
proof.
move=> ht; rewrite BArray640.get64_of_list64 1://.
by congr; rewrite /K512 /=.
qed.

lemma wk_set wk (y : W256.t) m0 m1 n : wkinv wk m0 m1 n => 0 <= n < 40 =>
  (forall L c, 0 <= L < 2 => 0 <= c < 2 => y \bits64 (2 * L + c) = W (lane L m0 m1) (2 * n + c)) =>
  wkinv (BArray1280.set256 wk n (VPADD_4u64 (VPBROADCAST_2u128 (BArray640.get128 sHA512_K n)) y))
        m0 m1 (n + 1).
proof.
move=> hk hn hy i L c hi hL hc.
rewrite BArray1280.get_set256E 1,2:/#.
case: (n = i) => hni.
+ rewrite vpadd64 1:/# vpbroadcast64 1:/# L640.get128_bits64 1:/# hy //.
  rewrite (_: (2 * L + c) %% 2 = c) 1:/# K512_kernel 1:/# -hni.
  by rewrite addrC.
by apply hk => //; smt().
qed.

lemma wk_get wk m0 m1 n i L c : wkinv wk m0 m1 n => 0 <= i < n => 0 <= L < 2 => 0 <= c < 2 =>
  BArray1280.get64 wk (4 * i + 2 * L + c)
  = W (lane L m0 m1) (2 * i + c) + nth W64.zero K512 (2 * i + c).
proof. by move=> hk hi hL hc; rewrite -addzA -L1280.get256_bits64 1:/#; exact hk. qed.
