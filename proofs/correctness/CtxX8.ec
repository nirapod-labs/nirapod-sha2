(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * CtxX8.ec
 * ========
 *
 * Functional correctness of the incremental 8-way SHA-256 of
 * src/context_x.jinc, over the 784-byte context the C API holds as opaque
 * storage.
 *
 * Layout (bytes): [0, 8) the tag, [8, 16) the common length absorbed,
 * [16, 272) the eight chaining values (SHA256_X8.ec, word j of lane k at
 * u32 cell 8 j + k), [272, 784) the eight pending blocks. ctx8 h0 ms c
 * says that c holds the 8-way tag, a length below 2^61, and an 8-way
 * stream state of the messages ms 0, ..., ms 7 from h0.
 *
 * Theorems (total correctness):
 *     sha256_x8_ctx_init_total    a fresh context of eight empty messages;
 *     sha256_x8_ctx_from_total    from a SHA-256 context of m (Ctx256.ec):
 *                                 status 0 and eight copies of m; status 1
 *                                 and the context unchanged when the source
 *                                 is not a SHA-256 context;
 *     sha256_x8_ctx_update_total  lane k absorbs l bytes at in[k]: status 0
 *                                 when the tag matches and the length stays
 *                                 below 2^61, 1 (wrong tag) or 2 (too long)
 *                                 with the context unchanged otherwise;
 *     sha256_x8_ctx_final_total   status 0, the eight digests and an
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
require import BArray16 BArray32 BArray64 BArray112 BArray256 BArray512 BArray784.
require import SBArray112_16 SBArray112_32 SBArray112_64.
require import SBArray784_16 SBArray784_256 SBArray784_512 SBArray512_64.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill Lanes.
require import SHA256_Stream Ctx256 SHA256_X8.
require JWordList.
import SHA256.

(* The tags of __sha2_tag: 2 for SHA-256, 9 for the 8-way contexts. *)
op tag256 : W64.t = W64.of_int (1100357333870 + (2 `<<` 32)).
op tagx8 : W64.t = W64.of_int (1100357333870 + (9 `<<` 32)).

(* ------------------------------------------------------------------ *)
(* Byte views of a context                                            *)

lemma w64_bytes784 (c : BArray784.t) o (w : W64.t) : 0 <= o => o + 8 <= 784 =>
  (forall k, 0 <= k < 8 => BArray784.get8 c (o + k) = w \bits8 k) => BArray784.get64d c o = w.
proof. by move=> h0 h1 hb; apply W8u8.wordP => k hk; rewrite BArray784.get64d_byte // hb. qed.

lemma sub256_bytes (c : BArray784.t) (a : BArray256.t) :
  (forall k, 0 <= k < 256 => BArray784.get8 c (16 + k) = BArray256.get8 a k) =>
  SBArray784_256.get_sub32 c 4 = a.
proof.
move=> hb; apply BArray256.tP => k hk.
by rewrite SBArray784_256.get8_get_sub hk /= hb.
qed.

lemma sub512_bytes (c : BArray784.t) (b : BArray512.t) :
  (forall k, 0 <= k < 512 => BArray784.get8 c (272 + k) = BArray512.get8 b k) =>
  SBArray784_512.get_sub8 c 272 = b.
proof.
move=> hb; apply BArray512.tP => k hk.
by rewrite SBArray784_512.get8_get_sub hk /= hb.
qed.

lemma headx_tag (c : BArray784.t) :
  BArray16.get64d (SBArray784_16.get_sub8 c 0) 0 = BArray784.get64d c 0.
proof. by rewrite SBArray784_16.get64d_get_sub. qed.

lemma headx_total (c : BArray784.t) :
  BArray16.get64d (SBArray784_16.get_sub8 c 0) 8 = BArray784.get64d c 8.
proof. by rewrite SBArray784_16.get64d_get_sub. qed.

(* The four writes that store an 8-way state into a context. *)
lemma updx8 (c : BArray784.t) (tag tot : W64.t) (a : BArray256.t) (b : BArray512.t) :
  let c' = SBArray784_512.set_sub8 (SBArray784_256.set_sub32
             (BArray784.set64d (BArray784.set64d c 0 tag) 8 tot) 4 a) 272 b in
  BArray784.get64d c' 0 = tag /\ BArray784.get64d c' 8 = tot /\
  SBArray784_256.get_sub32 c' 4 = a /\ SBArray784_512.get_sub8 c' 272 = b.
