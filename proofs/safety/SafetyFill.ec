(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyFill.ec
 * =============
 *
 * Safety of the byte movers of src/fill.jinc and of the byte reversal of
 * src/<arch>/word.jinc: for each function F, the lemma F_proof proves the
 * Hoare triple F_spec of the safety model NirapodSha2Safety, which says
 * that from a state meeting F's #[safety] contract every assertion of F
 * holds (no out-of-bounds access, no read of an uninitialised value) and
 * the contract's ensures hold on return.
 *
 * The text is the same on every unit: these functions are shared, and the
 * proofs do not depend on the instruction the unit uses for a byte
 * reversal.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib BArray64 BArray128 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Masks                                                              *)

lemma mask64_set8 (m : BArray64.t) d :
  BArray64.is_init m 0 d => 0 <= d < 64 =>
  BArray64.is_init (BArray64.set8 m d (W8.of_int 255)) 0 (d + 1).
proof. by move=> hm hd; apply BArray64.is_init_set_last. qed.

lemma mask128_set8 (m : BArray128.t) d :
  BArray128.is_init m 0 d => 0 <= d < 128 =>
  BArray128.is_init (BArray128.set8 m d (W8.of_int 255)) 0 (d + 1).
proof. by move=> hm hd; apply BArray128.is_init_set_last. qed.

lemma mask64_put64 (m : BArray64.t) d :
  BArray64.is_init m 0 d => 0 <= d => d + 8 <= 64 =>
  BArray64.is_init (BArray64.set64d m d (W64.of_int 18446744073709551615)) 0 (d + 8).
proof.
move=> hm hd hd8 j hj0 hj; rewrite BArray64.is_init_cell_set64d.
by case: (j < d) => hjd; [right; apply hm | left] => /#.
qed.

lemma mask128_put64 (m : BArray128.t) d :
  BArray128.is_init m 0 d => 0 <= d => d + 8 <= 128 =>
  BArray128.is_init (BArray128.set64d m d (W64.of_int 18446744073709551615)) 0 (d + 8).
proof.
move=> hm hd hd8 j hj0 hj; rewrite BArray128.is_init_cell_set64d.
by case: (j < d) => hjd; [right; apply hm | left] => /#.
qed.

(* ------------------------------------------------------------------ *)
(* Byte reversal                                                      *)

lemma __bswap32_proof _x : __bswap32_spec _x.
proof. by rewrite /__bswap32_spec; proc; auto => />; rewrite /valid. qed.

lemma __bswap64_proof _x : __bswap64_spec _x.
proof. by rewrite /__bswap64_spec; proc; auto => />; rewrite /valid. qed.

(* ------------------------------------------------------------------ *)
(* __fill64_mem, __fill128_mem                                        *)

lemma __fill64_mem_proof _buf _dst_ _p_ _n_ _ms _buf_init :
  __fill64_mem_spec _buf _dst_ _p_ _n_ _ms _buf_init.
