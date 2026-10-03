(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2_Safety.ec
 * =====================
 *
 * Safety of the SHA-512 AVX2 kernel (src/x86_64/avx2/sha512_compress.jinc):
 * for each of its functions F, F_proof proves F_spec of the safety model
 * (NirapodSha2Safety, extracted by jasmin2ec -m safety), the Hoare triple
 * stating that the #[safety] contract's precondition gives its
 * postcondition and that every assertion of F's trace holds (array
 * accesses in bounds and initialised, memory accesses valid).
 *
 * The working variables v and the schedule window x stay fully
 * initialised. Of m, the round reads the half it was given and writes the
 * other. The W + K table wk is written group by group, and the driver
 * reads only groups already written: groups 0 .. 7 before the rounds,
 * group 8 + t / 2 after round t of the first block (t odd, t < 64).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray16 BArray32 BArray64 BArray128 BArray256 BArray640 BArray1280.
require import NirapodSha2Safety Masks Valid.

clone Masks.Masks as K16 with theory A <- BArray16.
clone Masks.Masks as K64 with theory A <- BArray64.
clone Masks.Masks as K128 with theory A <- BArray128.
clone Masks.Masks as K256 with theory A <- BArray256.
clone Masks.Masks as K1280 with theory A <- BArray1280.

lemma __sha512_avx2_round_proof _v _m _s _t _x _j _ph _v_init _m_init _x_init :
  __sha512_avx2_round_spec _v _m _s _t _x _j _ph _v_init _m_init _x_init.
proof.
rewrite /__sha512_avx2_round_spec; proc.
case (ph = 0).
+ do 6!((rcondt ^if; first by auto); (rcondf ^if; first by auto)); rcondt ^if; first by auto.
  auto => /> ht0 ht1 hv hm hx.
  rewrite (K64.is_init_full _ hv) (K256.is_init_full _ hx) ?K64.full_set64d ?K256.full_set256d.
  rewrite ?K64.full_init ?K256.full_init /=.
  have h2 := modz_cmp _t 2 _; 1: done.
  have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
  do ?split; try (move=> k hk1 hk2; rewrite ?BArray16.is_init_cell_set64d); smt().
case (ph = 1).
+ do 6!((rcondf ^if; first by auto); (rcondt ^if; first by auto)); rcondf ^if; first by auto.
  auto => /> ht0 ht1 hv hm hx.
  rewrite (K64.is_init_full _ hv) (K256.is_init_full _ hx) ?K64.full_set64d ?K256.full_set256d.
  rewrite ?K64.full_init ?K256.full_init /=.
  have h2 := modz_cmp _t 2 _; 1: done.
  have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
  do ?split; try (move=> k hk1 hk2; rewrite ?BArray16.is_init_cell_set64d); smt().
do 13!(rcondf ^if; first by auto).
auto => /> ht0 ht1 hv hm hx _ _.
rewrite (K64.is_init_full _ hv) ?K64.full_set64d; try rewrite (K256.is_init_full _ hx).
rewrite ?K64.full_init ?K256.full_init /=.
have h2 := modz_cmp _t 2 _; 1: done.
have h21 : (_t + 1) %% 2 = 1 - _t %% 2 by smt().
do ?split; try (move=> k hk1 hk2; rewrite ?BArray16.is_init_cell_set64d); smt().
qed.

(* A 256-bit write of the all-ones word right after an initialised
   prefix of the table extends the prefix. *)
