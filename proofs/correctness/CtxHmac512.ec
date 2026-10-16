(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * CtxHmac512.ec
 * =============
 *
 * Functional correctness of the incremental HMAC-SHA-512 of
 * src/hmac_context.jinc, over the 272-byte context, as CtxHmac256.ec
 * does for HMAC-SHA-256.
 *
 * Layout (bytes): [0, 208) a SHA-512 context (Ctx512.ec) of the inner
 * hash, which has absorbed K0 xor ipad and the text so far; [208, 272) the
 * chaining value of the outer hash after K0 xor opad, as eight u64.
 * hctx512 tag K text c is the representation: the inner context is
 * ctx512 tag H0_512 ((K0 xor ipad) ++ text), and the outer words are
 * compress H0_512 (K0 xor opad). Updates go through the SHA-512 context
 * update on the first 208 bytes (Ctx512.ec).
 *
 * Theorems (total correctness):
 *     hmac_sha512_ctx_init_total   a context of the key and the empty text;
 *     hmac_sha512_ctx_final_total  status 0, HMAC-SHA-512 (K, text), and an
 *                                  all-zero context when the tag matches;
 *                                  status 1 and nothing changed otherwise.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh.
import SLH64.
require import BArray16 BArray64 BArray128 BArray208 BArray272.
require import SBArray208_16 SBArray208_64 SBArray208_128 SBArray272_16 SBArray272_208.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 FIPS198_HMAC StreamSpec HMACSpec SafetyLib State Fill.
require import SHA256_Stream SHA512_Stream HMAC_SHA512 Ctx256 Ctx512.
require JWordList K512.
import SHA512.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op outer272 (c : BArray272.t) : W64.t list =
  map (fun i => BArray272.get64d c (208 + 8 * i)) (iota_ 0 8).

op hctx512 (tag : W64.t) (k text : bytes) (c : BArray272.t) =
     ctx512 tag H0_512 (ib512 k ++ text) (SBArray272_208.get_sub8 c 0)
  /\ outer272 c = compress H0_512 (map be64 (chunk 8 (ob512 k))).

lemma hctx512_copy tag k text (c c' : BArray272.t) :
  BArray272.to_list c' = BArray272.to_list c => hctx512 tag k text c => hctx512 tag k text c'.
proof.
move=> heq; have -> // : c' = c.
by apply BArray272.tP => i hi; rewrite -!BArray272.get_to_list heq.
qed.

(* The first 208 bytes as a SHA-512 context. *)
lemma sub208_bytes (c : BArray272.t) (a : BArray208.t) :
  (forall k, 0 <= k < 208 => BArray272.get8 c k = BArray208.get8 a k) =>
  SBArray272_208.get_sub8 c 0 = a.
proof.
move=> hb; apply BArray208.tP => k hk.
by rewrite SBArray272_208.get8_get_sub hk /= hb.
qed.

lemma head272 (c : BArray272.t) :
  BArray16.get64d (SBArray272_16.get_sub8 c 0) 0
  = BArray208.get64d (SBArray272_208.get_sub8 c 0) 0 /\
  BArray16.get64d (SBArray272_16.get_sub8 c 0) 8
  = BArray208.get64d (SBArray272_208.get_sub8 c 0) 8.
proof. by rewrite !SBArray272_16.get64d_get_sub // !SBArray272_208.get64d_get_sub. qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

op tag512h : W64.t = W64.of_int (1100357333870 + (8 `<<` 32)).

lemma hmac_sha512_ctx_init_correct (pk lk : W64.t) :
  hoare [M.__hmac_sha512_ctx_init :
           key = pk /\ keylen = lk /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 ==>
           hctx512 tag512h (memread Glob.mem (to_uint pk) (to_uint lk)) [] res.`1].
proof.
proc.
wp; while (0 <= i <= 8 /\
           (forall k, 0 <= k < 208 => BArray272.get8 ctx k = BArray208.get8 aux k) /\
           (forall j, 0 <= j < i => BArray272.get64d ctx (208 + 8 * j) = BArray64.get64 outer j) /\
           ctx512 tag512h H0_512 (ib512 (memread Glob.mem (to_uint pk) (to_uint lk))) aux /\
           h512 outer = compress H0_512 (map be64 (chunk 8 (ob512 (memread Glob.mem (to_uint pk) (to_uint lk)))))).
+ auto => /> &hr hi0 hi8 hb hj * ; split; first smt().
  split.
  + by move=> k hk0 hk1; rewrite BArray272.get8_set64dE ifF 1:/#; apply hb.
  move=> j hj0 hj1; case: (j = i{hr}) => [->|hne].
  + by rewrite BArray272.get_set64dE_eq //; smt().
  by rewrite BArray272.get_set64dE_neq 1:/#; apply hj => /#.
wp; ecall (ctx_init512_correct inner tag total).
wp; ecall (sha2_tag_correct 8).
wp; ecall (hmac_sha512_init_correct k0).
ecall (hmac_sha512_keyblock_correct pk lk).
auto => /> &hr hpl hl k1 hk1 [i1 o1 ms1] /= hi1 ho1 a ha0 ha8 ha4.
pose K := memread Glob.mem{hr} (to_uint pk) (to_uint lk).
have hsi := size_ib512 K.
have hpi : parse (ib512 K) = [map be64 (chunk 8 (ib512 K))] by rewrite /parse chunk_block.
have hti : tail 128 (ib512 K) = [] by apply tail512_nil; rewrite hsi.
split.
+ do !split.
  + move=> k hq0 hq1; rewrite /protect_ptr SBArray272_208.get8_set_sub ifT 1:/#.
    by congr; ring.
  + smt().
  + by rewrite hsi.
  + by rewrite ha8 hsi.
  + by rewrite ha4 hpi /= hi1 /ib512 -hk1.
  + by rewrite hti; exact pend512_nil.
  by rewrite ho1 /ob512 -hk1.
move=> c2 i2 hn hi0 hi8 hb hj htag hs ht hh hp ho.
rewrite cats0; have -> : SBArray272_208.get_sub8 c2 0 = a by apply sub208_bytes.
do !split => //.
rewrite -ho /outer272 /h512; apply eq_in_map => j /mem_iota hj' /=.
by rewrite hj //; smt().
qed.

lemma hmac_sha512_ctx_init_ll : islossless M.__hmac_sha512_ctx_init.
proof.
proc; while (true) (8 - i); first by auto => /#.
wp; call ctx_init512_ll; wp; call sha2_tag_ll; wp; call hmac_sha512_init_ll.
by call hmac_sha512_keyblock_ll; auto => /#.
qed.

lemma hmac_sha512_ctx_init_total (pk lk : W64.t) :
  phoare [M.__hmac_sha512_ctx_init :
           key = pk /\ keylen = lk /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 ==>
           hctx512 tag512h (memread Glob.mem (to_uint pk) (to_uint lk)) [] res.`1] = 1%r.
proof. by conseq hmac_sha512_ctx_init_ll (hmac_sha512_ctx_init_correct pk lk). qed.

(* ------------------------------------------------------------------ *)
(* Reading the stream state back                                      *)

lemma ctx_load512_correct (c : BArray208.t) :
  hoare [M.__sha512_ctx_load :
           ctx = c ==> res.`1 = SBArray208_64.get_sub64 c 2 /\ res.`2 = SBArray208_128.get_sub8 c 80].
proof.
proc.
while (0 <= i <= 16 /\ ctx = c /\
       (forall b, 0 <= b < 64 => BArray64.get8 h b = BArray208.get8 c (16 + b)) /\
       (forall b, 0 <= b < 8 * i => BArray128.get8 buf b = BArray208.get8 c (80 + b))).
+ auto => /> &hr hi0 hi8 hh hb hlt; split; first smt().
  move=> b hb0 hb1; rewrite BArray128.get8_set64dE.
  case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
  + by rewrite ifT 1:/# BArray208.get64d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hb; smt().
wp; while (0 <= i <= 8 /\ ctx = c /\
           (forall b, 0 <= b < 8 * i => BArray64.get8 h b = BArray208.get8 c (16 + b))).
+ auto => /> &hr hi0 hi8 hh hlt; split; first smt().
  move=> b hb0 hb1; rewrite BArray64.get8_set64dE.
  case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
  + by rewrite ifT 1:/# BArray208.get64d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hh; smt().
auto => /> &hr; split; first smt().
move=> h1 i1 hn hi0 hi8 hh; split; first by split; [move=> b hb0 hb1; apply hh; smt() | smt()].
move=> b1 i2 hn2 hi20 hi28 hh2 hb; split.
+ by apply BArray64.tP => k hk; rewrite SBArray208_64.get8_get_sub hk /= hh2.
by apply BArray128.tP => k hk; rewrite SBArray208_128.get8_get_sub hk /= hb; smt().
qed.

lemma ctx_load512_ll : islossless M.__sha512_ctx_load.
proof. by proc; while (true) (16 - i); [auto => /# | wp; while (true) (8 - i); auto => /#]. qed.

(* ------------------------------------------------------------------ *)
(* The tag                                                            *)

lemma hmac_sha512_ctx_final_correct (c0 : BArray272.t) (o0 : BArray64.t) (k text : bytes) :
  hoare [M.__hmac_sha512_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> tag512h =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hctx512 tag512h k text c0 =>
              res.`3 = W64.zero /\ BArray64.to_list res.`2 = hmac_sha512 k text /\
              forall i, 0 <= i < 272 => BArray272.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 6 : (ctx = c0 /\ out = o0 /\ expect_0 = tag512h /\
         tag = BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 /\
         total = BArray208.get64d (SBArray272_208.get_sub8 c0 0) 8).
+ ecall (sha2_tag_correct 8); ecall (ctx_open_correct (SBArray272_16.get_sub8 ctx 0)).
  auto => /> r -> ->; exact (head272 c0).
sp; if.
+ wp; while (0 <= i <= 34 /\ inc = 34 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray272.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi18 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray272.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  case: (hctx512 tag512h k text c0).
  + wp; while (0 <= i <= 8 /\ BArray64.to_list mac = hmac_sha512 k text /\
               (forall b, 0 <= b < 8 * i => BArray64.get8 out b = BArray64.get8 mac b)).
    + auto => /> &hr hi0 hi4 hm hb hlt; split; first smt().
      move=> b hb0 hb1; rewrite BArray64.get8_set64dE.
      case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
      + by rewrite ifT 1:/# BArray64.get64d_byte 1:/#; congr; ring.
      by rewrite ifF 1:/#; apply hb; smt().
    wp; ecall (hmac_sha512_finalize_correct (ib512 k) (ob512 k) text (size_ob512 k)).
    wp; while (0 <= i <= 8 /\ ctx = c0 /\
               (forall j, 0 <= j < i => BArray64.get64 outer j = BArray272.get64d c0 (208 + 8 * j))).
    + auto => /> &hr hi0 hi8 hj hlt; split; first smt().
      move=> j hj0 hj1; rewrite BArray64.get_set64E 1,2:/#.
      by case: (i{hr} = j) => [<-|ne] //; apply hj => /#.
    wp; ecall (ctx_load512_correct (SBArray272_208.get_sub8 ctx 0)).
    auto => /> &hr htag hok hrep ht hh hp ho [i1 b1] /= -> ->.
    split; first smt().
    move=> i2 o2 hn hi0 hi8 hj.
    have hout : h512 o2 = compress H0_512 (map be64 (chunk 8 (ob512 k))).
    + rewrite -ho /outer272 /h512; apply eq_in_map => j /mem_iota hj' /=.
      by rewrite hj //; smt().
    split; first by do !split.
    move=> _ _ _ _ [m1 i3 b3 ms3] /= hm; split; first smt().
    move=> i4 o4 hn4 hi40 hi44 hm' hb; split; first smt().
    move=> c5 i5 hn5 hi50 hi58 hz; split.
    + have -> : o4 = m1 by apply BArray64.tP => b hb'; apply hb; smt().
      exact hm'.
    by move=> b hb0 hb1; apply hz; smt().
  wp; while (true); first by auto.
  wp; call (: true) => //; wp; while (true); first by auto.
  wp; call (: true) => //; auto => /> &hr; smt().
by auto => /> &hr htag hne; rewrite /hctx512 /ctx512; smt().
qed.

lemma hmac_sha512_ctx_final_ll : islossless M.__hmac_sha512_ctx_final.
proof.
proc.
seq 8 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
wp; while (true) (8 - i); first by auto => /#.
wp; call hmac_sha512_finalize_ll; wp; while (true) (8 - i); first by auto => /#.
by wp; call ctx_load512_ll; auto => /#.
qed.

lemma hmac_sha512_ctx_final_total (c0 : BArray272.t) (o0 : BArray64.t) (k text : bytes) :
  phoare [M.__hmac_sha512_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray208.get64d (SBArray272_208.get_sub8 c0 0) 0 <> tag512h =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hctx512 tag512h k text c0 =>
              res.`3 = W64.zero /\ BArray64.to_list res.`2 = hmac_sha512 k text /\
              forall i, 0 <= i < 272 => BArray272.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq hmac_sha512_ctx_final_ll (hmac_sha512_ctx_final_correct c0 o0 k text). qed.