proof.
rewrite /__fill64_mem_spec; proc.
wp; while (valid trace___fill64_mem /\ p_init /\ dst_init /\ end_init /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum hp hv hP0 hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  have hp1 : to_uint (p{m} + W64.one) = to_uint p{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___fill64_mem /\ p_init /\ dst_init /\ n_init /\ more_init /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum hp hv hP0 hPN hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (p{m} + W64.of_int 8) = to_uint p{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask64_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___fill64_mem /\ p_init /\ dst_init /\ n_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 64
       /\ BArray64.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum hp hv hP0 hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  have hp1 : to_uint (p{m} + W64.one) = to_uint p{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> &m hd hn hdn hb hv hp0 hpn.
have [hDN hs] := ule_sum _dst_ _n_ 64 _ hd hn hdn; 1: by [].
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ p0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 hp0' _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ p1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 hp1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ p2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' hp2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.

lemma __fill128_mem_proof _buf _dst_ _p_ _n_ _ms _buf_init :
  __fill128_mem_spec _buf _dst_ _p_ _n_ _ms _buf_init.
proof.
rewrite /__fill128_mem_spec; proc.
wp; while (valid trace___fill128_mem /\ p_init /\ dst_init /\ end_init /\ more_init /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hd' hsum hp hv hP0 hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  have hp1 : to_uint (p{m} + W64.one) = to_uint p{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___fill128_mem /\ p_init /\ dst_init /\ n_init /\ more_init /\ ms_init
       /\ more = (W64.of_int 8 \ule n)
       /\ to_uint _dst_ <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ hd hsum hp hv hP0 hPN hDN hb hlt.
  have hn8 : 8 <= to_uint n{m} by move: hlt; rewrite W64.uleE.
  have hd8 : to_uint (dst{m} + W64.of_int 8) = to_uint dst{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hp8 : to_uint (p{m} + W64.of_int 8) = to_uint p{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  rewrite hd8 hp8 subc_small 1:/#.
  do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask128_put64 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___fill128_mem /\ p_init /\ dst_init /\ n_init /\ end_init /\ more_init
       /\ ms_init
       /\ more = (dst \ult end_0)
       /\ to_uint _dst_ <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint _dst_ + to_uint _n_
       /\ to_uint p = to_uint _p_ + (to_uint dst - to_uint _dst_)
       /\ is_valid (2 ^ 64) Glob.mem_v (to_uint _p_) (to_uint _n_)
       /\ to_uint _dst_ + to_uint _n_ <= 128
       /\ BArray128.is_init buf_init 0 (to_uint dst)).
+ auto => /> &m htr _ _ _ _ _ _ hd hd' hsum hp hv hP0 hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  have hd1 : to_uint (dst{m} + W64.one) = to_uint dst{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  have hp1 : to_uint (p{m} + W64.one) = to_uint p{m} + 1.
  + by rewrite W64.to_uintD_small to_uint_one // w64_modulus; smt(W64.to_uint_cmp).
  rewrite hd1 hp1; do !split; 1: (by move=> i hi1 hi2; apply hv; smt(W64.to_uint_cmp)); 1..7: smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> &m hd hn hdn hb hv hp0 hpn.
have [hDN hs] := ule_sum _dst_ _n_ 128 _ hd hn hdn; 1: by [].
have := fill_head _dst_ _n_ _; 1: smt().
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first smt(W64.to_uint_cmp).
move=> bi0 d0 _ m0 _ _ p0 _ tr0 hm0 htr0 _ _ _ _ hlt0 hd0 hd0' hsum0 hp0' _ hb0.
have he0 : to_uint d0 = to_uint _dst_ + to_uint (if _n_ \ult (-_dst_) `&` W64.of_int 7 then _n_
                                              else (-_dst_) `&` W64.of_int 7).
+ by move: hlt0; rewrite W64.ultE hdh /#.
split; first smt().
move=> bi1 d1 _ m1 _ _ n0 _ p1 _ tr1 hm1 htr1 _ _ _ _ _ hle1 hd1 hsum1 hp1 hb1.
have hs1 : to_uint (d1 + n0) = to_uint d1 + to_uint n0.
+ by rewrite W64.to_uintD_small //; rewrite w64_modulus /#.
rewrite hs1 hsum1 /=; split; first smt(W64.to_uint_cmp).
move=> bi2 d2 _ m2 _ _ p2 _ tr2 hm2 htr2 _ _ _ _ hlt2 hd2 hd2' hp2 hb2.
have -> : to_uint (_dst_ + _n_) = to_uint d2.
+ by move: hlt2 hd2'; rewrite W64.ultE hs1 hs /#.
exact hb2.
qed.


(* ------------------------------------------------------------------ *)
(* __zero64, __zero128                                                *)

lemma __zero64_proof _buf _lo_ _hi _ms _buf_init :
  __zero64_spec _buf _lo_ _hi _ms _buf_init.
proof.
rewrite /__zero64_spec; proc.
wp; while (valid trace___zero64 /\ lo_init /\ more_init /\ ms_init /\ z_init /\ hi_init
       /\ hi = _hi /\ more = (lo \ult _hi)
       /\ to_uint _lo_ <= to_uint lo <= to_uint _hi <= 64
       /\ BArray64.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ hl hl' hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint _hi by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp).
  do !split; 1..4: smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___zero64 /\ lo_init /\ end_init /\ more_init /\ ms_init /\ z_init
       /\ hi_init /\ hi = _hi /\ more = (end_0 \ule _hi)
       /\ to_uint end_0 = to_uint lo + 8
       /\ to_uint _lo_ <= to_uint lo <= to_uint _hi <= 64
       /\ BArray64.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ _ he hl hl' hH hb hle.
  have hle' : to_uint lo{m} + 8 <= to_uint _hi by rewrite -he -W64.uleE.
  have h8 : to_uint (lo{m} + W64.of_int 8) = to_uint lo{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have h16 : to_uint (lo{m} + W64.of_int 16) = to_uint lo{m} + 16.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hm := mask64_put64 buf_init{m} (to_uint lo{m}) hb _ _; 1,2: smt(W64.to_uint_cmp).
  by rewrite h8 h16; do !split; smt(W64.to_uint_cmp).
wp; while (valid trace___zero64 /\ lo_init /\ end_init /\ more_init /\ ms_init /\ z_init
       /\ more = (lo \ult end_0)
       /\ to_uint _lo_ <= to_uint lo
       /\ (to_uint lo <= to_uint end_0 \/ to_uint lo = to_uint _lo_)
       /\ to_uint end_0 <= to_uint _hi <= 64
       /\ BArray64.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ hl hl' he hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp).
  do !split; 1..4: smt(W64.to_uint_cmp).
  by apply mask64_set8 => //; smt(W64.to_uint_cmp).
auto => /> hlh hh64 hb.
have hH : to_uint _hi <= 64 by move: hh64; rewrite W64.uleE.
have hLH : to_uint _lo_ <= to_uint _hi by rewrite -W64.uleE.
split; first by rewrite min_le.
move=> bi0 l0 _ m0 _ _ tr0 hm0 htr0 _ _ _ hlt0 hl0 hl0' he0 _ hb0.
have hl0h : to_uint l0 <= to_uint _hi by smt().
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> bi1 e1 _ l1 _ m1 _ _ tr1 hm1 htr1 _ _ _ _ hle1 he1 hl1 hl1' hb1.
move=> bi2 l2 _ m2 _ _ tr2 hm2 htr2 _ _ _ hlt2 hl2 hl2' hb2.
have -> : to_uint _hi = to_uint l2 by move: hlt2; rewrite W64.ultE /#.
exact hb2.
qed.

lemma __zero128_proof _buf _lo_ _hi _ms _buf_init :
  __zero128_spec _buf _lo_ _hi _ms _buf_init.
proof.
rewrite /__zero128_spec; proc.
wp; while (valid trace___zero128 /\ lo_init /\ more_init /\ ms_init /\ z_init /\ hi_init
       /\ hi = _hi /\ more = (lo \ult _hi)
       /\ to_uint _lo_ <= to_uint lo <= to_uint _hi <= 128
       /\ BArray128.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ hl hl' hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint _hi by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp).
  do !split; 1..4: smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
wp; while (valid trace___zero128 /\ lo_init /\ end_init /\ more_init /\ ms_init /\ z_init
       /\ hi_init /\ hi = _hi /\ more = (end_0 \ule _hi)
       /\ to_uint end_0 = to_uint lo + 8
       /\ to_uint _lo_ <= to_uint lo <= to_uint _hi <= 128
       /\ BArray128.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ _ he hl hl' hH hb hle.
  have hle' : to_uint lo{m} + 8 <= to_uint _hi by rewrite -he -W64.uleE.
  have h8 : to_uint (lo{m} + W64.of_int 8) = to_uint lo{m} + 8.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have h16 : to_uint (lo{m} + W64.of_int 16) = to_uint lo{m} + 16.
  + by rewrite addc_small //; smt(W64.to_uint_cmp).
  have hm := mask128_put64 buf_init{m} (to_uint lo{m}) hb _ _; 1,2: smt(W64.to_uint_cmp).
  by rewrite h8 h16; do !split; smt(W64.to_uint_cmp).
wp; while (valid trace___zero128 /\ lo_init /\ end_init /\ more_init /\ ms_init /\ z_init
       /\ more = (lo \ult end_0)
       /\ to_uint _lo_ <= to_uint lo
       /\ (to_uint lo <= to_uint end_0 \/ to_uint lo = to_uint _lo_)
       /\ to_uint end_0 <= to_uint _hi <= 128
       /\ BArray128.is_init buf_init 0 (to_uint lo)).
+ auto => /> &m htr _ _ _ _ _ hl hl' he hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp).
  do !split; 1..4: smt(W64.to_uint_cmp).
  by apply mask128_set8 => //; smt(W64.to_uint_cmp).
auto => /> hlh hh64 hb.
have hH : to_uint _hi <= 128 by move: hh64; rewrite W64.uleE.
have hLH : to_uint _lo_ <= to_uint _hi by rewrite -W64.uleE.
split; first by rewrite min_le.
move=> bi0 l0 _ m0 _ _ tr0 hm0 htr0 _ _ _ hlt0 hl0 hl0' he0 _ hb0.
have hl0h : to_uint l0 <= to_uint _hi by smt().
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> bi1 e1 _ l1 _ m1 _ _ tr1 hm1 htr1 _ _ _ _ hle1 he1 hl1 hl1' hb1.
move=> bi2 l2 _ m2 _ _ tr2 hm2 htr2 _ _ _ hlt2 hl2 hl2' hb2.
have -> : to_uint _hi = to_uint l2 by move: hlt2; rewrite W64.ultE /#.
exact hb2.
qed.

