(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * State.ec
 * ========
 *
 * The chaining value of each hash as the shared layers read it: the eight
 * words of FIPS 180-4 section 6.2.2 (6.4.2 for SHA-512), H(i)_0 to H(i)_7,
 * stored in order in a u32[8] (u64[8]) array, in native word order. Every
 * kernel keeps its state in this layout at its entry points, whatever it
 * does inside, so the layers above the kernels are stated against these
 * two views only.
 *)

require import AllCore List.
from Jasmin require import JWord.
require import BArray32 BArray64.

op h256 (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).
op h512 (h : BArray64.t) : W64.t list = map (BArray64.get64 h) (iota_ 0 8).

lemma size_h256 h : size (h256 h) = 8.
proof. by rewrite /h256 size_map size_iota. qed.

lemma size_h512 h : size (h512 h) = 8.
proof. by rewrite /h512 size_map size_iota. qed.

lemma nth_h256 h k : 0 <= k < 8 => nth W32.zero (h256 h) k = BArray32.get32 h k.
proof. by move=> hk; rewrite /h256 (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma nth_h512 h k : 0 <= k < 8 => nth W64.zero (h512 h) k = BArray64.get64 h k.
proof. by move=> hk; rewrite /h512 (nth_map 0) 1:size_iota 1:/# nth_iota. qed.
