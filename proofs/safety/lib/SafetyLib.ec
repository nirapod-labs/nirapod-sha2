(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyLib.ec
 * ============
 *
 * Facts used by every safety proof, independent of the model: the trace
 * of assertions a safety-model procedure returns, and sub-ranges of valid
 * memory. A trace is valid when every assertion in it holds; the two
 * simplification hints below turn the validity of a trace built by
 * appending single assertions into the conjunction of those assertions.
 *)

require import AllCore IntDiv List.
from Jasmin require import JWord JMemory Jcheck.

lemma valid_catE (x y : trace) : valid (x ++ y) = (valid x /\ valid y).
proof. by rewrite valid_cat. qed.

lemma valid1 (k : kind) (b : bool) : valid [(k, b)] = b.
proof. by rewrite /valid. qed.

lemma valid_nil : valid<:kind> [].
proof. by rewrite /valid. qed.

hint simplify valid_catE, valid1, valid_nil.

(* A sub-range of a valid range is valid. *)
lemma valid_sub mv (a n o l : int) :
  is_valid (2 ^ 64) mv a n => 0 <= o => 0 <= l => o + l <= n =>
  is_valid (2 ^ 64) mv (a + o) l.
proof.
rewrite /is_valid => -[hv [h0 hb]] ho hl hol.
by split; [move=> i hi; apply hv | move: h0 hb ho hol hl; clear hv]; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Small word arithmetic                                              *)

lemma w64_modulus : W64.modulus = 18446744073709551616.
proof. by []. qed.

lemma to_uint_one : W64.to_uint W64.one = 1.
proof. by []. qed.

lemma pow2_64 : 2 ^ 64 = 18446744073709551616.
proof. by []. qed.

(* Three bounded words whose sum is bounded: the sum does not wrap. *)
lemma ule_sum (a b : W64.t) c : 0 <= c < 2 ^ 63 =>
  a \ule W64.of_int c => b \ule W64.of_int c => a + b \ule W64.of_int c =>
  to_uint a + to_uint b <= c /\ to_uint (a + b) = to_uint a + to_uint b.
proof.
move=> hc; have hcm : c %% W64.modulus = c.
+ by rewrite pmod_small //; move: hc; rewrite (_ : W64.modulus = 2 ^ 63 * 2) 1:// /#.
rewrite !W64.uleE !W64.of_uintK hcm => ha hb hab.
have hs : to_uint (a + b) = to_uint a + to_uint b.
+ rewrite W64.to_uintD_small //; move: hc ha hb.
  by rewrite (_ : W64.modulus = 2 ^ 63 * 2) 1:// /#.
by rewrite hs; move: hab; rewrite hs.
qed.

lemma to_uint_and7 (x : W64.t) : to_uint (x `&` W64.of_int 7) < 8.
proof.
rewrite (_ : 7 = 2 ^ 3 - 1) 1:// W64.and_mod // W64.of_uintK.
smt(modz_ge0 ltz_pmod W64.to_uint_cmp pmod_small).
qed.

(* The head of a word fill: up to the next multiple of 8 of d, at most n. *)
lemma fill_head (d n : W64.t) :
  to_uint d + to_uint n <= 2 ^ 62 =>
  let h = if n \ult (-d) `&` W64.of_int 7 then n else (-d) `&` W64.of_int 7 in
  to_uint h <= to_uint n /\ to_uint (d + h) = to_uint d + to_uint h
  /\ to_uint (n - h) = to_uint n - to_uint h.
proof.
move=> hdn /=; have h7 := to_uint_and7 (-d).
have hle : to_uint (if n \ult (-d) `&` W64.of_int 7 then n else (-d) `&` W64.of_int 7) <= to_uint n.
+ by case: (n \ult (-d) `&` W64.of_int 7); rewrite ?W64.ultE /#.
split => //; split.
+ rewrite W64.to_uintD_small //; move: hdn hle h7; rewrite w64_modulus; smt(W64.to_uint_cmp).
by rewrite W64.to_uintB // W64.uleE.
qed.

