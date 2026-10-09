(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Sha2X4Safety.ec (aarch64/sha2)
 * ========================================
 *
 * Safety of the AArch64 4-way SHA-512 instruction kernel
 * (src/aarch64/sha2/sha512_x4_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. `valid` of the returned trace
 * is the conjunction of the model's asserts.
 *
 * Lemmas:
 *     __sha512_x4_load_pair_proof        two lanes of h4 into s, i < 2
 *     __sha512_x4_store_pair_proof       s back into h4, i < 2
 *     __sha512_x4_block2_proof           one block on both lanes of s
 *     _sha512_x4_compress_proof          one block per lane from an array
 *     _sha512_x4_compress_lanes_proof    n blocks per lane from valid
 *                                        memory at in[k] + off, n < 2^57
 *
 * The pair state s is ten 16-byte slots, five per lane: lane l owns
 * slots 5 l .. 5 l + 4. The load fills slots 0 .. 3 of each lane; the
 * fifth (the free slot i4) is first written by the first pair of rounds,
 * on lane 0 and then lane 1 (a64x4_lslots). The slot indices i0 .. i4 are
 * always a permutation of 0 .. 4.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray32 BArray128 BArray160 BArray256 BArray512 BArray640.

abbrev a64x4_ONE  = W128.of_int 340282366920938463463374607431768211455.
abbrev a64x4_I32  = BArray32.init_arr (W8.of_int 255).
abbrev a64x4_I128 = BArray128.init_arr (W8.of_int 255).
abbrev a64x4_I160 = BArray160.init_arr (W8.of_int 255).
abbrev a64x4_I256 = BArray256.init_arr (W8.of_int 255).
abbrev a64x4_I512 = BArray512.init_arr (W8.of_int 255).
abbrev a64x4_I640 = BArray640.init_arr (W8.of_int 255).

lemma a64x4_full32 (m : BArray32.t) : BArray32.is_init m 0 32 => m = a64x4_I32.
proof.
move=> hm; rewrite BArray32.tP => j hj.
rewrite /BArray32.init_arr BArray32.initiE //=.
by have := hm j _ _; rewrite /BArray32.is_init_cell /#.
qed.

lemma a64x4_full128 (m : BArray128.t) : BArray128.is_init m 0 128 => m = a64x4_I128.
proof.
move=> hm; rewrite BArray128.tP => j hj.
rewrite /BArray128.init_arr BArray128.initiE //=.
by have := hm j _ _; rewrite /BArray128.is_init_cell /#.
qed.

lemma a64x4_full160 (m : BArray160.t) : BArray160.is_init m 0 160 => m = a64x4_I160.
proof.
move=> hm; rewrite BArray160.tP => j hj.
rewrite /BArray160.init_arr BArray160.initiE //=.
by have := hm j _ _; rewrite /BArray160.is_init_cell /#.
qed.

lemma a64x4_full256 (m : BArray256.t) : BArray256.is_init m 0 256 => m = a64x4_I256.
proof.
move=> hm; rewrite BArray256.tP => j hj.
rewrite /BArray256.init_arr BArray256.initiE //=.
by have := hm j _ _; rewrite /BArray256.is_init_cell /#.
qed.

lemma a64x4_full512 (m : BArray512.t) : BArray512.is_init m 0 512 => m = a64x4_I512.
proof.
move=> hm; rewrite BArray512.tP => j hj.
rewrite /BArray512.init_arr BArray512.initiE //=.
by have := hm j _ _; rewrite /BArray512.is_init_cell /#.
qed.

lemma a64x4_full640 (m : BArray640.t) : BArray640.is_init m 0 640 => m = a64x4_I640.
proof.
move=> hm; rewrite BArray640.tP => j hj.
rewrite /BArray640.init_arr BArray640.initiE //=.
by have := hm j _ _; rewrite /BArray640.is_init_cell /#.
qed.

lemma a64x4_I32_init a l : BArray32.is_init a64x4_I32 a l.
proof. by move=> j _ _; apply (BArray32.init_arrP witness). qed.

lemma a64x4_I128_init a l : BArray128.is_init a64x4_I128 a l.
proof. by move=> j _ _; apply (BArray128.init_arrP witness). qed.

lemma a64x4_I160_init a l : BArray160.is_init a64x4_I160 a l.
proof. by move=> j _ _; apply (BArray160.init_arrP witness). qed.

lemma a64x4_I256_init a l : BArray256.is_init a64x4_I256 a l.
proof. by move=> j _ _; apply (BArray256.init_arrP witness). qed.

lemma a64x4_I512_init a l : BArray512.is_init a64x4_I512 a l.
proof. by move=> j _ _; apply (BArray512.init_arrP witness). qed.

lemma a64x4_I640_init a l : BArray640.is_init a64x4_I640 a l.
proof. by move=> j _ _; apply (BArray640.init_arrP witness). qed.

lemma a64x4_I160_set128 k : BArray160.set128 a64x4_I160 k a64x4_ONE = a64x4_I160.
proof.
apply a64x4_full160 => j _ _.
by rewrite BArray160.is_init_cell_set128d; right; apply (BArray160.init_arrP witness).
qed.

lemma a64x4_I256_set128 k : BArray256.set128 a64x4_I256 k a64x4_ONE = a64x4_I256.
proof.
apply a64x4_full256 => j _ _.
by rewrite BArray256.is_init_cell_set128d; right; apply (BArray256.init_arrP witness).
qed.

lemma a64x4_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

(* A 16-byte slot read after a 16-byte slot write. *)
lemma a64x4_slot160 (si : BArray160.t) (x y : int) :
  BArray160.is_init (BArray160.set128d si (16 * x) a64x4_ONE) (y * 16) 16
  = (x = y \/ BArray160.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray160.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray160.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

lemma a64x4_slot256 (si : BArray256.t) (x y : int) :
  BArray256.is_init (BArray256.set128d si (16 * x) a64x4_ONE) (y * 16) 16
  = (x = y \/ BArray256.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray256.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray256.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

(* ------------------------------------------------------------------ *)
(* Load and store                                                     *)

lemma a64x4_pair_step (si : BArray160.t) q : 0 <= q =>
  BArray160.is_init si 0 (16 * q) => BArray160.is_init si 80 (16 * q) =>
  let si' = BArray160.set128d (BArray160.set128d si (16 * q) a64x4_ONE)
              (16 * (5 + q)) a64x4_ONE in
  BArray160.is_init si' 0 (16 * (q + 1)) /\ BArray160.is_init si' 80 (16 * (q + 1)).
proof.
move=> hq h0 h80 /=; split => i hi0 hi1; rewrite !BArray160.is_init_cell_set128d.
+ by case: (i < 16 * q) => hi; [right; right; apply h0; smt() | right; left; smt()].
by case: (i < 80 + 16 * q) => hi; [right; right; apply h80; smt() | left; smt()].
qed.

lemma __sha512_x4_load_pair_proof _h4 _i _h4_init : __sha512_x4_load_pair_spec _h4 _i _h4_init.
proof.
rewrite /__sha512_x4_load_pair_spec; proc.
while (valid trace___sha512_x4_load_pair /\ q_init /\ i_init /\ 0 <= q <= 4 /\
       0 <= i < 2 /\ h4_init = a64x4_I256 /\
       BArray160.is_init s_init 0 (16 * q) /\ BArray160.is_init s_init 80 (16 * q)).
- auto => &m [#] hv hq hi h0 h4 hi0 hi1 -> hs0 hs80 hlt /=.
  have [h1 h2] := a64x4_pair_step _ _ h0 hs0 hs80.
  rewrite !valid_cat !a64x4_valid1 hv hq hi !a64x4_I256_init h1 h2 /=.
  smt().
auto => &m [#] <- <- _ hi0 hi1 hh.
rewrite (a64x4_full256 _ hh) /=.
split; 1: by rewrite /valid /=; smt().
move=> q0 si0 tr0 hlt [#] htr h0 h4 _ _ hs0 hs80.
have e : 16 * q0 = 64 by smt().
by move: hs0 hs80; rewrite e htr.
qed.

lemma __sha512_x4_store_pair_proof _h4 _s _i _h4_init _s_init :
  __sha512_x4_store_pair_spec _h4 _s _i _h4_init _s_init.
proof.
rewrite /__sha512_x4_store_pair_spec; proc.
while (valid trace___sha512_x4_store_pair /\ q_init /\ i_init /\ 0 <= q <= 4 /\
       0 <= i < 2 /\ h4_init = a64x4_I256 /\
       BArray160.is_init s_init 0 64 /\ BArray160.is_init s_init 80 64).
- auto => &m [#] hv hq hi h0 h4 hi0 hi1 -> hs0 hs80 hlt /=.
  have h1 : BArray160.is_init s_init{m} (q{m} * 16) 16.
  + by move=> j hj0 hj1; apply hs0 => /#.
  have h2 : BArray160.is_init s_init{m} ((5 + q{m}) * 16) 16.
  + by move=> j hj0 hj1; apply hs80 => /#.
  rewrite !valid_cat !a64x4_valid1 hv hq hi h1 h2 !a64x4_I256_set128 /=.
  smt().
auto => &m [#] <- <- <- _ _ hi0 hi1 hh hs0 hs80.
rewrite (a64x4_full256 _ hh) hs0 hs80 /=.
split; 1: by rewrite /valid /=; smt().
move=> hi q0 tr0 _ [#] htr _ _ _ _ ->.
by rewrite a64x4_I256_init htr.
qed.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

op a64x4_perm (i0 i1 i2 i3 i4 : int) : bool =
  0 <= i0 < 5 /\ 0 <= i1 < 5 /\ 0 <= i2 < 5 /\ 0 <= i3 < 5 /\ 0 <= i4 < 5 /\
  i0 <> i1 /\ i0 <> i2 /\ i0 <> i3 /\ i0 <> i4 /\ i1 <> i2 /\ i1 <> i3 /\
  i1 <> i4 /\ i2 <> i3 /\ i2 <> i4 /\ i3 <> i4.

lemma a64x4_perm_step i0 i1 i2 i3 i4 :
  a64x4_perm i0 i1 i2 i3 i4 => a64x4_perm i3 i0 i4 i2 i1.
proof. by rewrite /a64x4_perm /#. qed.

(* Slot k of lane l' is initialised unless it is the free slot i4 before
   the first pair of rounds has written it on that lane (lanes below l). *)
op a64x4_ls (si : BArray160.t) (i4 g l : int) : bool =
  forall l' k, 0 <= l' < 2 => 0 <= k < 5 => k <> i4 \/ 1 <= g \/ l' < l =>
  BArray160.is_init si ((5 * l' + k) * 16) 16.

lemma a64x4_ls_init (si : BArray160.t) :
  BArray160.is_init si 0 64 => BArray160.is_init si 80 64 => a64x4_ls si 4 0 0.
proof.
move=> h0 h80 l' k hl hk hc i hi0 hi1.
case: (l' = 0) => hl0; [apply h0 | apply h80]; smt().
qed.

lemma a64x4_ls_reads (si : BArray160.t) i0 i1 i2 i3 i4 g l :
  0 <= l < 2 => a64x4_perm i0 i1 i2 i3 i4 => a64x4_ls si i4 g l =>
  BArray160.is_init si ((5 * l + i0) * 16) 16 /\ BArray160.is_init si ((5 * l + i1) * 16) 16 /\
  BArray160.is_init si ((5 * l + i2) * 16) 16 /\ BArray160.is_init si ((5 * l + i3) * 16) 16.
proof.
rewrite /a64x4_perm /a64x4_ls => hl hp hs.
by split; [|split; [|split]]; apply hs; smt().
qed.

lemma a64x4_ls_step (si : BArray160.t) i0 i1 i2 i3 i4 g l :
  0 <= l < 2 => a64x4_perm i0 i1 i2 i3 i4 => a64x4_ls si i4 g l =>
  a64x4_ls
    (BArray160.set128d (BArray160.set128d (BArray160.set128d (BArray160.set128d si
       (16 * (5 * l + i3)) a64x4_ONE) (16 * (5 * l + i3)) a64x4_ONE)
       (16 * (5 * l + i4)) a64x4_ONE) (16 * (5 * l + i3)) a64x4_ONE) i4 g (l + 1).
proof.
rewrite /a64x4_perm /a64x4_ls => hl hp hs l' k hl' hk hc.
rewrite !a64x4_slot160.
case: (5 * l + i4 = 5 * l' + k) => // hne.
have -> // : BArray160.is_init si ((5 * l' + k) * 16) 16.
by apply hs => //; smt().
qed.

lemma a64x4_ls_next (si : BArray160.t) i4 g x :
  0 <= g => a64x4_ls si i4 g 2 => a64x4_ls si x (g + 1) 0.
proof. by move=> hg hs l' k hl hk _; apply hs => //; smt(). qed.

lemma a64x4_ls_full (si : BArray160.t) i4 g : 1 <= g => a64x4_ls si i4 g 0 => si = a64x4_I160.
proof.
move=> hg hs; apply a64x4_full160 => i hi0 hi1.
have := hs (i %/ 80) ((i %% 80) %/ 16) _ _ _; 1..3: smt().
by move=> h; apply h; smt().
qed.

lemma a64x4_pre_set (si : BArray128.t) (a b : int) : 0 <= a => a = b =>
  BArray128.is_init si 0 a => BArray128.is_init (BArray128.set128d si b a64x4_ONE) 0 (a + 16).
proof.
move=> ha <- hsi i hi0 hi1; rewrite BArray128.is_init_cell_set128d.
by case: (i < a) => hi; [right; apply hsi; smt() | left; smt()].
qed.

lemma __sha512_x4_block2_proof _s _m _k _s_init _m_init _k_init :
  __sha512_x4_block2_spec _s _m _k _s_init _m_init _k_init.
proof.
rewrite /__sha512_x4_block2_spec; proc.
wp.
while (valid trace___sha512_x4_block2 /\ l_init /\ 0 <= l <= 2 /\
       s_init = a64x4_I160 /\ save_init = a64x4_I128 /\ m_init = a64x4_I256).
- wp; while (valid trace___sha512_x4_block2 /\ l_init /\ j_init /\ 0 <= l < 2 /\ 0 <= j <= 4 /\
         s_init = a64x4_I160 /\ save_init = a64x4_I128 /\ m_init = a64x4_I256).
  + auto => &m [#] hv hl hj hl0 hl1 h0 h4 -> -> -> hlt /=.
    rewrite !valid_cat !a64x4_valid1 hv hl hj !a64x4_I160_init !a64x4_I128_init !a64x4_I160_set128 /=.
    smt().
  auto => &m [#] hv hl h0 h2 -> -> -> hlt /=.
  rewrite hv hl /=; split; 1: smt().
  move=> *; smt().
wp.
while (valid trace___sha512_x4_block2 /\ j_init /\ g_init /\ i0_init /\ i1_init /\
       i2_init /\ i3_init /\ i4_init /\ 0 <= g <= 40 /\
       m_init = a64x4_I256 /\ k_init = a64x4_I640 /\ save_init = a64x4_I128 /\
       a64x4_perm i0 i1 i2 i3 i4 /\ a64x4_ls s_init i4 g 0).
- wp.
  while (valid trace___sha512_x4_block2 /\ j_init /\ g_init /\ i0_init /\ i1_init /\
         i2_init /\ i3_init /\ i4_init /\ l_init /\ kv_init /\ 0 <= l <= 2 /\ 0 <= g < 40 /\
         j = g %% 8 /\ m_init = a64x4_I256 /\ k_init = a64x4_I640 /\ save_init = a64x4_I128 /\
         a64x4_perm i0 i1 i2 i3 i4 /\ a64x4_ls s_init i4 g l).
  + auto => &m [#] hv hj hg h0i h1i h2i h3i h4i hl hkv hl0 hl2 hg0 hg1 hjg -> -> -> hp hs hlt /=.
    have [r0 [r1 [r2 r3]]] := a64x4_ls_reads _ _ _ _ _ _ _ _ _ hp hs; 1: smt().
    have hss := a64x4_ls_step _ _ _ _ _ _ _ _ _ hp hs; 1: smt().
    rewrite !valid_cat !a64x4_valid1 hv hj hg h0i h1i h2i h3i h4i hl hkv.
    rewrite !a64x4_I256_set128 !a64x4_I256_init !a64x4_slot160 r0 r1 r2 r3 hss /=.
    smt(modz_ge0 ltz_pmod).
  auto => &m [#] hv hj hg h0i h1i h2i h3i h4i hg0 hg1 -> -> -> hp hs hlt /=.
  rewrite !valid_cat !a64x4_valid1 hv hg h0i h1i h2i h3i h4i hp hs a64x4_I640_init /=.
  split; 1: smt().
  move=> l0 mi0 si0 tr0 hlt0 [#] htr hl0 hl2 _ _ -> hls.
  have e : l0 = 2 by smt().
  move: hls; rewrite e => hls.
  rewrite !valid_cat !a64x4_valid1 htr (a64x4_perm_step _ _ _ _ _ hp).
  rewrite (a64x4_ls_next _ _ _ _ hg0 hls) /=.
  smt().
wp.
while (valid trace___sha512_x4_block2 /\ l_init /\ 0 <= l <= 2 /\
       BArray160.is_init s_init 0 64 /\ BArray160.is_init s_init 80 64 /\
       m_init = a64x4_I256 /\ k_init = a64x4_I640 /\ BArray128.is_init save_init 0 (64 * l) /\
       (0 < l => j_init)).
- wp; while (valid trace___sha512_x4_block2 /\ l_init /\ j_init /\ 0 <= l < 2 /\ 0 <= j <= 4 /\
         BArray160.is_init s_init 0 64 /\ BArray160.is_init s_init 80 64 /\
         m_init = a64x4_I256 /\ k_init = a64x4_I640 /\
         BArray128.is_init save_init 0 (64 * l + 16 * j)).
  + auto => &m [#] hv hl hj hl0 hl1 h0 h4 hs0 hs80 -> -> hsv hlt /=.
    have hr : BArray160.is_init s_init{m} ((5 * l{m} + j{m}) * 16) 16.
    + by move=> i hi0 hi1; case: (l{m} = 0) => hl'; [apply hs0 | apply hs80]; smt().
    have hw := a64x4_pre_set save_init{m} (64 * l{m} + 16 * j{m}) (16 * (4 * l{m} + j{m})) _ _ hsv.
    + smt().
    + ring.
    have e : 64 * l{m} + 16 * (j{m} + 1) = 64 * l{m} + 16 * j{m} + 16 by ring.
    rewrite !valid_cat !a64x4_valid1 hv hl hj hr e hw /=.
    smt().
  auto => &m [#] hv hl h0 h2 hs0 hs80 -> -> hsv _ hlt /=.
  rewrite hv hl hs0 hs80 hsv /=; split; 1: smt().
  move=> j0 sv0 tr0 hlt0 [#] htr _ _ hj0 hj4 hsv0.
  have e : 64 * (l{m} + 1) = 64 * l{m} + 16 * j0 by smt().
  by rewrite htr e hsv0 /=; smt().
auto => &m [#] <- <- <- _ _ _ hs0 hs80 hm hk.
rewrite (a64x4_full256 _ hm) (a64x4_full640 _ hk) hs0 hs80 /=.
split; 1: by rewrite /valid /=; move=> i /#.
move=> ji0 l0 sv0 tr0 hlt0 [#] htr hl0 hl2 hsv0 hji.
have e : 64 * l0 = 128 by smt().
have hsvf := a64x4_full128 sv0 _; 1: by rewrite -e.
rewrite htr hsvf (a64x4_ls_init _ hs0 hs80) /=.
split; 1: by rewrite /a64x4_perm /=; smt().
move=> g0 i00 i0i i10 i1i i20 i2i i30 i3i i40 i4i ji1 mi0 si0 tr1 hlt1
       [#] htr1 _ _ _ _ _ _ hg0 hg40 -> hp hls.
have hsf := a64x4_ls_full _ _ _ _ hls; 1: smt().
rewrite htr1 hsf /=.
move=> l1 si1 tr2 _ [#] htr2 _ _ ->.
by rewrite a64x4_I160_init a64x4_I256_init htr2.
qed.

(* ------------------------------------------------------------------ *)
(* One block and n blocks per lane                                    *)

(* Slots s of m with s %% 8 < j are initialised (the window loads). *)
op a64x4_win (si : BArray256.t) (j : int) : bool =
  forall s, 0 <= s < 16 => s %% 8 < j => BArray256.is_init si (s * 16) 16.

lemma a64x4_win_step (mi : BArray256.t) j : 0 <= j => a64x4_win mi j =>
  a64x4_win
    (BArray256.set128d (BArray256.set128d (BArray256.set128d (BArray256.set128d mi
       (16 * j) a64x4_ONE) (16 * j) a64x4_ONE) (16 * (8 + j)) a64x4_ONE)
       (16 * (8 + j)) a64x4_ONE) (j + 1).
proof.
rewrite /a64x4_win => hj hw s hs0 hsj; rewrite !a64x4_slot256.
case: (s %% 8 < j) => h; 1: by right; right; right; right; apply hw.
smt().
qed.

lemma a64x4_win_full (mi : BArray256.t) j : 8 <= j => a64x4_win mi j => mi = a64x4_I256.
proof.
move=> hj hw; apply a64x4_full256 => i hi0 hi1.
by have := hw (i %/ 16) _ _; [smt() | smt() | move=> h; apply h; smt()].
qed.

lemma _sha512_x4_compress_proof _h4 _blocks _ms _h4_init _blocks_init :
  _sha512_x4_compress_spec _h4 _blocks _ms _h4_init _blocks_init.
proof.
rewrite /_sha512_x4_compress_spec; proc.
wp.
while (valid trace__sha512_x4_compress /\ ms_init /\ i_init /\ 0 <= i <= 2 /\
       h4_init = a64x4_I256 /\ blocks_init = a64x4_I512 /\ k_init = a64x4_I640).
- wp; ecall (__sha512_x4_store_pair_proof h4 s i h4_init s_init).
  wp; ecall (__sha512_x4_block2_proof s m k s_init m_init k_init).
  wp; while (valid trace__sha512_x4_compress /\ ms_init /\ i_init /\ j_init /\
         0 <= j <= 8 /\ 0 <= i < 2 /\ h4_init = a64x4_I256 /\ blocks_init = a64x4_I512 /\
         k_init = a64x4_I640 /\ BArray160.is_init s_init 0 64 /\
         BArray160.is_init s_init 80 64 /\ a64x4_win m_init j).
  + auto => &m [#] hv hms hi hj h0 h8 hi0 hi1 -> -> -> hs0 hs80 hw hlt /=.
    rewrite !valid_cat !a64x4_valid1 hv hms hi hj !a64x4_I512_init !a64x4_slot256 /=.
    rewrite (a64x4_win_step _ _ h0 hw) /=.
    smt().
  wp; ecall (__sha512_x4_load_pair_proof h4 i h4_init).
  auto => &m [#] hv hms hi h0 h2 -> -> -> hlt /=.
  rewrite hms hi a64x4_I256_init /=.
  split; 1: smt().
  move=> _ r [[hr0 hr80] hr3].
  rewrite !valid_cat !a64x4_valid1 hv hr3 hr0 hr80 /=.
  split; 1: by rewrite /a64x4_win; smt(modz_ge0).
  move=> j0 mi0 tr0 hlt0 [#] htr hj0 hj8 _ _ hw.
  rewrite (a64x4_win_full _ _ _ hw) 1:/# a64x4_I256_init a64x4_I640_init /=.
  move=> r1 [[hr13 _] hr15].
  rewrite (a64x4_full160 _ hr13) !a64x4_I160_init /=.
  split; 1: smt().
  move=> _ r2 [hr22 hr23].
  by rewrite !valid_cat !a64x4_valid1 htr hr15 hr23 (a64x4_full256 _ hr22) /=; smt().
auto => &m [#] <- <- _ _ _ hh hb.
rewrite (a64x4_full256 _ hh) (a64x4_full512 _ hb) /=.
split; 1: by rewrite /valid.
move=> i0 hi0 tr0 _ [#] htr _ _ ->.
by rewrite a64x4_I256_init valid_cat a64x4_valid1 htr.
qed.

lemma a64x4_valid_sub mv (p : W64.t) (n o l : int) :
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

lemma a64x4_valid_step mv (p n : W64.t) :
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
by apply (a64x4_valid_sub _ _ _ _ _ hval); move: hn1; clear hval; smt().
qed.

(* Every lane's input, in[k] + off, is valid for n blocks. *)
op a64x4_lv mv (inp : BArray32.t) (off n : W64.t) : bool =
  forall k, 0 <= k < 4 =>
  is_valid ptr_modulus mv (W64.to_uint (BArray32.get64 inp k + off)) (128 * W64.to_uint n).

lemma _sha512_x4_compress_lanes_proof _h4 _in _off _n _ms _h4_init _in_init :
  _sha512_x4_compress_lanes_spec _h4 _in _off _n _ms _h4_init _in_init.
proof.
rewrite /_sha512_x4_compress_lanes_spec; proc.
wp.
while (valid trace__sha512_x4_compress_lanes /\ ms_init /\ off_init /\ n_init /\ i_init /\
       0 <= i <= 2 /\ h4_init = a64x4_I256 /\ in_init = a64x4_I32 /\ k_init = a64x4_I640 /\
       a64x4_lv Glob.mem_v in_0 off n).
- wp; ecall (__sha512_x4_store_pair_proof h4 s i h4_init s_init).
  wp.
  while (valid trace__sha512_x4_compress_lanes /\ ms_init /\ off_init /\ n_init /\
         i_init /\ p_init /\ q_init /\ c_init /\ more_init /\ 0 <= i < 2 /\
         h4_init = a64x4_I256 /\ in_init = a64x4_I32 /\ k_init = a64x4_I640 /\
         BArray160.is_init s_init 0 64 /\ BArray160.is_init s_init 80 64 /\
         more = (c <> W64.of_int 0) /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint c) /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint q) (128 * W64.to_uint c)).
  + wp; ecall (__sha512_x4_block2_proof s m k s_init m_init k_init).
    wp; while (valid trace__sha512_x4_compress_lanes /\ j_init /\ p_init /\ q_init /\
           0 <= j <= 8 /\
           is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 128 /\
           is_valid ptr_modulus Glob.mem_v (W64.to_uint q) 128 /\ a64x4_win m_init j).
    * auto => &m [#] hv hj hp hq h0 h8 hvp hvq hw hlt /=.
      rewrite !valid_cat !a64x4_valid1 hv hj hp hq !a64x4_slot256 /=.
      rewrite (a64x4_win_step _ _ h0 hw) /=.
      rewrite (a64x4_valid_sub _ _ _ _ _ hvp) 1..3:/# (a64x4_valid_sub _ _ _ _ _ hvq) 1..3:/#.
      smt().
    auto => &m [#] hv hms hof hn hi hp hq hc hmo hi0 hi1 -> -> -> hs0 hs80 hmore hvp hvq hm /=.
    have hc' : c{m} <> W64.of_int 0 by rewrite -hmore.
    have [hp128 hp'] := a64x4_valid_step _ _ _ hvp hc'.
    have [hq128 hq'] := a64x4_valid_step _ _ _ hvq hc'.
    move: hp' hq' => /= hp' hq'.
    rewrite !valid_cat !a64x4_valid1 hv hmo hms hp hq hp128 hq128 /=.
    split; 1: by rewrite /a64x4_win; smt(modz_ge0).
    move=> j0 mi0 tr0 hlt0 [#] htr hj0 hj8 hw.
    rewrite (a64x4_win_full _ _ _ hw) 1:/# hs0 hs80 a64x4_I256_init a64x4_I640_init /=.
    move=> r' [[hr3 _] hr5].
    rewrite (a64x4_full160 _ hr3) !a64x4_I160_init.
    by rewrite !valid_cat !a64x4_valid1 htr hr5 /=; smt().
  wp; ecall (__sha512_x4_load_pair_proof h4 i h4_init).
  auto => &m [#] hv hms hof hn hi h0 h2 -> -> -> hlv hlt /=.
  rewrite hms hof hn hi a64x4_I256_init /=.
  split; 1: smt().
  move=> _ r [[hr0 hr80] hr3].
  rewrite !valid_cat !a64x4_valid1 hv hr3 hr0 hr80 !a64x4_I32_init /protect_64 /=.
  have hl1 := hlv (2 * i{m}) _; 1: smt().
  have hl2 := hlv (2 * i{m} + 1) _; 1: smt().
  rewrite hl1 hl2 /=.
  split; 1: smt().
  move=> c0 ci0 mo0 moi0 msi0 p0 pi0 q0 qi0 si0 tr0 hnm H.
  have [hs0' hs80'] : BArray160.is_init si0 0 64 /\ BArray160.is_init si0 80 64 by smt().
  rewrite hs0' hs80' /=; split; 1: smt().
  move=> _ r1 [hr12 hr13].
  rewrite !valid_cat !a64x4_valid1 hr13 (a64x4_full256 _ hr12) /=.
  smt().
auto => &m [#] <- <- _ <- <- <- _ _ _ _ _ hh hin hlt hoff v0 v1 v2 v3.
have hn : W64.to_uint _n < 144115188075855872.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 128 * _n) = 128 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
have hlv : a64x4_lv Glob.mem_v{m} _in _off _n.
+ rewrite /a64x4_lv => k hk; rewrite -e.
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 by smt().
  by case=> [->|[->|[->|->]]] /=; assumption.
rewrite (a64x4_full256 _ hh) (a64x4_full32 _ hin) hlv /=.
split; 1: by rewrite /valid.
move=> i0 hi0 msi0 tr0 _ [#] htr hmsi _ _ ->.
by rewrite a64x4_I256_init valid_cat a64x4_valid1 htr hmsi.
qed.
