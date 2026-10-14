(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Scalar.ec (aarch64)
 * ===================
 *
 * The forms in which the scalar A64 kernels (src/aarch64/scalar) compute
 * the functions of FIPS 180-4 sections 4.1.2 and 4.1.3, proved equal to
 * the functions of spec/FIPS180_SHA2.ec:
 *
 *     Ch(e, f, g)    (e AND f) + BIC(g, e), where BIC(g, e) = g AND NOT e;
 *                    the two terms are bit-disjoint, so their sum is
 *                    their XOR
 *     Maj(a, b, c)   ((a XOR b) AND (b XOR c)) XOR b
 *     Σ0, Σ1, σ0, σ1 ROR and LSR by immediates, as the model writes them
 *                    (`|>>|` and `>>` with a W8 count)
 *
 * Model-free: checked once (proofs/Makefile, check-lib).
 *)

require import AllCore IntDiv.
from Jasmin require import JWord JUtils JModel_armv8a.
require import FIPS180_SHA2.

theory S256.
import SHA256.

lemma ch_bic (e f g : W32.t) : (e `&` f) + BIC_32 g e = ch e f g.
proof.
rewrite /BIC_32 /ch.
have hd : (e `&` f) `&` (g `&` invw e) = W32.zero.
+ by apply W32.wordP => i hi; rewrite !(W32.andwE, W32.invwE) hi /=; smt().
have -> : (e `&` f) + (g `&` invw e) = W32.orw (e `&` f) (g `&` invw e).
+ by rewrite -(W32.orw_disjoint (e `&` f) (g `&` invw e) hd).
by rewrite W32.orw_xorw hd (W32.andwC g (invw e)) W32.xorw0.
qed.

lemma maj_abc (a b c : W32.t) : ((a +^ b) `&` (b +^ c)) +^ b = maj a b c.
proof.
rewrite /maj; apply W32.wordP => i hi.
by rewrite !(W32.xorwE, W32.andwE) /=; smt().
qed.

lemma bsig0_ror (x : W32.t) :
  (x `|>>|` W8.of_int 2) +^ (x `|>>|` W8.of_int 13) +^ (x `|>>|` W8.of_int 22) = bsig0 x.
proof. by rewrite /bsig0 /(`|>>|`) !W8.of_uintK. qed.

lemma bsig1_ror (x : W32.t) :
  (x `|>>|` W8.of_int 6) +^ (x `|>>|` W8.of_int 11) +^ (x `|>>|` W8.of_int 25) = bsig1 x.
proof. by rewrite /bsig1 /(`|>>|`) !W8.of_uintK. qed.

lemma ssig0_ror (x : W32.t) :
  (x `|>>|` W8.of_int 7) +^ (x `|>>|` W8.of_int 18) +^ (x `>>` W8.of_int 3) = ssig0 x.
proof. by rewrite /ssig0 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

lemma ssig1_ror (x : W32.t) :
  (x `|>>|` W8.of_int 17) +^ (x `|>>|` W8.of_int 19) +^ (x `>>` W8.of_int 10) = ssig1 x.
proof. by rewrite /ssig1 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

end S256.

theory S512.
import SHA512.

lemma ch_bic (e f g : W64.t) : (e `&` f) + BIC_64 g e = ch e f g.
proof.
rewrite /BIC_64 /ch.
have hd : (e `&` f) `&` (g `&` invw e) = W64.zero.
+ by apply W64.wordP => i hi; rewrite !(W64.andwE, W64.invwE) hi /=; smt().
have -> : (e `&` f) + (g `&` invw e) = W64.orw (e `&` f) (g `&` invw e).
+ by rewrite -(W64.orw_disjoint (e `&` f) (g `&` invw e) hd).
by rewrite W64.orw_xorw hd (W64.andwC g (invw e)) W64.xorw0.
qed.

lemma maj_abc (a b c : W64.t) : ((a +^ b) `&` (b +^ c)) +^ b = maj a b c.
proof.
rewrite /maj; apply W64.wordP => i hi.
by rewrite !(W64.xorwE, W64.andwE) /=; smt().
qed.

lemma bsig0_ror (x : W64.t) :
  (x `|>>|` W8.of_int 28) +^ (x `|>>|` W8.of_int 34) +^ (x `|>>|` W8.of_int 39) = bsig0 x.
proof. by rewrite /bsig0 /(`|>>|`) !W8.of_uintK. qed.

lemma bsig1_ror (x : W64.t) :
  (x `|>>|` W8.of_int 14) +^ (x `|>>|` W8.of_int 18) +^ (x `|>>|` W8.of_int 41) = bsig1 x.
proof. by rewrite /bsig1 /(`|>>|`) !W8.of_uintK. qed.

lemma ssig0_ror (x : W64.t) :
  (x `|>>|` W8.of_int 1) +^ (x `|>>|` W8.of_int 8) +^ (x `>>` W8.of_int 7) = ssig0 x.
proof. by rewrite /ssig0 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

lemma ssig1_ror (x : W64.t) :
  (x `|>>|` W8.of_int 19) +^ (x `|>>|` W8.of_int 61) +^ (x `>>` W8.of_int 6) = ssig1 x.
proof. by rewrite /ssig1 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

end S512.
