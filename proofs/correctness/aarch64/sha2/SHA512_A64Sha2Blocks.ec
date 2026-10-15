(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Sha2Blocks.ec (aarch64/sha2)
 * ======================================
 *
 * Functional correctness of the memory entry point
 * _sha512_compress_blocks of the AArch64 SHA-512 instruction kernel
 * (src/aarch64/sha2/sha512_compress.jinc) against FIPS 180-4 section 6.4.2
 * (spec/FIPS180_SHA2.ec). The chaining value stays in s[0 .. 3] from
 * block to block; each iteration loads the block's eight vectors with
 * LDR q and REV64 and runs __sha512_block_a64 (SHA512_A64Sha2.ec).
 *
 * Memory is viewed through memread of crypto-specs JWordList: the byte
 * list mem.[a], ..., mem.[a + len - 1]. n blocks must end below 2^64
 * (to_uint p + 128 n < 2^64), because the kernel advances p past the last
 * block; the address arithmetic of the kernel does not wrap.
 *
 * Theorems:
 *     sha512_compress_blocks_total  _sha512_compress_blocks folds compress
 *                                   over the n blocks at p, which is the
 *                                   parse of section 5.2.2 of those bytes;
 *     sha512_compress_blocks_ll     _sha512_compress_blocks terminates.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_armv8a.
require import BArray64 BArray80 BArray128 BArray640.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds512 Vec Sha2Insn SHA512_A64Sha2.
require JWordList.
import SHA512 A512.

(* ------------------------------------------------------------------ *)
(* Lists of eight words and the state in four registers               *)

lemma list8 (H : W64.t list) : size H = 8 =>
  H = [nth W64.zero H 0; nth W64.zero H 1; nth W64.zero H 2; nth W64.zero H 3;
       nth W64.zero H 4; nth W64.zero H 5; nth W64.zero H 6; nth W64.zero H 7].
proof.
move=> hs; apply (eq_from_nth W64.zero); first by rewrite hs.
move=> i; rewrite hs => hi.
by have := range8 i hi; case=> [|[|[|[|[|[|[|]]]]]]] ->>.
qed.

lemma size_foldl_compress (h0 : W64.t list) (bs : W64.t list list) :
  size h0 = 8 => size (foldl compress h0 bs) = 8.
proof.
elim: bs h0 => [|b bs ih] h0 hs //=.
by apply ih; rewrite size_compress.
qed.

(* One block on the four registers is compress on the list. *)
lemma st_step (H mm : W64.t list) (j : int) : size H = 8 => 0 <= j => j < 4 =>
  VADD_2u64 (spair (rounds (schedule mm) (to_state H) 0 80) j) (spair (to_state H) j)
  = spair (to_state (compress H mm)) j.
proof.
move=> hs hj0 hj4; rewrite compress_rounds /ffwd.
move: (rounds (schedule mm) (to_state H) 0 80) => S.
case: S => a b c d e f g hh.
rewrite (list8 H hs) /to_state /of_state /=.
by have := range4 j hj0 hj4; case=> [->>|[->>|[->>|->>]]]; rewrite /spair /= vadd2_pack.
qed.

lemma hwords_of (h : BArray64.t) (H : W64.t list) : size H = 8 =>
  (forall i, 0 <= i < 4 => BArray64.get128 h i = spair (to_state H) i) =>
  hwords h = H.
proof.
move=> hs hh; apply (eq_from_nth W64.zero); first by rewrite size_hwords hs.
move=> k; rewrite size_hwords => hk.
rewrite nth_hwords // get64_of128 // hh; 1: exact (div2_range k hk).
rewrite /to_state /spair.
by have := range8 k hk; case=> [|[|[|[|[|[|[|]]]]]]] ->> /=; rewrite ?p2_0 ?p2_1.
qed.

(* ------------------------------------------------------------------ *)
(* Address arithmetic                                                 *)

lemma uint_add16 (p : W64.t) (j : int) : 0 <= j < 8 =>
  W64.to_uint p + 128 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (16 * j)) = W64.to_uint p + 16 * j.
