(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Fill.ec
 * =======
 *
 * Functional correctness of the byte movers of src/fill.jinc.
 *
 * __fill64_mem buf dst p n copies the n bytes at p into buf[dst, dst + n)
 * and leaves the other cells of buf as they were; __zero64 buf lo hi
 * clears buf[lo, hi) and leaves the rest. Each mover runs a byte loop up to
 * an 8-byte boundary, a 64-bit loop, and a byte loop for the remainder;
 * the theorems below say nothing about that split, only about the cells.
 * The 128-byte forms are the same text over a 128-byte buffer.
 *
 * Domain: the written range lies inside the buffer and the source range
 * does not wrap the address space. The movers read memory and never write
 * it.
 *)

require import AllCore IntDiv List.
from Jasmin require import JWord JUtils JMemory.
require import SafetyLib BArray64 BArray128 NirapodSha2 StreamSpec.

(* ------------------------------------------------------------------ *)
(* The cells of a filled or cleared buffer                            *)

(* b is b0 with cells [d, e) taken from memory from address p on. *)
op fill64v (b0 : BArray64.t) (mem : global_mem_t) (d p e : int) (b : BArray64.t) =
  forall i, 0 <= i < 64 =>
    BArray64.get8 b i
    = if d <= i < e then loadW8 mem (p + (i - d)) else BArray64.get8 b0 i.

op fill128v (b0 : BArray128.t) (mem : global_mem_t) (d p e : int) (b : BArray128.t) =
  forall i, 0 <= i < 128 =>
    BArray128.get8 b i
    = if d <= i < e then loadW8 mem (p + (i - d)) else BArray128.get8 b0 i.

(* b is b0 with cells [lo, hi) cleared. *)
op zero64v (b0 : BArray64.t) (lo hi : int) (b : BArray64.t) =
  forall i, 0 <= i < 64 =>
    BArray64.get8 b i = if lo <= i < hi then W8.zero else BArray64.get8 b0 i.

op zero128v (b0 : BArray128.t) (lo hi : int) (b : BArray128.t) =
  forall i, 0 <= i < 128 =>
    BArray128.get8 b i = if lo <= i < hi then W8.zero else BArray128.get8 b0 i.

lemma fill64v_nil b0 mem d p : fill64v b0 mem d p d b0.
proof. by move=> i hi /#. qed.

lemma fill128v_nil b0 mem d p : fill128v b0 mem d p d b0.
proof. by move=> i hi /#. qed.

lemma zero64v_nil b0 lo : zero64v b0 lo lo b0.
proof. by move=> i hi /#. qed.

lemma zero128v_nil b0 lo : zero128v b0 lo lo b0.
proof. by move=> i hi /#. qed.

(* One byte, then eight bytes, appended to the filled range. *)
lemma fill64v_set8 b b0 mem d p e :
  0 <= d <= e < 64 => fill64v b0 mem d p e b =>
  fill64v b0 mem d p (e + 1) (BArray64.set8 b e (loadW8 mem (p + (e - d)))).
proof.
move=> he hb i hi; rewrite BArray64.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma fill64v_set64 b b0 mem d p e :
  0 <= d <= e => e + 8 <= 64 => fill64v b0 mem d p e b =>
  fill64v b0 mem d p (e + 8) (BArray64.set64d b e (loadW64 mem (p + (e - d)))).
proof.
move=> he he8 hb i hi; rewrite BArray64.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=.
+ rewrite hi /= loadW64_bits8 1:/#; smt().
by rewrite hb //; smt().
qed.

lemma fill128v_set8 b b0 mem d p e :
  0 <= d <= e < 128 => fill128v b0 mem d p e b =>
  fill128v b0 mem d p (e + 1) (BArray128.set8 b e (loadW8 mem (p + (e - d)))).
proof.
move=> he hb i hi; rewrite BArray128.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma fill128v_set64 b b0 mem d p e :
  0 <= d <= e => e + 8 <= 128 => fill128v b0 mem d p e b =>
  fill128v b0 mem d p (e + 8) (BArray128.set64d b e (loadW64 mem (p + (e - d)))).
