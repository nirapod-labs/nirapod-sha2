(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2X4_Safety.ec
 * =======================
 *
 * Safety of the 4-way SHA-512 AVX2 kernel
 * (src/x86_64/avx2/sha512_x4_compress.jinc): for each of its functions F,
 * F_proof proves F_spec of the safety model (NirapodSha2Safety, extracted
 * by jasmin2ec -m safety), the Hoare triple stating that the #[safety]
 * contract's precondition gives its postcondition and that every
 * assertion of F's trace holds (array accesses in bounds and
 * initialised, memory accesses valid).
 *
 * The state v, the window w and the table stay fully initialised, so
 * every array fact is the full mask; what remains are the index bounds
 * (registers (k + 80 - t) mod 8, slots t mod 16, table words) and, for
 * the lanes form, the validity of each lane's 128 n bytes.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray32 BArray256 BArray512 BArray2560.
require import NirapodSha2Safety Masks Valid.

clone Masks.Masks as X32 with theory A <- BArray32.
clone Masks.Masks as X256 with theory A <- BArray256.
clone Masks.Masks as X512 with theory A <- BArray512.
clone Masks.Masks as X2560 with theory A <- BArray2560.

lemma __Sigma0_4x_proof _x : __Sigma0_4x_spec _x.
proof. by rewrite /__Sigma0_4x_spec; proc; auto => />; rewrite /valid. qed.

lemma __Sigma1_4x_proof _x : __Sigma1_4x_spec _x.
proof. by rewrite /__Sigma1_4x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sigma0_4x_proof _x _ror8 : __sigma0_4x_spec _x _ror8.
proof. by rewrite /__sigma0_4x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sigma1_4x_proof _x : __sigma1_4x_spec _x.
proof. by rewrite /__sigma1_4x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sha512_x4_round_proof _v _wk _cc _t _v_init :
  __sha512_x4_round_spec _v _wk _cc _t _v_init.
proof.
rewrite /__sha512_x4_round_spec; proc.
inline *; auto => /> hv.
rewrite (X256.is_init_full _ hv) ?X256.full_set256d ?X256.full_init /=.
by do ?split; smt(modz_cmp).
qed.

lemma __sha512_x4_schedule_proof _w _t _ror8 _w_init : __sha512_x4_schedule_spec _w _t _ror8 _w_init.
proof.
rewrite /__sha512_x4_schedule_spec; proc.
inline *; auto => /> hw.
rewrite (X512.is_init_full _ hw) ?X512.full_set256d ?X512.full_init /=.
by do ?split; smt(modz_cmp).
qed.

lemma __sha512_x4_transpose_proof _r0 _r1 _r2 _r3 _mask : __sha512_x4_transpose_spec _r0 _r1 _r2 _r3 _mask.
proof. by rewrite /__sha512_x4_transpose_spec; proc; auto => />; rewrite /valid. qed.

lemma __sha512_x4_round_full v0 wk0 cc0 t0 :
  hoare [M.__sha512_x4_round : v = v0 /\ wk = wk0 /\ cc = cc0 /\ t = t0 /\ v_init = X256.full ==>
         res.`3 = X256.full /\ valid res.`4].