proof.
move=> hj hp.
have h16 : W64.to_uint (W64.of_int (16 * j)) = 16 * j.
+ by rewrite W64.of_uintK modz_small 1:/#.
have hs : W64.to_uint p + W64.to_uint (W64.of_int (16 * j)) < W64.modulus.
+ by rewrite h16; move: hj hp; smt().
by rewrite W64.to_uintD_small // h16.
qed.

lemma nz_pos (n : W64.t) : n <> W64.zero => 0 < W64.to_uint n.
proof. by move=> hn; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp). qed.

lemma uint_sub1 (n : W64.t) : n <> W64.zero =>
  W64.to_uint (n - W64.one) = W64.to_uint n - 1.
proof.
move=> hn; rewrite W64.to_uintB.
+ by rewrite W64.uleE W64.to_uint1; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp).
by rewrite W64.to_uint1.
qed.

lemma uint_add128 (p : W64.t) : W64.to_uint p + 128 < W64.modulus =>
  W64.to_uint (p + W64.of_int 128) = W64.to_uint p + 128.
proof.
move=> hp; rewrite W64.to_uintD_small.
+ by rewrite W64.to_uint_small //; smt().
by rewrite W64.to_uint_small //; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Memory as bytes                                                    *)

lemma size_memread mem a l : 0 <= l => size (JWordList.memread mem a l) = l.
proof. exact JWordList.size_memread. qed.

lemma bswap_load64 mem a :
  bswap64 (loadW64 mem a) = be64 (JWordList.memread mem a 8).
proof.
rewrite /bswap64 /be64; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W8u8.size_to_list size_memread.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW64_bits8.
qed.

lemma memread_word mem a k : 0 <= k < 16 =>
  take 8 (drop (8 * k) (JWordList.memread mem a 128)) = JWordList.memread mem (a + 8 * k) 8.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