(* Adding or subtracting a small constant without wrapping. *)
lemma addc_small (x : W64.t) c : 0 <= c => to_uint x + c < 18446744073709551616 =>
  to_uint (x + W64.of_int c) = to_uint x + c.
proof.
move=> hc hx; have hcm : c %% W64.modulus = c.
+ by rewrite pmod_small //; smt(W64.to_uint_cmp w64_modulus).
by rewrite W64.to_uintD_small W64.of_uintK hcm // w64_modulus.
qed.

lemma addone_small (x : W64.t) : to_uint x + 1 < 18446744073709551616 =>
  to_uint (x + W64.one) = to_uint x + 1.
proof. by move=> hx; rewrite W64.to_uintD_small to_uint_one // w64_modulus. qed.

lemma subc_small (x : W64.t) c : 0 <= c <= to_uint x =>
  to_uint (x - W64.of_int c) = to_uint x - c.
proof.
move=> hc; have hcm : c %% W64.modulus = c.
+ by rewrite pmod_small //; smt(W64.to_uint_cmp w64_modulus).
have hle : W64.of_int c \ule x by rewrite W64.uleE W64.of_uintK hcm /#.
by rewrite W64.to_uintB // W64.of_uintK hcm.
qed.

lemma min_le (h x : W64.t) : to_uint (if h \ult x then h else x) <= to_uint h.
proof. by case: (h \ult x); rewrite ?W64.ultE /#. qed.

(* The byte length of n blocks of b bytes, for n below the contract bound. *)
lemma mulc_small (n : W64.t) b : 0 <= b < 18446744073709551616 =>
  b * to_uint n < 18446744073709551616 =>
  to_uint (W64.of_int b * n) = b * to_uint n.
proof.
move=> hb hbn; have hbm : b %% W64.modulus = b by rewrite pmod_small // w64_modulus.
by rewrite W64.to_uintM_small; rewrite W64.of_uintK hbm ?w64_modulus.
qed.

lemma ult_const (n : W64.t) c : 0 <= c < 18446744073709551616 =>
  n \ult W64.of_int c => to_uint n < c.
proof.
move=> hc; have hcm : c %% W64.modulus = c by rewrite pmod_small // w64_modulus.
by rewrite W64.ultE W64.of_uintK hcm.
qed.

lemma subone (n : W64.t) : n <> W64.zero => to_uint (n - W64.one) = to_uint n - 1.
proof.
move=> hn; have h1 : 1 <= to_uint n.
+ have : to_uint n <> 0 by move: hn; apply contra => h; apply W64.to_uint_eq; rewrite h.
  smt(W64.to_uint_cmp).
by rewrite W64.to_uintB ?W64.uleE to_uint_one.
qed.

lemma nonzero (n : W64.t) : n <> W64.zero => 1 <= to_uint n.
proof.
move=> hn; have : to_uint n <> 0 by move: hn; apply contra => h; apply W64.to_uint_eq; rewrite h.
smt(W64.to_uint_cmp).
qed.

(* Valid memory for each of k lanes: f i is lane i's address, l its length.
   A named predicate, so that proof scripts keep it folded. *)
op lanes_valid (mv : global_mem_v_t) (k : int) (f : int -> int) (l : int) =
  forall i, 0 <= i < k => is_valid (2 ^ 64) mv (f i) l.

lemma lanes_valid8 mv (f : int -> int) l :
  is_valid (2 ^ 64) mv (f 0) l => is_valid (2 ^ 64) mv (f 1) l =>
  is_valid (2 ^ 64) mv (f 2) l => is_valid (2 ^ 64) mv (f 3) l =>
  is_valid (2 ^ 64) mv (f 4) l => is_valid (2 ^ 64) mv (f 5) l =>
  is_valid (2 ^ 64) mv (f 6) l => is_valid (2 ^ 64) mv (f 7) l =>
  lanes_valid mv 8 f l.
