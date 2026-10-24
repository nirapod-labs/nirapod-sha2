(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Exports.ec
 * ==========
 *
 * The one step of the exports of src/nirapod_sha2.jinc that is more than
 * a call to a proved layer: hmac_sha256_update and hmac_sha512_update
 * absorb into the inner SHA-256 (SHA-512) context that fills the first
 * 112 (208) bytes of an HMAC context, through a sub-array view, and must
 * leave the outer chaining value after it untouched. Every other export
 * is one call after #init_msf and is stated in Theorems.ec directly.
 *
 * Theorems (partial correctness; Theorems.ec adds termination):
 *     hmac_sha256_update_correct, hmac_sha512_update_correct
 *         status 0 and the context of text ++ input when the tag matches
 *         and the inner message stays below 2^61 bytes; status 1 (wrong
 *         tag) or 2 (too long) and the context unchanged otherwise.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory Jslh.
import SLH64.
require import BArray16 BArray32 BArray64 BArray112 BArray128 BArray144 BArray208 BArray272.
require import SBArray144_112 SBArray272_208.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 FIPS198_HMAC StreamSpec State.
require import SHA256_Stream SHA512_Stream HMAC_SHA256 HMAC_SHA512 Ctx256 Ctx512 CtxHmac256 CtxHmac512.
require JWordList.

(* ------------------------------------------------------------------ *)
(* The inner context as a sub-array                                   *)

lemma sub144_set (c : BArray144.t) (a : BArray112.t) :
  SBArray144_112.get_sub8 (SBArray144_112.set_sub8 c 0 a) 0 = a.
proof.
apply BArray112.tP => i hi.
by rewrite SBArray144_112.get8_get_sub hi /= SBArray144_112.get8_set_sub ifT 1:/#.
qed.

lemma sub144_id (c : BArray144.t) :
  SBArray144_112.set_sub8 c 0 (SBArray144_112.get_sub8 c 0) = c.
proof.
apply BArray144.tP => i hi; rewrite SBArray144_112.get8_set_sub.
case: (0 <= i < 112) => h; last by rewrite ifF 1:/#.
by rewrite ifT 1:/# SBArray144_112.get8_get_sub ifT 1:/#.
qed.

lemma outer144_set (c : BArray144.t) (a : BArray112.t) :
  outer144 (SBArray144_112.set_sub8 c 0 a) = outer144 c.
proof.
rewrite /outer144; apply eq_in_map => i /mem_iota hi /=.
apply W4u8.wordP => j hj.
by rewrite !BArray144.get32d_byte // SBArray144_112.get8_set_sub ifF 1:/#.
qed.

lemma sub272_set (c : BArray272.t) (a : BArray208.t) :
  SBArray272_208.get_sub8 (SBArray272_208.set_sub8 c 0 a) 0 = a.
proof.
apply BArray208.tP => i hi.
by rewrite SBArray272_208.get8_get_sub hi /= SBArray272_208.get8_set_sub ifT 1:/#.
qed.

lemma sub272_id (c : BArray272.t) :
  SBArray272_208.set_sub8 c 0 (SBArray272_208.get_sub8 c 0) = c.
proof.
apply BArray272.tP => i hi; rewrite SBArray272_208.get8_set_sub.
case: (0 <= i < 208) => h; last by rewrite ifF 1:/#.
by rewrite ifT 1:/# SBArray272_208.get8_get_sub ifT 1:/#.
qed.

lemma outer272_set (c : BArray272.t) (a : BArray208.t) :
  outer272 (SBArray272_208.set_sub8 c 0 a) = outer272 c.
proof.
rewrite /outer272; apply eq_in_map => i /mem_iota hi /=.
apply W8u8.wordP => j hj.
by rewrite !BArray272.get64d_byte // SBArray272_208.get8_set_sub ifF 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* Absorbing into an HMAC context                                     *)

lemma hmac_sha256_update_correct (c0 : BArray144.t) (k text : bytes) (p0 l0 : W64.t) :
  hoare [M.hmac_sha256_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> tag256h => res.`2 = W64.one) /\
           (hctx256 tag256h k text c0 =>
              if size text + to_uint l0 < 2^61 - 64
              then res.`2 = W64.zero /\
                   hctx256 tag256h k (text ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc; wp.
ecall (sha256_ctx_update_correct (SBArray144_112.get_sub8 c0 0) tag256h SHA256.H0_256 (ib256 k ++ text) p0 l0).
ecall (sha2_tag_correct 7); auto => &hr [-> [-> [-> hpl]]] t -> /=.
split; first by rewrite /tag256h.
move=> [a st ms1] /= [h1 [h2 h3]]; split.
+ by move=> hst; rewrite (h1 hst) sub144_id.
split; first exact h2.
move=> [hc ho]; have := h3 hc; rewrite size_cat size_ib256.
case: (size text + to_uint l0 < 2305843009213693888) => hlt.
+ rewrite (ifT (64 + size text + to_uint l0 < 2^61)) 1:/#; move=> [-> ha]; split => //; split.
  + by rewrite sub144_set catA.
  by rewrite outer144_set.
by rewrite ifF 1:/#.
qed.

lemma hmac_sha512_update_correct (c0 : BArray272.t) (k text : bytes) (p0 l0 : W64.t) :
  hoare [M.hmac_sha512_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> tag512h => res.`2 = W64.one) /\
           (hctx512 tag512h k text c0 =>
              if size text + to_uint l0 < 2^61 - 128
              then res.`2 = W64.zero /\
                   hctx512 tag512h k (text ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc; wp.
ecall (sha512_ctx_update_correct (SBArray272_208.get_sub8 c0 0) tag512h SHA512.H0_512 (ib512 k ++ text) p0 l0).
ecall (sha2_tag_correct 8); auto => &hr [-> [-> [-> hpl]]] t -> /=.
split; first by rewrite /tag512h.
move=> [a st ms1] /= [h1 [h2 h3]]; split.
+ by move=> hst; rewrite (h1 hst) sub272_id.
split; first exact h2.
move=> [hc ho]; have := h3 hc; rewrite size_cat size_ib512.
case: (size text + to_uint l0 < 2305843009213693824) => hlt.
+ rewrite (ifT (128 + size text + to_uint l0 < 2^61)) 1:/#; move=> [-> ha]; split => //; split.
  + by rewrite sub272_set catA.
  by rewrite outer272_set.
by rewrite ifF 1:/#.
qed.
