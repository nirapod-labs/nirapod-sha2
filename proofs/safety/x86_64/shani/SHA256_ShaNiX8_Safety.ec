(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNiX8_Safety.ec
 * ========================
 *
 * Safety of the 8-way SHA-256 kernel on the x86 SHA extensions
 * (src/x86_64/shani/sha256_x8_compress.jinc): for each of its functions F,
 * F_proof proves F_spec of the safety model (NirapodSha2Safety), the Hoare
 * triple stating that the #[safety] contract's precondition gives its
 * postcondition and that every assertion of F's trace holds.
 *
 * As in the single-way kernel, the arrays stay fully initialised: h8, the
 * blocks, w, the state registers and the round-constant table are full on
 * entry or after their first writes, and every write sets the written
 * bytes. The two-lane round loop's wk is written before it is read in
 * every group, so its mask on entry to a group does not matter.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray16 BArray32 BArray64 BArray128 BArray256 BArray512 NirapodSha2Safety Masks Valid.

clone Masks.Masks as K32 with theory A <- BArray32.
clone Masks.Masks as K64 with theory A <- BArray64.
clone Masks.Masks as K128 with theory A <- BArray128.
clone Masks.Masks as K256 with theory A <- BArray256.
clone Masks.Masks as K512 with theory A <- BArray512.

lemma __shani_x8_load_pair_proof _h8 _f _r _h8_init :
  __shani_x8_load_pair_spec _h8 _f _r _h8_init.
proof.
rewrite /__shani_x8_load_pair_spec; proc; unroll for ^while; wp; skip => /> hf0 hf1 hr0 hr1 hh.
rewrite (K256.is_init_full _ hh) !K256.full_init /=; split; last smt().
by move=> j hj1 hj2 /=; smt().
qed.

lemma __shani_x8_store_pair_proof _h8 _st _f _r _h8_init _st_init :
  __shani_x8_store_pair_spec _h8 _st _f _r _h8_init _st_init.
proof.
rewrite /__shani_x8_store_pair_spec; proc; unroll for ^while; wp; skip => /> hf0 hf1 hr0 hr1 hh hs.
rewrite (K256.is_init_full _ hh) (K64.is_init_full _ hs) !K256.full_set128d !K256.full_init.
by rewrite !K64.full_init /=; smt().
qed.

lemma __shani_x8_block2_proof _st _w _k _st_init _w_init _k_init :
  __shani_x8_block2_spec _st _w _k _st_init _w_init _k_init.
proof.
rewrite /__shani_x8_block2_spec; proc; unroll for ^while.
wp; while (valid trace___shani_x8_block2 /\ 0 <= j <= 4 /\ j_init /\
           st_init = K64.full /\ s0_init = K64.full /\ w_init = K128.full).
+ auto => /> &hr hv hj0 _ hj4.
  rewrite !K64.full_set128d !K64.full_init !valid_cat hv /valid /=; smt().
wp; while (valid trace___shani_x8_block2 /\ 0 <= g <= 16 /\ g_init /\ j_init /\
           st_init = K64.full /\ s0_init = K64.full /\ w_init = K128.full /\ k_init = K256.full).
+ unroll for ^while; unroll for ^while; wp; skip => /> &hr hv hg0 _ hg16.
  rewrite !K64.full_set128d !K128.full_set128d !K64.full_init !K128.full_init !K256.full_init.
  rewrite !valid_cat hv /valid /=; smt(K32.set128d_here K32.set128d_keep).
wp; skip => /> hs hw hk.
have hs0 : BArray64.set128d (BArray64.set128d (BArray64.set128d (BArray64.set128d
             (BArray64.init_arr (W8.of_int 0)) 0 K64.ones128) 16 K64.ones128) 32 K64.ones128)
             48 K64.ones128 = K64.full.
+ by apply K64.is_init_full => j hj1 hj2 /=; smt().
rewrite (K64.is_init_full _ hs) (K128.is_init_full _ hw) (K256.is_init_full _ hk) hs0.
rewrite !K64.full_init /valid /= => *; exact (K128.full_init 0 128).
qed.

(* The two halves of the pair's message rows give the whole of w. *)
lemma w_halves (m : BArray128.t) :
  BArray128.is_init m 0 64 => BArray128.is_init m 64 64 => BArray128.is_init m 0 128.
proof. by move=> h1 h2 j hj1 hj2; case: (j < 64) => hj; [apply h1 | apply h2] => /#. qed.

lemma _sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init :
  _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init.
proof.
rewrite /_sha256_x8_compress_spec; proc.
wp; while (valid trace__sha256_x8_compress /\ 0 <= f <= 2 /\ f_init /\
           h8_init = K256.full /\ blocks_init = K512.full /\ k_init = K256.full /\
           mask_p_init = BArray16.init_arr (W8.of_int 255)).
+ wp; while (valid trace__sha256_x8_compress /\ 0 <= f < 2 /\ 0 <= r <= 2 /\ f_init /\ r_init /\
             h8_init = K256.full /\ blocks_init = K512.full /\ k_init = K256.full /\
             mask_p_init = BArray16.init_arr (W8.of_int 255)).
  + wp; ecall (__shani_x8_store_pair_proof h8 st f r h8_init st_init).
    wp; ecall (__shani_x8_block2_proof st w k st_init w_init k_init).
    wp; while (valid trace__sha256_x8_compress /\ 0 <= i <= 4 /\ 0 <= f < 2 /\ 0 <= r < 2 /\
               f_init /\ r_init /\ mask_init /\ i_init /\
               h8_init = K256.full /\ blocks_init = K512.full /\ k_init = K256.full /\
               mask_p_init = BArray16.init_arr (W8.of_int 255) /\
               BArray64.is_init st_init 0 64 /\
               BArray128.is_init w_init 0 (16 * i) /\ BArray128.is_init w_init 64 (16 * i)).
    + auto => /> &hr hv hi0 _ hf0 hf1 hr0 hr1 _ _ _ _ hs hw0 hw4 hi4.
      rewrite !K512.full_init !valid_cat hv /valid /=.
      have e1 : i{hr} * 16 = 16 * i{hr} by ring.
      have e2 : (4 + i{hr}) * 16 = 16 * (4 + i{hr}) by ring.
      rewrite e1 e2 !K128.set128d_here /=; split; first smt().
      split; [smt() | split].
      + move=> j hj1 hj2 /=; case: (16 * i{hr} <= j) => hj; first smt().
        by do 4!right; apply hw0 => /#.
      move=> j hj1 hj2 /=; case: (16 * (4 + i{hr}) <= j) => hj; first smt().
      by do 4!right; apply hw4 => /#.
    wp; ecall (__shani_x8_load_pair_proof h8 f r h8_init); wp; skip => />.
    move=> &hr hv hf0 hf1 hr0 _ _ _ hr2; split; first exact (K256.full_init 0 256).
    move=> _ rs hs hv1; split.
    + rewrite !valid_cat hv hv1 /valid /=; split; last by split; move=> j /#.
      by move=> j _ _; apply (BArray16.init_arrP witness).
    move=> i0 tr0 w0 hi4 hv0 hi0 hi1 hw0 hw4.
    have ->> : i0 = 4 by smt().
    split; first exact (w_halves _ hw0 hw4).
    move=> _ r0 hs0 hw hv2 r1 hh hv3.
    split; first by rewrite !valid_cat hv0 hv2 hv3 /valid.
    split; first smt().
    exact (K256.is_init_full _ hh).
  by auto => />; smt().
wp; skip => /> hh hb.
split; first by rewrite (K256.is_init_full _ hh) (K512.is_init_full _ hb).
move=> f0 tr0 _ hv _ _ _; split; first exact (K256.full_init 0 256).
by rewrite valid_cat hv /valid.
qed.

lemma _sha256_x8_compress_lanes_proof _h8 _in _off _n _ms _h8_init _in_init :
  _sha256_x8_compress_lanes_spec _h8 _in _off _n _ms _h8_init _in_init.
proof.
rewrite /_sha256_x8_compress_lanes_spec; proc.
wp; while (valid trace__sha256_x8_compress_lanes /\ 0 <= f <= 2 /\
           f_init /\ off_init /\ n_init /\ ms_init /\
           h8_init = K256.full /\ in_init = K64.full /\ k_init = K256.full /\
           mask_p_init = BArray16.init_arr (W8.of_int 255) /\
           in_0 = _in /\ off = _off /\ n = _n /\
           forall j, 0 <= j < 8 =>
             is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in j + _off))
               (64 * W64.to_uint _n)).
