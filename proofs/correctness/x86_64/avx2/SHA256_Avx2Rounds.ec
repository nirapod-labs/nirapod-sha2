(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2Rounds.ec
 * ====================
 *
 * Functional correctness of the SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_compress.jinc) against FIPS 180-4 section
 * 6.2.2 as spec/FIPS180_SHA2.ec writes it, round and schedule layers.
 * SHA256_Avx2.ec proves the driver and the entry points from them.
 * This file holds:
 *
 *   round_rst      one call of __sha256_avx2_round, scalar part: round t of
 *                  section 6.2.2 step 3 on the rotating slots of v
 *   round_v0 .. v3 its schedule steps (ph = 0, 1, 2, 3) on x[j mod 4]
 *   round_full     both, for ph in {0, 1, 2, 3}
 *   win0_step ..   the three schedule steps move the window from group j
 *                  to group j + 1 (section 6.2.2 step 1)
 *   wk_set, wk_get the W_t + K_t table on the stack
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *
 * Invariants. Working variable k (a = 0 ... h = 7) of round t is in slot
 * (k + 64 - t) mod 8 of v (vis). Between rounds the slot of a lacks the
 * deferred Sigma0, held in s, and m[t mod 2] holds b XOR c (rst). Each
 * 256-bit word of x and wk holds one group of four schedule words per
 * 128-bit half, the low half for the first block and the high half for
 * the second (lane). Before group g, x[r] holds group g + ((r - g) mod 4)
 * (win).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray8 BArray32 BArray128 BArray256 BArray512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes32 Arrays Rounds256.
import SHA256.

clone Arrays.ArrayLanes as L256 with theory A <- BArray256.
clone Arrays.ArrayLanes as L512 with theory A <- BArray512.

(* ------------------------------------------------------------------ *)
(* Rotating working variables                                          *)

op vis (v : BArray32.t) (t : int) (a b c d e f g h : W32.t) =
  BArray32.get32 v (((0 + 64) - t) %% 8) = a /\
  BArray32.get32 v (((1 + 64) - t) %% 8) = b /\
  BArray32.get32 v (((2 + 64) - t) %% 8) = c /\
  BArray32.get32 v (((3 + 64) - t) %% 8) = d /\
  BArray32.get32 v (((4 + 64) - t) %% 8) = e /\
  BArray32.get32 v (((5 + 64) - t) %% 8) = f /\
  BArray32.get32 v (((6 + 64) - t) %% 8) = g /\
  BArray32.get32 v (((7 + 64) - t) %% 8) = h.

lemma sl_get (v : BArray32.t) t k k' x : 0 <= k < 8 => 0 <= k' < 8 =>
  BArray32.get32 (BArray32.set32 v (((k + 64) - t) %% 8) x) (((k' + 64) - t) %% 8)
  = if k = k' then x else BArray32.get32 v (((k' + 64) - t) %% 8).
proof.
move=> hk hk'; rewrite BArray32.get_set32E 1,2:/#.
by congr; apply eq_iff; smt().
qed.

lemma vis_set0 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray32.set32 v (((0 + 64) - t) %% 8) x) t x b c d e f g h.
proof. by rewrite /vis !sl_get. qed.

lemma vis_set3 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray32.set32 v (((3 + 64) - t) %% 8) x) t a b c x e f g h.
proof. by rewrite /vis !sl_get. qed.

lemma vis_set7 v t a b c d e f g h x : vis v t a b c d e f g h =>
  vis (BArray32.set32 v (((7 + 64) - t) %% 8) x) t a b c d e f g x.
proof. by rewrite /vis !sl_get. qed.

lemma vis_next v t a b c d e f g h : vis v t a b c d e f g h =>
  vis v (t + 1) h a b c d e f g.
