(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Bmi.ec (x86_64)
 * ===============
 *
 * The scalar round arithmetic of the AVX2 kernels (BMI1 ANDN, BMI2 RORX)
 * against the functions of FIPS 180-4 section 4.1.2 and 4.1.3 as
 * spec/FIPS180_SHA2.ec writes them:
 *
 *   RORX_32, RORX_64   rotation right by an immediate
 *   ANDN_32, ANDN_64   (NOT x) AND y, the last result of the model's tuple
 *   ch_bmi             Ch(e, f, g) = (e AND f) + ((NOT e) AND g): the two
 *                      terms have no common bit, so + is XOR
 *   maj_bmi            Maj(a, b, c) = ((b XOR c) AND (a XOR b)) XOR b
 *   ror_xor            a rotation as two shifts and an XOR
 *
 * No model of the library is needed; this file is checked once.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import Bytes FIPS180_SHA2.

(* ------------------------------------------------------------------ *)
(* 64-bit words                                                        *)

lemma RORX_64E (x : W64.t) n : 0 <= n < 64 =>
  RORX_64 x (W8.of_int n) = x `|>>>|` n.
proof.
move=> hn; rewrite /RORX_64 /shift_mask /=.
by rewrite (pmod_small n 256) 1:/# pmod_small.
qed.

lemma ANDN_64E (x y : W64.t) : (ANDN_64 x y).`6 = invw x `&` y.
proof. by rewrite /ANDN_64 /flags_w. qed.

lemma disj_add64 (x y : W64.t) : x `&` y = W64.zero => x + y = x +^ y.
proof.
move=> h; rewrite -W64.orw_disjoint //.
apply W64.wordP => i hi /=.
have := congr1 (fun w : W64.t => w.[i]) _ _ h; rewrite /= => hb.
by move: hb; case: (x.[i]); case: (y.[i]).
qed.

lemma ch_bmi64 (e f g : W64.t) : (f `&` e) + (invw e `&` g) = SHA512.ch e f g.
proof.
rewrite /SHA512.ch disj_add64 1:W64.wordP; last by rewrite W64.andwC.
move=> i hi /=.
by case: (e.[i]).
qed.

lemma maj_bmi64 (a b c : W64.t) : ((b +^ c) `&` (a +^ b)) +^ b = SHA512.maj a b c.
proof.
rewrite /SHA512.maj; apply W64.wordP => i hi.
rewrite /=.
by case: (a.[i]); case: (b.[i]); case: (c.[i]).
qed.

lemma ror_xor64 (x : W64.t) i : 0 < i < 64 =>
  x `|>>>|` i = (x `>>>` i) +^ (x `<<<` (64 - i)).
proof.
move=> hi; apply W64.wordP => k hk /=.
rewrite hk /=.
case: (k + i < 64) => hki.
+ by rewrite pmod_small 1:/# (W64.get_out x (k - (64 - i))) 1:/#.
by rewrite (_: (k + i) %% 64 = k - (64 - i)) 1:/# (W64.get_out x (k + i)) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* 32-bit words                                                        *)

lemma RORX_32E (x : W32.t) n : 0 <= n < 32 =>
  RORX_32 x (W8.of_int n) = x `|>>>|` n.
proof.
move=> hn; rewrite /RORX_32 /shift_mask /=.
by rewrite (pmod_small n 256) 1:/# pmod_small.
qed.

lemma ANDN_32E (x y : W32.t) : (ANDN_32 x y).`6 = invw x `&` y.
proof. by rewrite /ANDN_32 /flags_w. qed.

lemma disj_add32 (x y : W32.t) : x `&` y = W32.zero => x + y = x +^ y.
proof.
move=> h; rewrite -W32.orw_disjoint //.
apply W32.wordP => i hi /=.
have := congr1 (fun w : W32.t => w.[i]) _ _ h; rewrite /= => hb.
by move: hb; case: (x.[i]); case: (y.[i]).
qed.

lemma ch_bmi32 (e f g : W32.t) : (f `&` e) + (invw e `&` g) = SHA256.ch e f g.
proof.
rewrite /SHA256.ch disj_add32 1:W32.wordP; last by rewrite W32.andwC.
move=> i hi /=.
by case: (e.[i]).
qed.

lemma maj_bmi32 (a b c : W32.t) : ((b +^ c) `&` (a +^ b)) +^ b = SHA256.maj a b c.
proof.
rewrite /SHA256.maj; apply W32.wordP => i hi.
rewrite /=.
by case: (a.[i]); case: (b.[i]); case: (c.[i]).
qed.

lemma ror_xor32 (x : W32.t) i : 0 < i < 32 =>
  x `|>>>|` i = (x `>>>` i) +^ (x `<<<` (32 - i)).
proof.
move=> hi; apply W32.wordP => k hk /=.
rewrite hk /=.
case: (k + i < 32) => hki.
+ by rewrite pmod_small 1:/# (W32.get_out x (k - (32 - i))) 1:/#.
by rewrite (_: (k + i) %% 32 = k - (32 - i)) 1:/# (W32.get_out x (k + i)) 1:/#.
qed.
