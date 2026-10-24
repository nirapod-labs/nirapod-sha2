(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SpecEval.ec
 * ===========
 *
 * Rewriting rules that let EasyCrypt evaluate the specifications of
 * spec/ on concrete inputs by reduction. The validation files next to
 * this one state FIPS 180-4 and FIPS 198-1 functions applied to byte-list
 * literals, and close each statement with `cbv`.
 *
 * The word operators of JWord are opaque to reduction, so cbv alone
 * cannot evaluate an expression such as
 * (W32.of_int x `|>>>|` 2) +^ W32.of_int y. Each rule below turns one
 * operator applied to of_int literals into of_int of an integer that
 * reduction computes, bit by bit for the logical operators and rotations.
 * Addition needs no rule: JWord already rewrites of_int x + of_int y to
 * of_int (x + y), and reduces of_int of an integer outside [0, 2^n) to its
 * residue. The list rules replace the axiomatised integer ranges and
 * nseq by the unfolding iotared of the Jasmin library.
 *
 * The rules for words follow tests/insn/WordEval.ec.in, which plays the
 * same part in the instruction-model test, restricted to the word sizes
 * and packings the SHA-2 specification uses: bytes, 32-bit and 64-bit
 * words, and words as four or eight bytes.
 *
 * Every rule is a lemma proved for all arguments, without SMT. The file
 * adds no axiom, so it cannot make a false equation provable; it only
 * decides which true ones cbv can close.
 *)

require import AllCore IntDiv List Bool BitEncoding.
from Jasmin require import JUtils JWord.
import BS2Int.

(* evl s is the integer whose binary digits, least significant first, are
   the bits of s. A right fold that reduction evaluates directly. *)
op evl (s : bool list) : int =
  foldr (fun (b : bool) (n : int) => b2i b + 2 * n) 0 s.

lemma evlE (s : bool list) : evl s = bs2int s.
proof.
  elim: s => [|b s ih]; first by rewrite /evl bs2int_nil.
  by rewrite bs2int_cons -ih.
qed.

(* ------------------------------------------------------------------ *)
(* Words of 8, 32 and 64 bits                                         *)

(* ev f is the n-bit word whose bit i is f i, as an integer. *)

theory Eval8.

op ev (f : int -> bool) : int = evl (map f (iotared 0 8)).

lemma ev_ext (w : W8.t) (f : int -> bool) :
  (forall i, 0 <= i < 8 => w.[i] = f i) => w = W8.of_int (ev f).
