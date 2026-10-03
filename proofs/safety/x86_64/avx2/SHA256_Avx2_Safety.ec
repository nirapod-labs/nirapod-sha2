(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2_Safety.ec
 * =====================
 *
 * Safety of the SHA-256 AVX2 kernel (src/x86_64/avx2/sha256_compress.jinc):
 * for each of its functions F, F_proof proves F_spec of the safety model
 * (NirapodSha2Safety, extracted by jasmin2ec -m safety), the Hoare triple
 * stating that the #[safety] contract's precondition gives its
 * postcondition and that every assertion of F's trace holds (array
 * accesses in bounds and initialised, memory accesses valid).
 *
 * The working variables v and the schedule window x stay fully
 * initialised. Of m, the round reads the half it was given and writes the
 * other. The W + K table wk is written group by group, and the driver
 * reads only groups already written: groups 0 .. 3 before the rounds,
 * group 4 + t / 4 after round t of the first block (t mod 4 = 2, t < 48).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray8 BArray32 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2Safety Masks Valid.

clone Masks.Masks as K8 with theory A <- BArray8.
clone Masks.Masks as K32 with theory A <- BArray32.
clone Masks.Masks as K64 with theory A <- BArray64.
clone Masks.Masks as K128 with theory A <- BArray128.
clone Masks.Masks as K512 with theory A <- BArray512.

lemma __sha256_avx2_round_proof _v _m _s _t _x _lo _hi _j _ph _v_init _m_init _x_init :
  __sha256_avx2_round_spec _v _m _s _t _x _lo _hi _j _ph _v_init _m_init _x_init.
proof.
rewrite /__sha256_avx2_round_spec; proc.
case (ph = 0).
+ rcondt ^if; first by auto. rcondf ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto. rcondf ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondt ^if; first by auto.
  auto => /> ht0 ht1 hv hm hx.
  rewrite (K32.is_init_full _ hv) (K128.is_init_full _ hx) ?K32.full_set32d ?K128.full_set256d.
  rewrite ?K32.full_init ?K128.full_init /=.
  have h2 := modz_cmp _t 2 _; 1: done.
  have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
  do ?split; try (move=> k hk1 hk2; rewrite ?BArray8.is_init_cell_set32d); smt().
case (ph = 1).
+ rcondf ^if; first by auto. rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto. rcondf ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto.
  auto => /> ht0 ht1 hv hm hx.
  rewrite (K32.is_init_full _ hv) (K128.is_init_full _ hx) ?K32.full_set32d ?K128.full_set256d.
  rewrite ?K32.full_init ?K128.full_init /=.
  have h2 := modz_cmp _t 2 _; 1: done.
  have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
  do ?split; try (move=> k hk1 hk2; rewrite ?BArray8.is_init_cell_set32d); smt().
case (ph = 2).
+ rcondf ^if; first by auto. rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto. rcondt ^if; first by auto.
  rcondf ^if; first by auto.
  auto => /> ht0 ht1 hv hm hx.
  rewrite (K32.is_init_full _ hv) (K128.is_init_full _ hx) ?K32.full_set32d ?K128.full_set256d.
  rewrite ?K32.full_init ?K128.full_init /=.
  have h2 := modz_cmp _t 2 _; 1: done.
  have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
  do ?split; try (move=> k hk1 hk2; rewrite ?BArray8.is_init_cell_set32d); smt().