proof.
move=> he he8 hb i hi; rewrite BArray128.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=.
+ rewrite hi /= loadW64_bits8 1:/#; smt().
by rewrite hb //; smt().
qed.

lemma trunc_zero : truncateu8 W64.zero = W8.zero.
proof. by rewrite /truncateu8 W64.to_uint0. qed.

lemma zero64v_set8 b b0 lo e :
  0 <= lo <= e < 64 => zero64v b0 lo e b =>
  zero64v b0 lo (e + 1) (BArray64.set8 b e W8.zero).
proof.
move=> he hb i hi; rewrite BArray64.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma zero64v_set64 b b0 lo e :
  0 <= lo <= e => e + 8 <= 64 => zero64v b0 lo e b =>
  zero64v b0 lo (e + 8) (BArray64.set64d b e W64.zero).
proof.
move=> he he8 hb i hi; rewrite BArray64.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=; first by rewrite W8u8.get_zero; smt().
by rewrite hb //; smt().
qed.

lemma zero128v_set8 b b0 lo e :
  0 <= lo <= e < 128 => zero128v b0 lo e b =>
  zero128v b0 lo (e + 1) (BArray128.set8 b e W8.zero).
proof.
move=> he hb i hi; rewrite BArray128.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma zero128v_set64 b b0 lo e :
  0 <= lo <= e => e + 8 <= 128 => zero128v b0 lo e b =>
  zero128v b0 lo (e + 8) (BArray128.set64d b e W64.zero).
proof.
move=> he he8 hb i hi; rewrite BArray128.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=; first by rewrite W8u8.get_zero; smt().
by rewrite hb //; smt().
qed.

(* ------------------------------------------------------------------ *)
(* __fill64_mem                                                       *)

lemma fill64_correct (b0 : BArray64.t) (d0 p0 n0 : W64.t) :
  hoare [M.__fill64_mem :
           buf = b0 /\ dst_ = d0 /\ p_ = p0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 64 /\ to_uint p0 + to_uint n0 < W64.modulus ==>
           fill64v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint d0 + to_uint n0) res.`1].
proof.
proc.
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hd' he hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill64v_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (W64.of_int 8 \ule n)
       /\ to_uint d0 <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hsum hp hPN hDN hb hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  rewrite subc_small 1:/# hp; do !split; 1..3: smt().
  by apply fill64v_set64 => //; smt(W64.to_uint_cmp).
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hd' hsum hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill64v_set8 => //; smt(W64.to_uint_cmp).
auto => /> &hr hDN hPN.
have := fill_head d0 n0 _; 1: smt(W64.to_uint_cmp).
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first by do !split; [smt(W64.to_uint_cmp) | smt() | exact fill64v_nil].
move=> b1 d1 m1 p1 hn1 hm1 hd1 hd1' hsum1 hp1 hb1.
have he1 : to_uint d1 = to_uint d0 + to_uint (if n0 \ult (-d0) `&` W64.of_int 7 then n0
                                              else (-d0) `&` W64.of_int 7).
+ by move: hm1; rewrite eq_sym W64.ultE hdh /#.
split; first smt().
move=> b2 d2 m2 n2 p2 hn2 hm2 hd2 hsum2 hp2 hb2.
have hs2 : to_uint (d2 + n2) = to_uint d2 + to_uint n2.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite hs2 hsum2 /=; split; first smt(W64.to_uint_cmp).
move=> b3 d3 m3 p3 hn3 hm3 hd3 hd3' hp3 hb3.
have -> : to_uint d0 + to_uint n0 = to_uint d3.
+ by move: hm3; rewrite eq_sym W64.ultE; smt().
exact hb3.
qed.

lemma fill64_ll : islossless M.__fill64_mem.
proof.
proc.
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (W64.of_int 8 \ule n)) (to_uint n).
+ move=> z; auto => /> &m hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite subc_small; smt().
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m d1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ d2 m2 n2; split; first by rewrite W64.uleE /=; smt().
move=> _ _ d3 m3; rewrite W64.ultE; smt().
qed.

lemma fill64_total (b0 : BArray64.t) (d0 p0 n0 : W64.t) :
  phoare [M.__fill64_mem :
           buf = b0 /\ dst_ = d0 /\ p_ = p0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 64 /\ to_uint p0 + to_uint n0 < W64.modulus ==>
           fill64v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint d0 + to_uint n0) res.`1]
  = 1%r.
