(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Arrays.ec (aarch64)
 * ===================
 *
 * 128-bit reads and writes of the byte arrays of the model, as 32-bit and
 * 64-bit words. The vector kernels move the state and the message through
 * q registers (LDR/STR q, LD1), while the specification and the scalar
 * views read the same bytes as 32-bit or 64-bit words; these lemmas relate
 * the two. Lane j of a 128-bit word read at byte offset o is the word read
 * at o + 4 j (o + 8 j), as the model's byte layout (little-endian lanes)
 * makes it on both architectures.
 *
 * The lemmas are stated once over an abstract byte array (the theory
 * Words, over JByte_array's ByteArray) and proved byte by byte on the
 * byte-offset forms get'Sd and set'Sd. A kernel proof instantiates them
 * for the arrays of its model, for example
 *
 *     clone Arrays.Words as W64 with theory A <= BArray64.
 *
 * which adds no axiom: the array theory's own axioms are those of the
 * model.
 *
 * Model-free: checked once (proofs/Makefile, check-lib).
 *)

require import AllCore IntDiv.
from Jasmin require import JWord JUtils JByte_array.

abstract theory Words.

clone ByteArray as A.

(* Lane j of a 128-bit read. *)
lemma get128d_bits32 (t : A.t) (o j : int) : 0 <= j < 4 =>
  A.get128d t o \bits32 j = A.get32d t (o + 4 * j).
proof.
move=> hj; apply W4u8.wordP => k hk.
rewrite W128_bits32_bits8 // A.get128d_byte 1:/# A.get32d_byte //.
by congr; ring.
qed.

lemma get128d_bits64 (t : A.t) (o j : int) : 0 <= j < 2 =>
  A.get128d t o \bits64 j = A.get64d t (o + 8 * j).
proof.
move=> hj; apply W8u8.wordP => k hk.
rewrite W128_bits64_bits8 // A.get128d_byte 1:/# A.get64d_byte //.
by congr; ring.
qed.

(* A 32-bit (64-bit) read inside a 128-bit write is a lane of the written
   word. *)
lemma get32d_set128d_in (t : A.t) (o j : int) (w : W128.t) :
  0 <= o => o + 16 <= A.size => 0 <= j < 4 =>
  A.get32d (A.set128d t o w) (o + 4 * j) = w \bits32 j.
proof.
move=> ho hs hj; apply W4u8.wordP => k hk.
rewrite A.get32d_byte // A.get8_set128dE W128_bits32_bits8 //.
by rewrite ifT 1:/#; congr; ring.
qed.

lemma get64d_set128d_in (t : A.t) (o j : int) (w : W128.t) :
  0 <= o => o + 16 <= A.size => 0 <= j < 2 =>
  A.get64d (A.set128d t o w) (o + 8 * j) = w \bits64 j.
proof.
move=> ho hs hj; apply W8u8.wordP => k hk.
rewrite A.get64d_byte // A.get8_set128dE W128_bits64_bits8 //.
by rewrite ifT 1:/#; congr; ring.
qed.

(* A read disjoint from a 128-bit write is unchanged. *)
lemma get32d_set128d_out (t : A.t) (o o' : int) (w : W128.t) :
  o' + 4 <= o \/ o + 16 <= o' =>
  A.get32d (A.set128d t o w) o' = A.get32d t o'.
proof.
move=> ho; apply W4u8.wordP => k hk.
by rewrite !A.get32d_byte // A.get8_set128dE ifF 1:/#.
qed.

lemma get64d_set128d_out (t : A.t) (o o' : int) (w : W128.t) :
  o' + 8 <= o \/ o + 16 <= o' =>
  A.get64d (A.set128d t o w) o' = A.get64d t o'.
proof.
move=> ho; apply W8u8.wordP => k hk.
by rewrite !A.get64d_byte // A.get8_set128dE ifF 1:/#.
qed.

end Words.
