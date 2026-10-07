(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyHmac.ec
 * =============
 *
 * Safety of HMAC-SHA-256 and HMAC-SHA-512 of src/hmac.jinc: the key
 * block for keys of any length, the inner and outer initial states, the
 * outer hash and the one-shot functions. The hashes enter through
 * SafetySha256 and SafetySha512.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK256 SafetyK512.
require import SafetySha256 SafetySha512.
require import BArray32 BArray64 BArray128 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Key block                                                          *)

lemma _hmac_sha256_keyblock_mem_proof _k0 _key _keylen _ms _k0_init :
  _hmac_sha256_keyblock_mem_spec _k0 _key _keylen _ms _k0_init.
proof.
rewrite /_hmac_sha256_keyblock_mem_spec; proc; sp.
seq 1 : (valid trace__hmac_sha256_keyblock_mem /\ ms_init /\ i_init
         /\ to_uint i <= 64 /\ BArray64.is_init k0_init 0 (to_uint i)).
+ if.
  + wp; while (valid trace__hmac_sha256_keyblock_mem /\ j_init /\ ms_init /\ 0 <= j <= 4
               /\ digest_init = full32 /\ k0_init = full64).
    + by auto => /> &m _ _ hj0 hj4 hlt; rewrite full64_set64d full32_init /=; smt().
    wp; ecall (_sha256_mem_proof digest key keylen ms digest_init); auto => /> &m.
    move=> _ _ _ _ r hr _; split; 1: exact (full32E _ hr).
    by move=> *; exact (full64_init 0 32).
  wp; ecall (__fill64_mem_proof k0 i key keylen ms k0_init); auto => /> &m.
  move=> hv hp0 hpl; rewrite !W64.ultE !W64.uleE /= => hl.
  by split; [do !split => //; try (move=> j /#); smt() | smt()].
wp; ecall (__zero64_proof k0 i hi ms k0_init); auto => /> &m _ _ _ hi hk.
by rewrite !W64.uleE /= hi.
qed.

lemma _hmac_sha512_keyblock_mem_proof _k0 _key _keylen _ms _k0_init :
  _hmac_sha512_keyblock_mem_spec _k0 _key _keylen _ms _k0_init.
proof.
rewrite /_hmac_sha512_keyblock_mem_spec; proc; sp.
seq 1 : (valid trace__hmac_sha512_keyblock_mem /\ ms_init /\ i_init
         /\ to_uint i <= 128 /\ BArray128.is_init k0_init 0 (to_uint i)).
+ if.
  + wp; while (valid trace__hmac_sha512_keyblock_mem /\ j_init /\ ms_init /\ 0 <= j <= 8
               /\ digest_init = full64 /\ k0_init = full128).
    + by auto => /> &m _ _ hj0 hj4 hlt; rewrite full128_set64d full64_init /=; smt().
    wp; ecall (_sha512_mem_proof digest key keylen ms digest_init); auto => /> &m.
    move=> _ _ _ _ r hr _; split; 1: exact (full64E _ hr).
    by move=> *; exact (full128_init 0 64).
  wp; ecall (__fill128_mem_proof k0 i key keylen ms k0_init); auto => /> &m.
  move=> hv hp0 hpl; rewrite !W64.ultE !W64.uleE /= => hl.
  by split; [do !split => //; try (move=> j /#); smt() | smt()].
wp; ecall (__zero128_proof k0 i hi ms k0_init); auto => /> &m _ _ _ hi hk.
by rewrite !W64.uleE /= hi.
qed.

(* ------------------------------------------------------------------ *)
(* Inner and outer initial states                                     *)

lemma __hmac_sha256_init_proof _inner _outer _k0 _ms _inner_init _outer_init _k0_init :
  __hmac_sha256_init_spec _inner _outer _k0 _ms _inner_init _outer_init _k0_init.
proof.
rewrite /__hmac_sha256_init_spec; proc.
wp; ecall (_sha256_compress_proof outer opad ms outer_init opad_init).
wp; ecall (__sha256_init_proof outer outer_init).
wp; ecall (_sha256_compress_proof inner ipad ms inner_init ipad_init).
wp; ecall (__sha256_init_proof inner inner_init).
wp; while (valid trace___hmac_sha256_init /\ i_init /\ mi_init /\ mo_init /\ ms_init /\ 0 <= i <= 8 /\ k0_init = full64
       /\ BArray64.is_init ipad_init 0 (8 * i) /\ BArray64.is_init opad_init 0 (8 * i)).
+ auto => /> &m _ _ _ _ _ hi0 hi8 hp ho hlt.
  have h1 := mask64_set64 ipad_init{m} i{m} hp _ _; 1,2: smt().
  have h2 := mask64_set64 opad_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full64_init h1 h2 /=; smt().
auto => /> hk; split; 1: by do !split; [exact full64E | move=> j /# | move=> j /#].
move=> i0 ip0 op0 _ hi _ hi0 hi8 _ hp ho; have e : 8 * i0 = 64 by smt().
by move: hp ho; rewrite e => hp ho.
qed.

lemma __hmac_sha512_init_proof _inner _outer _k0 _ms _inner_init _outer_init _k0_init :
  __hmac_sha512_init_spec _inner _outer _k0 _ms _inner_init _outer_init _k0_init.
proof.
rewrite /__hmac_sha512_init_spec; proc.
wp; ecall (_sha512_compress_proof outer opad ms outer_init opad_init).
wp; ecall (__sha512_init_proof outer outer_init).
wp; ecall (_sha512_compress_proof inner ipad ms inner_init ipad_init).
wp; ecall (__sha512_init_proof inner inner_init).
wp; while (valid trace___hmac_sha512_init /\ i_init /\ mi_init /\ mo_init /\ ms_init /\ 0 <= i <= 16 /\ k0_init = full128
       /\ BArray128.is_init ipad_init 0 (8 * i) /\ BArray128.is_init opad_init 0 (8 * i)).
+ auto => /> &m _ _ _ _ _ hi0 hi8 hp ho hlt.
  have h1 := mask128_set64 ipad_init{m} i{m} hp _ _; 1,2: smt().
  have h2 := mask128_set64 opad_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full128_init h1 h2 /=; smt().
auto => /> hk; split; 1: by do !split; [exact full128E | move=> j /# | move=> j /#].
move=> i0 ip0 op0 _ hi _ hi0 hi8 _ hp ho; have e : 8 * i0 = 128 by smt().
by move: hp ho; rewrite e => hp ho.
qed.

(* ------------------------------------------------------------------ *)
(* Outer hash                                                         *)

lemma __hmac_sha256_outer_proof _inner _buf _total _outer _ms _inner_init _buf_init _outer_init :
  __hmac_sha256_outer_spec _inner _buf _total _outer _ms _inner_init _buf_init _outer_init.
proof.
rewrite /__hmac_sha256_outer_spec; proc.
wp; while (valid trace___hmac_sha256_outer /\ i_init /\ ms_init /\ 0 <= i <= 4
           /\ inner_init = full32 /\ buf_init = full64 /\ digest_init = full32).
+ by auto => /> &m _ _ _ hi0 hi4 hlt; rewrite full64_set64d full32_init /=; smt().
wp; while (valid trace___hmac_sha256_outer /\ i_init /\ ms_init /\ 0 <= i <= 8
           /\ inner_init = full32 /\ outer_init = full32 /\ digest_init = full32
           /\ buf_init = full64).
+ by auto => /> &m _ _ _ hi0 hi8 hlt; rewrite full32_set32d full32_init /=; smt().
wp; ecall (_sha256___sha256_finalize_proof digest inner buf total ms digest_init inner_init buf_init).
auto => /> &m _ ho r h5 h6 h7 _.
split; 1: by rewrite (full32E _ h6) (full32E _ ho) (full32E _ h5) (full64E _ h7).
by move=> *; exact (full64_init 0 32).
qed.

lemma __hmac_sha256_finalize_proof _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init :
  __hmac_sha256_finalize_spec _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init.
proof.
rewrite /__hmac_sha256_finalize_spec; proc.
wp; ecall (_sha256___sha256_finalize_proof out inner buf total ms out_init inner_init buf_init).
wp; ecall (__hmac_sha256_outer_proof inner buf total outer ms inner_init buf_init outer_init).
auto => /> &m _ _ r _ h6 ->.
by rewrite umodc // W64.to_uint_small.
qed.

lemma __hmac_sha512_outer_proof _inner _buf _total _outer _ms _inner_init _buf_init _outer_init :
  __hmac_sha512_outer_spec _inner _buf _total _outer _ms _inner_init _buf_init _outer_init.
proof.
rewrite /__hmac_sha512_outer_spec; proc.
wp; while (valid trace___hmac_sha512_outer /\ i_init /\ ms_init /\ 0 <= i <= 8
           /\ inner_init = full64 /\ buf_init = full128 /\ digest_init = full64).
+ by auto => /> &m _ _ _ hi0 hi4 hlt; rewrite full128_set64d full64_init /=; smt().
wp; while (valid trace___hmac_sha512_outer /\ i_init /\ ms_init /\ 0 <= i <= 8
           /\ inner_init = full64 /\ outer_init = full64 /\ digest_init = full64
           /\ buf_init = full128).
+ by auto => /> &m _ _ _ hi0 hi8 hlt; rewrite full64_set64d full64_init /=; smt().
wp; ecall (_sha512___sha512_finalize_proof digest inner buf total ms digest_init inner_init buf_init).
auto => /> &m _ ho r h5 h6 h7 _.
split; 1: by rewrite (full64E _ h6) (full64E _ ho) (full64E _ h5) (full128E _ h7).
by move=> *; exact (full128_init 0 64).
qed.

lemma __hmac_sha512_finalize_proof _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init :
  __hmac_sha512_finalize_spec _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init.
proof.
rewrite /__hmac_sha512_finalize_spec; proc.
wp; ecall (_sha512___sha512_finalize_proof out inner buf total ms out_init inner_init buf_init).
wp; ecall (__hmac_sha512_outer_proof inner buf total outer ms inner_init buf_init outer_init).
auto => /> &m _ _ r _ h6 ->.
by rewrite umodc // W64.to_uint_small.
qed.

(* ------------------------------------------------------------------ *)
(* One-shot HMAC                                                      *)

lemma _hmac_sha256_mem_proof _out _key _keylen _msg _msglen _ms _out_init :
  _hmac_sha256_mem_spec _out _key _keylen _msg _msglen _ms _out_init.
proof.
rewrite /_hmac_sha256_mem_spec; proc.
wp; ecall (_sha256___sha256_finalize_proof out inner buf total ms out_init inner_init buf_init).
wp; ecall (__hmac_sha256_outer_proof inner buf total outer ms inner_init buf_init outer_init).
wp; ecall (_sha256_absorb_mem_proof inner buf total msg msglen ms inner_init buf_init).
wp; ecall (__hmac_sha256_init_proof inner outer k0 ms inner_init outer_init k0_init).
wp; ecall (_hmac_sha256_keyblock_mem_proof k0 key keylen ms k0_init).
auto => /> &m _ _ _ hm _ _ r _ _ r0 _ _ _; rewrite /protect_64 umodc // W64.to_uint_small //=.
split; 1: by split; [move=> j /# | move=> j h1 h2; apply hm].
move=> _ _ _ _ r1 _ _ _ _ r2 _ h6 -> _.
by rewrite umodc // W64.to_uint_small //; smt(w64_modulus).
qed.

lemma _hmac_sha512_mem_proof _out _key _keylen _msg _msglen _ms _out_init :
  _hmac_sha512_mem_spec _out _key _keylen _msg _msglen _ms _out_init.
proof.
rewrite /_hmac_sha512_mem_spec; proc.
wp; ecall (_sha512___sha512_finalize_proof out inner buf total ms out_init inner_init buf_init).
wp; ecall (__hmac_sha512_outer_proof inner buf total outer ms inner_init buf_init outer_init).
wp; ecall (_sha512_absorb_mem_proof inner buf total msg msglen ms inner_init buf_init).
wp; ecall (__hmac_sha512_init_proof inner outer k0 ms inner_init outer_init k0_init).
wp; ecall (_hmac_sha512_keyblock_mem_proof k0 key keylen ms k0_init).
auto => /> &m _ _ _ hm _ _ r _ _ r0 _ _ _; rewrite /protect_64 umodc // W64.to_uint_small //=.
split; 1: by split; [move=> j /# | move=> j h1 h2; apply hm].
move=> _ _ _ _ r1 _ _ _ _ r2 _ h6 -> _.
by rewrite umodc // W64.to_uint_small //; smt(w64_modulus).
qed.
