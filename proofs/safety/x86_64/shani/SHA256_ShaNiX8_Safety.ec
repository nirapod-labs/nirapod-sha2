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
