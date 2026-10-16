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

(* Group i of the stack table: W_{4i+c} + K_{4i+c} in each half. *)
op wkinv (wk : BArray512.t) (m0 m1 : W32.t list) (n : int) =
  forall i L c, 0 <= i < n => 0 <= L < 2 => 0 <= c < 4 =>
    BArray512.get256 wk i \bits32 (4 * L + c)
    = W (lane L m0 m1) (4 * i + c) + nth W32.zero K256 (4 * i + c).

lemma K256_kernel t : 0 <= t < 64 =>
  BArray256.get32 sHA256_K t = nth W32.zero K256 t.
proof.
move=> ht; rewrite BArray256.get32_of_list32 1://.
by congr; rewrite /K256 /=.
qed.

(* The table is a parameter kt rather than the model's sHA256_K, which is
   an abbreviation of a 64-entry literal: simplifying a goal that holds it
   is slow. Callers instantiate kt with sHA256_K and hK with K256_kernel. *)
lemma wk_set wk (kt : BArray256.t) (y : W256.t) m0 m1 n :
  (forall t, 0 <= t < 64 => BArray256.get32 kt t = nth W32.zero K256 t) =>
  wkinv wk m0 m1 n => 0 <= n < 16 =>
  (forall L c, 0 <= L < 2 => 0 <= c < 4 => y \bits32 (4 * L + c) = W (lane L m0 m1) (4 * n + c)) =>
  wkinv (BArray512.set256 wk n (VPADD_8u32 (VPBROADCAST_2u128 (BArray256.get128 kt n)) y))
        m0 m1 (n + 1).
proof.
move=> hK hk hn hy i L c hi hL hc.
rewrite BArray512.get_set256E 1,2:/#.
case: (n = i) => hni.
+ have [_ hm] := lcdiv L c hc.
  rewrite (vpadd32 _ _ _ (lc8 _ _ hL hc)) (vpbroadcast32 _ _ (lc8 _ _ hL hc)) hm.
  rewrite (L256.get128_bits32 _ _ _ hc) (hy _ _ hL hc).
  have h64 : 0 <= 4 * n + c < 64 by move: hn hc; clear hk hy hK; smt().
  by rewrite (hK _ h64) -hni addrC.
have hin : 0 <= i < n by move: hi hni; clear hk hy hK; smt().
by apply hk.
qed.

lemma wk_get wk m0 m1 n i L c : wkinv wk m0 m1 n => 0 <= i < n => 0 <= L < 2 => 0 <= c < 4 =>
  BArray512.get32 wk (8 * i + 4 * L + c)
  = W (lane L m0 m1) (4 * i + c) + nth W32.zero K256 (4 * i + c).
proof.
move=> hk hi hL hc; rewrite -addzA -L512.get256_bits32 1:/#; exact hk.
qed.

(* ------------------------------------------------------------------ *)
(* One iteration of the round loop                                     *)

lemma d4s t : t %% 4 < 3 => (t + 1) %/ 4 = t %/ 4 /\ (t + 1) %% 4 = t %% 4 + 1.
proof.
move=> h; have := divz_eq t 4; have := divz_eq (t + 1) 4.
have := modz_cmp (t + 1) 4; have := modz_cmp t 4; smt().
qed.

lemma d4w t : t %% 4 = 3 => (t + 1) %/ 4 = t %/ 4 + 1 /\ (t + 1) %% 4 = 0.
proof.
move=> h; have := divz_eq t 4; have := divz_eq (t + 1) 4.
have := modz_cmp (t + 1) 4; smt().
qed.

lemma d4b t : 0 <= t =>
  0 <= t %/ 4 /\ 4 * (t %/ 4) <= t /\ 4 * (t %/ 4) + t %% 4 = t /\ 0 <= t %% 4 < 4.
proof. move=> ht; have := divz_eq t 4; have := modz_cmp t 4; smt(). qed.

(* Number of table groups written before round t of the first block. *)
op wkn (t : int) : int = if t <= 48 then 4 + (t + 1) %/ 4 else 16.

