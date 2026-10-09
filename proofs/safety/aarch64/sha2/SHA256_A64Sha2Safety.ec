(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2Safety.ec (aarch64/sha2)
 * ======================================
 *
 * Safety of the AArch64 SHA-256 instruction kernel
 * (src/aarch64/sha2/sha256_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. A contract says that, under
 * its precondition, every array read touches initialised bytes, every
 * memory access is to valid memory, and the outputs it names are
 * initialised; `valid` of the returned trace is the conjunction of the
 * model's asserts.
 *
 * Lemmas:
 *     __sha256_block_a64_proof       the 64 rounds on abcd, efgh, the
 *                                    window m and the constant table k,
 *                                    m and k initialised
 *     _sha256_compress_proof         one block from an initialised array
 *     _sha256_compress_blocks_proof  n blocks from valid memory at p,
 *                                    n < 2^58
 *
 * The message window stays initialised: every write to m is a whole
 * 128-bit slot, so its mask stays full once the four slots are loaded.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray32 BArray64 BArray256.

abbrev a64h256_I32  = BArray32.init_arr (W8.of_int 255).
abbrev a64h256_I64  = BArray64.init_arr (W8.of_int 255).
abbrev a64h256_I256 = BArray256.init_arr (W8.of_int 255).

lemma a64h256_full32 (m : BArray32.t) : BArray32.is_init m 0 32 => m = a64h256_I32.
proof.
move=> hm; rewrite BArray32.tP => j hj.
rewrite /BArray32.init_arr BArray32.initiE //=.
by have := hm j _ _; rewrite /BArray32.is_init_cell /#.
qed.

lemma a64h256_full64 (m : BArray64.t) : BArray64.is_init m 0 64 => m = a64h256_I64.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma a64h256_full256 (m : BArray256.t) : BArray256.is_init m 0 256 => m = a64h256_I256.
proof.
move=> hm; rewrite BArray256.tP => j hj.
rewrite /BArray256.init_arr BArray256.initiE //=.
by have := hm j _ _; rewrite /BArray256.is_init_cell /#.
qed.

lemma a64h256_I32_init a l : BArray32.is_init a64h256_I32 a l.
proof. by move=> j _ _; apply (BArray32.init_arrP witness). qed.

lemma a64h256_I64_init a l : BArray64.is_init a64h256_I64 a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma a64h256_I256_init a l : BArray256.is_init a64h256_I256 a l.
proof. by move=> j _ _; apply (BArray256.init_arrP witness). qed.

lemma a64h256_I32_set128 k :
  BArray32.set128 a64h256_I32 k (W128.of_int 340282366920938463463374607431768211455)
  = a64h256_I32.
proof.
apply a64h256_full32 => j _ _.
by rewrite BArray32.is_init_cell_set128d; right; apply (BArray32.init_arrP witness).
qed.

lemma a64h256_I64_set128 k :
  BArray64.set128 a64h256_I64 k (W128.of_int 340282366920938463463374607431768211455)
  = a64h256_I64.
proof.
apply a64h256_full64 => j _ _.
by rewrite BArray64.is_init_cell_set128d; right; apply (BArray64.init_arrP witness).
qed.

lemma a64h256_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

lemma __sha256_block_a64_proof _abcd _efgh _m _k _m_init _k_init :
  __sha256_block_a64_spec _abcd _efgh _m _k _m_init _k_init.
proof.
rewrite /__sha256_block_a64_spec; proc.
wp.
while (valid trace___sha256_block_a64 /\ g_init /\ abcd_init /\ efgh_init /\
       abcd0_init /\ efgh0_init /\ 12 <= g <= 16 /\
       m_init = a64h256_I64 /\ k_init = a64h256_I256).
- auto => &m [#] hv hg ha he ha0 he0 h12 h16 -> -> hlt.
  rewrite !valid_cat !a64h256_valid1 hv hg ha he /= ?a64h256_I64_init ?a64h256_I256_init /=.
  smt(modz_ge0 ltz_pmod).
wp.
while (valid trace___sha256_block_a64 /\ g_init /\ abcd_init /\ efgh_init /\
       abcd0_init /\ efgh0_init /\ 0 <= g <= 12 /\
       m_init = a64h256_I64 /\ k_init = a64h256_I256).
- auto => &m [#] hv hg ha he ha0 he0 h0 h12 -> -> hlt /=.
  rewrite !valid_cat !a64h256_valid1 hv hg ha he /= ?a64h256_I64_set128.
  rewrite ?a64h256_I64_init ?a64h256_I256_init /=.
  smt(modz_ge0 ltz_pmod).
auto => &m [#] <- <- _ _ _ _ hm hk.
rewrite (a64h256_full64 _ hm) (a64h256_full256 _ hk) /=.
split; first by rewrite ?valid_cat ?a64h256_valid1 /valid.
move=> ai ei g0 mi0 tr0 hlt [#] htr ha he h0 h12 -> /=.
split; first by rewrite htr ha he.
move=> ai1 ei1 g1 tr1 hlt1 [#] htr1 ha1 he1 _ _.
by rewrite !valid_cat !a64h256_valid1 htr1 ha1 he1 a64h256_I64_init.
qed.

lemma a64h256_init_set128 (m : BArray64.t) (j : int) : 0 <= j < 4 =>
  BArray64.is_init m 0 (16 * j) =>
  BArray64.is_init
    (BArray64.set128 m j (W128.of_int 340282366920938463463374607431768211455)) 0 (16 * (j + 1)).
proof.
move=> hj hm i hi0 hi1; rewrite BArray64.is_init_cell_set128d.
by case: (i < 16 * j) => hi; [right; apply hm; smt() | left; smt()].
qed.

lemma _sha256_compress_proof _h _block _ms _h_init _block_init :
  _sha256_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha256_compress_spec; proc.
wp.
ecall (__sha256_block_a64_proof abcd efgh m k m_init k_init).
wp.
while (valid trace__sha256_compress /\ ms_init /\ j_init /\ abcd_init /\ efgh_init /\
       0 <= j <= 4 /\ block_init = a64h256_I64 /\ h_init = a64h256_I32 /\
       BArray64.is_init m_init 0 (16 * j)).
- auto => &m [#] hv hms hj ha he h0 h4 -> -> hmi hlt /=.
  have h1 : BArray64.is_init
              (BArray64.set128d m_init{m} (16 * j{m})
                 (W128.of_int 340282366920938463463374607431768211455)) (j{m} * 16) 16.
  + by move=> i hi0 hi1; rewrite BArray64.is_init_cell_set128d /#.
  have h2 : BArray64.is_init
              (BArray64.set128d (BArray64.set128d m_init{m} (16 * j{m})
                 (W128.of_int 340282366920938463463374607431768211455)) (16 * j{m})
                 (W128.of_int 340282366920938463463374607431768211455)) 0 (16 * (j{m} + 1)).
  + move=> i hi0 hi1; rewrite !BArray64.is_init_cell_set128d.
    by case: (i < 16 * j{m}) => hi; [right; right; apply hmi; smt() | left; smt()].
  rewrite !valid_cat !a64h256_valid1 hv hms hj ha he a64h256_I64_init h1 h2 /=.
  smt().
auto => &m [#] <- <- _ _ _ hh hb.
rewrite (a64h256_full32 _ hh) (a64h256_full64 _ hb) /=.
split; first by rewrite ?valid_cat ?a64h256_valid1 /valid ?a64h256_I32_init /=; smt().
move=> j0 mi0 tr0 hlt [#] htr h0 h4 hmi.
have e : 16 * j0 = 64 by smt().
rewrite -e hmi a64h256_I256_init /=.
move=> r [hr1 hr2].
by rewrite !valid_cat !a64h256_valid1 htr hr2 /= => i hi0 hi1; rewrite !BArray32.is_init_cell_set128d /#.
qed.

lemma a64h256_valid_sub mv (p : W64.t) (n o l : int) :
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

lemma a64h256_valid_step mv (p n : W64.t) :
  is_valid ptr_modulus mv (W64.to_uint p) (64 * W64.to_uint n) => n <> W64.zero =>
  is_valid ptr_modulus mv (W64.to_uint p) 64 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 64)) (64 * W64.to_uint (n - W64.one)).
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
by apply (a64h256_valid_sub _ _ _ _ _ hval); move: hn1; clear hval; smt().
qed.

lemma a64h256_m_set1 (mi : BArray64.t) (j : int) :
  BArray64.is_init
    (BArray64.set128d mi (16 * j) (W128.of_int 340282366920938463463374607431768211455))
    (j * 16) 16.
proof. by move=> i hi0 hi1; rewrite BArray64.is_init_cell_set128d /#. qed.

lemma a64h256_m_set2 (mi : BArray64.t) (j : int) : 0 <= j =>
  BArray64.is_init mi 0 (16 * j) =>
  BArray64.is_init
    (BArray64.set128d (BArray64.set128d mi (16 * j)
       (W128.of_int 340282366920938463463374607431768211455)) (16 * j)
       (W128.of_int 340282366920938463463374607431768211455)) 0 (16 * (j + 1)).
proof.
move=> hj hmi i hi0 hi1; rewrite !BArray64.is_init_cell_set128d.
by case: (i < 16 * j) => hi; [right; right; apply hmi; smt() | left; smt()].
qed.

lemma _sha256_compress_blocks_proof _h _p _n _ms _h_init :
  _sha256_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha256_compress_blocks_spec; proc.
wp.
while (valid trace__sha256_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init /\
       abcd_init /\ efgh_init /\ more = (n <> W64.of_int 0) /\
       h_init = a64h256_I32 /\ k_init = a64h256_I256 /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint n)).
- wp.
  ecall (__sha256_block_a64_proof abcd efgh m k m_init k_init).
  wp.
  while (valid trace__sha256_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init /\
         j_init /\ abcd_init /\ efgh_init /\ 0 <= j <= 4 /\ n <> W64.of_int 0 /\
         h_init = a64h256_I32 /\ k_init = a64h256_I256 /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint n) /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 64 /\
         BArray64.is_init m_init 0 (16 * j)).
  + auto => &m [#] hv hp hn hmi hms hj ha he h0 h4 hn0 -> -> hval hv64 hwi hlt /=.
    rewrite !valid_cat !a64h256_valid1 hv hp hj a64h256_m_set1 a64h256_m_set2 // /=.
    rewrite (a64h256_valid_sub _ _ _ _ _ hv64) 1..3:/# /=.
    by rewrite hn hmi hms ha he hn0 hval hv64 /=; smt().
  auto => &m [#] hv hp hn hmi hms ha he hmore -> -> hval hm.
  have hn' : n{m} <> W64.of_int 0 by rewrite -hmore.
  have [hv64 hval'] := a64h256_valid_step _ _ _ hval hn'.
  rewrite /= !valid_cat !a64h256_valid1 hv hp hn hmi hms ha he hn' hval hv64 /=.
  split; 1: by move=> j /#.
  move=> j0 mi0 tr0 hlt H.
  have htr : valid tr0 by smt().
  have hw64 : BArray64.is_init mi0 0 64.
  + have e : 16 * j0 = 64 by smt().
    by case: H => _ [_]; rewrite e.
  rewrite hw64 a64h256_I256_init /=.
  move=> r [hr1 hr2].
  move: hval' => /= hval'.
  by rewrite !valid_cat !a64h256_valid1 htr hr2 /= hval'.
auto => &m [#] <- _ <- <- _ hh hlt hval /=.
have hn : W64.to_uint _n < 288230376151711744.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 64 * _n) = 64 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
move: hval; rewrite e => hval.
rewrite (a64h256_full32 _ hh) ?a64h256_I32_init hval /=.
split; 1: by rewrite ?valid_cat ?a64h256_valid1 /valid.
move=> ai0 ei0 mo0 moi0 msi0 n0 ni0 p0 pi0 tr0 _ [#] htr _ _ hmoi hmsi hai hei _ _.
rewrite !valid_cat !a64h256_valid1 htr hmoi hmsi hai hei /=.
by move=> i hi0 hi1; rewrite !BArray32.is_init_cell_set128d /#.
qed.
