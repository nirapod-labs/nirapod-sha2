(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Valid.ec (x86_64)
 * =================
 *
 * Valid memory ranges (JMemory.is_valid over Glob.mem_v) as the kernels
 * read caller memory: sub-ranges of a valid range, and the step from n
 * blocks at p to one block at p and n - 1 blocks at p + 64 (or + 128).
 *)

require import AllCore IntDiv CoreMap List.
from Jasmin require import JWord JUtils JMemory JModel_x86.

lemma valid_sub mv (p : W64.t) (n o l : int) :
  is_valid ptr_modulus mv (W64.to_uint p) n => 0 <= o => 0 <= l => o + l <= n =>
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int o)) l.
proof.
move=> hval ho hl hol; have := hval; rewrite /is_valid => -[hv [h0 hb]].
have hlt : W64.to_uint p + o < W64.modulus by move: hb hol hl; clear hv hval; smt().
have -> : W64.to_uint (p + W64.of_int o) = W64.to_uint p + o.
+ rewrite W64.to_uintD_small W64.to_uint_small //; move: hlt ho; clear hv hval; smt(W64.to_uint_cmp).
split; 1: by move=> j hj; apply hv; move: hj ho hol hl; clear hv hval; smt().
by move: h0 hb ho hol hl; clear hv hval; smt().
qed.

lemma valid_step (b : int) mv (p n : W64.t) : 0 <= b =>
  is_valid ptr_modulus mv (W64.to_uint p) (b * W64.to_uint n) => n <> W64.zero =>
  is_valid ptr_modulus mv (W64.to_uint p) b /\
  is_valid ptr_modulus mv (W64.to_uint (p + W64.of_int b)) (b * W64.to_uint (n - W64.one)).
proof.
move=> hb0 hval hn.
have hn1 : 1 <= W64.to_uint n.
+ have hc := W64.to_uint_cmp n.
  have : W64.to_uint n <> 0.
  + by move: hn; apply contra => h; rewrite W64.to_uint_eq h.
  by move: hc; clear hval; smt().
have -> : W64.to_uint (n - W64.one) = W64.to_uint n - 1.
+ by rewrite W64.to_uintB ?W64.uleE W64.to_uint1.
split.
+ have := hval; rewrite is_validP => h; apply h; move: hn1 hb0; clear h hval; smt().
by apply (valid_sub _ _ _ _ _ hval); move: hn1 hb0; clear hval; smt().
qed.
