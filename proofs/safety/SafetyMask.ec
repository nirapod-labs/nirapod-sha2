(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyMask.ec
 * =============
 *
 * Initialisation masks of the safety model. Every array a of a procedure
 * has a byte mask a_init, 0xFF where a is initialised. A mask that is
 * initialised everywhere is the constant full mask fullN, and writing
 * initialised words into it leaves it unchanged, so a proof can keep a
 * fully initialised array's mask as an equation rather than a range.
 *)

require import AllCore IntDiv CoreMap List.
from Jasmin require import JWord JUtils.
require import BArray16 BArray28 BArray32 BArray48 BArray64 BArray112 BArray128 BArray144 BArray208 BArray256 BArray272 BArray512 BArray640 BArray784.

(* ------------------------------------------------------------------ *)
abbrev full16 = BArray16.init_arr (W8.of_int 255).

lemma full16E (m : BArray16.t) : BArray16.is_init m 0 16 => m = full16.
proof.
move=> hm; rewrite BArray16.tP => j hj.
rewrite /BArray16.init_arr BArray16.initiE //=.
by have := hm j _ _; rewrite /BArray16.is_init_cell /#.
qed.

lemma full16_init a l : BArray16.is_init full16 a l.
proof. by move=> j _ _; apply (BArray16.init_arrP witness). qed.

