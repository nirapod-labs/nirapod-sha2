(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64ScalarSafety.ec (aarch64/scalar)
 * ==========================================
 *
 * Safety of the AArch64 scalar SHA-512 kernel
 * (src/aarch64/scalar/sha512_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. A contract says that, under
 * its precondition, every array read touches initialised bytes, every
 * memory access is to valid memory, and the outputs it names are
 * initialised; `valid` of the returned trace is the conjunction of the
 * model's asserts.
 *
 * Lemmas:
 *     a64s512_bswap64_proof          the REV leaf, used by the callers
 *     _sha512_rounds_a64_proof       the rounds on h, the window w and the
 *                                    constant table k, all initialised
 *     _sha512_compress_proof         one block from an initialised array
 *     _sha512_compress_blocks_proof  n blocks from valid memory at p,
 *                                    n < 2^57
 *
 * Every mask the rounds read is full: the working variables v are
 * copied from h before the first round, and the Maj slots abc are
 * written before they are read (abc[1] before round 0, abc[t mod 2] in
 * round t).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray16 BArray64 BArray128 BArray640.

abbrev a64s512_IA   = BArray16.init_arr (W8.of_int 255).
abbrev a64s512_IH  = BArray64.init_arr (W8.of_int 255).
abbrev a64s512_IW  = BArray128.init_arr (W8.of_int 255).
abbrev a64s512_IK = BArray640.init_arr (W8.of_int 255).

lemma a64s512_fullH (m : BArray64.t) : BArray64.is_init m 0 64 => m = a64s512_IH.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma a64s512_fullW (m : BArray128.t) : BArray128.is_init m 0 128 => m = a64s512_IW.
proof.
move=> hm; rewrite BArray128.tP => j hj.
rewrite /BArray128.init_arr BArray128.initiE //=.
by have := hm j _ _; rewrite /BArray128.is_init_cell /#.
qed.

lemma a64s512_fullA (m : BArray16.t) : BArray16.is_init m 0 16 => m = a64s512_IA.
proof.
move=> hm; rewrite BArray16.tP => j hj.
rewrite /BArray16.init_arr BArray16.initiE //=.
by have := hm j _ _; rewrite /BArray16.is_init_cell /#.
qed.

lemma a64s512_fullK (m : BArray640.t) : BArray640.is_init m 0 640 => m = a64s512_IK.
proof.
move=> hm; rewrite BArray640.tP => j hj.
rewrite /BArray640.init_arr BArray640.initiE //=.
by have := hm j _ _; rewrite /BArray640.is_init_cell /#.
qed.

lemma a64s512_IA_init a l : BArray16.is_init a64s512_IA a l.
proof. by move=> j _ _; apply (BArray16.init_arrP witness). qed.

lemma a64s512_IH_init a l : BArray64.is_init a64s512_IH a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma a64s512_IW_init a l : BArray128.is_init a64s512_IW a l.
proof. by move=> j _ _; apply (BArray128.init_arrP witness). qed.

lemma a64s512_IK_init a l : BArray640.is_init a64s512_IK a l.
proof. by move=> j _ _; apply (BArray640.init_arrP witness). qed.

lemma a64s512_IA_set64 k :
  BArray16.set64 a64s512_IA k (W64.of_int 18446744073709551615) = a64s512_IA.
proof.
apply a64s512_fullA => j _ _.
by rewrite BArray16.is_init_cell_set64d; right; apply (BArray16.init_arrP witness).
qed.

lemma a64s512_IH_set64 k :
  BArray64.set64 a64s512_IH k (W64.of_int 18446744073709551615) = a64s512_IH.
proof.
apply a64s512_fullH => j _ _.
by rewrite BArray64.is_init_cell_set64d; right; apply (BArray64.init_arrP witness).
qed.

lemma a64s512_IW_set64 k :
  BArray128.set64 a64s512_IW k (W64.of_int 18446744073709551615) = a64s512_IW.
proof.
apply a64s512_fullW => j _ _.
by rewrite BArray128.is_init_cell_set64d; right; apply (BArray128.init_arrP witness).
qed.

lemma a64s512_IA_set64d k :
  BArray16.set64d a64s512_IA k (W64.of_int 18446744073709551615) = a64s512_IA.
proof.
apply a64s512_fullA => j _ _.
by rewrite BArray16.is_init_cell_set64d; right; apply (BArray16.init_arrP witness).
qed.

lemma a64s512_IH_set64d k :
  BArray64.set64d a64s512_IH k (W64.of_int 18446744073709551615) = a64s512_IH.
proof.
apply a64s512_fullH => j _ _.
by rewrite BArray64.is_init_cell_set64d; right; apply (BArray64.init_arrP witness).
qed.

lemma a64s512_IW_set64d k :
  BArray128.set64d a64s512_IW k (W64.of_int 18446744073709551615) = a64s512_IW.
proof.
apply a64s512_fullW => j _ _.
by rewrite BArray128.is_init_cell_set64d; right; apply (BArray128.init_arrP witness).
qed.

lemma a64s512_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

lemma a64s512_bswap64_proof _x : __bswap64_spec _x.
proof. by rewrite /__bswap64_spec; proc; auto => />; rewrite /valid. qed.

(* The Maj slots after abc[1] is written, before round 0. *)
abbrev a64s512_A1 = BArray16.set64d (BArray16.init_arr (W8.of_int 0)) 8 (W64.of_int 18446744073709551615).

lemma a64s512_A1_set0 : BArray16.set64d a64s512_A1 0 (W64.of_int 18446744073709551615) = a64s512_IA.
proof.
apply a64s512_fullA => j hj0 hj8.
by rewrite !BArray16.is_init_cell_set64d /#.
qed.

lemma _sha512_rounds_a64_proof _h _w _k _ms _h_init _w_init _k_init :
  _sha512_rounds_a64_spec _h _w _k _ms _h_init _w_init _k_init.
proof.
rewrite /_sha512_rounds_a64_spec; proc.
wp.
while (valid trace__sha512_rounds_a64 /\ ms_init /\ i_init /\ 0 <= i <= 8 /\
       h_init = a64s512_IH /\ v_init = a64s512_IH /\ w_init = a64s512_IW).
- auto => &m [#] hv hms hi h0 h8 -> -> -> hlt.
  rewrite !valid_cat ?a64s512_valid1 hv hi a64s512_IH_init a64s512_IH_set64 /=.
  smt().
wp.
while (valid trace__sha512_rounds_a64 /\ ms_init /\ t_init /\ 0 <= t <= 80 /\
       h_init = a64s512_IH /\ v_init = a64s512_IH /\ w_init = a64s512_IW /\
       k_init = a64s512_IK /\
       abc_init = (if t = 0 then a64s512_A1 else a64s512_IA)).
- seq 22 : (valid trace__sha512_rounds_a64 /\ ms_init /\ t_init /\ 0 <= t < 80 /\
            h_init = a64s512_IH /\ v_init = a64s512_IH /\ w_init = a64s512_IW /\
            k_init = a64s512_IK /\
            abc_init = (if t = 0 then a64s512_A1 else a64s512_IA) /\
            ia_init /\ ib_init /\ id_init /\ ie_init /\ iff_init /\ ig_init /\ ih_init /\
            ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\ id = (3 + 80 - t) %% 8 /\
            ie = (4 + 80 - t) %% 8 /\ iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
            ih = (7 + 80 - t) %% 8).
  + auto => &m [#] hv hms ht h0 h64 -> -> -> -> -> hlt.
    by rewrite !valid_cat !a64s512_valid1 hv ht /= /#.
  if.
  + auto => &m [#] hv hms ht h0 h64 -> -> -> -> -> hia hib hid hie hif hig hih -> -> -> -> -> -> -> h16.
    rewrite (_ : t{m} <> 0) 1:/# /=.
    rewrite !valid_cat !a64s512_valid1 hv hms ht hia hib hid hie hif hig hih /=.
    rewrite ?a64s512_IA_set64d ?a64s512_IH_set64d ?a64s512_IW_set64d.
    rewrite ?a64s512_IA_init ?a64s512_IH_init ?a64s512_IW_init ?a64s512_IK_init /=.
    smt(modz_ge0 ltz_pmod).
  auto => &m [#] hv hms ht h0 h64 -> -> -> -> -> hia hib hid hie hif hig hih -> -> -> -> -> -> -> h16.
  rewrite /= !valid_cat !a64s512_valid1 hv hms ht hia hib hid hie hif hig hih /=.
  case: (t{m} = 0) => [-> /=|hne].
  + rewrite a64s512_A1_set0.
    rewrite ?a64s512_IA_set64d ?a64s512_IH_set64d ?a64s512_IW_set64d.
    by rewrite ?a64s512_IA_init ?a64s512_IH_init ?a64s512_IW_init ?a64s512_IK_init /=.
  rewrite ?a64s512_IA_set64d ?a64s512_IH_set64d ?a64s512_IW_set64d.
  rewrite ?a64s512_IA_init ?a64s512_IH_init ?a64s512_IW_init ?a64s512_IK_init /=.
  smt(modz_ge0 ltz_pmod).
wp.
while (valid trace__sha512_rounds_a64 /\ ms_init /\ i_init /\ 0 <= i <= 8 /\
       h_init = a64s512_IH /\ w_init = a64s512_IW /\ k_init = a64s512_IK /\
       BArray64.is_init v_init 0 (8 * i)).
- auto => &m [#] hv hms hi h0 h8 -> -> -> hvi hlt.
  rewrite /= !valid_cat !a64s512_valid1 hv hms hi ?a64s512_IH_init /=.
  split; 1: smt().
  split; 1: smt().
  move=> j hj1 hj2; rewrite BArray64.is_init_cell_set64d.
  by case: (j < 8 * i{m}) => hj; [right; apply hvi; smt() | left; smt()].
auto => &m [#] <- <- <- _ _ _ _ hh hw hk.
rewrite (a64s512_fullH _ hh) (a64s512_fullW _ hw) (a64s512_fullK _ hk) /=.
split; 1: by split; [rewrite /valid | move=> j /#].
move=> i0 tr0 vi0 hlt [#] htr h0 h8 hvi.
have e : 8 * i0 = 64 by smt().
have -> := a64s512_fullH vi0 _; 1: by rewrite -e.
rewrite !valid_cat !a64s512_valid1 htr ?a64s512_IH_init /=.
move=> abc0 t0 tr1 vi1 wi0 hlt1 [#] htr1 _ _ -> -> _; rewrite htr1 /=.
move=> h_i1 i1 tr2 hlt2 [#] htr2 _ _ ->.
by rewrite valid_cat a64s512_valid1 htr2 ?a64s512_IH_init ?a64s512_IW_init.
qed.

lemma _sha512_compress_proof _h _block _ms _h_init _block_init :
  _sha512_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha512_compress_spec; proc.
wp.
ecall (_sha512_rounds_a64_proof h w k ms h_init w_init k_init).
wp.
while (valid trace__sha512_compress /\ ms_init /\ i_init /\ 0 <= i <= 16 /\
       block_init = a64s512_IW /\ BArray128.is_init w_s_init 0 (8 * i)).
- wp.
  ecall (a64s512_bswap64_proof x).
  auto => &m [#] hv hms hi h0 h16 -> hwi hlt r hr.
  rewrite /= !valid_cat !a64s512_valid1 hv hr hi ?a64s512_IW_init /=.
  do 3!(split; 1: smt()).
  move=> j hj1 hj2; rewrite BArray128.is_init_cell_set64d.
  by case: (j < 8 * i{m}) => hj; [right; apply hwi; smt() | left; smt()].
auto => &m [#] <- <- _ _ _ hh hb.
rewrite (a64s512_fullW _ hb) /=.
split; 1: by split; [rewrite /valid | move=> j /#].
move=> i0 tr0 wi0 hi [#] htr h0 h16 hwi.
have e : 8 * i0 = 128 by smt().
rewrite -e hh hwi a64s512_IK_init /=.
move=> r [hr1 hr2].
by rewrite hr1 /= !valid_cat !a64s512_valid1 htr hr2.
qed.

lemma a64s512_valid_sub mv (p : W64.t) (n o l : int) :
  is_valid ptr_modulus mv (W64.to_uint p) n => 0 <= o => 0 <= l => o + l <= n =>
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int o)) l.
proof.
move=> hval ho hl hol; have := hval; rewrite /is_valid => -[hv [h0 hb]].
have hlt : W64.to_uint p + o < W64.modulus by move: hb hol hl; clear hv hval; smt().
have -> : W64.to_uint (p + W64.of_int o) = W64.to_uint p + o.
+ rewrite W64.to_uintD_small W64.to_uint_small //; move: hlt ho; clear hv hval; smt(W64.to_uint_cmp).
split; 1: by move=> j hj; apply hv; move: hj ho hol hl; clear hv hval; smt().
by move: h0 hb ho hol hl; clear hv hval; smt().
qed.

lemma a64s512_valid_step mv (p n : W64.t) :
  is_valid ptr_modulus mv (W64.to_uint p) (128 * W64.to_uint n) => n <> W64.zero =>
  is_valid ptr_modulus mv (W64.to_uint p) 128 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 128)) (128 * W64.to_uint (n - W64.one)).
proof.
move=> hval hn.
have hn1 : 1 <= W64.to_uint n.
+ have hc := W64.to_uint_cmp n.
  have : W64.to_uint n <> 0.
  + by move: hn; apply contra => h; rewrite W64.to_uint_eq h.
  by move: hc; clear hval; smt().
have -> : W64.to_uint (n - W64.one) = W64.to_uint n - 1.
+ by rewrite W64.to_uintB ?W64.uleE W64.to_uint1.
split.
+ have := hval; rewrite is_validP => h; apply h; move: hn1; clear h hval; smt().
by apply (a64s512_valid_sub _ _ _ _ _ hval); move: hn1; clear hval; smt().
qed.

lemma _sha512_compress_blocks_proof _h _p _n _ms _h_init :
  _sha512_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha512_compress_blocks_spec; proc.
wp.
while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init /\
       more = (n <> W64.of_int 0) /\ BArray64.is_init h_init 0 64 /\
       k_init = a64s512_IK /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n)).
- wp.
  ecall (_sha512_rounds_a64_proof h w k ms h_init w_init k_init).
  wp.
  while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ ms_init /\ i_init /\
         0 <= i <= 16 /\ n <> W64.of_int 0 /\ BArray64.is_init h_init 0 64 /\
         k_init = a64s512_IK /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n) /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 128 /\
         BArray128.is_init w_init 0 (8 * i)).
  + wp.
    ecall (a64s512_bswap64_proof x).
    auto => &m [#] hv hp hn hms hi h0 h16 hn0 hh -> hval hv64 hwi hlt r hr.
    rewrite /= !valid_cat !a64s512_valid1 hv hr hi hp /=.
    rewrite (a64s512_valid_sub _ _ _ _ _ hv64) 1..3:/# /=.
    rewrite hn0 hh hval hv64 hn hms /=.
    do 2!(split; 1: smt()).
    move=> j hj1 hj2; rewrite BArray128.is_init_cell_set64d.
    by case: (j < 8 * i{m}) => hj; [right; apply hwi; smt() | left; smt()].
  auto => &m [#] hv hp hn hmi hms hmore hh -> hval hm.
  have hn' : n{m} <> W64.of_int 0 by rewrite -hmore.
  have [hv64 hval'] := a64s512_valid_step _ _ _ hval hn'.
  rewrite /= !valid_cat !a64s512_valid1 hv hp hn hmi hms hn' hh hval hv64 /=.
  split; 1: by move=> j /#.
  move=> i0 tr0 wi0 hlt [#] htr hi0 hi16 hwi.
  have hw64 : BArray128.is_init wi0 0 128.
  + by have <- : 8 * i0 = 128 by smt().
  rewrite hw64 a64s512_IK_init /=.
  move=> r [[hr1 hr2] hr3].
  move: hval' => /= hval'.
  by rewrite !valid_cat !a64s512_valid1 htr hr1 hr3 /= hval'.
auto => &m [#] <- _ <- <- _ hh hlt hval /=.
have hn : W64.to_uint _n < 144115188075855872.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 128 * _n) = 128 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
move: hval; rewrite e => hval.
rewrite hh hval /=; split; 1: by rewrite /valid.
move=> hi0 m0 mi0 msi0 n0 ni0 p0 pi0 tr0 _ [#] htr _ _ hmi hmsi _ hh0 _.
by rewrite hh0 !valid_cat !a64s512_valid1 htr hmi hmsi.
qed.