(* The block's vector j, as LDR q and REV64 form it. *)
lemma vrev_load mem (a j : int) : 0 <= j < 8 =>
  VREV64_16u8 (loadW128 mem (a + 16 * j))
  = wv2 (schedule (blockwords (JWordList.memread mem a 128))) (2 * j).
proof.
move=> hj; rewrite {1}(p2_bits (VREV64_16u8 (loadW128 mem (a + 16 * j)))) /wv2.
have hsz : size (JWordList.memread mem a 128) = 128 by rewrite size_memread.
have e : forall i, 0 <= i < 2 =>
  VREV64_16u8 (loadW128 mem (a + 16 * j)) \bits64 i
  = nth W64.zero (schedule (blockwords (JWordList.memread mem a 128))) (2 * j + i).
+ move=> i hi; rewrite vrev64_lane // loadW128_bits64 // bswap_load64.
  rewrite nth_schedule_lo 1:size_blockwords // 1:/# nth_blockwords // 1:/#.
  by rewrite memread_word 1:/#; congr; congr; ring.
by rewrite (e 0) // (e 1).
qed.

(* One more block of memory adds one block to the parse. *)
lemma parse_memreadS mem a k : 0 <= k =>
  parse (JWordList.memread mem a (128 * (k + 1)))
  = rcons (parse (JWordList.memread mem a (128 * k)))
          (blockwords (JWordList.memread mem (a + 128 * k) 128)).
proof.
move=> hk; rewrite /parse (_ : 128 * (k + 1) = 128 * k + 128) 1:/#.
rewrite JWordList.memread_add 1,2:/# chunk_cat; first by rewrite size_memread 1:/# dvdz_mulr.
have hne : JWordList.memread mem (a + 128 * k) 128 <> [] by rewrite -size_eq0 size_memread.
have := chunk_exact (JWordList.memread mem (a + 128 * k) 128) hne.
rewrite size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

(* The block lemma with the schedule of the block at a in memory. *)
lemma sha512_block_mem (S : state) mem (a : int) :
  hoare [M.__sha512_block_a64 :
           k = sHA512_K /\
           (forall j, 0 <= j < 4 => BArray80.get128 s j = spair S j) /\
           (forall j, 0 <= j < 8 =>
              BArray128.get128 m j = wv2 (schedule (blockwords (JWordList.memread mem a 128))) (2 * j)) ==>
           forall j, 0 <= j < 4 =>
             BArray80.get128 res.`1 j
             = VADD_2u64 (spair (rounds (schedule (blockwords (JWordList.memread mem a 128))) S 0 80) j)
                         (spair S j)].
proof.
have hsz : size (blockwords (JWordList.memread mem a 128)) = 16.
+ by rewrite size_blockwords // size_memread.
apply (sha512_block_a64_correct S).
by move=> t ht; rewrite /srec (nth_schedule_hi _ _ hsz).
qed.

(* ------------------------------------------------------------------ *)
(* n blocks from memory                                               *)

(* The counters after one more block. *)
lemma blk_step (n n0 p p0 : int) : 0 < n => n <= n0 => p = p0 + 128 * (n0 - n) =>
  (0 <= n - 1 /\ (0 <= n - 1 => n - 1 <= n0)) /\ p + 128 = p0 + 128 * (n0 - (n - 1)).
proof. smt(). qed.

lemma sha512_compress_blocks_correct (h0 : W64.t list) (p0 n0 : W64.t) :
  hoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))].
proof.
proc.
while (0 <= j <= 4 /\ size h0 = 8 /\ W64.to_uint n = 0 /\
       (forall i, 0 <= i < 4 =>
          BArray80.get128 s i = spair (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
            (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))))) i) /\
       (forall i, 0 <= i < j =>
          BArray64.get128 h i = spair (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
            (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))))) i)).
+ wp; skip => /> &hr hj0 _ hs8 hn hs hdone hj4; split; first smt().
  move=> i hi0 hi1; rewrite BArray64.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite hs /#.
  by rewrite hdone /#.
wp.
while (0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
       W64.to_uint p = W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) /\
       W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
       k = sHA512_K /\ size h0 = 8 /\
       (forall i, 0 <= i < 4 =>
          BArray80.get128 s i = spair (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
            (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))))) i)).
+ wp.
  ecall (sha512_block_mem
           (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
              (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n))))))
           Glob.mem (W64.to_uint p)).
  while (0 <= j <= 8 /\ n <> W64.zero /\
         0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
         W64.to_uint p = W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) /\
         W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
         k = sHA512_K /\ size h0 = 8 /\
         (forall i, 0 <= i < 4 =>
            BArray80.get128 s i = spair (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
              (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))))) i) /\
         forall i, 0 <= i < j =>
           BArray128.get128 m i = VREV64_16u8 (loadW128 Glob.mem (W64.to_uint p + 16 * i))).
  + wp; skip => /> &hr hj0 _ hnz hn0 hnn hp hb hs8 hs hm hj8.
    have hp128 : W64.to_uint p{hr} + 128 <= W64.modulus by smt(nz_pos).
    split; first smt().
    move=> i hi0 hi1.
    rewrite BArray128.get_set128E 1,2:/#.
    case: (j{hr} = i) => [<-|ne].
    + by rewrite BArray128.get_set128E 1,2:/# /= uint_add16 1:/#.
    by rewrite BArray128.get_set128E 1,2:/# ne /= hm /#.
  wp; skip => /> &hr hn0 hnn hp hb hs8 hs hnz.
  split; first smt().
  move=> j0 m0 hlt hj0 hj8 hm0.
  have hmw : forall j1, 0 <= j1 < 8 =>
    BArray128.get128 m0 j1
    = wv2 (schedule (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 128))) (2 * j1).
  + by move=> j1 hj1; rewrite hm0 1:/# vrev_load.
  split; first by move=> j1 hj1 hj2; apply hmw.
  move=> _ r hr.
  have hsub := uint_sub1 n{hr} hnz.
  have hplt : W64.to_uint p{hr} + 128 < W64.modulus by smt(nz_pos).
  have hadd := uint_add128 p{hr} hplt.
  have hF := size_foldl_compress h0 (parse (JWordList.memread Glob.mem{hr}
               (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n{hr})))) hs8.
  have hpar : foldl compress h0 (parse (JWordList.memread Glob.mem{hr} (W64.to_uint p0)
                (128 * (W64.to_uint n0 - (W64.to_uint n{hr} - 1)))))
            = compress (foldl compress h0 (parse (JWordList.memread Glob.mem{hr}
                (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n{hr})))))
                (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 128)).
  + rewrite (_ : W64.to_uint n0 - (W64.to_uint n{hr} - 1)
               = (W64.to_uint n0 - W64.to_uint n{hr}) + 1) 1:/#.
    by rewrite parse_memreadS 1:/# foldl_rcons hp.
  have hS : forall i, 0 <= i < 4 =>
    BArray80.get128 r.`1 i
    = spair (to_state (compress (foldl compress h0 (parse (JWordList.memread Glob.mem{hr}
                (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n{hr})))))
                (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 128)))) i.
  + by move=> i hi; rewrite hr // st_step // /#.
  rewrite hsub hadd hpar /=.
  have [h1 h2] := blk_step _ _ _ _ (nz_pos n{hr} hnz) hnn hp.
  by split; [exact h1 | split; [exact h2 | move=> i hi0 hi4; apply hS]].