proof.
move=> c'; split.
+ apply w64_bytes784 => // k hk.
  rewrite /c' SBArray784_512.get8_set_sub ifF 1:/# SBArray784_256.get8_set_sub ifF 1:/#.
  by rewrite BArray784.get8_set64dE ifF 1:/# BArray784.get8_set64dE ifT 1:/#.
split.
+ apply w64_bytes784 => // k hk.
  rewrite /c' SBArray784_512.get8_set_sub ifF 1:/# SBArray784_256.get8_set_sub ifF 1:/#.
  by rewrite BArray784.get8_set64dE ifT 1:/#.
split.
+ apply sub256_bytes => k hk.
  rewrite /c' SBArray784_512.get8_set_sub ifF 1:/# SBArray784_256.get8_set_sub ifT 1:/#.
  by congr; ring.
apply sub512_bytes => k hk.
by rewrite /c' SBArray784_512.get8_set_sub ifT 1:/#; congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op ctx8 (h0 : W32.t list) (ms : int -> bytes) (c : BArray784.t) =
     BArray784.get64d c 0 = tagx8
  /\ to_uint (BArray784.get64d c 8) < 2^61
  /\ stream8 h0 ms (SBArray784_256.get_sub32 c 4) (SBArray784_512.get_sub8 c 272) (BArray784.get64d c 8).

(* The meaning of a context is a function of its bytes. *)
lemma ctx8_copy h0 ms (c c' : BArray784.t) :
  BArray784.to_list c' = BArray784.to_list c => ctx8 h0 ms c => ctx8 h0 ms c'.
proof.
move=> heq; have -> // : c' = c.
by apply BArray784.tP => i hi; rewrite -!BArray784.get_to_list heq.
qed.

(* Writes into the pending blocks leave the header and chaining values. *)
lemma setbuf_frame (c : BArray784.t) o (w : W64.t) : 272 <= o => o + 8 <= 784 =>
  BArray784.get64d (BArray784.set64d c o w) 0 = BArray784.get64d c 0 /\
  BArray784.get64d (BArray784.set64d c o w) 8 = BArray784.get64d c 8 /\
  SBArray784_256.get_sub32 (BArray784.set64d c o w) 4 = SBArray784_256.get_sub32 c 4.
proof.
move=> h0 h1; split.
+ by apply w64_bytes784 => // k hk; rewrite BArray784.get8_set64dE ifF 1:/# BArray784.get64d_byte.
split.
+ by apply w64_bytes784 => // k hk; rewrite BArray784.get8_set64dE ifF 1:/# BArray784.get64d_byte.
apply sub256_bytes => k hk; rewrite BArray784.get8_set64dE ifF 1:/#.
by rewrite SBArray784_256.get8_get_sub hk.
qed.

(* The three writes of a fresh context. *)
lemma updx8h (c : BArray784.t) (tag tot : W64.t) (a : BArray256.t) :
  let c' = SBArray784_256.set_sub32 (BArray784.set64d (BArray784.set64d c 0 tag) 8 tot) 4 a in
  BArray784.get64d c' 0 = tag /\ BArray784.get64d c' 8 = tot /\ SBArray784_256.get_sub32 c' 4 = a.
proof.
move=> c'; split.
+ apply w64_bytes784 => // k hk.
  rewrite /c' SBArray784_256.get8_set_sub ifF 1:/#.
  by rewrite BArray784.get8_set64dE ifF 1:/# BArray784.get8_set64dE ifT 1:/#.
split.
+ apply w64_bytes784 => // k hk.
  by rewrite /c' SBArray784_256.get8_set_sub ifF 1:/# BArray784.get8_set64dE ifT 1:/#.
apply sub256_bytes => k hk.
by rewrite /c' SBArray784_256.get8_set_sub ifT 1:/#; congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* A fresh context                                                    *)

lemma sha256_x8_ctx_init_correct :
  hoare [M.__sha256_x8_ctx_init : true ==> ctx8 H0_256 (fun _ => []) res].
proof.
proc.
while (0 <= i <= 64 /\ z = W64.zero /\ BArray784.get64d ctx 0 = tagx8 /\
       BArray784.get64d ctx 8 = W64.zero /\
       forall k, 0 <= k < 8 => l8 (SBArray784_256.get_sub32 ctx 4) k = H0_256).
+ auto => /> &hr hi0 _ ht hz hh hi64.
  have [h1 [h2 h3]] := setbuf_frame ctx{hr} (272 + 8 * i{hr}) W64.zero _ _; 1,2: smt().
  by rewrite h1 h2 h3 ht hz /=; smt().
wp; ecall (sha256_x8_init_correct); wp; ecall (sha2_tag_correct 9); auto => /> &hr c hh.
have [h1 [h2 h3]] := updx8h ctx{hr} (W64.of_int (1100357333870 + (9 `<<` 32))) W64.zero c.
rewrite h1 h2 h3 /=; split; first by split => // k *; apply hh => /#.
move=> c1 i1 hi1 hi10 hi164 ht hz hh1; rewrite hz /=.
have [_ hl] := stream8_nil H0_256 _ (SBArray784_512.get_sub8 c1 272) hh1.
exact hl.
qed.

lemma sha256_x8_ctx_init_ll : islossless M.__sha256_x8_ctx_init.
proof.
proc; while (0 <= i <= 64) (64 - i); first by auto => /#.
by wp; call sha256_x8_init_ll; wp; call sha2_tag_ll; auto => /#.
qed.

lemma sha256_x8_ctx_init_total :
  phoare [M.__sha256_x8_ctx_init : true ==> ctx8 H0_256 (fun _ => []) res] = 1%r.
proof. by conseq sha256_x8_ctx_init_ll sha256_x8_ctx_init_correct. qed.

(* ------------------------------------------------------------------ *)
(* Eight lanes from one SHA-256 context                               *)

lemma sha256_x8_ctx_from_correct (c0 : BArray784.t) (s0 : BArray112.t) (h0 : W32.t list) (m : bytes) :
  hoare [M._sha256_x8_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray112.get64d s0 0 <> tag256 => res.`2 = W64.one /\ res.`1 = c0) /\
           (ctx256 tag256 h0 m s0 => res.`2 = W64.zero /\ ctx8 h0 (fun _ => m) res.`1)].