proof.
  move=> h; rewrite -{1}(W8.to_uintK' w) W8.to_uintE /ev evlE /W8.w2bits.
  rewrite iotaredE; congr; congr; apply eq_in_map => i.
  by rewrite mem_iota /= => -[h0 h1]; apply h; rewrite h0 h1.
qed.

lemma xorE (a b : int) :
  W8.of_int a +^ W8.of_int b
  = W8.of_int (ev (fun i => W8.int_bit a i ^^ W8.int_bit b i)).
proof. by apply ev_ext => i hi; rewrite W8.xorwE !W8.of_intwE hi. qed.

end Eval8.

theory Eval32.

op ev (f : int -> bool) : int = evl (map f (iotared 0 32)).

lemma ev_ext (w : W32.t) (f : int -> bool) :
  (forall i, 0 <= i < 32 => w.[i] = f i) => w = W32.of_int (ev f).
proof.
  move=> h; rewrite -{1}(W32.to_uintK' w) W32.to_uintE /ev evlE /W32.w2bits.
  rewrite iotaredE; congr; congr; apply eq_in_map => i.
  by rewrite mem_iota /= => -[h0 h1]; apply h; rewrite h0 h1.
qed.

lemma xorE (a b : int) :
  W32.of_int a +^ W32.of_int b
  = W32.of_int (ev (fun i => W32.int_bit a i ^^ W32.int_bit b i)).
proof. by apply ev_ext => i hi; rewrite W32.xorwE !W32.of_intwE hi. qed.

lemma andE (a b : int) :
  W32.andw (W32.of_int a) (W32.of_int b)
  = W32.of_int (ev (fun i => W32.int_bit a i /\ W32.int_bit b i)).
proof. by apply ev_ext => i hi; rewrite W32.andwE !W32.of_intwE hi. qed.

lemma invE (a : int) :
  W32.invw (W32.of_int a) = W32.of_int (ev (fun i => !W32.int_bit a i)).
proof. by apply ev_ext => i hi; rewrite W32.invwE !W32.of_intwE hi. qed.

lemma rorE (a k : int) :
  W32.ror (W32.of_int a) k
  = W32.of_int (ev (fun i => W32.int_bit a ((i + k) %% 32))).
proof.
  apply ev_ext => i hi; rewrite W32.rorwE hi /= W32.of_intwE.
  by rewrite modz_cmp.
qed.

lemma shrE (a k : int) :
  W32.of_int a `>>>` k
  = W32.of_int (ev (fun i => 0 <= i + k < 32 /\ W32.int_bit a (i + k))).
proof. by apply ev_ext => i hi; rewrite W32.shrwE hi /= W32.of_intwE. qed.

end Eval32.

theory Eval64.

op ev (f : int -> bool) : int = evl (map f (iotared 0 64)).

lemma ev_ext (w : W64.t) (f : int -> bool) :
  (forall i, 0 <= i < 64 => w.[i] = f i) => w = W64.of_int (ev f).
proof.
  move=> h; rewrite -{1}(W64.to_uintK' w) W64.to_uintE /ev evlE /W64.w2bits.
  rewrite iotaredE; congr; congr; apply eq_in_map => i.
  by rewrite mem_iota /= => -[h0 h1]; apply h; rewrite h0 h1.
qed.

lemma xorE (a b : int) :
  W64.of_int a +^ W64.of_int b
  = W64.of_int (ev (fun i => W64.int_bit a i ^^ W64.int_bit b i)).
proof. by apply ev_ext => i hi; rewrite W64.xorwE !W64.of_intwE hi. qed.

lemma andE (a b : int) :
  W64.andw (W64.of_int a) (W64.of_int b)
  = W64.of_int (ev (fun i => W64.int_bit a i /\ W64.int_bit b i)).
proof. by apply ev_ext => i hi; rewrite W64.andwE !W64.of_intwE hi. qed.

lemma invE (a : int) :
  W64.invw (W64.of_int a) = W64.of_int (ev (fun i => !W64.int_bit a i)).
proof. by apply ev_ext => i hi; rewrite W64.invwE !W64.of_intwE hi. qed.

lemma rorE (a k : int) :
  W64.ror (W64.of_int a) k
  = W64.of_int (ev (fun i => W64.int_bit a ((i + k) %% 64))).
proof.
  apply ev_ext => i hi; rewrite W64.rorwE hi /= W64.of_intwE.
  by rewrite modz_cmp.
qed.

lemma shrE (a k : int) :
  W64.of_int a `>>>` k
  = W64.of_int (ev (fun i => 0 <= i + k < 64 /\ W64.int_bit a (i + k))).
proof. by apply ev_ext => i hi; rewrite W64.shrwE hi /= W64.of_intwE. qed.

end Eval64.

(* ------------------------------------------------------------------ *)
(* Words as bytes                                                     *)

(* Byte i of a literal, and a word assembled from bytes: the reading and
   writing of words in section 3.1 of FIPS 180-4 (be32, be64, w32_be,
   w64_be of spec/FIPS180_SHA2.ec). *)

theory EvalW4u8.

lemma bitsE (x i : int) :
  W32.of_int x \bits8 i
  = W8.of_int (Eval8.ev (fun j => 0 <= i * 8 + j < 32 /\ W32.int_bit x (i * 8 + j))).
proof. by apply Eval8.ev_ext => j hj; rewrite W4u8.bits8iE // W32.of_intwE. qed.

lemma packE (ws : W4u8.Pack.pack_t) :
  W4u8.pack4_t ws = W32.of_int (Eval32.ev (fun i => ws.[i %/ 8].[i %% 8])).
proof. by apply Eval32.ev_ext => i hi; rewrite W4u8.pack4wE. qed.

end EvalW4u8.

theory EvalW8u8.

lemma bitsE (x i : int) :
  W64.of_int x \bits8 i
  = W8.of_int (Eval8.ev (fun j => 0 <= i * 8 + j < 64 /\ W64.int_bit x (i * 8 + j))).
proof. by apply Eval8.ev_ext => j hj; rewrite W8u8.bits8iE // W64.of_intwE. qed.

lemma packE (ws : W8u8.Pack.pack_t) :
  W8u8.pack8_t ws = W64.of_int (Eval64.ev (fun i => ws.[i %/ 8].[i %% 8])).
proof. by apply Eval64.ev_ext => i hi; rewrite W8u8.pack8wE. qed.

end EvalW8u8.

(* ------------------------------------------------------------------ *)
(* Lists                                                              *)

(* range, mkseq and chunk are written with iota_, which reduction does not
   unfold; iotared is the same list and does. nseq is an iteration that
   reduction does not unfold either. *)
lemma iota_iotared (i n : int) : iota_ i n = iotared i n.
proof. by rewrite iotaredE. qed.

lemma nseq_mkseq ['a] (n : int) (x : 'a) : nseq n x = mkseq (fun _ => x) n.
proof. by rewrite mkseq_nseq. qed.

(* The hints come last, so that the proofs above are not slowed down by
   simplification unfolding the bits of every word. *)
hint simplify (Eval8.xorE).
hint simplify (Eval32.xorE, Eval32.andE, Eval32.invE, Eval32.rorE, Eval32.shrE).
hint simplify (Eval64.xorE, Eval64.andE, Eval64.invE, Eval64.rorE, Eval64.shrE).
hint simplify (EvalW4u8.bitsE, EvalW4u8.packE, EvalW8u8.bitsE, EvalW8u8.packE).
hint simplify (W8.of_intwE, W32.of_intwE, W64.of_intwE).
hint simplify (iota_iotared, nseq_mkseq).
