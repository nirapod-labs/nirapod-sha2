(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * HMAC_SHA256.ec
 * ==============
 *
 * Functional correctness of HMAC-SHA-256 in src/hmac.jinc against FIPS
 * 198-1 (spec/FIPS198_HMAC.ec), for keys of any length.
 *
 * The code follows Table 1 of FIPS 198-1 in four steps:
 *
 *     _hmac_sha256_keyblock_mem   K0: the key padded with zeros to one
 *                                 block, or its SHA-256 digest padded when
 *                                 the key is longer than a block (steps 1
 *                                 to 3);
 *     __hmac_sha256_init          the chaining values after the blocks
 *                                 K0 xor ipad and K0 xor opad (steps 4, 7);
 *     __hmac_sha256_outer         the inner digest H((K0 xor ipad) || text),
 *                                 written as the second part of the outer
 *                                 message (steps 5, 6, 8);
 *     __hmac_sha256_finalize      outer, then the outer digest (step 9).
 *
 * Theorems (total correctness):
 *     hmac_sha256_keyblock_total, hmac_sha256_init_total,
 *     hmac_sha256_outer_total, hmac_sha256_finalize_total and
 *     hmac_sha256_mem_total: to_list out = hmac_sha256 K text for the key
 *     K and the text read from memory.
 *
 * Domain: key and text do not wrap the address space, the key is below
 * 2^61 bytes and the text below 2^61 - 64 bytes.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray32 BArray64.
require import NirapodSha2 ArchWord.
require import Bytes FIPS180_SHA2 FIPS198_HMAC StreamSpec HMACSpec SafetyLib State Fill SHA256_Stream.
require JWordList K256.
import SHA256.

(* ------------------------------------------------------------------ *)
(* K0 (steps 1 to 3)                                                  *)

(* What the key block holds before its zero padding. *)
op kpre256 (k : bytes) : bytes = if 64 < size k then sha256 k else k.

lemma size_kpre256 (k : bytes) : size (kpre256 k) = if 64 < size k then 32 else size k.
proof. by rewrite /kpre256; case: (64 < size k) => //; rewrite size_sha256. qed.

lemma hmac_key256E (k : bytes) :
  hmac_key sha256 64 k = kpre256 k ++ zeros (64 - size (kpre256 k)).
proof.
rewrite /kpre256; case: (64 < size k) => h; first by rewrite hmac_key_long.
by rewrite hmac_key_short 1:/#.
qed.

(* A buffer whose first cells are r and whose other cells are zero. *)
lemma key_block (b : BArray64.t) (r : bytes) :
  size r <= 64 =>
  (forall i, 0 <= i < 64 => BArray64.get8 b i = if i < size r then nth W8.zero r i else W8.zero) =>
  BArray64.to_list b = r ++ zeros (64 - size r).
proof.
move=> hs hb; apply (eq_from_nth W8.zero).
+ by rewrite BArray64.size_to_list size_cat size_zeros; smt(size_ge0).
move=> i; rewrite BArray64.size_to_list => hi.
rewrite BArray64.get_to_list hb // nth_cat.
by case: (i < size r) => // hir; rewrite /zeros nth_nseq; smt(size_ge0).
qed.

lemma hmac_sha256_keyblock_correct (p0 l0 : W64.t) :
  hoare [M._hmac_sha256_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_key sha256 64 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc.
seq 3 : (to_uint i = size (kpre256 (memread Glob.mem (to_uint p0) (to_uint l0))) /\
         to_uint i <= 64 /\
         forall j, 0 <= j < to_uint i =>
           BArray64.get8 k0 j = nth W8.zero (kpre256 (memread Glob.mem (to_uint p0) (to_uint l0))) j).
+ seq 2 : (long = (W64.of_int 64 \ult keylen) /\ key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61); first by auto.
  if.
  + wp; while (0 <= j <= 4 /\ 64 < to_uint l0 /\
               BArray32.to_list digest = sha256 (memread Glob.mem (to_uint p0) (to_uint l0)) /\
               forall b, 0 <= b < 8 * j =>
                 BArray64.get8 k0 b = nth W8.zero (sha256 (memread Glob.mem (to_uint p0) (to_uint l0))) b).
    + auto => /> &hr hj0 hj4 hl hd hk hlt; split; first smt().
      move=> b hb0 hb1; rewrite BArray64.get8_set64dE.
      case: (8 * j{hr} <= b < 8 * j{hr} + 8) => hbi.
      + rewrite ifT 1:/# BArray32.get64d_byte 1:/# -hd BArray32.get_to_list.
        by congr; ring.
      by rewrite ifF 1:/#; apply hk; smt().
    wp; ecall (sha256_mem_correct p0 l0); auto => /> &hr hpl hl61 hlong.
    have h64 : 64 < to_uint l0 by move: hlong; rewrite W64.ultE.
    move=> d hd; split; first smt().
    move=> j1 k1 hn hj0 hj4 _ hk.
    have -> : kpre256 (memread Glob.mem{hr} (to_uint p0) (to_uint l0))
              = sha256 (memread Glob.mem{hr} (to_uint p0) (to_uint l0)).
    + by rewrite /kpre256 JWordList.size_memread; smt(W64.to_uint_cmp).
    rewrite size_sha256 /=; move=> b hb0 hb1; apply hk; smt().
  wp; ecall (fill64_correct k0 i key keylen); auto => /> &hr hpl hl61 hshort.
  have h64 : to_uint l0 <= 64 by move: hshort; rewrite W64.ultE /#.
  split; first smt().
  move=> _ [b1 ms1] /= hb1.
  have -> : kpre256 (memread Glob.mem{hr} (to_uint p0) (to_uint l0))
            = memread Glob.mem{hr} (to_uint p0) (to_uint l0).
  + by rewrite /kpre256 JWordList.size_memread; smt(W64.to_uint_cmp).
  rewrite JWordList.size_memread; 1: smt(W64.to_uint_cmp).
  split; first done.
  by move=> b hb0 hb1'; rewrite hb1 1:/# ifT 1:/# JWordList.nth_memread.
wp; ecall (zero64_correct k0 i hi); auto => /> &hr hi hi64 hk.
move=> [b1 ms1] /= hb1.
rewrite hmac_key256E; apply key_block; first by rewrite -hi.
move=> j hj; rewrite hb1 // -hi.
case: (j < to_uint i{hr}) => hj'.
+ by rewrite ifF 1:/#; apply hk; smt().
by rewrite ifT 1:/#.
qed.

lemma hmac_sha256_keyblock_ll : islossless M._hmac_sha256_keyblock_mem.
proof.
proc.
seq 3 : (to_uint i <= 64) 1%r 1%r 0%r 0%r => //.
+ seq 2 : (long = (W64.of_int 64 \ult keylen)) 1%r 1%r 0%r 0%r => //; first by auto.
  + if.
    + wp; while (true) (4 - j); first by auto => /#.
      by wp; call sha256_mem_ll; auto => /#.
    by wp; call fill64_ll; auto => /> &hr; rewrite W64.ultE /#.
  by hoare; auto.
+ by wp; call zero64_ll; auto.
hoare; seq 2 : (long = (W64.of_int 64 \ult keylen)); first by auto.
if.
+ wp; while (true); first by auto.
  by wp; call (: true) => //; auto.
by wp; call (: true) => //; auto => /> &hr; rewrite W64.ultE /#.
qed.

lemma hmac_sha256_keyblock_total (p0 l0 : W64.t) :
  phoare [M._hmac_sha256_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_key sha256 64 (memread Glob.mem (to_uint p0) (to_uint l0))] = 1%r.
proof. by conseq hmac_sha256_keyblock_ll (hmac_sha256_keyblock_correct p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* The two padded key blocks (steps 4 and 7)                          *)

(* A buffer whose bytes are those of the key xor a constant byte. *)
lemma xor_block (b k : BArray64.t) (c : W8.t) :
  (forall j, 0 <= j < 64 => BArray64.get8 b j = BArray64.get8 k j +^ c) =>
  BArray64.to_list b = xorb (BArray64.to_list k) (nseq 64 c).
proof.
move=> hb; apply (eq_from_nth W8.zero).
+ by rewrite size_xorb ?size_nseq !BArray64.size_to_list.
move=> j; rewrite BArray64.size_to_list => hj.
rewrite nth_xorb ?size_nseq ?BArray64.size_to_list // nth_nseq //.
by rewrite !BArray64.get_to_list hb.
qed.

lemma hmac_sha256_init_correct (K : BArray64.t) :
  hoare [M.__hmac_sha256_init :
           k0 = K ==>
           h256 res.`1 = compress H0_256 (map be32 (chunk 4 (xorb (BArray64.to_list K) (ipad 64)))) /\
           h256 res.`2 = compress H0_256 (map be32 (chunk 4 (xorb (BArray64.to_list K) (opad 64))))].
proof.
proc.
ecall (K256.compress_correct (h256 outer) opad); call sha256_init_correct.
ecall (K256.compress_correct (h256 inner) ipad); call sha256_init_correct.
while (0 <= i <= 8 /\ k0 = K /\ mi = W64.of_int 3906369333256140342 /\
       mo = W64.of_int 6655295901103053916 /\
       forall j, 0 <= j < 8 * i =>
         BArray64.get8 ipad j = BArray64.get8 K j +^ W8.of_int 0x36 /\
         BArray64.get8 opad j = BArray64.get8 K j +^ W8.of_int 0x5c).
+ auto => /> &hr hi0 hi8 hj hlt; split; first smt().
  move=> j hj0 hj1; rewrite !BArray64.get8_set64dE.
  case: (8 * i{hr} <= j) => hlo.
  + rewrite !ifT 1,2:/# !W8u8.xorb8E BArray64.get64d_byte 1:/# mi_bits8 1:/# mo_bits8 1:/#.
    by rewrite (_ : 8 * i{hr} + (j - 8 * i{hr}) = j) 1:/#.
  by rewrite !ifF 1,2:/#; apply hj => /#.
auto => />; split; first smt().
move=> i ipad1 opad1 hn hi0 hi8 hj h1 hh1 h2 hh2 h3 hh3 h4 hh4.
rewrite hh4 hh3 hh2 hh1 /ipad /opad; split; congr; congr; congr.
+ by apply xor_block => j hj'; have := hj j _; [smt() | move=> [-> _]].
by apply xor_block => j hj'; have := hj j _; [smt() | move=> [_ ->]].
qed.

lemma hmac_sha256_init_ll : islossless M.__hmac_sha256_init.
proof.
proc; call K256.compress_ll; call sha256_init_ll; call K256.compress_ll; call sha256_init_ll.
by while (true) (8 - i); auto => /#.
qed.

lemma hmac_sha256_init_total (K : BArray64.t) :
  phoare [M.__hmac_sha256_init :
           k0 = K ==>
           h256 res.`1 = compress H0_256 (map be32 (chunk 4 (xorb (BArray64.to_list K) (ipad 64)))) /\
           h256 res.`2 = compress H0_256 (map be32 (chunk 4 (xorb (BArray64.to_list K) (opad 64))))] = 1%r.
proof. by conseq hmac_sha256_init_ll (hmac_sha256_init_correct K). qed.

(* ------------------------------------------------------------------ *)
(* The inner digest as the tail of the outer message (steps 5, 6, 8)  *)

lemma take_sha256 (m : bytes) : take 32 (flatten (map w32_be (SHA256.hash H0_256 m))) = sha256 m.
proof. by rewrite take_oversize // size_digest256 // HMACSpec.size_hash256. qed.

(* After one full block ob, a digest of 32 bytes is pending. *)
lemma stream_outer (ob d : bytes) : size ob = 64 => size d = 32 =>
  parse (ob ++ d) = [map be32 (chunk 4 ob)] /\ tail 64 (ob ++ d) = d.
proof.
move=> hob hd; have hto : tail 64 ob = [] by apply tail_nil; rewrite hob.
have [hps hts] := parse_short ob d _; first by rewrite hto /= hd.
by rewrite hps hts hto /= /parse chunk_block.
qed.

lemma hmac_sha256_outer_correct (ib ob text : bytes) : size ob = 64 =>
  hoare [M.__hmac_sha256_outer :
           stream256 H0_256 (ib ++ text) inner buf total /\
           h256 outer = compress H0_256 (map be32 (chunk 4 ob)) /\ size (ib ++ text) < 2^61 ==>
           stream256 H0_256 (ob ++ sha256 (ib ++ text)) res.`1 res.`2 res.`3].
proof.
move=> hob; proc.
wp; while (0 <= i <= 4 /\ (forall j, 0 <= j < 8 * i => BArray64.get8 buf j = BArray32.get8 digest j) /\
           BArray32.to_list digest = sha256 (ib ++ text) /\
           h256 inner = compress H0_256 (map be32 (chunk 4 ob))).
+ auto => /> &hr hi0 hi4 hj hd hh hlt; split; first smt().
  move=> j hj0 hj1; rewrite BArray64.get8_set64dE.
  case: (8 * i{hr} <= j) => hlo.
  + by rewrite ifT 1:/# BArray32.get64d_byte 1:/#; congr; smt().
  by rewrite ifF 1:/#; apply hj => /#.
wp; while (0 <= i <= 8 /\
           (forall k, 0 <= k < i => BArray32.get32 inner k = BArray32.get32 outer k) /\
           h256 outer = compress H0_256 (map be32 (chunk 4 ob)) /\
           BArray32.to_list digest = sha256 (ib ++ text)).
+ auto => /> &hr hi0 hi8 hk ho hd hlt; split; first smt().
  move=> k hk0 hk1; rewrite BArray32.get_set32E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne] //; apply hk => /#.
wp; ecall (sha256_finalize_correct H0_256 (ib ++ text)).
auto => /> &hr ht hh hp ho hm [d1 inner1 buf1 ms1] /=; rewrite take_sha256 => hd.
split; first smt().
move=> i2 inner2 hn hi0 hi8 hk _; split.
+ split; first smt().
  rewrite -ho /h256; apply eq_in_map => k /mem_iota hk'; apply hk => /#.
move=> buf2 i3 hn' hi0' hi4 hj hh2.
have hsd : size (sha256 (ib ++ text)) = 32 by rewrite size_sha256.
have [hpd htd] := stream_outer ob (sha256 (ib ++ text)) hob hsd.
rewrite hpd htd /= size_cat hob hsd /=; split; first by rewrite hh2.
by move=> j hj'; rewrite hj 1:/# -hd BArray32.get_to_list.
qed.

lemma hmac_sha256_outer_ll : islossless M.__hmac_sha256_outer.
proof.
proc; wp; while (true) (4 - i); first by auto => /#.
wp; while (true) (8 - i); first by auto => /#.
by wp; call sha256_finalize_ll; auto => /#.
qed.

lemma hmac_sha256_outer_total (ib ob text : bytes) : size ob = 64 =>
  phoare [M.__hmac_sha256_outer :
           stream256 H0_256 (ib ++ text) inner buf total /\
           h256 outer = compress H0_256 (map be32 (chunk 4 ob)) /\ size (ib ++ text) < 2^61 ==>
           stream256 H0_256 (ob ++ sha256 (ib ++ text)) res.`1 res.`2 res.`3] = 1%r.
proof. by move=> hob; conseq hmac_sha256_outer_ll (hmac_sha256_outer_correct ib ob text hob). qed.

(* ------------------------------------------------------------------ *)
(* The outer digest (step 9)                                          *)

lemma hmac_sha256_finalize_correct (ib ob text : bytes) : size ob = 64 =>
  hoare [M.__hmac_sha256_finalize :
           stream256 H0_256 (ib ++ text) inner buf total /\
           h256 outer = compress H0_256 (map be32 (chunk 4 ob)) /\ size (ib ++ text) < 2^61 ==>
           BArray32.to_list res.`1 = sha256 (ob ++ sha256 (ib ++ text))].
proof.
move=> hob; proc.
ecall (sha256_finalize_correct H0_256 (ob ++ sha256 (ib ++ text))).
ecall (hmac_sha256_outer_correct ib ob text hob); auto => /> &hr ht hh hp ho hm r _ _ _.
split; first by rewrite size_cat hob size_sha256.
by move=> _ r2; rewrite take_sha256.
qed.

lemma hmac_sha256_finalize_ll : islossless M.__hmac_sha256_finalize.
proof. by proc; call sha256_finalize_ll; call hmac_sha256_outer_ll. qed.

lemma hmac_sha256_finalize_total (ib ob text : bytes) : size ob = 64 =>
  phoare [M.__hmac_sha256_finalize :
           stream256 H0_256 (ib ++ text) inner buf total /\
           h256 outer = compress H0_256 (map be32 (chunk 4 ob)) /\ size (ib ++ text) < 2^61 ==>
           BArray32.to_list res.`1 = sha256 (ob ++ sha256 (ib ++ text))] = 1%r.
proof. by move=> hob; conseq hmac_sha256_finalize_ll (hmac_sha256_finalize_correct ib ob text hob). qed.

(* ------------------------------------------------------------------ *)
(* One-shot HMAC-SHA-256                                              *)

op ib256 (k : bytes) : bytes = xorb (hmac_key sha256 64 k) (ipad 64).
op ob256 (k : bytes) : bytes = xorb (hmac_key sha256 64 k) (opad 64).

lemma size_ib256 k : size (ib256 k) = 64.
proof. by rewrite /ib256 /ipad size_xorb_pad // size_key256. qed.

lemma size_ob256 k : size (ob256 k) = 64.
proof. by rewrite /ob256 /opad size_xorb_pad // size_key256. qed.

lemma hmac_sha256_mem_correct (pk lk pm lm : W64.t) :
  hoare [M._hmac_sha256_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 /\
           to_uint pm + to_uint lm < W64.modulus /\ 64 + to_uint lm < 2^61 ==>
           BArray32.to_list res.`1
           = hmac_sha256 (memread Glob.mem (to_uint pk) (to_uint lk))
                         (memread Glob.mem (to_uint pm) (to_uint lm))].
proof.
proc.
ecall (sha256_finalize_correct H0_256
        (ob256 (memread Glob.mem (to_uint pk) (to_uint lk))
         ++ sha256 (ib256 (memread Glob.mem (to_uint pk) (to_uint lk))
                    ++ memread Glob.mem (to_uint pm) (to_uint lm)))).
ecall (hmac_sha256_outer_correct (ib256 (memread Glob.mem (to_uint pk) (to_uint lk)))
        (ob256 (memread Glob.mem (to_uint pk) (to_uint lk)))
        (memread Glob.mem (to_uint pm) (to_uint lm)) (size_ob256 _)).
ecall (sha256_absorb_mem_correct H0_256 (ib256 (memread Glob.mem (to_uint pk) (to_uint lk))) pm lm).
wp; ecall (hmac_sha256_init_correct k0).
ecall (hmac_sha256_keyblock_correct pk lk).
auto => /> &hr hpk hlk hpm hlm k1 hk1 [i1 o1 ms1] /= hi1 ho1.
pose K := memread Glob.mem{hr} (to_uint pk) (to_uint lk).
pose T := memread Glob.mem{hr} (to_uint pm) (to_uint lm).
have hsi := size_ib256 K.
have hpi : parse (ib256 K) = [map be32 (chunk 4 (ib256 K))] by rewrite /parse chunk_block.
have hti : tail 64 (ib256 K) = [] by apply tail_nil; rewrite hsi.
have hT : size T = to_uint lm by rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
split.
+ rewrite hsi hpi hti /= hi1 /ib256 -hk1 /=; split; first exact pending_nil.
  smt(W64.to_uint_cmp).
move=> _ _ _ _ _ _ r1 _ _ _.
split; first by rewrite ho1 /ob256 -hk1 size_cat hsi hT; smt().
move=> _ _ r2 _ _ _.
split; first by rewrite size_cat size_ob256 size_sha256.
by move=> _ r3 ->; rewrite take_sha256 /hmac_sha256 hmac_unfold.
qed.

lemma hmac_sha256_mem_ll : islossless M._hmac_sha256_mem.
proof.
proc; call sha256_finalize_ll; call hmac_sha256_outer_ll; call sha256_absorb_mem_ll.
by wp; call hmac_sha256_init_ll; call hmac_sha256_keyblock_ll; auto.
qed.

lemma hmac_sha256_mem_total (pk lk pm lm : W64.t) :
  phoare [M._hmac_sha256_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 /\
           to_uint pm + to_uint lm < W64.modulus /\ 64 + to_uint lm < 2^61 ==>
           BArray32.to_list res.`1
           = hmac_sha256 (memread Glob.mem (to_uint pk) (to_uint lk))
                         (memread Glob.mem (to_uint pm) (to_uint lm))] = 1%r.
proof. by conseq hmac_sha256_mem_ll (hmac_sha256_mem_correct pk lk pm lm). qed.