(* Window and table state before round t of the first block. *)
op xw (x : BArray128.t) (wk : BArray512.t) (m0 m1 : W32.t list) (t : int) =
  wkinv wk m0 m1 (wkn t) /\
  (t < 48 =>
     if t %% 4 = 0 then win x m0 m1 (t %/ 4)
     else if t %% 4 = 1 then win0 x m0 m1 (t %/ 4)
     else if t %% 4 = 2 then win1 x m0 m1 (t %/ 4)
     else win x m0 m1 (t %/ 4 + 1)).

(* The table entry written after round t: group 4 + t / 4. *)
op wknext (kt : BArray256.t) (x : BArray128.t) (wk : BArray512.t) (t : int) : BArray512.t =
  BArray512.set256 wk (4 + t %/ 4)
    (VPADD_8u32 (VPBROADCAST_2u128 (BArray256.get128 kt (4 + t %/ 4)))
       (BArray128.get256 x ((t %/ 4) %% 4))).

lemma xw_nw x wk m0 m1 lo hi t :
  twice lo lo_mask128 => size m0 = 16 => size m1 = 16 =>
  xw x wk m0 m1 t => 0 <= t < 48 => t %% 4 <> 2 =>
  xw (xnext x lo hi (t %/ 4) (t %% 4)) wk m0 m1 (t + 1).
proof.
move=> hlo hs0 hs1 [hk hw] ht hn2.
have [hj0 [hj1 [hj2 hr]]] := d4b t _; 1: smt().
have hw' := hw _; 1: smt().
case: (t %% 4 = 3) => h3.
+ have [hd hm] := d4w t h3.
  have [e2 _] := d4s (t + 1) _; 1: by rewrite hm.
  rewrite /xnext h3 /=; split.
  + by move: hk; rewrite /wkn !ifT 1,2:/# e2.
  by move=> _; move: hw'; rewrite h3 hm hd.
have hlt : t %% 4 < 3 by smt().
have [hd hm] := d4s t hlt.
have hwk : wkinv wk m0 m1 (wkn (t + 1)).
+ have [e2 _] := d4s (t + 1) _; 1: by rewrite hm; smt().
  by move: hk; rewrite /wkn !ifT 1,2:/# e2.
case: (t %% 4 = 0) => h0.
+ rewrite /xnext h0 /=; split; 1: exact hwk.
  move=> _; rewrite hm h0 /= hd; apply half0_win.
  by move: hw'; rewrite h0.
have h1 : t %% 4 = 1 by smt().
rewrite /xnext h1 /=; split; 1: exact hwk.
have hj12 : 0 <= t %/ 4 < 12 by move: ht hj0 hj1; clear hw hw' hk hwk; smt().
move=> _; rewrite hm h1 /= hd; apply half1_win => //.
by move: hw'; rewrite h1.
qed.

lemma xw_w kt x wk m0 m1 lo hi t :
  (forall t, 0 <= t < 64 => BArray256.get32 kt t = nth W32.zero K256 t) =>
  twice hi hi_mask128 => size m0 = 16 => size m1 = 16 =>
  xw x wk m0 m1 t => 0 <= t < 48 => t %% 4 = 2 =>
  xw (xnext x lo hi (t %/ 4) (t %% 4)) (wknext kt (xnext x lo hi (t %/ 4) (t %% 4)) wk t) m0 m1 (t + 1).
proof.
move=> hK hhi hs0 hs1 [hk hw] ht h2.
have [hj0 [hj1 [hj2 hr]]] := d4b t _; 1: smt().
have [hd hm] := d4s t _; 1: by rewrite h2.
have hj12 : 0 <= t %/ 4 < 12 by move: ht hj0 hj1; clear hw hk hK; smt().
have hw1 : win1 x m0 m1 (t %/ 4) by move: (hw _); [smt() | rewrite h2].
have hwn := half2_win x m0 m1 hi (t %/ 4) hhi hs0 hs1 hj12 hw1.
have [e2 _] := d4w (t + 1) _; 1: by rewrite hm h2.
rewrite /xnext h2 /=; split; last by move=> _; rewrite hm h2 /= hd.
rewrite /wkn ifT 1:/# e2 hd.
have -> : 4 + (t %/ 4 + 1) = 4 + t %/ 4 + 1 by ring.
rewrite /wknext.
have := wk_set wk kt (BArray128.get256 (BArray128.set256 x (t %/ 4 %% 4) (half2 x hi (t %/ 4))) (t %/ 4 %% 4))
          m0 m1 (4 + t %/ 4) hK.