proof.
proc.
seq 1 : (ctx = c0 /\ src = s0 /\ tag = BArray112.get64d s0 0 /\ total = BArray112.get64d s0 8).
+ ecall (ctx_open_correct (SBArray112_16.get_sub8 src 0)); auto => /> r -> ->.
  by rewrite head_tag head_total.
seq 3 : (ctx = c0 /\ src = s0 /\ total = BArray112.get64d s0 8 /\ status = W64.one /\
         ok = (BArray112.get64d s0 0 = tag256)).
+ by wp; ecall (sha2_tag_correct 2); auto => />.
if.
+ wp; ecall (sha256_x8_from_correct (SBArray112_32.get_sub32 src 4) (SBArray112_64.get_sub8 src 48)).
  wp; ecall (sha2_tag_correct 9); auto => /> htag [a b] /= hh hb _ hm hs hhs hps.
  have [h1 [h2 [h3 h4]]] := updx8 c0 (W64.of_int (1100357333870 + (9 `<<` 32))) (BArray112.get64d s0 8) a b.
  rewrite h1 h2 h3 h4 /tagx8 /=.
  split; first by rewrite hs.
  split; first by move=> k *; rewrite hs.
  by move=> k hk /=; split; [rewrite hh // hhs | rewrite hb].
by auto => /> &hr hne; split => // [#] ht; rewrite ht in hne.
qed.

lemma sha256_x8_ctx_from_ll : islossless M._sha256_x8_ctx_from.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
by wp; call sha256_x8_from_ll; wp; call sha2_tag_ll; auto.
qed.

lemma sha256_x8_ctx_from_total (c0 : BArray784.t) (s0 : BArray112.t) (h0 : W32.t list) (m : bytes) :
  phoare [M._sha256_x8_ctx_from :
           ctx = c0 /\ src = s0 ==>
           (BArray112.get64d s0 0 <> tag256 => res.`2 = W64.one /\ res.`1 = c0) /\
           (ctx256 tag256 h0 m s0 => res.`2 = W64.zero /\ ctx8 h0 (fun _ => m) res.`1)] = 1%r.
proof. by conseq sha256_x8_ctx_from_ll (sha256_x8_ctx_from_correct c0 s0 h0 m). qed.

(* ------------------------------------------------------------------ *)
(* Absorbing into a context                                           *)

(* The three writes that store an 8-way state back into a context. *)
lemma updx8u (c : BArray784.t) (a : BArray256.t) (b : BArray512.t) (tot : W64.t) :
  let c' = BArray784.set64d (SBArray784_512.set_sub8 (SBArray784_256.set_sub32 c 4 a) 272 b) 8 tot in
  BArray784.get64d c' 0 = BArray784.get64d c 0 /\ BArray784.get64d c' 8 = tot /\
  SBArray784_256.get_sub32 c' 4 = a /\ SBArray784_512.get_sub8 c' 272 = b.
proof.
move=> c'; split.
+ apply w64_bytes784 => // k hk.
  rewrite /c' BArray784.get8_set64dE ifF 1:/# SBArray784_512.get8_set_sub ifF 1:/#.
  by rewrite SBArray784_256.get8_set_sub ifF 1:/# BArray784.get64d_byte.
split; first by apply w64_bytes784 => // k hk; rewrite /c' BArray784.get8_set64dE ifT 1:/#.
split.
+ apply sub256_bytes => k hk.
  rewrite /c' BArray784.get8_set64dE ifF 1:/# SBArray784_512.get8_set_sub ifF 1:/#.
  by rewrite SBArray784_256.get8_set_sub ifT 1:/#; congr; ring.
apply sub512_bytes => k hk.
rewrite /c' BArray784.get8_set64dE ifF 1:/# SBArray784_512.get8_set_sub ifT 1:/#.
by congr; ring.
qed.

lemma sha256_x8_ctx_update_correct (c0 : BArray784.t) (h0 : W32.t list) (ms0 : int -> bytes)
  (in0 : BArray64.t) (l0 : W64.t) :
  hoare [M._sha256_x8_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 8 => ptr in0 q + to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> tagx8 => res.`2 = W64.one) /\
           (ctx8 h0 ms0 c0 =>
              if size (ms0 0) + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx8 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)].
proof.
proc.
seq 1 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall q, 0 <= q < 8 => ptr in0 q + to_uint l0 < W64.modulus) /\
         tag = BArray784.get64d c0 0 /\ total = BArray784.get64d c0 8).
+ ecall (ctx_open_correct (SBArray784_16.get_sub8 ctx 0)); auto => /> &hr r -> ->.
  by rewrite headx_tag headx_total.
seq 3 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall q, 0 <= q < 8 => ptr in0 q + to_uint l0 < W64.modulus) /\
         total = BArray784.get64d c0 8 /\ status = W64.one /\ ok = (BArray784.get64d c0 0 = tagx8)).
+ by wp; ecall (sha2_tag_correct 9); auto => />.
case: (ctx8 h0 ms0 c0).
+ (* a context of ms0 *)
  if.
  + seq 4 : (ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
             (forall q, 0 <= q < 8 => ptr in0 q + to_uint l0 < W64.modulus) /\
             total = BArray784.get64d c0 8 /\ ctx8 h0 ms0 c0 /\ status = W64.of_int 2 /\
             ok = (size (ms0 0) + to_uint l0 < 2^61)).
    + wp; ecall (room_correct total); auto => /> &hr hpl hlt hs hl r hr.
      by rewrite W64.ultE hr -(hs 0) //; smt().
    if.
    + wp; ecall (sha256_x8_absorb_correct h0 ms0 in0 l0); auto => /> &hr hpl ht hlt hs hl hok.
      split; first smt().
      move=> _ [a b tot ms1] /= hs' hl'.
      have [h1 [h2 [h3 h4]]] := updx8u c0 a b tot.
      move: h1 h3 h4; rewrite /= => h1 h3 h4.
      rewrite h1 ht h3 h4 /=; split; last by split => // k *; apply hs'.
      by rewrite (hs' 0) // size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
    by auto => /> &hr hpl hc hok; rewrite hc /=; smt().
  by auto => /> &hr hpl hc hne; move: hc; rewrite /ctx8; smt().
(* any other context: the absorb, if it runs, returns status 0 *)
if.
+ seq 4 : (ctx = c0 /\ BArray784.get64d c0 0 = tagx8 /\ status = W64.of_int 2 /\ !ctx8 h0 ms0 c0).
  + by wp; call (: true) => //; auto => /> &hr.
  if.
  + by wp; call (: true) => //; auto => /> &hr.
  by auto => /> &hr.
by auto => /> &hr _ hne; smt().
qed.

lemma sha256_x8_ctx_update_ll : islossless M._sha256_x8_ctx_update.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call room_ll; auto.
if; last by auto.
by wp; call sha256_x8_absorb_ll; auto.
qed.

lemma sha256_x8_ctx_update_total (c0 : BArray784.t) (h0 : W32.t list) (ms0 : int -> bytes)
  (in0 : BArray64.t) (l0 : W64.t) :
  phoare [M._sha256_x8_ctx_update :
           ctx = c0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 8 => ptr in0 q + to_uint l0 < W64.modulus) ==>
           (res.`2 <> W64.zero => res.`1 = c0) /\
           (BArray784.get64d c0 0 <> tagx8 => res.`2 = W64.one) /\
           (ctx8 h0 ms0 c0 =>
              if size (ms0 0) + to_uint l0 < 2^61
              then res.`2 = W64.zero /\
                   ctx8 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1
              else res.`2 = W64.of_int 2)] = 1%r.
