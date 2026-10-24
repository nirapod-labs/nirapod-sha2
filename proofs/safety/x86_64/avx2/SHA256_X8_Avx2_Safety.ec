(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_Avx2_Safety.ec
 * =======================
 *
 * Safety of the 8-way SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_x8_compress.jinc): for each of its functions F,
 * F_proof proves F_spec of the safety model (NirapodSha2Safety, extracted
 * by jasmin2ec -m safety), the Hoare triple stating that the #[safety]
 * contract's precondition gives its postcondition and that every
 * assertion of F's trace holds (array accesses in bounds and
 * initialised, memory accesses valid).
 *
 * The state v, the window w and the table stay fully initialised, so
 * every array fact is the full mask; what remains are the index bounds
 * (registers (k + 64 - t) mod 8, slots t mod 16, table words) and, for
 * the lanes form, the validity of each lane's 64 n bytes.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JModel_x86 Jcheck JSafety.
require import BArray32 BArray64 BArray256 BArray512 BArray2048.
require import NirapodSha2Safety Masks Valid.

clone Masks.Masks as X32 with theory A <- BArray32.
clone Masks.Masks as X64 with theory A <- BArray64.
clone Masks.Masks as X256 with theory A <- BArray256.
clone Masks.Masks as X512 with theory A <- BArray512.
clone Masks.Masks as X2048 with theory A <- BArray2048.

lemma __Sigma0_8x_proof _x : __Sigma0_8x_spec _x.
proof. by rewrite /__Sigma0_8x_spec; proc; auto => />; rewrite /valid. qed.

lemma __Sigma1_8x_proof _x : __Sigma1_8x_spec _x.
proof. by rewrite /__Sigma1_8x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sigma0_8x_proof _x : __sigma0_8x_spec _x.
proof. by rewrite /__sigma0_8x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sigma1_8x_proof _x : __sigma1_8x_spec _x.
proof. by rewrite /__sigma1_8x_spec; proc; auto => />; rewrite /valid. qed.

lemma __sha256_x8_round_proof _v _wk _cc _t _v_init :
  __sha256_x8_round_spec _v _wk _cc _t _v_init.
proof.
rewrite /__sha256_x8_round_spec; proc.
inline *; auto => /> hv.
rewrite (X256.is_init_full _ hv) ?X256.full_set256d ?X256.full_init /=.
by do ?split; smt(modz_cmp).
qed.

lemma __sha256_x8_schedule_proof _w _t _w_init : __sha256_x8_schedule_spec _w _t _w_init.
proof.
rewrite /__sha256_x8_schedule_spec; proc.
inline *; auto => /> hw.
rewrite (X512.is_init_full _ hw) ?X512.full_set256d ?X512.full_init /=.
by do ?split; smt(modz_cmp).
qed.

lemma __sha256_x8_transpose_proof _r _mask _r_init : __sha256_x8_transpose_spec _r _mask _r_init.
proof.
rewrite /__sha256_x8_transpose_spec; proc.
unroll for ^while; unroll for ^while.
auto => /> hr.
rewrite (X256.is_init_full _ hr) ?X256.full_init /=.
by do ?split; try (move=> i h1 h2 /=); smt().
qed.

lemma __sha256_x8_round_full v0 wk0 cc0 t0 :
  hoare [M.__sha256_x8_round : v = v0 /\ wk = wk0 /\ cc = cc0 /\ t = t0 /\ v_init = X256.full ==>
         res.`3 = X256.full /\ valid res.`4].
