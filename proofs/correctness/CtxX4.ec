(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * CtxX4.ec
 * ========
 *
 * Functional correctness of the incremental 4-way SHA-512 of
 * src/context_x.jinc, over the 784-byte context the C API holds as opaque
 * storage.
 *
 * Layout (bytes): [0, 8) the tag, [8, 16) the common length absorbed,
 * [16, 272) the four chaining values (SHA512_X4.ec, word j of lane k at
 * u64 cell 4 j + k), [272, 784) the four pending blocks. ctx4 h0 ms c
 * says that c holds the 4-way tag, a length below 2^61, and a 4-way
 * stream state of the messages ms 0, ..., ms 3 from h0. The byte views of
 * the layout are the lemmas of CtxX8.ec, which shares it.
 *
 * Theorems (total correctness):
 *     sha512_x4_ctx_init_total    a fresh context of four empty messages;
 *     sha512_x4_ctx_from_total    from a SHA-512 context of m (Ctx512.ec):
 *                                 status 0 and four copies of m; status 1
 *                                 and the context unchanged when the source
 *                                 is not a SHA-512 context;
 *     sha512_x4_ctx_update_total  lane k absorbs l bytes at in[k]: status 0
 *                                 when the tag matches and the length stays
 *                                 below 2^61, 1 (wrong tag) or 2 (too long)
 *                                 with the context unchanged otherwise;
 *     sha512_x4_ctx_final_total   status 0, the four digests and an
 *                                 all-zero context when the tag matches;
 *                                 status 1, context and output unchanged
 *                                 otherwise.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray16 BArray32 BArray64 BArray128 BArray208 BArray256 BArray512 BArray784.
require import SBArray208_16 SBArray208_64 SBArray208_128.
require import SBArray784_16 SBArray784_256 SBArray784_512 SBArray512_128.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill Lanes.
require import SHA512_Stream Ctx256 Ctx512 SHA512_X4 CtxX8.
require JWordList.
import SHA512.

(* The tags of __sha2_tag: 4 for SHA-512, 10 for the 4-way contexts. *)
op tag512 : W64.t = W64.of_int (1100357333870 + (4 `<<` 32)).
op tagx4 : W64.t = W64.of_int (1100357333870 + (10 `<<` 32)).

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op ctx4 (h0 : W64.t list) (ms : int -> bytes) (c : BArray784.t) =
     BArray784.get64d c 0 = tagx4
  /\ to_uint (BArray784.get64d c 8) < 2^61
  /\ stream4 h0 ms (SBArray784_256.get_sub32 c 4) (SBArray784_512.get_sub8 c 272) (BArray784.get64d c 8).

(* The meaning of a context is a function of its bytes. *)
lemma ctx4_copy h0 ms (c c' : BArray784.t) :
  BArray784.to_list c' = BArray784.to_list c => ctx4 h0 ms c => ctx4 h0 ms c'.
proof.
move=> heq; have -> // : c' = c.
by apply BArray784.tP => i hi; rewrite -!BArray784.get_to_list heq.
qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

lemma sha512_x4_ctx_init_correct :
  hoare [M.__sha512_x4_ctx_init : true ==> ctx4 H0_512 (fun _ => []) res].
proof.
proc.
while (0 <= i <= 64 /\ z = W64.zero /\ BArray784.get64d ctx 0 = tagx4 /\
       BArray784.get64d ctx 8 = W64.zero /\
       forall k, 0 <= k < 4 => l4 (SBArray784_256.get_sub32 ctx 4) k = H0_512).
+ auto => /> &hr hi0 _ ht hz hh hi64.
  have [h1 [h2 h3]] := setbuf_frame ctx{hr} (272 + 8 * i{hr}) W64.zero _ _; 1,2: smt().
  by rewrite h1 h2 h3 ht hz /=; smt().
wp; ecall (sha512_x4_init_correct); wp; ecall (sha2_tag_correct 10); auto => /> &hr c hh.
have [h1 [h2 h3]] := updx8h ctx{hr} (W64.of_int (1100357333870 + (10 `<<` 32))) W64.zero c.
rewrite h1 h2 h3 /=; split; first by split => // k *; apply hh => /#.
move=> c1 i1 hi1 hi10 hi164 ht hz hh1; rewrite hz /=.
have [_ hl] := stream4_nil H0_512 _ (SBArray784_512.get_sub8 c1 272) hh1.
exact hl.
qed.

lemma sha512_x4_ctx_init_ll : islossless M.__sha512_x4_ctx_init.
proof.
proc; while (0 <= i <= 64) (64 - i); first by auto => /#.
by wp; call sha512_x4_init_ll; wp; call sha2_tag_ll; auto => /#.
qed.

lemma sha512_x4_ctx_init_total :
  phoare [M.__sha512_x4_ctx_init : true ==> ctx4 H0_512 (fun _ => []) res] = 1%r.
proof. by conseq sha512_x4_ctx_init_ll sha512_x4_ctx_init_correct. qed.

(* ------------------------------------------------------------------ *)
(* Four lanes from one SHA-512 context                                *)

lemma sha512_x4_ctx_from_correct (c0 : BArray784.t) (s0 : BArray208.t) (h0 : W64.t list) (m : bytes) :
  hoare [M._sha512_x4_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray208.get64d s0 0 <> tag512 => res.`2 = W64.one /\ res.`1 = c0) /\
           (ctx512 tag512 h0 m s0 => res.`2 = W64.zero /\ ctx4 h0 (fun _ => m) res.`1)].
proof.
proc.
seq 1 : (ctx = c0 /\ src = s0 /\ tag = BArray208.get64d s0 0 /\ total = BArray208.get64d s0 8).
+ ecall (ctx_open_correct (SBArray208_16.get_sub8 src 0)); auto => /> r -> ->.
  by rewrite head_tag512 head_total512.
seq 3 : (ctx = c0 /\ src = s0 /\ total = BArray208.get64d s0 8 /\ status = W64.one /\
         ok = (BArray208.get64d s0 0 = tag512)).
+ by wp; ecall (sha2_tag_correct 4); auto => />.
if.
+ wp; ecall (sha512_x4_from_correct (SBArray208_64.get_sub64 src 2) (SBArray208_128.get_sub8 src 80)).
  wp; ecall (sha2_tag_correct 10); auto => /> htag [a b] /= hh hb _ hm hs hhs hps.
  have [h1 [h2 [h3 h4]]] := updx8 c0 (W64.of_int (1100357333870 + (10 `<<` 32))) (BArray208.get64d s0 8) a b.
  rewrite h1 h2 h3 h4 /tagx4 /=.
  split; first by rewrite hs.
  split; first by move=> k *; rewrite hs.
  by move=> k hk /=; split; [rewrite hh // hhs | rewrite hb].
by auto => /> &hr hne; split => // [#] ht; rewrite ht in hne.
qed.

lemma sha512_x4_ctx_from_ll : islossless M._sha512_x4_ctx_from.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
by wp; call sha512_x4_from_ll; wp; call sha2_tag_ll; auto.
qed.

lemma sha512_x4_ctx_from_total (c0 : BArray784.t) (s0 : BArray208.t) (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_x4_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray208.get64d s0 0 <> tag512 => res.`2 = W64.one /\ res.`1 = c0) /\
           (ctx512 tag512 h0 m s0 => res.`2 = W64.zero /\ ctx4 h0 (fun _ => m) res.`1)] = 1%r.
proof. by conseq sha512_x4_ctx_from_ll (sha512_x4_ctx_from_correct c0 s0 h0 m). qed.

(* ------------------------------------------------------------------ *)
(* Absorbing into a context                                           *)

lemma sha512_x4_ctx_update_correct (c0 : BArray784.t) (h0 : W64.t list) (ms0 : int -> bytes)
  (in0 : BArray32.t) (l0 : W64.t) :
  hoare [M._sha512_x4_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> tagx4 => res.`2 = W64.one) /\
           (ctx4 h0 ms0 c0 =>
              if size (ms0 0) + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx4 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc.
seq 1 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         tag = BArray784.get64d c0 0 /\ total = BArray784.get64d c0 8).
+ ecall (ctx_open_correct (SBArray784_16.get_sub8 ctx 0)); auto => /> &hr r -> ->.
  by rewrite headx_tag headx_total.
seq 3 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         total = BArray784.get64d c0 8 /\ status = W64.one /\ ok = (BArray784.get64d c0 0 = tagx4)).
+ by wp; ecall (sha2_tag_correct 10); auto => />.
case: (ctx4 h0 ms0 c0).
+ (* a context of ms0 *)
  if.
  + seq 4 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
             (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
             total = BArray784.get64d c0 8 /\ ctx4 h0 ms0 c0 /\ status = W64.of_int 2 /\
             ok = (size (ms0 0) + to_uint l0 < 2^61)).
    + wp; ecall (room_correct total); auto => /> &hr hpl hlt hs hl r hr.
      by rewrite W64.ultE hr -(hs 0) //; smt().
    if.
    + wp; ecall (sha512_x4_absorb_correct h0 ms0 in0 l0); auto => /> &hr hpl ht hlt hs hl hok.
      split; first smt().
      move=> _ [a b tot ms1] /= hs' hl'.
      have [h1 [h2 [h3 h4]]] := updx8u c0 a b tot.
      move: h1 h3 h4; rewrite /= => h1 h3 h4.
      rewrite h1 ht h3 h4 /=; split; last by split => // k *; apply hs'.
      by rewrite (hs' 0) // size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
    by auto => /> &hr hpl hc hok; rewrite hc /=; smt().
  by auto => /> &hr hpl hc hne; move: hc; rewrite /ctx4; smt().
(* any other context: the absorb, if it runs, returns status 0 *)
if.
+ seq 4 : (ctx = c0 /\ BArray784.get64d c0 0 = tagx4 /\ status = W64.of_int 2 /\ !ctx4 h0 ms0 c0).
  + by wp; call (: true) => //; auto => /> &hr.
  if.
  + by wp; call (: true) => //; auto => /> &hr.
  by auto => /> &hr.
by auto => /> &hr _ hne; smt().
qed.

lemma sha512_x4_ctx_update_ll : islossless M._sha512_x4_ctx_update.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call room_ll; auto.
if; last by auto.
by wp; call sha512_x4_absorb_ll; auto.
qed.

lemma sha512_x4_ctx_update_total (c0 : BArray784.t) (h0 : W64.t list) (ms0 : int -> bytes)
  (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> tagx4 => res.`2 = W64.one) /\
           (ctx4 h0 ms0 c0 =>
              if size (ms0 0) + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx4 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by conseq sha512_x4_ctx_update_ll (sha512_x4_ctx_update_correct c0 h0 ms0 in0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Finishing a context                                                *)

lemma sha512_x4_ctx_final_correct (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W64.t list)
  (ms0 : int -> bytes) :
  hoare [M._sha512_x4_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> tagx4 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx4 h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 4 =>
                 lane_block 64 (BArray256.to_list res.`2) k = flatten (map w64_be (SHA512.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 1 : (ctx = c0 /\ out = d0 /\ tag = BArray784.get64d c0 0 /\ total = BArray784.get64d c0 8).
+ ecall (ctx_open_correct (SBArray784_16.get_sub8 ctx 0)); auto => /> r -> ->.
  by rewrite headx_tag headx_total.
seq 3 : (ctx = c0 /\ out = d0 /\ total = BArray784.get64d c0 8 /\ status = W64.one /\
         ok = (BArray784.get64d c0 0 = tagx4)).
+ by wp; ecall (sha2_tag_correct 10); auto => />.
if.
+ wp; while (0 <= i <= 98 /\ inc = 98 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray784.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi98 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray784.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  wp; case: (ctx4 h0 ms0 c0).
  + ecall (sha512_x4_finalize_correct h0 ms0); auto => /> _ _ hlt hs hl [d1 h1 b1 ms1] /= hd.
    split; first smt().
    by move=> c1 i1 hn hi0 hi98 hb b hb0 hb1; apply hb; smt().
  by call (: true) => //; auto => /> /#.
by auto => /> &hr hne; rewrite /ctx4; smt().
qed.

lemma sha512_x4_ctx_final_ll : islossless M._sha512_x4_ctx_final.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
by wp; call sha512_x4_finalize_ll; auto => /#.
qed.

lemma sha512_x4_ctx_final_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W64.t list)
  (ms0 : int -> bytes) :
  phoare [M._sha512_x4_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> tagx4 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx4 h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 4 =>
                 lane_block 64 (BArray256.to_list res.`2) k = flatten (map w64_be (SHA512.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha512_x4_ctx_final_ll (sha512_x4_ctx_final_correct c0 d0 h0 ms0). qed.
