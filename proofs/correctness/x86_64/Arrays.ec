(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Arrays.ec (x86_64)
 * ==================
 *
 * Reads and writes of a byte array at different widths. The model holds
 * every array of the library as a clone of eclib's ByteArray (the
 * BArray<n> theories jasmin2ec writes beside it), and the vector kernels
 * read and write 128-bit and 256-bit words of arrays whose meaning the
 * specification gives in 32-bit or 64-bit words. This file states the
 * relation once, for an arbitrary ByteArray, on the byte-offset forms
 * get<w>d and set<w>d and by bytes (get<w>d_byte, get8_set<w>dE); a proof
 * about a model clones ArrayLanes with `theory A <- BArray<n>`.
 *
 * Lanes of a 128-bit word are written with Vec.p4.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JByte_array.
require import Vec.

abstract theory ArrayLanes.
  clone import ByteArray as A.

  (* ---------------------------------------------------------------- *)
  (* Reads                                                            *)

  lemma get128d_bits32 (t : A.t) i j : 0 <= j < 4 =>
    A.get128d t i \bits32 j = A.get32d t (i + 4 * j).
  proof.
  move=> hj; apply W4u8.wordP => k hk.
  by rewrite W128_bits32_bits8 // A.get128d_byte 1:/# A.get32d_byte // addzA.
  qed.

  lemma get64d_bits32 (t : A.t) i j : 0 <= j < 2 =>
    A.get64d t i \bits32 j = A.get32d t (i + 4 * j).
  proof.
  move=> hj; apply W4u8.wordP => k hk.
  by rewrite W64_bits32_bits8 // A.get64d_byte 1:/# A.get32d_byte // addzA.
  qed.

  (* The 128-bit word i as its four 32-bit words. *)
  lemma get128_p4 (t : A.t) i :
    A.get128 t i = p4 (A.get32 t (4 * i)) (A.get32 t (4 * i + 1))
                      (A.get32 t (4 * i + 2)) (A.get32 t (4 * i + 3)).
  proof.
  apply p4P; rewrite get128d_bits32 //; congr; ring.
  qed.

  (* The same at a byte offset, the form the model's literal offsets
     take after simplification. *)
  lemma get128d_p4 (t : A.t) i :
    A.get128d t i = p4 (A.get32d t i) (A.get32d t (i + 4))
                       (A.get32d t (i + 8)) (A.get32d t (i + 12)).
  proof. by apply p4P; rewrite get128d_bits32. qed.

  (* ---------------------------------------------------------------- *)
  (* A 32-bit read after a 128-bit write                              *)

  lemma get32_set128 (t : A.t) i x k :
    0 <= i => 16 * (i + 1) <= A.size =>
    A.get32 (A.set128 t i x) k
    = if 4 * i <= k < 4 * i + 4 then x \bits32 (k - 4 * i) else A.get32 t k.
  proof.
  move=> hi hs; apply W4u8.wordP => j hj.
  rewrite A.get32d_byte // A.get8_set128dE.
  case: (4 * i <= k < 4 * i + 4) => hk.
  + rewrite W128_bits32_bits8 // ifT 1:/#; congr; ring.
  rewrite A.get32d_byte // ifF //; smt().
  qed.
  lemma get32d_set128d (t : A.t) i x k :
    0 <= i => i + 16 <= A.size => (k - i) %% 4 = 0 =>
    A.get32d (A.set128d t i x) k
    = if i <= k < i + 16 then x \bits32 ((k - i) %/ 4) else A.get32d t k.
  proof.
  move=> hi hs hm; apply W4u8.wordP => j hj.
  rewrite A.get32d_byte // A.get8_set128dE.
  case: (i <= k < i + 16) => hk.
  + by rewrite W128_bits32_bits8 // ifT 1:/#; congr; smt().
  by rewrite A.get32d_byte // ifF //; smt().
  qed.
end ArrayLanes.
