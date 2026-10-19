(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_ShaNiBlock.ec
 * ======================
 *
 * One block of a pair of lanes in the 8-way SHA-256 kernel on the x86 SHA
 * extensions (src/x86_64/shani/sha256_x8_compress.jinc):
 *
 *   block2_correct   __shani_x8_block2, the 64 rounds and the
 *                    feed-forward of two lanes, interleaved
 *
 * Each lane is the single-way kernel's block (SHA256_ShaNi.block_correct):
 * the same schedule window, held in w[4l .. 4l + 3] for lane l, and the
 * same four-round group (ShaNi.shani_rounds4), issued for lane 0 and then
 * lane 1 at each of its two SHA256RNDS2 steps. The postcondition is the
 * conjunction of the two single-lane postconditions.
 *
 * The round constants are a parameter kt with their values as a
 * hypothesis, so that no goal holds the 64-entry table literal.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import BArray32 BArray64 BArray128 BArray256.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Vec Arrays SpecRounds ShaNi.
require SHA256_ShaNi.
import SHA256 R256.

(* The working variables of a lane before group g (SHA256_ShaNi.st). *)
abbrev sts = SHA256_ShaNi.st.

(* ------------------------------------------------------------------ *)
(* The schedule window of lane l, in w[o .. o + 3], o = 4l            *)

op wreg8 (w : BArray128.t) (o : int) (m : W32.t list) (g : int) =
  forall i, 0 <= i < 4 => BArray128.get128 w (o + i) = wv m (4 * SHA256_ShaNi.grp g i).

lemma wreg8_lo w o m g : 0 <= g < 4 => wreg8 w o m g => wreg8 w o m (g + 1).
proof. by move=> hg hw i hi; rewrite hw // /SHA256_ShaNi.grp /#. qed.

(* Writes outside w[o .. o + 3] leave lane l's window as it was. *)
lemma wreg8_frame (w w' : BArray128.t) o m g :
  (forall i, 0 <= i < 4 => BArray128.get128 w' (o + i) = BArray128.get128 w (o + i)) =>
  wreg8 w o m g => wreg8 w' o m g.
proof. by move=> he hw i hi; rewrite he // hw. qed.

(* The four schedule steps of group g >= 4 on lane l's window: the
   single-way kernel's step (SHA256_ShaNi.wstep) at offset o. *)
lemma wstep8 (w : BArray128.t) o m g :
  (o = 0 \/ o = 4) => size m = 16 => 4 <= g < 16 => wreg8 w o m g =>
  let r = o + g %% 4 in
  let w1 = BArray128.set128 w r
             (SHA256MSG1 (BArray128.get128 w r) (BArray128.get128 w (o + (g + 1) %% 4))) in
  let t = VPALIGNR_128 (BArray128.get128 w1 (o + (g + 3) %% 4))
            (BArray128.get128 w1 (o + (g + 2) %% 4)) (W8.of_int 4) in
  let w2 = BArray128.set128 w1 r (VPADD_4u32 (BArray128.get128 w1 r) t) in
  let w3 = BArray128.set128 w2 r
             (SHA256MSG2 (BArray128.get128 w2 r) (BArray128.get128 w2 (o + (g + 3) %% 4))) in
  wreg8 w3 o m (g + 1) /\
  forall i, 0 <= i < 8 => (i < o \/ o + 4 <= i) => BArray128.get128 w3 i = BArray128.get128 w i.
proof.
move=> ho hm hg hw /=.
have hr : 0 <= g %% 4 < 4 by smt().
split; last first.
+ move=> i hi hio; do !(rewrite BArray128.get_set128E 1,2:/#).
  by rewrite !ifF 1..3:/#.
move=> i hi.
do !(rewrite BArray128.get_set128E 1,2:/#).
have -> /= : (o + g %% 4 = o + (g + 2) %% 4) = false by smt().
have -> /= : (o + g %% 4 = o + (g + 3) %% 4) = false by smt().
case: (o + g %% 4 = o + i) => [hgi|hne] /=; last first.
+ by rewrite hw // SHA256_ShaNi.grp_keep /#.
have ->> : i = g %% 4 by smt().
rewrite SHA256_ShaNi.grp_cur 1:/#.
have h0 := hw (g %% 4) hr; have h1 := hw ((g + 1) %% 4) _; 1: smt().
have h2 := hw ((g + 2) %% 4) _; 1: smt().
have h3 := hw ((g + 3) %% 4) _; 1: smt().
rewrite h0 h1 h2 h3.
have e0 : SHA256_ShaNi.grp g (g %% 4) = g - 4 by have := SHA256_ShaNi.grp_win g 0; smt().
rewrite e0 !SHA256_ShaNi.grp_win // 1..3:/#.
have -> : 4 * (g - 4) = 4 * g - 16 by ring.
have -> : 4 * (g - 4 + 1) = 4 * g - 12 by ring.
have -> : 4 * (g - 4 + 3) = 4 * g - 4 by ring.
have -> : 4 * (g - 4 + 2) = 4 * g - 8 by ring.
by apply shani_sched4 => /#.
qed.

(* ------------------------------------------------------------------ *)
(* One block of the pair                                               *)

(* The four state registers, [abef; cdgh] of lane 0 then of lane 1. *)
op regs (st : BArray64.t) (sa sb : state) =
  BArray64.get128 st 0 = abef sa /\ BArray64.get128 st 1 = cdgh sa /\
  BArray64.get128 st 2 = abef sb /\ BArray64.get128 st 3 = cdgh sb.

lemma block2_correct (kt : BArray256.t) (ma mb : W32.t list) (sa sb : state) :
  (forall g, 0 <= g < 16 => BArray256.get128 kt g
     = p4 (nth W32.zero K256 (4 * g)) (nth W32.zero K256 (4 * g + 1))
          (nth W32.zero K256 (4 * g + 2)) (nth W32.zero K256 (4 * g + 3))) =>
  hoare [M.__shani_x8_block2 :
    size ma = 16 /\ size mb = 16 /\ k = kt /\ regs st sa sb /\
    wreg8 w 0 ma 0 /\ wreg8 w 4 mb 0 ==>
    BArray64.get128 res.`1 0 = VPADD_4u32 (abef (sts ma sa 16)) (abef sa) /\
    BArray64.get128 res.`1 1 = VPADD_4u32 (cdgh (sts ma sa 16)) (cdgh sa) /\
    BArray64.get128 res.`1 2 = VPADD_4u32 (abef (sts mb sb 16)) (abef sb) /\
    BArray64.get128 res.`1 3 = VPADD_4u32 (cdgh (sts mb sb 16)) (cdgh sb)].
proof.
move=> hK; proc; unroll for ^while; unroll for 11.
wp.
while (0 <= g <= 16 /\ size ma = 16 /\ size mb = 16 /\ k = kt /\ regs s0 sa sb /\
       wreg8 w 0 ma g /\ wreg8 w 4 mb g /\
       regs st (sts ma sa g) (sts mb sb g)).
+ unroll for ^while; unroll for ^while.
  (* lane 0, schedule *)
  seq 1 : (0 <= g < 16 /\ size ma = 16 /\ size mb = 16 /\ k = kt /\ regs s0 sa sb /\
           wreg8 w 0 ma (g + 1) /\ wreg8 w 4 mb g /\ regs st (sts ma sa g) (sts mb sb g)).
  + if.
    + wp; skip => &hr [#] hg0 _ hma hmb hk hs0 hw0 hw4 hst hg16 hg4.
      have [h1 h2] /= := wstep8 w{hr} 0 ma g{hr} _ hma _ hw0; 1,2: smt().
      rewrite hma hmb hk hs0 hst h1 /=; split; first smt().
      by apply (wreg8_frame w{hr}) => // i hi; apply h2 => /#.
    by skip => &hr [#] hg0 _ hma hmb hk hs0 hw0 hw4 hst hg16 hg4; rewrite wreg8_lo /#.
  (* lane 0, rounds 4g and 4g + 1 *)
  seq 3 : (0 <= g < 16 /\ size ma = 16 /\ size mb = 16 /\ k = kt /\ regs s0 sa sb /\
           wreg8 w 0 ma (g + 1) /\ wreg8 w 4 mb g /\
           BArray64.get128 st 0 = abef (sts ma sa g) /\
           BArray64.get128 st 1 = cdgh (sts ma sa (g + 1)) /\
           BArray64.get128 st 2 = abef (sts mb sb g) /\
           BArray64.get128 st 3 = cdgh (sts mb sb g) /\
           BArray32.get128 wk 0 = wk4 (schedule ma) (4 * g)).
  + wp; skip => &hr [#] hg0 hg1 hma hmb hk hs0 hw0 hw4 hst.
    move: hst; rewrite /regs /= => [#] e0 e1 e2 e3.
    have hwk : VPADD_4u32 (BArray128.get128 w{hr} (g{hr} %% 4)) (BArray256.get128 kt g{hr})
               = wk4 (schedule ma) (4 * g{hr}).
    + have /= -> := hw0 (g{hr} %% 4) _; 1: smt().
      by rewrite SHA256_ShaNi.grp_cur 1:/# hK // /wv /wk4.
    have [h1 h2] := shani_rounds4 (schedule ma) (4 * g{hr}) (sts ma sa g{hr}).
    rewrite hma hmb hk hw0 hw4 /= e0 e1 e2 e3 hwk h2 (SHA256_ShaNi.stS ma sa g{hr}) 1:/#.
    smt().
  (* lane 1, schedule *)
  seq 1 : (0 <= g < 16 /\ size ma = 16 /\ size mb = 16 /\ k = kt /\ regs s0 sa sb /\
           wreg8 w 0 ma (g + 1) /\ wreg8 w 4 mb (g + 1) /\
           BArray64.get128 st 0 = abef (sts ma sa g) /\
           BArray64.get128 st 1 = cdgh (sts ma sa (g + 1)) /\
           BArray64.get128 st 2 = abef (sts mb sb g) /\
           BArray64.get128 st 3 = cdgh (sts mb sb g) /\
           BArray32.get128 wk 0 = wk4 (schedule ma) (4 * g)).
  + if.
    + wp; skip => &hr [#] hg0 hg1 hma hmb hk hs0 hw0 hw4 e0 e1 e2 e3 ewk hg4.
      have [h1 h2] /= := wstep8 w{hr} 4 mb g{hr} _ hmb _ hw4; 1,2: smt().
      rewrite hma hmb hk hs0 e0 e1 e2 e3 ewk h1 /=; split; first smt().
      by apply (wreg8_frame w{hr}) => // i hi; apply h2 => /#.
    by skip => &hr [#] hg0 hg1 hma hmb hk hs0 hw0 hw4 e0 e1 e2 e3 ewk hg4; rewrite (wreg8_lo w{hr} 4 mb g{hr}) /#.
  (* lane 1, rounds 4g and 4g + 1 *)
  seq 3 : (0 <= g < 16 /\ size ma = 16 /\ size mb = 16 /\ k = kt /\ regs s0 sa sb /\
           wreg8 w 0 ma (g + 1) /\ wreg8 w 4 mb (g + 1) /\
           BArray64.get128 st 0 = abef (sts ma sa g) /\
           BArray64.get128 st 1 = cdgh (sts ma sa (g + 1)) /\
           BArray64.get128 st 2 = abef (sts mb sb g) /\
           BArray64.get128 st 3 = cdgh (sts mb sb (g + 1)) /\
           BArray32.get128 wk 0 = wk4 (schedule ma) (4 * g) /\
           BArray32.get128 wk 1 = wk4 (schedule mb) (4 * g)).
  + wp; skip => &hr [#] hg0 hg1 hma hmb hk hs0 hw0 hw4 e0 e1 e2 e3 ewk.
    have hwk : VPADD_4u32 (BArray128.get128 w{hr} (4 + g{hr} %% 4)) (BArray256.get128 kt g{hr})
               = wk4 (schedule mb) (4 * g{hr}).
    + have /= -> := hw4 (g{hr} %% 4) _; 1: smt().
      by rewrite SHA256_ShaNi.grp_cur 1:/# hK // /wv /wk4.
    have [h1 h2] := shani_rounds4 (schedule mb) (4 * g{hr}) (sts mb sb g{hr}).
    move: e0 e1 e2 e3 ewk => /= e0 e1 e2 e3 ewk.
    rewrite hma hmb hk /= e0 e1 e2 e3 ewk hwk h2 (SHA256_ShaNi.stS mb sb g{hr}) 1:/#.
    smt().
  (* rounds 4g + 2 and 4g + 3 of both lanes *)
  wp; skip => &hr [#] hg0 hg1 hma hmb hk hs0 hw0 hw4 e0 e1 e2 e3 ewa ewb.
  have [ha1 ha2] := shani_rounds4 (schedule ma) (4 * g{hr}) (sts ma sa g{hr}).
  have [hb1 hb2] := shani_rounds4 (schedule mb) (4 * g{hr}) (sts mb sb g{hr}).
  move: e0 e1 e2 e3 ewa ewb => /= e0 e1 e2 e3 ewa ewb.
  rewrite hma hmb hk /regs /= e0 e1 e2 e3 ewa ewb.
  rewrite (SHA256_ShaNi.stS ma sa g{hr}) 1:/# (SHA256_ShaNi.stS mb sb g{hr}) 1:/#.
  rewrite -ha2 ha1 -hb2 hb1 /=; smt().
wp; skip => &hr [#] hma hmb -> hr hw0 hw4; split.
+ rewrite hma hmb hw0 hw4 !SHA256_ShaNi.st0 /=.
  by move: hr; rewrite /regs /= => [#] -> -> -> ->.
move=> g st0 w0 hg [#] hg0 hg1 _ _ _ hs0 _ _ hst; have ->> : g = 16 by smt().
by move: hs0 hst; rewrite /regs /= => [#] -> -> -> -> [#] -> -> -> ->.
qed.