lemma mask16_le (m : BArray16.t) a b : BArray16.is_init m 0 b => a <= b => BArray16.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full16_set32d k : BArray16.set32d full16 k (W32.of_int 4294967295) = full16.
proof.
apply full16E => j _ _.
by rewrite BArray16.is_init_cell_set32d; right; apply (BArray16.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask16_set32 (m : BArray16.t) i :
  BArray16.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 16 =>
  BArray16.is_init (BArray16.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray16.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full16_set64d k : BArray16.set64d full16 k (W64.of_int 18446744073709551615) = full16.
proof.
apply full16E => j _ _.
by rewrite BArray16.is_init_cell_set64d; right; apply (BArray16.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask16_set64 (m : BArray16.t) i :
  BArray16.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 16 =>
  BArray16.is_init (BArray16.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray16.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full16_set8 k : BArray16.set8 full16 k (W8.of_int 255) = full16.
proof.
apply full16E => j hj0 hj1.
rewrite BArray16.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray16.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full28 = BArray28.init_arr (W8.of_int 255).

lemma full28E (m : BArray28.t) : BArray28.is_init m 0 28 => m = full28.
proof.
move=> hm; rewrite BArray28.tP => j hj.
rewrite /BArray28.init_arr BArray28.initiE //=.
by have := hm j _ _; rewrite /BArray28.is_init_cell /#.
qed.

lemma full28_init a l : BArray28.is_init full28 a l.
proof. by move=> j _ _; apply (BArray28.init_arrP witness). qed.

lemma mask28_le (m : BArray28.t) a b : BArray28.is_init m 0 b => a <= b => BArray28.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full28_set32d k : BArray28.set32d full28 k (W32.of_int 4294967295) = full28.
proof.
apply full28E => j _ _.
by rewrite BArray28.is_init_cell_set32d; right; apply (BArray28.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask28_set32 (m : BArray28.t) i :
  BArray28.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 28 =>
  BArray28.is_init (BArray28.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray28.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma mask28_set64 (m : BArray28.t) i :
  BArray28.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 28 =>
  BArray28.is_init (BArray28.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray28.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full28_set8 k : BArray28.set8 full28 k (W8.of_int 255) = full28.
proof.
apply full28E => j hj0 hj1.
rewrite BArray28.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray28.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full32 = BArray32.init_arr (W8.of_int 255).

lemma full32E (m : BArray32.t) : BArray32.is_init m 0 32 => m = full32.
proof.
move=> hm; rewrite BArray32.tP => j hj.
rewrite /BArray32.init_arr BArray32.initiE //=.
by have := hm j _ _; rewrite /BArray32.is_init_cell /#.
qed.

lemma full32_init a l : BArray32.is_init full32 a l.
proof. by move=> j _ _; apply (BArray32.init_arrP witness). qed.

lemma mask32_le (m : BArray32.t) a b : BArray32.is_init m 0 b => a <= b => BArray32.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full32_set32d k : BArray32.set32d full32 k (W32.of_int 4294967295) = full32.
proof.
apply full32E => j _ _.
by rewrite BArray32.is_init_cell_set32d; right; apply (BArray32.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask32_set32 (m : BArray32.t) i :
  BArray32.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 32 =>
  BArray32.is_init (BArray32.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray32.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full32_set64d k : BArray32.set64d full32 k (W64.of_int 18446744073709551615) = full32.
proof.
apply full32E => j _ _.
by rewrite BArray32.is_init_cell_set64d; right; apply (BArray32.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask32_set64 (m : BArray32.t) i :
  BArray32.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 32 =>
  BArray32.is_init (BArray32.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray32.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full32_set8 k : BArray32.set8 full32 k (W8.of_int 255) = full32.
proof.
apply full32E => j hj0 hj1.
rewrite BArray32.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray32.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full48 = BArray48.init_arr (W8.of_int 255).

lemma full48E (m : BArray48.t) : BArray48.is_init m 0 48 => m = full48.
proof.
move=> hm; rewrite BArray48.tP => j hj.
rewrite /BArray48.init_arr BArray48.initiE //=.
by have := hm j _ _; rewrite /BArray48.is_init_cell /#.
qed.

lemma full48_init a l : BArray48.is_init full48 a l.
proof. by move=> j _ _; apply (BArray48.init_arrP witness). qed.

lemma mask48_le (m : BArray48.t) a b : BArray48.is_init m 0 b => a <= b => BArray48.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full48_set32d k : BArray48.set32d full48 k (W32.of_int 4294967295) = full48.
proof.
apply full48E => j _ _.
by rewrite BArray48.is_init_cell_set32d; right; apply (BArray48.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask48_set32 (m : BArray48.t) i :
  BArray48.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 48 =>
  BArray48.is_init (BArray48.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray48.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full48_set64d k : BArray48.set64d full48 k (W64.of_int 18446744073709551615) = full48.
proof.
apply full48E => j _ _.
by rewrite BArray48.is_init_cell_set64d; right; apply (BArray48.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask48_set64 (m : BArray48.t) i :
  BArray48.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 48 =>
  BArray48.is_init (BArray48.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray48.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full48_set8 k : BArray48.set8 full48 k (W8.of_int 255) = full48.
proof.
apply full48E => j hj0 hj1.
rewrite BArray48.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray48.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full64 = BArray64.init_arr (W8.of_int 255).

lemma full64E (m : BArray64.t) : BArray64.is_init m 0 64 => m = full64.
proof.
move=> hm; rewrite BArray64.tP => j hj.
rewrite /BArray64.init_arr BArray64.initiE //=.
by have := hm j _ _; rewrite /BArray64.is_init_cell /#.
qed.

lemma full64_init a l : BArray64.is_init full64 a l.
proof. by move=> j _ _; apply (BArray64.init_arrP witness). qed.

lemma mask64_le (m : BArray64.t) a b : BArray64.is_init m 0 b => a <= b => BArray64.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full64_set32d k : BArray64.set32d full64 k (W32.of_int 4294967295) = full64.
proof.
apply full64E => j _ _.
by rewrite BArray64.is_init_cell_set32d; right; apply (BArray64.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask64_set32 (m : BArray64.t) i :
  BArray64.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 64 =>
  BArray64.is_init (BArray64.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray64.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full64_set64d k : BArray64.set64d full64 k (W64.of_int 18446744073709551615) = full64.
proof.
apply full64E => j _ _.
by rewrite BArray64.is_init_cell_set64d; right; apply (BArray64.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask64_set64 (m : BArray64.t) i :
  BArray64.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 64 =>
  BArray64.is_init (BArray64.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray64.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full64_set8 k : BArray64.set8 full64 k (W8.of_int 255) = full64.
proof.
apply full64E => j hj0 hj1.
rewrite BArray64.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray64.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full112 = BArray112.init_arr (W8.of_int 255).

lemma full112E (m : BArray112.t) : BArray112.is_init m 0 112 => m = full112.
proof.
move=> hm; rewrite BArray112.tP => j hj.
rewrite /BArray112.init_arr BArray112.initiE //=.
by have := hm j _ _; rewrite /BArray112.is_init_cell /#.
qed.

lemma full112_init a l : BArray112.is_init full112 a l.
proof. by move=> j _ _; apply (BArray112.init_arrP witness). qed.

lemma mask112_le (m : BArray112.t) a b : BArray112.is_init m 0 b => a <= b => BArray112.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full112_set32d k : BArray112.set32d full112 k (W32.of_int 4294967295) = full112.
proof.
apply full112E => j _ _.
by rewrite BArray112.is_init_cell_set32d; right; apply (BArray112.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask112_set32 (m : BArray112.t) i :
  BArray112.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 112 =>
  BArray112.is_init (BArray112.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray112.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full112_set64d k : BArray112.set64d full112 k (W64.of_int 18446744073709551615) = full112.
proof.
apply full112E => j _ _.
by rewrite BArray112.is_init_cell_set64d; right; apply (BArray112.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask112_set64 (m : BArray112.t) i :
  BArray112.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 112 =>
  BArray112.is_init (BArray112.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray112.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full112_set8 k : BArray112.set8 full112 k (W8.of_int 255) = full112.
proof.
apply full112E => j hj0 hj1.
rewrite BArray112.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray112.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full128 = BArray128.init_arr (W8.of_int 255).

lemma full128E (m : BArray128.t) : BArray128.is_init m 0 128 => m = full128.
proof.
move=> hm; rewrite BArray128.tP => j hj.
rewrite /BArray128.init_arr BArray128.initiE //=.
by have := hm j _ _; rewrite /BArray128.is_init_cell /#.
qed.

lemma full128_init a l : BArray128.is_init full128 a l.
proof. by move=> j _ _; apply (BArray128.init_arrP witness). qed.

lemma mask128_le (m : BArray128.t) a b : BArray128.is_init m 0 b => a <= b => BArray128.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full128_set32d k : BArray128.set32d full128 k (W32.of_int 4294967295) = full128.
proof.
apply full128E => j _ _.
by rewrite BArray128.is_init_cell_set32d; right; apply (BArray128.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask128_set32 (m : BArray128.t) i :
  BArray128.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 128 =>
  BArray128.is_init (BArray128.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray128.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full128_set64d k : BArray128.set64d full128 k (W64.of_int 18446744073709551615) = full128.
proof.
apply full128E => j _ _.
by rewrite BArray128.is_init_cell_set64d; right; apply (BArray128.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask128_set64 (m : BArray128.t) i :
  BArray128.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 128 =>
  BArray128.is_init (BArray128.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray128.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full128_set8 k : BArray128.set8 full128 k (W8.of_int 255) = full128.
proof.
apply full128E => j hj0 hj1.
rewrite BArray128.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray128.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full144 = BArray144.init_arr (W8.of_int 255).

lemma full144E (m : BArray144.t) : BArray144.is_init m 0 144 => m = full144.
proof.
move=> hm; rewrite BArray144.tP => j hj.
rewrite /BArray144.init_arr BArray144.initiE //=.
by have := hm j _ _; rewrite /BArray144.is_init_cell /#.
qed.

lemma full144_init a l : BArray144.is_init full144 a l.
proof. by move=> j _ _; apply (BArray144.init_arrP witness). qed.

lemma mask144_le (m : BArray144.t) a b : BArray144.is_init m 0 b => a <= b => BArray144.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full144_set32d k : BArray144.set32d full144 k (W32.of_int 4294967295) = full144.
proof.
apply full144E => j _ _.
by rewrite BArray144.is_init_cell_set32d; right; apply (BArray144.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask144_set32 (m : BArray144.t) i :
  BArray144.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 144 =>
  BArray144.is_init (BArray144.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray144.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full144_set64d k : BArray144.set64d full144 k (W64.of_int 18446744073709551615) = full144.
proof.
apply full144E => j _ _.
by rewrite BArray144.is_init_cell_set64d; right; apply (BArray144.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask144_set64 (m : BArray144.t) i :
  BArray144.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 144 =>
  BArray144.is_init (BArray144.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray144.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full144_set8 k : BArray144.set8 full144 k (W8.of_int 255) = full144.
proof.
apply full144E => j hj0 hj1.
rewrite BArray144.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray144.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full208 = BArray208.init_arr (W8.of_int 255).

lemma full208E (m : BArray208.t) : BArray208.is_init m 0 208 => m = full208.
proof.
move=> hm; rewrite BArray208.tP => j hj.
rewrite /BArray208.init_arr BArray208.initiE //=.
by have := hm j _ _; rewrite /BArray208.is_init_cell /#.
qed.

lemma full208_init a l : BArray208.is_init full208 a l.
proof. by move=> j _ _; apply (BArray208.init_arrP witness). qed.

lemma mask208_le (m : BArray208.t) a b : BArray208.is_init m 0 b => a <= b => BArray208.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full208_set32d k : BArray208.set32d full208 k (W32.of_int 4294967295) = full208.
proof.
apply full208E => j _ _.
by rewrite BArray208.is_init_cell_set32d; right; apply (BArray208.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask208_set32 (m : BArray208.t) i :
  BArray208.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 208 =>
  BArray208.is_init (BArray208.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray208.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full208_set64d k : BArray208.set64d full208 k (W64.of_int 18446744073709551615) = full208.
proof.
apply full208E => j _ _.
by rewrite BArray208.is_init_cell_set64d; right; apply (BArray208.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask208_set64 (m : BArray208.t) i :
  BArray208.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 208 =>
  BArray208.is_init (BArray208.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray208.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full208_set8 k : BArray208.set8 full208 k (W8.of_int 255) = full208.
proof.
apply full208E => j hj0 hj1.
rewrite BArray208.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray208.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full256 = BArray256.init_arr (W8.of_int 255).

lemma full256E (m : BArray256.t) : BArray256.is_init m 0 256 => m = full256.
proof.
move=> hm; rewrite BArray256.tP => j hj.
rewrite /BArray256.init_arr BArray256.initiE //=.
by have := hm j _ _; rewrite /BArray256.is_init_cell /#.
qed.

lemma full256_init a l : BArray256.is_init full256 a l.
proof. by move=> j _ _; apply (BArray256.init_arrP witness). qed.

lemma mask256_le (m : BArray256.t) a b : BArray256.is_init m 0 b => a <= b => BArray256.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full256_set32d k : BArray256.set32d full256 k (W32.of_int 4294967295) = full256.
proof.
apply full256E => j _ _.
by rewrite BArray256.is_init_cell_set32d; right; apply (BArray256.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask256_set32 (m : BArray256.t) i :
  BArray256.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 256 =>
  BArray256.is_init (BArray256.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray256.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full256_set64d k : BArray256.set64d full256 k (W64.of_int 18446744073709551615) = full256.
proof.
apply full256E => j _ _.
by rewrite BArray256.is_init_cell_set64d; right; apply (BArray256.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask256_set64 (m : BArray256.t) i :
  BArray256.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 256 =>
  BArray256.is_init (BArray256.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray256.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full256_set8 k : BArray256.set8 full256 k (W8.of_int 255) = full256.
proof.
apply full256E => j hj0 hj1.
rewrite BArray256.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray256.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full272 = BArray272.init_arr (W8.of_int 255).

lemma full272E (m : BArray272.t) : BArray272.is_init m 0 272 => m = full272.
proof.
move=> hm; rewrite BArray272.tP => j hj.
rewrite /BArray272.init_arr BArray272.initiE //=.
by have := hm j _ _; rewrite /BArray272.is_init_cell /#.
qed.

lemma full272_init a l : BArray272.is_init full272 a l.
proof. by move=> j _ _; apply (BArray272.init_arrP witness). qed.

lemma mask272_le (m : BArray272.t) a b : BArray272.is_init m 0 b => a <= b => BArray272.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full272_set32d k : BArray272.set32d full272 k (W32.of_int 4294967295) = full272.
proof.
apply full272E => j _ _.
by rewrite BArray272.is_init_cell_set32d; right; apply (BArray272.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask272_set32 (m : BArray272.t) i :
  BArray272.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 272 =>
  BArray272.is_init (BArray272.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray272.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full272_set64d k : BArray272.set64d full272 k (W64.of_int 18446744073709551615) = full272.
proof.
apply full272E => j _ _.
by rewrite BArray272.is_init_cell_set64d; right; apply (BArray272.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask272_set64 (m : BArray272.t) i :
  BArray272.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 272 =>
  BArray272.is_init (BArray272.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray272.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full272_set8 k : BArray272.set8 full272 k (W8.of_int 255) = full272.
proof.
apply full272E => j hj0 hj1.
rewrite BArray272.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray272.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full512 = BArray512.init_arr (W8.of_int 255).

lemma full512E (m : BArray512.t) : BArray512.is_init m 0 512 => m = full512.
proof.
move=> hm; rewrite BArray512.tP => j hj.
rewrite /BArray512.init_arr BArray512.initiE //=.
by have := hm j _ _; rewrite /BArray512.is_init_cell /#.
qed.

lemma full512_init a l : BArray512.is_init full512 a l.
proof. by move=> j _ _; apply (BArray512.init_arrP witness). qed.

lemma mask512_le (m : BArray512.t) a b : BArray512.is_init m 0 b => a <= b => BArray512.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full512_set32d k : BArray512.set32d full512 k (W32.of_int 4294967295) = full512.
proof.
apply full512E => j _ _.
by rewrite BArray512.is_init_cell_set32d; right; apply (BArray512.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask512_set32 (m : BArray512.t) i :
  BArray512.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 512 =>
  BArray512.is_init (BArray512.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray512.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full512_set64d k : BArray512.set64d full512 k (W64.of_int 18446744073709551615) = full512.
proof.
apply full512E => j _ _.
by rewrite BArray512.is_init_cell_set64d; right; apply (BArray512.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask512_set64 (m : BArray512.t) i :
  BArray512.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 512 =>
  BArray512.is_init (BArray512.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray512.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full512_set8 k : BArray512.set8 full512 k (W8.of_int 255) = full512.
proof.
apply full512E => j hj0 hj1.
rewrite BArray512.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray512.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full640 = BArray640.init_arr (W8.of_int 255).

lemma full640E (m : BArray640.t) : BArray640.is_init m 0 640 => m = full640.
proof.
move=> hm; rewrite BArray640.tP => j hj.
rewrite /BArray640.init_arr BArray640.initiE //=.
by have := hm j _ _; rewrite /BArray640.is_init_cell /#.
qed.

lemma full640_init a l : BArray640.is_init full640 a l.
proof. by move=> j _ _; apply (BArray640.init_arrP witness). qed.

lemma mask640_le (m : BArray640.t) a b : BArray640.is_init m 0 b => a <= b => BArray640.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full640_set32d k : BArray640.set32d full640 k (W32.of_int 4294967295) = full640.
proof.
apply full640E => j _ _.
by rewrite BArray640.is_init_cell_set32d; right; apply (BArray640.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask640_set32 (m : BArray640.t) i :
  BArray640.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 640 =>
  BArray640.is_init (BArray640.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray640.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full640_set64d k : BArray640.set64d full640 k (W64.of_int 18446744073709551615) = full640.
proof.
apply full640E => j _ _.
by rewrite BArray640.is_init_cell_set64d; right; apply (BArray640.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask640_set64 (m : BArray640.t) i :
  BArray640.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 640 =>
  BArray640.is_init (BArray640.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray640.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full640_set8 k : BArray640.set8 full640 k (W8.of_int 255) = full640.
proof.
apply full640E => j hj0 hj1.
rewrite BArray640.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray640.initiE /#.
qed.

(* ------------------------------------------------------------------ *)
abbrev full784 = BArray784.init_arr (W8.of_int 255).

lemma full784E (m : BArray784.t) : BArray784.is_init m 0 784 => m = full784.
proof.
move=> hm; rewrite BArray784.tP => j hj.
rewrite /BArray784.init_arr BArray784.initiE //=.
by have := hm j _ _; rewrite /BArray784.is_init_cell /#.
qed.

lemma full784_init a l : BArray784.is_init full784 a l.
proof. by move=> j _ _; apply (BArray784.init_arrP witness). qed.

lemma mask784_le (m : BArray784.t) a b : BArray784.is_init m 0 b => a <= b => BArray784.is_init m 0 a.
proof. by move=> hm hab j hj0 hj; apply hm => /#. qed.

lemma full784_set32d k : BArray784.set32d full784 k (W32.of_int 4294967295) = full784.
proof.
apply full784E => j _ _.
by rewrite BArray784.is_init_cell_set32d; right; apply (BArray784.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask784_set32 (m : BArray784.t) i :
  BArray784.is_init m 0 (4 * i) => 0 <= i => 4 * (i + 1) <= 784 =>
  BArray784.is_init (BArray784.set32 m i (W32.of_int 4294967295)) 0 (4 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray784.is_init_cell_set32d.
by case: (j < 4 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full784_set64d k : BArray784.set64d full784 k (W64.of_int 18446744073709551615) = full784.
proof.
apply full784E => j _ _.
by rewrite BArray784.is_init_cell_set64d; right; apply (BArray784.init_arrP witness).
qed.

(* Word i written into a mask initialised below word i. *)
lemma mask784_set64 (m : BArray784.t) i :
  BArray784.is_init m 0 (8 * i) => 0 <= i => 8 * (i + 1) <= 784 =>
  BArray784.is_init (BArray784.set64 m i (W64.of_int 18446744073709551615)) 0 (8 * (i + 1)).
proof.
move=> hm hi hb j hj0 hj; rewrite BArray784.is_init_cell_set64d.
by case: (j < 8 * i) => hji; [right; apply hm | left] => /#.
qed.

lemma full784_set8 k : BArray784.set8 full784 k (W8.of_int 255) = full784.
proof.
apply full784E => j hj0 hj1.
rewrite BArray784.is_init_cellP; case: (_ /\ _) => // _.
by rewrite BArray784.initiE /#.
qed.