proof. by conseq fill64_ll (fill64_correct b0 d0 p0 n0). qed.

(* ------------------------------------------------------------------ *)
(* __zero64                                                           *)

lemma zero64_correct (b0 : BArray64.t) (l0 h0 : W64.t) :
  hoare [M.__zero64 :
           buf = b0 /\ lo_ = l0 /\ hi = h0 /\ to_uint l0 <= to_uint h0 <= 64 ==>
           zero64v b0 (to_uint l0) (to_uint h0) res.`1].
proof.
proc.
wp; while (more = (lo \ult hi) /\ hi = h0 /\ z = W64.zero
       /\ to_uint l0 <= to_uint lo <= to_uint h0 <= 64
       /\ zero64v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m hl hl' hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint h0 by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp w64_modulus).
  rewrite trunc_zero; do !split; 1..2: smt().
  by apply zero64v_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (end_0 \ule hi) /\ hi = h0 /\ z = W64.zero
       /\ to_uint end_0 = to_uint lo + 8
       /\ to_uint l0 <= to_uint lo <= to_uint h0 <= 64
       /\ zero64v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m he hl hl' hH hb hle.
  have hle' : to_uint lo{m} + 8 <= to_uint h0 by rewrite -he -W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  have := zero64v_set64 buf{m} b0 (to_uint l0) (to_uint lo{m}) _ _ hb; 1,2: smt(W64.to_uint_cmp).
  by move=> hz; do !split; smt().
wp; while (more = (lo \ult end_0) /\ hi = h0 /\ z = W64.zero
       /\ to_uint l0 <= to_uint lo
       /\ (to_uint lo <= to_uint end_0 \/ to_uint lo = to_uint l0)
       /\ to_uint end_0 <= to_uint h0 <= 64
       /\ zero64v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m hl hl' he hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp w64_modulus).
  rewrite trunc_zero; do !split; 1..2: smt().
  by apply zero64v_set8 => //; smt(W64.to_uint_cmp).
auto => /> hLH hH.
split; first by split; [apply min_le | exact zero64v_nil].
move=> b1 l1 m1 hn1 hm1 hl1 hl1' he1 hb1.
have hl1h : to_uint l1 <= to_uint h0 by smt().
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> b2 e2 l2 m2 hn2 hm2 he2 hl2 hl2' hb2.
move=> b3 l3 m3 hn3 hm3 hl3 hl3' hb3.
have -> : to_uint h0 = to_uint l3 by move: hm3; rewrite eq_sym W64.ultE /#.
exact hb3.
qed.

lemma zero64_ll :
  phoare [M.__zero64 : to_uint lo_ <= to_uint hi <= 64 ==> true] = 1%r.
proof.
proc.
wp; while (more = (lo \ult hi)) (to_uint hi - to_uint lo).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint lo{m} < to_uint hi{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (end_0 \ule hi) /\ to_uint end_0 = to_uint lo + 8 /\ to_uint hi <= 64)
          (to_uint hi - to_uint lo).
+ move=> z; auto => /> &m he hH hle.
  have hle' : to_uint lo{m} + 8 <= to_uint hi{m} by rewrite -he -W64.uleE.
  rewrite !addc_small //; smt(W64.to_uint_cmp).
wp; while (more = (lo \ult end_0) /\ to_uint lo <= 64 /\ to_uint end_0 <= 64 /\ to_uint hi <= 64)
          (to_uint end_0 - to_uint lo).
+ move=> z; auto => /> &m hl he hH hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m hLH hH.
have hm := min_le hi{m} ((lo_{m} + W64.of_int 7) `&` W64.of_int 18446744073709551608).
split; first by smt().
move=> l1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ hl1 he1.
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> e2 l2 m2; split; first by rewrite W64.uleE; smt().
move=> _ _ _ l3; rewrite W64.ultE; smt().
qed.

lemma zero64_total (b0 : BArray64.t) (l0 h0 : W64.t) :
  phoare [M.__zero64 :
           buf = b0 /\ lo_ = l0 /\ hi = h0 /\ to_uint l0 <= to_uint h0 <= 64 ==>
           zero64v b0 (to_uint l0) (to_uint h0) res.`1] = 1%r.
