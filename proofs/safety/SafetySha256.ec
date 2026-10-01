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


(* ------------------------------------------------------------------ *)
(* Absorb                                                             *)

(* The head of an absorb: f bytes are buffered, and n of the l input
   bytes top the buffer up (none when it is empty). *)
lemma absorb_head256 (t l f n : W64.t) :
  f = t `&` W64.of_int 63 =>
  n = (if f = W64.of_int 0 then f
       else if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f) =>
  to_uint f = to_uint t %% 64 /\ to_uint f + to_uint n <= 64
  /\ to_uint n <= to_uint l /\ to_uint (l - n) = to_uint l - to_uint n
  /\ (to_uint f = 0 => to_uint n = 0)
  /\ (to_uint f <> 0 => to_uint f + to_uint n <> 64 => to_uint n = to_uint l).
proof.
move=> hfd ->.
have hf : to_uint f = to_uint t %% 64 by rewrite hfd and63.
have hf64 : to_uint f < 64 by smt(modz_cmp).
have hs : to_uint (W64.of_int 64 - f) = 64 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE; smt(W64.of_uintK).
have hz : (f = W64.of_int 0) <=> to_uint f = 0 by rewrite W64.to_uint_eq.
case: (f = W64.of_int 0) => hf0 /=.
+ have h0 : to_uint f = 0 by rewrite hf0 W64.to_uint0.
  by rewrite W64.to_uintB 1:W64.uleE; smt(W64.to_uint_cmp).
case: (l \ult W64.of_int 64 - f) => hl /=.
+ by move: hl; rewrite W64.ultE hs; smt(W64.to_uint_cmp).
move: hl; rewrite W64.ultE hs => hl.
by rewrite W64.to_uintB 1:W64.uleE 1:hs; smt(W64.to_uint_cmp).
qed.

lemma _sha256_absorb_mem_proof _h _buf _total _in _inlen _ms _h_init _buf_init :
  _sha256_absorb_mem_spec _h _buf _total _in _inlen _ms _h_init _buf_init.
proof.
rewrite /_sha256_absorb_mem_spec; proc; sp.
seq 1 : (valid trace__sha256_absorb_mem /\ total_init /\ fill_init /\ in_init
         /\ inlen_init /\ ms_init /\ n_init /\ valid M.tmp__trace
         /\ total = _total + _inlen
         /\ BArray32.is_init h_init 0 32 /\ to_uint fill + to_uint n <= 64
         /\ BArray64.is_init buf_init 0 (to_uint fill + to_uint n)
         /\ (to_uint fill = 0 => to_uint n = 0)
         /\ (to_uint fill <> 0 => to_uint fill + to_uint n <> 64 => to_uint inlen = 0)
         /\ to_uint fill + to_uint n + to_uint inlen = to_uint _total %% 64 + to_uint _inlen
         /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint n + to_uint inlen)).
+ ecall (__fill64_mem_proof buf fill in_0 n ms buf_init).
  auto => /> &m hh hb hv hp0 hpl.
  pose f := _total `&` W64.of_int 63.
  pose n := if f = W64.of_int 0 then f
            else if _inlen \ult W64.of_int 64 - f then _inlen else W64.of_int 64 - f.
  have [#] hf hfn hnl hln hf0 hfl := absorb_head256 _total _inlen f n _ _ => //.
  have hfn' : to_uint (f + n) = to_uint f + to_uint n.
  + by rewrite W64.to_uintD_small; smt().
  rewrite !W64.uleE /= hfn' hln; move: hb; rewrite umodc // -hf => hb.
  split; 2: move=> _ _ _ _ _ _ _ r hr _.
  + by do !split => //; try (move=> i h1 h2; apply hv => /#); smt().
  by do !split => //; try (move=> i h1 h2; apply hv => /#); smt().
sp; seq 1 : (valid trace__sha256_absorb_mem /\ total_init /\ fill_init /\ in_init
             /\ inlen_init /\ ms_init /\ total = _total + _inlen
             /\ BArray32.is_init h_init 0 32 /\ to_uint fill < 64
             /\ BArray64.is_init buf_init 0 (to_uint fill)
             /\ (to_uint fill <> 0 => to_uint inlen = 0)
             /\ (to_uint fill + to_uint inlen) %% 64
                = (to_uint _total %% 64 + to_uint _inlen) %% 64
             /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint inlen)).
