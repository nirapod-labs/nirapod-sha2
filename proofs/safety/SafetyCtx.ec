(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyCtx.ec
 * ============
 *
 * Safety of the incremental contexts of src/ctx.jinc and its sized
 * instances: the context header, the length room, loading and storing
 * the hash state, update and final for the six hashes, and the HMAC
 * contexts. The hashes enter through SafetySha256, SafetySha512 and
 * SafetyHmac.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK256 SafetyK512.
require import SafetySha256 SafetySha512 SafetyHmac.
require import BArray16 BArray28 BArray32 BArray48 BArray64 BArray112 BArray128.
require import BArray208 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Context header and length room                                     *)

lemma __sha2_tag_proof _f : __sha2_tag_spec _f.
proof. by rewrite /__sha2_tag_spec; proc; auto. qed.

lemma __sha2_ctx_open_proof _head _ms _head_init :
  __sha2_ctx_open_spec _head _ms _head_init.
proof.
rewrite /__sha2_ctx_open_spec; proc; auto => /> hh.
by rewrite (full16E _ hh) !full16_init.
qed.

lemma __sha2_room_proof _total : __sha2_room_spec _total.
proof. by rewrite /__sha2_room_spec; proc; auto. qed.

(* ------------------------------------------------------------------ *)
(* Hash state                                                         *)

lemma __sha256_ctx_load_proof _h _buf _ctx _h_init _buf_init _ctx_init :
  __sha256_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init.
proof.
rewrite /__sha256_ctx_load_spec; proc.
while (valid trace___sha256_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full112
       /\ BArray32.is_init h_init 0 32 /\ BArray64.is_init buf_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hb hlt.
  have hm := mask64_set64 buf_init{m} i{m} hb _ _; 1,2: smt().
  by rewrite full112_init hm /=; smt().
wp; while (valid trace___sha256_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full112
           /\ BArray32.is_init h_init 0 (4 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask32_set32 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full112_init hm /=; smt().
auto => /> hc; split; 1: by split; [exact full112E | move=> j /#].
move=> h0 i0 tr0 hlt _ _ hi8 _ hh; split.
+ by split; [have <- : 4 * i0 = 32 by smt() | move=> j /#].
by move=> b0 i1 tr1 hlt1 _ _ hi1 _ hb; have <- : 8 * i1 = 64 by smt().
qed.

lemma __sha512_ctx_load_proof _h _buf _ctx _h_init _buf_init _ctx_init :
  __sha512_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init.
proof.
rewrite /__sha512_ctx_load_spec; proc.
while (valid trace___sha512_ctx_load /\ i_init /\ 0 <= i <= 16 /\ ctx_init = full208
       /\ BArray64.is_init h_init 0 64 /\ BArray128.is_init buf_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hb hlt.
  have hm := mask128_set64 buf_init{m} i{m} hb _ _; 1,2: smt().
  by rewrite full208_init hm /=; smt().
wp; while (valid trace___sha512_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full208
           /\ BArray64.is_init h_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask64_set64 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full208_init hm /=; smt().
auto => /> hc; split; 1: by split; [exact full208E | move=> j /#].
move=> h0 i0 tr0 hlt _ _ hi8 _ hh; split.
+ by split; [have <- : 8 * i0 = 64 by smt() | move=> j /#].
by move=> b0 i1 tr1 hlt1 _ _ hi1 _ hb; have <- : 8 * i1 = 128 by smt().
qed.