proof. by conseq zero64_ll (zero64_correct b0 l0 h0) => /#. qed.

(* ------------------------------------------------------------------ *)
(* __fill128_mem                                                       *)

lemma fill128_correct (b0 : BArray128.t) (d0 p0 n0 : W64.t) :
  hoare [M.__fill128_mem :
           buf = b0 /\ dst_ = d0 /\ p_ = p0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 128 /\ to_uint p0 + to_uint n0 < W64.modulus ==>
           fill128v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint d0 + to_uint n0) res.`1].
proof.
proc.
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hd' he hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill128v_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (W64.of_int 8 \ule n)
       /\ to_uint d0 <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hsum hp hPN hDN hb hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  rewrite subc_small 1:/# hp; do !split; 1..3: smt().
  by apply fill128v_set64 => //; smt(W64.to_uint_cmp).
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint p = to_uint p0 + (to_uint dst - to_uint d0)
       /\ to_uint p0 + to_uint n0 < W64.modulus /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint dst) buf).
+ auto => /> &m hd hd' hsum hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill128v_set8 => //; smt(W64.to_uint_cmp).
auto => /> &hr hDN hPN.
have := fill_head d0 n0 _; 1: smt(W64.to_uint_cmp).
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first by do !split; [smt(W64.to_uint_cmp) | smt() | exact fill128v_nil].
move=> b1 d1 m1 p1 hn1 hm1 hd1 hd1' hsum1 hp1 hb1.
have he1 : to_uint d1 = to_uint d0 + to_uint (if n0 \ult (-d0) `&` W64.of_int 7 then n0
                                              else (-d0) `&` W64.of_int 7).
+ by move: hm1; rewrite eq_sym W64.ultE hdh /#.
split; first smt().
move=> b2 d2 m2 n2 p2 hn2 hm2 hd2 hsum2 hp2 hb2.
have hs2 : to_uint (d2 + n2) = to_uint d2 + to_uint n2.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite hs2 hsum2 /=; split; first smt(W64.to_uint_cmp).
move=> b3 d3 m3 p3 hn3 hm3 hd3 hd3' hp3 hb3.
have -> : to_uint d0 + to_uint n0 = to_uint d3.
+ by move: hm3; rewrite eq_sym W64.ultE; smt().
exact hb3.
qed.

lemma fill128_ll : islossless M.__fill128_mem.
proof.
proc.
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (W64.of_int 8 \ule n)) (to_uint n).
+ move=> z; auto => /> &m hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite subc_small; smt().
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m d1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ d2 m2 n2; split; first by rewrite W64.uleE /=; smt().
move=> _ _ d3 m3; rewrite W64.ultE; smt().
qed.

lemma fill128_total (b0 : BArray128.t) (d0 p0 n0 : W64.t) :
  phoare [M.__fill128_mem :
           buf = b0 /\ dst_ = d0 /\ p_ = p0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 128 /\ to_uint p0 + to_uint n0 < W64.modulus ==>
           fill128v b0 Glob.mem (to_uint d0) (to_uint p0) (to_uint d0 + to_uint n0) res.`1]
  = 1%r.
proof. by conseq fill128_ll (fill128_correct b0 d0 p0 n0). qed.

(* ------------------------------------------------------------------ *)
(* __zero128                                                           *)

