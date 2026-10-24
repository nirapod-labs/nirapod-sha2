(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64ScalarBlocks.ec (aarch64/scalar)
 * ==========================================
 *
 * Functional correctness of the memory entry point
 * _sha512_compress_blocks of the AArch64 scalar SHA-512 compression
 * kernel (src/aarch64/scalar/sha512_compress.jinc) against FIPS 180-4
 * section 6.4.2 (spec/FIPS180_SHA2.ec). The kernel has no separate
 * one-block procedure: each iteration loads the block words from memory
 * into the schedule window and calls _sha512_rounds_a64, so this file
 * proves the loop directly.
 *
 * Memory is viewed through memread of crypto-specs JWordList: the byte
 * list mem.[a], ..., mem.[a + len - 1]. n blocks must end below 2^64
 * (to_uint p + 128 n < 2^64), because the kernel advances p past the last
 * block; the address arithmetic of the kernel does not wrap.
 *
 * Theorems:
 *     sha512_compress_blocks_correct  _sha512_compress_blocks folds
 *                                     compress over the n blocks at p,
 *                                     which is the parse of section
 *                                     5.2.2 of those bytes (Hoare logic:
 *                                     partial correctness);
 *     sha512_compress_blocks_ll       _sha512_compress_blocks terminates;
 *     sha512_compress_blocks_total    the same with termination.
 *
 * The shared stream proof uses both statements, so this file has the same
 * interface as the portable kernel's.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray64 BArray128.
require import NirapodSha2 ArchWord.
require import Bytes FIPS180_SHA2 SHA512_A64Scalar.
require JWordList.
import SHA512.

abbrev memread = JWordList.memread.

(* Address arithmetic of the block loads. The kernel adds the byte offset
   with 64-bit word arithmetic, so the proof needs the sum below 2^64. *)
lemma modulus_ge64 : 128 <= W64.modulus by [].

lemma of_int_word (i : int) : 0 <= i < 16 =>
  W64.to_uint (W64.of_int (8 * i)) = 8 * i.
proof.
move=> hi.
have hm : (8 * i) %% W64.modulus = 8 * i
  by apply modz_small; smt(modulus_ge64).
by rewrite W64.of_uintK hm.
qed.

lemma small_add (x i M : int) : 0 <= i < 16 => x + 128 <= M => x + 8 * i < M.
proof. by move=> hi hx; smt(). qed.

lemma uint_add8 (p : W64.t) (i : int) : 0 <= i < 16 =>
  W64.to_uint p + 128 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (8 * i)) = W64.to_uint p + 8 * i.
proof.
move=> hi hp.
have h8 : W64.to_uint (W64.of_int (8 * i)) = 8 * i by apply of_int_word.
have hside : W64.to_uint p + W64.to_uint (W64.of_int (8 * i)) < W64.modulus.
+ by rewrite h8; apply (small_add (W64.to_uint p) i W64.modulus hi hp).
by rewrite (W64.to_uintD_small p (W64.of_int (8 * i)) hside) h8.
qed.

lemma bound_at (p0 n0 p n M : int) : 0 < n => n <= n0 =>
  p = p0 + 128 * (n0 - n) => p0 + 128 * n0 < M => p + 128 <= M.
proof. by move=> hn hn0 hp hb; smt(). qed.

lemma bound_lt (p0 n0 p n M : int) : 0 < n => n <= n0 =>
  p = p0 + 128 * (n0 - n) => p0 + 128 * n0 < M => p + 128 < M.
proof. by move=> hn hn0 hp hb; smt(). qed.

lemma nz_pos (n : W64.t) : n <> W64.zero => 0 < W64.to_uint n.
proof. by move=> hn; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp). qed.

lemma uint_sub1 (n : W64.t) : n <> W64.zero =>
  W64.to_uint (n - W64.one) = W64.to_uint n - 1.
proof.
move=> hn.
rewrite W64.to_uintB.
+ rewrite W64.uleE W64.to_uint1.
  smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp).
by rewrite W64.to_uint1.
qed.