proof.
rewrite /vis => [#] <- <- <- <- <- <- <- <-.
by do !split; congr; smt().
qed.

lemma m_get (m : BArray8.t) t x :
  BArray8.get32 (BArray8.set32 m (t %% 2) x) ((t + 1) %% 2) = BArray8.get32 m ((t + 1) %% 2).
proof. by rewrite BArray8.get_set32E 1,2:/#; smt(). qed.

lemma m_get' (m : BArray8.t) t x :
  BArray8.get32 (BArray8.set32 m ((t + 1) %% 2) x) (t %% 2) = BArray8.get32 m (t %% 2).
proof. by rewrite BArray8.get_set32E 1,2:/#; smt(). qed.

lemma m_setp (m : BArray8.t) t x : BArray8.get32 (BArray8.set32 m (t %% 2) x) (t %% 2) = x.
proof. by rewrite BArray8.get_set32E 1,2:/#. qed.

lemma m_setq (m : BArray8.t) t x :
  BArray8.get32 (BArray8.set32 m ((t + 1) %% 2) x) ((t + 1) %% 2) = x.
proof. by rewrite BArray8.get_set32E 1,2:/#. qed.

(* ------------------------------------------------------------------ *)
(* Scalar round                                                        *)

lemma round_scalar (a0 b c d e f g h0 s0 mp : W32.t) (t0 : int) :
  hoare [M.__sha256_avx2_round :
    t = t0 /\ s = s0 /\ vis v t a0 b c d e f g h0 /\ BArray8.get32 m (t %% 2) = mp ==>
    let a = a0 + s0 in
    let t1 = h0 + (f `&` e) + (ANDN_32 e g).`6
             + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6)) in
    vis res.`1 t0 a b c (d + t1) e f g (t1 + ((mp `&` (a +^ b)) +^ b)) /\
    res.`3 = RORX_32 a (W8.of_int 13) +^ RORX_32 a (W8.of_int 22) +^ RORX_32 a (W8.of_int 2) /\
    BArray8.get32 res.`2 ((t0 + 1) %% 2) = a +^ b].
proof.
proc.
seq 4 : (t = t0 /\ vis v t (a0 + s0) b c d e f g h0 /\ BArray8.get32 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> -> hv hm.
  have := vis_set0 _ _ _ _ _ _ _ _ _ _ (a0 + s0) hv.
  have -> : BArray32.get32 v{hr} (((0 + 64) - t0) %% 8) = a0 by move: hv => @/vis [#].
  smt().
seq 7 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e)) /\
         z = RORX_32 e (W8.of_int 25) /\ w = RORX_32 e (W8.of_int 11) /\
         BArray8.get32 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e)) hv.
  move: hv => @/vis [#] _ _ _ _ -> -> _ ->.
  smt().
seq 8 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e) + (ANDN_32 e g).`6) /\
         z = RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) /\
         w = RORX_32 e (W8.of_int 6) /\ BArray8.get32 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv -> -> hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e) + (ANDN_32 e g).`6) hv.
  move: hv => @/vis [#] _ _ _ _ -> _ -> ->.
  smt().
seq 7 : (t = t0 /\ vis v t (a0 + s0) b c d e f g (h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6))) /\
         BArray8.get32 m ((t + 1) %% 2) = (a0 + s0) /\ y = RORX_32 (a0 + s0) (W8.of_int 22) /\
         BArray8.get32 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv -> -> hm.
  have := vis_set7 _ _ _ _ _ _ _ _ _ _ (h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6))) hv.
  move: hv => @/vis [#] -> _ _ _ _ _ _ ->.
  rewrite m_setq m_get' hm; smt().
seq 6 : (t = t0 /\ vis v t (a0 + s0) b c (d + (h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6)))) e f g (h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6))) /\
         BArray8.get32 m ((t + 1) %% 2) = (a0 + s0) +^ b /\ y = RORX_32 (a0 + s0) (W8.of_int 22) /\
         s = RORX_32 (a0 + s0) (W8.of_int 13) /\ z = RORX_32 (a0 + s0) (W8.of_int 2) /\
         BArray8.get32 m (t %% 2) = mp).