proof.
have := __sha512_x4_round_proof v0 wk0 cc0 t0 X256.full; rewrite /__sha512_x4_round_spec => h.
conseq h.
+ by move=> &hr [#] -> -> -> -> ->; rewrite X256.full_init.
by move=> &hr _ r [h1 h2]; rewrite (X256.is_init_full _ h1).
qed.

lemma __sha512_x4_schedule_full w0 t0 m0 :
  hoare [M.__sha512_x4_schedule : w = w0 /\ t = t0 /\ ror8 = m0 /\ w_init = X512.full ==>
         res.`3 = X512.full /\ valid res.`4].
proof.
have := __sha512_x4_schedule_proof w0 t0 m0 X512.full; rewrite /__sha512_x4_schedule_spec => h.
conseq h.
+ by move=> &hr [#] -> -> -> ->; rewrite X512.full_init.
by move=> &hr _ r [h1 h2]; rewrite (X512.is_init_full _ h1).
qed.

lemma addw (o : W64.t) n : 0 <= n < 4096 => W64.to_uint o <= 2048 =>
  W64.to_uint (o + W64.of_int n) = W64.to_uint o + n.
proof.
move=> hn ho; rewrite W64.to_uintD_small !W64.of_uintK (pmod_small n) //; smt(W64.to_uint_cmp pow2_64).
qed.

(* A 256-bit write of the all-ones word right after an initialised
   prefix extends the prefix. *)
lemma ext256 (m : BArray256.t) i : 0 <= i => BArray256.is_init m 0 (32 * i) =>
  BArray256.is_init
    (BArray256.set256d m (32 * i)
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    0 (32 * i + 32).
proof.
move=> hi hm j hj1 hj2; rewrite BArray256.is_init_cell_set256d.
by case: (j < 32 * i) => hj; [right; apply hm | left] => /#.
qed.

lemma x4s_schedule_true : hoare [M.__sha512_x4_schedule : true ==> true].
proof. by proc; inline *; auto. qed.

lemma _sha512_x4_block_proof _h4 _w _ms _h4_init _w_init :
  _sha512_x4_block_spec _h4 _w _ms _h4_init _w_init.
proof.
rewrite /_sha512_x4_block_spec; proc.
(* step 4 *)
wp; while (valid trace__sha512_x4_block /\ 0 <= i <= 8 /\ i_init /\ ms_init /\
           h4_init = X256.full /\ v_init = X256.full /\ w_init = X512.full).
+ by auto => /> &hr hv hi0 hi1 hi; rewrite !valid_cat hv /valid /= X256.full_set256d X256.full_init /#.
(* rounds 16 .. 63 *)
wp; while (valid trace__sha512_x4_block /\ ms_init /\ o_init /\ more_init /\ c0_init /\ c1_init /\
           ror8_init /\ more = (W64.to_uint o <= 2048) /\ 512 <= W64.to_uint o <= 2560 /\
           h4_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2560.full).
+ wp; while (valid trace__sha512_x4_block /\ ms_init /\ o_init /\ more_init /\ c0_init /\ c1_init /\
             t_init /\ ror8_init /\ 16 <= t <= 32 /\ 512 <= W64.to_uint o <= 2048 /\
             h4_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2560.full).
  + case (t %% 2 = 0).
    + rcondt ^if; 1: by wp; call x4s_schedule_true; auto.
      wp; ecall (__sha512_x4_round_full v wk c0 t); wp; ecall (__sha512_x4_schedule_full w t ror8).
      auto => /> &hr hv _ _ _ _ _ _ _ ht0 ht1 ho0 ho1 ht2 _ r _ hr r0 _ hr0.
      have ho := addw o{hr} (32 * (t{hr} - 16)) _ _; 1,2: smt().
      by rewrite !valid_cat hv hr hr0 /valid /= ho X2560.full_init /=; smt().
    rcondf ^if; 1: by wp; call x4s_schedule_true; auto.
    wp; ecall (__sha512_x4_round_full v wk c1 t); wp; ecall (__sha512_x4_schedule_full w t ror8).
    auto => /> &hr hv _ _ _ _ _ _ _ ht0 ht1 ho0 ho1 ht2 _ r _ hr r0 _ hr0.
    have ho := addw o{hr} (32 * (t{hr} - 16)) _ _; 1,2: smt().
    by rewrite !valid_cat hv hr hr0 /valid /= ho X2560.full_init /=; smt().
  auto => /> &hr hv _ _ _ _ _ _ ho0 ho1 ho2; split; 1: by rewrite !valid_cat hv /valid.
  move=> c0i c1i t' tr ht hv' _ _ ht1 ht2.
  have ho := addw o{hr} 512 _ _; 1,2: smt().
  by rewrite !valid_cat hv' /valid /= W64.uleE ho W64.of_uintK /=; smt().
(* rounds 0 .. 15 *)
wp; while (valid trace__sha512_x4_block /\ 0 <= t <= 16 /\ t_init /\ ror8_init /\ ms_init /\ c0_init /\
           (0 < t => c1_init) /\
           h4_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2560.full).
+ case (t %% 2 = 0).
  + rcondt ^if; 1: by auto.
    wp; ecall (__sha512_x4_round_full v wk c0 t).
    auto => /> &hr hv ht0 ht1 hti hro hms hc0 hc1 ht2 hev r hr3 hr.
    by rewrite !valid_cat hv hr /valid /= X512.full_init X2560.full_init /=; smt().
  rcondf ^if; 1: by auto.
  wp; ecall (__sha512_x4_round_full v wk c1 t).
  auto => /> &hr hv ht0 ht1 hti hro hms hc0 hc1 ht2 hodd r hr3 hr.
  have h1 : c1_init{hr} by apply hc1; smt().
  by rewrite !valid_cat hv hr /valid /= X512.full_init X2560.full_init h1 /=; smt().
(* v <- h8 *)
wp; while (valid trace__sha512_x4_block /\ 0 <= i <= 8 /\ i_init /\ ms_init /\
           BArray256.is_init h4_init 0 256 /\ BArray512.is_init w_init 0 512 /\
           BArray256.is_init v_init 0 (32 * i)).
+ auto => /> &hr hv hi0 hi1 hii hms hh hw hvi hi.
  rewrite !valid_cat hv /valid /= (X256.is_init_sub _ 0 256) //; 1,2: smt().
  by rewrite (_: 32 * (i{hr} + 1) = 32 * i{hr} + 32) 1:/# ext256 //; smt().
auto => /> hh hw.
have hhf := X256.is_init_full _ hh; have hwf := X512.is_init_full _ hw.
split; 1: by move=> j /#.
move=> i0 tr vi hi hv hi0 hi8 hvi.
have h8 : i0 = 8 by smt().
have hvf : vi = X256.full by apply X256.is_init_full; move: hvi; rewrite h8.
rewrite hvf hhf hwf /= !valid_cat hv /valid /= ?X256.full_init /=.
split; 1: exact (X32.full_init 0 32).
move=> c0i c1i t0 tr1 ht hv1 ht0 ht16 hc0 hc1; split.
+ by rewrite !all_cat hv1 /=; apply hc1; smt().
move=> c0i' c1i' more' mi msi o' oi tr2 hm hv2 _ _ _ _ _ hmo ho0 ho1; split.
+ by rewrite !all_cat hv2.
by move=> i1 tr3 hi1 hv3 _ _; rewrite !all_cat hv3.
qed.


lemma _sha512_x4_compress_proof _h4 _blocks _ms _h4_init _blocks_init :
  _sha512_x4_compress_spec _h4 _blocks _ms _h4_init _blocks_init.
proof.
rewrite /_sha512_x4_compress_spec; proc.
wp; ecall (_sha512_x4_block_proof h4 w ms h4_init w_init).
wp; while (valid trace__sha512_x4_compress /\ 0 <= q <= 4 /\ q_init /\ mask_init /\ ms_init /\
       BArray256.is_init h4_init 0 256 /\ blocks_init = X512.full /\
       BArray512.is_init w_init 0 (32 * (4 * q))).
+ wp; ecall (__sha512_x4_transpose_proof r0 r1 r2 r3 mask).
  auto => /> &hr hv hq0 hq1 _ _ _ hh hw hq r hr.
  rewrite !valid_cat hv hr /valid /= ?X512.full_init /=; split; 1: smt().
  split; 1: smt().
  move=> j hj1 hj2; rewrite !BArray512.is_init_cell_set256d.
  case: (j < 32 * (4 * q{hr})) => hj; [by right; right; right; right; apply hw | smt()].
auto => /> hh hb; split.
+ by rewrite (X512.is_init_full _ hb) /=; split; [exact (X32.full_init 0 32) | move=> j /#].
move=> q0 tr wi hq hv hq0 hq1 _ hwi.
have hq2 : q0 = 4 by smt().
have hw : BArray512.is_init wi 0 512 by move: hwi; rewrite hq2.
by split; 1: done; move=> _ r _ _ hr; rewrite !valid_cat hv hr /valid.
qed.

lemma mul128 (n : W64.t) : n \ult W64.of_int 144115188075855872 =>
  W64.to_uint (W64.of_int 128 * n) = 128 * W64.to_uint n.
proof.
rewrite W64.ultE W64.of_uintK /= => hn.
by rewrite W64.to_uintM_small W64.of_uintK /=; smt(W64.to_uint_cmp).
qed.

lemma vrows4 mv (p : W64.t) n : 1 <= n =>
  is_valid ptr_modulus mv (W64.to_uint p) (128 * n) =>
  is_valid ptr_modulus mv (W64.to_uint p) 32 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 32)) 32 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 64)) 32 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 96)) 32.
