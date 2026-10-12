(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Mem.ec (x86_64)
 * ===============
 *
 * Caller memory as bytes (JWordList.memread) and its parse into message
 * blocks (section 5.2.1), as the kernels read it: 32-bit loads and
 * 128-bit loads followed by a byte reversal of each 32-bit lane. No model
 * of the library is used.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import Bytes FIPS180_SHA2 WordSpec Vec.
require JWordList.
import SHA256.

abbrev memread = JWordList.memread.

lemma size_memread mem a l : 0 <= l => size (memread mem a l) = l.
proof. exact JWordList.size_memread. qed.

lemma memread_add mem a x y : 0 <= x => 0 <= y =>
  memread mem a (x + y) = memread mem a x ++ memread mem (a + x) y.
proof. exact JWordList.memread_add. qed.

(* The big-endian word at a, as the kernels read it: a little-endian load
   followed by a byte reversal. *)
lemma bswap_load32 mem a :
  bswap32 (loadW32 mem a) = be32 (memread mem a 4).
proof.
rewrite /bswap32 /be32; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W4u8.size_to_list size_memread.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW32_bits8.
qed.

lemma memread_word mem a k : 0 <= k < 16 =>
  take 4 (drop (4 * k) (memread mem a 64)) = memread mem (a + 4 * k) 4.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

lemma nth_chunk4 (bs : W8.t list) k :
  0 <= k < size bs %/ 4 => nth [] (chunk 4 bs) k = take 4 (drop (4 * k) bs).
proof. by move=> hk; rewrite /chunk nth_mkseq. qed.

(* The sixteen words of the block at a. *)
lemma nth_mblock_mem mem a k : 0 <= k < 16 =>
  nth W32.zero (map be32 (chunk 4 (memread mem a 64))) k = bswap32 (loadW32 mem (a + 4 * k)).
proof.
move=> hk; rewrite (nth_map []); first by rewrite size_chunk // size_memread /#.
rewrite nth_chunk4; first by rewrite size_memread /#.
by rewrite memread_word // bswap_load32.
qed.

lemma size_mblock_mem mem a : size (map be32 (chunk 4 (memread mem a 64))) = 16.
proof. by rewrite size_map size_chunk // size_memread. qed.

(* A 128-bit load and PSHUFB with the byte-reversal mask: four words of
   the block, big-endian. *)
lemma vpshufb_load128 mem a :
  VPSHUFB_128 (loadW128 mem a) bswap_mask32
  = p4 (bswap32 (loadW32 mem a)) (bswap32 (loadW32 mem (a + 4)))
       (bswap32 (loadW32 mem (a + 8))) (bswap32 (loadW32 mem (a + 12))).
proof. by rewrite vpshufb_bswap32 !loadW128_bits32. qed.

(* One more block of memory adds one block to the parse. *)
lemma parse_memreadS mem a k : 0 <= k =>
  parse (memread mem a (64 * (k + 1)))
  = rcons (parse (memread mem a (64 * k))) (map be32 (chunk 4 (memread mem (a + 64 * k) 64))).
proof.
move=> hk; rewrite /parse (_ : 64 * (k + 1) = 64 * k + 64) 1:/#.
rewrite memread_add 1,2:/# chunk_cat; first by rewrite size_memread 1:/# dvdz_mulr.
have hne : memread mem (a + 64 * k) 64 <> [] by rewrite -size_eq0 size_memread.
have := chunk_exact (memread mem (a + 64 * k) 64) hne.
rewrite size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

lemma parse_memread0 mem a : parse (memread mem a 0) = [].
proof. by rewrite /parse JWordList.memread0 /chunk /= mkseq0. qed.