wp.
while (0 <= j <= 4 /\ hwords h = h0 /\ p = p0 /\ n = n0 /\
       W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
       forall i, 0 <= i < j => BArray80.get128 s i = BArray64.get128 h i).
+ wp; skip => /> &hr hj0 _ hb hi hj4; split; first smt().
  move=> i hi0 hi1; rewrite BArray80.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first done.
  by rewrite hi /#.
wp; skip => /> &hr hb.
have hp0 : parse [] = [] by rewrite /parse /chunk /= mkseq0.
rewrite hp0 /=.
split; first smt().
move=> j0 s00 hjn hj0 hj4 hs.
split.
+ split; first smt(W64.to_uint_cmp).
  split; first by rewrite size_hwords.
  by move=> i hi0 hi4; rewrite hs 1:/# spair_h.
move=> more1 n1 p1 s1 hm1 hn10 hn1n0 hmore hp1 _ hs1.
have hz : W64.to_uint n1 = 0.
+ by have -> : n1 = W64.zero by smt(); rewrite W64.to_uint0.
split; first by split => //; smt().
move=> h1 j1 hjn1 hj10 hj14 _ hh.
apply hwords_of; first by rewrite size_foldl_compress // size_hwords.
by move=> i hi; rewrite hh 1:/# hz.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* The outer loop counts n down to 0; the inner loops run over constant
   ranges. *)
lemma sha512_compress_blocks_ll : islossless M._sha512_compress_blocks.
proof.
proc; wp.
while (0 <= j <= 4) (4 - j); first by auto => /#.
wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call sha512_block_a64_ll; wp.
  while (0 <= j <= 8) (8 - j); first by auto => /#.
  auto => /> &hr hnz.
  move=> j0; split; first smt().
  by move=> _ _ _; rewrite (uint_sub1 n{hr} hnz); smt().
wp; while (0 <= j <= 4) (4 - j); first by auto => /#.
by wp; skip => />; smt(W64.to_uint_eq W64.to_uint_cmp W64.to_uint0).
qed.

lemma sha512_compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha512_compress_blocks_ll (sha512_compress_blocks_correct h0 p0 n0). qed.