lemma uint_add128 (p : W64.t) : W64.to_uint p + 128 < W64.modulus =>
  W64.to_uint (p + W64.of_int 128) = W64.to_uint p + 128.
proof.
move=> hp.
rewrite W64.to_uintD_small.
+ by rewrite W64.to_uint_small //; smt(modulus_ge64).
by rewrite W64.to_uint_small //; smt(modulus_ge64).
qed.

(* The byte reversal is called inside a probabilistic proof, so it is used
   in total form. *)
lemma bswap64_ll : islossless M.__bswap64.
proof. by proc; auto. qed.

lemma bswap64_total (x0 : W64.t) :
  phoare [M.__bswap64 : x = x0 ==> res = WordSpec.bswap64 x0] = 1%r.
proof. by conseq bswap64_ll (bswap64_spec x0). qed.

(* ------------------------------------------------------------------ *)
(* Memory as bytes                                                    *)

lemma size_memread mem a l : 0 <= l => size (memread mem a l) = l.
proof. exact JWordList.size_memread. qed.

lemma memread_add mem a x y : 0 <= x => 0 <= y =>
  memread mem a (x + y) = memread mem a x ++ memread mem (a + x) y.
proof. exact JWordList.memread_add. qed.

(* The big-endian word at a, as the kernel reads it: a little-endian load
   followed by a byte reversal. *)
lemma bswap_load64 mem a :
  WordSpec.bswap64 (loadW64 mem a) = be64 (memread mem a 8).
proof.
rewrite /WordSpec.bswap64 /be64; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W8u8.size_to_list size_memread.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW64_bits8.
qed.

lemma memread_word mem a k : 0 <= k < 16 =>
  take 8 (drop (8 * k) (memread mem a 128)) = memread mem (a + 8 * k) 8.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

(* One more block of memory adds one block to the parse. *)
lemma parse_memreadS mem a k : 0 <= k =>
  parse (memread mem a (128 * (k + 1)))
  = rcons (parse (memread mem a (128 * k))) (map be64 (chunk 8 (memread mem (a + 128 * k) 128))).
proof.
move=> hk; rewrite /parse (_ : 128 * (k + 1) = 128 * k + 128) 1:/#.
rewrite memread_add 1,2:/# chunk_cat; first by rewrite size_memread 1:/# dvdz_mulr.
have hne : memread mem (a + 128 * k) 128 <> [] by rewrite -size_eq0 size_memread.
have := chunk_exact (memread mem (a + 128 * k) 128) hne.
rewrite size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

lemma parse_memread0 mem a : parse (memread mem a 0) = [].
proof. by rewrite /parse JWordList.memread0 /chunk /= mkseq0. qed.

(* ------------------------------------------------------------------ *)
(* n blocks from memory                                               *)

lemma sha512_compress_blocks_correct (h0 : W64.t list) (p0 n0 : W64.t) :
  hoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))].
proof.
proc; wp.
while (0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
       W64.to_uint p = W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) /\
       W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
       k = sHA512_K /\
       hwords h = foldl compress h0
         (parse (memread Glob.mem (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n))))).