+ wp; skip => &hr /= [#] -> hv hq -> hm.
  have := vis_set3 _ _ _ _ _ _ _ _ _ _ (d + (h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6)))) hv.
  move: hv => @/vis [#] -> -> _ -> _ _ _ ->.
  rewrite m_setq hq m_get' hm; smt().
wp; skip => &hr /= [#] -> hv hq -> -> -> hm.
have := vis_set7 _ _ _ _ _ _ _ _ _ _ ((h0 + (f `&` e) + (ANDN_32 e g).`6 + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6))) + ((mp `&` ((a0 + s0) +^ b)) +^ b)) hv.
move: hv => @/vis [#] _ -> _ _ _ _ _ ->.
rewrite !m_setp !m_get hm hq; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The round against section 6.2.2, step 3                            *)

op rst (v : BArray32.t) (m : BArray8.t) (s : W32.t) (st : state) (t : int) =
  vis v t (st.`1 - s) st.`2 st.`3 st.`4 st.`5 st.`6 st.`7 st.`8 /\
  BArray8.get32 m (t %% 2) = st.`2 +^ st.`3.

op rinw (v : BArray32.t) (m : BArray8.t) (s : W32.t) (w : W32.t list) (st : state) (t : int) =
  vis v t (st.`1 - s) st.`2 st.`3 st.`4 st.`5 st.`6 st.`7
      (st.`8 + nth W32.zero K256 t + nth W32.zero w t) /\
  BArray8.get32 m (t %% 2) = st.`2 +^ st.`3.

lemma vis_eq v t a b c d e f g h a' e' : a = a' => e = e' =>
  vis v t a b c d e f g h => vis v t a' b c d e' f g h.
proof. by move=> -> ->. qed.

lemma xor3r (a b c : W32.t) : a +^ b +^ c = c +^ b +^ a.
proof. by rewrite W32.xorwC (W32.xorwC a) W32.xorwA. qed.

lemma xor3l (a b c : W32.t) : a +^ b +^ c = c +^ a +^ b.
proof. by rewrite W32.xorwC W32.xorwA. qed.

lemma t1E (h e f g : W32.t) :
  h + (f `&` e) + (ANDN_32 e g).`6
  + (RORX_32 e (W8.of_int 25) +^ RORX_32 e (W8.of_int 11) +^ RORX_32 e (W8.of_int 6))
  = h + bsig1 e + ch e f g.
proof. by rewrite ANDN_32E !RORX_32E // /bsig1 xor3r -ch_bmi32; ring. qed.

lemma s0E (a : W32.t) :
  RORX_32 a (W8.of_int 13) +^ RORX_32 a (W8.of_int 22) +^ RORX_32 a (W8.of_int 2) = bsig0 a.
proof. by rewrite !RORX_32E // /bsig0 xor3l. qed.

lemma round_rst (w : W32.t list) (st : state) (t0 : int) :
  hoare [M.__sha256_avx2_round :
    t = t0 /\ rinw v m s w st t ==> rst res.`1 res.`2 res.`3 (round w st t0) (t0 + 1)].
proof.
case: st => a b c d e f g h.
exlim s => s0.
conseq (round_scalar (a - s0) b c d e f g (h + nth W32.zero K256 t0 + nth W32.zero w t0)
          s0 (b +^ c) t0).
+ by move=> &hr; rewrite /rinw /=; smt().
move=> &hr _ [v' m' s' x'] /=.
have -> : a - s0 + s0 = a by ring.
move=> [#] hv -> hq; rewrite /rst /round /=; split; last by rewrite hq.
apply (vis_eq _ _ _ _ _ _ _ _ _ _ _ _ _ _ (vis_next _ _ _ _ _ _ _ _ _ _ hv)).
+ by rewrite maj_bmi32 t1E s0E; ring.
by rewrite t1E; ring.
qed.

(* ------------------------------------------------------------------ *)
(* Schedule steps                                                      *)

lemma gs256 (x : BArray128.t) j a r :
  BArray128.get256 (BArray128.set256 x (j %% 4) a) r
  = if j %% 4 = r then a else BArray128.get256 x r.
proof. by rewrite BArray128.get_set256E 1,2:/#. qed.

lemma ss256 (x : BArray128.t) j a b :
  BArray128.set256 (BArray128.set256 x (j %% 4) a) (j %% 4) b = BArray128.set256 x (j %% 4) b.
proof. by apply BArray128.ext_eq => r hr; rewrite !BArray128.get8_set256dE; smt(). qed.

(* ph = 0: x[j] gains W_{t-7} and sigma0 of W_{t-15}, four lanes per half. *)
op half0 (x : BArray128.t) (j : int) : W256.t =
  VPADD_8u32
    (VPADD_8u32 (BArray128.get256 x (j %% 4))
       (VPALIGNR_256 (BArray128.get256 x ((j + 3) %% 4)) (BArray128.get256 x ((j + 2) %% 4))
          (W8.of_int 4)))
    (vsig0w (VPALIGNR_256 (BArray128.get256 x ((j + 1) %% 4)) (BArray128.get256 x (j %% 4))
          (W8.of_int 4))).

(* ph = 1: lanes 0 and 1 of each half gain sigma1 of x[j + 3] lanes 2, 3. *)
op half1 (x : BArray128.t) (lo : W256.t) (j : int) : W256.t =
  VPADD_8u32 (BArray128.get256 x (j %% 4))
    (VPSHUFB_256 (vsig1w (VPSHUFD_256 (BArray128.get256 x ((j + 3) %% 4)) (W8.of_int 250))) lo).

(* ph = 2: lanes 2 and 3 gain sigma1 of the lanes 0, 1 just completed. *)
op half2 (x : BArray128.t) (hi : W256.t) (j : int) : W256.t =
  VPADD_8u32 (BArray128.get256 x (j %% 4))
    (VPSHUFB_256 (vsig1w (VPSHUFD_256 (BArray128.get256 x (j %% 4)) (W8.of_int 80))) hi).

lemma round_v0 (x0 : BArray128.t) (j0 : int) :
  hoare [M.__sha256_avx2_round : ph = 0 /\ x = x0 /\ j = j0 ==>
    res.`4 = BArray128.set256 x0 (j0 %% 4) (half0 x0 j0)].
proof.
proc.
rcondt ^if; first by auto. rcondf ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto. rcondf ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondt ^if; first by auto.
wp; skip => &hr /= [#] _ -> ->.
by rewrite ss256 gs256 /= /half0 /vsig0w.
qed.

lemma round_v1 (x0 : BArray128.t) (lo0 : W256.t) (j0 : int) :
  hoare [M.__sha256_avx2_round : ph = 1 /\ x = x0 /\ lo = lo0 /\ j = j0 ==>
    res.`4 = BArray128.set256 x0 (j0 %% 4) (half1 x0 lo0 j0)].
proof.
proc.
rcondf ^if; first by auto. rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto. rcondf ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto.
wp; skip => &hr /= [#] _ -> -> ->.
by rewrite /half1 /vsig1w.
qed.

lemma round_v2 (x0 : BArray128.t) (hi0 : W256.t) (j0 : int) :
  hoare [M.__sha256_avx2_round : ph = 2 /\ x = x0 /\ hi = hi0 /\ j = j0 ==>
    res.`4 = BArray128.set256 x0 (j0 %% 4) (half2 x0 hi0 j0)].
proof.
proc.
rcondf ^if; first by auto. rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto. rcondt ^if; first by auto.
rcondf ^if; first by auto.
wp; skip => &hr /= [#] _ -> -> ->.
by rewrite /half2 /vsig1w.
qed.

lemma round_v3 (x0 : BArray128.t) :
  hoare [M.__sha256_avx2_round : ph = 3 /\ x = x0 ==> res.`4 = x0].
proof.
proc.
do 15!(rcondf ^if; first by auto).
by wp; skip => &hr /= [#] _ ->.
qed.

op xnext (x : BArray128.t) (lo hi : W256.t) (j ph : int) : BArray128.t =
  if ph = 0 then BArray128.set256 x (j %% 4) (half0 x j)
  else if ph = 1 then BArray128.set256 x (j %% 4) (half1 x lo j)
  else if ph = 2 then BArray128.set256 x (j %% 4) (half2 x hi j) else x.

lemma round_full (w : W32.t list) (st : state) (t0 : int) (x0 : BArray128.t) (lo0 hi0 : W256.t)
                 (j0 p0 : int) :
  p0 = 0 \/ p0 = 1 \/ p0 = 2 \/ p0 = 3 =>
  hoare [M.__sha256_avx2_round :
    t = t0 /\ rinw v m s w st t /\ x = x0 /\ lo = lo0 /\ hi = hi0 /\ j = j0 /\ ph = p0 ==>
    rst res.`1 res.`2 res.`3 (round w st t0) (t0 + 1) /\ res.`4 = xnext x0 lo0 hi0 j0 p0].
proof.
move=> [hp|[hp|[hp|hp]]].
+ proc*.
  conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
         (_: ph = 0 /\ x = x0 /\ j = j0 ==> r.`4 = BArray128.set256 x0 (j0 %% 4) (half0 x0 j0)).
  + by move=> &hr /= [#] -> hr -> hl hh hj hph; rewrite hph hp /= hr ?hj.
  + by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
  + by call (round_v0 x0 j0); auto.
  by call (round_rst w st t0); auto.
+ proc*.
  conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
         (_: ph = 1 /\ x = x0 /\ lo = lo0 /\ j = j0 ==>
             r.`4 = BArray128.set256 x0 (j0 %% 4) (half1 x0 lo0 j0)).
  + by move=> &hr /= [#] -> hr -> hl hh hj hph; rewrite hph hp /= hr ?hj ?hl.
  + by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
  + by call (round_v1 x0 lo0 j0); auto.
  by call (round_rst w st t0); auto.
+ proc*.
  conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
         (_: ph = 2 /\ x = x0 /\ hi = hi0 /\ j = j0 ==>
             r.`4 = BArray128.set256 x0 (j0 %% 4) (half2 x0 hi0 j0)).
  + by move=> &hr /= [#] -> hr -> hl hh hj hph; rewrite hph hp /= hr ?hj ?hh.
  + by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
  + by call (round_v2 x0 hi0 j0); auto.
  by call (round_rst w st t0); auto.
proc*.
conseq (_: t = t0 /\ rinw v m s w st t ==> rst r.`1 r.`2 r.`3 (round w st t0) (t0 + 1))
       (_: ph = 3 /\ x = x0 ==> r.`4 = x0).
+ by move=> &hr /= [#] -> hr -> hl hh hj hph; rewrite hph hp /= hr.
+ by move=> &hr _ rr [h1 h2]; split; [exact h1 | rewrite /xnext hp /= h2].
+ by call (round_v3 x0); auto.
by call (round_rst w st t0); auto.
qed.

(* __sha256_avx2_round with its phase in the precondition, for ecall. *)
lemma round_call (w : W32.t list) (st : state) (t0 : int) (x0 : BArray128.t) (lo0 hi0 : W256.t)
                 (j0 p0 : int) :
  hoare [M.__sha256_avx2_round :
    (p0 = 0 \/ p0 = 1 \/ p0 = 2 \/ p0 = 3) /\ t = t0 /\ rinw v m s w st t /\ x = x0 /\
    lo = lo0 /\ hi = hi0 /\ j = j0 /\ ph = p0 ==>
    rst res.`1 res.`2 res.`3 (round w st t0) (t0 + 1) /\ res.`4 = xnext x0 lo0 hi0 j0 p0].
proof.
case: (p0 = 0 \/ p0 = 1 \/ p0 = 2 \/ p0 = 3) => hp.
+ by conseq (round_full w st t0 x0 lo0 hi0 j0 p0 hp).
by conseq (_: false ==> _) => //; proc; exfalso.
qed.

(* ------------------------------------------------------------------ *)
(* The schedule window and the W + K table                             *)

op W (m : W32.t list) (t : int) : W32.t = nth W32.zero (schedule m) t.

(* 128-bit half L of every vector belongs to block L. *)
op lane (L : int) (m0 m1 : W32.t list) : W32.t list = if L = 0 then m0 else m1.

lemma size_lane L m0 m1 : size m0 = 16 => size m1 = 16 => size (lane L m0 m1) = 16.
proof. by rewrite /lane; case: (L = 0). qed.

lemma Wrec m t : size m = 16 => 16 <= t < 64 =>
  W m t = ssig1 (W m (t - 2)) + W m (t - 7) + ssig0 (W m (t - 15)) + W m (t - 16).
proof. by move=> hm ht; rewrite /W nth_schedule_hi. qed.

(* Before group g: x[r] holds group g + ((r - g) mod 4), the words
   W_{4i} .. W_{4i+3} of that group i in each half. *)
op win (x : BArray128.t) (m0 m1 : W32.t list) (g : int) =
  forall r L c, 0 <= r < 4 => 0 <= L < 2 => 0 <= c < 4 =>
    BArray128.get256 x r \bits32 (4 * L + c) = W (lane L m0 m1) (4 * (g + (r - g) %% 4) + c).

(* The partial sum of group j + 4 that the first step leaves in x[j mod 4]. *)
op part (m : W32.t list) (j c : int) : W32.t = W m (4 * j + c) + W m (4 * j + 9 + c) + ssig0 (W m (4 * j + 1 + c)).

op others (x : BArray128.t) (m0 m1 : W32.t list) (j : int) =
  forall r L c, 0 <= r < 4 => r <> j %% 4 => 0 <= L < 2 => 0 <= c < 4 =>
    BArray128.get256 x r \bits32 (4 * L + c) = W (lane L m0 m1) (4 * (j + (r - j) %% 4) + c).

(* After the first step (ph = 0) of group j + 4. *)
op win0 (x : BArray128.t) (m0 m1 : W32.t list) (j : int) =
  others x m0 m1 j /\
  forall L c, 0 <= L < 2 => 0 <= c < 4 =>
    BArray128.get256 x (j %% 4) \bits32 (4 * L + c) = part (lane L m0 m1) j c.

(* After the second step (ph = 1): lanes 0 and 1 of each half complete. *)
op win1 (x : BArray128.t) (m0 m1 : W32.t list) (j : int) =
  others x m0 m1 j /\
  forall L c, 0 <= L < 2 => 0 <= c < 4 =>
    BArray128.get256 x (j %% 4) \bits32 (4 * L + c)
    = if c < 2 then W (lane L m0 m1) (4 * j + 16 + c) else part (lane L m0 m1) j c.

lemma m4 j : 0 <= j %% 4 < 4.
proof. by apply modz_cmp. qed.

lemma m4off j k : 0 <= k < 4 => ((j + k) %% 4 - j) %% 4 = k.
proof. by move=> hk; rewrite modzDml (_: j + k - j = k) 1:/# pmod_small. qed.

lemma m4off0 j : (j %% 4 - j) %% 4 = 0.
proof. by rewrite modzDml subrr mod0z. qed.

lemma m4ne j k : 0 < k < 4 => (j + k) %% 4 <> j %% 4.
proof. by move=> hk; apply/negP => heq; have := m4off j k _; [smt() | rewrite heq m4off0 /#]. qed.

lemma m4m1 j : (j %% 4 - (j + 1)) %% 4 = 3.
proof. rewrite modzDml (_: j - (j + 1) = -1) 1:/#; smt(). qed.

lemma lc8 L c : 0 <= L < 2 => 0 <= c < 4 => 0 <= 4 * L + c < 8.
proof. smt(). qed.

lemma lcdiv L c : 0 <= c < 4 => (4 * L + c) %/ 4 = L /\ (4 * L + c) %% 4 = c.
proof. by move=> hc; smt(). qed.

lemma winE x m0 m1 g r L c : win x m0 m1 g => 0 <= r < 4 => 0 <= L < 2 => 0 <= c < 4 =>
  BArray128.get256 x r \bits32 (4 * L + c) = W (lane L m0 m1) (4 * (g + (r - g) %% 4) + c).
proof. by move=> hw; exact hw. qed.

lemma half0_win x m0 m1 j : win x m0 m1 j =>
  win0 (BArray128.set256 x (j %% 4) (half0 x j)) m0 m1 j.
proof.
move=> hw; split.
+ move=> r L c hr hne hL hc; rewrite gs256 ifF 1:/#; exact hw.
move=> L c hL hc; have [hd hm] := lcdiv L c hc.
rewrite gs256 /= /half0 !(vpadd32 _ _ _ (lc8 _ _ hL hc)) ssig0_w 1:(lc8 _ _ hL hc).
rewrite !(vpalignr4_32 _ _ _ (lc8 _ _ hL hc)) hm.
rewrite (hw (j %% 4) L c (m4 j) hL hc) m4off0 /part.
case: (c < 3) => hc3.
+ rewrite (_: 4 * L + c + 1 = 4 * L + (c + 1)) 1:/#.
  rewrite (hw ((j + 2) %% 4) L (c + 1) (m4 _) hL _) 1:/# (m4off j 2) //.
  rewrite (hw (j %% 4) L (c + 1) (m4 _) hL _) 1:/# m4off0.
  have -> : 4 * (j + 2) + (c + 1) = 4 * j + 9 + c by ring.
  by have -> : 4 * (j + 0) + (c + 1) = 4 * j + 1 + c by ring.
have hc' : c = 3 by smt().
rewrite (_: 4 * L + c - 3 = 4 * L + 0) 1:/#.
rewrite (hw ((j + 3) %% 4) L 0 (m4 _) hL _) 1:// (m4off j 3) //.
rewrite (hw ((j + 1) %% 4) L 0 (m4 _) hL _) 1:// (m4off j 1) //.
rewrite hc'; have -> : 4 * (j + 3) + 0 = 4 * j + 9 + 3 by ring.
by have -> : 4 * (j + 1) + 0 = 4 * j + 1 + 3 by ring.
qed.

(* The complete word 4j + 16 + c from its partial sum and sigma1. *)
lemma part_done m j c : size m = 16 => 0 <= j < 12 => 0 <= c < 4 =>
  part m j c + ssig1 (W m (4 * j + 14 + c)) = W m (4 * j + 16 + c).
proof.
move=> hm hj hc; rewrite /part (Wrec m (4 * j + 16 + c) hm) 1:/#.
have -> : 4 * j + 16 + c - 2 = 4 * j + 14 + c by ring.
have -> : 4 * j + 16 + c - 7 = 4 * j + 9 + c by ring.
have -> : 4 * j + 16 + c - 15 = 4 * j + 1 + c by ring.
have -> : 4 * j + 16 + c - 16 = 4 * j + c by ring.
by ring.
qed.

lemma idx_fa L c : 0 <= L < 2 => 0 <= c < 2 =>
  4 * ((2 * (2 * L + c)) %/ 4) + 2 + ((2 * (2 * L + c)) %% 4) %/ 2 = 4 * L + (2 + c) /\
  4 * ((2 * (2 * L + c) + 1) %/ 4) + 2 + ((2 * (2 * L + c) + 1) %% 4) %/ 2 = 4 * L + (2 + c).
proof.
move=> hL hc; have hL' : L = 0 \/ L = 1 by smt().
have hc' : c = 0 \/ c = 1 by smt().
by case: hL' => ->; case: hc' => ->.
qed.

lemma idx_50 L c : 0 <= L < 2 => 2 <= c < 4 =>
  4 * ((2 * (2 * L + (c - 2))) %/ 4) + ((2 * (2 * L + (c - 2))) %% 4) %/ 2 = 4 * L + (c - 2) /\
  4 * ((2 * (2 * L + (c - 2)) + 1) %/ 4) + ((2 * (2 * L + (c - 2)) + 1) %% 4) %/ 2 = 4 * L + (c - 2).
proof.
move=> hL hc; have hL' : L = 0 \/ L = 1 by smt().
have hc' : c = 2 \/ c = 3 by smt().
by case: hL' => ->; case: hc' => ->.
qed.

lemma half1_win x m0 m1 lo j : twice lo lo_mask128 => size m0 = 16 => size m1 = 16 => 0 <= j < 12 =>
  win0 x m0 m1 j => win1 (BArray128.set256 x (j %% 4) (half1 x lo j)) m0 m1 j.
proof.
move=> hlo hs0 hs1 hj [ho hp]; split.
+ move=> r L c hr hne hL hc; rewrite gs256 ifF 1:/#; exact ho.
move=> L c hL hc; have [hd hm] := lcdiv L c hc.
rewrite gs256 /= /half1 (vpadd32 _ _ _ (lc8 _ _ hL hc)) (vpshufb_lo _ _ _ (lc8 _ _ hL hc) hlo) hd hm hp //.
case: (c < 2) => hc2; last by rewrite addr0.
have hq : 0 <= 2 * L + c < 4 by smt().
rewrite (_: 4 * L + 2 * c = 2 * (2 * L + c)) 1:/#.
have [i0 i1] := idx_fa L c hL _; 1: smt().
rewrite (ssig1_w _ _ hq); 1: by rewrite (vpshufd_fa _ (2 * (2 * L + c))) 1:/# (vpshufd_fa _ (2 * (2 * L + c) + 1)) 1:/# i0 i1.
rewrite vpshufd_fa 1:/# i0.
rewrite (ho ((j + 3) %% 4) L (2 + c) (m4 _) (m4ne j 3 _) hL _) 1,2:/# (m4off j 3) //.
have -> : 4 * (j + 3) + (2 + c) = 4 * j + 14 + c by ring.
by rewrite part_done // size_lane.
qed.

(* Every slot but j mod 4 keeps its group when the window moves on. *)
lemma grpS4 j r : 0 <= r < 4 => r <> j %% 4 =>
  j + 1 + (r - (j + 1)) %% 4 = j + (r - j) %% 4.
proof.
move=> hr hne.
have := divz_eq (r - j) 4; have := divz_eq (r - (j + 1)) 4; have := divz_eq j 4.
have : 0 <= (r - j) %% 4 < 4 by smt(modz_ge0 ltz_pmod).
have : 0 <= (r - (j + 1)) %% 4 < 4 by smt(modz_ge0 ltz_pmod).
have : 0 <= j %% 4 < 4 by smt(modz_ge0 ltz_pmod).
smt().
qed.

lemma half2_win x m0 m1 hi j : twice hi hi_mask128 => size m0 = 16 => size m1 = 16 => 0 <= j < 12 =>
  win1 x m0 m1 j => win (BArray128.set256 x (j %% 4) (half2 x hi j)) m0 m1 (j + 1).
proof.
move=> hhi hs0 hs1 hj [ho hp] r L c hr hL hc.
rewrite gs256; case: (j %% 4 = r) => hjr; last first.
+ have hne : r <> j %% 4 by smt().
  by rewrite grpS4 //; apply ho.
rewrite -hjr m4m1 /half2 (vpadd32 _ _ _ (lc8 _ _ hL hc)) (vpshufb_hi _ _ _ (lc8 _ _ hL hc) hhi).
have [hd hm] := lcdiv L c hc; rewrite hd hm (hp L c hL hc).
have -> : 4 * (j + 1 + 3) + c = 4 * j + 16 + c by ring.
case: (c < 2) => hc2.
+ by rewrite ifF 1:/# addr0.
rewrite ifT 1:/#.
have hq : 0 <= 2 * L + (c - 2) < 4 by smt().
have [i0 i1] := idx_50 L c hL _; 1: smt().
rewrite (_: 4 * L + 2 * (c - 2) = 2 * (2 * L + (c - 2))) 1:/#.
rewrite (ssig1_w _ _ hq); 1: by rewrite (vpshufd_50 _ (2 * (2 * L + (c - 2)))) 1:/# (vpshufd_50 _ (2 * (2 * L + (c - 2)) + 1)) 1:/# i0 i1.
rewrite vpshufd_50 1:/# i0 (hp L (c - 2) hL _) 1:/# ifT 1:/#.
have -> : 4 * j + 16 + (c - 2) = 4 * j + 14 + c by ring.
by rewrite part_done // size_lane.
qed.