lemma zero128_correct (b0 : BArray128.t) (l0 h0 : W64.t) :
  hoare [M.__zero128 :
           buf = b0 /\ lo_ = l0 /\ hi = h0 /\ to_uint l0 <= to_uint h0 <= 128 ==>
           zero128v b0 (to_uint l0) (to_uint h0) res.`1].
proof.
proc.
wp; while (more = (lo \ult hi) /\ hi = h0 /\ z = W64.zero
       /\ to_uint l0 <= to_uint lo <= to_uint h0 <= 128
       /\ zero128v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m hl hl' hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint h0 by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp w64_modulus).
  rewrite trunc_zero; do !split; 1..2: smt().
  by apply zero128v_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (end_0 \ule hi) /\ hi = h0 /\ z = W64.zero
       /\ to_uint end_0 = to_uint lo + 8
       /\ to_uint l0 <= to_uint lo <= to_uint h0 <= 128
       /\ zero128v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m he hl hl' hH hb hle.
  have hle' : to_uint lo{m} + 8 <= to_uint h0 by rewrite -he -W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  have := zero128v_set64 buf{m} b0 (to_uint l0) (to_uint lo{m}) _ _ hb; 1,2: smt(W64.to_uint_cmp).
  by move=> hz; do !split; smt().
wp; while (more = (lo \ult end_0) /\ hi = h0 /\ z = W64.zero
       /\ to_uint l0 <= to_uint lo
       /\ (to_uint lo <= to_uint end_0 \/ to_uint lo = to_uint l0)
       /\ to_uint end_0 <= to_uint h0 <= 128
       /\ zero128v b0 (to_uint l0) (to_uint lo) buf).
+ auto => /> &m hl hl' he hH hb hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; 1: smt(W64.to_uint_cmp w64_modulus).
  rewrite trunc_zero; do !split; 1..2: smt().
  by apply zero128v_set8 => //; smt(W64.to_uint_cmp).
auto => /> hLH hH.
split; first by split; [apply min_le | exact zero128v_nil].
move=> b1 l1 m1 hn1 hm1 hl1 hl1' he1 hb1.
have hl1h : to_uint l1 <= to_uint h0 by smt().
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> b2 e2 l2 m2 hn2 hm2 he2 hl2 hl2' hb2.
move=> b3 l3 m3 hn3 hm3 hl3 hl3' hb3.
have -> : to_uint h0 = to_uint l3 by move: hm3; rewrite eq_sym W64.ultE /#.
exact hb3.
qed.

lemma zero128_ll :
  phoare [M.__zero128 : to_uint lo_ <= to_uint hi <= 128 ==> true] = 1%r.
proof.
proc.
wp; while (more = (lo \ult hi)) (to_uint hi - to_uint lo).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint lo{m} < to_uint hi{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (end_0 \ule hi) /\ to_uint end_0 = to_uint lo + 8 /\ to_uint hi <= 128)
          (to_uint hi - to_uint lo).
+ move=> z; auto => /> &m he hH hle.
  have hle' : to_uint lo{m} + 8 <= to_uint hi{m} by rewrite -he -W64.uleE.
  rewrite !addc_small //; smt(W64.to_uint_cmp).
wp; while (more = (lo \ult end_0) /\ to_uint lo <= 128 /\ to_uint end_0 <= 128 /\ to_uint hi <= 128)
          (to_uint end_0 - to_uint lo).
+ move=> z; auto => /> &m hl he hH hlt.
  have hlt' : to_uint lo{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m hLH hH.
have hm := min_le hi{m} ((lo_{m} + W64.of_int 7) `&` W64.of_int 18446744073709551608).
split; first by smt().
move=> l1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ hl1 he1.
rewrite addc_small //; 1: smt(W64.to_uint_cmp).
split; first done.
move=> e2 l2 m2; split; first by rewrite W64.uleE; smt().
move=> _ _ _ l3; rewrite W64.ultE; smt().
qed.

lemma zero128_total (b0 : BArray128.t) (l0 h0 : W64.t) :
  phoare [M.__zero128 :
           buf = b0 /\ lo_ = l0 /\ hi = h0 /\ to_uint l0 <= to_uint h0 <= 128 ==>
           zero128v b0 (to_uint l0) (to_uint h0) res.`1] = 1%r.
proof. by conseq zero128_ll (zero128_correct b0 l0 h0) => /#. qed.