move=> H; apply H.
+ by move: hk; rewrite /wkn ifT 1:/# hd.
+ by move: hj12; clear hw hk hK hwn H; smt().
move=> L c hL hc; rewrite (hwn (t %/ 4 %% 4) L c (m4 _) hL hc) m4m1.
by have -> : 4 * (t %/ 4 + 1 + 3) + c = 4 * (4 + t %/ 4) + c by ring.
qed.

lemma xw_late x wk m0 m1 lo hi t : xw x wk m0 m1 t => 48 <= t < 64 =>
  xw (xnext x lo hi 0 3) wk m0 m1 (t + 1).
proof.
move=> [hk _] ht; rewrite /xnext /=; split; last by rewrite (_: (t + 1 < 48) = false) 1:/#.
have e0 : wkn t = 16 by rewrite /wkn; case: (t <= 48) => h; [have -> : t = 48 by smt() | ].
have e1 : wkn (t + 1) = 16 by rewrite /wkn ifF 1:/#.
by move: hk; rewrite e0 e1.
qed.

(* Loop state of the round loop of block l, apart from the working
   variables. *)
op tctx (x : BArray128.t) (wk : BArray512.t) (m0 m1 : W32.t list) (lo hi : W256.t) (l t : int) =
  0 <= t <= 64 /\ 0 <= l < 2 /\ size m0 = 16 /\ size m1 = 16 /\
  twice lo lo_mask128 /\ twice hi hi_mask128 /\
  (if l = 0 then xw x wk m0 m1 t else wkinv wk m0 m1 16).

lemma wk_read x wk m0 m1 lo hi l t : tctx x wk m0 m1 lo hi l t => t < 64 =>
  BArray512.get32 wk (8 * (t %/ 4) + 4 * l + t %% 4)
  = nth W32.zero K256 t + nth W32.zero (schedule (lane l m0 m1)) t.
