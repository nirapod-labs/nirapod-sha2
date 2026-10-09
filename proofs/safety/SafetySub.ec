(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetySub.ec
 * ============
 *
 * Masks of sub-arrays in the safety model. A call on a window
 * a[o : n] passes get_sub a_init o as the callee's mask and writes the
 * callee's result mask back with set_sub. These lemmas move an
 * initialised range across get_sub, and through set_sub inside and
 * outside the window, for each sub-array theory the models use.
 *)

require import AllCore IntDiv CoreMap List.
from Jasmin require import JWord JUtils.
require import BArray16 BArray32 BArray64 BArray112 BArray128 BArray144 BArray208 BArray256 BArray272 BArray512 BArray784.
require import SBArray112_16 SBArray112_32 SBArray112_64 SBArray144_112 SBArray144_16 SBArray208_128 SBArray208_16 SBArray208_64 SBArray272_16 SBArray272_208 SBArray512_128 SBArray512_64 SBArray784_16 SBArray784_256 SBArray784_512.

(* ------------------------------------------------------------------ *)
lemma sub112_16_get (t : BArray112.t) o x l :
  BArray112.is_init t (o + x) l => 0 <= o => o + 16 <= 112 => 0 <= x => x + l <= 16 =>
  BArray16.is_init (SBArray112_16.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray112_16.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub112_16_set_in (t : BArray112.t) (s : BArray16.t) o x l :
  BArray16.is_init s x l => 0 <= o => o + 16 <= 112 => 0 <= x => x + l <= 16 =>
  BArray112.is_init (SBArray112_16.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray112_16.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub112_16_set_out (t : BArray112.t) (s : BArray16.t) o x l :
  BArray112.is_init t x l => (x + l <= o \/ o + 16 <= x) =>
  BArray112.is_init (SBArray112_16.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray112_16.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub112_32_get (t : BArray112.t) o x l :
  BArray112.is_init t (o + x) l => 0 <= o => o + 32 <= 112 => 0 <= x => x + l <= 32 =>
  BArray32.is_init (SBArray112_32.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray112_32.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub112_32_set_in (t : BArray112.t) (s : BArray32.t) o x l :
  BArray32.is_init s x l => 0 <= o => o + 32 <= 112 => 0 <= x => x + l <= 32 =>
  BArray112.is_init (SBArray112_32.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray112_32.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub112_32_set_out (t : BArray112.t) (s : BArray32.t) o x l :
  BArray112.is_init t x l => (x + l <= o \/ o + 32 <= x) =>
  BArray112.is_init (SBArray112_32.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray112_32.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub112_64_get (t : BArray112.t) o x l :
  BArray112.is_init t (o + x) l => 0 <= o => o + 64 <= 112 => 0 <= x => x + l <= 64 =>
  BArray64.is_init (SBArray112_64.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray112_64.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub112_64_set_in (t : BArray112.t) (s : BArray64.t) o x l :
  BArray64.is_init s x l => 0 <= o => o + 64 <= 112 => 0 <= x => x + l <= 64 =>
  BArray112.is_init (SBArray112_64.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray112_64.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub112_64_set_out (t : BArray112.t) (s : BArray64.t) o x l :
  BArray112.is_init t x l => (x + l <= o \/ o + 64 <= x) =>
  BArray112.is_init (SBArray112_64.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray112_64.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub144_112_get (t : BArray144.t) o x l :
  BArray144.is_init t (o + x) l => 0 <= o => o + 112 <= 144 => 0 <= x => x + l <= 112 =>
  BArray112.is_init (SBArray144_112.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray144_112.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub144_112_set_in (t : BArray144.t) (s : BArray112.t) o x l :
  BArray112.is_init s x l => 0 <= o => o + 112 <= 144 => 0 <= x => x + l <= 112 =>
  BArray144.is_init (SBArray144_112.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray144_112.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub144_112_set_out (t : BArray144.t) (s : BArray112.t) o x l :
  BArray144.is_init t x l => (x + l <= o \/ o + 112 <= x) =>
  BArray144.is_init (SBArray144_112.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray144_112.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub144_16_get (t : BArray144.t) o x l :
  BArray144.is_init t (o + x) l => 0 <= o => o + 16 <= 144 => 0 <= x => x + l <= 16 =>
  BArray16.is_init (SBArray144_16.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray144_16.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub144_16_set_in (t : BArray144.t) (s : BArray16.t) o x l :
  BArray16.is_init s x l => 0 <= o => o + 16 <= 144 => 0 <= x => x + l <= 16 =>
  BArray144.is_init (SBArray144_16.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray144_16.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub144_16_set_out (t : BArray144.t) (s : BArray16.t) o x l :
  BArray144.is_init t x l => (x + l <= o \/ o + 16 <= x) =>
  BArray144.is_init (SBArray144_16.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray144_16.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub208_128_get (t : BArray208.t) o x l :
  BArray208.is_init t (o + x) l => 0 <= o => o + 128 <= 208 => 0 <= x => x + l <= 128 =>
  BArray128.is_init (SBArray208_128.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray208_128.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub208_128_set_in (t : BArray208.t) (s : BArray128.t) o x l :
  BArray128.is_init s x l => 0 <= o => o + 128 <= 208 => 0 <= x => x + l <= 128 =>
  BArray208.is_init (SBArray208_128.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray208_128.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub208_128_set_out (t : BArray208.t) (s : BArray128.t) o x l :
  BArray208.is_init t x l => (x + l <= o \/ o + 128 <= x) =>
  BArray208.is_init (SBArray208_128.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray208_128.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub208_16_get (t : BArray208.t) o x l :
  BArray208.is_init t (o + x) l => 0 <= o => o + 16 <= 208 => 0 <= x => x + l <= 16 =>
  BArray16.is_init (SBArray208_16.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray208_16.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub208_16_set_in (t : BArray208.t) (s : BArray16.t) o x l :
  BArray16.is_init s x l => 0 <= o => o + 16 <= 208 => 0 <= x => x + l <= 16 =>
  BArray208.is_init (SBArray208_16.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray208_16.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub208_16_set_out (t : BArray208.t) (s : BArray16.t) o x l :
  BArray208.is_init t x l => (x + l <= o \/ o + 16 <= x) =>
  BArray208.is_init (SBArray208_16.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray208_16.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub208_64_get (t : BArray208.t) o x l :
  BArray208.is_init t (o + x) l => 0 <= o => o + 64 <= 208 => 0 <= x => x + l <= 64 =>
  BArray64.is_init (SBArray208_64.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray208_64.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub208_64_set_in (t : BArray208.t) (s : BArray64.t) o x l :
  BArray64.is_init s x l => 0 <= o => o + 64 <= 208 => 0 <= x => x + l <= 64 =>
  BArray208.is_init (SBArray208_64.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray208_64.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub208_64_set_out (t : BArray208.t) (s : BArray64.t) o x l :
  BArray208.is_init t x l => (x + l <= o \/ o + 64 <= x) =>
  BArray208.is_init (SBArray208_64.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray208_64.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub272_16_get (t : BArray272.t) o x l :
  BArray272.is_init t (o + x) l => 0 <= o => o + 16 <= 272 => 0 <= x => x + l <= 16 =>
  BArray16.is_init (SBArray272_16.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray272_16.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub272_16_set_in (t : BArray272.t) (s : BArray16.t) o x l :
  BArray16.is_init s x l => 0 <= o => o + 16 <= 272 => 0 <= x => x + l <= 16 =>
  BArray272.is_init (SBArray272_16.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray272_16.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub272_16_set_out (t : BArray272.t) (s : BArray16.t) o x l :
  BArray272.is_init t x l => (x + l <= o \/ o + 16 <= x) =>
  BArray272.is_init (SBArray272_16.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray272_16.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub272_208_get (t : BArray272.t) o x l :
  BArray272.is_init t (o + x) l => 0 <= o => o + 208 <= 272 => 0 <= x => x + l <= 208 =>
  BArray208.is_init (SBArray272_208.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray272_208.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub272_208_set_in (t : BArray272.t) (s : BArray208.t) o x l :
  BArray208.is_init s x l => 0 <= o => o + 208 <= 272 => 0 <= x => x + l <= 208 =>
  BArray272.is_init (SBArray272_208.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray272_208.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub272_208_set_out (t : BArray272.t) (s : BArray208.t) o x l :
  BArray272.is_init t x l => (x + l <= o \/ o + 208 <= x) =>
  BArray272.is_init (SBArray272_208.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray272_208.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub512_128_get (t : BArray512.t) o x l :
  BArray512.is_init t (o + x) l => 0 <= o => o + 128 <= 512 => 0 <= x => x + l <= 128 =>
  BArray128.is_init (SBArray512_128.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray512_128.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub512_128_set_in (t : BArray512.t) (s : BArray128.t) o x l :
  BArray128.is_init s x l => 0 <= o => o + 128 <= 512 => 0 <= x => x + l <= 128 =>
  BArray512.is_init (SBArray512_128.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray512_128.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub512_128_set_out (t : BArray512.t) (s : BArray128.t) o x l :
  BArray512.is_init t x l => (x + l <= o \/ o + 128 <= x) =>
  BArray512.is_init (SBArray512_128.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray512_128.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub512_64_get (t : BArray512.t) o x l :
  BArray512.is_init t (o + x) l => 0 <= o => o + 64 <= 512 => 0 <= x => x + l <= 64 =>
  BArray64.is_init (SBArray512_64.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray512_64.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub512_64_set_in (t : BArray512.t) (s : BArray64.t) o x l :
  BArray64.is_init s x l => 0 <= o => o + 64 <= 512 => 0 <= x => x + l <= 64 =>
  BArray512.is_init (SBArray512_64.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray512_64.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub512_64_set_out (t : BArray512.t) (s : BArray64.t) o x l :
  BArray512.is_init t x l => (x + l <= o \/ o + 64 <= x) =>
  BArray512.is_init (SBArray512_64.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray512_64.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub784_16_get (t : BArray784.t) o x l :
  BArray784.is_init t (o + x) l => 0 <= o => o + 16 <= 784 => 0 <= x => x + l <= 16 =>
  BArray16.is_init (SBArray784_16.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray784_16.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub784_16_set_in (t : BArray784.t) (s : BArray16.t) o x l :
  BArray16.is_init s x l => 0 <= o => o + 16 <= 784 => 0 <= x => x + l <= 16 =>
  BArray784.is_init (SBArray784_16.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray784_16.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub784_16_set_out (t : BArray784.t) (s : BArray16.t) o x l :
  BArray784.is_init t x l => (x + l <= o \/ o + 16 <= x) =>
  BArray784.is_init (SBArray784_16.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray784_16.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub784_256_get (t : BArray784.t) o x l :
  BArray784.is_init t (o + x) l => 0 <= o => o + 256 <= 784 => 0 <= x => x + l <= 256 =>
  BArray256.is_init (SBArray784_256.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray784_256.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub784_256_set_in (t : BArray784.t) (s : BArray256.t) o x l :
  BArray256.is_init s x l => 0 <= o => o + 256 <= 784 => 0 <= x => x + l <= 256 =>
  BArray784.is_init (SBArray784_256.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray784_256.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub784_256_set_out (t : BArray784.t) (s : BArray256.t) o x l :
  BArray784.is_init t x l => (x + l <= o \/ o + 256 <= x) =>
  BArray784.is_init (SBArray784_256.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray784_256.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

(* ------------------------------------------------------------------ *)
lemma sub784_512_get (t : BArray784.t) o x l :
  BArray784.is_init t (o + x) l => 0 <= o => o + 512 <= 784 => 0 <= x => x + l <= 512 =>
  BArray512.is_init (SBArray784_512.get_sub t o) x l.
proof.
move=> ht ho hob hx hxl j hj0 hj; rewrite SBArray784_512.is_init_cell_get 1,2:/#.
by apply ht => /#.
qed.

lemma sub784_512_set_in (t : BArray784.t) (s : BArray512.t) o x l :
  BArray512.is_init s x l => 0 <= o => o + 512 <= 784 => 0 <= x => x + l <= 512 =>
  BArray784.is_init (SBArray784_512.set_sub t o s) (o + x) l.
proof.
move=> hs ho hob hx hxl j hj0 hj; rewrite SBArray784_512.is_init_cell_set.
by rewrite ifT 1:/#; apply hs => /#.
qed.

lemma sub784_512_set_out (t : BArray784.t) (s : BArray512.t) o x l :
  BArray784.is_init t x l => (x + l <= o \/ o + 512 <= x) =>
  BArray784.is_init (SBArray784_512.set_sub t o s) x l.
proof.
move=> ht hout j hj0 hj; rewrite SBArray784_512.is_init_cell_set.
by rewrite ifF 1:/#; apply ht.
qed.

