(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2.ec
 * ==============
 *
 * Functional correctness of the SHA-512 AVX2 kernel
 * (src/x86_64/avx2/sha512_compress.jinc) against FIPS 180-4 section
 * 6.4.2: the driver __sha512_avx2, which runs the rounds of one or two
 * blocks held in the two 128-bit halves of x, from the round, schedule
 * and loop lemmas of SHA512_Avx2Rounds.ec.
 *
 * Model. NirapodSha2 is the model of a unit whose Sha512Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray64 BArray256 BArray640 BArray1280.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes64 Arrays Rounds512.
require import SHA512_Avx2Rounds.
import SHA512.

(* The feed-forward loop: words 0 .. i - 1 of h hold H(i) = s + H(i-1). *)
op finv (h0 : W64.t list) (nb0 : int) (m0 m1 : W64.t list) (hb h v : BArray64.t)
        (x : BArray256.t) (wk : BArray1280.t) (inc l i : int) =
  oinv h0 nb0 m0 m1 hb inc l /\ tctx x wk m0 m1 l 80 /\ 0 <= i <= 8 /\
  (forall k, 0 <= k < i =>
     BArray64.get64 h k = nth W64.zero (of_state (sl m0 m1 hb l 80)) k + BArray64.get64 hb k /\
     BArray64.get64 v k = BArray64.get64 h k) /\
  (forall k, i <= k < 8 =>
     BArray64.get64 h k = BArray64.get64 hb k /\
     BArray64.get64 v k = nth W64.zero (of_state (sl m0 m1 hb l 80)) k).

lemma ff_step h0 nb0 m0 m1 hb h v x wk inc l i :
  finv h0 nb0 m0 m1 hb h v x wk inc l i => i < 8 =>
  finv h0 nb0 m0 m1 hb
    (BArray64.set64 h i (BArray64.get64 (BArray64.set64 v i (BArray64.get64 v i + BArray64.get64 h i)) i))
    (BArray64.set64 v i (BArray64.get64 v i + BArray64.get64 h i)) x wk inc l (i + 1).
proof.
rewrite /finv => [#] ho hc hi0 hi1 hlo hhi hi.
have hb8 : 0 <= i < 8 by move: hi0 hi; clear hlo hhi; smt().
have [hh hv] := hhi i _; 1: by move: hb8; clear hlo hhi; smt().
rewrite BArray64.get_set64E 1,2:/# ifT //.
split; 1: exact ho. split; 1: exact hc.
split; 1: by move: hb8; clear hlo hhi; smt().
split => k hk.
+ rewrite !BArray64.get_set64E 1..4:/#.
  case: (i = k) => hki; last first.
  + rewrite ?ifF //; apply hlo; move: hk hki; clear hlo hhi; smt().
  by rewrite -hki ?ifT // hh hv.
rewrite !BArray64.get_set64E 1..4:/#.
have hki : i <> k by move: hk; clear hlo hhi; smt().
rewrite !ifF //; apply hhi; move: hk; clear hlo hhi; smt().
qed.

lemma avx2_driver (h0 m0 m1 : W64.t list) (nb0 : int) :
  hoare [M.__sha512_avx2 :
    hwords h = h0 /\ nb = nb0 /\ (nb0 = 1 \/ nb0 = 2) /\ size m0 = 16 /\ size m1 = 16 /\
    win x m0 m1 0 ==>
    hwords res.`1 = foldl compress h0 (take nb0 [m0; m1])].
proof.
proc.
seq 5 : (iinv h0 nb0 m0 m1 h nb x wk 8).
+ while (iinv h0 nb0 m0 m1 h nb x wk i).
  + wp; skip => &hr [hI hc]; exact (iinv_step _ _ _ _ _ _ _ _ _ _ K512_kernel hI hc).
  wp; skip => &hr [#] hh hn hnb hs0 hs1 hw; split.
  + rewrite /iinv hh hn hnb hs0 hs1 hw /=.
    by move=> i L c hi; move: hi; clear hw; smt().
  move=> i wk hc hI; have hi : i = 8.
  + by move: hI => @/iinv [#] _ _ _ _ _ _ hi0 hi1 _; move: hc hi1; clear hw; smt().
  by rewrite -hi.
seq 2 : (iinv h0 nb0 m0 m1 h nb x wk 8 /\
         forall k, 0 <= k < 8 => BArray64.get64 v k = BArray64.get64 h k).
+ while (iinv h0 nb0 m0 m1 h nb x wk 8 /\ 0 <= i <= 8 /\
         forall k, 0 <= k < i => BArray64.get64 v k = BArray64.get64 h k).
  + wp; skip => &hr [#] hI hi0 hi1 hv hc; split; 1: exact hI.
    split; 1: by move: hi0 hc; clear hI hv; smt().
    move=> k hk; rewrite BArray64.get_set64E 1,2:/#.
    case: (i{hr} = k) => hik; 1: by rewrite hik.
    by apply hv; move: hk hik; clear hI hv; smt().
  wp; skip => &hr hI; split; 1: by rewrite hI /=; smt().
  move=> i v hc [#] hJ hi0 hi1 hv; split; 1: exact hJ.
  by move=> k hk; apply hv; move: hk hc hi1; clear hI hJ hv; smt().
seq 2 : (linv h0 nb0 m0 m1 h v x wk inc l).
+ by wp; skip => &hr [hI hv]; exact (linv_init _ _ _ _ _ _ _ _ _ hI hv).
while (linv h0 nb0 m0 m1 h v x wk inc l); last first.
+ skip => &hr hI; split; 1: exact hI.
  move=> h1 l0 v0 wk0 x0 hc; rewrite /linv => [#] hi _ _ _ hl0 hl1 hh _ _.
  have hl : l0 = nb0 by move: hc hi hl1; clear hh; smt().
  by rewrite -hl -hh.
seq 4 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 l t /\ rst v m s (sl m0 m1 h l t) t /\ t = 0).
+ wp; skip => &hr [hI hl].
  have [h1 [h2 h3]] := tinv_init _ _ _ _ _ _ _ _ _ _ m{hr} hI hl.
  by split; [exact h1 | split; [exact h2 | split; [exact h3 | done]]].
seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 l 80 /\ rst v m s (sl m0 m1 h l 80) 80).
+ while (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 l t /\ rst v m s (sl m0 m1 h l t) t).
  + seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x wk m0 m1 l t /\ t < 80 /\
             rinw v m s (schedule (lane l m0 m1)) (sl m0 m1 h l t) t).
    + wp; skip => &hr [[ho [hc hr]] ht].
      split; 1: exact ho. split; 1: exact hc. split; 1: exact ht.
      exact (tpre_step _ _ _ _ _ _ _ _ _ _ _ _ _ ho hc hr ht).
    exlim x, t => x0 t0.
    if.
    + seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x0 wk m0 m1 l t0 /\ t0 < 80 /\ l = 0 /\ t0 < 64 /\
               t = t0 /\ rst v m s (sl m0 m1 h l (t0 + 1)) (t0 + 1) /\ x = xnext x0 (t0 %/ 2) (t0 %% 2)).
      + ecall (round_call (schedule (lane l m0 m1)) (sl m0 m1 h l t) t x (t %/ 2) (t %% 2)).
        skip => &hr [[[hx ht] [ho [hc [ht8 hri]]]] [hl hl64]].
        have ht0 : 0 <= t{hr} by move: hc => @/tctx [#].
        split.
        + split; 1: by have := modz_cmp t{hr} 2; clear hri hc ho; smt().
          by rewrite /=; exact hri.
        move=> _ r [hr1 hr2]; rewrite hx ht.
        split; 1: exact ho. split; 1: exact hc. split; 1: exact ht8.
        split; 1: exact hl. split; 1: exact hl64. split; 1: done.
        by split; [rewrite -sl_next //; exact hr1 | exact hr2].
      if.
      + wp; skip => &hr [[ho [hc [ht8 [hl [hl64 [ht [hr hx]]]]]]] [_ hodd]].
        rewrite ht in hodd; rewrite hx ht.
        split; 1: exact ho. split; last exact hr.
        exact (tctx_odd _ _ _ _ _ _ _ K512_kernel hc hl hl64 hodd).
      wp; skip => &hr [[ho [hc [ht8 [hl [hl64 [ht [hr hx]]]]]]] hn].
      have hodd : t0 %% 2 <> 1 by move: hn; rewrite hl ht hl64.
      rewrite hx ht.
      split; 1: exact ho. split; last exact hr.
      exact (tctx_even _ _ _ _ _ _ hc hl hl64 hodd).
    seq 1 : (oinv h0 nb0 m0 m1 h inc l /\ tctx x0 wk m0 m1 l t0 /\ t0 < 80 /\ !(l = 0 /\ t0 < 64) /\
             t = t0 /\ rst v m s (sl m0 m1 h l (t0 + 1)) (t0 + 1) /\ x = xnext x0 0 2).
    + ecall (round_call (schedule (lane l m0 m1)) (sl m0 m1 h l t) t x 0 2).
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
    exact (tctx_late _ _ _ _ _ _ hc hn ht8).
  skip => &hr [ho [hc [hr ht]]]; split; 1: by split; [exact ho | split; [exact hc | exact hr]].
  move=> m2 s0 t0 v0 wk0 x0 hn [ho' [hc' hr']].
  have h80 : t0 = 80 by move: hc' => @/tctx [#] _ ht1; move: hn ht1; clear ho' hr'; smt().
  by subst t0; split; [exact ho' | split; [exact hc' | exact hr']].
exlim h => hb.
seq 3 : (finv h0 nb0 m0 m1 hb h v x wk inc l i /\ i = 0).
+ wp; skip => &hr [hb' [ho [hc hr]]].
  move: ho hr; rewrite /SLH64.protect_ptr -hb' => ho hr.
  split; 2: done. split; 1: exact ho. split; 1: exact hc. split; 1: done.
  split; 1: by move=> k [hk0 hk1]; move: hk0 hk1; clear ho hc hr; smt().
  by move=> k hk; split; [done | exact (fin_v _ _ _ _ hr k hk)].
wp; while (finv h0 nb0 m0 m1 hb h v x wk inc l i).
+ by wp; skip => &hr [hI hc]; exact (ff_step _ _ _ _ _ _ _ _ _ _ _ _ hI hc).
skip => &hr [hI _]; split; 1: exact hI.
move=> h' i' v' hc; rewrite /finv => [#] ho hc' hi0 hi1 hlo _.
have hi : i' = 8 by move: hc hi1; clear hlo; smt().
subst i'; exact (linv_next _ _ _ _ _ _ _ _ _ _ _ ho hc' hlo).
qed.