+ if.
  + wp; ecall (_sha256_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ in0 _ f0 _ _ _ _ _ _ _ _ _ hT hh hfn hb hf0 hfl hsum hv hp0 hpl hfull.
    have e64 : to_uint f0 + to_uint n{m} = 64.
    + by rewrite -W64.to_uintD_small 1:/# hfull W64.to_uint_small.
    have ein : to_uint (in0 + n{m}) = to_uint in0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 ein.
    have hm : to_uint inlen{m} %% 64 = (to_uint _total %% 64 + to_uint _inlen) %% 64.
    + by rewrite (_ : to_uint _total %% 64 + to_uint _inlen = to_uint inlen{m} + 1 * 64)
        1:/# modzMDr.
    do !split => //; try exact (full64_init 0 0); try (move=> i h1 h2; apply hv);
      smt(W64.to_uint_cmp).
  auto => /> &m _ in0 _ f0 _ _ _ _ _ _ _ _ _ hT hh hfn hb hf0 hfl hsum hv hp0 hpl hfull.
  have efn : to_uint (f0 + n{m}) = to_uint f0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  have ein : to_uint (in0 + n{m}) = to_uint in0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq efn W64.to_uint_small.
  rewrite efn ein; do !split => //; try (move=> i h1 h2; apply hv); smt(W64.to_uint_cmp).
sp; seq 1 : (valid trace__sha256_absorb_mem /\ total_init /\ fill_init /\ in_init
             /\ inlen_init /\ ms_init /\ off_init /\ total = _total + _inlen
             /\ BArray32.is_init h_init 0 32 /\ to_uint off <= to_uint inlen
             /\ to_uint fill + (to_uint inlen - to_uint off)
                = (to_uint _total %% 64 + to_uint _inlen) %% 64
             /\ BArray64.is_init buf_init 0 (to_uint fill)
             /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint inlen)).
+ if.
  + wp; ecall (_sha256_compress_blocks_proof h in_0 n ms h_init).
    auto => /> &m _ _ _ _ _ _ _ hh hf hb hf0 hm hv hp0 hpl hnz.
    have hn : to_uint (inlen{m} `>>` W8.of_int 6) = to_uint inlen{m} %/ 64.
    + by have := shrc inlen{m} 6 _.
    have ho : to_uint ((inlen{m} `>>` W8.of_int 6) `<<` W8.of_int 6)
              = 64 * (to_uint inlen{m} %/ 64).
    + by have := blocksc inlen{m} 6 _.
    have hn1 := nonzero _ hnz.
    have e := mulc_small (inlen{m} `>>` W8.of_int 6) 64 _ _; 1,2: smt(W64.to_uint_cmp).
    have hdm := divz_eq (to_uint inlen{m}) 64.
    have hz : to_uint fill{m} = 0 by smt(W64.to_uint_cmp).
    rewrite /protect_64 e ho hn W64.ultE hn W64.to_uint_small //=.
    split; 1: by do !split; try (move=> i h1 h2; apply hv); smt(modz_ge0 W64.to_uint_cmp).
    move=> _ _ _ _ r _ _; split; 1: smt(modz_ge0).
    split; 1: by move: hm; rewrite hz /=; smt().
    split; 1: exact (full64_init 0 0).
    by move=> i h1 h2; apply hv.
  auto => /> &m _ _ _ _ _ _ _ hh hf hb hf0 hm hv hp0 hpl hz.
  have hn : to_uint inlen{m} %/ 64 = 0.
  + have := shrc inlen{m} 6 _; 1: done.
    by rewrite hz W64.to_uint0 => ->.
  have hl : to_uint inlen{m} < 64 by smt(divz_eq modz_ge0 ltz_pmod W64.to_uint_cmp).
  by rewrite -hm pmod_small; smt(W64.to_uint_cmp).
wp; ecall (__fill64_mem_proof buf fill in_0 inlen ms buf_init).
auto => /> &m _ _ _ _ _ _ _ hh ho hs hb hv hp0 hpl.
have e1 : to_uint (inlen{m} - off{m}) = to_uint inlen{m} - to_uint off{m}.
+ by rewrite W64.to_uintB 1:W64.uleE.
have e2 : to_uint (in_0{m} + off{m}) = to_uint in_0{m} + to_uint off{m}.
+ by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
have e3 : to_uint (fill{m} + (inlen{m} - off{m}))
          = to_uint fill{m} + (to_uint inlen{m} - to_uint off{m}).
+ by rewrite W64.to_uintD_small e1; smt(W64.to_uint_cmp modz_cmp).
have e4 : to_uint ((_total + _inlen) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _inlen) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
have hlt : to_uint fill{m} + (to_uint inlen{m} - to_uint off{m}) < 64.
+ by rewrite hs; smt(modz_cmp).
rewrite !W64.uleE /= e1 e2 e3 e4 -hs.
split; 1: by do !split; try (move=> i h1 h2; apply hv); smt(W64.to_uint_cmp).
by move=> _ _ _ _ _ _ r h _.
qed.
