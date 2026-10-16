(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2.ec
 * ==============
 *
 * Functional correctness of the SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_compress.jinc) against FIPS 180-4 section
 * 6.2.2: the driver __sha256_avx2, which runs the rounds of one or two
 * blocks held in the two 128-bit halves of x, from the round, schedule
 * and loop lemmas of SHA256_Avx2Rounds.ec.
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray8 BArray32 BArray128 BArray256 BArray512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes32 Arrays Rounds256.
require import SHA256_Avx2Rounds.
import SHA256.

clone Arrays.ArrayLanes as L32 with theory A <- BArray32.

(* The kernel's two VPSHUFB masks of the schedule. *)
lemma lo_kernel : twice (BArray32.get256 sHA256_AVX2_LO 0) lo_mask128.
proof.
move=> i hi; rewrite L32.get256_bits32 // BArray32.get32_of_list32 1:/# /lo_mask128 p4_lane 1:/#.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

lemma hi_kernel : twice (BArray32.get256 sHA256_AVX2_HI 0) hi_mask128.
proof.
move=> i hi; rewrite L32.get256_bits32 // BArray32.get32_of_list32 1:/# /hi_mask128 p4_lane 1:/#.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

(* The feed-forward loop: words 0 .. i - 1 of h hold H(i) = s + H(i-1). *)
op finv (h0 : W32.t list) (nb0 : int) (m0 m1 : W32.t list) (hb h v : BArray32.t)
        (x : BArray128.t) (wk : BArray512.t) (lo hi : W256.t) (inc l i : int) =
  oinv h0 nb0 m0 m1 hb inc l /\ tctx x wk m0 m1 lo hi l 64 /\ 0 <= i <= 8 /\
  (forall k, 0 <= k < i =>
     BArray32.get32 h k = nth W32.zero (of_state (sl m0 m1 hb l 64)) k + BArray32.get32 hb k /\
     BArray32.get32 v k = BArray32.get32 h k) /\
  (forall k, i <= k < 8 =>
     BArray32.get32 h k = BArray32.get32 hb k /\
     BArray32.get32 v k = nth W32.zero (of_state (sl m0 m1 hb l 64)) k).

lemma ff_step h0 nb0 m0 m1 hb h v x wk lo hi inc l i :
  finv h0 nb0 m0 m1 hb h v x wk lo hi inc l i => i < 8 =>
  finv h0 nb0 m0 m1 hb
    (BArray32.set32 h i (BArray32.get32 (BArray32.set32 v i (BArray32.get32 v i + BArray32.get32 h i)) i))
    (BArray32.set32 v i (BArray32.get32 v i + BArray32.get32 h i)) x wk lo hi inc l (i + 1).
proof.
rewrite /finv => [#] ho hc hi0 hi1 hlo hhi hlt.
have hb8 : 0 <= i < 8 by move: hi0 hlt; clear hlo hhi; smt().
have [hh hv] := hhi i _; 1: by move: hb8; clear hlo hhi; smt().
rewrite BArray32.get_set32E 1,2:/# ifT //.
split; 1: exact ho. split; 1: exact hc.
split; 1: by move: hb8; clear hlo hhi; smt().
split => k hk.
+ rewrite !BArray32.get_set32E 1..4:/#.
  case: (i = k) => hki; last first.
  + rewrite ?ifF //; apply hlo; move: hk hki; clear hlo hhi; smt().
  by rewrite -hki ?ifT // hh hv.
rewrite !BArray32.get_set32E 1..4:/#.
have hki : i <> k by move: hk; clear hlo hhi; smt().
rewrite !ifF //; apply hhi; move: hk; clear hlo hhi; smt().
qed.

lemma avx2_driver (h0 m0 m1 : W32.t list) (nb0 : int) :
  hoare [M.__sha256_avx2 :
    hwords h = h0 /\ nb = nb0 /\ (nb0 = 1 \/ nb0 = 2) /\ size m0 = 16 /\ size m1 = 16 /\
    win x m0 m1 0 ==>
    hwords res.`1 = foldl compress h0 (take nb0 [m0; m1])].
proof.
proc.
seq 7 : (iinv h0 nb0 m0 m1 h nb x wk 4).
+ while (iinv h0 nb0 m0 m1 h nb x wk i).
  + wp; skip => &hr [hI hc]; exact (iinv_step _ _ _ _ _ _ _ _ _ _ K256_kernel hI hc).
  wp; skip => &hr [#] hh hn hnb hs0 hs1 hw; split.
  + rewrite /iinv hh hn hnb hs0 hs1 hw /=.
    by move=> i L c hi; move: hi; clear hw; smt().
  move=> i wk hc hI; have hi : i = 4.
  + by move: hI => @/iinv [#] _ _ _ _ _ _ hi0 hi1 _; move: hc hi1; clear hw; smt().
  by rewrite -hi.
seq 6 : (iinv h0 nb0 m0 m1 h nb x wk 4 /\ twice lo lo_mask128 /\ twice hi hi_mask128 /\
         forall k, 0 <= k < 8 => BArray32.get32 v k = BArray32.get32 h k).
+ while (iinv h0 nb0 m0 m1 h nb x wk 4 /\ twice lo lo_mask128 /\ twice hi hi_mask128 /\ 0 <= i <= 8 /\
         forall k, 0 <= k < i => BArray32.get32 v k = BArray32.get32 h k).
  + wp; skip => &hr [#] hI hlo hhi hi0 hi1 hv hc; split; 1: exact hI.
    split; 1: exact hlo. split; 1: exact hhi.
    split; 1: by move: hi0 hc; clear hI hv; smt().
    move=> k hk; rewrite BArray32.get_set32E 1,2:/#.
    case: (i{hr} = k) => hik; 1: by rewrite hik.
    by apply hv; move: hk hik; clear hI hv; smt().
  wp; skip => &hr hI; split; 1: by rewrite hI lo_kernel hi_kernel /=; smt().
  move=> i v hc [#] hJ hlo hhi hi0 hi1 hv; split; 1: exact hJ.
  split; 1: exact hlo. split; 1: exact hhi.
  by move=> k hk; apply hv; move: hk hc hi1; clear hI hJ hv; smt().
seq 2 : (linv h0 nb0 m0 m1 h v x wk lo hi inc l).
+ by wp; skip => &hr [hI [hlo [hhi hv]]]; exact (linv_init _ _ _ _ _ _ _ _ _ _ _ hI hlo hhi hv).
while (linv h0 nb0 m0 m1 h v x wk lo hi inc l); last first.
+ skip => &hr hI; split; 1: exact hI.
  move=> h1 l0 v0 wk0 x0 hc; rewrite /linv => [#] hinc _ _ _ hl0 hl1 hh _ _ _ _.
  have hl : l0 = nb0 by move: hc hinc hl1; clear hh; smt().
  by rewrite -hl -hh.
seq 4 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 lo hi l t /\ rst v m s (sl m0 m1 h l t) t /\ t = 0).
+ wp; skip => &hr [hI hl].
  have [h1 [h2 h3]] := tinv_init _ _ _ _ _ _ _ _ _ _ _ _ m{hr} hI hl.
  by split; [exact h1 | split; [exact h2 | split; [exact h3 | done]]].
seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 lo hi l 64 /\ rst v m s (sl m0 m1 h l 64) 64).
+ while (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 lo hi l t /\ rst v m s (sl m0 m1 h l t) t).
  + seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 lo hi l t /\ t < 64 /\
             rinw v m s (schedule (lane l m0 m1)) (sl m0 m1 h l t) t).
    + wp; skip => &hr [[ho [hc hr]] ht].
      split; 1: exact ho. split; 1: exact hc. split; 1: exact ht.
      exact (tpre_step _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ho hc hr ht).
    exlim x, t => x0 t0.
    if.
    + seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x0 wk m0 m1 lo hi l t0 /\ t0 < 64 /\ l = 0 /\ t0 < 48 /\
               t = t0 /\ rst v m s (sl m0 m1 h l (t0 + 1)) (t0 + 1) /\
               x = xnext x0 lo hi (t0 %/ 4) (t0 %% 4)).
      + ecall (round_call (schedule (lane l m0 m1)) (sl m0 m1 h l t) t x lo hi (t %/ 4) (t %% 4)).
        skip => &hr [[[hx ht] [ho [hc [ht8 hri]]]] [hl hl48]].
        have ht0 : 0 <= t{hr} by move: hc => @/tctx [#].
        split.
        + split; 1: by have := modz_cmp t{hr} 4; clear hri hc ho; smt().
          by rewrite /=; exact hri.
        move=> _ r [hr1 hr2]; rewrite hx ht.
        split; 1: exact ho. split; 1: exact hc. split; 1: exact ht8.
        split; 1: exact hl. split; 1: exact hl48. split; 1: done.
        by split; [rewrite -sl_next //; exact hr1 | exact hr2].
      if.
      + wp; skip => &hr [[ho [hc [ht8 [hl [hl48 [ht [hr hx]]]]]]] [_ h2]].
        rewrite ht in h2; rewrite hx ht.
        split; 1: exact ho. split; last exact hr.
        exact (tctx_w _ _ _ _ _ _ _ _ _ K256_kernel hc hl hl48 h2).
      wp; skip => &hr [[ho [hc [ht8 [hl [hl48 [ht [hr hx]]]]]]] hn].
      have h2 : t0 %% 4 <> 2 by move: hn; rewrite hl ht hl48.
      rewrite hx ht.
      split; 1: exact ho. split; last exact hr.
      exact (tctx_nw _ _ _ _ _ _ _ _ hc hl hl48 h2).
    seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x0 wk m0 m1 lo hi l t0 /\ t0 < 64 /\ !(l = 0 /\ t0 < 48) /\
             t = t0 /\ rst v m s (sl m0 m1 h l (t0 + 1)) (t0 + 1) /\ x = xnext x0 lo hi 0 3).
    + ecall (round_call (schedule (lane l m0 m1)) (sl m0 m1 h l t) t x lo hi 0 3).
      skip => &hr [[[hx ht] [ho [hc [ht8 hri]]]] hn].
      have ht0 : 0 <= t{hr} by move: hc => @/tctx [#].
      split; 1: by rewrite /=; exact hri.
      move=> _ r [hr1 hr2]; rewrite hx ht.
      split; 1: exact ho. split; 1: exact hc. split; 1: exact ht8. split; 1: exact hn. split; 1: done.
      by split; [rewrite -sl_next //; exact hr1 | exact hr2].
    rcondf 1; 1: by skip => &hr [_ [_ [_ [hn [ht _]]]]]; move: hn; rewrite ht; smt().
    wp; skip => &hr [ho [hc [ht8 [hn [ht [hr hx]]]]]].
    rewrite hx ht.
    split; 1: exact ho. split; last exact hr.
    exact (tctx_late _ _ _ _ _ _ _ _ hc hn ht8).
  skip => &hr [ho [hc [hr ht]]]; split; 1: by split; [exact ho | split; [exact hc | exact hr]].
  move=> m2 s0 t0 v0 wk0 x0 hn [ho' [hc' hr']].
  have h64 : t0 = 64 by move: hc' => @/tctx [#] _ ht1; move: hn ht1; clear ho' hr'; smt().
  by subst t0; split; [exact ho' | split; [exact hc' | exact hr']].
exlim h => hb.
seq 3 : (finv h0 nb0 m0 m1 hb h v x wk lo hi inc l i /\ i = 0).
+ wp; skip => &hr [hb' [ho [hc hr]]].
  move: ho hr; rewrite /SLH64.protect_ptr -hb' => ho hr.
  split; 2: done. split; 1: exact ho. split; 1: exact hc. split; 1: done.
  split; 1: by move=> k [hk0 hk1]; move: hk0 hk1; clear ho hc hr; smt().
  by move=> k hk; split; [done | exact (fin_v _ _ _ _ hr k hk)].
wp; while (finv h0 nb0 m0 m1 hb h v x wk lo hi inc l i).
+ by wp; skip => &hr [hI hc]; exact (ff_step _ _ _ _ _ _ _ _ _ _ _ _ _ _ hI hc).
skip => &hr [hI _]; split; 1: exact hI.
move=> h' i' v' hc; rewrite /finv => [#] ho hc' hi0 hi1 hlo _.
have hi : i' = 8 by move: hc hi1; clear hlo; smt().
subst i'; exact (linv_next _ _ _ _ _ _ _ _ _ _ _ _ _ ho hc' hlo).
qed.
