(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetySha256.ec
 * ===============
 *
 * Safety of the streaming and one-shot SHA-224 and SHA-256 of
 * src/sha256.jinc and src/sha256_DSIZE.jinc: initial values, absorb,
 * padding and output for both digest sizes, one-shot hashing. The unit's
 * SHA-256 kernel enters through SafetyK256.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK256.
require import BArray28 BArray32 BArray64 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Initial values                                                     *)

lemma __sha256_init_proof _h _h_init : __sha256_init_spec _h _h_init.
proof.
rewrite /__sha256_init_spec; proc.
while (valid trace___sha256_init /\ i_init /\ 0 <= i <= 8 /\ iv_init = full32
       /\ BArray32.is_init h_init 0 (4 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask32_set32 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full32_init hm /=; smt().
auto => />; split; 1: by move=> j /#.
by move=> hi0 i0 tr0 hlt _ _ hi8 hh; have <- : 4 * i0 = 32 by smt().
qed.

lemma __sha224_init_proof _h _h_init : __sha224_init_spec _h _h_init.
proof.
rewrite /__sha224_init_spec; proc.
while (valid trace___sha224_init /\ i_init /\ 0 <= i <= 8 /\ iv_init = full32
       /\ BArray32.is_init h_init 0 (4 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask32_set32 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full32_init hm /=; smt().
auto => />; split; 1: by move=> j /#.
by move=> hi0 i0 tr0 hlt _ _ hi8 hh; have <- : 4 * i0 = 32 by smt().
qed.

