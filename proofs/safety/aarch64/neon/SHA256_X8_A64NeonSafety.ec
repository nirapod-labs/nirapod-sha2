(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64NeonSafety.ec (aarch64/neon)
 * =========================================
 *
 * Safety of the AArch64 Advanced SIMD 8-way SHA-256 kernel
 * (src/aarch64/neon/sha256_x8_compress.jinc): each procedure meets the
 * contract of its #[safety] annotation, as the -m safety model
 * NirapodSha2Safety states it in <fn>_spec. `valid` of the returned trace
 * is the conjunction of the model's asserts.
 *
 * Every loop over the two halves x = 0, 1 of the state is unrolled
 * (`unroll for`), so each round of _sha256_x8_block is straight-line code
 * whose asserts are the slot bounds and the initialisation of the slots
 * it reads. The working variables rotate over nine slots v[9x .. 9x + 8]:
 * at the head of round t the slot ((7 + 576) - t) mod 9 may be
 * uninitialised in round 0 only, and round 0 writes it before reading it.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_armv8a Jcheck JSafety.
require import NirapodSha2Safety BArray32 BArray64 BArray256 BArray288 BArray512.

abbrev a64n_ONE  = W128.of_int 340282366920938463463374607431768211455.
abbrev a64n_I32  = BArray32.init_arr (W8.of_int 255).
abbrev a64n_I64  = BArray64.init_arr (W8.of_int 255).
abbrev a64n_I256 = BArray256.init_arr (W8.of_int 255).
abbrev a64n_I288 = BArray288.init_arr (W8.of_int 255).
abbrev a64n_I512 = BArray512.init_arr (W8.of_int 255).

lemma a64n_valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

lemma a64n_full64 (m : BArray64.t) : BArray64.is_init m 0 64 => m = a64n_I64.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma a64n_full256 (m : BArray256.t) : BArray256.is_init m 0 256 => m = a64n_I256.
proof.
move=> hm; rewrite BArray256.tP => j hj.
rewrite /BArray256.init_arr BArray256.initiE //=.
by have := hm j _ _; rewrite /BArray256.is_init_cell /#.
qed.

lemma a64n_full512 (m : BArray512.t) : BArray512.is_init m 0 512 => m = a64n_I512.
proof.
move=> hm; rewrite BArray512.tP => j hj.
rewrite /BArray512.init_arr BArray512.initiE //=.
by have := hm j _ _; rewrite /BArray512.is_init_cell /#.
qed.

lemma a64n_I64_init a l : BArray64.is_init a64n_I64 a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma a64n_I256_init a l : BArray256.is_init a64n_I256 a l.
proof. by move=> j _ _; apply (BArray256.init_arrP witness). qed.

lemma a64n_I512_init a l : BArray512.is_init a64n_I512 a l.
proof. by move=> j _ _; apply (BArray512.init_arrP witness). qed.

lemma a64n_I256_set128 k : BArray256.set128 a64n_I256 k a64n_ONE = a64n_I256.
proof.
apply a64n_full256 => j _ _.
by rewrite BArray256.is_init_cell_set128d; right; apply (BArray256.init_arrP witness).
qed.

lemma a64n_I512_set128 k : BArray512.set128 a64n_I512 k a64n_ONE = a64n_I512.
proof.
apply a64n_full512 => j _ _.
by rewrite BArray512.is_init_cell_set128d; right; apply (BArray512.init_arrP witness).
qed.

(* A 16-byte slot read after a 16-byte slot write. *)
lemma a64n_slot32 (si : BArray32.t) (x y : int) :
  BArray32.is_init (BArray32.set128d si (16 * x) a64n_ONE) (y * 16) 16
  = (x = y \/ BArray32.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray32.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray32.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

lemma a64n_slot64 (si : BArray64.t) (x y : int) :
  BArray64.is_init (BArray64.set128d si (16 * x) a64n_ONE) (y * 16) 16
  = (x = y \/ BArray64.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray64.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray64.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

lemma a64n_slot288 (si : BArray288.t) (x y : int) :
  BArray288.is_init (BArray288.set128d si (16 * x) a64n_ONE) (y * 16) 16
  = (x = y \/ BArray288.is_init si (y * 16) 16).
proof.
rewrite eq_iff; split.
+ move=> h; case: (x = y) => // hne; right => i hi0 hi1.
  by have := h i hi0 hi1; rewrite BArray288.is_init_cell_set128d /#.
case=> [<-|h] i hi0 hi1; rewrite BArray288.is_init_cell_set128d; first by left; smt().
by right; apply h.
qed.

(* The whole of a small array from its 16-byte slots. *)
lemma a64n_slots64 (si : BArray64.t) :
  (forall s, 0 <= s < 4 => BArray64.is_init si (s * 16) 16) => BArray64.is_init si 0 64.
proof. by move=> h i hi0 hi1; have := h (i %/ 16) _ i _ _; smt(). qed.

lemma a64n_slots512 (si : BArray512.t) :
  (forall s, 0 <= s < 32 => BArray512.is_init si (s * 16) 16) => BArray512.is_init si 0 512.
proof. by move=> h i hi0 hi1; have := h (i %/ 16) _ i _ _; smt(). qed.

lemma a64n_slots256 (si : BArray256.t) :
  (forall s, 0 <= s < 16 => BArray256.is_init si (s * 16) 16) => BArray256.is_init si 0 256.
proof. by move=> h i hi0 hi1; have := h (i %/ 16) _ i _ _; smt(). qed.

(* A write of a full slot: the slot is initialised, and what was. *)
lemma a64n_hit32 (si : BArray32.t) o : 0 <= o => o + 16 <= 32 =>
  BArray32.is_init (BArray32.set128d si o a64n_ONE) o 16.
proof. by move=> h0 h1 i hi0 hi1; rewrite BArray32.is_init_cell_set128d; left; smt(). qed.

lemma a64n_keep32 (si : BArray32.t) o a l :
  BArray32.is_init si a l => BArray32.is_init (BArray32.set128d si o a64n_ONE) a l.
proof. by move=> h i hi0 hi1; rewrite BArray32.is_init_cell_set128d; right; apply h. qed.

lemma a64n_hit64 (si : BArray64.t) o : 0 <= o => o + 16 <= 64 =>
  BArray64.is_init (BArray64.set128d si o a64n_ONE) o 16.
proof. by move=> h0 h1 i hi0 hi1; rewrite BArray64.is_init_cell_set128d; left; smt(). qed.

lemma a64n_keep64 (si : BArray64.t) o a l :
  BArray64.is_init si a l => BArray64.is_init (BArray64.set128d si o a64n_ONE) a l.
proof. by move=> h i hi0 hi1; rewrite BArray64.is_init_cell_set128d; right; apply h. qed.

lemma a64n_hit288 (si : BArray288.t) o : 0 <= o => o + 16 <= 288 =>
  BArray288.is_init (BArray288.set128d si o a64n_ONE) o 16.
proof. by move=> h0 h1 i hi0 hi1; rewrite BArray288.is_init_cell_set128d; left; smt(). qed.

lemma a64n_keep288 (si : BArray288.t) o a l :
  BArray288.is_init si a l => BArray288.is_init (BArray288.set128d si o a64n_ONE) a l.
proof. by move=> h i hi0 hi1; rewrite BArray288.is_init_cell_set128d; right; apply h. qed.

lemma a64n_I64_setd o : BArray64.set128d a64n_I64 o a64n_ONE = a64n_I64.
proof.
apply a64n_full64 => j _ _.
by rewrite BArray64.is_init_cell_set128d; right; apply (BArray64.init_arrP witness).
qed.

lemma a64n_I256_setd o : BArray256.set128d a64n_I256 o a64n_ONE = a64n_I256.
proof.
apply a64n_full256 => j _ _.
by rewrite BArray256.is_init_cell_set128d; right; apply (BArray256.init_arrP witness).
qed.

lemma a64n_I512_setd o : BArray512.set128d a64n_I512 o a64n_ONE = a64n_I512.
proof.
apply a64n_full512 => j _ _.
by rewrite BArray512.is_init_cell_set128d; right; apply (BArray512.init_arrP witness).
qed.

(* ------------------------------------------------------------------ *)
(* The lane functions                                                 *)

lemma __rotr_x2_proof _x0 _x1 _r : __rotr_x2_spec _x0 _x1 _r.
proof. by rewrite /__rotr_x2_spec; proc; auto. qed.

lemma __Sigma0_x2_proof _x0 _x1 : __Sigma0_x2_spec _x0 _x1.
proof.
rewrite /__Sigma0_x2_spec; proc.
wp; ecall (__rotr_x2_proof x0 x1 22); wp; ecall (__rotr_x2_proof x0 x1 13).
wp; ecall (__rotr_x2_proof x0 x1 2); auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma __Sigma1_x2_proof _x0 _x1 : __Sigma1_x2_spec _x0 _x1.
proof.
rewrite /__Sigma1_x2_spec; proc.
wp; ecall (__rotr_x2_proof x0 x1 25); wp; ecall (__rotr_x2_proof x0 x1 11).
wp; ecall (__rotr_x2_proof x0 x1 6); auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma __sigma0_x2_proof _x0 _x1 : __sigma0_x2_spec _x0 _x1.
proof.
rewrite /__sigma0_x2_spec; proc.
wp; ecall (__rotr_x2_proof x0 x1 18); wp; ecall (__rotr_x2_proof x0 x1 7); auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma __sigma1_x2_proof _x0 _x1 : __sigma1_x2_spec _x0 _x1.
proof.
rewrite /__sigma1_x2_spec; proc.
wp; ecall (__rotr_x2_proof x0 x1 19); wp; ecall (__rotr_x2_proof x0 x1 17); auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

(* The same, for any arguments. *)
lemma a64n_rotr_v : hoare [M.__rotr_x2 : true ==> valid res.`3].
proof. by proc; auto. qed.

lemma a64n_Sigma0_v : hoare [M.__Sigma0_x2 : true ==> valid res.`3].
proof.
proc; wp; call a64n_rotr_v; wp; call a64n_rotr_v; wp; call a64n_rotr_v; auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma a64n_Sigma1_v : hoare [M.__Sigma1_x2 : true ==> valid res.`3].
proof.
proc; wp; call a64n_rotr_v; wp; call a64n_rotr_v; wp; call a64n_rotr_v; auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma a64n_sigma0_v : hoare [M.__sigma0_x2 : true ==> valid res.`3].
proof.
proc; wp; call a64n_rotr_v; wp; call a64n_rotr_v; auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

lemma a64n_sigma1_v : hoare [M.__sigma1_x2 : true ==> valid res.`3].
proof.
proc; wp; call a64n_rotr_v; wp; call a64n_rotr_v; auto => />.
by move=> *; rewrite !all_cat /= /#.
qed.

(* ------------------------------------------------------------------ *)
(* The row transpose                                                  *)

lemma __sha256_x8_rows_proof _r _r_init : __sha256_x8_rows_spec _r _r_init.
proof.
rewrite /__sha256_x8_rows_spec; proc.
unroll for 8.
auto => /> hr.
rewrite (a64n_full64 _ hr) !a64n_I64_setd !a64n_I64_init /=.
by do ! (split || (apply a64n_hit64; done) || apply a64n_keep64).
qed.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

abbrev a64n_I0_32 = BArray32.init_arr (W8.of_int 0).

lemma a64n_full32 (m : BArray32.t) : BArray32.is_init m 0 32 => m = a64n_I32.
proof.
move=> hm; rewrite BArray32.tP => j hj.
rewrite /BArray32.init_arr BArray32.initiE //=.
by have := hm j _ _; rewrite /BArray32.is_init_cell /#.
qed.

lemma a64n_I32_init a l : BArray32.is_init a64n_I32 a l.
proof. by move=> j _ _; apply (BArray32.init_arrP witness). qed.

(* Both slots of a two-slot array written: the array is initialised. *)
lemma a64n_two32 (m : BArray32.t) :
  BArray32.set128d (BArray32.set128d m 0 a64n_ONE) 16 a64n_ONE = a64n_I32.
proof.
apply a64n_full32 => i hi0 hi1; rewrite !BArray32.is_init_cell_set128d; smt().
qed.

lemma a64n_I32_setd o : BArray32.set128d a64n_I32 o a64n_ONE = a64n_I32.
proof.
apply a64n_full32 => j _ _.
by rewrite BArray32.is_init_cell_set128d; right; apply (BArray32.init_arrP witness).
qed.

(* The slots of v that round t may read: all but slot 7 of each half in
   round 0. *)
op a64n_vok (v : BArray288.t) (t : int) =
  forall y, 0 <= y < 18 => (0 < t \/ y %% 9 <> 7) => BArray288.is_init v (y * 16) 16.

(* Round t reads ab[2x + (t + 1) mod 2]; in round 0 only those are set. *)
op a64n_abok (a : BArray64.t) (t : int) =
  forall y, 0 <= y < 4 => (0 < t \/ y %% 2 = 1) => BArray64.is_init a (y * 16) 16.

lemma a64n_vok_keep v o t : a64n_vok v t => a64n_vok (BArray288.set128d v o a64n_ONE) t.
proof. by move=> h y hy ht; apply a64n_keep288; apply h. qed.

lemma a64n_abok_keep a o t : a64n_abok a t => a64n_abok (BArray64.set128d a o a64n_ONE) t.
proof. by move=> h y hy ht; apply a64n_keep64; apply h. qed.

(* The reads of round t: slot ((c + 576) - t) mod 9 of both halves, for
   every working variable c but the free slot 7. *)
lemma a64n_vrd (v : BArray288.t) t c : a64n_vok v t => 0 <= t => 0 <= c < 9 => c <> 7 =>
  BArray288.is_init v ((((c + 576) - t) %% 9) * 16) 16 /\
  BArray288.is_init v ((9 + ((c + 576) - t) %% 9) * 16) 16.
proof.
move=> hv ht hc h7; split.
+ by apply hv; smt().
by apply hv; smt().
qed.

lemma a64n_abrd (a : BArray64.t) t : a64n_abok a t => 0 <= t =>
  BArray64.is_init a (((t + 1) %% 2) * 16) 16 /\
  BArray64.is_init a ((2 + (t + 1) %% 2) * 16) 16.
proof. by move=> h ht; split; apply h; smt(). qed.

(* Round t < 63 writes slot ((7 + 576) - t) mod 9 of both halves. *)
op a64n_c7 (v : BArray288.t) (t : int) =
  t < 63 =>
  BArray288.is_init v ((((7 + 576) - t) %% 9) * 16) 16 /\
  BArray288.is_init v ((9 + ((7 + 576) - t) %% 9) * 16) 16.

lemma a64n_c7_keep v o t : a64n_c7 v t => a64n_c7 (BArray288.set128d v o a64n_ONE) t.
proof. by move=> h ht; have [h1 h2] := h ht; split; apply a64n_keep288. qed.

lemma a64n_c7_new (v : BArray288.t) t :
  a64n_c7 (BArray288.set128d (BArray288.set128d v (16 * ((583 - t) %% 9)) a64n_ONE)
             (16 * (9 + (583 - t) %% 9)) a64n_ONE) t.
proof.
move=> _; split.
+ apply a64n_keep288; rewrite (_ : (7 + 576 - t) %% 9 * 16 = 16 * ((583 - t) %% 9)) 1:/#.
  by apply a64n_hit288; smt().
rewrite (_ : (9 + (7 + 576 - t) %% 9) * 16 = 16 * (9 + (583 - t) %% 9)) 1:/#.
by apply a64n_hit288; smt().
qed.

lemma a64n_vok_next v t : 0 <= t < 64 => a64n_vok v t => a64n_c7 v t => a64n_vok v (t + 1).
proof.
move=> ht hv hc y hy _; case: (0 < t) => h0; first by apply hv => /#.
have ->> : t = 0 by smt().
case: (y %% 9 = 7) => h7; last by apply hv => /#.
have [e1 e2] := hc _; 1: done.
have : y = 7 \/ y = 16 by smt().
by case=> ->>; [move: e1 | move: e2].
qed.

(* Rounds write ab[2x + t mod 2], then ab[2x + (t + 1) mod 2]. *)
op a64n_hab (a : BArray64.t) (t : int) =
  BArray64.is_init a ((t %% 2) * 16) 16 /\ BArray64.is_init a ((2 + t %% 2) * 16) 16.

lemma a64n_hab_keep a o t : a64n_hab a t => a64n_hab (BArray64.set128d a o a64n_ONE) t.
proof. by move=> [h1 h2]; split; apply a64n_keep64. qed.

lemma a64n_hab_new (a : BArray64.t) u :
  a64n_hab (BArray64.set128d (BArray64.set128d a (16 * (u %% 2)) a64n_ONE)
              (16 * (2 + u %% 2)) a64n_ONE) u.
proof.
split.
+ by apply a64n_keep64; rewrite (_ : u %% 2 * 16 = 16 * (u %% 2)) 1:/#; apply a64n_hit64; smt().
by rewrite (_ : (2 + u %% 2) * 16 = 16 * (2 + u %% 2)) 1:/#; apply a64n_hit64; smt().
qed.

lemma a64n_abok_next a t : 0 <= t => a64n_hab a t => a64n_hab a (t + 1) =>
  a64n_abok a (t + 1).
proof.
move=> ht [h1 h2] [h3 h4] y hy _.
have e : (t + 1) %% 2 = 1 - t %% 2 by smt().
move: h3 h4; rewrite e => h3 h4.
have hy4 : y = 0 \/ y = 1 \/ y = 2 \/ y = 3 by smt().
have : t %% 2 = 0 \/ t %% 2 = 1 by smt().
case=> he; move: h1 h2 h3 h4; rewrite he /= => h1 h2 h3 h4.
+ by case: hy4 => [->>|[->>|[->>|->>]]].
by case: hy4 => [->>|[->>|[->>|->>]]].
qed.

lemma _sha256_x8_block_proof _h8 _w _ms _h8_init _w_init :
  _sha256_x8_block_spec _h8 _w _ms _h8_init _w_init.
proof.
rewrite /_sha256_x8_block_spec; proc.
seq 50 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
          t = 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
          a64n_vok v_init t); last first.
+ wp.
  while (valid trace__sha256_x8_block /\ x_init /\ ms_init /\ 0 <= x <= 2 /\
         h8_init = a64n_I256 /\ a64n_vok v_init 64).
  + wp.
    while (valid trace__sha256_x8_block /\ x_init /\ ms_init /\ j_init /\ 0 <= x < 2 /\
           0 <= j <= 7 /\ h8_init = a64n_I256 /\ a64n_vok v_init 64).
    + auto => &m [#] hv hx hms hj hx0 hx2 hj0 hj7 -> hvok hlt /=.
      rewrite !valid_cat !a64n_valid1 hv hx hj !a64n_I256_init !a64n_I256_setd /=.
      have := hvok (9 * x{m} + (j{m} + 512) %% 9) _ _; 1,2: smt().
      smt().
    auto => &m [#] hv hx hms hx0 hx2 -> hvok hlt /=.
    split; first smt().
    move=> h0 j0 tr0 hj [#] htr _ _ _ _ hj0 hj7 -> _.
    rewrite !valid_cat !a64n_valid1 htr hx !a64n_I256_init !a64n_I256_setd /=.
    have := hvok (9 * x{m} + 6) _ _; 1,2: smt().
    smt().
  auto => &m [#] hv hx hkq hkd hms ht ht64 hk hh hw hvok.
  move: hvok; rewrite ht64 => hvok.
  rewrite hv hms hh hvok /=.
  move=> h0 tr0 x0 hx0 [#] htr hx1 hx2 ->.
  by rewrite a64n_I256_init valid_cat a64n_valid1 htr.
while (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
       0 <= t <= 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
       a64n_vok v_init t /\ a64n_abok ab_init t).
+ seq 2 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             wt_init = a64n_I32).
  + seq 1 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t).
    + by auto => &m [#] hv *; rewrite valid_cat a64n_valid1 hv /#.
    if.
    + seq 56 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\
                t_init /\ 16 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\
                w_init = a64n_I512 /\ a64n_vok v_init t /\ a64n_abok ab_init t /\
                wt_init = a64n_I32).
      + unroll for 55; unroll for 52; unroll for 49; unroll for 29; unroll for 26.
        unroll for 6; unroll for 3.
        wp; call a64n_sigma0_v; wp; call a64n_sigma1_v.
        auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hle /= r hr r' hr'.
        rewrite !valid_cat !a64n_valid1 hv ht hr hr' !a64n_two32 ?a64n_I32_setd ?a64n_I32_init /=.
        rewrite ?a64n_I512_init hvok habok /=.
        smt().
      if; last by auto => /> /#.
      unroll for 3.
      auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok -> hlt /=.
      rewrite !valid_cat !a64n_valid1 hv ht ?a64n_I32_init !a64n_I512_setd hvok habok /=.
      smt().
    unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hlt /=.
    rewrite !valid_cat !a64n_valid1 hv ht ?a64n_I512_init a64n_two32 hvok habok /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok -> /=.
    have /= [r1 r2] := a64n_vrd _ _ 8 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht ?a64n_I32_init /=.
    rewrite ?r1 ?r2 !a64n_keep288 // !a64n_vok_keep // habok /=.
    smt().
  seq 2 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t).
  + seq 1 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t).
    + by auto => &m [#] hv *; rewrite valid_cat a64n_valid1 hv /#.
    if; last by auto => /> /#.
    unroll for 11.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hlt /=.
    have /= [r1 r2] := a64n_vrd _ _ 6 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hkq ?a64n_I256_init /=.
    rewrite ?r1 ?r2 !a64n_keep288 // !a64n_vok_keep // a64n_c7_new habok /=.
    smt().
  seq 20 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ s_init = a64n_I32).
  + wp; call a64n_Sigma1_v.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 /= r hr.
    have /= [r1 r2] := a64n_vrd _ _ 4 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hr r1 r2 a64n_two32 /=.
    smt().
  seq 1 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t).
  + if.
    + unroll for 9; unroll for 6; unroll for 3.
      auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> hlt /=.
      have /= [r1 r2] := a64n_vrd _ _ 4 hvok _ _ _; 1..3: smt().
      have /= [q1 q2] := a64n_vrd _ _ 5 hvok _ _ _; 1..3: smt().
      have /= [p1 p2] := a64n_vrd _ _ 6 hvok _ _ _; 1..3: smt().
      have /= [o1 o2] := a64n_vrd _ _ 8 hvok _ _ _; 1..3: smt().
      rewrite !valid_cat !a64n_valid1 hv ht ?a64n_I32_init /=.
      rewrite ?r1 ?q1 ?p1 ?o1 !a64n_keep288 // !a64n_vok_keep // !a64n_c7_keep // habok /=.
      smt().
    unroll for 15; unroll for 12; unroll for 9; unroll for 6; unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> hlt /=.
    have /= [r1 r2] := a64n_vrd _ _ 4 hvok _ _ _; 1..3: smt().
    have /= [q1 q2] := a64n_vrd _ _ 5 hvok _ _ _; 1..3: smt().
    have /= [p1 p2] := a64n_vrd _ _ 6 hvok _ _ _; 1..3: smt().
    have /= [o1 o2] := a64n_vrd _ _ 8 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht !a64n_two32 ?a64n_I32_setd ?a64n_I32_init /=.
    rewrite ?r1 ?q1 ?p1 ?o1 ?r2 ?q2 ?p2 ?o2 !a64n_keep288 // !a64n_vok_keep // !a64n_c7_keep // habok /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 /=.
    have /= [r1 r2] := a64n_vrd _ _ 3 hvok _ _ _; 1..3: smt().
    have /= [q1 q2] := a64n_vrd _ _ 8 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht /=.
    rewrite ?r1 ?q1 !a64n_keep288 // !a64n_vok_keep // !a64n_c7_keep // habok /=.
    smt().
  seq 19 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ s_init = a64n_I32).
  + wp; call a64n_Sigma0_v.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 /= r hr.
    have /= [r1 r2] := a64n_vrd _ _ 0 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hr r1 r2 a64n_two32 /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ s_init = a64n_I32 /\ a64n_hab ab_init t).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> /=.
    have /= [r1 r2] := a64n_vrd _ _ 0 hvok _ _ _; 1..3: smt().
    have /= [q1 q2] := a64n_vrd _ _ 1 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hkq hkd hms /=.
    rewrite ?r1 ?q1 ?r2 ?q2 hvok !a64n_abok_keep // hc7 a64n_hab_new /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ s_init = a64n_I32 /\ a64n_hab ab_init t /\
             a64n_hab ab_init (t + 1)).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> [ha0 ha1] /=.
    have /= [r1 r2] := a64n_vrd _ _ 0 hvok _ _ _; 1..3: smt().
    have /= [q1 q2] := a64n_vrd _ _ 1 hvok _ _ _; 1..3: smt().
    have [b1 b2] := a64n_abrd _ _ habok _; 1: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hkq hkd hms /=.
    rewrite ?b1 ?r1 ?q1 ?r2 ?q2 a64n_keep64 // hvok !a64n_abok_keep // hc7 !a64n_hab_keep //.
    rewrite ?ha0 ?ha1 /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ s_init = a64n_I32 /\ a64n_hab ab_init t /\
             a64n_hab ab_init (t + 1)).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> [ha0 ha1] [hb0 hb1] /=.
    rewrite !valid_cat !a64n_valid1 hv ht hkq hkd hms !a64n_I32_init !a64n_I32_setd /=.
    rewrite a64n_I32_init hb0 hb1 hvok habok hc7 /a64n_hab ha0 ha1 hb0 hb1 /=.
    smt().
  seq 3 : (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ t_init /\
             0 <= t < 64 /\ k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\
             a64n_vok v_init t /\ a64n_abok ab_init t /\
             a64n_c7 v_init t /\ a64n_hab ab_init t /\ a64n_hab ab_init (t + 1)).
  + unroll for 3.
    auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 -> hab0 hab1 /=.
    have /= [r1 r2] := a64n_vrd _ _ 8 hvok _ _ _; 1..3: smt().
    rewrite !valid_cat !a64n_valid1 hv ht hkq hkd hms !a64n_I32_init /=.
    rewrite !a64n_vok_keep // !a64n_c7_keep // habok hab0 hab1 r1 a64n_keep288 //=.
    smt().
  auto => &m [#] hv hx hkq hkd hms ht ht0 ht64 -> -> -> hvok habok hc7 hab0 hab1.
  rewrite hv hx hkq hkd hms ht /=.
  split; first smt().
  split; first exact (a64n_vok_next _ _ _ hvok hc7).
  exact (a64n_abok_next _ _ ht0 hab0 hab1).
wp.
while (valid trace__sha256_x8_block /\ x_init /\ kq_init /\ kd_init /\ ms_init /\ 0 <= x <= 2 /\
       k_init = a64n_I256 /\ h8_init = a64n_I256 /\ w_init = a64n_I512 /\ a64n_vok v_init 0 /\
       (forall y, 0 <= y < 4 => y %% 2 = 1 => y < 2 * x => BArray64.is_init ab_init (y * 16) 16)).
+ auto => &m [#] hv hx hkq hkd hms hx0 hx2 -> -> -> hvok hab hlt /=.
  have h8 := hvok (9 * x{m} + 8) _ _; 1,2: smt().
  have h1 := hvok (9 * x{m} + 1) _ _; 1,2: smt().
  have h2 := hvok (9 * x{m} + 2) _ _; 1,2: smt().
  rewrite !valid_cat !a64n_valid1 hv hx hkq hkd h8 !a64n_keep288 // a64n_vok_keep //=.
  have hf : forall y0, 0 <= y0 < 4 => y0 %% 2 = 1 => y0 < 2 * (x{m} + 1) =>
    BArray64.is_init (BArray64.set128d ab_init{m} (16 * (2 * x{m} + 1)) a64n_ONE) (y0 * 16) 16.
  + move=> y0 hy0 hy1 hy2; rewrite a64n_slot64.
    by case: (2 * x{m} + 1 = y0) => h; [left | right; apply hab => /#].
  smt().
wp.
while (valid trace__sha256_x8_block /\ x_init /\ ms_init /\ 0 <= x <= 2 /\
       h8_init = a64n_I256 /\
       (forall y, 0 <= y < 9 * x => y %% 9 <> 7 => BArray288.is_init v_init (y * 16) 16)).
+ wp.
  while (valid trace__sha256_x8_block /\ x_init /\ ms_init /\ j_init /\ 0 <= x < 2 /\
         0 <= j <= 7 /\ h8_init = a64n_I256 /\
         (forall y, 0 <= y < 9 * x + j => y %% 9 <> 7 => BArray288.is_init v_init (y * 16) 16)).
  + auto => &m [#] hv hx hms hj hx0 hx2 hj0 hj7 -> hvi hlt /=.
    rewrite !valid_cat !a64n_valid1 hv hx hj !a64n_I256_init /=.
    have hf : forall y0, 0 <= y0 < 9 * x{m} + (j{m} + 1) => y0 %% 9 <> 7 =>
      BArray288.is_init (BArray288.set128d v_init{m} (16 * (9 * x{m} + j{m})) a64n_ONE)
        (y0 * 16) 16.
    + move=> y0 hy0 hy7; rewrite a64n_slot288.
      by case: (9 * x{m} + j{m} = y0) => h; [left | right; apply hvi => /#].
    smt().
  auto => &m [#] hv hx hms hx0 hx2 -> hvi hlt /=.
  split; first smt().
  move=> j0 tr0 v0 hj [#] htr _ _ _ _ hj0 hj7 hvi0.
  rewrite !valid_cat !a64n_valid1 htr hx !a64n_I256_init /=.
  have hf : forall y0, 0 <= y0 < 9 * (x{m} + 1) => y0 %% 9 <> 7 =>
    BArray288.is_init (BArray288.set128d v0 (16 * (9 * x{m} + 8)) a64n_ONE) (y0 * 16) 16.
  + move=> y0 hy0 hy7; rewrite a64n_slot288.
    by case: (9 * x{m} + 8 = y0) => h; [left | right; apply hvi0 => /#].
  smt().
auto => &m [#] /= -> -> _ _ _ hh hw.
rewrite (a64n_full256 _ hh) (a64n_full512 _ hw) /=.
split; first by rewrite /valid /=; smt().
move=> tr0 v0 x0 hx [#] htr hx0 hx2 hvi.
have hvok : a64n_vok v0 0.
+ by move=> y hy [/#|h7]; apply hvi => /#.
rewrite !valid_cat !a64n_valid1 htr a64n_I256_init hvok /=.
split; first smt().
move=> ab0 tr1 v1 x1 hx1 [#] htr1 hx10 hx12 hv1 hab1.
have habok : a64n_abok ab0 0.
+ by move=> y hy [/#|h1]; apply hab1 => /#.
rewrite htr1 hv1 habok /=.
move=> ab1 kd0 kq0 t0 tr2 v2 w0 x0' ht [#] htr2 hx0' hkq hkd ht0 ht64 hw0 hv2 hab2.
have ->> : t0 = 64 by smt().
by rewrite htr2 hx0' hkq hkd hw0 hv2.
qed.
