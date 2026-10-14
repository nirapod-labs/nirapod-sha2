(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2X8Safety.ec (aarch64/sha2)
 * ========================================
 *
 * Safety of the AArch64 8-way SHA-256 instruction kernel
 * (src/aarch64/sha2/sha256_x8_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. `valid` of the returned trace
 * is the conjunction of the model's asserts.
 *
 * Lemmas:
 *     __sha256_x8_tr4_proof              the 4x4 word transpose
 *     __sha256_x8_load_half_proof        four lanes of h8 into st, f < 2
 *     __sha256_x8_store_half_proof       st back into h8, f < 2
 *     __sha256_x8_block2_proof           one block on the lane pair r < 2
 *     _sha256_x8_compress_proof          one block per lane from an array
 *     _sha256_x8_compress_lanes_proof    n blocks per lane from valid
 *                                        memory at in[k] + off, n < 2^58
 *
 * The state st of four lanes is eight 16-byte slots, two per lane. A slot
 * mask that is full stays full under whole-slot writes, so most invariants
 * say a mask equals the full one; the slots filled one by one in a loop
 * are described by a64x8_half (load_half) and a64x8_win (the window m).
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray32 BArray64 BArray128 BArray256 BArray512.

abbrev a64x8_ONE  = W128.of_int 340282366920938463463374607431768211455.
abbrev a64x8_I64  = BArray64.init_arr (W8.of_int 255).
abbrev a64x8_I128 = BArray128.init_arr (W8.of_int 255).
abbrev a64x8_I256 = BArray256.init_arr (W8.of_int 255).
abbrev a64x8_I512 = BArray512.init_arr (W8.of_int 255).

lemma a64x8_full64 (m : BArray64.t) : BArray64.is_init m 0 64 => m = a64x8_I64.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma a64x8_full128 (m : BArray128.t) : BArray128.is_init m 0 128 => m = a64x8_I128.
proof.
move=> hm; rewrite BArray128.tP => j hj.
rewrite /BArray128.init_arr BArray128.initiE //=.
by have := hm j _ _; rewrite /BArray128.is_init_cell /#.
qed.

lemma a64x8_full256 (m : BArray256.t) : BArray256.is_init m 0 256 => m = a64x8_I256.
proof.
move=> hm; rewrite BArray256.tP => j hj.
rewrite /BArray256.init_arr BArray256.initiE //=.
by have := hm j _ _; rewrite /BArray256.is_init_cell /#.
qed.

lemma a64x8_full512 (m : BArray512.t) : BArray512.is_init m 0 512 => m = a64x8_I512.
proof.
move=> hm; rewrite BArray512.tP => j hj.
rewrite /BArray512.init_arr BArray512.initiE //=.
by have := hm j _ _; rewrite /BArray512.is_init_cell /#.
qed.

lemma a64x8_I64_init a l : BArray64.is_init a64x8_I64 a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma a64x8_I128_init a l : BArray128.is_init a64x8_I128 a l.
proof. by move=> j _ _; apply (BArray128.init_arrP witness). qed.

lemma a64x8_I256_init a l : BArray256.is_init a64x8_I256 a l.
proof. by move=> j _ _; apply (BArray256.init_arrP witness). qed.

lemma a64x8_I512_init a l : BArray512.is_init a64x8_I512 a l.
proof. by move=> j _ _; apply (BArray512.init_arrP witness). qed.

lemma a64x8_I128_set128 k : BArray128.set128 a64x8_I128 k a64x8_ONE = a64x8_I128.
proof.
apply a64x8_full128 => j _ _.
by rewrite BArray128.is_init_cell_set128d; right; apply (BArray128.init_arrP witness).
qed.

lemma a64x8_I256_set128 k : BArray256.set128 a64x8_I256 k a64x8_ONE = a64x8_I256.
proof.
apply a64x8_full256 => j _ _.
by rewrite BArray256.is_init_cell_set128d; right; apply (BArray256.init_arrP witness).
qed.

lemma a64x8_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

(* A 16-byte slot read after a 16-byte slot write. *)
lemma a64x8_slot128 (si : BArray128.t) (x y : int) :
  BArray128.is_init (BArray128.set128d si (16 * x) a64x8_ONE) (y * 16) 16
  = (x = y \/ BArray128.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray128.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray128.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

lemma a64x8_slot32 (si : BArray32.t) (x y : int) :
  BArray32.is_init (BArray32.set128d si (16 * x) a64x8_ONE) (y * 16) 16
  = (x = y \/ BArray32.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray32.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray32.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

lemma a64x8_slot64 (si : BArray64.t) (x y : int) :
  BArray64.is_init (BArray64.set128d si (16 * x) a64x8_ONE) (y * 16) 16
  = (x = y \/ BArray64.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray64.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray64.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

(* Slots s of st with s %% 2 < q are initialised (load_half). *)
op a64x8_half (si : BArray128.t) (q : int) : bool =
  forall s, 0 <= s < 8 => s %% 2 < q => BArray128.is_init si (s * 16) 16.

(* Slots s of m with s %% 4 < i are initialised (the window loads). *)
op a64x8_win (si : BArray128.t) (i : int) : bool =
  forall s, 0 <= s < 8 => s %% 4 < i => BArray128.is_init si (s * 16) 16.

lemma a64x8_slots_full (si : BArray128.t) :
  (forall s, 0 <= s < 8 => BArray128.is_init si (s * 16) 16) => si = a64x8_I128.
proof.
move=> h; apply a64x8_full128 => i hi0 hi1.
by have := h (i %/ 16) _; [smt() | move=> h'; apply h'; smt()].
qed.

lemma a64x8_half_step (si : BArray128.t) q : 0 <= q => a64x8_half si q =>
  a64x8_half
    (BArray128.set128d (BArray128.set128d (BArray128.set128d (BArray128.set128d si
       (16 * q) a64x8_ONE) (16 * (2 + q)) a64x8_ONE) (16 * (4 + q)) a64x8_ONE)
       (16 * (6 + q)) a64x8_ONE) (q + 1).
proof.
rewrite /a64x8_half => hq hs s hs0 hsq; rewrite !a64x8_slot128.
case: (s %% 2 < q) => h; 1: by right; right; right; right; apply hs.
smt().
qed.

(* ------------------------------------------------------------------ *)

lemma __sha256_x8_tr4_proof _a _b _c _d : __sha256_x8_tr4_spec _a _b _c _d.
proof.
by rewrite /__sha256_x8_tr4_spec; proc; auto.
qed.

lemma __sha256_x8_load_half_proof _h8 _f _h8_init : __sha256_x8_load_half_spec _h8 _f _h8_init.
proof.
rewrite /__sha256_x8_load_half_spec; proc.
while (valid trace___sha256_x8_load_half /\ q_init /\ f_init /\ 0 <= q <= 2 /\
       0 <= f < 2 /\ h8_init = a64x8_I256 /\ a64x8_half st_init q).
- wp; ecall (__sha256_x8_tr4_proof a b c d).
  auto => &m [#] hv hq hf h0 h2 hf0 hf1 -> hst hlt /=.
  move=> r hr; rewrite !valid_cat !a64x8_valid1 hv hq hf hr !a64x8_I256_init.
  rewrite (a64x8_half_step _ _ h0 hst) /=.
  smt().
auto => &m [#] <- <- _ hf0 hf1 hh.
rewrite (a64x8_full256 _ hh) /=.
split; 1: by rewrite /valid /=; split; [smt() | move=> s /#].
move=> q0 si0 tr0 hlt [#] htr h0 h2 _ _ hhalf.
split; 2: by exact htr.
have -> := a64x8_slots_full si0 _; 2: by exact a64x8_I128_init.
by move=> s hs0 hs1; apply hhalf; smt().
qed.

lemma __sha256_x8_store_half_proof _h8 _st _f _h8_init _st_init :
  __sha256_x8_store_half_spec _h8 _st _f _h8_init _st_init.
proof.
rewrite /__sha256_x8_store_half_spec; proc.
while (valid trace___sha256_x8_store_half /\ q_init /\ f_init /\ 0 <= q <= 2 /\
       0 <= f < 2 /\ h8_init = a64x8_I256 /\ st_init = a64x8_I128).
- wp; ecall (__sha256_x8_tr4_proof (BArray128.get128 st q) (BArray128.get128 st (2 + q))
             (BArray128.get128 st (4 + q)) (BArray128.get128 st (6 + q))).
  auto => &m [#] hv hq hf h0 h2 hf0 hf1 -> -> hlt /=.
  move=> r hr; rewrite !valid_cat !a64x8_valid1 hv hq hf hr !a64x8_I128_init !a64x8_I256_set128 /=.
  smt().
auto => &m [#] <- <- <- _ _ hf0 hf1 hh hs.
rewrite (a64x8_full256 _ hh) (a64x8_full128 _ hs) /=.
split; 1: by rewrite /valid /=; smt().
move=> hi0 q0 tr0 _ [#] htr _ _ _ _ ->.
by rewrite a64x8_I256_init htr.
qed.

lemma a64x8_s0_set (si : BArray64.t) (j : int) : 0 <= j =>
  BArray64.is_init si 0 (16 * j) =>
  BArray64.is_init (BArray64.set128d si (16 * j) a64x8_ONE) 0 (16 * (j + 1)).
proof.
move=> hj hsi i hi0 hi1; rewrite BArray64.is_init_cell_set128d.
by case: (i < 16 * j) => hi; [right; apply hsi; smt() | left; smt()].
qed.

lemma __sha256_x8_block2_proof _st _r _m _k _st_init _m_init _k_init :
  __sha256_x8_block2_spec _st _r _m _k _st_init _m_init _k_init.
proof.
rewrite /__sha256_x8_block2_spec; proc.
wp.
while (valid trace___sha256_x8_block2 /\ j_init /\ r_init /\ 0 <= j <= 4 /\ 0 <= r < 2 /\
       st_init = a64x8_I128 /\ m_init = a64x8_I128 /\ BArray64.is_init s0_init 0 64).
- auto => &m [#] hv hj hr h0 h4 hr0 hr1 -> -> hs0 hlt /=.
  have h1 : BArray64.is_init s0_init{m} (j{m} * 16) 16.
  + by move=> i hi0 hi1; apply hs0 => /#.
  rewrite !valid_cat !a64x8_valid1 hv hj hr h1 !a64x8_I128_init !a64x8_I128_set128 /=.
  smt().
wp.
while (valid trace___sha256_x8_block2 /\ g_init /\ r_init /\ 0 <= g <= 16 /\ 0 <= r < 2 /\
       st_init = a64x8_I128 /\ m_init = a64x8_I128 /\ k_init = a64x8_I256 /\
       BArray64.is_init s0_init 0 64).
- wp.
  while (valid trace___sha256_x8_block2 /\ g_init /\ r_init /\ l_init /\ kv_init /\
         0 <= l <= 2 /\ 0 <= g < 16 /\ 0 <= r < 2 /\
         st_init = a64x8_I128 /\ m_init = a64x8_I128 /\ k_init = a64x8_I256 /\
         BArray64.is_init s0_init 0 64).
  + auto => &m [#] hv hg hr hl hkv h0 h2 hg0 hg1 hr0 hr1 -> -> -> hs0 hlt /=.
    rewrite !valid_cat !a64x8_valid1 hv hg hr hl hkv !a64x8_I128_set128 !a64x8_I128_init.
    rewrite !a64x8_slot32 /=.
    smt(modz_ge0 ltz_pmod).
  auto => &m [#] hv hg hr h0 h16 hr0 hr1 -> -> -> hs0 hlt /=.
  rewrite !valid_cat !a64x8_valid1 hv hg hr !a64x8_I256_init /=.
  split; 1: smt().
  move=> *; smt().
wp.
while (valid trace___sha256_x8_block2 /\ j_init /\ r_init /\ 0 <= j <= 4 /\ 0 <= r < 2 /\
       st_init = a64x8_I128 /\ BArray64.is_init s0_init 0 (16 * j)).
- auto => &m [#] hv hj hr h0 h4 hr0 hr1 -> hs0 hlt /=.
  rewrite !valid_cat !a64x8_valid1 hv hj hr !a64x8_I128_init a64x8_s0_set //=.
  smt().
auto => &m [#] <- <- <- _ _ <- _ hr0 hr1 hs hm hk.
rewrite (a64x8_full128 _ hs) (a64x8_full128 _ hm) (a64x8_full256 _ hk) /=.
split; 1: by rewrite /valid /=; split; [smt() | move=> i /#].
move=> j0 si0 tr0 hlt [#] htr h0 h4 _ _ hsi.
have e : 16 * j0 = 64 by smt().
have hs64 : BArray64.is_init si0 0 64 by rewrite -e.
split; 1: by rewrite htr hs64 /=; smt().
move=> g0 mi0 st0 tr1 _ [#] htr1 _ _ _ _ -> -> _.
split; 1: by rewrite htr1 hs64 /=; smt().
move=> j1 st1 tr2 _ [#] htr2 _ _ _ _ -> _ _.
by rewrite !a64x8_I128_init htr2.
qed.

lemma a64x8_win_step (mi : BArray128.t) i : 0 <= i => a64x8_win mi i =>
  a64x8_win
    (BArray128.set128d (BArray128.set128d (BArray128.set128d (BArray128.set128d mi
       (16 * i) a64x8_ONE) (16 * i) a64x8_ONE) (16 * (4 + i)) a64x8_ONE)
       (16 * (4 + i)) a64x8_ONE) (i + 1).
proof.
rewrite /a64x8_win => hi hw s hs0 hsi; rewrite !a64x8_slot128.
case: (s %% 4 < i) => h; 1: by right; right; right; right; apply hw.
smt().
qed.

lemma a64x8_win_full (mi : BArray128.t) i : 4 <= i => a64x8_win mi i => mi = a64x8_I128.
proof. by move=> hi hw; apply a64x8_slots_full => s hs0 hs1; apply hw => //; smt(). qed.

lemma _sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init :
  _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init.
proof.
rewrite /_sha256_x8_compress_spec; proc.
wp.
while (valid trace__sha256_x8_compress /\ ms_init /\ f_init /\ 0 <= f <= 2 /\
       h8_init = a64x8_I256 /\ blocks_init = a64x8_I512 /\ k_init = a64x8_I256).
- wp; ecall (__sha256_x8_store_half_proof h8 st f h8_init st_init).
  wp; while (valid trace__sha256_x8_compress /\ ms_init /\ f_init /\ r_init /\
         0 <= r <= 2 /\ 0 <= f < 2 /\ h8_init = a64x8_I256 /\ blocks_init = a64x8_I512 /\
         k_init = a64x8_I256 /\ st_init = a64x8_I128).
  + wp; ecall (__sha256_x8_block2_proof st r m k st_init m_init k_init).
    wp; while (valid trace__sha256_x8_compress /\ ms_init /\ f_init /\ r_init /\ i_init /\
           0 <= i <= 4 /\ 0 <= r < 2 /\ 0 <= f < 2 /\ h8_init = a64x8_I256 /\
           blocks_init = a64x8_I512 /\ k_init = a64x8_I256 /\ st_init = a64x8_I128 /\
           a64x8_win m_init i).
    * auto => &m [#] hv hms hf hr hi h0 h4 hr0 hr1 hf0 hf1 -> -> -> -> hw hlt /=.
      rewrite !valid_cat !a64x8_valid1 hv hms hf hr hi !a64x8_I512_init !a64x8_slot128 /=.
      rewrite (a64x8_win_step _ _ h0 hw) /=.
      smt().
    auto => &m [#] hv hms hf hr h0 h2 hf0 hf1 -> -> -> -> hlt /=.
    rewrite hv hms hf hr /=.
    split; 1: by rewrite /a64x8_win; smt(modz_ge0).
    move=> i0 mi0 tr0 hlt0 [#] htr hi0 hi4 _ _ _ _ hw.
    rewrite (a64x8_win_full _ _ _ hw) 1:/# !a64x8_I128_init a64x8_I256_init /=.
    split; 1: smt().
    move=> _ r' [[hr3 _] hr5].
    by rewrite !valid_cat !a64x8_valid1 htr hr5 (a64x8_full128 _ hr3) /=; smt().
  wp; ecall (__sha256_x8_load_half_proof h8 f h8_init).
  auto => &m [#] hv hms hf h0 h2 -> -> -> hlt /=.
  rewrite hms hf a64x8_I256_init /=.
  split; 1: smt().
  move=> _ r [hr2 hr3].
  rewrite !valid_cat !a64x8_valid1 hv hr3 (a64x8_full128 _ hr2) /=.
  split; 1: smt().
  move=> r0 st0 tr0 _ [#] htr _ _ _ _ ->.
  rewrite a64x8_I128_init /=; split; 1: smt().
  move=> _ r1 [hr12 hr13].
  by rewrite !valid_cat !a64x8_valid1 htr hr13 (a64x8_full256 _ hr12) /=; smt().
auto => &m [#] <- <- _ _ _ hh hb.
rewrite (a64x8_full256 _ hh) (a64x8_full512 _ hb) /=.
split; 1: by rewrite /valid.
move=> f0 hi0 tr0 _ [#] htr _ _ ->.
by rewrite a64x8_I256_init valid_cat a64x8_valid1 htr.
qed.

lemma a64x8_valid_sub mv (p : W64.t) (n o l : int) :
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

lemma a64x8_valid_step mv (p n : W64.t) :
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
by apply (a64x8_valid_sub _ _ _ _ _ hval); move: hn1; clear hval; smt().
qed.

(* Every lane's input, in[k] + off, is valid for n blocks. *)
op a64x8_lv mv (inp : BArray64.t) (off n : W64.t) : bool =
  forall k, 0 <= k < 8 =>
  is_valid ptr_modulus mv (W64.to_uint (BArray64.get64 inp k + off)) (64 * W64.to_uint n).

lemma _sha256_x8_compress_lanes_proof _h8 _in _off _n _ms _h8_init _in_init :
  _sha256_x8_compress_lanes_spec _h8 _in _off _n _ms _h8_init _in_init.
proof.
rewrite /_sha256_x8_compress_lanes_spec; proc.
wp.
while (valid trace__sha256_x8_compress_lanes /\ ms_init /\ off_init /\ n_init /\ f_init /\
       0 <= f <= 2 /\ h8_init = a64x8_I256 /\ in_init = a64x8_I64 /\ k_init = a64x8_I256 /\
       a64x8_lv Glob.mem_v in_0 off n).
- wp; ecall (__sha256_x8_store_half_proof h8 st f h8_init st_init).
  wp; while (valid trace__sha256_x8_compress_lanes /\ ms_init /\ off_init /\ n_init /\
         f_init /\ r_init /\ 0 <= r <= 2 /\ 0 <= f < 2 /\ h8_init = a64x8_I256 /\
         in_init = a64x8_I64 /\ k_init = a64x8_I256 /\ st_init = a64x8_I128 /\
         a64x8_lv Glob.mem_v in_0 off n).
  + wp.
    while (valid trace__sha256_x8_compress_lanes /\ ms_init /\ off_init /\ n_init /\
           f_init /\ r_init /\ p_init /\ q_init /\ c_init /\ more_init /\
           0 <= r < 2 /\ 0 <= f < 2 /\ h8_init = a64x8_I256 /\
           in_init = a64x8_I64 /\ k_init = a64x8_I256 /\ st_init = a64x8_I128 /\
           more = (c <> W64.of_int 0) /\
           is_valid ptr_modulus Glob.mem_v (W64.to_uint p) (64 * W64.to_uint c) /\
           is_valid ptr_modulus Glob.mem_v (W64.to_uint q) (64 * W64.to_uint c)).
    * wp; ecall (__sha256_x8_block2_proof st r m k st_init m_init k_init).
      wp; while (valid trace__sha256_x8_compress_lanes /\ i_init /\ p_init /\ q_init /\
             0 <= i <= 4 /\
             is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 64 /\
             is_valid ptr_modulus Glob.mem_v (W64.to_uint q) 64 /\ a64x8_win m_init i).
      - auto => &m [#] hv hi hp hq h0 h4 hvp hvq hw hlt /=.
        rewrite !valid_cat !a64x8_valid1 hv hi hp hq !a64x8_slot128 /=.
        rewrite (a64x8_win_step _ _ h0 hw) /=.
        rewrite (a64x8_valid_sub _ _ _ _ _ hvp) 1..3:/# (a64x8_valid_sub _ _ _ _ _ hvq) 1..3:/#.
        smt().
      auto => &m [#] hv hms hof hn hf hr hp hq hc hmo hr0 hr1 hf0 hf1 -> -> -> -> hmore hvp hvq hm /=.
      have hc' : c{m} <> W64.of_int 0 by rewrite -hmore.
      have [hp64 hp'] := a64x8_valid_step _ _ _ hvp hc'.
      have [hq64 hq'] := a64x8_valid_step _ _ _ hvq hc'.
      move: hp' hq' => /= hp' hq'.
      rewrite !valid_cat !a64x8_valid1 hv hmo hms hp hq hp64 hq64 /=.
      split; 1: by rewrite /a64x8_win; smt(modz_ge0).
      move=> i0 mi0 tr0 hlt0 [#] htr hi0 hi4 hw.
      rewrite (a64x8_win_full _ _ _ hw) 1:/# !a64x8_I128_init a64x8_I256_init /=.
      split; 1: smt().
      move=> _ r' [[hr3 _] hr5].
      by rewrite !valid_cat !a64x8_valid1 htr hr5 (a64x8_full128 _ hr3) /=; smt().
    auto => &m [#] hv hms hof hn hf hr h0 h2 hf0 hf1 -> -> -> -> hlv hlt /=.
    rewrite !valid_cat !a64x8_valid1 hv hms hof hn hf hr !a64x8_I64_init /protect_64 /=.
    have hl1 := hlv (4 * f{m} + 2 * r{m}) _; 1: smt().
    have hl2 := hlv (4 * f{m} + 2 * r{m} + 1) _; 1: smt().
    rewrite hl1 hl2 /=.
    split; 1: smt().
    move=> c0 ci0 mo0 moi0 msi0 p0 pi0 q0 qi0 st0 tr0 hnm H.
    rewrite !valid_cat !a64x8_valid1 /=.
    smt().
  wp; ecall (__sha256_x8_load_half_proof h8 f h8_init).
  auto => &m [#] hv hms hof hn hf h0 h2 -> -> -> hlv hlt /=.
  rewrite hms hof hn hf hlv a64x8_I256_init /=.
  split; 1: smt().
  move=> _ r [hr2 hr3].
  rewrite !valid_cat !a64x8_valid1 hv hr3 (a64x8_full128 _ hr2) /=.
  split; 1: smt().
  move=> msi0 r0 st0 tr0 _ [#] htr hmsi _ _ _ _ ->.
  rewrite a64x8_I128_init /=; split; 1: smt().
  move=> _ r1 [hr12 hr13].
  by rewrite !valid_cat !a64x8_valid1 htr hr13 hmsi (a64x8_full256 _ hr12) /=; smt().
auto => &m [#] <- <- _ <- <- <- _ _ _ _ _ _ _ _ _ hh hin hlt hoff v0 v1 v2 v3 v4 v5 v6 v7.
have hn : W64.to_uint _n < 288230376151711744.
+ by move: hlt; rewrite W64.ultE W64.to_uint_small.
have e : W64.to_uint (W64.of_int 64 * _n) = 64 * W64.to_uint _n.
+ rewrite W64.to_uintM_small W64.to_uint_small //.
  by move: hn; smt(W64.to_uint_cmp).
have hlv : a64x8_lv Glob.mem_v{m} _in _off _n.
+ rewrite /a64x8_lv => k hk; rewrite -e.
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=; assumption.
rewrite (a64x8_full256 _ hh) (a64x8_full64 _ hin) hlv /=.
split; 1: by rewrite /valid.
move=> f0 hi0 msi0 tr0 _ [#] htr hmsi _ _ ->.
by rewrite a64x8_I256_init valid_cat a64x8_valid1 htr hmsi.
qed.