proof.
rewrite /tctx => [#] ht0 ht1 hl0 hl1 _ _ _ _ hc ht.
have [hq0 [hq1 [hq2 hr]]] := d4b t ht0.
have hb : 0 <= t %/ 4 < (if l = 0 then wkn t else 16).
+ by rewrite /wkn; move: hq0 hq1 ht; clear hc; smt().
have hk : wkinv wk m0 m1 (if l = 0 then wkn t else 16).
+ by move: hc; case: (l = 0) => _ /=; [case | ].
rewrite (wk_get _ _ _ _ (t %/ 4) l (t %% 4) hk hb _ hr); 1: smt().
by rewrite hq2 /W addrC.
qed.

lemma rst_add v m s w st t (y : W32.t) :
  rst v m s st t => y = nth W32.zero K256 t + nth W32.zero w t =>
  rinw (BArray32.set32 v (((7 + 64) - t) %% 8) (BArray32.get32 v (((7 + 64) - t) %% 8) + y)) m s w st t.
proof.
rewrite /rst /rinw => [#] hv hm ->; split; last exact hm.
have := vis_set7 _ _ _ _ _ _ _ _ _ _ (st.`8 + (nth W32.zero K256 t + nth W32.zero w t)) hv.
move: hv => @/vis [#] _ _ _ _ _ _ _ ->.
by rewrite addrA.
qed.

lemma tctx_w kt x wk m0 m1 lo hi l t :
  (forall t, 0 <= t < 64 => BArray256.get32 kt t = nth W32.zero K256 t) =>
  tctx x wk m0 m1 lo hi l t => l = 0 => t < 48 => t %% 4 = 2 =>
  tctx (xnext x lo hi (t %/ 4) (t %% 4)) (wknext kt (xnext x lo hi (t %/ 4) (t %% 4)) wk t)
       m0 m1 lo hi l (t + 1).
proof.
rewrite /tctx => hK [#] ht0 ht1 hl0 hl1 hs0 hs1 hlo hhi hc hl ht h2; subst l.
move: hc => /= hc.
have hx := xw_w kt x wk m0 m1 lo hi t hK hhi hs0 hs1 hc _ h2; 1: smt().
by rewrite /= hs0 hs1 hlo hhi hx /=; move: ht0 ht; clear hK hc hx; smt().
qed.

lemma tctx_nw x wk m0 m1 lo hi l t :
  tctx x wk m0 m1 lo hi l t => l = 0 => t < 48 => t %% 4 <> 2 =>
  tctx (xnext x lo hi (t %/ 4) (t %% 4)) wk m0 m1 lo hi l (t + 1).
proof.
rewrite /tctx => [#] ht0 ht1 hl0 hl1 hs0 hs1 hlo hhi hc hl ht h2; subst l.
move: hc => /= hc.
have hx := xw_nw x wk m0 m1 lo hi t hlo hs0 hs1 hc _ h2; 1: smt().
by rewrite /= hs0 hs1 hlo hhi hx /=; move: ht0 ht; clear hc hx; smt().
qed.

lemma tctx_late x wk m0 m1 lo hi l t :
  tctx x wk m0 m1 lo hi l t => !(l = 0 /\ t < 48) => t < 64 =>
  tctx (xnext x lo hi 0 3) wk m0 m1 lo hi l (t + 1).
proof.
rewrite /tctx => [#] ht0 ht1 hl0 hl1 hs0 hs1 hlo hhi hc hn ht.
rewrite hs0 hs1 hlo hhi /=; split; 1: by move: ht0 ht; clear hc; smt().
split; 1: by move: hl0 hl1; clear hc; smt().
case: (l = 0) => hl; last by move: hc; rewrite hl /xnext.
move: hc; rewrite hl /= => hc; apply (xw_late x wk m0 m1 lo hi t hc).
by move: hn ht hl; clear hc; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Driver invariants                                                   *)

op hwords (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).

lemma nth_hwords h k : 0 <= k < 8 => nth W32.zero (hwords h) k = BArray32.get32 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

(* The table loop: groups 0 .. i - 1 written. *)
op iinv (h0 : W32.t list) (nb0 : int) (m0 m1 : W32.t list) (h : BArray32.t) (nb : int)
        (x : BArray128.t) (wk : BArray512.t) (i : int) =
  hwords h = h0 /\ nb = nb0 /\ (nb0 = 1 \/ nb0 = 2) /\ size m0 = 16 /\ size m1 = 16 /\
  win x m0 m1 0 /\ 0 <= i <= 4 /\ wkinv wk m0 m1 i.

lemma iinv_step kt h0 nb0 m0 m1 h nb x wk i :
  (forall t, 0 <= t < 64 => BArray256.get32 kt t = nth W32.zero K256 t) =>
  iinv h0 nb0 m0 m1 h nb x wk i => i < 4 =>
  iinv h0 nb0 m0 m1 h nb x
    (BArray512.set256 wk i (VPADD_8u32 (VPBROADCAST_2u128 (BArray256.get128 kt i))
                              (BArray128.get256 x i))) (i + 1).
proof.
rewrite /iinv => hK [#] hh hn hnb hs0 hs1 hw hi0 hi1 hk hi.
have hb : 0 <= i < 4 by move: hi0 hi; clear hK hk hw; smt().
rewrite hh hn hnb hs0 hs1 hw /=; split; 1: by move: hb; clear hK hk hw; smt().
apply (wk_set _ _ _ _ _ _ hK hk); 1: by move: hb; clear hK hk hw; smt().
move=> L c hL hc; rewrite (hw i L c hb hL hc).
by rewrite (_: (i - 0) %% 4 = i) 1:pmod_small.
qed.

(* Before block l and around its round loop. *)
op linv (h0 : W32.t list) (nb0 : int) (m0 m1 : W32.t list) (h v : BArray32.t)
        (x : BArray128.t) (wk : BArray512.t) (lo hi : W256.t) (inc l : int) =
  inc = nb0 /\ (nb0 = 1 \/ nb0 = 2) /\ size m0 = 16 /\ size m1 = 16 /\ 0 <= l <= nb0 /\
  hwords h = foldl compress h0 (take l [m0; m1]) /\
  (forall k, 0 <= k < 8 => BArray32.get32 v k = BArray32.get32 h k) /\
  twice lo lo_mask128 /\ twice hi hi_mask128 /\
  (l < nb0 => tctx x wk m0 m1 lo hi l 0).

op oinv (h0 : W32.t list) (nb0 : int) (m0 m1 : W32.t list) (h : BArray32.t) (inc l : int) =
  inc = nb0 /\ (nb0 = 1 \/ nb0 = 2) /\ 0 <= l < nb0 /\
  hwords h = foldl compress h0 (take l [m0; m1]).

(* The working variables of block l after t rounds. *)
op sl (m0 m1 : W32.t list) (h : BArray32.t) (l t : int) : state =
  rounds (schedule (lane l m0 m1)) (to_state (hwords h)) 0 t.

lemma sl_next m0 m1 h l t : 0 <= t =>
  round (schedule (lane l m0 m1)) (sl m0 m1 h l t) t = sl m0 m1 h l (t + 1).
proof. by move=> ht; rewrite /sl roundsS. qed.

lemma slot0 k : 0 <= k < 8 => ((k + 64) - 0) %% 8 = k.
proof. by move=> hk; rewrite (_: k + 64 - 0 = k + 8 * 8) 1:/# modzMDr pmod_small. qed.

lemma slot64 k : 0 <= k < 8 => ((k + 64) - 64) %% 8 = k.
proof. by move=> hk; rewrite (_: k + 64 - 64 = k) 1:/# pmod_small. qed.

lemma linv_init h0 nb0 m0 m1 h nb x wk v lo hi :
  iinv h0 nb0 m0 m1 h nb x wk 4 => twice lo lo_mask128 => twice hi hi_mask128 =>
  (forall k, 0 <= k < 8 => BArray32.get32 v k = BArray32.get32 h k) =>
  linv h0 nb0 m0 m1 h v x wk lo hi nb 0.
proof.
rewrite /iinv /linv => [#] hh hn hnb hs0 hs1 hw _ _ hk hlo hhi hv.
rewrite hn hnb hs0 hs1 take0 /= hh /=; split; 1: by move: hnb; clear hw hk hv hlo hhi; smt().
split; 1: exact hv. split; 1: exact hlo. split; 1: exact hhi.
move=> _; rewrite /tctx /xw /wkn hs0 hs1 hlo hhi /= ?div0z ?mod0z /=.
by rewrite hk hw.
qed.

lemma tinv_init h0 nb0 m0 m1 h v x wk lo hi inc l (m : BArray8.t) :
  linv h0 nb0 m0 m1 h v x wk lo hi inc l => l < inc =>
  oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 lo hi l 0 /\
  rst v (BArray8.set32 (BArray8.set32 m 0 (BArray32.get32 v 1)) 0
           (BArray8.get32 (BArray8.set32 m 0 (BArray32.get32 v 1)) 0 `^` BArray32.get32 v 2))
      (W32.of_int 0) (sl m0 m1 h l 0) 0.
proof.
rewrite /linv /oinv => [#] hinc hnb hs0 hs1 hl0 hl1 hh hv hlo hhi hc hl.
split; 1: by rewrite hinc hnb hh /=; move: hl0 hl; clear hv hc; smt().
split; 1: by apply hc; rewrite -hinc.
rewrite /sl rounds_nil // /rst /vis /to_state !slot0 // !nth_hwords // !hv //.
by rewrite !subr0 /=.
qed.

lemma tpre_step h0 nb0 m0 m1 h v m s x wk lo hi inc l t :
  oinv h0 nb0 m0 m1 h inc l => tctx x wk m0 m1 lo hi l t => rst v m s (sl m0 m1 h l t) t => t < 64 =>
  rinw (BArray32.set32 v (((7 + 64) - t) %% 8)
          (BArray32.get32 v (((7 + 64) - t) %% 8) + BArray512.get32 wk (8 * (t %/ 4) + 4 * l + t %% 4)))
       m s (schedule (lane l m0 m1)) (sl m0 m1 h l t) t.
proof. by move=> _ hc hr ht; apply (rst_add _ _ _ _ _ _ _ hr); exact (wk_read _ _ _ _ _ _ _ _ hc ht). qed.

lemma fin_v v m s (S : state) : rst v m s S 64 => forall k, 0 <= k < 8 =>
  BArray32.get32 (BArray32.set32 v 0 (BArray32.get32 v 0 + s)) k = nth W32.zero (of_state S) k.
proof.
case: S => a b c d e f g h; rewrite /rst /vis !slot64 // => [#] h0 h1 h2 h3 h4 h5 h6 h7 _ k hk.
rewrite BArray32.get_set32E //.
move: h0 h1 h2 h3 h4 h5 h6 h7 => /= h0 h1 h2 h3 h4 h5 h6 h7.
have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
case=> [->|]; 1: by rewrite /of_state /= h0; ring.
by case=> [->|[->|[->|[->|[->|[->|->]]]]]]; rewrite /of_state /= ?h1 ?h2 ?h3 ?h4 ?h5 ?h6 ?h7.
qed.

lemma hwords_ffwd h hb (S : state) :
  (forall k, 0 <= k < 8 => BArray32.get32 h k = nth W32.zero (of_state S) k + BArray32.get32 hb k) =>
  hwords h = ffwd S (hwords hb).
proof.
move=> hk; apply (eq_from_nth W32.zero).
+ by rewrite size_hwords /ffwd size_map size_zip size_of_state size_hwords.
move=> k; rewrite size_hwords => hk8; rewrite nth_hwords // /ffwd (nth_map (W32.zero, W32.zero)).
+ by rewrite size_zip size_of_state size_hwords.
rewrite nth_zip; 1: by rewrite size_of_state size_hwords.
by rewrite /= nth_hwords // hk.
qed.

lemma fold_next h0 m0 m1 l : 0 <= l < 2 =>
  foldl compress h0 (take (l + 1) [m0; m1]) = compress (foldl compress h0 (take l [m0; m1])) (lane l m0 m1).
proof.
move=> hl; case: (l = 0) => hl0; 1: by rewrite hl0 /lane /=.
have -> : l = 1 by smt().
by rewrite /lane /=.
qed.

lemma linv_next h0 nb0 m0 m1 hb h v x wk lo hi inc l :
  oinv h0 nb0 m0 m1 hb inc l => tctx x wk m0 m1 lo hi l 64 =>
  (forall k, 0 <= k < 8 =>
     BArray32.get32 h k = nth W32.zero (of_state (sl m0 m1 hb l 64)) k + BArray32.get32 hb k /\
     BArray32.get32 v k = BArray32.get32 h k) =>
  linv h0 nb0 m0 m1 h v x wk lo hi inc (l + 1).
proof.
rewrite /oinv /linv => [#] hinc hnb hl0 hl1 hh hc hf.
have hs := hc; move: hs => @/tctx [#] _ _ _ _ hs0 hs1 hlo hhi hx.
have hff : hwords h = ffwd (sl m0 m1 hb l 64) (hwords hb).
+ by apply hwords_ffwd => k hk; case: (hf k hk).
split; 1: exact hinc. split; 1: exact hnb. split; 1: exact hs0. split; 1: exact hs1.
split; 1: by move: hl0 hl1 hnb; clear hf hc hx hh hff; smt().
split.
+ rewrite fold_next; 1: by move: hl0 hl1 hnb; clear hf hc hx hh hff; smt().
  by rewrite -hh compress_rounds hff /sl.
split; 1: by move=> k hk; case: (hf k hk).
split; 1: exact hlo. split; 1: exact hhi.
move=> hl'; have hl : l = 0 by move: hl' hnb hl0 hl1; clear hf hc hx hh hff; smt().
move: hx; rewrite hl /= /xw /wkn /= => hk.
by rewrite /= hs0 hs1 hlo hhi /=; exact hk.
qed.
