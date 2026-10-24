(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * HMAC_SHA512.ec
 * ==============
 *
 * Functional correctness of HMAC-SHA-512 in src/hmac.jinc against FIPS
 * 198-1 (spec/FIPS198_HMAC.ec), for keys of any length.
 *
 * The code follows Table 1 of FIPS 198-1 in four steps:
 *
 *     _hmac_sha512_keyblock_mem   K0: the key padded with zeros to one
 *                                 block, or its SHA-512 digest padded when
 *                                 the key is longer than a block (steps 1
 *                                 to 3);
 *     __hmac_sha512_init          the chaining values after the blocks
 *                                 K0 xor ipad and K0 xor opad (steps 4, 7);
 *     __hmac_sha512_outer         the inner digest H((K0 xor ipad) || text),
 *                                 written as the second part of the outer
 *                                 message (steps 5, 6, 8);
 *     __hmac_sha512_finalize      outer, then the outer digest (step 9).
 *
 * Theorems (total correctness):
 *     hmac_sha512_keyblock_total, hmac_sha512_init_total,
 *     hmac_sha512_outer_total, hmac_sha512_finalize_total and
 *     hmac_sha512_mem_total: to_list out = hmac_sha512 K text for the key
 *     K and the text read from memory.
 *
 * Domain: key and text do not wrap the address space, the key is below
 * 2^61 bytes and the text below 2^61 - 128 bytes.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray64 BArray128.
require import NirapodSha2 ArchWord.
require import Bytes FIPS180_SHA2 FIPS198_HMAC StreamSpec HMACSpec SafetyLib State Fill SHA256_Stream SHA512_Stream.
require JWordList K512.
import SHA512.

(* ------------------------------------------------------------------ *)
(* K0 (steps 1 to 3)                                                  *)

(* What the key block holds before its zero padding. *)
op kpre512 (k : bytes) : bytes = if 128 < size k then sha512 k else k.

lemma size_kpre512 (k : bytes) : size (kpre512 k) = if 128 < size k then 64 else size k.
proof. by rewrite /kpre512; case: (128 < size k) => //; rewrite size_sha512. qed.

lemma hmac_key512E (k : bytes) :
  hmac_key sha512 128 k = kpre512 k ++ zeros (128 - size (kpre512 k)).
proof.
rewrite /kpre512; case: (128 < size k) => h; first by rewrite hmac_key_long.
by rewrite hmac_key_short 1:/#.
qed.

(* A buffer whose first cells are r and whose other cells are zero. *)
lemma key_block512 (b : BArray128.t) (r : bytes) :
  size r <= 128 =>
  (forall i, 0 <= i < 128 => BArray128.get8 b i = if i < size r then nth W8.zero r i else W8.zero) =>
  BArray128.to_list b = r ++ zeros (128 - size r).
proof.
move=> hs hb; apply (eq_from_nth W8.zero).
+ by rewrite BArray128.size_to_list size_cat size_zeros; smt(size_ge0).
move=> i; rewrite BArray128.size_to_list => hi.
rewrite BArray128.get_to_list hb // nth_cat.
by case: (i < size r) => // hir; rewrite /zeros nth_nseq; smt(size_ge0).
qed.

lemma hmac_sha512_keyblock_correct (p0 l0 : W64.t) :
  hoare [M._hmac_sha512_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray128.to_list res.`1
           = hmac_key sha512 128 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc.
seq 3 : (to_uint i = size (kpre512 (memread Glob.mem (to_uint p0) (to_uint l0))) /\
         to_uint i <= 128 /\
         forall j, 0 <= j < to_uint i =>
           BArray128.get8 k0 j = nth W8.zero (kpre512 (memread Glob.mem (to_uint p0) (to_uint l0))) j).
+ seq 2 : (long = (W64.of_int 128 \ult keylen) /\ key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61); first by auto.
  if.
  + wp; while (0 <= j <= 8 /\ 128 < to_uint l0 /\
               BArray64.to_list digest = sha512 (memread Glob.mem (to_uint p0) (to_uint l0)) /\
               forall b, 0 <= b < 8 * j =>
                 BArray128.get8 k0 b = nth W8.zero (sha512 (memread Glob.mem (to_uint p0) (to_uint l0))) b).
    + auto => /> &hr hj0 hj4 hl hd hk hlt; split; first smt().
      move=> b hb0 hb1; rewrite BArray128.get8_set64dE.
      case: (8 * j{hr} <= b < 8 * j{hr} + 8) => hbi.
      + rewrite ifT 1:/# BArray64.get64d_byte 1:/# -hd BArray64.get_to_list.
        by congr; ring.
      by rewrite ifF 1:/#; apply hk; smt().
    wp; ecall (sha512_mem_correct p0 l0); auto => /> &hr hpl hl61 hlong.
    have h64 : 128 < to_uint l0 by move: hlong; rewrite W64.ultE.
    move=> d hd; split; first smt().
    move=> j1 k1 hn hj0 hj4 _ hk.
    have -> : kpre512 (memread Glob.mem{hr} (to_uint p0) (to_uint l0))
              = sha512 (memread Glob.mem{hr} (to_uint p0) (to_uint l0)).
    + by rewrite /kpre512 JWordList.size_memread; smt(W64.to_uint_cmp).
    rewrite size_sha512 /=; move=> b hb0 hb1; apply hk; smt().
  wp; ecall (fill128_correct k0 i key keylen); auto => /> &hr hpl hl61 hshort.
  have h64 : to_uint l0 <= 128 by move: hshort; rewrite W64.ultE /#.
  split; first smt().
  move=> _ [b1 ms1] /= hb1.
  have -> : kpre512 (memread Glob.mem{hr} (to_uint p0) (to_uint l0))
            = memread Glob.mem{hr} (to_uint p0) (to_uint l0).
  + by rewrite /kpre512 JWordList.size_memread; smt(W64.to_uint_cmp).
  rewrite JWordList.size_memread; 1: smt(W64.to_uint_cmp).
  split; first done.
  by move=> b hb0 hb1'; rewrite hb1 1:/# ifT 1:/# JWordList.nth_memread.
wp; ecall (zero128_correct k0 i hi); auto => /> &hr hi hi64 hk.
move=> [b1 ms1] /= hb1.
rewrite hmac_key512E; apply key_block512; first by rewrite -hi.
move=> j hj; rewrite hb1 // -hi.
case: (j < to_uint i{hr}) => hj'.
+ by rewrite ifF 1:/#; apply hk; smt().
by rewrite ifT 1:/#.
qed.

lemma hmac_sha512_keyblock_ll : islossless M._hmac_sha512_keyblock_mem.
proof.
proc.
seq 3 : (to_uint i <= 128) 1%r 1%r 0%r 0%r => //.
+ seq 2 : (long = (W64.of_int 128 \ult keylen)) 1%r 1%r 0%r 0%r => //; first by auto.
  + if.
    + wp; while (true) (8 - j); first by auto => /#.
      by wp; call sha512_mem_ll; auto => /#.
    by wp; call fill128_ll; auto => /> &hr; rewrite W64.ultE /#.
  by hoare; auto.
+ by wp; call zero128_ll; auto.
hoare; seq 2 : (long = (W64.of_int 128 \ult keylen)); first by auto.
if.
+ wp; while (true); first by auto.
  by wp; call (: true) => //; auto.
by wp; call (: true) => //; auto => /> &hr; rewrite W64.ultE /#.
qed.

lemma hmac_sha512_keyblock_total (p0 l0 : W64.t) :
  phoare [M._hmac_sha512_keyblock_mem :
           key = p0 /\ keylen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray128.to_list res.`1
           = hmac_key sha512 128 (memread Glob.mem (to_uint p0) (to_uint l0))] = 1%r.
proof. by conseq hmac_sha512_keyblock_ll (hmac_sha512_keyblock_correct p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* The two padded key blocks (steps 4 and 7)                          *)

(* A buffer whose bytes are those of the key xor a constant byte. *)
lemma xor_block512 (b k : BArray128.t) (c : W8.t) :
  (forall j, 0 <= j < 128 => BArray128.get8 b j = BArray128.get8 k j +^ c) =>
  BArray128.to_list b = xorb (BArray128.to_list k) (nseq 128 c).
proof.
move=> hb; apply (eq_from_nth W8.zero).
+ by rewrite size_xorb ?size_nseq !BArray128.size_to_list.
move=> j; rewrite BArray128.size_to_list => hj.
rewrite nth_xorb ?size_nseq ?BArray128.size_to_list // nth_nseq //.
by rewrite !BArray128.get_to_list hb.
qed.

lemma hmac_sha512_init_correct (K : BArray128.t) :
  hoare [M.__hmac_sha512_init :
           k0 = K ==>
           h512 res.`1 = compress H0_512 (map be64 (chunk 8 (xorb (BArray128.to_list K) (ipad 128)))) /\
           h512 res.`2 = compress H0_512 (map be64 (chunk 8 (xorb (BArray128.to_list K) (opad 128))))].
proof.
proc.
ecall (K512.compress_correct (h512 outer) opad); call sha512_init_correct.
ecall (K512.compress_correct (h512 inner) ipad); call sha512_init_correct.
while (0 <= i <= 16 /\ k0 = K /\ mi = W64.of_int 3906369333256140342 /\
       mo = W64.of_int 6655295901103053916 /\
       forall j, 0 <= j < 8 * i =>
         BArray128.get8 ipad j = BArray128.get8 K j +^ W8.of_int 0x36 /\
         BArray128.get8 opad j = BArray128.get8 K j +^ W8.of_int 0x5c).
+ auto => /> &hr hi0 hi8 hj hlt; split; first smt().
  move=> j hj0 hj1; rewrite !BArray128.get8_set64dE.
  case: (8 * i{hr} <= j) => hlo.
  + rewrite !ifT 1,2:/# !W8u8.xorb8E BArray128.get64d_byte 1:/# mi_bits8 1:/# mo_bits8 1:/#.
    by rewrite (_ : 8 * i{hr} + (j - 8 * i{hr}) = j) 1:/#.
  by rewrite !ifF 1,2:/#; apply hj => /#.
auto => />; split; first smt().
move=> i ipad1 opad1 hn hi0 hi8 hj h1 hh1 h2 hh2 h3 hh3 h4 hh4.
rewrite hh4 hh3 hh2 hh1 /ipad /opad; split; congr; congr; congr.
+ by apply xor_block512 => j hj'; have := hj j _; [smt() | move=> [-> _]].
by apply xor_block512 => j hj'; have := hj j _; [smt() | move=> [_ ->]].
qed.

lemma hmac_sha512_init_ll : islossless M.__hmac_sha512_init.
proof.
proc; call K512.compress_ll; call sha512_init_ll; call K512.compress_ll; call sha512_init_ll.
by while (true) (16 - i); auto => /#.
qed.

lemma hmac_sha512_init_total (K : BArray128.t) :
  phoare [M.__hmac_sha512_init :
           k0 = K ==>
           h512 res.`1 = compress H0_512 (map be64 (chunk 8 (xorb (BArray128.to_list K) (ipad 128)))) /\
           h512 res.`2 = compress H0_512 (map be64 (chunk 8 (xorb (BArray128.to_list K) (opad 128))))] = 1%r.
proof. by conseq hmac_sha512_init_ll (hmac_sha512_init_correct K). qed.

(* ------------------------------------------------------------------ *)
(* The inner digest as the tail of the outer message (steps 5, 6, 8)  *)

lemma take_sha512 (m : bytes) : take 64 (flatten (map w64_be (SHA512.hash H0_512 m))) = sha512 m.
proof. by rewrite take_oversize // size_digest512 // HMACSpec.size_hash512. qed.

(* After one full block ob, a digest of 64 bytes is pending. *)
lemma stream_outer512 (ob d : bytes) : size ob = 128 => size d = 64 =>
  parse (ob ++ d) = [map be64 (chunk 8 ob)] /\ tail 128 (ob ++ d) = d.
proof.
move=> hob hd; have hto : tail 128 ob = [] by apply tail512_nil; rewrite hob.
have [hps hts] := parse512_short ob d _; first by rewrite hto /= hd.
by rewrite hps hts hto /= /parse chunk_block.
qed.

lemma hmac_sha512_outer_correct (ib ob text : bytes) : size ob = 128 =>
  hoare [M.__hmac_sha512_outer :
           stream512 H0_512 (ib ++ text) inner buf total /\
           h512 outer = compress H0_512 (map be64 (chunk 8 ob)) /\ size (ib ++ text) < 2^61 ==>
           stream512 H0_512 (ob ++ sha512 (ib ++ text)) res.`1 res.`2 res.`3].
proof.
move=> hob; proc.
wp; while (0 <= i <= 8 /\ (forall j, 0 <= j < 8 * i => BArray128.get8 buf j = BArray64.get8 digest j) /\
           BArray64.to_list digest = sha512 (ib ++ text) /\
           h512 inner = compress H0_512 (map be64 (chunk 8 ob))).
+ auto => /> &hr hi0 hi4 hj hd hh hlt; split; first smt().
  move=> j hj0 hj1; rewrite BArray128.get8_set64dE.
  case: (8 * i{hr} <= j) => hlo.
  + by rewrite ifT 1:/# BArray64.get64d_byte 1:/#; congr; smt().
  by rewrite ifF 1:/#; apply hj => /#.
wp; while (0 <= i <= 8 /\
           (forall k, 0 <= k < i => BArray64.get64 inner k = BArray64.get64 outer k) /\
           h512 outer = compress H0_512 (map be64 (chunk 8 ob)) /\
           BArray64.to_list digest = sha512 (ib ++ text)).
+ auto => /> &hr hi0 hi8 hk ho hd hlt; split; first smt().
  move=> k hk0 hk1; rewrite BArray64.get_set64E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne] //; apply hk => /#.
wp; ecall (sha512_finalize_correct H0_512 (ib ++ text)).
auto => /> &hr ht hh hp ho hm [d1 inner1 buf1 ms1] /=; rewrite take_sha512 => hd.
split; first smt().
move=> i2 inner2 hn hi0 hi8 hk _; split.
+ split; first smt().
  rewrite -ho /h512; apply eq_in_map => k /mem_iota hk'; apply hk => /#.
move=> buf2 i3 hn' hi0' hi4 hj hh2.
have hsd : size (sha512 (ib ++ text)) = 64 by rewrite size_sha512.
have [hpd htd] := stream_outer512 ob (sha512 (ib ++ text)) hob hsd.
rewrite hpd htd /= size_cat hob hsd /=; split; first by rewrite hh2.
by move=> j hj'; rewrite hj 1:/# -hd BArray64.get_to_list.
qed.

lemma hmac_sha512_outer_ll : islossless M.__hmac_sha512_outer.
proof.
proc; wp; while (true) (8 - i); first by auto => /#.
wp; while (true) (8 - i); first by auto => /#.
by wp; call sha512_finalize_ll; auto => /#.
qed.

lemma hmac_sha512_outer_total (ib ob text : bytes) : size ob = 128 =>
  phoare [M.__hmac_sha512_outer :
           stream512 H0_512 (ib ++ text) inner buf total /\
           h512 outer = compress H0_512 (map be64 (chunk 8 ob)) /\ size (ib ++ text) < 2^61 ==>
           stream512 H0_512 (ob ++ sha512 (ib ++ text)) res.`1 res.`2 res.`3] = 1%r.
proof. by move=> hob; conseq hmac_sha512_outer_ll (hmac_sha512_outer_correct ib ob text hob). qed.

(* ------------------------------------------------------------------ *)
(* The outer digest (step 9)                                          *)

lemma hmac_sha512_finalize_correct (ib ob text : bytes) : size ob = 128 =>
  hoare [M.__hmac_sha512_finalize :
           stream512 H0_512 (ib ++ text) inner buf total /\
           h512 outer = compress H0_512 (map be64 (chunk 8 ob)) /\ size (ib ++ text) < 2^61 ==>
           BArray64.to_list res.`1 = sha512 (ob ++ sha512 (ib ++ text))].
proof.
move=> hob; proc.
ecall (sha512_finalize_correct H0_512 (ob ++ sha512 (ib ++ text))).
ecall (hmac_sha512_outer_correct ib ob text hob); auto => /> &hr ht hh hp ho hm r _ _ _.
split; first by rewrite size_cat hob size_sha512.
by move=> _ r2; rewrite take_sha512.
qed.

lemma hmac_sha512_finalize_ll : islossless M.__hmac_sha512_finalize.
proof. by proc; call sha512_finalize_ll; call hmac_sha512_outer_ll. qed.

lemma hmac_sha512_finalize_total (ib ob text : bytes) : size ob = 128 =>
  phoare [M.__hmac_sha512_finalize :
           stream512 H0_512 (ib ++ text) inner buf total /\
           h512 outer = compress H0_512 (map be64 (chunk 8 ob)) /\ size (ib ++ text) < 2^61 ==>
           BArray64.to_list res.`1 = sha512 (ob ++ sha512 (ib ++ text))] = 1%r.
proof. by move=> hob; conseq hmac_sha512_finalize_ll (hmac_sha512_finalize_correct ib ob text hob). qed.

(* ------------------------------------------------------------------ *)
(* One-shot HMAC-SHA-256                                              *)

op ib512 (k : bytes) : bytes = xorb (hmac_key sha512 128 k) (ipad 128).
op ob512 (k : bytes) : bytes = xorb (hmac_key sha512 128 k) (opad 128).

lemma size_ib512 k : size (ib512 k) = 128.
proof. by rewrite /ib512 /ipad size_xorb_pad // size_key512. qed.

lemma size_ob512 k : size (ob512 k) = 128.
proof. by rewrite /ob512 /opad size_xorb_pad // size_key512. qed.

lemma hmac_sha512_mem_correct (pk lk pm lm : W64.t) :
  hoare [M._hmac_sha512_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 /\
           to_uint pm + to_uint lm < W64.modulus /\ 128 + to_uint lm < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_sha512 (memread Glob.mem (to_uint pk) (to_uint lk))
                         (memread Glob.mem (to_uint pm) (to_uint lm))].
proof.
proc.
ecall (sha512_finalize_correct H0_512
        (ob512 (memread Glob.mem (to_uint pk) (to_uint lk))
         ++ sha512 (ib512 (memread Glob.mem (to_uint pk) (to_uint lk))
                    ++ memread Glob.mem (to_uint pm) (to_uint lm)))).
ecall (hmac_sha512_outer_correct (ib512 (memread Glob.mem (to_uint pk) (to_uint lk)))
        (ob512 (memread Glob.mem (to_uint pk) (to_uint lk)))
        (memread Glob.mem (to_uint pm) (to_uint lm)) (size_ob512 _)).
ecall (sha512_absorb_mem_correct H0_512 (ib512 (memread Glob.mem (to_uint pk) (to_uint lk))) pm lm).
wp; ecall (hmac_sha512_init_correct k0).
ecall (hmac_sha512_keyblock_correct pk lk).
auto => /> &hr hpk hlk hpm hlm k1 hk1 [i1 o1 ms1] /= hi1 ho1.
pose K := memread Glob.mem{hr} (to_uint pk) (to_uint lk).
pose T := memread Glob.mem{hr} (to_uint pm) (to_uint lm).
have hsi := size_ib512 K.
have hpi : parse (ib512 K) = [map be64 (chunk 8 (ib512 K))] by rewrite /parse chunk_block.
have hti : tail 128 (ib512 K) = [] by apply tail512_nil; rewrite hsi.
have hT : size T = to_uint lm by rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
split.
+ rewrite hsi hpi hti /= hi1 /ib512 -hk1 /=; split; first exact pend512_nil.
  smt(W64.to_uint_cmp).
move=> _ _ _ _ _ _ r1 _ _ _.
split; first by rewrite ho1 /ob512 -hk1 size_cat hsi hT; smt().
move=> _ _ r2 _ _ _.
split; first by rewrite size_cat size_ob512 size_sha512.
by move=> _ r3 ->; rewrite take_sha512 /hmac_sha512 hmac_unfold.
qed.

lemma hmac_sha512_mem_ll : islossless M._hmac_sha512_mem.
proof.
proc; call sha512_finalize_ll; call hmac_sha512_outer_ll; call sha512_absorb_mem_ll.
by wp; call hmac_sha512_init_ll; call hmac_sha512_keyblock_ll; auto.
qed.

lemma hmac_sha512_mem_total (pk lk pm lm : W64.t) :
  phoare [M._hmac_sha512_mem :
           key = pk /\ keylen = lk /\ msg = pm /\ msglen = lm /\
           to_uint pk + to_uint lk < W64.modulus /\ to_uint lk < 2^61 /\
           to_uint pm + to_uint lm < W64.modulus /\ 128 + to_uint lm < 2^61 ==>
           BArray64.to_list res.`1
           = hmac_sha512 (memread Glob.mem (to_uint pk) (to_uint lk))
                         (memread Glob.mem (to_uint pm) (to_uint lm))] = 1%r.
proof. by conseq hmac_sha512_mem_ll (hmac_sha512_mem_correct pk lk pm lm). qed.
