(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_KernelSafety.ec
 * ======================
 *
 * Safety of the portable SHA-512 compression kernel,
 * src/sha512_compress.jinc: for each function F of the kernel, F_proof
 * proves F_spec of the safety model, the #[safety] contract of F with
 * every assertion of its body (array bounds, initialised reads, valid
 * memory). Checked on every unit whose SHA-512 kernel is the portable one.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetyFill.
require import BArray64 BArray128 BArray640 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Section 4.1.3 functions                                            *)

lemma __Sigma0_512_proof _x : __Sigma0_512_spec _x.
proof. by rewrite /__Sigma0_512_spec; proc; auto. qed.

lemma __Sigma1_512_proof _x : __Sigma1_512_spec _x.
proof. by rewrite /__Sigma1_512_spec; proc; auto. qed.

lemma __sigma0_512_proof _x : __sigma0_512_spec _x.
proof. by rewrite /__sigma0_512_spec; proc; auto. qed.

lemma __sigma1_512_proof _x : __sigma1_512_spec _x.
proof. by rewrite /__sigma1_512_spec; proc; auto. qed.

(* ------------------------------------------------------------------ *)
(* The rounds                                                         *)

lemma __sha512_rounds_proof _h _w _h_init _w_init :
  __sha512_rounds_spec _h _w _h_init _w_init.
proof.
rewrite /__sha512_rounds_spec; proc.
while (valid trace___sha512_rounds /\ i_init /\ 0 <= i <= 8
       /\ h_init = full64 /\ v_init = full64).
+ auto => /> &m _ _ hi0 hi8 hlt.
  by rewrite full64_set64d !full64_init /=; smt().
wp; while (valid trace___sha512_rounds /\ t_init /\ 0 <= t <= 80
       /\ h_init = full64 /\ v_init = full64 /\ w_init = full128).
+ seq 1 : (valid trace___sha512_rounds /\ t_init /\ 0 <= t < 80
           /\ h_init = full64 /\ v_init = full64 /\ w_init = full128).
  + by auto => />.
  seq 1 : (valid trace___sha512_rounds /\ t_init /\ 0 <= t < 80
           /\ h_init = full64 /\ v_init = full64 /\ w_init = full128 /\ t1_init).
  + if.
    + wp; ecall (__sigma0_512_proof x); wp; ecall (__sigma1_512_proof x).
      auto => /> &m *.
      by rewrite full128_set64d !full128_init /=; smt(modz_ge0 ltz_pmod).
    auto => /> &m *.
    by rewrite full128_init /=; smt().
  wp; ecall (__Sigma0_512_proof (BArray64.get64 v (((0 + 80) - t) %% 8))).
  wp; ecall (__Sigma1_512_proof (BArray64.get64 v (((4 + 80) - t) %% 8))).
  auto => /> &m *.
  by rewrite ?full64_set64d !full64_init ?full128_init ?full640_init /=; smt(modz_ge0 ltz_pmod).
wp; while (valid trace___sha512_rounds /\ i_init /\ 0 <= i <= 8
       /\ h_init = full64 /\ w_init = full128 /\ BArray64.is_init v_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hv hlt.
  rewrite full64_init /=; do 2!(split; 1: smt()).
  by apply mask64_set64 => /#.
auto => /> hh hw.
split; 1: by rewrite (full64E _ hh) (full128E _ hw) /=; move=> j /#.
move=> i0 tr0 vi0 hlt _ _ hi8 _ _ hv; apply full64E.
by have <- : 8 * i0 = 64 by smt().
qed.

(* ------------------------------------------------------------------ *)
(* The entry points                                                   *)

lemma _sha512_compress_proof _h _block _ms _h_init _block_init :
  _sha512_compress_spec _h _block _ms _h_init _block_init.
proof.
rewrite /_sha512_compress_spec; proc.
wp; ecall (__sha512_rounds_proof h w h_init w_init).
wp; while (valid trace__sha512_compress /\ i_init /\ 0 <= i <= 16
       /\ block_init = full128 /\ BArray128.is_init w_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ hi0 hi16 hw hlt r hr.
  rewrite full128_init /=; do 2!(split; 1: smt()).
  by apply mask128_set64 => /#.
auto => /> hh hb.
split; 1: by rewrite (full128E _ hb); move=> j /#.
move=> i0 tr0 wi0 hlt _ _ hi16 _ hw.
by have <- : 8 * i0 = 128 by smt().
qed.

lemma _sha512_compress_one_proof _h _p _ms _h_init :
  _sha512_compress_one_spec _h _p _ms _h_init.
proof.
rewrite /_sha512_compress_one_spec; proc.
wp; ecall (__sha512_rounds_proof h w h_init w_init).
wp; while (valid trace__sha512_compress_one /\ i_init /\ p_init /\ 0 <= i <= 16 /\ p = _p
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p) 128
       /\ BArray128.is_init w_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ _ hi0 hi16 hv hp0 hp64 hw hlt r hr.
  rewrite addc_small 1,2:/#.
  do !split; 1: (by move=> j hj1 hj2; apply hv => /#); 1..6: smt().
  by apply mask128_set64 => /#.
auto => /> &m hh hv hp0 hp64; split; 1: by move=> j /#.
move=> i0 tr0 wi0 hlt _ _ hi16 hw.
by have <- : 8 * i0 = 128 by smt().
qed.

lemma _sha512_compress_blocks_proof _h _p _n _ms _h_init :
  _sha512_compress_blocks_spec _h _p _n _ms _h_init.
proof.
rewrite /_sha512_compress_blocks_spec; proc.
wp; while (valid trace__sha512_compress_blocks /\ p_init /\ n_init /\ more_init /\ ms_init
       /\ more = (n <> W64.of_int 0) /\ to_uint n < 144115188075855872
       /\ BArray64.is_init h_init 0 64
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint p) (128 * to_uint n)).
+ wp; ecall (_sha512_compress_one_proof h p ms h_init); auto => /> &m _ _ _ _ _ hn hh hv hp0 hpn hnz.
  have hn1 := nonzero _ hnz.
  split; 1: by split; [move=> i hi1 hi2; apply hv => /# | smt()].
  move=> _ _ _ r hr1 hr2; rewrite /protect_64 subone // addc_small 1,2:/#.
  by do !split; 1: smt(); 1: (move=> i hi1 hi2; apply hv => /#); smt().
auto => /> &m hh hlt hv hp0 hpn.
have hn := ult_const _ _ _ hlt; 1: done.
have e := mulc_small _n 128 _ _; 1,2: smt(W64.to_uint_cmp).
by move: hv hpn; rewrite e => hv hpn; do !split => //; move=> i hi1 hi2; apply hv.
qed.