+ wp; while (valid trace__sha256_x8_compress_lanes /\ 0 <= f < 2 /\ 0 <= r <= 2 /\
             f_init /\ r_init /\ off_init /\ n_init /\ ms_init /\
             h8_init = K256.full /\ in_init = K64.full /\ k_init = K256.full /\
             mask_p_init = BArray16.init_arr (W8.of_int 255) /\
             in_0 = _in /\ off = _off /\ n = _n /\
             forall j, 0 <= j < 8 =>
               is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in j + _off))
                 (64 * W64.to_uint _n)).
  + wp; ecall (__shani_x8_store_pair_proof h8 st f r h8_init st_init).
    wp; while (valid trace__sha256_x8_compress_lanes /\ 0 <= f < 2 /\ 0 <= r < 2 /\
               f_init /\ r_init /\ off_init /\ n_init /\ ms_init /\
               p_init /\ q_init /\ c_init /\ more_init /\
               h8_init = K256.full /\ in_init = K64.full /\ k_init = K256.full /\
               mask_p_init = BArray16.init_arr (W8.of_int 255) /\
               in_0 = _in /\ off = _off /\ n = _n /\
               BArray64.is_init st_init 0 64 /\ more = (c <> W64.of_int 0) /\
               is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint c) /\
               is_valid ptr_modulus Glob.mem_v (W64.to_uint q) (64 * W64.to_uint c)).
    + wp; ecall (__shani_x8_block2_proof st w k st_init w_init k_init).
      wp; while (valid trace__sha256_x8_compress_lanes /\ 0 <= i <= 4 /\
                 f_init /\ r_init /\ off_init /\ n_init /\ ms_init /\
                 p_init /\ q_init /\ c_init /\ more_init /\ mask_init /\ i_init /\
                 h8_init = K256.full /\ in_init = K64.full /\ k_init = K256.full /\
                 mask_p_init = BArray16.init_arr (W8.of_int 255) /\
                 BArray64.is_init st_init 0 64 /\
                 is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 64 /\
                 is_valid ptr_modulus Glob.mem_v (W64.to_uint q) 64 /\
                 BArray128.is_init w_init 0 (16 * i) /\ BArray128.is_init w_init 64 (16 * i)).
      + auto => &hr [#] hv hi0 hi1 hf hr hoi hni hmi hpi hqi hci hmo hmk hii -> -> -> -> hs hvp hvq hw0 hw4 hi4.
        rewrite /= !valid_cat hv /valid /=.
        have e1 : i{hr} * 16 = 16 * i{hr} by ring.
        have e2 : (4 + i{hr}) * 16 = 16 * (4 + i{hr}) by ring.
        rewrite e1 e2 !K128.set128d_here /=.
        rewrite (valid_sub _ _ _ _ _ hvp) 1..3:/# (valid_sub _ _ _ _ _ hvq) 1..3:/# /=.
        split; first by move: hi0 hi4; clear hvp hvq hw0 hw4 hv; smt().
        split; first by move: hi0 hi4; clear hvp hvq hw0 hw4 hv; smt().
        do 14!(split; first done).
        split.
        + move=> j hj1 hj2 /=; case: (16 * i{hr} <= j) => hj; first smt().
          by do 4!right; apply hw0 => /#.
        move=> j hj1 hj2 /=; case: (16 * (4 + i{hr}) <= j) => hj; first smt().
        by do 4!right; apply hw4 => /#.
      wp; skip => &hr [#] hv hf0 hf1 hr0 hr1 hf hr hoi hni hmi hpi hqi hci hmo -> -> -> -> -> -> -> hs hmore hvp hvq hm.
      have hn : c{hr} <> W64.zero by move: hm; rewrite hmore.
      have [hp64 hp'] := valid_step 64 _ _ _ _ hvp hn; 1: done.
      have [hq64 hq'] := valid_step 64 _ _ _ _ hvq hn; 1: done.
      rewrite /= !valid_cat hv /valid /= hf hr hoi hni hpi hqi hci hmo hs hp64 hq64 hp' hq' /=; split.
      + by split; [split; [done | move=> j _ _; apply (BArray16.init_arrP witness)] | split; move=> j /#].
      move=> /> i0 tr0 wi0 hi4 hv0 hi0 hi1 hw0 hw4.
      have e : i0 = 4 by move: hi4 hi1; clear hv0 hv hw0 hw4; smt().
      move: hw0 hw4; rewrite e /= => hw0 hw4.
      split; first by split; [exact (w_halves _ hw0 hw4) | exact (K256.full_init 0 256)].
      by move=> _ _ rs hs1 hw1 hv1; rewrite !all_cat hv0 hv1.
    wp; ecall (__shani_x8_load_pair_proof h8 f r h8_init); wp; skip.
    move=> &hr [#] hv hf0 hf1 hr0 _ hf hr hoi hni hmi -> -> -> -> -> -> -> hlv hr2.
    have hpa : 0 <= 4 * f{hr} + 2 * r{hr} < 8 by move: hf0 hf1 hr0 hr2; clear hlv hv; smt().
    have hpb : 0 <= 4 * f{hr} + 2 * r{hr} + 1 < 8 by move: hf0 hf1 hr0 hr2; clear hlv hv; smt().
    have hva := hlv _ hpa; have hvb := hlv _ hpb.
    split; first by rewrite /= hf0 hf1 hr0 hr2 /=; exact (K256.full_init 0 256).
    move=> _ rs [hs hv1].
    have epa : SLH64.protect_64 (BArray64.get64 _in (4 * f{hr} + 2 * r{hr})) ms{hr} + _off
               = BArray64.get64 _in (4 * f{hr} + 2 * r{hr}) + _off by rewrite /SLH64.protect_64.
    have epb : SLH64.protect_64 (BArray64.get64 _in (4 * f{hr} + 2 * r{hr} + 1)) ms{hr} + _off
               = BArray64.get64 _in (4 * f{hr} + 2 * r{hr} + 1) + _off by rewrite /SLH64.protect_64.
    rewrite /= epa epb hva hvb !valid_cat hv hv1 /valid /= hf hr hoi hni hmi hs !K64.full_init /=.
    split; first by move: hpa hpb hf0 hf1 hr0 hr2; clear hlv hva hvb hv; smt().
    move=> c0 ci mo moi mi p0 pi q0 qi sti tr0 hmo [#] hv0 *.
    split; first by rewrite K256.full_init /=; do !split => //.
    move=> _ rs0 [hh hv2]; rewrite !all_cat hv0 hv2 /=.
    rewrite (K256.is_init_full _ hh) /=; do !split; try exact hlv;
      by move: hf0 hf1 hr0 hr2; clear hlv hva hvb hv hv0 hv2; smt().
  wp; skip => &hr [#] hv hf0 hf1 hf hoi hni hmi -> -> -> -> -> -> -> hlv hf2; split.
  + by rewrite /=; do !split => //.
  move=> h8i mi' r' tr' hr' [#] hv' _ _ hr0 hr1 hf' hri hoi' hni' hmi' -> _ _ _ _ _ _ hlv'.
  by rewrite /=; do !split => //; move: hf0 hf2; clear hlv hlv' hv hv'; smt().
wp; skip => &hr [#] e1 e2 e3 e4 e5 e6 e7
  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  hh hin hn hoff hv0 hv1 hv2 hv3 hv4 hv5 hv6 hv7.
rewrite -e1 -e2 -e4 -e5 -e6 /= (K256.is_init_full _ hh) (K64.is_init_full _ hin) /=.
have hn' : W64.to_uint _n < 288230376151711744.
+ by move: hn; rewrite W64.ultE W64.to_uint_small.
have e64 : W64.to_uint (W64.of_int 64 * _n) = 64 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn'; clear hv0 hv1 hv2 hv3 hv4 hv5 hv6 hv7; smt(W64.to_uint_cmp).
move: hv0 hv1 hv2 hv3 hv4 hv5 hv6 hv7; rewrite e64 => hv0 hv1 hv2 hv3 hv4 hv5 hv6 hv7.
split.
+ split; first by rewrite /valid.
  move=> j hj; have : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 \/ j = 4 \/ j = 5 \/ j = 6 \/ j = 7.
  + by move: hj; clear hv0 hv1 hv2 hv3 hv4 hv5 hv6 hv7; smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
move=> f0 h8i' mi0 tr0 hf [#] hv0' _ _ hmi -> _.
by rewrite K256.full_init valid_cat hv0' /valid /= hmi.
qed.
