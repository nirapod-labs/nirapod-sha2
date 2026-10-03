(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyExports.ec
 * ================
 *
 * Safety of the exported entry points of src/nirapod_sha2.jinc: each
 * export sets up the misspeculation flag and calls one front end, so
 * every proof is the contract of that front end.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK256 SafetyK512 SafetyKX8 SafetyKX4.
require import SafetySha256 SafetySha512 SafetyHmac SafetyCtx SafetyMulti SafetyCtxX.
require import BArray16 BArray28 BArray32 BArray48 BArray64 BArray112 BArray128 BArray144.
require import BArray208 BArray256 BArray272 BArray512 BArray784 NirapodSha2Safety.
require import SBArray144_112 SBArray272_208.

lemma sha224_proof _out _in _inlen _out_init :
  sha224_spec _out _in _inlen _out_init.
proof.
rewrite /sha224_spec; proc.
wp; ecall (_sha224_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha224_init_proof _ctx _ctx_init :
  sha224_init_spec _ctx _ctx_init.
proof.
rewrite /sha224_init_spec; proc.
wp; ecall (__sha256_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 1).
wp; ecall (__sha224_init_proof h h_init).
by auto => />.
qed.

lemma sha224_update_proof _ctx _in _inlen _ctx_init :
  sha224_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha224_update_spec; proc.
wp; ecall (_sha256_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 1).
by auto => />.
qed.

lemma sha224_final_proof _ctx _out _ctx_init _out_init :
  sha224_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha224_final_spec; proc.
wp; ecall (_sha224_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 1).
by auto => />.
qed.

lemma sha256_proof _out _in _inlen _out_init :
  sha256_spec _out _in _inlen _out_init.
proof.
rewrite /sha256_spec; proc.
wp; ecall (_sha256_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha256_init_proof _ctx _ctx_init :
  sha256_init_spec _ctx _ctx_init.
proof.
rewrite /sha256_init_spec; proc.
wp; ecall (__sha256_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 2).
wp; ecall (__sha256_init_proof h h_init).
by auto => />.
qed.

lemma sha256_update_proof _ctx _in _inlen _ctx_init :
  sha256_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha256_update_spec; proc.
wp; ecall (_sha256_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 2).
by auto => />.
qed.

lemma sha256_final_proof _ctx _out _ctx_init _out_init :
  sha256_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha256_final_spec; proc.
wp; ecall (_sha256_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 2).
by auto => />.
qed.

lemma sha384_proof _out _in _inlen _out_init :
  sha384_spec _out _in _inlen _out_init.
proof.
rewrite /sha384_spec; proc.
wp; ecall (_sha384_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha384_init_proof _ctx _ctx_init :
  sha384_init_spec _ctx _ctx_init.
proof.
rewrite /sha384_init_spec; proc.
wp; ecall (__sha512_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 3).
wp; ecall (__sha384_init_proof h h_init).
by auto => />.
qed.

lemma sha384_update_proof _ctx _in _inlen _ctx_init :
  sha384_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha384_update_spec; proc.
wp; ecall (_sha512_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 3).
by auto => />.
qed.

lemma sha384_final_proof _ctx _out _ctx_init _out_init :
  sha384_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha384_final_spec; proc.
wp; ecall (_sha384_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 3).
by auto => />.
qed.

lemma sha512_proof _out _in _inlen _out_init :
  sha512_spec _out _in _inlen _out_init.
proof.
rewrite /sha512_spec; proc.
wp; ecall (_sha512_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha512_init_proof _ctx _ctx_init :
  sha512_init_spec _ctx _ctx_init.
proof.
rewrite /sha512_init_spec; proc.
wp; ecall (__sha512_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 4).
wp; ecall (__sha512_init_proof h h_init).
by auto => />.
qed.

lemma sha512_update_proof _ctx _in _inlen _ctx_init :
  sha512_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha512_update_spec; proc.
wp; ecall (_sha512_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 4).
by auto => />.
qed.

lemma sha512_final_proof _ctx _out _ctx_init _out_init :
  sha512_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha512_final_spec; proc.
wp; ecall (_sha512_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 4).
by auto => />.
qed.

lemma sha512_224_proof _out _in _inlen _out_init :
  sha512_224_spec _out _in _inlen _out_init.
proof.
rewrite /sha512_224_spec; proc.
wp; ecall (_sha512_224_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha512_224_init_proof _ctx _ctx_init :
  sha512_224_init_spec _ctx _ctx_init.
proof.
rewrite /sha512_224_init_spec; proc.
wp; ecall (__sha512_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 5).
wp; ecall (__sha512_224_init_proof h h_init).
by auto => />.
qed.

lemma sha512_224_update_proof _ctx _in _inlen _ctx_init :
  sha512_224_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha512_224_update_spec; proc.
wp; ecall (_sha512_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 5).
by auto => />.
qed.

lemma sha512_224_final_proof _ctx _out _ctx_init _out_init :
  sha512_224_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha512_224_final_spec; proc.
wp; ecall (_sha512_224_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 5).
by auto => />.
qed.

lemma sha512_256_proof _out _in _inlen _out_init :
  sha512_256_spec _out _in _inlen _out_init.
proof.
rewrite /sha512_256_spec; proc.
wp; ecall (_sha512_256_mem_proof out in_0 inlen ms out_init).
by auto => />.
qed.

lemma sha512_256_init_proof _ctx _ctx_init :
  sha512_256_init_spec _ctx _ctx_init.
proof.
rewrite /sha512_256_init_spec; proc.
wp; ecall (__sha512_ctx_init_proof ctx h tag total ctx_init h_init).
wp; ecall (__sha2_tag_proof 6).
wp; ecall (__sha512_256_init_proof h h_init).
by auto => />.
qed.

lemma sha512_256_update_proof _ctx _in _inlen _ctx_init :
  sha512_256_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /sha512_256_update_spec; proc.
wp; ecall (_sha512_ctx_update_proof ctx in_0 inlen expect_0 ms ctx_init).
wp; ecall (__sha2_tag_proof 6).
by auto => />.
qed.

lemma sha512_256_final_proof _ctx _out _ctx_init _out_init :
  sha512_256_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha512_256_final_spec; proc.
wp; ecall (_sha512_256_ctx___sha2_ctx_final_proof ctx out expect_0 ms ctx_init out_init).
wp; ecall (__sha2_tag_proof 6).
by auto => />.
qed.

lemma hmac_sha256_proof _out _key _keylen _msg _msglen _out_init :
  hmac_sha256_spec _out _key _keylen _msg _msglen _out_init.
proof.
rewrite /hmac_sha256_spec; proc.
wp; ecall (_hmac_sha256_mem_proof out key keylen msg msglen ms out_init).
by auto => />.
qed.

lemma hmac_sha256_init_proof _ctx _key _keylen _ctx_init :
  hmac_sha256_init_spec _ctx _key _keylen _ctx_init.
proof.
rewrite /hmac_sha256_init_spec; proc.
wp; ecall (__hmac_sha256_ctx_init_proof ctx key keylen ms ctx_init).
by auto => />.
qed.

lemma hmac_sha256_update_proof _ctx _in _inlen _ctx_init :
  hmac_sha256_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /hmac_sha256_update_spec; proc.
wp; ecall (_sha256_ctx_update_proof (SBArray144_112.get_sub8 ctx 0) in_0 inlen expect_0 ms (SBArray144_112.get_sub ctx_init (1 * 0))).
wp; ecall (__sha2_tag_proof 7).
auto => /> &m hc *; rewrite (full144E _ hc); split.
+ by apply (sub144_112_get _ 0 0 112) => //; exact full144_init.
by move=> _ r h4 _; rewrite set_sub144_112_full //; exact full144_init.
qed.

lemma hmac_sha256_final_proof _ctx _out _ctx_init _out_init :
  hmac_sha256_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /hmac_sha256_final_spec; proc.
wp; ecall (__hmac_sha256_ctx_final_proof ctx out ms ctx_init out_init).
by auto => />.
qed.

lemma hmac_sha512_proof _out _key _keylen _msg _msglen _out_init :
  hmac_sha512_spec _out _key _keylen _msg _msglen _out_init.
proof.
rewrite /hmac_sha512_spec; proc.
wp; ecall (_hmac_sha512_mem_proof out key keylen msg msglen ms out_init).
by auto => />.
qed.

lemma hmac_sha512_init_proof _ctx _key _keylen _ctx_init :
  hmac_sha512_init_spec _ctx _key _keylen _ctx_init.
proof.
rewrite /hmac_sha512_init_spec; proc.
wp; ecall (__hmac_sha512_ctx_init_proof ctx key keylen ms ctx_init).
by auto => />.
qed.

lemma hmac_sha512_update_proof _ctx _in _inlen _ctx_init :
  hmac_sha512_update_spec _ctx _in _inlen _ctx_init.
proof.
rewrite /hmac_sha512_update_spec; proc.
wp; ecall (_sha512_ctx_update_proof (SBArray272_208.get_sub8 ctx 0) in_0 inlen expect_0 ms (SBArray272_208.get_sub ctx_init (1 * 0))).
wp; ecall (__sha2_tag_proof 8).
auto => /> &m hc *; rewrite (full272E _ hc); split.
+ by apply (sub272_208_get _ 0 0 208) => //; exact full272_init.
by move=> _ r h4 _; rewrite set_sub272_208_full //; exact full272_init.
qed.

lemma hmac_sha512_final_proof _ctx _out _ctx_init _out_init :
  hmac_sha512_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /hmac_sha512_final_spec; proc.
wp; ecall (__hmac_sha512_ctx_final_proof ctx out ms ctx_init out_init).
by auto => />.
qed.

lemma sha256_x8_proof _out _in _len _out_init _in_init :
  sha256_x8_spec _out _in _len _out_init _in_init.
proof.
rewrite /sha256_x8_spec; proc.
wp; ecall (_sha256_x8_lanes_proof out in_0 len ms out_init in_init).
by auto => />.
qed.

lemma sha256_x8_init_proof _ctx _ctx_init :
  sha256_x8_init_spec _ctx _ctx_init.
proof.
rewrite /sha256_x8_init_spec; proc.
wp; ecall (__sha256_x8_ctx_init_proof ctx ctx_init).
by auto => />.
qed.

lemma sha256_x8_init_from_proof _ctx _src _ctx_init _src_init :
  sha256_x8_init_from_spec _ctx _src _ctx_init _src_init.
proof.
rewrite /sha256_x8_init_from_spec; proc.
wp; ecall (_sha256_x8_ctx_from_proof ctx src ms ctx_init src_init).
by auto => />.
qed.

lemma sha256_x8_update_proof _ctx _in _inlen _ctx_init _in_init :
  sha256_x8_update_spec _ctx _in _inlen _ctx_init _in_init.
proof.
rewrite /sha256_x8_update_spec; proc.
wp; ecall (_sha256_x8_ctx_update_proof ctx in_0 inlen ms ctx_init in_init).
by auto => />.
qed.

lemma sha256_x8_final_proof _ctx _out _ctx_init _out_init :
  sha256_x8_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha256_x8_final_spec; proc.
wp; ecall (_sha256_x8_ctx_final_proof ctx out ms ctx_init out_init).
by auto => />.
qed.

lemma sha512_x4_proof _out _in _len _out_init _in_init :
  sha512_x4_spec _out _in _len _out_init _in_init.
proof.
rewrite /sha512_x4_spec; proc.
wp; ecall (_sha512_x4_lanes_proof out in_0 len ms out_init in_init).
by auto => />.
qed.

lemma sha512_x4_init_proof _ctx _ctx_init :
  sha512_x4_init_spec _ctx _ctx_init.
proof.
rewrite /sha512_x4_init_spec; proc.
wp; ecall (__sha512_x4_ctx_init_proof ctx ctx_init).
by auto => />.
qed.

lemma sha512_x4_init_from_proof _ctx _src _ctx_init _src_init :
  sha512_x4_init_from_spec _ctx _src _ctx_init _src_init.
proof.
rewrite /sha512_x4_init_from_spec; proc.
wp; ecall (_sha512_x4_ctx_from_proof ctx src ms ctx_init src_init).
by auto => />.
qed.

lemma sha512_x4_update_proof _ctx _in _inlen _ctx_init _in_init :
  sha512_x4_update_spec _ctx _in _inlen _ctx_init _in_init.
proof.
rewrite /sha512_x4_update_spec; proc.
wp; ecall (_sha512_x4_ctx_update_proof ctx in_0 inlen ms ctx_init in_init).
by auto => />.
qed.

lemma sha512_x4_final_proof _ctx _out _ctx_init _out_init :
  sha512_x4_final_spec _ctx _out _ctx_init _out_init.
proof.
rewrite /sha512_x4_final_spec; proc.
wp; ecall (_sha512_x4_ctx_final_proof ctx out ms ctx_init out_init).
by auto => />.
qed.
