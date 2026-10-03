(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Masks.ec (x86_64)
 * =================
 *
 * Initialisation masks of the safety model. jasmin2ec -m safety carries,
 * beside every array a, a byte array a_init of the same size whose byte
 * is 0xff where a is initialised; a write of w bits sets the written bytes
 * to 0xff. The vector kernels keep their arrays fully initialised, so
 * their proofs reason about the full mask only: it is initialised on every
 * range and every write leaves it unchanged. Stated once for an arbitrary
 * ByteArray; a proof about a model clones Masks with
 * `theory A <- BArray<n>`.
 *)

require import AllCore IntDiv.
from Jasmin require import JWord JUtils JByte_array.

abstract theory Masks.
  clone import ByteArray as A.

  abbrev full = A.init_arr (W8.of_int 255).

  lemma full_init a l : A.is_init full a l.
  proof. by move=> j _ _; apply (A.init_arrP witness). qed.

  (* An initialised range is initialised on every sub-range. *)
  lemma is_init_sub (m : A.t) a l b k :
    a <= b => b + k <= a + l => A.is_init m a l => A.is_init m b k.
  proof. by move=> h1 h2 hm j hj1 hj2; apply hm => /#. qed.

  lemma is_init_full (m : A.t) : A.is_init m 0 A.size => m = full.
  proof.
  move=> hm; rewrite A.tP => j hj.
  rewrite /A.init_arr A.initiE //=.
  by have := hm j _ _; rewrite /A.is_init_cell /#.
  qed.

  lemma full_set32d k : A.set32d full k (W32.of_int 4294967295) = full.
  proof.
  by apply is_init_full => j _ _; rewrite A.is_init_cell_set32d; right; apply (A.init_arrP witness).
  qed.

  lemma full_set64d k : A.set64d full k (W64.of_int 18446744073709551615) = full.
  proof.
  by apply is_init_full => j _ _; rewrite A.is_init_cell_set64d; right; apply (A.init_arrP witness).
  qed.

  lemma full_set128d k :
    A.set128d full k (W128.of_int 340282366920938463463374607431768211455) = full.
  proof.
  by apply is_init_full => j _ _; rewrite A.is_init_cell_set128d; right; apply (A.init_arrP witness).
  qed.

  lemma full_set256d k :
    A.set256d full k (W256.of_int 115792089237316195423570985008687907853269984665640564039457584007913129639935) = full.
  proof.
  by apply is_init_full => j _ _; rewrite A.is_init_cell_set256d; right; apply (A.init_arrP witness).
  qed.
  (* A 128-bit write of the all-ones word, as the model makes it for every
     128-bit store. *)
  abbrev ones128 = W128.of_int 340282366920938463463374607431768211455.

  lemma set128d_keep (m : A.t) i a l :
    A.is_init m a l => A.is_init (A.set128d m i ones128) a l.
  proof. by move=> hm j hj1 hj2; rewrite A.is_init_cell_set128d; right; apply hm. qed.

  lemma set128d_here (m : A.t) i : A.is_init (A.set128d m i ones128) i 16.
  proof. by move=> j hj1 hj2; rewrite A.is_init_cell_set128d; left. qed.

  lemma set128d_ext (m : A.t) i a :
    a <= i => A.is_init m a (i - a) => A.is_init (A.set128d m i ones128) a (i - a + 16).
  proof.
  move=> ha hm j hj1 hj2; rewrite A.is_init_cell_set128d.
  by case: (j < i) => hj; [right; apply hm | left] => /#.
  qed.

  lemma set128d_ext0 (m : A.t) i :
    0 <= i => A.is_init m 0 i => A.is_init (A.set128d m i ones128) 0 (i + 16).
  proof. by move=> hi hm; have /= := set128d_ext m i 0 hi; apply. qed.
end Masks.
