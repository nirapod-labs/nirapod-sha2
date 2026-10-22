(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * ArraySafety.ec
 * ==============
 *
 * Safety of the array instances of the array test unit
 * tests/array/array.jazz, sizes 1, 64, 128 and 333, in its safety model
 * ArraySha2Safety. For every procedure F of an instance (the byte movers
 * of src/fill_ASIZE.jinc, the four absorbs of src/*_ASIZE.jinc and the
 * four one-shot test exports), the lemma F_proof proves the Hoare triple
 * F_spec: from a state meeting F's #[safety] contract every assertion of
 * F holds and the contract's ensures hold on return.
 *
 * The instances call the unit's own copies of the portable kernels and of
 * the init and finalize procedures. Those copies are the text of
 * NirapodSha2Safety, so each is related to its procedure there by
 * proc; sim, and the safety lemma of that procedure is carried over by
 * conseq (the lemmas arr<F>_proof).
 *
 * The proofs of the instances follow those of the memory forms in
 * SafetyFill, SafetySha256 and SafetyMulti, with an index into the array
 * a in place of a pointer: is_init on a_init replaces is_valid on the
 * memory, and the size bound replaces the address-space bound. A protect
 * of a marks a_init fully initialised, which the invariants allow. The
 * scripts are the same for every size, which appears only as the bound.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyMulti.
require import BArray1 BArray32 BArray64 BArray128 BArray256 BArray333 BArray512.
require import SBArray512_64 SBArray512_128.
require NirapodSha2Safety SafetySha256 SafetySha512.
require SHA256_KernelSafety SHA512_KernelSafety SHA256_X8_KernelSafety SHA512_X4_KernelSafety.
require import ArraySha2Safety.

(* ------------------------------------------------------------------ *)
(* The kernels, init and finalize procedures the instances call       *)

equiv arr_sha256_compress_eq : M._sha256_compress ~ NirapodSha2Safety.M._sha256_compress : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha256_compress_proof _h _block _ms _h_init _block_init :
  _sha256_compress_spec _h _block _ms _h_init _block_init.
proof.
have H := SHA256_KernelSafety._sha256_compress_proof _h _block _ms _h_init _block_init.
rewrite /NirapodSha2Safety._sha256_compress_spec in H; rewrite /_sha256_compress_spec.
conseq arr_sha256_compress_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha512_compress_eq : M._sha512_compress ~ NirapodSha2Safety.M._sha512_compress : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha512_compress_proof _h _block _ms _h_init _block_init :
  _sha512_compress_spec _h _block _ms _h_init _block_init.
proof.
have H := SHA512_KernelSafety._sha512_compress_proof _h _block _ms _h_init _block_init.
rewrite /NirapodSha2Safety._sha512_compress_spec in H; rewrite /_sha512_compress_spec.
conseq arr_sha512_compress_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha256_x8_compress_eq : M._sha256_x8_compress ~ NirapodSha2Safety.M._sha256_x8_compress : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init :
  _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init.
proof.
have H := SHA256_X8_KernelSafety._sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init.
rewrite /NirapodSha2Safety._sha256_x8_compress_spec in H; rewrite /_sha256_x8_compress_spec.
conseq arr_sha256_x8_compress_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha512_x4_compress_eq : M._sha512_x4_compress ~ NirapodSha2Safety.M._sha512_x4_compress : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha512_x4_compress_proof _h4 _blocks _ms _h4_init _blocks_init :
  _sha512_x4_compress_spec _h4 _blocks _ms _h4_init _blocks_init.
proof.
have H := SHA512_X4_KernelSafety._sha512_x4_compress_proof _h4 _blocks _ms _h4_init _blocks_init.
rewrite /NirapodSha2Safety._sha512_x4_compress_spec in H; rewrite /_sha512_x4_compress_spec.
conseq arr_sha512_x4_compress_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr__sha256_init_eq : M.__sha256_init ~ NirapodSha2Safety.M.__sha256_init : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr__sha256_init_proof _h _h_init :
  __sha256_init_spec _h _h_init.
proof.
have H := SafetySha256.__sha256_init_proof _h _h_init.
rewrite /NirapodSha2Safety.__sha256_init_spec in H; rewrite /__sha256_init_spec.
conseq arr__sha256_init_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha256___sha256_finalize_eq : M._sha256___sha256_finalize ~ NirapodSha2Safety.M._sha256___sha256_finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha256___sha256_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha256___sha256_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
have H := SafetySha256._sha256___sha256_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init.
rewrite /NirapodSha2Safety._sha256___sha256_finalize_spec in H; rewrite /_sha256___sha256_finalize_spec.
conseq arr_sha256___sha256_finalize_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr__sha512_init_eq : M.__sha512_init ~ NirapodSha2Safety.M.__sha512_init : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr__sha512_init_proof _h _h_init :
  __sha512_init_spec _h _h_init.
proof.
have H := SafetySha512.__sha512_init_proof _h _h_init.
rewrite /NirapodSha2Safety.__sha512_init_spec in H; rewrite /__sha512_init_spec.
conseq arr__sha512_init_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha512___sha512_finalize_eq : M._sha512___sha512_finalize ~ NirapodSha2Safety.M._sha512___sha512_finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha512___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha512___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
have H := SafetySha512._sha512___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init.
rewrite /NirapodSha2Safety._sha512___sha512_finalize_spec in H; rewrite /_sha512___sha512_finalize_spec.
conseq arr_sha512___sha512_finalize_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr__sha256_x8_init_eq : M.__sha256_x8_init ~ NirapodSha2Safety.M.__sha256_x8_init : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr__sha256_x8_init_proof _h _h_init :
  __sha256_x8_init_spec _h _h_init.
proof.
have H := SafetyMulti.__sha256_x8_init_proof _h _h_init.
rewrite /NirapodSha2Safety.__sha256_x8_init_spec in H; rewrite /__sha256_x8_init_spec.
conseq arr__sha256_x8_init_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha256_x8_finalize_eq : M._sha256_x8_finalize ~ NirapodSha2Safety.M._sha256_x8_finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha256_x8_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha256_x8_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
have H := SafetyMulti._sha256_x8_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init.
rewrite /NirapodSha2Safety._sha256_x8_finalize_spec in H; rewrite /_sha256_x8_finalize_spec.
conseq arr_sha256_x8_finalize_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr__sha512_x4_init_eq : M.__sha512_x4_init ~ NirapodSha2Safety.M.__sha512_x4_init : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr__sha512_x4_init_proof _h _h_init :
  __sha512_x4_init_spec _h _h_init.
proof.
have H := SafetyMulti.__sha512_x4_init_proof _h _h_init.
rewrite /NirapodSha2Safety.__sha512_x4_init_spec in H; rewrite /__sha512_x4_init_spec.
conseq arr__sha512_x4_init_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

equiv arr_sha512_x4_finalize_eq : M._sha512_x4_finalize ~ NirapodSha2Safety.M._sha512_x4_finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

lemma arr_sha512_x4_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha512_x4_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
have H := SafetyMulti._sha512_x4_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init.
rewrite /NirapodSha2Safety._sha512_x4_finalize_spec in H; rewrite /_sha512_x4_finalize_spec.
conseq arr_sha512_x4_finalize_eq H; [by move=> &1 h; exists arg{1} | by move=> /#].
qed.

(* ------------------------------------------------------------------ *)
(* Arithmetic shared by the sizes                                     *)

(* The step of an absorb: n = min(l, b - f) bytes top up f buffered ones. *)
lemma absorb_n (f l : W64.t) b : 0 < b <= 128 => to_uint f < b =>
  let n = if l \ult W64.of_int b - f then l else W64.of_int b - f in
  to_uint n <= to_uint l /\ to_uint f + to_uint n <= b
  /\ (to_uint f + to_uint n <> b => to_uint n = to_uint l)
  /\ to_uint (f + n) = to_uint f + to_uint n
  /\ to_uint (l - n) = to_uint l - to_uint n.
proof.
move=> hb hf /=.
have hb' : to_uint (W64.of_int b) = b.
+ by rewrite W64.of_uintK pmod_small // w64_modulus /#.
have hs : to_uint (W64.of_int b - f) = b - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE hb' /#.
case: (l \ult W64.of_int b - f) => hl /=.
+ move: hl; rewrite W64.ultE hs => hl.
  by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
move: hl; rewrite W64.ultE hs => hl.
rewrite W64.to_uintB 1:W64.uleE 1:hs 1:/# hs W64.to_uintD_small hs; smt(W64.to_uint_cmp).
qed.

lemma mul_lane (k m s : int) : 0 <= s => k <= m => k * s <= m * s.
proof. by move=> hs hk; apply StdOrder.IntOrder.ler_wpmul2r. qed.

(* Lane k of a multi-way form starts at off + k * stride. With every word
   at most n < 2^60 and the last lane m in bounds, nothing wraps. *)
lemma lane_off (o s l : W64.t) n m k : 0 <= k <= m => m < 8 => 0 <= n < 1152921504606846976 =>
  o \ule W64.of_int n => s \ule W64.of_int n => l \ule W64.of_int n =>
  o + W64.of_int m * s + l \ule W64.of_int n =>
  to_uint o + m * to_uint s + to_uint l <= n
  /\ to_uint (o + W64.of_int k * s) = to_uint o + k * to_uint s.
proof.
move=> hk hm8 hn; have hm : n %% W64.modulus = n by rewrite pmod_small // w64_modulus /#.
rewrite !W64.uleE !W64.of_uintK hm => ho hs hl.
have hj7 : forall j, 0 <= j < 8 => j * to_uint s <= 7 * to_uint s.
+ by move=> j hj; apply mul_lane; smt(W64.to_uint_cmp).
have hks : forall j, 0 <= j < 8 => to_uint (W64.of_int j * s) = j * to_uint s.
+ move=> j hj; have := hj7 j hj.
  rewrite W64.to_uintM_small W64.of_uintK pmod_small // w64_modulus; smt(W64.to_uint_cmp).
have hos : forall j, 0 <= j < 8 => to_uint (o + W64.of_int j * s) = to_uint o + j * to_uint s.
+ move=> j hj; have := hj7 j hj.
  by rewrite W64.to_uintD_small hks // w64_modulus; smt(W64.to_uint_cmp).
have em : to_uint (o + W64.of_int m * s + l) = to_uint o + m * to_uint s + to_uint l.
+ have := hj7 m _; 1: smt().
  by rewrite W64.to_uintD_small hos //; smt(W64.to_uint_cmp w64_modulus).
by rewrite em => h; split; [smt() | apply hos; smt()].
qed.

lemma lane_bound (o s l n ks m c : int) : 1 <= m => 0 <= o => 0 <= s => 0 <= l => 0 <= n =>
  ks <= m * s => o + m * s + l <= c => n <= l =>
  o + ks + n <= c /\ o + ks + s <= 2 * c.
proof.
move=> hm ho hs hl hn hks hc hnl; have := mul_lane 1 m s hs hm.
smt().
qed.

(* ------------------------------------------------------------------ *)
(* Size 1                                                             *)

lemma a1____fill64_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a1____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a1____fill64_array_spec; proc.
wp; while (valid trace_a1____fill64_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a1____fill64_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask64_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a1____fill64_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 64 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a1____fill128_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a1____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a1____fill128_array_spec; proc.
wp; while (valid trace_a1____fill128_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a1____fill128_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask128_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a1____fill128_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray1.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 1
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 128 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a1___sha256_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a1___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a1___sha256_absorb_array_spec; proc.
wp; while (valid trace_a1___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ BArray64.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 1
       /\ BArray1.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a1___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray64.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 1
       /\ BArray1.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a1____fill64_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha256_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full64_init 0 0); 3: by move=> j _ _; apply (BArray1.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 1 _ ho hl hol; 1: by [].
rewrite and63; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a1___sha512_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a1___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a1___sha512_absorb_array_spec; proc.
wp; while (valid trace_a1___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ BArray128.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 1
       /\ BArray1.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a1___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray128.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 1
       /\ BArray1.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a1____fill128_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha512_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full128_init 0 0); 3: by move=> j _ _; apply (BArray1.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 1 _ ho hl hol; 1: by [].
rewrite and127; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a1___sha256_x8_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a1___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a1___sha256_x8_absorb_array_spec; proc.
wp; while (valid trace_a1___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 64
       /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 8 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a1___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 8 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 8 64 8 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a1___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 8 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 8 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a1____fill64_array_proof (SBArray512_64.get_sub8 buf (64 * k)) fill a src n ms
                 (SBArray512_64.get_sub buf_init (1 * (64 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 7 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 7 1 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes64_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes64_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 8 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha256_x8_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes8_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 8 64 8 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray1.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7 ho hs hl hosl ha0 ha1 ha2 ha3 ha4 ha5 ha6 ha7.
have [hsum _] := lane_off _off _stride _len 1 7 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes8I _ _ hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and63; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 1 7 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 64 + to_uint _len) %% 64.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 h4 h5 h6 h7 := lanes8E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3 h4 h5 h6 h7.
qed.

lemma a1___sha512_x4_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a1___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a1___sha512_x4_absorb_array_spec; proc.
wp; while (valid trace_a1___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 128
       /\ lanes buf_init 4 128 4 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 4 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a1___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 4 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 4 128 4 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a1___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 1
       /\ (forall k, 0 <= k < 4 =>
             BArray1.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 4 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 4 128 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a1____fill128_array_proof (SBArray512_128.get_sub8 buf (128 * k)) fill a src n ms
                 (SBArray512_128.get_sub buf_init (1 * (128 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 3 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 3 1 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes128_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes128_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 4 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha512_x4_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes4_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 4 128 4 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray1.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 ho hs hl hosl ha0 ha1 ha2 ha3.
have [hsum _] := lane_off _off _stride _len 1 3 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes4I _ _ hb0 hb1 hb2 hb3.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and127; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 1 3 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 by smt().
  by case=> [->|[->|[->|->]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 128 + to_uint _len) %% 128.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 := lanes4E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3.
qed.

lemma a1__sha256_proof _out _a _off _len _out_init _a_init :
  a1__sha256_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a1__sha256_spec; proc.
wp; ecall (arr_sha256___sha256_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a1___sha256_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha256_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray1.init_arrP witness)); smt().
qed.

lemma a1__sha512_proof _out _a _off _len _out_init _a_init :
  a1__sha512_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a1__sha512_spec; proc.
wp; ecall (arr_sha512___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a1___sha512_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha512_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray1.init_arrP witness)); smt().
qed.

lemma a1__sha256_x8_proof _out _a _off _stride _len _out_init _a_init :
  a1__sha256_x8_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a1__sha256_x8_spec; proc.
wp; ecall (arr_sha256_x8_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a1___sha256_x8_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha256_x8_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray1.init_arrP witness)); smt().
qed.

lemma a1__sha512_x4_proof _out _a _off _stride _len _out_init _a_init :
  a1__sha512_x4_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a1__sha512_x4_spec; proc.
wp; ecall (arr_sha512_x4_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a1___sha512_x4_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha512_x4_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray1.init_arrP witness)); smt().
qed.

(* ------------------------------------------------------------------ *)
(* Size 64                                                            *)

lemma a64____fill64_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a64____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a64____fill64_array_spec; proc.
wp; while (valid trace_a64____fill64_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a64____fill64_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask64_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a64____fill64_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 64 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a64____fill128_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a64____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a64____fill128_array_spec; proc.
wp; while (valid trace_a64____fill128_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a64____fill128_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask128_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a64____fill128_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray64.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 64
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 128 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a64___sha256_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a64___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a64___sha256_absorb_array_spec; proc.
wp; while (valid trace_a64___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ BArray64.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 64
       /\ BArray64.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a64___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray64.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 64
       /\ BArray64.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a64____fill64_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha256_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full64_init 0 0); 3: by move=> j _ _; apply (BArray64.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 64 _ ho hl hol; 1: by [].
rewrite and63; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a64___sha512_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a64___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a64___sha512_absorb_array_spec; proc.
wp; while (valid trace_a64___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ BArray128.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 64
       /\ BArray64.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a64___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray128.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 64
       /\ BArray64.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a64____fill128_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha512_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full128_init 0 0); 3: by move=> j _ _; apply (BArray64.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 64 _ ho hl hol; 1: by [].
rewrite and127; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a64___sha256_x8_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a64___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a64___sha256_x8_absorb_array_spec; proc.
wp; while (valid trace_a64___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 64
       /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 8 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a64___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 8 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 8 64 8 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a64___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 8 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 8 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a64____fill64_array_proof (SBArray512_64.get_sub8 buf (64 * k)) fill a src n ms
                 (SBArray512_64.get_sub buf_init (1 * (64 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 7 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 7 64 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes64_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes64_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 8 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha256_x8_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes8_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 8 64 8 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray64.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7 ho hs hl hosl ha0 ha1 ha2 ha3 ha4 ha5 ha6 ha7.
have [hsum _] := lane_off _off _stride _len 64 7 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes8I _ _ hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and63; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 64 7 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 64 + to_uint _len) %% 64.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 h4 h5 h6 h7 := lanes8E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3 h4 h5 h6 h7.
qed.

lemma a64___sha512_x4_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a64___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a64___sha512_x4_absorb_array_spec; proc.
wp; while (valid trace_a64___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 128
       /\ lanes buf_init 4 128 4 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 4 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a64___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 4 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 4 128 4 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a64___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 64
       /\ (forall k, 0 <= k < 4 =>
             BArray64.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 4 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 4 128 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a64____fill128_array_proof (SBArray512_128.get_sub8 buf (128 * k)) fill a src n ms
                 (SBArray512_128.get_sub buf_init (1 * (128 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 3 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 3 64 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes128_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes128_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 4 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha512_x4_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes4_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 4 128 4 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray64.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 ho hs hl hosl ha0 ha1 ha2 ha3.
have [hsum _] := lane_off _off _stride _len 64 3 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes4I _ _ hb0 hb1 hb2 hb3.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and127; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 64 3 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 by smt().
  by case=> [->|[->|[->|->]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 128 + to_uint _len) %% 128.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 := lanes4E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3.
qed.

lemma a64__sha256_proof _out _a _off _len _out_init _a_init :
  a64__sha256_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a64__sha256_spec; proc.
wp; ecall (arr_sha256___sha256_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a64___sha256_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha256_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray64.init_arrP witness)); smt().
qed.

lemma a64__sha512_proof _out _a _off _len _out_init _a_init :
  a64__sha512_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a64__sha512_spec; proc.
wp; ecall (arr_sha512___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a64___sha512_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha512_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray64.init_arrP witness)); smt().
qed.

lemma a64__sha256_x8_proof _out _a _off _stride _len _out_init _a_init :
  a64__sha256_x8_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a64__sha256_x8_spec; proc.
wp; ecall (arr_sha256_x8_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a64___sha256_x8_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha256_x8_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray64.init_arrP witness)); smt().
qed.

lemma a64__sha512_x4_proof _out _a _off _stride _len _out_init _a_init :
  a64__sha512_x4_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a64__sha512_x4_spec; proc.
wp; ecall (arr_sha512_x4_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a64___sha512_x4_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha512_x4_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray64.init_arrP witness)); smt().
qed.

(* ------------------------------------------------------------------ *)
(* Size 128                                                           *)

lemma a128____fill64_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a128____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a128____fill64_array_spec; proc.
wp; while (valid trace_a128____fill64_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a128____fill64_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask64_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a128____fill64_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 64 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a128____fill128_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a128____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a128____fill128_array_spec; proc.
wp; while (valid trace_a128____fill128_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a128____fill128_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask128_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a128____fill128_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray128.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 128
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 128 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a128___sha256_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a128___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a128___sha256_absorb_array_spec; proc.
wp; while (valid trace_a128___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ BArray64.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 128
       /\ BArray128.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a128___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray64.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 128
       /\ BArray128.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a128____fill64_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha256_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full64_init 0 0); 3: by move=> j _ _; apply (BArray128.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 128 _ ho hl hol; 1: by [].
rewrite and63; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a128___sha512_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a128___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a128___sha512_absorb_array_spec; proc.
wp; while (valid trace_a128___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ BArray128.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 128
       /\ BArray128.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a128___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray128.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 128
       /\ BArray128.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a128____fill128_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha512_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full128_init 0 0); 3: by move=> j _ _; apply (BArray128.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 128 _ ho hl hol; 1: by [].
rewrite and127; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a128___sha256_x8_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a128___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a128___sha256_x8_absorb_array_spec; proc.
wp; while (valid trace_a128___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 64
       /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 8 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a128___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 8 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 8 64 8 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a128___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 8 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 8 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a128____fill64_array_proof (SBArray512_64.get_sub8 buf (64 * k)) fill a src n ms
                 (SBArray512_64.get_sub buf_init (1 * (64 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 7 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 7 128 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes64_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes64_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 8 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha256_x8_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes8_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 8 64 8 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray128.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7 ho hs hl hosl ha0 ha1 ha2 ha3 ha4 ha5 ha6 ha7.
have [hsum _] := lane_off _off _stride _len 128 7 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes8I _ _ hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and63; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 128 7 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 64 + to_uint _len) %% 64.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 h4 h5 h6 h7 := lanes8E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3 h4 h5 h6 h7.
qed.

lemma a128___sha512_x4_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a128___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a128___sha512_x4_absorb_array_spec; proc.
wp; while (valid trace_a128___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 128
       /\ lanes buf_init 4 128 4 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 4 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a128___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 4 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 4 128 4 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a128___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 128
       /\ (forall k, 0 <= k < 4 =>
             BArray128.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 4 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 4 128 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a128____fill128_array_proof (SBArray512_128.get_sub8 buf (128 * k)) fill a src n ms
                 (SBArray512_128.get_sub buf_init (1 * (128 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 3 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 3 128 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes128_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes128_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 4 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha512_x4_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes4_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 4 128 4 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray128.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 ho hs hl hosl ha0 ha1 ha2 ha3.
have [hsum _] := lane_off _off _stride _len 128 3 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes4I _ _ hb0 hb1 hb2 hb3.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and127; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 128 3 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 by smt().
  by case=> [->|[->|[->|->]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 128 + to_uint _len) %% 128.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 := lanes4E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3.
qed.

lemma a128__sha256_proof _out _a _off _len _out_init _a_init :
  a128__sha256_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a128__sha256_spec; proc.
wp; ecall (arr_sha256___sha256_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a128___sha256_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha256_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray128.init_arrP witness)); smt().
qed.

lemma a128__sha512_proof _out _a _off _len _out_init _a_init :
  a128__sha512_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a128__sha512_spec; proc.
wp; ecall (arr_sha512___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a128___sha512_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha512_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray128.init_arrP witness)); smt().
qed.

lemma a128__sha256_x8_proof _out _a _off _stride _len _out_init _a_init :
  a128__sha256_x8_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a128__sha256_x8_spec; proc.
wp; ecall (arr_sha256_x8_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a128___sha256_x8_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha256_x8_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray128.init_arrP witness)); smt().
qed.

lemma a128__sha512_x4_proof _out _a _off _stride _len _out_init _a_init :
  a128__sha512_x4_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a128__sha512_x4_spec; proc.
wp; ecall (arr_sha512_x4_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a128___sha512_x4_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha512_x4_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray128.init_arrP witness)); smt().
qed.

(* ------------------------------------------------------------------ *)
(* Size 333                                                           *)

lemma a333____fill64_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a333____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a333____fill64_array_spec; proc.
wp; while (valid trace_a333____fill64_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a333____fill64_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask64_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a333____fill64_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 64 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a333____fill128_array_proof _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init :
  a333____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init.
proof.
rewrite /a333____fill128_array_spec; proc.
wp; while (valid trace_a333____fill128_array /\ off_init /\ dst_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a333____fill128_array /\ off_init /\ dst_init /\ n_init /\ more_init
       /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum ho ha hon hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (off{m} + W64.of_int 8) = to_uint off{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by move=> i hi1 hi2; apply ha; smt(W64.to_uint_cmp).
  by apply mask128_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace_a333____fill128_array /\ off_init /\ dst_init /\ n_init /\ end_init
       /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint off = to_uint _off_ + (to_uint dst - to_uint _dst_)
       /\ BArray333.is_init a_init (to_uint _off_) (to_uint _n_)
       /\ to_uint _off_ + to_uint _n_ <= 333
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum ho ha hon hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  have hp1 : to_uint (off{m} + W64.one) = to_uint off{m} + 1.
  + by rewrite addone_small; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1,2,4..8: smt(W64.to_uint_cmp).
  + by have := ha (to_uint off{m}) _ _; smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> hd hn hdn hb ho hon ha.
have [hDN hs] := ule_sum _dst_ _n_ 128 _ hd hn hdn; 1: by [].
move: ho hon; rewrite !W64.uleE /= ?to_uint_one => ho hon.
have hos : to_uint (_off_ + _n_) = to_uint _off_ + to_uint _n_.
+ by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ o0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 ho0 _ _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ o1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 ho1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ o2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' ho2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma a333___sha256_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a333___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a333___sha256_absorb_array_spec; proc.
wp; while (valid trace_a333___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ BArray64.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 333
       /\ BArray333.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a333___sha256_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray32.is_init h_init 0 32
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray64.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + to_uint len <= 333
       /\ BArray333.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a333____fill64_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha256_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full64_init 0 0); 3: by move=> j _ _; apply (BArray333.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 333 _ ho hl hol; 1: by [].
rewrite and63; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a333___sha512_absorb_array_proof _h _buf _total _a _off _len _ms _h_init _buf_init _a_init :
  a333___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a333___sha512_absorb_array_spec; proc.
wp; while (valid trace_a333___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ BArray128.is_init buf_init 0 (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 333
       /\ BArray333.is_init a_init (to_uint off) (to_uint len)).
+ sp; seq 1 : (valid trace_a333___sha512_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ len_init /\ ms_init /\ n_init /\ valid M.tmp__trace
       /\ total = _total + _len
       /\ BArray64.is_init h_init 0 64
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ BArray128.is_init buf_init 0 (to_uint fill + to_uint n)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + to_uint len <= 333
       /\ BArray333.is_init a_init (to_uint off) (to_uint len)).
  + ecall (a333____fill128_array_proof buf fill a off n ms buf_init a_init).
    auto => /> &m _ tr htr _ _ _ _ _ _ hh hf hb hm hol ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    have hon : to_uint (off{m} + n) = to_uint off{m} + to_uint n.
    + by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
    rewrite !W64.uleE /= hfn' hon.
    split; 1: by do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
    by move=> _ _ _ _ _ _ r hr hv; do !split => //; smt().
  sp; if.
  + wp; ecall (arr_sha512_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (full128_init 0 0); 3: by move=> j _ _; apply (BArray333.init_arrP witness).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    smt().
  auto => /> &m _ l0 _ o0 _ f0 _ tr htr _ _ _ _ _ _ _ hh hf hnl hfn hfl hfn' hln hb hm hol ha hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  by rewrite hfn' hln eo; do !split; try (move=> i h1 h2; apply ha); smt(W64.to_uint_cmp).
auto => /> hh hb ho hl hol ha.
have [hOL hs] := ule_sum _off _len 333 _ ho hl hol; 1: by [].
rewrite and127; move: hb; rewrite umodc // => hb.
split; 1: by do !split => //; smt(modz_cmp).
move=> a0 b0 f0 _ h0 l0 _ _ _ _ o0 _ _ tr _ _ _ _ _ _ _ _ hl0 _ hf0 hb0 hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
by rewrite e4 -hm0 hz /= pmod_small //; smt(W64.to_uint_cmp).
qed.

lemma a333___sha256_x8_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a333___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a333___sha256_x8_absorb_array_spec; proc.
wp; while (valid trace_a333___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 64
       /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 8 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a333___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 8 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 8 64 8 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a333___sha256_x8_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 64
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 64
       /\ (to_uint fill + to_uint n <> 64 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 64 = (to_uint _total %% 64 + to_uint _len) %% 64
       /\ to_uint off + 7 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 8 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 8 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a333____fill64_array_proof (SBArray512_64.get_sub8 buf (64 * k)) fill a src n ms
                 (SBArray512_64.get_sub buf_init (1 * (64 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 7 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 7 333 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes64_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes64_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 64 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 64 - fill{m} then len{m} else W64.of_int 64 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 8 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha256_x8_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes8_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 8 64 8 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 64) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray333.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7 ho hs hl hosl ha0 ha1 ha2 ha3 ha4 ha5 ha6 ha7.
have [hsum _] := lane_off _off _stride _len 333 7 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes8I _ _ hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and63; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 333 7 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
  by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _len) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 64 + to_uint _len) %% 64.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 h4 h5 h6 h7 := lanes8E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3 h4 h5 h6 h7.
qed.

lemma a333___sha512_x4_absorb_array_proof _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init :
  a333___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init.
proof.
rewrite /a333___sha512_x4_absorb_array_spec; proc.
wp; while (valid trace_a333___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ more_init /\ ms_init
       /\ more = (len <> W64.of_int 0)
       /\ to_uint fill < 128
       /\ lanes buf_init 4 128 4 (to_uint fill) (to_uint fill)
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 4 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))).
+ sp; seq 1 : (valid trace_a333___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 4 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ lanes buf_init 4 128 4 (to_uint fill + to_uint n) (to_uint fill + to_uint n)).
  + while (valid trace_a333___sha512_x4_absorb_array /\ total_init /\ fill_init /\ off_init
       /\ stride_init /\ len_init /\ ms_init /\ n_init
       /\ to_uint fill < 128
       /\ to_uint n <= to_uint len /\ to_uint fill + to_uint n <= 128
       /\ (to_uint fill + to_uint n <> 128 => to_uint n = to_uint len)
       /\ to_uint (fill + n) = to_uint fill + to_uint n
       /\ to_uint (len - n) = to_uint len - to_uint n
       /\ (to_uint fill + to_uint len) %% 128 = (to_uint _total %% 128 + to_uint _len) %% 128
       /\ to_uint off + 3 * to_uint stride + to_uint len <= 333
       /\ (forall k, 0 <= k < 4 =>
             BArray333.is_init a_init (to_uint off + k * to_uint stride) (to_uint len))
       /\ src_init /\ k_init /\ 0 <= k <= 4 /\ to_uint src = to_uint off + k * to_uint stride
       /\ lanes buf_init 4 128 k (to_uint fill) (to_uint fill + to_uint n)).
    + wp; ecall (a333____fill128_array_proof (SBArray512_128.get_sub8 buf (128 * k)) fill a src n ms
                 (SBArray512_128.get_sub buf_init (1 * (128 * k))) a_init).
      auto => /> &m _ _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha _ _ hk0 hk8 hsrc hlb hk.
      have hks : k{m} * to_uint stride{m} <= 3 * to_uint stride{m}.
      + by apply mul_lane; smt(W64.to_uint_cmp).
      have hsb := lane_bound (to_uint off{m}) (to_uint stride{m}) (to_uint len{m}) (to_uint n{m})
                    (k{m} * to_uint stride{m}) 3 333 _ _ _ _ _ hks hosl hnl; 1..5: smt(W64.to_uint_cmp).
      rewrite -hsrc in hsb.
      have hss : to_uint (src{m} + stride{m}) = to_uint src{m} + to_uint stride{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      have hsn : to_uint (src{m} + n{m}) = to_uint src{m} + to_uint n{m}.
      + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
      rewrite !W64.uleE /= hfn' hsn.
      split.
      + do !split; 1..3,5,6: smt(W64.to_uint_cmp).
        + by apply (lanes128_get _ _ _ _ hlb); smt(W64.to_uint_cmp).
        move=> i h1 h2; have hak := ha k{m} _; 1: smt().
        by apply hak; smt(W64.to_uint_cmp).
      move=> _ _ _ _ _ _ _ r hr _; do !split; 1..6: smt().
      + by rewrite hss hsrc; ring.
      by apply (lanes128_set _ _ _ _ _ hlb) => //; smt(W64.to_uint_cmp).
    auto => /> &m _ tr htr _ _ _ _ _ _ _ hf hlb hm hosl ha hnz.
    have /= [#] hnl hfn hfl hfn' hln := absorb_n fill{m} len{m} 128 _ hf; 1: done.
    move: hnl hfn hfl hfn' hln.
    move: (if len{m} \ult W64.of_int 128 - fill{m} then len{m} else W64.of_int 128 - fill{m}).
    move=> n hnl hfn hfl hfn' hln.
    split; 1: by do !split => //; exact (lanes_start _ _ _ _ _ hlb).
    move=> b0 k0 _ s0 _ tr1 hk _ _ _ _ _ _ _ _ hk0 hk8 _ hb.
    have ->> : k0 = 4 by smt().
    exact (lanes_end _ _ _ _ _ hb).
  sp; if.
  + wp; ecall (arr_sha512_x4_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128 by rewrite -hfn' hfull.
    have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
    move: hlb; rewrite e64 => hlb; rewrite (lanes4_full _ hlb).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r _ _; rewrite /protect_64 eo hln.
    do !split; 1: exact (lanes_full 4 128 4 0 0).
    + by rewrite -hm (_ : to_uint f0 + to_uint l0 = (to_uint l0 - to_uint n{m}) + 1 * 128) 1:/# modzMDr.
    + smt().
    by move=> k _ _ j _ _; apply (BArray333.init_arrP witness).
  auto => /> &m _ l0 _ o0 _ f0 tr htr _ _ _ _ _ _ _ hf hnl hfn hfl hfn' hln hm hosl ha hlb hfull.
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq hfn' W64.to_uint_small.
  have eo : to_uint (o0 + n{m}) = to_uint o0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small // w64_modulus; smt(W64.to_uint_cmp).
  have hnz : to_uint (l0 - n{m}) = 0 by rewrite hln; smt().
  rewrite hfn' hnz eo /=; do !split; 1..3: smt(W64.to_uint_cmp).
  + smt().
  by move=> k _ _ j h1 h2; smt().
auto => /> hh hb0 hb1 hb2 hb3 ho hs hl hosl ha0 ha1 ha2 ha3.
have [hsum _] := lane_off _off _stride _len 333 3 0 _ _ _ ho hs hl hosl; 1..3: done.
have hlL := lanes4I _ _ hb0 hb1 hb2 hb3.
move: hlL; rewrite umodc // => hlL.
split.
+ rewrite and127; do !split => //; 1: smt(modz_cmp).
  move=> k hk0 hkL; have [_ <-] := lane_off _off _stride _len 333 3 k _ _ _ ho hs hl hosl; 1..3: smt().
  have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 by smt().
  by case=> [->|[->|[->|->]]] /=.
move=> a0 b0 f0 _ l0 _ _ _ ms0 _ o0 _ s0 _ tr _ _ _ _ _ _ _ _ hl0 hf0 hb0' hm0 _ _.
have e4 : to_uint ((_total + _len) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _len) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hz : to_uint l0 = 0 by smt(W64.to_uint0).
have ef : to_uint f0 = (to_uint _total %% 128 + to_uint _len) %% 128.
+ by move: hm0; rewrite hz /= (pmod_small (to_uint f0)); smt(W64.to_uint_cmp).
have [#] h0 h1 h2 h3 := lanes4E _ _ hb0'.
by rewrite /protect_64 e4 -ef (full256_init 0 256) h0 h1 h2 h3.
qed.

lemma a333__sha256_proof _out _a _off _len _out_init _a_init :
  a333__sha256_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a333__sha256_spec; proc.
wp; ecall (arr_sha256___sha256_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a333___sha256_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha256_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray333.init_arrP witness)); smt().
qed.

lemma a333__sha512_proof _out _a _off _len _out_init _a_init :
  a333__sha512_spec _out _a _off _len _out_init _a_init.
proof.
rewrite /a333__sha512_spec; proc.
wp; ecall (arr_sha512___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a333___sha512_absorb_array_proof h buf total a off len ms h_init buf_init a_init).
wp; ecall (arr__sha512_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray333.init_arrP witness)); smt().
qed.

lemma a333__sha256_x8_proof _out _a _off _stride _len _out_init _a_init :
  a333__sha256_x8_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a333__sha256_x8_spec; proc.
wp; ecall (arr_sha256_x8_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a333___sha256_x8_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha256_x8_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 64) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray333.init_arrP witness)); smt().
qed.

lemma a333__sha512_x4_proof _out _a _off _stride _len _out_init _a_init :
  a333__sha512_x4_spec _out _a _off _stride _len _out_init _a_init.
proof.
rewrite /a333__sha512_x4_spec; proc.
wp; ecall (arr_sha512_x4_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (a333___sha512_x4_absorb_array_proof h buf total a off stride len ms h_init buf_init a_init).
wp; ecall (arr__sha512_x4_init_proof h h_init).
auto => /> &m *.
have e : to_uint (W64.zero \umod W64.of_int 128) = 0 by rewrite umodc // W64.to_uint0.
rewrite e; do !split; move=> j h1 h2; try (by apply (BArray333.init_arrP witness)); smt().
qed.