do 15!(rcondf ^if; first by auto => /#).
auto => /> ht0 ht1 hv hm hx _ _ _.
rewrite (K32.is_init_full _ hv) ?K32.full_set32d; try rewrite (K128.is_init_full _ hx).
rewrite ?K32.full_init ?K128.full_init /=.
have h2 := modz_cmp _t 2 _; 1: done.
have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
do ?split; try (move=> k hk1 hk2; rewrite ?BArray8.is_init_cell_set32d); smt().
qed.

(* A 256-bit write of the all-ones word right after an initialised
   prefix of the table extends the prefix. *)
lemma wk_ext (m : BArray512.t) n : 0 <= n => BArray512.is_init m 0 (32 * n) =>
  BArray512.is_init
    (BArray512.set256d m (32 * n)
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    0 (32 * n + 32).
proof.
move=> hn hm j hj1 hj2; rewrite BArray512.is_init_cell_set256d.
by case: (j < 32 * n) => hj; [right; apply hm | left] => /#.
qed.

(* The table entry that round t of block l reads. *)
lemma wk_idx t l : 0 <= t < 64 => 0 <= l < 2 =>
  0 <= (8 * (t %/ 4) + 4 * l + t %% 4) * 4 /\
  (8 * (t %/ 4) + 4 * l + t %% 4) * 4 + 4 <= 32 * (if l = 0 /\ t <= 48 then 4 + (t + 1) %/ 4 else 16).
proof.
move=> ht hl; have := modz_cmp t 4; have := divz_eq t 4; have := divz_eq (t + 1) 4.
by have := modz_cmp (t + 1) 4; smt().
qed.

lemma slot_b k : 0 <= k %% 8 * 4 /\ k %% 8 * 4 + 4 <= 32.
proof. by have := modz_cmp k 8; smt(). qed.

lemma wkn_w l t : (l = 0 /\ t < 48) /\ t %% 4 = 2 =>
  32 * (if l = 0 /\ t + 1 <= 48 then 4 + (t + 1 + 1) %/ 4 else 16) = 32 * (4 + t %/ 4) + 32 /\
  (if l = 0 /\ t <= 48 then 4 + (t + 1) %/ 4 else 16) = 4 + t %/ 4.
proof.
move=> hc; have := divz_eq t 4; have := divz_eq (t + 1) 4; have := divz_eq (t + 2) 4.
have := modz_cmp (t + 1) 4; have := modz_cmp (t + 2) 4; smt().
qed.

lemma wkn_nw l t : 0 <= t < 64 => !((l = 0 /\ t < 48) /\ t %% 4 = 2) =>
  (if l = 0 /\ t + 1 <= 48 then 4 + (t + 1 + 1) %/ 4 else 16)
  = (if l = 0 /\ t <= 48 then 4 + (t + 1) %/ 4 else 16).
proof.
move=> ht hc; have := divz_eq t 4; have := divz_eq (t + 1) 4; have := divz_eq (t + 2) 4.
have := modz_cmp t 4; have := modz_cmp (t + 1) 4; have := modz_cmp (t + 2) 4; smt().
qed.

lemma grp_b t : 0 <= t < 48 =>
  (0 <= (4 + t %/ 4) * 16 /\ (4 + t %/ 4) * 16 + 16 <= 256) /\
  (0 <= (4 + t %/ 4) * 32 /\ (4 + t %/ 4) * 32 + 32 <= 512) /\
  (0 <= t %/ 4 %% 4 * 32 /\ t %/ 4 %% 4 * 32 + 32 <= 128) /\ 0 <= 4 + t %/ 4.
proof. by move=> ht; have := divz_eq t 4; have := modz_cmp t 4; have := modz_cmp (t %/ 4) 4; smt(). qed.

lemma v_ext (m : BArray32.t) i : 0 <= i => BArray32.is_init m 0 (4 * i) =>
  BArray32.is_init (BArray32.set32d m (4 * i) (W32.of_int 4294967295)) 0 (4 * i + 4).
proof.
move=> hi hm j hj1 hj2; rewrite BArray32.is_init_cell_set32d.
by case: (j < 4 * i) => hj; [right; apply hm | left] => /#.
qed.

lemma __sha256_avx2_proof _h _x _nb _ms _h_init _x_init :
  __sha256_avx2_spec _h _x _nb _ms _h_init _x_init.
proof.
rewrite /__sha256_avx2_spec; proc.
wp; while (valid trace___sha256_avx2 /\ 0 <= l /\ inc = nb /\ 0 <= nb <= 2 /\
       BArray32.is_init h_init 0 32 /\ x_init = K128.full /\ v_init = K32.full /\
       BArray512.is_init wk_init 0 (if l = 0 then 128 else 512) /\
       l_init /\ nb_init /\ ms_init /\ i_init /\ lo_init /\ hi_init).
+ wp; while (valid trace___sha256_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= i <= 8 /\
             h_init = K32.full /\ x_init = K128.full /\ v_init = K32.full /\
             BArray512.is_init wk_init 0 512 /\
             l_init /\ nb_init /\ ms_init /\ i_init /\ s_init /\ lo_init /\ hi_init).
  + wp; skip => &hr [[#] hval hl0 hl1 hinc hnb0 hnb1 hi0 hi1 hh hx hv hwk hli hnbi hmsi hii hsi hloi hhii] hc.
    rewrite /= hh hv !K32.full_set32d !K32.full_init !valid_cat hval /valid /= hii hx hwk hli hnbi hmsi hsi /=.
    by move: hi0 hc hl0 hl1 hinc hnb0 hnb1; clear hval hwk; smt().
  wp; while (valid trace___sha256_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= t <= 64 /\
             BArray32.is_init h_init 0 32 /\ x_init = K128.full /\ v_init = K32.full /\
             BArray8.is_init m_init (4 * (t %% 2)) 4 /\
             BArray512.is_init wk_init 0 (32 * (if l = 0 /\ t <= 48 then 4 + (t + 1) %/ 4 else 16)) /\
             l_init /\ nb_init /\ ms_init /\ i_init /\ t_init /\ s_init /\ lo_init /\ hi_init).
  + sp; seq 1 : (valid trace___sha256_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= t < 64 /\
                 BArray32.is_init h_init 0 32 /\ x_init = K128.full /\ v_init = K32.full /\
                 m_init = K8.full /\
                 BArray512.is_init wk_init 0 (32 * (if l = 0 /\ t <= 48 then 4 + (t + 1) %/ 4 else 16)) /\
                 l_init /\ nb_init /\ ms_init /\ i_init /\ t_init /\ s_init /\ lo_init /\ hi_init).
    + if.
      + wp; ecall (__sha256_avx2_round_proof v m s t x lo hi (t %/ 4) (t %% 4) v_init m_init x_init); wp; skip.
        move=> &hr [[vi0 v0 tr0 [#] hv hvi htr hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hvf hm hwk hli hnbi hmsi hii hti hsi hloi hhii ht80] _].
        split; 1: by rewrite /= hvi hvf K32.full_set32d K32.full_init hx K128.full_init /= hm; smt().
        move=> _ r [[[hv' hm'] hx'] hval'].
        have hl2 : 0 <= l{hr} < 2 by move: hl0 hl1 hinc hnb1; clear htr; smt().
        have [hw0 hw1] := wk_idx t{hr} l{hr} _ hl2; 1: by split.
        have hwr : BArray512.is_init wk_init{hr} ((8 * (t{hr} %/ 4) + 4 * l{hr} + t{hr} %% 4) * 4) 4.
        + by apply (K512.is_init_sub _ 0 (32 * (if l{hr} = 0 /\ t{hr} <= 48 then 4 + (t{hr} + 1) %/ 4 else 16))).
        rewrite htr !valid_cat hval hval' /valid /= hvf K32.full_init hwr hli hti hsi hnbi hloi hhii /=.
        rewrite (K32.is_init_full _ hv') (K8.is_init_full _ hm') (K128.is_init_full _ hx') /=.
        rewrite !slot_b hw0 /=.
        split; 1: by move: hw1; clear htr; smt().
        by do ?split => //; move: ht0 ht80; clear htr; smt().
      wp; ecall (__sha256_avx2_round_proof v m s t x lo hi 0 3 v_init m_init x_init); wp; skip.
      move=> &hr [[vi0 v0 tr0 [#] hv hvi htr hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hvf hm hwk hli hnbi hmsi hii hti hsi hloi hhii ht80] _].
      split; 1: by rewrite /= hvi hvf K32.full_set32d K32.full_init hx K128.full_init /= hm; smt().
      move=> _ r [[[hv' hm'] hx'] hval'].
      have hl2 : 0 <= l{hr} < 2 by move: hl0 hl1 hinc hnb1; clear htr; smt().
      have [hw0 hw1] := wk_idx t{hr} l{hr} _ hl2; 1: by split.
      have hwr : BArray512.is_init wk_init{hr} ((8 * (t{hr} %/ 4) + 4 * l{hr} + t{hr} %% 4) * 4) 4.
      + by apply (K512.is_init_sub _ 0 (32 * (if l{hr} = 0 /\ t{hr} <= 48 then 4 + (t{hr} + 1) %/ 4 else 16))).
      rewrite htr !valid_cat hval hval' /valid /= hvf K32.full_init hwr hli hti hsi hnbi hloi hhii /=.
      rewrite (K32.is_init_full _ hv') (K8.is_init_full _ hm') (K128.is_init_full _ hx') /=.
      rewrite !slot_b hw0 /=.
      split; 1: by move: hw1; clear htr; smt().
      by do ?split => //; move: ht0 ht80; clear htr; smt().
    wp; skip => &hr [#] hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hv hm hwk hli hnbi hmsi hii hti hsi hloi hhii.
    rewrite /= hx hv hm K8.full_init /=.
    case: ((l{hr} = 0 /\ t{hr} < 48) /\ t{hr} %% 4 = 2) => hc.
    + have [e1 e2] := wkn_w _ _ hc.
      have [b1 [b2 [b3 b4]]] := grp_b t{hr} _; 1: smt().
      have hw' := wk_ext wk_init{hr} (4 + t{hr} %/ 4) b4 _; 1: by rewrite -e2.
      rewrite !valid_cat hval /valid /= hli hti hnbi K128.full_init b1 b2 b3 e1 hw' /=.
      by do ?split => //; move: hc ht0; clear hval hwk hw'; smt().
    have e := wkn_nw l{hr} t{hr} _ hc; 1: by split.
    rewrite !valid_cat hval /valid /= hli hti hnbi e hwk /=.
    by do ?split => //; move: ht0 ht1; clear hval hwk; smt().
  wp; skip => &hr [[#] hval hl0 hinc hnb0 hnb1 hh hx hv hwk hli hnbi hmsi hii hloi hhii] hl.
  rewrite hv K32.full_init /=; split.
  + have hm0 : forall (m : BArray8.t),
      BArray8.is_init (BArray8.set32d m 0 (W32.of_int 4294967295)) 0 4.
    + by move=> m j hj1 hj2; rewrite BArray8.is_init_cell_set32d; left; smt().
    rewrite !valid_cat hval /valid /= hli hnbi hmsi hii hloi hhii /= K32.full_init hm0 hh hx /=.
    have hwk0 : BArray512.is_init wk_init{hr} 0 (32 * if l{hr} = 0 then 4 else 16).
    + by move: hwk; case: (l{hr} = 0).
    rewrite hwk0 /=.
    by do ?split => //; move: hl0 hl hinc hnb0 hnb1; clear hval hwk hwk0; smt().
  move=> m0 s0 t0 tr0 vi0 wki0 xi0 hc [#] hval' _ _ _ _ _ ht0 ht1 _ hx' hv' _ hwk' _ _ _ _ hs0 _ _.
  have h64 : t0 = 64 by move: hc ht1; clear hval' hwk'; smt().
  subst t0; move: hwk' => /= hwk'.
  rewrite hv' hx' K32.full_set32d K32.full_init /= hwk' hs0 hli hnbi hmsi hloi hhii /=.
  split; 1: by rewrite !valid_cat hval' /valid /=; move: hl0 hl hinc hnb0 hnb1; clear hval hval' hwk'; smt().
  move=> h' i' tr' vi' hc' [#] hval'' _ _ _ _ _ _ _ hh' hv''.
  rewrite hval'' hh' hv'' K32.full_init (_: (l{hr} + 1 = 0) = false) 1:/# /= ?hwk' /=.
  by move: hl0 hinc hnb0 hnb1; clear hval hval' hval''; smt().
wp; while (valid trace___sha256_avx2 /\ 0 <= i <= 8 /\ BArray32.is_init v_init 0 (4 * i) /\
           BArray32.is_init h_init 0 32 /\ BArray512.is_init wk_init 0 128 /\
           i_init /\ nb_init /\ ms_init /\ lo_init /\ hi_init).
+ wp; skip => &hr [[#] hval hi0 hi1 hv hh hwk hii hnbi hmsi hloi hhii] hc.
  have hb : 0 <= i{hr} < 8 by split.
  have hhi : BArray32.is_init h_init{hr} (i{hr} * 4) 4.
  + by apply (K32.is_init_sub _ 0 32) => //; smt().
  rewrite !valid_cat hval /valid /= hii hhi (_: i{hr} * 4 = 4 * i{hr}) 1:/#.
  rewrite (_: 4 * (i{hr} + 1) = 4 * i{hr} + 4) 1:/# v_ext // hh hwk hnbi hmsi hloi hhii /=.
  by move: hb; clear hval hv hh hwk hhi; smt().
wp; while (valid trace___sha256_avx2 /\ 0 <= i <= 4 /\ BArray512.is_init wk_init 0 (32 * i) /\
           BArray128.is_init x_init 0 128 /\ i_init /\ nb_init /\ ms_init).
+ wp; skip => &hr [[#] hval hi0 hi1 hwk hx hii hnbi hmsi] hc.
  have hb : 0 <= i{hr} < 4 by split.
  rewrite !valid_cat hval /valid /= hii (K128.is_init_full _ hx) K128.full_init.
  rewrite (_: i{hr} * 32 = 32 * i{hr}) 1:/# (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/#.
  rewrite wk_ext // K128.full_init hnbi hmsi /=.
  by move: hb; clear hval hwk hx; smt().
wp; skip => /> hnb0 hnb1 hh hx.
split; 1: by move=> j; smt().
move=> i0 tr0 wk0 hc hval hi0 hi1 hwk.
have hi4 : i0 = 4 by smt().
move: hwk; rewrite hi4 /= => hwk.
split; 1: by rewrite !valid_cat hval /valid /= K32.full_init /= hwk /=; move=> j; smt().
move=> i1 tr1 vi hc' hval' hi0' hi1' hv hwk'.
have hi8' : i1 = 8 by smt().
move: hv; rewrite hi8' /= => hv.
rewrite valid_cat hval' /valid /= (K128.is_init_full _ hx) (K32.is_init_full _ hv) /=.
move=> h0 ii0 l0 tr2 wki1 hc'' hval'' _ _ _ _.
by move: hval''; rewrite /valid all_cat => ->.
qed.
