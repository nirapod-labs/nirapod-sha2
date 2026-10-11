(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Mem512.ec (x86_64)
 * ==================
 *
 * SHA-512 message blocks (FIPS 180-4 section 5.2.2) as the AVX2 kernel
 * reads them from caller memory (JWordList.memread): sixteen 64-bit words
 * each, big-endian, and the parse of memory into 128-byte blocks. No model
 * of the library is used.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import Bytes FIPS180_SHA2.
require JWordList WordSpec.
import SHA512.

lemma nth_chunk8 (bs : W8.t list) k :
  0 <= k < size bs %/ 8 => nth [] (chunk 8 bs) k = take 8 (drop (8 * k) bs).
proof. by move=> hk; rewrite /chunk nth_mkseq. qed.

(* The big-endian word at a: a little-endian load and a byte reversal. *)
lemma bswap_load64 mem a :
  WordSpec.bswap64 (loadW64 mem a) = be64 (JWordList.memread mem a 8).
proof.
rewrite /WordSpec.bswap64 /be64; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W8u8.size_to_list JWordList.size_memread.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW64_bits8.
qed.

lemma memread_word64 mem a k : 0 <= k < 16 =>
  take 8 (drop (8 * k) (JWordList.memread mem a 128)) = JWordList.memread mem (a + 8 * k) 8.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

(* Word k of the block at a. *)
lemma nth_mblock512_mem mem a k : 0 <= k < 16 =>
  nth W64.zero (map be64 (chunk 8 (JWordList.memread mem a 128))) k
  = WordSpec.bswap64 (loadW64 mem (a + 8 * k)).
proof.
move=> hk; rewrite (nth_map []); first by rewrite size_chunk // JWordList.size_memread /#.
rewrite nth_chunk8; first by rewrite JWordList.size_memread /#.
by rewrite memread_word64 // bswap_load64.
qed.

lemma size_mblock512_mem mem a : size (map be64 (chunk 8 (JWordList.memread mem a 128))) = 16.
proof. by rewrite size_map size_chunk // JWordList.size_memread. qed.

(* One more block of memory adds one block to the parse. *)
lemma parse512_memreadS mem a k : 0 <= k =>
  parse (JWordList.memread mem a (128 * (k + 1)))
  = rcons (parse (JWordList.memread mem a (128 * k)))
          (map be64 (chunk 8 (JWordList.memread mem (a + 128 * k) 128))).
proof.
move=> hk; rewrite /parse (_ : 128 * (k + 1) = 128 * k + 128) 1:/#.
rewrite JWordList.memread_add 1,2:/# chunk_cat; first by rewrite JWordList.size_memread 1:/# dvdz_mulr.
have hne : JWordList.memread mem (a + 128 * k) 128 <> [] by rewrite -size_eq0 JWordList.size_memread.
have := chunk_exact (JWordList.memread mem (a + 128 * k) 128) hne.
rewrite JWordList.size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

lemma parse512_memread0 mem a : parse (JWordList.memread mem a 0) = [].
proof. by rewrite /parse JWordList.memread0 /chunk /= mkseq0. qed.