proof.
move=> h0 h1 h2 h3 h4 h5 h6 h7 i hi.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

lemma lanes_valid4 mv (f : int -> int) l :
  is_valid (2 ^ 64) mv (f 0) l => is_valid (2 ^ 64) mv (f 1) l =>
  is_valid (2 ^ 64) mv (f 2) l => is_valid (2 ^ 64) mv (f 3) l =>
  lanes_valid mv 4 f l.
proof.
move=> h0 h1 h2 h3 i hi.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
by case=> [->|[->|[->|->]]].
qed.

(* Block arithmetic of the absorb: fill = total mod B, whole blocks. *)
lemma umodc (x : W64.t) c : 0 < c < 18446744073709551616 =>
  to_uint (x \umod W64.of_int c) = to_uint x %% c.
proof.
move=> hc; have hcm : c %% W64.modulus = c by rewrite pmod_small // w64_modulus /#.
rewrite W64.umodE /ulift2 !W64.of_uintK hcm pmod_small //.
split; [smt(modz_ge0) | move=> _]; rewrite w64_modulus.
by have := ltz_pmod (to_uint x) c _; [smt() | smt()].
qed.

lemma andmask (x : W64.t) k : 0 <= k < 64 =>
  to_uint (x `&` W64.of_int (2 ^ k - 1)) = to_uint x %% 2 ^ k.
proof.
move=> hk; rewrite W64.and_mod 1:/# W64.of_uintK.
have h1 : 0 < 2 ^ k by apply StdOrder.IntOrder.expr_gt0.
have h2 : 2 ^ k <= 2 ^ 64 by apply StdOrder.IntOrder.ler_weexpn2l => /#.
rewrite (pmod_small _ W64.modulus) //.
split; first by apply modz_ge0 => /#.
by move=> _; apply (StdOrder.IntOrder.ltr_le_trans (2 ^ k)) => //; apply ltz_pmod.
qed.

lemma and63 (x : W64.t) : to_uint (x `&` W64.of_int 63) = to_uint x %% 64.
proof. by have := andmask x 6 _; 1: done. qed.

lemma and127 (x : W64.t) : to_uint (x `&` W64.of_int 127) = to_uint x %% 128.
proof. by have := andmask x 7 _; 1: done. qed.

lemma shrc (x : W64.t) k : 0 <= k < 64 => to_uint (x `>>` W8.of_int k) = to_uint x %/ 2 ^ k.
proof.
move=> hk; rewrite /(`>>`) W64.to_uint_shr W8.of_uintK; 1: smt(modz_ge0).
by rewrite (pmod_small k) 1:/#.
qed.

lemma shlc (x : W64.t) k : 0 <= k < 64 => to_uint (x `<<` W8.of_int k) = (to_uint x * 2 ^ k) %% 2 ^ 64.
proof.
move=> hk; rewrite /(`<<`) W64.to_uint_shl W8.of_uintK; 1: smt(modz_ge0).
by rewrite (pmod_small k) 1:/#.
qed.

(* Whole blocks of b = 2^k bytes in x: (x >> k) << k. *)
lemma blocksc (x : W64.t) k : 0 <= k < 64 =>
  to_uint ((x `>>` W8.of_int k) `<<` W8.of_int k) = 2 ^ k * (to_uint x %/ 2 ^ k).
proof.
move=> hk; rewrite shlc // shrc // pmod_small; last by ring.
have h1 : 0 < 2 ^ k by apply StdOrder.IntOrder.expr_gt0.
split; first by apply StdOrder.IntOrder.mulr_ge0; smt(divz_ge0 W64.to_uint_cmp).
move=> _; rewrite pow2_64; have := W64.to_uint_cmp x; rewrite w64_modulus => hx.
smt(divz_eq modz_ge0).
qed.
