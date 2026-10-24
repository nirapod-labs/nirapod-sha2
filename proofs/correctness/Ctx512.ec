(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Ctx512.ec
 * =========
 *
 * Functional correctness of the incremental SHA-384, SHA-512, SHA-512/224
 * and SHA-512/256 of src/context.jinc, over the 208-byte context, as
 * Ctx256.ec does for SHA-256.
 *
 * Layout (bytes): [0, 8) the tag, [8, 16) the total length, [16, 80) the
 * chaining value as eight u64, [80, 208) the pending block. ctx512 tag h0
 * m c is the representation: c holds the tag, |m| < 2^61, and a stream
 * state of m from h0 (SHA512_Stream.ec).
 *
 * Theorems (total correctness): sha512_ctx_init_total,
 * sha512_ctx_update_total, and <f>_ctx_final_total for the four digest
 * sizes, with the status codes of Ctx256.ec.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray16 BArray28 BArray32 BArray48 BArray64 BArray128 BArray208.
require import SBArray208_16 SBArray208_64 SBArray208_128.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill SHA256_Stream SHA512_Stream Ctx256.
require JWordList K512.
import SHA512.

(* Byte views of a context                                            *)

lemma w64_bytes208 (c : BArray208.t) o (w : W64.t) : 0 <= o => o + 8 <= 208 =>
  (forall k, 0 <= k < 8 => BArray208.get8 c (o + k) = w \bits8 k) => BArray208.get64d c o = w.
proof. by move=> h0 h1 hb; apply W8u8.wordP => k hk; rewrite BArray208.get64d_byte // hb. qed.

lemma subh_bytes512 (c : BArray208.t) (a : BArray64.t) :
  (forall k, 0 <= k < 64 => BArray208.get8 c (16 + k) = BArray64.get8 a k) =>
  SBArray208_64.get_sub64 c 2 = a.
proof.
move=> hb; apply BArray64.tP => k hk.
by rewrite SBArray208_64.get8_get_sub hk /= hb.
qed.

lemma subb_bytes512 (c : BArray208.t) (b : BArray128.t) :
  (forall k, 0 <= k < 128 => BArray208.get8 c (80 + k) = BArray128.get8 b k) =>
  SBArray208_128.get_sub8 c 80 = b.
proof.
move=> hb; apply BArray128.tP => k hk.
by rewrite SBArray208_128.get8_get_sub hk /= hb.
qed.

lemma head_tag512 (c : BArray208.t) :
  BArray16.get64d (SBArray208_16.get_sub8 c 0) 0 = BArray208.get64d c 0.
proof. by rewrite SBArray208_16.get64d_get_sub. qed.

lemma head_total512 (c : BArray208.t) :
  BArray16.get64d (SBArray208_16.get_sub8 c 0) 8 = BArray208.get64d c 8.
proof. by rewrite SBArray208_16.get64d_get_sub. qed.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op ctx512 (tag : W64.t) (h0 : W64.t list) (m : bytes) (c : BArray208.t) =
     BArray208.get64d c 0 = tag
  /\ size m < 2^61
  /\ stream512 h0 m (SBArray208_64.get_sub64 c 2) (SBArray208_128.get_sub8 c 80)
       (BArray208.get64d c 8).

(* The meaning of a context is a function of its bytes. *)
lemma ctx512_copy tag h0 m (c c' : BArray208.t) :
  BArray208.to_list c' = BArray208.to_list c => ctx512 tag h0 m c => ctx512 tag h0 m c'.
proof.
move=> heq; have -> // : c' = c.
apply BArray208.tP => i hi; rewrite -!BArray208.get_to_list.
by rewrite heq.
qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

lemma ctx_init512_correct (h1 : BArray64.t) (t tot : W64.t) :
  hoare [M.__sha512_ctx_init :
           h = h1 /\ tag = t /\ total = tot ==>
           BArray208.get64d res 0 = t /\ BArray208.get64d res 8 = tot /\
           SBArray208_64.get_sub64 res 2 = h1].
proof.
proc.
while (0 <= i <= 16 /\
       (forall k, 0 <= k < 8 => BArray208.get8 ctx k = t \bits8 k /\ BArray208.get8 ctx (8 + k) = tot \bits8 k) /\
       (forall k, 0 <= k < 64 => BArray208.get8 ctx (16 + k) = BArray64.get8 h1 k)).
+ auto => /> &hr hi0 hi8 hth hh hlt; split; first smt().
  split => k hk0 hk1; rewrite !BArray208.get8_set64dE; smt().
wp; while (0 <= i <= 8 /\ h = h1 /\
           (forall k, 0 <= k < 8 => BArray208.get8 ctx k = t \bits8 k /\ BArray208.get8 ctx (8 + k) = tot \bits8 k) /\
           (forall k, 0 <= k < 8 * i => BArray208.get8 ctx (16 + k) = BArray64.get8 h1 k)).
+ auto => /> &hr hi0 hi8 hth hh hlt; split; first smt().
  split => k hk0 hk1; rewrite !BArray208.get8_set64dE.
  + by rewrite !ifF 1,2:/#; apply hth.
  case: (8 * i{hr} <= k) => hki.
  + by rewrite ifT 1:/# BArray64.get64d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hh; smt().
auto => /> &hr; split.
+ split; last smt().
  move=> k hk0 hk1; rewrite !BArray208.get8_set64dE; split.
  + by rewrite ifF 1:/# ifT 1:/#.
  by rewrite ifT 1:/#.
move=> c1 i1 hn hi0 hi8 hth hh; split; first smt().
move=> c2 i2 hn2 hi20 hi28 hth2 hh2.
do !split.
+ by apply w64_bytes208 => // k hk; have := hth2 k hk => [[-> _]].
+ by apply w64_bytes208 => // k hk; have := hth2 k hk => [[_ ->]].
by apply subh_bytes512 => k hk; apply hh2.
qed.

lemma ctx_init512_ll : islossless M.__sha512_ctx_init.
proof.
proc; while (true) (16 - i); first by auto => /#.
by wp; while (true) (8 - i); auto => /#.
qed.

(* A fresh context of the empty message. *)
lemma sha512_ctx_init_correct (h1 : BArray64.t) (t : W64.t) :
  hoare [M.__sha512_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> ctx512 t (h512 h1) [] res].
proof.
conseq (ctx_init512_correct h1 t W64.zero) => // &m _ c [ht [hz hs]].
rewrite /ctx512 ht hz /=.
by apply stream512_nil; rewrite hs.
qed.

lemma sha512_ctx_init_total (h1 : BArray64.t) (t : W64.t) :
  phoare [M.__sha512_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> ctx512 t (h512 h1) [] res] = 1%r.
proof. by conseq ctx_init512_ll (sha512_ctx_init_correct h1 t). qed.

(* ------------------------------------------------------------------ *)
(* Absorbing into a context                                           *)

(* The three writes that store a stream state back into a context. *)
lemma upd512 (c : BArray208.t) (a : BArray64.t) (b : BArray128.t) (tot : W64.t) :
  let c' = BArray208.set64d (SBArray208_128.set_sub8 (SBArray208_64.set_sub64 c 2 a) 80 b) 8 tot in
  BArray208.get64d c' 0 = BArray208.get64d c 0 /\ BArray208.get64d c' 8 = tot /\
  SBArray208_64.get_sub64 c' 2 = a /\ SBArray208_128.get_sub8 c' 80 = b.
proof.
move=> c'; split.
+ apply w64_bytes208 => // k hk.
  rewrite /c' BArray208.get8_set64dE ifF 1:/# SBArray208_128.get8_set_sub ifF 1:/#.
  by rewrite SBArray208_64.get8_set_sub ifF 1:/# BArray208.get64d_byte.
split; first by apply w64_bytes208 => // k hk; rewrite /c' BArray208.get8_set64dE ifT 1:/#.
split.
+ apply subh_bytes512 => k hk.
  rewrite /c' BArray208.get8_set64dE ifF 1:/# SBArray208_128.get8_set_sub ifF 1:/#.
  by rewrite SBArray208_64.get8_set_sub ifT 1:/#.
apply subb_bytes512 => k hk.
rewrite /c' BArray208.get8_set64dE ifF 1:/# SBArray208_128.get8_set_sub ifT 1:/#.
by congr; ring.
qed.

lemma sha512_ctx_update_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (p0 l0 : W64.t) :
  hoare [M._sha512_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (ctx512 tag0 h0 m c0 =>
              if size m + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx512 tag0 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc.
seq 1 : (ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
         to_uint p0 + to_uint l0 < W64.modulus /\
         tag = BArray208.get64d c0 0 /\ total = BArray208.get64d c0 8).
+ ecall (ctx_open_correct (SBArray208_16.get_sub8 ctx 0)); auto => /> &hr r -> ->.
  by rewrite head_tag512 head_total512.
case: (ctx512 tag0 h0 m c0).
+ (* a context of m *)
  sp; if.
  + seq 4 : (ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
             to_uint p0 + to_uint l0 < W64.modulus /\ total = BArray208.get64d c0 8 /\
             ctx512 tag0 h0 m c0 /\ status = W64.of_int 2 /\
             ok = (size m + to_uint l0 < 2^61)).
    + wp; ecall (room_correct total); auto => /> &hr hm ht _ _ r hr.
      by rewrite W64.ultE hr ht ifT //; smt().
    if.
    + wp; ecall (sha512_absorb_mem_correct h0 m p0 l0); auto => /> &hr hpl hm ht hh hp hml.
      split; first smt().
      move=> _ [a b tot ms1] /= ht' hh' hp'.
      have [h1 [h2 [h3 h4]]] := upd512 c0 a b tot.
      have hs : size (m ++ memread Glob.mem{hr} (to_uint p0) (to_uint l0)) = size m + to_uint l0.
      + by rewrite size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
      move: h1; rewrite BArray208.get_set64dE_neq 1:// => h1.
      by rewrite h1 h3 h4 hs hml /=.
    by auto => /> &hr hpl hrep hok; rewrite hrep /=; smt().
  by auto => /> &hr hpl hrep hne; move: hrep; rewrite /ctx512; smt().
(* any other context: the absorb, if it runs, returns status 0 *)
sp; if.
+ seq 4 : (ctx = c0 /\ expect_0 = tag0 /\ BArray208.get64d c0 0 = tag0 /\
           status = W64.of_int 2 /\ !ctx512 tag0 h0 m c0).
  + by wp; call (: true) => //; auto => /> &hr; rewrite eq_sym.
  if.
  + by wp; call (: true) => //; auto => /> &hr.
  by auto => /> &hr.
by auto => /> &hr _ hne; smt().
qed.

lemma sha512_ctx_update_ll : islossless M._sha512_ctx_update.
proof.
proc.
seq 3 : true 1%r 1%r 0%r 0%r => //; first by wp; call ctx_open_ll; auto.
if; last by auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call room_ll; auto.
if; last by auto.
by wp; call sha512_absorb_mem_ll; auto.
qed.

lemma sha512_ctx_update_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (p0 l0 : W64.t) :
  phoare [M._sha512_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray208.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (ctx512 tag0 h0 m c0 =>
              if size m + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx512 tag0 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by conseq sha512_ctx_update_ll (sha512_ctx_update_correct c0 tag0 h0 m p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Finishing a context, once for every digest size                    *)

(* src/context.jinc writes the finishing step once over _DSIZE, as
   src/sha512.jinc does for __sha512_finalize (SHA512_Stream.ec); the
   theory below repeats it with the size abstract, over the finalize of
   Final512 at the same size, and each instance is a clone checked
   against the extracted text by an equivalence. *)
abstract theory CtxFinal512.

op dsize : int.

axiom dsize_ok : 4 <= dsize <= 64 /\ dsize %% 4 = 0.

clone import ByteArray as BArrayD with op size <= dsize.

clone import Final512 as FD with op dsize <= dsize, theory BArrayD <= BArrayD
proof dsize_ok by exact dsize_ok.

module C = {
  proc ctx_finalize (ctx:BArray208.t, digest:BArrayD.t,
                                    total:W64.t, ms:W64.t) : BArray208.t *
                                                             BArrayD.t *
                                                             W64.t = {
    var aux_1:BArray128.t;
    var aux:BArrayD.t;
    var aux_0:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ FD.F.finalize (digest,
    (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc ctx_final (ctx:BArray208.t, digest:BArrayD.t,
                                     expect_0:W64.t, ms:W64.t) : BArray208.t *
                                                                 BArrayD.t *
                                                                 W64.t *
                                                                 W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ M.__sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray208.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
}.

lemma ctx_final_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes) (d0 : BArrayD.t) :
  hoare [C.ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArrayD.to_list res.`2 = take dsize (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 1 : (ctx = c0 /\ digest = d0 /\ expect_0 = tag0 /\
         tag = BArray208.get64d c0 0 /\ total = BArray208.get64d c0 8).
+ ecall (ctx_open_correct (SBArray208_16.get_sub8 ctx 0)); auto => /> r -> ->.
  by rewrite head_tag512 head_total512.
sp; if.
+ wp; while (0 <= i <= 26 /\ inc = 26 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray208.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi14 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray208.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  inline C.ctx_finalize; wp.
  case: (ctx512 tag0 h0 m c0).
  + ecall (FD.finalize_correct h0 m); auto => /> &hr htag hok hrep.
    move=> [d1 h1 b1 ms1] /= hd; split; first smt().
    by move=> c1 i1 hn hi0 hi14 hb b hb0 hb1; apply hb; smt().
  call (: true) => //; auto => /> &hr; smt().
by auto => /> &hr htag hne; rewrite /ctx512; smt().
qed.

lemma ctx_final_ll : islossless C.ctx_final.
proof.
proc.
seq 3 : true 1%r 1%r 0%r 0%r => //; first by wp; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
by inline C.ctx_finalize; wp; call FD.finalize_ll; auto => /#.
qed.

end CtxFinal512.

clone CtxFinal512 as CFsha512 with op dsize <= 64, theory BArrayD <= BArray64
proof dsize_ok by done.

clone CtxFinal512 as CFsha384 with op dsize <= 48, theory BArrayD <= BArray48
proof dsize_ok by done.

clone CtxFinal512 as CFsha512_224 with op dsize <= 28, theory BArrayD <= BArray28
proof dsize_ok by done.

clone CtxFinal512 as CFsha512_256 with op dsize <= 32, theory BArrayD <= BArray32
proof dsize_ok by done.

equiv cfsha512_fin_eq : M._sha512___sha512_finalize ~ CFsha512.FD.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

equiv cfsha512_fz_eq : M._sha512_ctx____ctx_finalize ~ CFsha512.C.ctx_finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2.
proof. by proc; wp; call cfsha512_fin_eq; auto => /> &2 [a b c d] [a2 b2 c2 d2] /= *; subst. qed.

equiv cfsha512_eq : M._sha512_ctx___sha2_ctx_final ~ CFsha512.C.ctx_final : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cfsha512_fz_eq; auto.
qed.

lemma sha512_ctx_final_ll : islossless M._sha512_ctx___sha2_ctx_final.
proof. by conseq cfsha512_eq CFsha512.ctx_final_ll => /#. qed.

lemma sha512_ctx_final_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray64.t) :
  hoare [M._sha512_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray64.to_list res.`2 = take 64 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)].
proof. by conseq cfsha512_eq (CFsha512.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha512_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray64.t) :
  phoare [M._sha512_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray64.to_list res.`2 = take 64 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha512_ctx_final_ll (sha512_ctx_final_correct c0 tag0 h0 m d0). qed.

equiv cfsha384_fin_eq : M._sha384___sha512_finalize ~ CFsha384.FD.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

equiv cfsha384_fz_eq : M._sha384_ctx____ctx_finalize ~ CFsha384.C.ctx_finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2.
proof. by proc; wp; call cfsha384_fin_eq; auto => /> &2 [a b c d] [a2 b2 c2 d2] /= *; subst. qed.

equiv cfsha384_eq : M._sha384_ctx___sha2_ctx_final ~ CFsha384.C.ctx_final : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cfsha384_fz_eq; auto.
qed.

lemma sha384_ctx_final_ll : islossless M._sha384_ctx___sha2_ctx_final.
proof. by conseq cfsha384_eq CFsha384.ctx_final_ll => /#. qed.

lemma sha384_ctx_final_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray48.t) :
  hoare [M._sha384_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray48.to_list res.`2 = take 48 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)].
proof. by conseq cfsha384_eq (CFsha384.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha384_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray48.t) :
  phoare [M._sha384_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray48.to_list res.`2 = take 48 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha384_ctx_final_ll (sha384_ctx_final_correct c0 tag0 h0 m d0). qed.

equiv cfsha512_224_fin_eq : M._sha512_224___sha512_finalize ~ CFsha512_224.FD.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

equiv cfsha512_224_fz_eq : M._sha512_224_ctx____ctx_finalize ~ CFsha512_224.C.ctx_finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2.
proof. by proc; wp; call cfsha512_224_fin_eq; auto => /> &2 [a b c d] [a2 b2 c2 d2] /= *; subst. qed.

equiv cfsha512_224_eq : M._sha512_224_ctx___sha2_ctx_final ~ CFsha512_224.C.ctx_final : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cfsha512_224_fz_eq; auto.
qed.

lemma sha512_224_ctx_final_ll : islossless M._sha512_224_ctx___sha2_ctx_final.
proof. by conseq cfsha512_224_eq CFsha512_224.ctx_final_ll => /#. qed.

lemma sha512_224_ctx_final_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray28.t) :
  hoare [M._sha512_224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)].
proof. by conseq cfsha512_224_eq (CFsha512_224.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha512_224_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray28.t) :
  phoare [M._sha512_224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha512_224_ctx_final_ll (sha512_224_ctx_final_correct c0 tag0 h0 m d0). qed.

equiv cfsha512_256_fin_eq : M._sha512_256___sha512_finalize ~ CFsha512_256.FD.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

equiv cfsha512_256_fz_eq : M._sha512_256_ctx____ctx_finalize ~ CFsha512_256.C.ctx_finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2.
proof. by proc; wp; call cfsha512_256_fin_eq; auto => /> &2 [a b c d] [a2 b2 c2 d2] /= *; subst. qed.

equiv cfsha512_256_eq : M._sha512_256_ctx___sha2_ctx_final ~ CFsha512_256.C.ctx_final : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cfsha512_256_fz_eq; auto.
qed.

lemma sha512_256_ctx_final_ll : islossless M._sha512_256_ctx___sha2_ctx_final.
proof. by conseq cfsha512_256_eq CFsha512_256.ctx_final_ll => /#. qed.

lemma sha512_256_ctx_final_correct (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray32.t) :
  hoare [M._sha512_256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)].
proof. by conseq cfsha512_256_eq (CFsha512_256.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha512_256_ctx_final_total (c0 : BArray208.t) (tag0 : W64.t) (h0 : W64.t list) (m : bytes)
  (d0 : BArray32.t) :
  phoare [M._sha512_256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray208.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx512 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w64_be (SHA512.hash h0 m))) /\
              forall i, 0 <= i < 208 => BArray208.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha512_256_ctx_final_ll (sha512_256_ctx_final_correct c0 tag0 h0 m d0). qed.