proof.
move=> hn h; split.
+ by move: h; rewrite is_validP => h; apply h => /#.
split; 1: by apply (valid_sub _ _ _ 32 32 h) => /#.
split; 1: by apply (valid_sub _ _ _ 64 32 h) => /#.
by apply (valid_sub _ _ _ 96 32 h) => /#.
qed.

(* What the block loop of the lanes form keeps. *)
op lsafe (mv : global_mem_v_t) (in0 : BArray32.t) (off n n0 : W64.t) =
  W64.to_uint n <= W64.to_uint n0 /\ n0 \ult W64.of_int 144115188075855872 /\
  forall L, 0 <= L < 4 =>
    is_valid ptr_modulus mv (W64.to_uint (BArray32.get64 in0 L + off)) (128 * W64.to_uint n).

lemma _sha512_x4_compress_lanes_proof _h4 _in _off _n _ms _h4_init _in_init :
  _sha512_x4_compress_lanes_spec _h4 _in _off _n _ms _h4_init _in_init.
proof.
rewrite /_sha512_x4_compress_lanes_spec.
conseq (_: in_0 = _in /\ off = _off /\ n = _n /\ h4_init = X256.full /\ in_init = X32.full /\
           lsafe Glob.mem_v _in _off _n _n ==> _).
+ move=> &hr [[#] -> -> _ -> -> -> _] /= [#] _ _ _ _ hh hi hn _ v0 v1 v2 v3.
  rewrite (X256.is_init_full _ hh) (X32.is_init_full _ hi) /=; split; 1: done. split; 1: done.
  move=> L hL; rewrite -(mul128 _ hn).
  by have [->|[->|[->|->]]] : L = 0 \/ L = 1 \/ L = 2 \/ L = 3 by smt().
proc.
wp; while (valid trace__sha512_x4_compress_lanes /\ more = (n <> W64.zero) /\ more_init /\
           off_init /\ n_init /\ ms_init /\ in_0 = _in /\ in_init = X32.full /\
           h4_init = X256.full /\ lsafe Glob.mem_v _in off n _n).
+ unroll for ^while.
  wp; ecall (_sha512_x4_block_proof h4 w ms h4_init w_init).
  wp; ecall (__sha512_x4_transpose_proof r0 r1 r2 r3 mask).
  wp; ecall (__sha512_x4_transpose_proof r0 r1 r2 r3 mask).
  wp; ecall (__sha512_x4_transpose_proof r0 r1 r2 r3 mask).
  wp; ecall (__sha512_x4_transpose_proof r0 r1 r2 r3 mask).
  auto => /> &hr hv hmi hoi hni hmsi hnn hn hval hnz.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + have : W64.to_uint n{hr} <> 0 by move: hnz; apply contra => h; rewrite W64.to_uint_eq h.
    by smt(W64.to_uint_cmp).
  have := vrows4 _ _ _ hn1 (hval 0 _); 1: done; rewrite /= => -[a0 [b0 [c0 d0]]].
  have := vrows4 _ _ _ hn1 (hval 1 _); 1: done; rewrite /= => -[a1 [b1 [c1 d1]]].
  have := vrows4 _ _ _ hn1 (hval 2 _); 1: done; rewrite /= => -[a2 [b2 [c2 d2]]].
  have := vrows4 _ _ _ hn1 (hval 3 _); 1: done; rewrite /= => -[a3 [b3 [c3 d3]]].
  rewrite /SLH64.protect_64.
  move=> r1 hr1 r2 hr2 r3 hr3 r4 hr4; split.
  + split; 1: exact (X256.full_init 0 256).
    by move=> j hj1 hj2; rewrite !BArray512.is_init_cell_set256d; smt().
  move=> _ _ r5 hr5a hr5b hvr5.
  rewrite !valid_cat hv hr1 hr2 hr3 hr4 hvr5 /valid /= ?X32.full_init /=.
  rewrite (X256.is_init_full _ hr5a) /=.
  rewrite a0 a1 a2 a3 b0 b1 b2 b3 c0 c1 c2 c3 d0 d1 d2 d3 /=.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
  rewrite hsub; split; 1: smt().
  move=> L hL0 hL1.
  have := valid_step 128 _ _ _ _ (hval L _) hnz; 1,2: smt().
  move=> [_]; rewrite -addrA /is_valid hsub => -[h1 [h2 h3]].
  by split; [move=> i hi1 hi2; apply h1 => /# | split => //; smt(pow2_64)].
auto => />.
by move=> &hr hn hval more0 mi msi n0 ni off0 oi tr hm hv *; rewrite X256.full_init /= !valid_cat hv /valid.
qed.