proof.
have := __sha256_x8_round_proof v0 wk0 cc0 t0 X256.full; rewrite /__sha256_x8_round_spec => h.
conseq h.
+ by move=> &hr [#] -> -> -> -> ->; rewrite X256.full_init.
by move=> &hr _ r [h1 h2]; rewrite (X256.is_init_full _ h1).
qed.

lemma __sha256_x8_schedule_full w0 t0 :
  hoare [M.__sha256_x8_schedule : w = w0 /\ t = t0 /\ w_init = X512.full ==>
         res.`3 = X512.full /\ valid res.`4].
proof.
have := __sha256_x8_schedule_proof w0 t0 X512.full; rewrite /__sha256_x8_schedule_spec => h.
conseq h.
+ by move=> &hr [#] -> -> ->; rewrite X512.full_init.
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

lemma x8s_schedule_true : hoare [M.__sha256_x8_schedule : true ==> true].
proof. by proc; inline *; auto. qed.

lemma _sha256_x8_block_proof _h8 _w _ms _h8_init _w_init :
  _sha256_x8_block_spec _h8 _w _ms _h8_init _w_init.
proof.
rewrite /_sha256_x8_block_spec; proc.
(* step 4 *)
wp; while (valid trace__sha256_x8_block /\ 0 <= i <= 8 /\ i_init /\ ms_init /\
           h8_init = X256.full /\ v_init = X256.full /\ w_init = X512.full).
+ by auto => /> &hr hv hi0 hi1 hi; rewrite !valid_cat hv /valid /= X256.full_set256d X256.full_init /#.
(* rounds 16 .. 63 *)
wp; while (valid trace__sha256_x8_block /\ ms_init /\ o_init /\ more_init /\ c0_init /\ c1_init /\
           more = (W64.to_uint o <= 1536) /\ 512 <= W64.to_uint o <= 2048 /\
           h8_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2048.full).
+ wp; while (valid trace__sha256_x8_block /\ ms_init /\ o_init /\ more_init /\ c0_init /\ c1_init /\
             t_init /\ 16 <= t <= 32 /\ 512 <= W64.to_uint o <= 1536 /\
             h8_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2048.full).
  + case (t %% 2 = 0).
    + rcondt ^if; 1: by wp; call x8s_schedule_true; auto.
      wp; ecall (__sha256_x8_round_full v wk c0 t); wp; ecall (__sha256_x8_schedule_full w t).
      auto => /> &hr hv _ _ _ _ _ _ ht0 ht1 ho0 ho1 ht2 _ r _ hr r0 _ hr0.
      have ho := addw o{hr} (32 * (t{hr} - 16)) _ _; 1,2: smt().
      by rewrite !valid_cat hv hr hr0 /valid /= ho X2048.full_init /=; smt().
    rcondf ^if; 1: by wp; call x8s_schedule_true; auto.
    wp; ecall (__sha256_x8_round_full v wk c1 t); wp; ecall (__sha256_x8_schedule_full w t).
    auto => /> &hr hv _ _ _ _ _ _ ht0 ht1 ho0 ho1 ht2 _ r _ hr r0 _ hr0.
    have ho := addw o{hr} (32 * (t{hr} - 16)) _ _; 1,2: smt().
    by rewrite !valid_cat hv hr hr0 /valid /= ho X2048.full_init /=; smt().
  auto => /> &hr hv _ _ _ _ _ ho0 ho1 ho2; split; 1: by rewrite !valid_cat hv /valid.
  move=> c0i c1i t' tr ht hv' _ _ ht1 ht2.
  have ho := addw o{hr} 512 _ _; 1,2: smt().
  by rewrite !valid_cat hv' /valid /= W64.uleE ho W64.of_uintK /=; smt().
(* rounds 0 .. 15 *)
wp; while (valid trace__sha256_x8_block /\ 0 <= t <= 16 /\ t_init /\ ms_init /\ c0_init /\
           (0 < t => c1_init) /\
           h8_init = X256.full /\ v_init = X256.full /\ w_init = X512.full /\ kp_init = X2048.full).
+ case (t %% 2 = 0).
  + rcondt ^if; 1: by auto.
    wp; ecall (__sha256_x8_round_full v wk c0 t).
    auto => /> &hr hv ht0 ht1 hti hms hc0 hc1 ht2 hev r hr3 hr.
    by rewrite !valid_cat hv hr /valid /= X512.full_init X2048.full_init /=; smt().
  rcondf ^if; 1: by auto.
  wp; ecall (__sha256_x8_round_full v wk c1 t).
  auto => /> &hr hv ht0 ht1 hti hms hc0 hc1 ht2 hodd r hr3 hr.
  have h1 : c1_init{hr} by apply hc1; smt().
  by rewrite !valid_cat hv hr /valid /= X512.full_init X2048.full_init h1 /=; smt().
(* v <- h8 *)
wp; while (valid trace__sha256_x8_block /\ 0 <= i <= 8 /\ i_init /\ ms_init /\
           BArray256.is_init h8_init 0 256 /\ BArray512.is_init w_init 0 512 /\
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
move=> c0i c1i t0 tr1 ht hv1 ht0 ht16 hc0 hc1; split.
+ by rewrite !all_cat hv1 /=; apply hc1; smt().
move=> c0i' c1i' more' mi msi o' oi tr2 hm hv2 _ _ _ _ _ hmo ho0 ho1; split.
+ by rewrite !all_cat hv2.
by move=> i1 tr3 hi1 hv3 _ _; rewrite !all_cat hv3.
qed.

lemma ext512 (m : BArray512.t) i : 0 <= i => BArray512.is_init m 0 (32 * i) =>
  BArray512.is_init
    (BArray512.set256d m (32 * i)
       (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935))
    0 (32 * i + 32).
proof.
move=> hi hm j hj1 hj2; rewrite BArray512.is_init_cell_set256d.
by case: (j < 32 * i) => hj; [right; apply hm | left] => /#.
qed.

lemma _sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init :
  _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init.
proof.
rewrite /_sha256_x8_compress_spec; proc.
wp; ecall (_sha256_x8_block_proof h8 w ms h8_init w_init).
wp; while (valid trace__sha256_x8_compress /\ 0 <= q <= 2 /\ q_init /\ mask_init /\ ms_init /\
       BArray256.is_init h8_init 0 256 /\ blocks_init = X512.full /\
       BArray512.is_init w_init 0 (32 * (8 * q))).
+ wp; while (valid trace__sha256_x8_compress /\ 0 <= k <= 8 /\ 0 <= q < 2 /\ q_init /\ k_init /\
             mask_init /\ ms_init /\ BArray256.is_init h8_init 0 256 /\ blocks_init = X512.full /\
             r_init = X256.full /\ BArray512.is_init w_init 0 (32 * (8 * q + k))).
  + auto => /> &hr hv hk0 hk1 hq0 hq1 _ _ _ _ hh hw hk.
    rewrite !valid_cat hv /valid /= X256.full_init /=.
    rewrite (_: 32 * (8 * q{hr} + (k{hr} + 1)) = 32 * (8 * q{hr} + k{hr}) + 32) 1:/# ext512 //; smt().
  wp; ecall (__sha256_x8_transpose_proof r mask r_init).
  wp; while (valid trace__sha256_x8_compress /\ 0 <= k <= 8 /\ 0 <= q < 2 /\ q_init /\ k_init /\
             mask_init /\ ms_init /\ BArray256.is_init h8_init 0 256 /\ blocks_init = X512.full /\
             BArray256.is_init r_init 0 (32 * k) /\ BArray512.is_init w_init 0 (32 * (8 * q))).
  + auto => /> &hr hv hk0 hk1 hq0 hq1 _ _ _ _ hh hr hw hk.
    rewrite !valid_cat hv /valid /= X512.full_init /=.
    rewrite (_: 32 * (k{hr} + 1) = 32 * k{hr} + 32) 1:/# ext256 //; smt().
  auto => /> &hr hv hq0 hq1 _ _ _ hh hw hq; split; 1: by move=> j /#.
  move=> k0 ri tr hk hv' hk0 hk1 hri.
  have hk8 : k0 = 8 by smt().
  have hrf : BArray256.is_init ri 0 256 by move: hri; rewrite hk8.
  split; 1: done. move=> _ r hr2 hr3; split.
  + by rewrite !valid_cat hv' hr3 /valid /= (X256.is_init_full _ hr2).
  move=> k1 tr1 wi hk' hv1 hk10 hk11 _ hwi.
  have hk18 : k1 = 8 by smt().
  split; 1: smt().
  by move: hwi; rewrite hk18 (_: 8 * q{hr} + 8 = 8 * (q{hr} + 1)) 1:/#.
auto => /> hh hb; split.
+ by rewrite (X512.is_init_full _ hb) /=; split; [exact (X32.full_init 0 32) | move=> j /#].
move=> q0 tr wi hq hv hq0 hq1 _ hwi.
have hq2 : q0 = 2 by smt().
have hw : BArray512.is_init wi 0 512 by move: hwi; rewrite hq2.
by split; 1: done; move=> _ r _ _ hr; rewrite !valid_cat hv hr /valid.
qed.

lemma mul64 (n : W64.t) : n \ult W64.of_int 288230376151711744 =>
  W64.to_uint (W64.of_int 64 * n) = 64 * W64.to_uint n.
proof.
rewrite W64.ultE W64.of_uintK /= => hn.
by rewrite W64.to_uintM_small W64.of_uintK /=; smt(W64.to_uint_cmp).
qed.

lemma vrows mv (p : W64.t) n : 1 <= n =>
  is_valid ptr_modulus mv (W64.to_uint p) (64 * n) =>
  is_valid ptr_modulus mv (W64.to_uint p) 32 /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int 32)) 32.
proof.
move=> hn h; split.
+ by move: h; rewrite is_validP => h; apply h => /#.
by apply (valid_sub _ _ _ 32 32 h) => /#.
qed.

(* What the block loop of the lanes form keeps. *)
op lsafe (mv : global_mem_v_t) (in0 : BArray64.t) (off n n0 : W64.t) =
  W64.to_uint n <= W64.to_uint n0 /\ n0 \ult W64.of_int 288230376151711744 /\
  forall L, 0 <= L < 8 =>
    is_valid ptr_modulus mv (W64.to_uint (BArray64.get64 in0 L + off)) (64 * W64.to_uint n).

lemma _sha256_x8_compress_lanes_proof _h8 _in _off _n _ms _h8_init _in_init :
  _sha256_x8_compress_lanes_spec _h8 _in _off _n _ms _h8_init _in_init.
proof.
rewrite /_sha256_x8_compress_lanes_spec.
conseq (_: in_0 = _in /\ off = _off /\ n = _n /\ h8_init = X256.full /\ in_init = X64.full /\
           lsafe Glob.mem_v _in _off _n _n ==> _).
+ move=> &hr [[#] -> -> _ -> -> -> _] /= [#] _ _ _ _ _ _ _ _ hh hi hn _ v0 v1 v2 v3 v4 v5 v6 v7.
  rewrite (X256.is_init_full _ hh) (X64.is_init_full _ hi) /=; split; 1: done. split; 1: done.
  move=> L hL; rewrite -(mul64 _ hn).
  by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] : L = 0 \/ L = 1 \/ L = 2 \/ L = 3 \/ L = 4 \/ L = 5 \/ L = 6 \/ L = 7 by smt().
proc.
wp; while (valid trace__sha256_x8_compress_lanes /\ more = (n <> W64.zero) /\ more_init /\
           off_init /\ n_init /\ ms_init /\ in_0 = _in /\ in_init = X64.full /\
           h8_init = X256.full /\ lsafe Glob.mem_v _in off n _n).
+ unroll for ^while; do 2!(unroll for ^while).
  wp; ecall (_sha256_x8_block_proof h8 w ms h8_init w_init).
  wp; ecall (__sha256_x8_transpose_proof r mask r_init).
  wp; ecall (__sha256_x8_transpose_proof r mask r_init).
  auto => /> &hr hv hmi hoi hni hmsi hnn hn hval hnz.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + have : W64.to_uint n{hr} <> 0 by move: hnz; apply contra => h; rewrite W64.to_uint_eq h.
    by smt(W64.to_uint_cmp).
  have := vrows _ _ _ hn1 (hval 0 _); 1: done; rewrite /= => -[a0 b0].
  have := vrows _ _ _ hn1 (hval 1 _); 1: done; rewrite /= => -[a1 b1].
  have := vrows _ _ _ hn1 (hval 2 _); 1: done; rewrite /= => -[a2 b2].
  have := vrows _ _ _ hn1 (hval 3 _); 1: done; rewrite /= => -[a3 b3].
  have := vrows _ _ _ hn1 (hval 4 _); 1: done; rewrite /= => -[a4 b4].
  have := vrows _ _ _ hn1 (hval 5 _); 1: done; rewrite /= => -[a5 b5].
  have := vrows _ _ _ hn1 (hval 6 _); 1: done; rewrite /= => -[a6 b6].
  have := vrows _ _ _ hn1 (hval 7 _); 1: done; rewrite /= => -[a7 b7].
  rewrite /SLH64.protect_64.
  split; 1: by move=> j hj1 hj2; rewrite !BArray256.is_init_cell_set256d; smt().
  move=> _ r1 hr1 hvr1; split; 1: by move=> j hj1 hj2; rewrite !BArray256.is_init_cell_set256d; smt().
  move=> _ r2 hr2 hvr2; split.
  + split; 1: exact (X256.full_init 0 256).
    by move=> j hj1 hj2; rewrite !BArray512.is_init_cell_set256d; smt().
  move=> _ _ r3 hr3a hr3b hvr3.
  rewrite !valid_cat hv hvr1 hvr2 hvr3 /valid /= ?X64.full_init ?X32.full_init /=.
  rewrite (X256.is_init_full _ hr1) (X256.is_init_full _ hr2) (X256.is_init_full _ hr3a) ?X256.full_init /=.
  rewrite a0 a1 a2 a3 a4 a5 a6 a7 b0 b1 b2 b3 b4 b5 b6 b7 /=.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
  rewrite hsub; split; 1: smt().
  move=> L hL0 hL1.
  have := valid_step 64 _ _ _ _ (hval L _) hnz; 1,2: smt().
  move=> [_]; rewrite -addrA /is_valid hsub => -[h1 [h2 h3]].
  by split; [move=> i hi1 hi2; apply h1 => /# | split => //; smt(pow2_64)].
auto => />.
by move=> &hr hn hval more0 mi msi n0 ni off0 oi tr hm hv *; rewrite X256.full_init /= !valid_cat hv /valid.
qed.