lemma wk_ext (m : BArray1280.t) n : 0 <= n => BArray1280.is_init m 0 (32 * n) =>
  BArray1280.is_init
    (BArray1280.set256d m (32 * n)
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    0 (32 * n + 32).
proof.
move=> hn hm j hj1 hj2; rewrite BArray1280.is_init_cell_set256d.
by case: (j < 32 * n) => hj; [right; apply hm | left] => /#.
qed.

(* The table entry that round t of block l reads. *)
lemma wk_idx t l : 0 <= t < 80 => 0 <= l < 2 =>
  0 <= (4 * (t %/ 2) + 2 * l + t %% 2) * 8 /\
  (4 * (t %/ 2) + 2 * l + t %% 2) * 8 + 8 <= 32 * (if l = 0 /\ t <= 64 then 8 + t %/ 2 else 40).
proof. by move=> ht hl; have := modz_cmp t 2; have := divz_eq t 2; smt(). qed.

lemma slot_b k : 0 <= k %% 8 * 8 /\ k %% 8 * 8 + 8 <= 64.
proof. by have := modz_cmp k 8; smt(). qed.

lemma wkn_odd l t : (l = 0 /\ t < 64) /\ t %% 2 = 1 =>
  32 * (if l = 0 /\ t + 1 <= 64 then 8 + (t + 1) %/ 2 else 40) = 32 * (8 + t %/ 2) + 32 /\
  (if l = 0 /\ t <= 64 then 8 + t %/ 2 else 40) = 8 + t %/ 2.
proof. by move=> hc; have := divz_eq t 2; have := divz_eq (t + 1) 2; have := modz_cmp (t + 1) 2; smt(). qed.

lemma wkn_even l t : 0 <= t < 80 => !((l = 0 /\ t < 64) /\ t %% 2 = 1) =>
  (if l = 0 /\ t + 1 <= 64 then 8 + (t + 1) %/ 2 else 40) = (if l = 0 /\ t <= 64 then 8 + t %/ 2 else 40).
proof.
move=> ht hc; have := divz_eq t 2; have := divz_eq (t + 1) 2; have := modz_cmp (t + 1) 2.
by have := modz_cmp t 2; smt().
qed.

lemma grp_b t : 0 <= t < 64 =>
  (0 <= (8 + t %/ 2) * 16 /\ (8 + t %/ 2) * 16 + 16 <= 640) /\
  (0 <= (8 + t %/ 2) * 32 /\ (8 + t %/ 2) * 32 + 32 <= 1280) /\
  (0 <= t %/ 2 %% 8 * 32 /\ t %/ 2 %% 8 * 32 + 32 <= 256) /\ 0 <= 8 + t %/ 2.
proof. by move=> ht; have := divz_eq t 2; have := modz_cmp t 2; have := modz_cmp (t %/ 2) 8; smt(). qed.

lemma v_ext (m : BArray64.t) i : 0 <= i => BArray64.is_init m 0 (8 * i) =>
  BArray64.is_init (BArray64.set64d m (8 * i) (W64.of_int 18446744073709551615)) 0 (8 * i + 8).
proof.
move=> hi hm j hj1 hj2; rewrite BArray64.is_init_cell_set64d.
by case: (j < 8 * i) => hj; [right; apply hm | left] => /#.
qed.

lemma __sha512_avx2_proof _h _x _nb _ms _h_init _x_init :
  __sha512_avx2_spec _h _x _nb _ms _h_init _x_init.
proof.
rewrite /__sha512_avx2_spec; proc.
wp; while (valid trace___sha512_avx2 /\ 0 <= l /\ inc = nb /\ 0 <= nb <= 2 /\
       BArray64.is_init h_init 0 64 /\ x_init = K256.full /\ v_init = K64.full /\
       BArray1280.is_init wk_init 0 (if l = 0 then 256 else 1280) /\
       l_init /\ nb_init /\ ms_init /\ i_init).
+ wp; while (valid trace___sha512_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= i <= 8 /\
             h_init = K64.full /\ x_init = K256.full /\ v_init = K64.full /\
             BArray1280.is_init wk_init 0 1280 /\
             l_init /\ nb_init /\ ms_init /\ i_init /\ s_init).
  + wp; skip => &hr [[#] hval hl0 hl1 hinc hnb0 hnb1 hi0 hi1 hh hx hv hwk hli hnbi hmsi hii hsi] hc.
    rewrite /= hh hv !K64.full_set64d !K64.full_init !valid_cat hval /valid /= hii hx hwk hli hnbi hmsi hsi /=.
    by move: hi0 hc hl0 hl1 hinc hnb0 hnb1; clear hval hwk; smt().
  wp; while (valid trace___sha512_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= t <= 80 /\
             BArray64.is_init h_init 0 64 /\ x_init = K256.full /\ v_init = K64.full /\
             BArray16.is_init m_init (8 * (t %% 2)) 8 /\
             BArray1280.is_init wk_init 0 (32 * (if l = 0 /\ t <= 64 then 8 + t %/ 2 else 40)) /\
             l_init /\ nb_init /\ ms_init /\ i_init /\ t_init /\ s_init).
  + sp; seq 1 : (valid trace___sha512_avx2 /\ 0 <= l < inc /\ inc = nb /\ 0 <= nb <= 2 /\ 0 <= t < 80 /\
                 BArray64.is_init h_init 0 64 /\ x_init = K256.full /\ v_init = K64.full /\
                 m_init = K16.full /\
                 BArray1280.is_init wk_init 0 (32 * (if l = 0 /\ t <= 64 then 8 + t %/ 2 else 40)) /\
                 l_init /\ nb_init /\ ms_init /\ i_init /\ t_init /\ s_init).
    + if.
      + wp; ecall (__sha512_avx2_round_proof v m s t x (t %/ 2) (t %% 2) v_init m_init x_init); wp; skip.
        move=> &hr [[vi0 v0 tr0 [#] hv hvi htr hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hvf hm hwk hli hnbi hmsi hii hti hsi ht80] _].
        split; 1: by rewrite /= hvi hvf K64.full_set64d K64.full_init hx K256.full_init /= hm; smt().
        move=> _ r [[[hv' hm'] hx'] hval'].
        have hl2 : 0 <= l{hr} < 2 by move: hl0 hl1 hinc hnb1; clear htr; smt().
        have [hw0 hw1] := wk_idx t{hr} l{hr} _ hl2; 1: by split.
        have hwr : BArray1280.is_init wk_init{hr} ((4 * (t{hr} %/ 2) + 2 * l{hr} + t{hr} %% 2) * 8) 8.
        + by apply (K1280.is_init_sub _ 0 (32 * (if l{hr} = 0 /\ t{hr} <= 64 then 8 + t{hr} %/ 2 else 40))).
        rewrite htr !valid_cat hval hval' /valid /= hvf K64.full_init hwr hli hti hsi hnbi /=.
        rewrite (K64.is_init_full _ hv') (K16.is_init_full _ hm') (K256.is_init_full _ hx') /=.
        rewrite !slot_b hw0 /=.
        split; 1: by move: hw1; clear htr; smt().
        by do ?split => //; move: ht0 ht80; clear htr; smt().
    wp; ecall (__sha512_avx2_round_proof v m s t x 0 2 v_init m_init x_init); wp; skip.
      move=> &hr [[vi0 v0 tr0 [#] hv hvi htr hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hvf hm hwk hli hnbi hmsi hii hti hsi ht80] _].
      split; 1: by rewrite /= hvi hvf K64.full_set64d K64.full_init hx K256.full_init /= hm; smt().
      move=> _ r [[[hv' hm'] hx'] hval'].
      have hl2 : 0 <= l{hr} < 2 by move: hl0 hl1 hinc hnb1; clear htr; smt().
      have [hw0 hw1] := wk_idx t{hr} l{hr} _ hl2; 1: by split.
      have hwr : BArray1280.is_init wk_init{hr} ((4 * (t{hr} %/ 2) + 2 * l{hr} + t{hr} %% 2) * 8) 8.
      + by apply (K1280.is_init_sub _ 0 (32 * (if l{hr} = 0 /\ t{hr} <= 64 then 8 + t{hr} %/ 2 else 40))).
      rewrite htr !valid_cat hval hval' /valid /= hvf K64.full_init hwr hli hti hsi hnbi /=.
      rewrite (K64.is_init_full _ hv') (K16.is_init_full _ hm') (K256.is_init_full _ hx') /=.
      rewrite !slot_b hw0 /=.
      split; 1: by move: hw1; clear htr; smt().
      by do ?split => //; move: ht0 ht80; clear htr; smt().
    wp; skip => &hr [#] hval hl0 hl1 hinc hnb0 hnb1 ht0 ht1 hh hx hv hm hwk hli hnbi hmsi hii hti hsi.
    rewrite /= hx hv hm K16.full_init /=.
    case: ((l{hr} = 0 /\ t{hr} < 64) /\ t{hr} %% 2 = 1) => hc.
    + have [e1 e2] := wkn_odd _ _ hc.
      have [b1 [b2 [b3 b4]]] := grp_b t{hr} _; 1: smt().
      have hw' := wk_ext wk_init{hr} (8 + t{hr} %/ 2) b4 _; 1: by rewrite -e2.
      rewrite !valid_cat hval /valid /= hli hti hnbi K256.full_init b1 b2 b3 e1 hw' /=.
      by do ?split => //; move: hc ht0; clear hval hwk hw'; smt().
    have e := wkn_even l{hr} t{hr} _ hc; 1: by split.
    rewrite !valid_cat hval /valid /= hli hti hnbi e hwk /=.
    by do ?split => //; move: ht0 ht1; clear hval hwk; smt().
  wp; skip => &hr [[#] hval hl0 hinc hnb0 hnb1 hh hx hv hwk hli hnbi hmsi hii] hl.
  rewrite hv K64.full_init /=; split.
  + have hm0 : forall (m : BArray16.t),
      BArray16.is_init (BArray16.set64d m 0 (W64.of_int 18446744073709551615)) 0 8.
    + by move=> m j hj1 hj2; rewrite BArray16.is_init_cell_set64d; left; smt().
    rewrite !valid_cat hval /valid /= hli hnbi hmsi hii /= K64.full_init hm0 hh hx /=.
    have hwk0 : BArray1280.is_init wk_init{hr} 0 (32 * if l{hr} = 0 then 8 else 40).
    + by move: hwk; case: (l{hr} = 0).
    rewrite hwk0 /=.
    by do ?split => //; move: hl0 hl hinc hnb0 hnb1; clear hval hwk hwk0; smt().
  move=> m0 s0 t0 tr0 vi0 wki0 xi0 hc [#] hval' _ _ _ _ _ ht0 ht1 _ hx' hv' _ hwk' _ _ _ _ hs0.
  have h80 : t0 = 80 by move: hc ht1; clear hval' hwk'; smt().
  subst t0; move: hwk' => /= hwk'.
  rewrite hv' hx' K64.full_set64d K64.full_init /= hwk' hs0 /=.
  split; 1: by rewrite !valid_cat hval' /valid /= hmsi.
  move=> h' i' tr' vi' hc' [#] hval'' _ _ _ _ _ _ _ hh' hv'' _ _ _.
  rewrite hval'' hh' hv'' K64.full_init (_: (l{hr} + 1 = 0) = false) 1:/# /= hwk' /=.
  by move: hl0 hinc hnb0 hnb1; clear hval hval' hval''; smt().
wp; while (valid trace___sha512_avx2 /\ 0 <= i <= 8 /\ BArray64.is_init v_init 0 (8 * i) /\
           BArray64.is_init h_init 0 64 /\ BArray1280.is_init wk_init 0 256 /\
           i_init /\ nb_init /\ ms_init).
+ wp; skip => &hr [[#] hval hi0 hi1 hv hh hwk hii hnbi hmsi] hc.
  have hb : 0 <= i{hr} < 8 by split.
  have hhi : BArray64.is_init h_init{hr} (i{hr} * 8) 8.
  + by apply (K64.is_init_sub _ 0 64) => //; smt().
  rewrite !valid_cat hval /valid /= hii hhi (_: i{hr} * 8 = 8 * i{hr}) 1:/#.
  rewrite (_: 8 * (i{hr} + 1) = 8 * i{hr} + 8) 1:/# v_ext // hh hwk /=.
  by move: hb; clear hval hv hh hwk hhi; smt().
wp; while (valid trace___sha512_avx2 /\ 0 <= i <= 8 /\ BArray1280.is_init wk_init 0 (32 * i) /\
           BArray256.is_init x_init 0 256 /\ i_init /\ nb_init /\ ms_init).
+ wp; skip => &hr [[#] hval hi0 hi1 hwk hx hii hnbi hmsi] hc.
  have hb : 0 <= i{hr} < 8 by split.
  rewrite !valid_cat hval /valid /= hii (K256.is_init_full _ hx) K256.full_init.
  rewrite (_: i{hr} * 32 = 32 * i{hr}) 1:/# (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/#.
  rewrite wk_ext // K256.full_init hnbi hmsi /=.
  by move: hb; clear hval hwk hx; smt().
wp; skip => /> hnb0 hnb1 hh hx.
split; 1: by move=> j; smt().
move=> i0 tr0 wk0 hc hval hi0 hi1 hwk.
have hi8 : i0 = 8 by smt().
move: hwk; rewrite hi8 /= => hwk.
split; 1: by split; [move=> j; smt() | exact hwk].
move=> i1 tr1 vi hc' hval' hi0' hi1' hv hwk'.
have hi8' : i1 = 8 by smt().
move: hv; rewrite hi8' /= => hv.
rewrite valid_cat hval' /valid /= (K256.is_init_full _ hx) (K64.is_init_full _ hv) /=.
move=> h0 ii0 l0 tr2 wki1 hc'' hval'' _ _ _ _.
by move: hval''; rewrite /valid all_cat => ->.
qed.

(* ------------------------------------------------------------------ *)
(* Entry points                                                        *)

lemma x_ext (m : BArray256.t) i : 0 <= i => BArray256.is_init m 0 (32 * i) =>
  BArray256.is_init
    (BArray256.set256d m (32 * i)
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    0 (32 * i + 32).
proof.
move=> hi hm j hj1 hj2; rewrite BArray256.is_init_cell_set256d.
by case: (j < 32 * i) => hj; [right; apply hm | left] => /#.
qed.

lemma x_here (m : BArray256.t) i :
  BArray256.is_init
    (BArray256.set256d m i
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    i 32.
proof. by move=> j hj1 hj2; rewrite BArray256.is_init_cell_set256d; left. qed.

lemma _sha512_compress_proof _h _block _ms _h_init _block_init :
  _sha512_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha512_compress_spec; proc; wp.
ecall (__sha512_avx2_proof h x 1 ms h_init x_init); wp.
while (valid trace__sha512_compress /\ i_init /\ mask_init /\ ms_init /\ 0 <= i <= 8 /\
       BArray128.is_init block_init 0 128 /\ BArray64.is_init h_init 0 64 /\
       BArray256.is_init x_init 0 (32 * i)).
+ wp; skip => &hr [[#] hv hii hmi hms hi0 hi1 hb hh hxi] hlt.
  have hbi : BArray128.is_init block_init{hr} (i{hr} * 16) 16.
  + by apply (K128.is_init_sub _ 0 128) => //; smt().
  rewrite /= !valid_cat hv /valid /= hii hmi hms hbi hb hh (_: i{hr} * 32 = 32 * i{hr}) 1:/# x_here.
  have h1 := x_ext x_init{hr} i{hr} hi0 hxi.
  have h2 := x_ext _ i{hr} hi0 (K256.is_init_sub _ 0 (32 * i{hr} + 32) 0 (32 * i{hr}) _ _ h1); 1,2: smt().
  rewrite (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/# h2 /=.
  by move: hi0 hlt; clear hv h1 h2; smt().
auto => /> hh hb; split.
+ rewrite /valid /=; split; 1: by move=> j _ _; apply (BArray32.init_arrP witness).
  by move=> j /#.
move=> i tr xi hi8 hv hi0 hil hxi.
have e : 32 * i = 256 by smt().
move: hxi; rewrite e => hxi; split; 1: done.
move=> _ r _ hvr.
by rewrite !valid_cat hv hvr /valid.
qed.

lemma _sha512_compress_one_proof _h _p _ms _h_init : _sha512_compress_one_spec _h _p _ms _h_init.
proof.
rewrite /_sha512_compress_one_spec; proc; wp.
ecall (__sha512_avx2_proof h x 1 ms h_init x_init); wp.
while (valid trace__sha512_compress_one /\ i_init /\ mask_init /\ ms_init /\ p_init /\ 0 <= i <= 8 /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 128 /\ BArray64.is_init h_init 0 64 /\
       BArray256.is_init x_init 0 (32 * i)).
+ wp; skip => &hr [[#] hv hii hmi hms hpi hi0 hi1 hval hh hxi] hlt.
  have hm := valid_sub _ _ _ (16 * i{hr}) 16 hval _ _ _; 1..3: smt().
  rewrite /= !valid_cat hv /valid /= hii hmi hms hpi hm hval hh (_: i{hr} * 32 = 32 * i{hr}) 1:/# x_here.
  have h1 := x_ext x_init{hr} i{hr} hi0 hxi.
  have h2 := x_ext _ i{hr} hi0 (K256.is_init_sub _ 0 (32 * i{hr} + 32) 0 (32 * i{hr}) _ _ h1); 1,2: smt().
  rewrite (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/# h2 /=.
  by move: hi0 hlt; clear hv h1 h2 hval hm; smt().
auto => /> &hr hh hv1 hv2 hv3; split.
+ split; 1: by move=> j _ _; apply (BArray32.init_arrP witness).
  by move=> j /#.
move=> i tr xi hi8 hv hi0 hil hxi.
have e : 32 * i = 256 by smt().
move: hxi; rewrite e => hxi; split; 1: done.
move=> _ r _ hvr.
by rewrite !valid_cat hv hvr /valid.
qed.

lemma _sha512_compress_two_proof _h _p _ms _h_init : _sha512_compress_two_spec _h _p _ms _h_init.
proof.
rewrite /_sha512_compress_two_spec; proc; wp.
ecall (__sha512_avx2_proof h x 2 ms h_init x_init); wp.
while (valid trace__sha512_compress_two /\ i_init /\ mask_init /\ ms_init /\ p_init /\ 0 <= i <= 8 /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 256 /\ BArray64.is_init h_init 0 64 /\
       BArray256.is_init x_init 0 (32 * i)).
+ wp; skip => &hr [[#] hv hii hmi hms hpi hi0 hi1 hval hh hxi] hlt.
  have hm := valid_sub _ _ _ (16 * i{hr}) 16 hval _ _ _; 1..3: smt().
  have hm1 := valid_sub _ _ _ 128 128 hval _ _ _; 1..3: smt().
  have hm2 := valid_sub _ _ _ (16 * i{hr}) 16 hm1 _ _ _; 1..3: smt().
  rewrite /= !valid_cat hv /valid /= hii hmi hms hpi hm hm2 hval hh (_: i{hr} * 32 = 32 * i{hr}) 1:/#.
  rewrite !x_here.
  have h1 := x_ext x_init{hr} i{hr} hi0 hxi.
  have h2 := x_ext _ i{hr} hi0 (K256.is_init_sub _ 0 (32 * i{hr} + 32) 0 (32 * i{hr}) _ _ h1); 1,2: smt().
  have h3 := x_ext _ i{hr} hi0 (K256.is_init_sub _ 0 (32 * i{hr} + 32) 0 (32 * i{hr}) _ _ h2); 1,2: smt().
  rewrite (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/# h3 /=.
  by move: hi0 hlt; clear hv h1 h2 h3 hval hm hm1 hm2; smt().
auto => /> &hr hh hv1 hv2 hv3; split.
+ split; 1: by move=> j _ _; apply (BArray32.init_arrP witness).
  by move=> j /#.
move=> i tr xi hi8 hv hi0 hil hxi.
have e : 32 * i = 256 by smt().
move: hxi; rewrite e => hxi; split; 1: done.
move=> _ r _ hvr.
by rewrite !valid_cat hv hvr /valid.
qed.

lemma valid_pre mv (p : W64.t) n l : is_valid ptr_modulus mv (W64.to_uint p) n => 0 <= l <= n =>
  is_valid ptr_modulus mv (W64.to_uint p) l.
proof.
rewrite /is_valid => -[hv [h0 hb]] hl; split; 1: by move=> j hj; apply hv; smt().
by move: h0 hb hl; clear hv; smt().
qed.

lemma ule2s (n : W64.t) : (W64.of_int 2 \ule n) = (2 <= W64.to_uint n).
proof. by rewrite W64.uleE W64.of_uintK pmod_small. qed.

lemma sub2 (n : W64.t) : 2 <= W64.to_uint n => W64.to_uint (n - W64.of_int 2) = W64.to_uint n - 2.
proof.
by move=> h2; rewrite W64.to_uintB 1:ule2s //.
qed.

lemma _sha512_compress_blocks_proof _h _p _n _ms _h_init :
  _sha512_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha512_compress_blocks_spec; proc.
seq 10 : (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ ms_init /\ more_init /\
          !more /\ more = (2 <= W64.to_uint n) /\ BArray64.is_init h_init 0 64 /\
          is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n)).
+ while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ ms_init /\ more_init /\
         more = (2 <= W64.to_uint n) /\ BArray64.is_init h_init 0 64 /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n)).
  + wp; ecall (_sha512_compress_two_proof h p ms h_init); wp; skip.
    move=> &hr [[#] hv hpi hni hmsi hmi hmore hh hval] hc.
    have h2 : 2 <= W64.to_uint n{hr} by rewrite -hmore.
    rewrite /= /SLH64.protect_64 hh (valid_pre _ _ _ 256 hval) /=; 1: by move: h2; clear hval; smt().
    move=> r [hr hvr]; rewrite ule2s sub2 // hr /=.
    rewrite !valid_cat hv hvr /valid /= hpi hni hmi hmsi /=.
    have := valid_sub _ _ _ 256 (128 * (W64.to_uint n{hr} - 2)) hval _ _ _; 1..3: by move: h2; clear hval; smt().
    by move=> ->.
  wp; skip => &hr [#] 5!->> _ _ _ hh hlt hval0.
  have hn : W64.to_uint n{hr} < 144115188075855872.
  + by move: hlt; rewrite W64.ultE W64.to_uint_small.
  have e : W64.to_uint (W64.of_int 128 * n{hr}) = 128 * W64.to_uint n{hr}.
  + rewrite W64.to_uintM_small W64.to_uint_small //.
    by move: hn; smt(W64.to_uint_cmp).
  move: hval0; rewrite e => hval0.
  split; 1: by rewrite /valid /= ule2s hh hval0.
  move=> h0 mo moi msi n0 ni p0 pi tr hmo [#] hv hpi hni hms hmi hmore hh0 hval.
  by do 8!(split; 1: assumption); assumption.
sp; if.
+ wp; ecall (_sha512_compress_one_proof h p ms h_init); wp; skip.
  move=> &hr [[moi0 mo0 msi0 ms0 tr0 [#] _ hmsi1 hmore' hmoi1 htr hv hpi hni hmsi hmoi hmo hmo2 hh hval] hc].
  have hne : n{hr} <> W64.zero by rewrite -hmore'.
  have hn2 : W64.to_uint n{hr} < 2 by move: hmo; rewrite hmo2; smt().
  have h1 : W64.to_uint n{hr} = 1.
  + case: (W64.to_uint n{hr} = 0) => hz; last by move: hn2 hz; smt(W64.to_uint_cmp).
    by move: hne; rewrite W64.to_uint_eq hz W64.to_uint0.
  split.
  + by rewrite /= hh (valid_pre _ _ _ 128 hval) // h1.
  move=> _ r [hr3 hvr] /=; rewrite hr3 /=.
  by rewrite htr !valid_cat hv hvr /valid /= hpi hmsi hmoi hmsi1 hmoi1 hni.
wp; skip => &hr [[moi0 mo0 msi0 ms0 tr0 [#] _ hmsi1 hmore' hmoi1 htr hv hpi hni hmsi hmoi hmo hmo2 hh hval] hc].
by rewrite /= hh htr !valid_cat hv /valid /= hmsi hmoi hmsi1 hmoi1 hni.
qed.