proof. by conseq sha256_x8_ctx_update_ll (sha256_x8_ctx_update_correct c0 h0 ms0 in0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Finishing a context                                                *)

lemma sha256_x8_ctx_final_correct (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W32.t list)
  (ms0 : int -> bytes) :
  hoare [M._sha256_x8_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> tagx8 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx8 h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 8 =>
                 lane_block 32 (BArray256.to_list res.`2) k = flatten (map w32_be (SHA256.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)].
proof.
proc.
seq 1 : (ctx = c0 /\ out = d0 /\ tag = BArray784.get64d c0 0 /\ total = BArray784.get64d c0 8).
+ ecall (ctx_open_correct (SBArray784_16.get_sub8 ctx 0)); auto => /> r -> ->.
  by rewrite headx_tag headx_total.
seq 3 : (ctx = c0 /\ out = d0 /\ total = BArray784.get64d c0 8 /\ status = W64.one /\
         ok = (BArray784.get64d c0 0 = tagx8)).
+ by wp; ecall (sha2_tag_correct 9); auto => />.
if.
+ wp; while (0 <= i <= 98 /\ inc = 98 /\ z = W64.zero /\
             (forall b, 0 <= b < 8 * i => BArray784.get8 ctx b = W8.zero)).
  + auto => /> &hr hi0 hi98 hb hlt; split; first smt().
    move=> b hb0 hb1; rewrite BArray784.get8_set64dE.
    case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi.
    + by rewrite ifT 1:/# W8u8.get_zero.
    by rewrite ifF 1:/#; apply hb; smt().
  wp; case: (ctx8 h0 ms0 c0).
  + ecall (sha256_x8_finalize_correct h0 ms0); auto => /> _ _ hlt hs hl [d1 h1 b1 ms1] /= hd.
    split; first smt().
    by move=> c1 i1 hn hi0 hi98 hb b hb0 hb1; apply hb; smt().
  by call (: true) => //; auto => /> /#.
by auto => /> &hr hne; rewrite /ctx8; smt().
qed.

lemma sha256_x8_ctx_final_ll : islossless M._sha256_x8_ctx_final.
proof.
proc.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by wp; call sha2_tag_ll; call ctx_open_ll; auto.
if; last by auto.
wp; while (true) (inc - i); first by auto => /#.
by wp; call sha256_x8_finalize_ll; auto => /#.
qed.

lemma sha256_x8_ctx_final_total (c0 : BArray784.t) (d0 : BArray256.t) (h0 : W32.t list)
  (ms0 : int -> bytes) :
  phoare [M._sha256_x8_ctx_final :
           ctx = c0 /\ out = d0 ==>
           (BArray784.get64d c0 0 <> tagx8 => res.`3 = W64.one /\ res.`1 = c0 /\ res.`2 = d0) /\
           (ctx8 h0 ms0 c0 =>
              res.`3 = W64.zero /\
              (forall k, 0 <= k < 8 =>
                 lane_block 32 (BArray256.to_list res.`2) k = flatten (map w32_be (SHA256.hash h0 (ms0 k)))) /\
              forall i, 0 <= i < 784 => BArray784.get8 res.`1 i = W8.zero)] = 1%r.
proof. by conseq sha256_x8_ctx_final_ll (sha256_x8_ctx_final_correct c0 d0 h0 ms0). qed.