+ wp.
  ecall (sha512_rounds_a64_correct (hwords h)
           (map be64 (chunk 8 (memread Glob.mem (W64.to_uint p) 128)))).
  while (0 <= i <= 16 /\
         n <> W64.zero /\
         0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
         W64.to_uint p = W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) /\
         W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
         k = sHA512_K /\
         hwords h = foldl compress h0
           (parse (memread Glob.mem (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))) /\
         forall kk, 0 <= kk < i =>
           BArray128.get64 w kk = be64 (memread Glob.mem (W64.to_uint p + 8 * kk) 8)).
  + wp; ecall (bswap64_spec x); auto => /> &hr hi0 hi16 hnz hn0 hnn hp hb hh hk hlt.
    have hp128 : W64.to_uint p{hr} + 128 <= W64.modulus.
    + exact (bound_at (W64.to_uint p0) (W64.to_uint n0) (W64.to_uint p{hr})
               (W64.to_uint n{hr}) W64.modulus (nz_pos n{hr} hnz) hnn hp hb).
    split; first smt().
    move=> kk hk1 hk2; rewrite BArray128.get_set64E 1,2:/#.
    case: (i{hr} = kk) => [<-|ne]; last by apply hk => /#.
    rewrite bswap_load64; congr; congr.
    have hi : 0 <= i{hr} < 16 by smt().
    by rewrite (uint_add8 p{hr} i{hr} hi hp128).
  + auto => />.
  move=> &hr hn0 hnn hp hb hh hnz.
  split.
  + by move=> kk hk1 hk2; smt().
  move=> i0 w0 hnot hi0 hi16 hki.
  have hki16 : forall kk, 0 <= kk < 16 =>
    get64d w0 (8 * kk) = be64 (memread Glob.mem{hr} (W64.to_uint p{hr} + 8 * kk) 8).
  + by move=> kk hk; apply hki; smt().
  have hmw : mwords w0 = map be64 (chunk 8 (memread Glob.mem{hr} (W64.to_uint p{hr}) 128)).
  + apply (eq_from_nth W64.zero).
    + by rewrite /mwords size_map size_iota size_map size_chunk // size_memread.
    move=> kk; rewrite /mwords size_map size_iota => hk'.
    rewrite (nth_map 0) 1:size_iota 1:/# nth_iota 1:/# (nth_map []).
    + by rewrite size_chunk // size_memread /#.
    have hc : 0 <= kk < size (memread Glob.mem{hr} (W64.to_uint p{hr}) 128) %/ 8.
    + by rewrite size_memread /#.
    by rewrite /= (nth_chunk8 _ _ hc) memread_word 1:/# -(hki16 kk) /#.
  split.
  + split; first exact hmw.
    by rewrite size_map size_chunk // size_memread.
  move=> _ _ [h' ms'] /= hh'.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by apply (uint_sub1 n{hr} hnz).
  have hplt : W64.to_uint p{hr} + 128 < W64.modulus.
  + exact (bound_lt (W64.to_uint p0) (W64.to_uint n0) (W64.to_uint p{hr})
             (W64.to_uint n{hr}) W64.modulus (nz_pos n{hr} hnz) hnn hp hb).
  have hadd : W64.to_uint (p{hr} + W64.of_int 128) = W64.to_uint p{hr} + 128.
  + by apply (uint_add128 p{hr} hplt).
  rewrite hsub hh'.
  split.
  + split; first by smt(nz_pos).
    by smt(nz_pos).
  split.
  + by rewrite hadd; smt().
  rewrite (_ : W64.to_uint n0 - (W64.to_uint n{hr} - 1)
               = (W64.to_uint n0 - W64.to_uint n{hr}) + 1) 1:/#.
  by rewrite parse_memreadS 1:/# foldl_rcons hh hp.
auto => />.
move=> &hr hb; split.
+ split; first by smt(W64.to_uint_cmp).
  by rewrite /parse /chunk /= mkseq0.
move=> h1 more0 n1 p1 hnot hn1 hn1n0 hfalse hp1 hh1.
have hn1z : W64.to_uint n1 = 0.
+ have hz : n1 = W64.zero by smt().
  by rewrite hz W64.to_uint0.
by rewrite hh1 hn1z subz0.
qed.

(* Each loop advances a counter towards a bound fixed before it starts. *)
lemma sha512_compress_blocks_ll : islossless M._sha512_compress_blocks.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call sha512_rounds_a64_ll; wp.
  while (0 <= i <= 16) (16 - i).
  + move=> zi; wp; call bswap64_ll; auto => /#.
  auto => /> &hr hne r.
  have hnz : n{hr} <> W64.zero by exact hne.
  rewrite (uint_sub1 n{hr} hnz).
  smt().
by auto => /> n1 h0; apply W64.to_uint_eq; smt(W64.to_uint_cmp).
qed.

lemma sha512_compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha512_compress_blocks_ll (sha512_compress_blocks_correct h0 p0 n0). qed.
