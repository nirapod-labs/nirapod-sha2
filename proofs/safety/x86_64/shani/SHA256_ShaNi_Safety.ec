(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNi_Safety.ec
 * ======================
 *
 * Safety of the SHA-256 kernel on the x86 SHA extensions
 * (src/x86_64/shani/sha256_compress.jinc): for each of its functions F,
 * F_proof proves F_spec of the safety model (NirapodSha2Safety, extracted
 * by jasmin2ec -m safety), the Hoare triple stating that the #[safety]
 * contract's precondition gives its postcondition and that every assertion
 * of F's trace holds (array accesses in bounds and initialised, memory
 * accesses valid).
 *
 * The kernel keeps its arrays fully initialised: w and the round-constant
 * table are full on entry and every write sets the written bytes, so the
 * masks stay full (Masks.ec).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray16 BArray32 BArray64 BArray256 NirapodSha2Safety Masks Valid.

clone Masks.Masks as K32 with theory A <- BArray32.
clone Masks.Masks as K64 with theory A <- BArray64.
clone Masks.Masks as K256 with theory A <- BArray256.

lemma __shani_load_state_proof _h _h_init : __shani_load_state_spec _h _h_init.
proof.
rewrite /__shani_load_state_spec; by proc; auto => /> hi; split; apply (K32.is_init_sub _ 0 32).
qed.

lemma __shani_store_state_proof _h _abef _cdgh _h_init :
  __shani_store_state_spec _h _abef _cdgh _h_init.
proof.
rewrite /__shani_store_state_spec; proc; auto => /> j hj1 hj2.
by rewrite !BArray32.is_init_cell_set128d /#.
qed.

lemma __shani_block_proof _abef _cdgh _w _k _w_init _k_init :
  __shani_block_spec _abef _cdgh _w _k _w_init _k_init.
proof.
rewrite /__shani_block_spec; proc; wp.
while (valid trace___shani_block /\ g_init /\ abef_init /\ cdgh_init /\
       abef0_init /\ cdgh0_init /\ 0 <= g <= 16 /\ w_init = K64.full /\ k_init = K256.full).
+ auto => /> &hr hv hgi hai hci ha0 hc0 hg0 hg16 hlt.
  rewrite !K64.full_set128d !K64.full_init !K256.full_init !valid_cat hv /valid /=.
  smt().
auto => /> hw hk; split; first by rewrite (K64.is_init_full _ hw) (K256.is_init_full _ hk).
by move=> ai ci g tr _ hv *; rewrite K64.full_init !valid_cat hv /valid.
qed.

lemma __shani_rounds_proof _h _w _h_init _w_init : __shani_rounds_spec _h _w _h_init _w_init.
proof.
rewrite /__shani_rounds_spec; proc; wp.
ecall (__shani_store_state_proof h abef cdgh h_init); wp.
ecall (__shani_block_proof abef cdgh w k w_init k_init); wp.
ecall (__shani_load_state_proof h h_init); auto => /> hh hw r1 hv1.
rewrite K256.full_init /= => r2 _ hv2 r3 _ hv3.
by rewrite -/(valid _) !valid_cat hv1 hv2 hv3 /valid.
qed.

lemma _sha256_compress_proof _h _block _ms _h_init _block_init :
  _sha256_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha256_compress_spec; proc; wp.
ecall (__shani_rounds_proof h w h_init w_init); wp.
while (valid trace__sha256_compress /\ i_init /\ mask_init /\ ms_init /\ 0 <= i <= 4 /\
       block_init = K64.full /\ BArray32.is_init h_init 0 32 /\ BArray64.is_init w_init 0 (16 * i)).
+ auto => /> &hr hv hii hmi hms hi0 _ hh hwi hlt.
  rewrite !K64.full_init !valid_cat hv /valid /=.
  have e : i{hr} * 16 = 16 * i{hr} by ring.
  rewrite e (_: 16 * (i{hr} + 1) = 16 * i{hr} + 16) 1:/#.
  smt(K64.set128d_here K64.set128d_keep K64.set128d_ext0).
auto => /> hh hb; split.
+ rewrite (K64.is_init_full _ hb) /=; split; last by move=> j /#.
  by move=> j _ _; apply (BArray16.init_arrP witness).
move=> i tr wi hi4 hv hi0 hil _ hwi.
have e : 16 * i = 64 by smt().
move: hwi; rewrite e => hwi; rewrite hwi /= => r _ hvr.
by rewrite !valid_cat hv hvr /valid.
qed.

