(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Sha2Safety.ec (aarch64/sha2)
 * ======================================
 *
 * Safety of the AArch64 SHA-512 instruction kernel
 * (src/aarch64/sha2/sha512_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. A contract says that, under
 * its precondition, every array read touches initialised bytes, every
 * memory access is to valid memory, and the outputs it names are
 * initialised; `valid` of the returned trace is the conjunction of the
 * model's asserts.
 *
 * Lemmas:
 *     __sha512_block_a64_proof       the 80 rounds on the slots s, the
 *                                    window m and the constant table k,
 *                                    s[0 .. 3], m and k initialised
 *     _sha512_compress_proof         one block from an initialised array
 *     _sha512_compress_blocks_proof  n blocks from valid memory at p,
 *                                    n < 2^57
 *
 * The five slot indices i0 .. i4 are always a permutation of 0 .. 4.
 * Before the first pair of rounds every slot other than i4 (slot 4) is
 * initialised; the first pair writes slot i4, and from then on all five
 * are (a64h512_slots).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray64 BArray80 BArray128 BArray640.

abbrev a64h512_ONE  = W128.of_int 340282366920938463463374607431768211455.
abbrev a64h512_I64  = BArray64.init_arr (W8.of_int 255).
abbrev a64h512_I128 = BArray128.init_arr (W8.of_int 255).
abbrev a64h512_I640 = BArray640.init_arr (W8.of_int 255).

lemma a64h512_full64 (m : BArray64.t) : BArray64.is_init m 0 64 => m = a64h512_I64.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma a64h512_full128 (m : BArray128.t) : BArray128.is_init m 0 128 => m = a64h512_I128.
proof.
move=> hm; rewrite BArray128.tP => j hj.
rewrite /BArray128.init_arr BArray128.initiE //=.
by have := hm j _ _; rewrite /BArray128.is_init_cell /#.
qed.

lemma a64h512_full640 (m : BArray640.t) : BArray640.is_init m 0 640 => m = a64h512_I640.
proof.
move=> hm; rewrite BArray640.tP => j hj.
rewrite /BArray640.init_arr BArray640.initiE //=.
by have := hm j _ _; rewrite /BArray640.is_init_cell /#.
qed.

lemma a64h512_I64_init a l : BArray64.is_init a64h512_I64 a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma a64h512_I128_init a l : BArray128.is_init a64h512_I128 a l.
proof. by move=> j _ _; apply (BArray128.init_arrP witness). qed.

lemma a64h512_I640_init a l : BArray640.is_init a64h512_I640 a l.
proof. by move=> j _ _; apply (BArray640.init_arrP witness). qed.

lemma a64h512_I128_set128 k : BArray128.set128 a64h512_I128 k a64h512_ONE = a64h512_I128.
proof.
apply a64h512_full128 => j _ _.
by rewrite BArray128.is_init_cell_set128d; right; apply (BArray128.init_arrP witness).
qed.

lemma a64h512_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

(* ------------------------------------------------------------------ *)
(* The slots                                                          *)

(* A 16-byte slot read after a 16-byte slot write. *)
lemma a64h512_slot_set (si : BArray80.t) (x y : int) :
  BArray80.is_init (BArray80.set128d si (16 * x) a64h512_ONE) (y * 16) 16
  = (x = y \/ BArray80.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray80.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray80.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

op a64h512_perm (i0 i1 i2 i3 i4 : int) : bool =
  0 <= i0 < 5 /\ 0 <= i1 < 5 /\ 0 <= i2 < 5 /\ 0 <= i3 < 5 /\ 0 <= i4 < 5 /\
  i0 <> i1 /\ i0 <> i2 /\ i0 <> i3 /\ i0 <> i4 /\ i1 <> i2 /\ i1 <> i3 /\
  i1 <> i4 /\ i2 <> i3 /\ i2 <> i4 /\ i3 <> i4.

(* Every slot is initialised, except the free slot i4 before pair 1. *)
op a64h512_slots (si : BArray80.t) (i4 g : int) : bool =
  forall k, 0 <= k < 5 => k <> i4 \/ 1 <= g => BArray80.is_init si (k * 16) 16.

lemma a64h512_perm_step i0 i1 i2 i3 i4 :
  a64h512_perm i0 i1 i2 i3 i4 => a64h512_perm i3 i0 i4 i2 i1.
proof. by rewrite /a64h512_perm /#. qed.

lemma a64h512_reads (si : BArray80.t) i0 i1 i2 i3 i4 g :
  a64h512_perm i0 i1 i2 i3 i4 => a64h512_slots si i4 g =>
  BArray80.is_init si (i0 * 16) 16 /\ BArray80.is_init si (i1 * 16) 16 /\
  BArray80.is_init si (i2 * 16) 16 /\ BArray80.is_init si (i3 * 16) 16.
proof.
rewrite /a64h512_perm /a64h512_slots => hp hs.
by split; [|split; [|split]]; apply hs; smt().
qed.

lemma a64h512_slots_step (si : BArray80.t) i0 i1 i2 i3 i4 g : 0 <= g =>
  a64h512_perm i0 i1 i2 i3 i4 => a64h512_slots si i4 g =>
  a64h512_slots
    (BArray80.set128d (BArray80.set128d (BArray80.set128d (BArray80.set128d si
       (16 * i3) a64h512_ONE) (16 * i3) a64h512_ONE) (16 * i4) a64h512_ONE)
       (16 * i3) a64h512_ONE) i1 (g + 1).
proof.
rewrite /a64h512_perm /a64h512_slots => hg hp hs k hk _.
rewrite !a64h512_slot_set.
case: (i4 = k) => // hne.
by have := hs k hk; smt().
qed.

lemma a64h512_slots0 (si : BArray80.t) : BArray80.is_init si 0 64 => a64h512_slots si 4 0.
proof. by move=> h k hk [hk4|//] i hi0 hi1; apply h => /#. qed.

lemma a64h512_slots_full (si : BArray80.t) i4 g : 1 <= g =>
  a64h512_slots si i4 g => BArray80.is_init si 0 80.
proof.
move=> hg hs i hi0 hi1.
have := hs (i %/ 16) _ _; 1,2: smt().
by move=> h; apply h; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

lemma __sha512_block_a64_proof _s _m _k _s_init _m_init _k_init :
  __sha512_block_a64_spec _s _m _k _s_init _m_init _k_init.
proof.
rewrite /__sha512_block_a64_spec; proc.
wp.
while (valid trace___sha512_block_a64 /\ j_init /\ 0 <= j <= 4 /\
       BArray80.is_init s_init 0 80 /\ m_init = a64h512_I128 /\ s0_init = a64h512_I64).
- auto => &m [#] hv hj h0 h4 hs -> -> hlt /=.
  have h1 : BArray80.is_init s_init{m} (j{m} * 16) 16.
  + by move=> i hi0 hi1; apply hs => /#.
  have h2 : BArray80.is_init (BArray80.set128d s_init{m} (16 * j{m}) a64h512_ONE) 0 80.
  + by move=> i hi0 hi1; rewrite BArray80.is_init_cell_set128d; right; apply hs.
  rewrite !valid_cat !a64h512_valid1 hv hj a64h512_I64_init h1 h2 /=.
  smt().
wp.
while (valid trace___sha512_block_a64 /\ j_init /\ g_init /\ i0_init /\ i1_init /\
       i2_init /\ i3_init /\ i4_init /\ 32 <= g <= 40 /\
       m_init = a64h512_I128 /\ k_init = a64h512_I640 /\ s0_init = a64h512_I64 /\
       a64h512_perm i0 i1 i2 i3 i4 /\ a64h512_slots s_init i4 g).
- auto => &m [#] hv hj hg h0i h1i h2i h3i h4i hg0 hg1 -> -> -> hp hs hlt /=.
  have [r0 [r1 [r2 r3]]] := a64h512_reads _ _ _ _ _ _ _ hp hs.
  have hss := a64h512_slots_step _ _ _ _ _ _ _ _ hp hs; 1: smt().
  have hps := a64h512_perm_step _ _ _ _ _ hp.
  rewrite !valid_cat !a64h512_valid1 hv ?hj ?hg ?h0i ?h1i ?h2i ?h3i ?h4i /=.
  rewrite ?a64h512_I128_init ?a64h512_I640_init !a64h512_slot_set r0 r1 r2 r3 /=.
  move: hp; rewrite /a64h512_perm => hp.
  smt().
wp.
while (valid trace___sha512_block_a64 /\ j_init /\ g_init /\ i0_init /\ i1_init /\
       i2_init /\ i3_init /\ i4_init /\ 0 <= g <= 32 /\
       m_init = a64h512_I128 /\ k_init = a64h512_I640 /\ s0_init = a64h512_I64 /\
       a64h512_perm i0 i1 i2 i3 i4 /\ a64h512_slots s_init i4 g).
- auto => &m [#] hv hj hg h0i h1i h2i h3i h4i hg0 hg1 -> -> -> hp hs hlt /=.
  have [r0 [r1 [r2 r3]]] := a64h512_reads _ _ _ _ _ _ _ hp hs.
  have hss := a64h512_slots_step _ _ _ _ _ _ _ _ hp hs; 1: smt().
  have hps := a64h512_perm_step _ _ _ _ _ hp.
  rewrite !valid_cat !a64h512_valid1 hv ?hj ?hg ?h0i ?h1i ?h2i ?h3i ?h4i /=.
  rewrite ?a64h512_I128_set128 ?a64h512_I128_init ?a64h512_I640_init !a64h512_slot_set r0 r1 r2 r3 /=.
  move: hp; rewrite /a64h512_perm => hp.
  smt(modz_ge0 ltz_pmod).
wp.
while (valid trace___sha512_block_a64 /\ j_init /\ 0 <= j <= 4 /\
       BArray80.is_init s_init 0 64 /\ m_init = a64h512_I128 /\ k_init = a64h512_I640 /\
       BArray64.is_init s0_init 0 (16 * j)).
- auto => &m [#] hv hj h0 h4 hs -> -> hs0 hlt /=.
  have h1 : BArray80.is_init s_init{m} (j{m} * 16) 16.
  + by move=> i hi0 hi1; apply hs => /#.
  have h2 : BArray64.is_init (BArray64.set128d s0_init{m} (16 * j{m}) a64h512_ONE) 0 (16 * (j{m} + 1)).
  + move=> i hi0 hi1; rewrite BArray64.is_init_cell_set128d.
    by case: (i < 16 * j{m}) => hi; [right; apply hs0; smt() | left; smt()].
  rewrite !valid_cat !a64h512_valid1 hv ?hj h1 h2 /=.
  smt().
auto => &m [#] <- <- <- _ _ _ hs hm hk.
rewrite (a64h512_full128 _ hm) (a64h512_full640 _ hk) /=.
split; first by rewrite /valid /=; smt().
move=> j0 si0 tr0 hlt [#] htr hj0 hj4 _ hsi0.
have e : 16 * j0 = 64 by smt().
split.
+ rewrite htr (a64h512_full64 si0 _) /=; first by rewrite -e.
  by split; [rewrite /a64h512_perm | exact (a64h512_slots0 _ hs)].
move=> g0 i00 i0i0 i10 i1i0 i20 i2i0 i30 i3i0 i40 i4i0 ji0 mi0 si1 tr1 hlt1
       [#] htr1 hji h0 h1 h2 h3 h4 hg0 hg32 hmi hs0 hp hsl.
have ->> : g0 = 32 by smt().
split; first by rewrite htr1 hji h0 h1 h2 h3 h4 hmi hs0 hp hsl.
move=> g1 i01 i0i1 i11 i1i1 i21 i2i1 i31 i3i1 i41 i4i1 ji1 si2 tr2 hlt2
       [#] htr2 hji1 h01 h11 h21 h31 h41 hg1 hg40 _ _ hp1 hsl1.
have hf := a64h512_slots_full _ _ _ _ hsl1; 1: smt().
split; first by rewrite htr2 hf hmi hs0.
move=> j1 si3 tr3 hlt3 H; rewrite hmi a64h512_I128_init /=.
smt().
qed.

(* ------------------------------------------------------------------ *)
(* One block and n blocks                                             *)

lemma a64h512_I64_set128 k : BArray64.set128 a64h512_I64 k a64h512_ONE = a64h512_I64.
proof.
apply a64h512_full64 => j _ _.
by rewrite BArray64.is_init_cell_set128d; right; apply (BArray64.init_arrP witness).
qed.

lemma a64h512_s_set (si : BArray80.t) (j : int) : 0 <= j =>
  BArray80.is_init si 0 (16 * j) =>
  BArray80.is_init (BArray80.set128d si (16 * j) a64h512_ONE) 0 (16 * (j + 1)).
proof.
move=> hj hsi i hi0 hi1; rewrite BArray80.is_init_cell_set128d.
by case: (i < 16 * j) => hi; [right; apply hsi; smt() | left; smt()].
qed.

lemma a64h512_m_set1 (mi : BArray128.t) (j : int) :
  BArray128.is_init (BArray128.set128d mi (16 * j) a64h512_ONE) (j * 16) 16.
proof. by move=> i hi0 hi1; rewrite BArray128.is_init_cell_set128d /#. qed.

lemma a64h512_m_set2 (mi : BArray128.t) (j : int) : 0 <= j =>
  BArray128.is_init mi 0 (16 * j) =>
  BArray128.is_init
    (BArray128.set128d (BArray128.set128d mi (16 * j) a64h512_ONE) (16 * j) a64h512_ONE)
    0 (16 * (j + 1)).
proof.
move=> hj hmi i hi0 hi1; rewrite !BArray128.is_init_cell_set128d.
by case: (i < 16 * j) => hi; [right; right; apply hmi; smt() | left; smt()].
qed.

lemma _sha512_compress_proof _h _block _ms _h_init _block_init :
  _sha512_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha512_compress_spec; proc.
wp.
while (valid trace__sha512_compress /\ ms_init /\ j_init /\ 0 <= j <= 4 /\
       BArray80.is_init s_init 0 80 /\ h_init = a64h512_I64).
- auto => &m [#] hv hms hj h0 h4 hs -> hlt /=.
  have h1 : BArray80.is_init s_init{m} (j{m} * 16) 16.
  + by move=> i hi0 hi1; apply hs => /#.
  rewrite !valid_cat !a64h512_valid1 hv hms hj h1 a64h512_I64_set128 /=.
  smt().
wp.
ecall (__sha512_block_a64_proof s m k s_init m_init k_init).
wp.
while (valid trace__sha512_compress /\ ms_init /\ j_init /\ 0 <= j <= 8 /\
       block_init = a64h512_I128 /\ h_init = a64h512_I64 /\
       BArray80.is_init s_init 0 64 /\ BArray128.is_init m_init 0 (16 * j)).
- auto => &m [#] hv hms hj h0 h8 -> -> hs hmi hlt /=.
  rewrite !valid_cat !a64h512_valid1 hv hms hj a64h512_I128_init a64h512_m_set1 a64h512_m_set2 // /=.
  smt().
wp.
while (valid trace__sha512_compress /\ ms_init /\ j_init /\ 0 <= j <= 4 /\
       block_init = a64h512_I128 /\ h_init = a64h512_I64 /\
       BArray80.is_init s_init 0 (16 * j)).
- auto => &m [#] hv hms hj h0 h4 -> -> hs hlt /=.
  rewrite !valid_cat !a64h512_valid1 hv hms hj a64h512_I64_init a64h512_s_set // /=.
  smt().
auto => &m [#] <- <- _ _ _ hh hb.
rewrite (a64h512_full64 _ hh) (a64h512_full128 _ hb) /=.
split; 1: by split; [rewrite /valid | move=> i /#].
move=> j0 si0 tr0 hlt [#] htr h0 h4 hsi.
have e : 16 * j0 = 64 by smt().
have hs64 : BArray80.is_init si0 0 64 by rewrite -e.
split; 1: by rewrite htr hs64 /=; move=> i /#.
move=> j1 mi0 tr1 hlt1 [#] htr1 h10 h18 _ hmi.
have e1 : 16 * j1 = 128 by smt().
have hm128 : BArray128.is_init mi0 0 128 by rewrite -e1.
rewrite hs64 hm128 a64h512_I640_init /=.
move=> r [[hr3 hr4] hr5].
split; 1: by rewrite !valid_cat !a64h512_valid1 htr1 hr5 hr3.
move=> hi0 j2 tr2 hlt2 [#] htr2 _ _ _ ->.
by rewrite a64h512_I64_init valid_cat a64h512_valid1 htr2.
qed.

lemma a64h512_valid_sub mv (p : W64.t) (n o l : int) :
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

lemma a64h512_valid_step mv (p n : W64.t) :
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
by apply (a64h512_valid_sub _ _ _ _ _ hval); move: hn1; clear hval; smt().
qed.

lemma _sha512_compress_blocks_proof _h _p _n _ms _h_init :
  _sha512_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha512_compress_blocks_spec; proc.
wp.
while (valid trace__sha512_compress_blocks /\ ms_init /\ j_init /\ 0 <= j <= 4 /\
       BArray80.is_init s_init 0 64 /\ h_init = a64h512_I64).
- auto => &m [#] hv hms hj h0 h4 hs -> hlt /=.
  have h1 : BArray80.is_init s_init{m} (j{m} * 16) 16.
  + by move=> i hi0 hi1; apply hs => /#.
  rewrite !valid_cat !a64h512_valid1 hv hms hj h1 a64h512_I64_set128 /=.
  smt().
wp.
while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init /\
       more = (n <> W64.of_int 0) /\ h_init = a64h512_I64 /\ k_init = a64h512_I640 /\
       BArray80.is_init s_init 0 64 /\
       is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n)).
- wp.
  ecall (__sha512_block_a64_proof s m k s_init m_init k_init).
  wp.
  while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init /\
         j_init /\ 0 <= j <= 8 /\ n <> W64.of_int 0 /\
         h_init = a64h512_I64 /\ k_init = a64h512_I640 /\ BArray80.is_init s_init 0 64 /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (128 * W64.to_uint n) /\
         is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 128 /\
         BArray128.is_init m_init 0 (16 * j)).
  + auto => &m [#] hv hp hn hmo hms hj h0 h8 hn0 -> -> hs hval hv128 hmi hlt /=.
    rewrite !valid_cat !a64h512_valid1 hv hp hj a64h512_m_set1 a64h512_m_set2 // /=.
    rewrite (a64h512_valid_sub _ _ _ _ _ hv128) 1..3:/# /=.
    by rewrite hn hmo hms hs hn0 hval hv128 /=; smt().
  auto => &m [#] hv hp hn hmo hms hmore -> -> hs hval hm.
  have hn' : n{m} <> W64.of_int 0 by rewrite -hmore.
  have [hv128 hval'] := a64h512_valid_step _ _ _ hval hn'.
  rewrite /= !valid_cat !a64h512_valid1 hv hp hn hmo hms hs hn' hval hv128 /=.
  split; 1: by move=> j /#.
  move=> j0 mi0 tr0 hlt H.
  have htr : valid tr0 by smt().
  have hw : BArray128.is_init mi0 0 128.
  + have e : 16 * j0 = 128 by smt().
    by move: H; rewrite e; smt().
  rewrite hw a64h512_I640_init /=.
  move=> r [[hr3 hr4] hr5].
  have hr64 : BArray80.is_init r.`3 0 64 by move=> i hi0 hi1; apply hr3 => /#.
  move: hval' => /= hval'.
  by rewrite !valid_cat !a64h512_valid1 htr hr5 /= hr64 hval'.
wp.
while (valid trace__sha512_compress_blocks /\ j_init /\ 0 <= j <= 4 /\
       h_init = a64h512_I64 /\ BArray80.is_init s_init 0 (16 * j)).
- auto => &m [#] hv hj h0 h4 -> hs hlt /=.
  rewrite !valid_cat !a64h512_valid1 hv hj a64h512_I64_init a64h512_s_set // /=.
  smt().
auto => &m [#] <- _ <- <- _ hh hlt hval /=.
have hn : W64.to_uint _n < 144115188075855872.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 128 * _n) = 128 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
move: hval; rewrite e => hval.
rewrite (a64h512_full64 _ hh) /=.
split; 1: by split; [rewrite /valid | move=> i /#].
move=> j0 si0 tr0 hlt0 [#] htr h0 h4 hsi.
have e4 : 16 * j0 = 64 by smt().
have hs64 : BArray80.is_init si0 0 64 by rewrite -e4.
split; 1: by rewrite !valid_cat !a64h512_valid1 htr hs64 hval.
move=> mo0 moi0 msi0 n0 ni0 p0 pi0 si1 tr1 _ [#] htr1 _ _ hmoi hmsi _ hsi1 _.
split; 1: by rewrite !valid_cat !a64h512_valid1 htr1 hmoi hmsi hsi1.
move=> hi0 j1 tr2 _ [#] htr2 _ _ _ ->.
by rewrite a64h512_I64_init valid_cat a64h512_valid1 htr2.
qed.
