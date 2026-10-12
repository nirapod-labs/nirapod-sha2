(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Ctx256.ec
 * =========
 *
 * Functional correctness of the incremental SHA-224 and SHA-256 of
 * src/context.jinc, over the 112-byte context the C API holds as opaque
 * storage.
 *
 * Layout (bytes): [0, 8) the tag naming the function, [8, 16) the total
 * length absorbed, [16, 48) the chaining value as eight u32, [48, 112) the
 * pending block. ctx256 tag h0 m c says that c is a context of the
 * function with that tag which has absorbed the message m from the initial
 * value h0: c holds the tag, |m| < 2^61, and its last three fields are a
 * stream state of m (SHA256_Stream.ec). The predicate reads the bytes of c
 * only, so two contexts with the same bytes have the same meaning
 * (ctx256_copy): the C API may copy a context with memcpy.
 *
 * Theorems (total correctness):
 *     sha256_ctx_init_total    a fresh context of the empty message;
 *     sha256_ctx_update_total  status 0 and the context of m ++ input when
 *                              the tag matches and |m| + |input| < 2^61;
 *                              status 1 (wrong tag) or 2 (too long) and
 *                              the context unchanged otherwise;
 *     sha224_ctx_final_total, sha256_ctx_final_total
 *                              status 0, the digest of m, and an all-zero
 *                              context when the tag matches; status 1, the
 *                              context and the output unchanged otherwise.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray16 BArray28 BArray32 BArray64 BArray112.
require import SBArray112_16 SBArray112_32 SBArray112_64.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill SHA256_Stream.
require JWordList K256.
import SHA256.

(* ------------------------------------------------------------------ *)
(* Byte views of a context                                            *)

lemma w64_bytes (c : BArray112.t) o (w : W64.t) : 0 <= o => o + 8 <= 112 =>
  (forall k, 0 <= k < 8 => BArray112.get8 c (o + k) = w \bits8 k) => BArray112.get64d c o = w.
proof. by move=> h0 h1 hb; apply W8u8.wordP => k hk; rewrite BArray112.get64d_byte // hb. qed.

lemma sub32_bytes (c : BArray112.t) (a : BArray32.t) :
  (forall k, 0 <= k < 32 => BArray112.get8 c (16 + k) = BArray32.get8 a k) =>
  SBArray112_32.get_sub32 c 4 = a.
proof.
move=> hb; apply BArray32.tP => k hk.
by rewrite SBArray112_32.get8_get_sub hk /= hb.
qed.

lemma sub64_bytes (c : BArray112.t) (b : BArray64.t) :
  (forall k, 0 <= k < 64 => BArray112.get8 c (48 + k) = BArray64.get8 b k) =>
  SBArray112_64.get_sub8 c 48 = b.
proof.
move=> hb; apply BArray64.tP => k hk.
by rewrite SBArray112_64.get8_get_sub hk /= hb.
qed.

lemma head_tag (c : BArray112.t) :
  BArray16.get64d (SBArray112_16.get_sub8 c 0) 0 = BArray112.get64d c 0.
proof. by rewrite SBArray112_16.get64d_get_sub. qed.

lemma head_total (c : BArray112.t) :
  BArray16.get64d (SBArray112_16.get_sub8 c 0) 8 = BArray112.get64d c 8.
proof. by rewrite SBArray112_16.get64d_get_sub. qed.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op ctx256 (tag : W64.t) (h0 : W32.t list) (m : bytes) (c : BArray112.t) =
     BArray112.get64d c 0 = tag
  /\ size m < 2^61
  /\ stream256 h0 m (SBArray112_32.get_sub32 c 4) (SBArray112_64.get_sub8 c 48)
       (BArray112.get64d c 8).

(* The meaning of a context is a function of its bytes. *)
lemma ctx256_copy tag h0 m (c c' : BArray112.t) :
  BArray112.to_list c' = BArray112.to_list c => ctx256 tag h0 m c => ctx256 tag h0 m c'.
proof.
move=> heq; have -> // : c' = c.
apply BArray112.tP => i hi; rewrite -!BArray112.get_to_list.
by rewrite heq.
qed.

(* ------------------------------------------------------------------ *)
(* Tag, header and room                                               *)

lemma sha2_tag_correct f0 :
  hoare [M.__sha2_tag : f = f0 ==> res = W64.of_int (1100357333870 + (f0 `<<` 32))].
proof. by proc; auto. qed.

lemma sha2_tag_ll : islossless M.__sha2_tag.
proof. by proc; auto. qed.

lemma ctx_open_correct (hd : BArray16.t) :
  hoare [M.__sha2_ctx_open :
           head = hd ==> res.`1 = BArray16.get64d hd 0 /\ res.`2 = BArray16.get64d hd 8].
proof. by proc; auto. qed.

lemma ctx_open_ll : islossless M.__sha2_ctx_open.
proof. by proc; auto. qed.

(* The bytes a context may still absorb: 2^61 - total, or none. *)
lemma room_correct (t : W64.t) :
  hoare [M.__sha2_room :
           total = t ==>
           to_uint res = if to_uint t < 2^61 then 2^61 - to_uint t else 0].
proof.
proc; auto => />; rewrite W64.ultE /=.
case: (to_uint t < 2305843009213693952) => h /=; last done.
by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
qed.

lemma room_ll : islossless M.__sha2_room.
proof. by proc; auto. qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

lemma ctx_init256_correct (h1 : BArray32.t) (t tot : W64.t) :
  hoare [M.__sha256_ctx_init :
           h = h1 /\ tag = t /\ total = tot ==>
           BArray112.get64d res 0 = t /\ BArray112.get64d res 8 = tot /\
           SBArray112_32.get_sub32 res 4 = h1].
proof.
proc.
while (0 <= i <= 8 /\
       (forall k, 0 <= k < 8 => BArray112.get8 ctx k = t \bits8 k /\ BArray112.get8 ctx (8 + k) = tot \bits8 k) /\
       (forall k, 0 <= k < 32 => BArray112.get8 ctx (16 + k) = BArray32.get8 h1 k)).
+ auto => /> &hr hi0 hi8 hth hh hlt; split; first smt().
  split => k hk0 hk1; rewrite !BArray112.get8_set64dE; smt().
wp; while (0 <= i <= 8 /\ h = h1 /\
           (forall k, 0 <= k < 8 => BArray112.get8 ctx k = t \bits8 k /\ BArray112.get8 ctx (8 + k) = tot \bits8 k) /\
           (forall k, 0 <= k < 4 * i => BArray112.get8 ctx (16 + k) = BArray32.get8 h1 k)).
+ auto => /> &hr hi0 hi8 hth hh hlt; split; first smt().
  split => k hk0 hk1; rewrite !BArray112.get8_set32dE.
  + by rewrite !ifF 1,2:/#; apply hth.
  case: (4 * i{hr} <= k) => hki.
  + by rewrite ifT 1:/# BArray32.get32d_byte 1:/#; congr; ring.
  by rewrite ifF 1:/#; apply hh; smt().
auto => /> &hr; split.
+ split; last smt().
  move=> k hk0 hk1; rewrite !BArray112.get8_set64dE; split.
  + by rewrite ifF 1:/# ifT 1:/#.
  by rewrite ifT 1:/#.
move=> c1 i1 hn hi0 hi8 hth hh; split; first smt().
move=> c2 i2 hn2 hi20 hi28 hth2 hh2.
do !split.
+ by apply w64_bytes => // k hk; have := hth2 k hk => [[-> _]].
+ by apply w64_bytes => // k hk; have := hth2 k hk => [[_ ->]].
by apply sub32_bytes => k hk; apply hh2.
qed.

lemma ctx_init256_ll : islossless M.__sha256_ctx_init.
proof.
proc; while (true) (8 - i); first by auto => /#.
by wp; while (true) (8 - i); auto => /#.
qed.

(* A fresh context of the empty message. *)
lemma sha256_ctx_init_correct (h1 : BArray32.t) (t : W64.t) :
  hoare [M.__sha256_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> ctx256 t (h256 h1) [] res].
proof.
conseq (ctx_init256_correct h1 t W64.zero) => // &m _ c [ht [hz hs]].
rewrite /ctx256 ht hz /=.
by apply stream256_nil; rewrite hs.
qed.

lemma sha256_ctx_init_total (h1 : BArray32.t) (t : W64.t) :
  phoare [M.__sha256_ctx_init :
           h = h1 /\ tag = t /\ total = W64.zero ==> ctx256 t (h256 h1) [] res] = 1%r.
proof. by conseq ctx_init256_ll (sha256_ctx_init_correct h1 t). qed.

(* ------------------------------------------------------------------ *)
(* Absorbing into a context                                           *)

(* The three writes that store a stream state back into a context. *)
lemma upd256 (c : BArray112.t) (a : BArray32.t) (b : BArray64.t) (tot : W64.t) :
  let c' = BArray112.set64d (SBArray112_64.set_sub8 (SBArray112_32.set_sub32 c 4 a) 48 b) 8 tot in
  BArray112.get64d c' 0 = BArray112.get64d c 0 /\ BArray112.get64d c' 8 = tot /\
  SBArray112_32.get_sub32 c' 4 = a /\ SBArray112_64.get_sub8 c' 48 = b.
proof.
move=> c'; split.
+ apply w64_bytes => // k hk.
  rewrite /c' BArray112.get8_set64dE ifF 1:/# SBArray112_64.get8_set_sub ifF 1:/#.
  by rewrite SBArray112_32.get8_set_sub ifF 1:/# BArray112.get64d_byte.
split; first by apply w64_bytes => // k hk; rewrite /c' BArray112.get8_set64dE ifT 1:/#.
split.
+ apply sub32_bytes => k hk.
  rewrite /c' BArray112.get8_set64dE ifF 1:/# SBArray112_64.get8_set_sub ifF 1:/#.
  by rewrite SBArray112_32.get8_set_sub ifT 1:/#.
apply sub64_bytes => k hk.
rewrite /c' BArray112.get8_set64dE ifF 1:/# SBArray112_64.get8_set_sub ifT 1:/#.
by congr; ring.
qed.

lemma sha256_ctx_update_correct (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (p0 l0 : W64.t) :
  hoare [M._sha256_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (ctx256 tag0 h0 m c0 =>
              if size m + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx256 tag0 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc.
seq 1 : (ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
         to_uint p0 + to_uint l0 < W64.modulus /\
         tag = BArray112.get64d c0 0 /\ total = BArray112.get64d c0 8).
+ ecall (ctx_open_correct (SBArray112_16.get_sub8 ctx 0)); auto => /> &hr r -> ->.
  by rewrite head_tag head_total.
case: (ctx256 tag0 h0 m c0).
+ (* a context of m *)
  sp; if.
  + seq 4 : (ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
             to_uint p0 + to_uint l0 < W64.modulus /\ total = BArray112.get64d c0 8 /\
             ctx256 tag0 h0 m c0 /\ status = W64.of_int 2 /\
             ok = (size m + to_uint l0 < 2^61)).
    + wp; ecall (room_correct total); auto => /> &hr hm ht _ _ r hr.
      by rewrite W64.ultE hr ht ifT //; smt().
    if.
    + wp; ecall (sha256_absorb_mem_correct h0 m p0 l0); auto => /> &hr hpl hm ht hh hp hml.
      split; first smt().
      move=> _ [a b tot ms1] /= ht' hh' hp'.
      have [h1 [h2 [h3 h4]]] := upd256 c0 a b tot.
      have hs : size (m ++ memread Glob.mem{hr} (to_uint p0) (to_uint l0)) = size m + to_uint l0.
      + by rewrite size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
      move: h1; rewrite BArray112.get_set64dE_neq 1:// => h1.
      by rewrite h1 h3 h4 hs hml /=.
    by auto => /> &hr hpl hrep hok; rewrite hrep /=; smt().
  by auto => /> &hr hpl hrep hne; move: hrep; rewrite /ctx256; smt().
(* any other context: the absorb, if it runs, returns status 0 *)
sp; if.
+ seq 4 : (ctx = c0 /\ expect_0 = tag0 /\ BArray112.get64d c0 0 = tag0 /\
           status = W64.of_int 2 /\ !ctx256 tag0 h0 m c0).
  + by wp; call (: true) => //; auto => /> &hr; rewrite eq_sym.
  if.
  + by wp; call (: true) => //; auto => /> &hr.
  by auto => /> &hr.
by auto => /> &hr _ hne; smt().
qed.

lemma sha256_ctx_update_ll : islossless M._sha256_ctx_update.
proof.
proc.
seq 3 : true 1%r 1%r 0%r 0%r => //; first by wp; call ctx_open_ll; auto.
if; last by auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call room_ll; auto.
if; last by auto.
by wp; call sha256_absorb_mem_ll; auto.
qed.

lemma sha256_ctx_update_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (p0 l0 : W64.t) :
  phoare [M._sha256_ctx_update :
           ctx = c0 /\ in_0 = p0 /\ inlen = l0 /\ expect_0 = tag0 /\
           to_uint p0 + to_uint l0 < W64.modulus ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray112.get64d c0 0 <> tag0 => res.`2 = W64.one) /\
           (ctx256 tag0 h0 m c0 =>
              if size m + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx256 tag0 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by conseq sha256_ctx_update_ll (sha256_ctx_update_correct c0 tag0 h0 m p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Finishing a context, once for every digest size                    *)

(* src/context.jinc writes the finishing step once over _DSIZE, as
   src/sha256.jinc does for __sha256_finalize (SHA256_Stream.ec); the
   theory below repeats it with the size abstract, over the finalize of
   Final256 at the same size, and each instance is a clone checked
   against the extracted text by sim. *)
abstract theory CtxFinal256.

op dsize : int.

axiom dsize_ok : 4 <= dsize <= 32 /\ dsize %% 4 = 0.

clone import ByteArray as BArrayD with op size <= dsize.

clone import Final256 as FD with op dsize <= dsize, theory BArrayD <= BArrayD
proof dsize_ok by exact dsize_ok.

module C = {
  proc ctx_finalize (ctx:BArray112.t, digest:BArrayD.t,
                                    total:W64.t, ms:W64.t) : BArray112.t *
                                                             BArrayD.t *
                                                             W64.t = {
    var aux:BArrayD.t;
    var aux_0:BArray32.t;
    var aux_1:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ FD.F.finalize (digest,
    (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray112_32.set_sub32 ctx 4 aux_0);
    ctx <- (SBArray112_64.set_sub8 ctx 48 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc ctx_final (ctx:BArray112.t, digest:BArrayD.t,
                                     expect_0:W64.t, ms:W64.t) : BArray112.t *
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
    (tag, total) <@ M.__sha2_ctx_open ((SBArray112_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (112 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray112.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
}.

lemma ctx_final_correct (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes) (d0 : BArrayD.t) :
  hoare [C.ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx256 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArrayD.to_list res.`2 = take dsize (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 1 : (ctx = c0 /\ digest = d0 /\ expect_0 = tag0 /\
         tag = BArray112.get64d c0 0 /\ total = BArray112.get64d c0 8).
+ ecall (ctx_open_correct (SBArray112_16.get_sub8 ctx 0)); auto => /> r -> ->.
  by rewrite head_tag head_total.
sp; if.
+ wp; while (0 <= i <= 14 /\ inc = 14 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray112.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi14 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray112.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  inline C.ctx_finalize; wp.
  case: (ctx256 tag0 h0 m c0).
  + ecall (FD.finalize_correct h0 m); auto => /> &hr htag hok hrep.
    move=> [d1 h1 b1 ms1] /= hd; split; first smt().
    by move=> c1 i1 hn hi0 hi14 hb b hb0 hb1; apply hb; smt().
  call (: true) => //; auto => /> &hr; smt().
by auto => /> &hr htag hne; rewrite /ctx256; smt().
qed.

lemma ctx_final_ll : islossless C.ctx_final.
proof.
proc.
seq 3 : true 1%r 1%r 0%r 0%r => //; first by wp; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
by inline C.ctx_finalize; wp; call FD.finalize_ll; auto => /#.
qed.

end CtxFinal256.

clone CtxFinal256 as CF256 with op dsize <= 32, theory BArrayD <= BArray32
proof dsize_ok by done.

clone CtxFinal256 as CF224 with op dsize <= 28, theory BArrayD <= BArray28
proof dsize_ok by done.

equiv cf224_fin_eq : M._sha224___sha256_finalize ~ CF224.FD.F.finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

equiv cf224_fz_eq : M._sha224_ctx____ctx_finalize ~ CF224.C.ctx_finalize : ={arg} ==> ={res}.
proof. by proc; wp; call cf224_fin_eq; auto. qed.

equiv cf224_eq : M._sha224_ctx___sha2_ctx_final ~ CF224.C.ctx_final : ={arg} ==> ={res}.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cf224_fz_eq; auto.
qed.

lemma sha224_ctx_final_ll : islossless M._sha224_ctx___sha2_ctx_final.
proof. by conseq cf224_eq CF224.ctx_final_ll => /#. qed.

lemma sha224_ctx_final_correct (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray28.t) :
  hoare [M._sha224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx256 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)].
proof. by conseq cf224_eq (CF224.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha224_ctx_final_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray28.t) :
  phoare [M._sha224_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx256 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray28.to_list res.`2 = take 28 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha224_ctx_final_ll (sha224_ctx_final_correct c0 tag0 h0 m d0). qed.

equiv cf256_fin_eq : M._sha256___sha256_finalize ~ CF256.FD.F.finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

equiv cf256_fz_eq : M._sha256_ctx____ctx_finalize ~ CF256.C.ctx_finalize : ={arg} ==> ={res}.
proof. by proc; wp; call cf256_fin_eq; auto. qed.

equiv cf256_eq : M._sha256_ctx___sha2_ctx_final ~ CF256.C.ctx_final : ={arg} ==> ={res}.
proof.
proc; seq 3 3 : (={ctx, digest, expect_0, ms, tag, total, status, ok}); first by sim.
if => //; last by auto.
wp; while (={i, inc, ctx, z}); first by auto.
by wp; call cf256_fz_eq; auto.
qed.

lemma sha256_ctx_final_ll : islossless M._sha256_ctx___sha2_ctx_final.
proof. by conseq cf256_eq CF256.ctx_final_ll => /#. qed.

lemma sha256_ctx_final_correct (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray32.t) :
  hoare [M._sha256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx256 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)].
proof. by conseq cf256_eq (CF256.ctx_final_correct c0 tag0 h0 m d0) => /#. qed.

lemma sha256_ctx_final_total (c0 : BArray112.t) (tag0 : W64.t) (h0 : W32.t list) (m : bytes)
  (d0 : BArray32.t) :
  phoare [M._sha256_ctx___sha2_ctx_final :
           ctx = c0 /\ digest = d0 /\ expect_0 = tag0 ==>
           (BArray112.get64d c0 0 <> tag0 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx256 tag0 h0 m c0 =>
              res.`3 = W64.zero /\
              BArray32.to_list res.`2 = take 32 (flatten (map w32_be (SHA256.hash h0 m))) /\
              forall i, 0 <= i < 112 => BArray112.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha256_ctx_final_ll (sha256_ctx_final_correct c0 tag0 h0 m d0). qed.