lemma _sha256_compress_one_proof _h _p _ms _h_init : _sha256_compress_one_spec _h _p _ms _h_init.
proof.
rewrite /_sha256_compress_one_spec; proc; wp.
ecall (__shani_rounds_proof h w h_init w_init); wp.
while (valid trace__sha256_compress_one /\ i_init /\ p_init /\ mask_init /\ ms_init /\
       0 <= i <= 4 /\ is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 64 /\
       BArray32.is_init h_init 0 32 /\ BArray64.is_init w_init 0 (16 * i)).
+ auto => &hr [#] hv hii hpi hmi hms hi0 hi4 hval hh hwi hlt.
  rewrite /= !valid_cat hv (valid_sub _ _ _ _ _ hval) 1..3:/# /valid /= hii hpi hmi hms hval hh /=.
  have e : i{hr} * 16 = 16 * i{hr} by ring.
  rewrite e (_: 16 * (i{hr} + 1) = 16 * i{hr} + 16) 1:/#.
  smt(K64.set128d_here K64.set128d_keep K64.set128d_ext0).
auto => &hr [#] 4!->> hh hval /=; split.
+ rewrite hval hh /valid /=; split; last by move=> j /#.
  by move=> j _ _; apply (BArray16.init_arrP witness).
move=> i tr wi hi4 [#] hv hi0 hil _ hh' hwi.
have e : 16 * i = 64 by smt().
move: hwi; rewrite e => hwi; rewrite hwi hh' /= => r [hr hvr].
by rewrite hr !valid_cat hv hvr /valid.
qed.

lemma _sha256_compress_blocks_proof _h _p _n _ms _h_init :
  _sha256_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha256_compress_blocks_spec; proc; wp.
ecall (__shani_store_state_proof h abef cdgh h_init); wp.
while (valid trace__sha256_compress_blocks /\ p_init /\ n_init /\ ms_init /\ more_init /\
       abef_init /\ cdgh_init /\ mask_init /\ more = (n <> W64.of_int 0) /\
       BArray32.is_init h_init 0 32 /\ k_init = K256.full /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint n)).
+ wp; ecall (__shani_block_proof abef cdgh w k w_init k_init); wp.
  while (valid trace__sha256_compress_blocks /\ p_init /\ n_init /\ ms_init /\ more_init /\
       abef_init /\ cdgh_init /\ mask_init /\ i_init /\ n <> W64.of_int 0 /\ 0 <= i <= 4 /\
       BArray32.is_init h_init 0 32 /\ k_init = K256.full /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint n) /\
       BArray64.is_init w_init 0 (16 * i)).
  + auto => &hr [#] hv hpi hni hms hmo hai hci hmi hii hn hi0 hi4 hh hk hval hwi hlt.
    have [hv64 _] := valid_step 64 _ _ _ _ hval hn; 1: done.
    rewrite /= !valid_cat hv (valid_sub _ _ _ _ _ hv64) 1..3:/# /valid /=.
    rewrite hpi hni hms hmo hai hci hmi hii hn hh hk hval /=.
    have e : i{hr} * 16 = 16 * i{hr} by ring.
    rewrite e (_: 16 * (i{hr} + 1) = 16 * i{hr} + 16) 1:/#.
    smt(K64.set128d_here K64.set128d_keep K64.set128d_ext0).
  auto => &hr [#] hv hpi hni hms hmo hai hci hmi hmore hh hk hval hm.
  have hn : n{hr} <> W64.zero by smt().
  rewrite !valid_cat hv /valid /= hpi hni hmo hai hci hmi hh hk hval hn /=.
  split; first by rewrite hms; move=> j /#.
  move=> i tr wi hi4 [#] hv' hi0 hil hwi.
  have e : 16 * i = 64 by smt().
  move: hwi; rewrite e => hwi; rewrite hwi K256.full_init /= => r [_ hvr].
  have [_ hval'] := valid_step 64 _ _ _ _ hval hn; 1: done.
  by rewrite !all_cat hv' hvr /= hval'.
wp; ecall (__shani_load_state_proof h h_init); auto => &hr [#] 5!->> hh hlt hval0.
have hn : W64.to_uint n{hr} < 288230376151711744.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 64 * n{hr}) = 64 * W64.to_uint n{hr}.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
move: hval0; rewrite e => hval0.
rewrite hh hval0 /= => r hr.
move: hr; rewrite /valid /= !all_cat => -> /=; split.
+ by move=> j _ _; apply (BArray16.init_arrP witness).
move=> ai ci mo moi msi n0 ni p0 pi tr hmo [#] hv _ _ hms hmi hai hci _ _ r0 [hr0 hvr0].
by rewrite hr0 !all_cat hv hvr0 /= hmi hms hai hci.
qed.
