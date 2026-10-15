(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * CtxHmac256.ec
 * =============
 *
 * Functional correctness of the incremental HMAC-SHA-256 of
 * src/hmac_context.jinc, over the 144-byte context.
 *
 * Layout (bytes): [0, 112) a SHA-256 context (Ctx256.ec) of the inner
 * hash, which has absorbed K0 xor ipad and the text so far; [112, 144) the
 * chaining value of the outer hash after K0 xor opad, as eight u32.
 * hctx256 tag K text c is the representation: the inner context is
 * ctx256 tag H0_256 ((K0 xor ipad) ++ text), and the outer words are
 * compress H0_256 (K0 xor opad). Updates go through the SHA-256 context
 * update on the first 112 bytes (Ctx256.ec).
 *
 * Theorems (total correctness):
 *     hmac_sha256_ctx_init_total   a context of the key and the empty text;
 *     hmac_sha256_ctx_final_total  status 0, HMAC-SHA-256 (K, text), and an
 *                                  all-zero context when the tag matches;
 *                                  status 1 and nothing changed otherwise.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh.
import SLH64.
require import BArray16 BArray32 BArray64 BArray112 BArray144.
require import SBArray112_16 SBArray112_32 SBArray112_64 SBArray144_16 SBArray144_112.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 FIPS198_HMAC StreamSpec HMACSpec SafetyLib State Fill.
require import SHA256_Stream HMAC_SHA256 Ctx256.
require JWordList K256.
import SHA256.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op outer144 (c : BArray144.t) : W32.t list =
  map (fun i => BArray144.get32d c (112 + 4 * i)) (iota_ 0 8).

op hctx256 (tag : W64.t) (k text : bytes) (c : BArray144.t) =
     ctx256 tag H0_256 (ib256 k ++ text) (SBArray144_112.get_sub8 c 0)
  /\ outer144 c = compress H0_256 (map be32 (chunk 4 (ob256 k))).

lemma hctx256_copy tag k text (c c' : BArray144.t) :
  BArray144.to_list c' = BArray144.to_list c => hctx256 tag k text c => hctx256 tag k text c'.
proof.
move=> heq; have -> // : c' = c.
by apply BArray144.tP => i hi; rewrite -!BArray144.get_to_list heq.
qed.

(* The first 112 bytes as a SHA-256 context. *)
lemma sub112_bytes (c : BArray144.t) (a : BArray112.t) :
  (forall k, 0 <= k < 112 => BArray144.get8 c k = BArray112.get8 a k) =>
  SBArray144_112.get_sub8 c 0 = a.
proof.
move=> hb; apply BArray112.tP => k hk.
by rewrite SBArray144_112.get8_get_sub hk /= hb.
qed.

lemma head144 (c : BArray144.t) :
  BArray16.get64d (SBArray144_16.get_sub8 c 0) 0
  = BArray112.get64d (SBArray144_112.get_sub8 c 0) 0 /\
  BArray16.get64d (SBArray144_16.get_sub8 c 0) 8
  = BArray112.get64d (SBArray144_112.get_sub8 c 0) 8.
proof. by rewrite !SBArray144_16.get64d_get_sub // !SBArray144_112.get64d_get_sub. qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

op tag256h : W64.t = W64.of_int (1100357333870 + (7 `<<` 32)).

lemma hmac_sha256_ctx_init_correct (pk lk : W64.t) :
  hoare [M.__hmac_sha256_ctx_init :
           key = pk /\ keylen = lk /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 ==>
           hctx256 tag256h (memread Glob.mem (to_uint pk) (to_uint lk)) [] res.`1].
proof.
proc.
wp; while (0 <= i <= 8 /\
           (forall k, 0 <= k < 112 => BArray144.get8 ctx k = BArray112.get8 aux k) /\
           (forall j, 0 <= j < i => BArray144.get32d ctx (112 + 4 * j) = BArray32.get32 outer j) /\
           ctx256 tag256h H0_256 (ib256 (memread Glob.mem (to_uint pk) (to_uint lk))) aux /\
           h256 outer = compress H0_256 (map be32 (chunk 4 (ob256 (memread Glob.mem (to_uint pk) (to_uint lk)))))).
+ auto => /> &hr hi0 hi8 hb hj * ; split; first smt().
  split.
  + by move=> k hk0 hk1; rewrite BArray144.get8_set32dE ifF 1:/#; apply hb.
  move=> j hj0 hj1; case: (j = i{hr}) => [->|hne].
  + by rewrite BArray144.get_set32dE_eq //; smt().
  by rewrite BArray144.get_set32dE_neq 1:/#; apply hj => /#.
wp; ecall (ctx_init256_correct inner tag total).
wp; ecall (sha2_tag_correct 7).
wp; ecall (hmac_sha256_init_correct k0).
ecall (hmac_sha256_keyblock_correct pk lk).
auto => /> &hr hpl hl k1 hk1 [i1 o1 ms1] /= hi1 ho1 a ha0 ha8 ha4.
pose K := memread Glob.mem{hr} (to_uint pk) (to_uint lk).
have hsi := size_ib256 K.
have hpi : parse (ib256 K) = [map be32 (chunk 4 (ib256 K))] by rewrite /parse chunk_block.
have hti : tail 64 (ib256 K) = [] by apply tail_nil; rewrite hsi.
split.
+ do !split.
  + move=> k hq0 hq1; rewrite /protect_ptr SBArray144_112.get8_set_sub ifT 1:/#.
    by congr; ring.
  + smt().
  + by rewrite hsi.
  + by rewrite ha8 hsi.
  + by rewrite ha4 hpi /= hi1 /ib256 -hk1.
  + by rewrite hti; exact pending_nil.
  by rewrite ho1 /ob256 -hk1.
move=> c2 i2 hn hi0 hi8 hb hj htag hs ht hh hp ho.
rewrite cats0; have -> : SBArray144_112.get_sub8 c2 0 = a by apply sub112_bytes.
do !split => //.
rewrite -ho /outer144 /h256; apply eq_in_map => j /mem_iota hj' /=.
by rewrite hj //; smt().
qed.

lemma hmac_sha256_ctx_init_ll : islossless M.__hmac_sha256_ctx_init.
proof.
proc; while (true) (8 - i); first by auto => /#.
wp; call ctx_init256_ll; wp; call sha2_tag_ll; wp; call hmac_sha256_init_ll.
by call hmac_sha256_keyblock_ll; auto => /#.
qed.

lemma hmac_sha256_ctx_init_total (pk lk : W64.t) :
  phoare [M.__hmac_sha256_ctx_init :
           key = pk /\ keylen = lk /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 ==>
           hctx256 tag256h (memread Glob.mem (to_uint pk) (to_uint lk)) [] res.`1] = 1%r.
proof. by conseq hmac_sha256_ctx_init_ll (hmac_sha256_ctx_init_correct pk lk). qed.

(* ------------------------------------------------------------------ *)
(* Reading the stream state back                                      *)

lemma ctx_load256_correct (c : BArray112.t) :
  hoare [M.__sha256_ctx_load :
           ctx = c ==> res.`1 = SBArray112_32.get_sub32 c 4 /\ res.`2 = SBArray112_64.get_sub8 c 48].
proof.
proc.
while (0 <= i <= 8 /\ ctx = c /\
       (forall b, 0 <= b < 32 => BArray32.get8 h b = BArray112.get8 c (16 + b)) /\
       (forall b, 0 <= b < 8 * i => BArray64.get8 buf b = BArray112.get8 c (48 + b))).
+ auto => /> &hr hi0 hi8 hh hb hlt; split; first smt().
  move=> b hb0 hb1; rewrite BArray64.get8_set64dE.
  case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
  + by rewrite ifT 1:/# BArray112.get64d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hb; smt().
wp; while (0 <= i <= 8 /\ ctx = c /\
           (forall b, 0 <= b < 4 * i => BArray32.get8 h b = BArray112.get8 c (16 + b))).
+ auto => /> &hr hi0 hi8 hh hlt; split; first smt().
  move=> b hb0 hb1; rewrite BArray32.get8_set32dE.
  case: (4 * i{hr} <= b < 4 * i{hr} + 4) => hbi.
  + by rewrite ifT 1:/# BArray112.get32d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hh; smt().
auto => /> &hr; split; first smt().
move=> h1 i1 hn hi0 hi8 hh; split; first by split; [move=> b hb0 hb1; apply hh; smt() | smt()].
move=> b1 i2 hn2 hi20 hi28 hh2 hb; split.
+ by apply BArray32.tP => k hk; rewrite SBArray112_32.get8_get_sub hk /= hh2.
by apply BArray64.tP => k hk; rewrite SBArray112_64.get8_get_sub hk /= hb; smt().
qed.

lemma ctx_load256_ll : islossless M.__sha256_ctx_load.
proof. by proc; while (true) (8 - i); [auto => /# | wp; while (true) (8 - i); auto => /#]. qed.

(* ------------------------------------------------------------------ *)
(* The tag                                                            *)

lemma hmac_sha256_ctx_final_correct (c0 : BArray144.t) (o0 : BArray32.t) (k text : bytes) :
  hoare [M.__hmac_sha256_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> tag256h =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hctx256 tag256h k text c0 =>
              res.`3 = W64.zero /\ BArray32.to_list res.`2 = hmac_sha256 k text /\
              forall i, 0 <= i < 144 => BArray144.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 6 : (ctx = c0 /\ out = o0 /\ expect_0 = tag256h /\
         tag = BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 /\
         total = BArray112.get64d (SBArray144_112.get_sub8 c0 0) 8).
+ ecall (sha2_tag_correct 7); ecall (ctx_open_correct (SBArray144_16.get_sub8 ctx 0)).
  auto => /> r -> ->; exact (head144 c0).
sp; if.
+ wp; while (0 <= i <= 18 /\ inc = 18 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray144.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi18 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray144.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  case: (hctx256 tag256h k text c0).
  + wp; while (0 <= i <= 4 /\ BArray32.to_list mac = hmac_sha256 k text /\
               (forall b, 0 <= b < 8 * i => BArray32.get8 out b = BArray32.get8 mac b)).
    + auto => /> &hr hi0 hi4 hm hb hlt; split; first smt().
      move=> b hb0 hb1; rewrite BArray32.get8_set64dE.
      case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
      + by rewrite ifT 1:/# BArray32.get64d_byte 1:/#; congr; ring.
      by rewrite ifF 1:/#; apply hb; smt().
    wp; ecall (hmac_sha256_finalize_correct (ib256 k) (ob256 k) text (size_ob256 k)).
    wp; while (0 <= i <= 8 /\ ctx = c0 /\
               (forall j, 0 <= j < i => BArray32.get32 outer j = BArray144.get32d c0 (112 + 4 * j))).
    + auto => /> &hr hi0 hi8 hj hlt; split; first smt().
      move=> j hj0 hj1; rewrite BArray32.get_set32E 1,2:/#.
      by case: (i{hr} = j) => [<-|ne] //; apply hj => /#.
    wp; ecall (ctx_load256_correct (SBArray144_112.get_sub8 ctx 0)).
    auto => /> &hr htag hok hrep ht hh hp ho [i1 b1] /= -> ->.
    split; first smt().
    move=> i2 o2 hn hi0 hi8 hj.
    have hout : h256 o2 = compress H0_256 (map be32 (chunk 4 (ob256 k))).
    + rewrite -ho /outer144 /h256; apply eq_in_map => j /mem_iota hj' /=.
      by rewrite hj //; smt().
    split; first by do !split.
    move=> _ _ _ _ [m1 i3 b3 ms3] /= hm; split; first smt().
    move=> i4 o4 hn4 hi40 hi44 hm' hb; split; first smt().
    move=> c5 i5 hn5 hi50 hi58 hz; split.
    + have -> : o4 = m1 by apply BArray32.tP => b hb'; apply hb; smt().
      exact hm'.
    by move=> b hb0 hb1; apply hz; smt().
  wp; while (true); first by auto.
  wp; call (: true) => //; wp; while (true); first by auto.
  wp; call (: true) => //; auto => /> &hr; smt().
by auto => /> &hr htag hne; rewrite /hctx256 /ctx256; smt().
qed.

lemma hmac_sha256_ctx_final_ll : islossless M.__hmac_sha256_ctx_final.
proof.
proc.
seq 8 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
wp; while (true) (4 - i); first by auto => /#.
wp; call hmac_sha256_finalize_ll; wp; while (true) (8 - i); first by auto => /#.
by wp; call ctx_load256_ll; auto => /#.
qed.

lemma hmac_sha256_ctx_final_total (c0 : BArray144.t) (o0 : BArray32.t) (k text : bytes) :
  phoare [M.__hmac_sha256_ctx_final :
           ctx = c0 /\ out = o0 ==>
           (BArray112.get64d (SBArray144_112.get_sub8 c0 0) 0 <> tag256h =>
              res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = o0) /\
           (hctx256 tag256h k text c0 =>
              res.`3 = W64.zero /\ BArray32.to_list res.`2 = hmac_sha256 k text /\
              forall i, 0 <= i < 144 => BArray144.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq hmac_sha256_ctx_final_ll (hmac_sha256_ctx_final_correct c0 o0 k text). qed.
