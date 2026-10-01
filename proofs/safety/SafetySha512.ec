(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetySha512.ec
 * ===============
 *
 * Safety of the streaming and one-shot SHA-384, SHA-512, SHA-512/224 and
 * SHA-512/256 of src/sha512.jinc and src/sha512_DSIZE.jinc: initial
 * values, absorb, padding and output for the four digest sizes, one-shot
 * hashing. The unit's SHA-512 kernel enters through SafetyK512.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK512.
require import BArray28 BArray32 BArray48 BArray64 BArray128 NirapodSha2Safety.

(* ------------------------------------------------------------------ *)
(* Initial values                                                     *)

lemma __sha512_load_iv_proof _h _iv _h_init _iv_init :
  __sha512_load_iv_spec _h _iv _h_init _iv_init.
proof.
rewrite /__sha512_load_iv_spec; proc.
while (valid trace___sha512_load_iv /\ i_init /\ 0 <= i <= 8 /\ iv_init = full64
       /\ BArray64.is_init h_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask64_set64 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full64_init hm /=; smt().
auto => /> hiv; split; 1: by split; [exact full64E | move=> j /#].
by move=> hi1 i0 tr0 hlt _ _ hi8 _ hh; have <- : 8 * i0 = 64 by smt().
qed.

lemma __sha512_init_proof _h _h_init : __sha512_init_spec _h _h_init.
proof.
rewrite /__sha512_init_spec; proc.
wp; ecall (__sha512_load_iv_proof h sHA512_IV h_init full64).
by auto => />; exact (full64_init 0 64).
qed.

lemma __sha384_init_proof _h _h_init : __sha384_init_spec _h _h_init.
proof.
rewrite /__sha384_init_spec; proc.
wp; ecall (__sha512_load_iv_proof h sHA384_IV h_init full64).
by auto => />; exact (full64_init 0 64).
qed.

lemma __sha512_224_init_proof _h _h_init : __sha512_224_init_spec _h _h_init.
proof.
rewrite /__sha512_224_init_spec; proc.
wp; ecall (__sha512_load_iv_proof h sHA512_224_IV h_init full64).
by auto => />; exact (full64_init 0 64).
qed.

lemma __sha512_256_init_proof _h _h_init : __sha512_256_init_spec _h _h_init.
proof.
rewrite /__sha512_256_init_spec; proc.
wp; ecall (__sha512_load_iv_proof h sHA512_256_IV h_init full64).
by auto => />; exact (full64_init 0 64).
qed.

(* ------------------------------------------------------------------ *)
(* Absorb                                                             *)

(* The head of an absorb: f bytes are buffered, and n of the l input
   bytes top the buffer up (none when it is empty). *)
lemma absorb_head512 (t l f n : W64.t) :
  f = t `&` W64.of_int 127 =>
  n = (if f = W64.of_int 0 then f
       else if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f) =>
  to_uint f = to_uint t %% 128 /\ to_uint f + to_uint n <= 128
  /\ to_uint n <= to_uint l /\ to_uint (l - n) = to_uint l - to_uint n
  /\ (to_uint f = 0 => to_uint n = 0)
  /\ (to_uint f <> 0 => to_uint f + to_uint n <> 128 => to_uint n = to_uint l).
proof.
move=> hfd ->.
have hf : to_uint f = to_uint t %% 128 by rewrite hfd and127.
have hf64 : to_uint f < 128 by smt(modz_cmp).
have hs : to_uint (W64.of_int 128 - f) = 128 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE; smt(W64.of_uintK).
have hz : (f = W64.of_int 0) <=> to_uint f = 0 by rewrite W64.to_uint_eq.
case: (f = W64.of_int 0) => hf0 /=.
+ have h0 : to_uint f = 0 by rewrite hf0 W64.to_uint0.
  by rewrite W64.to_uintB 1:W64.uleE; smt(W64.to_uint_cmp).
case: (l \ult W64.of_int 128 - f) => hl /=.
+ by move: hl; rewrite W64.ultE hs; smt(W64.to_uint_cmp).
move: hl; rewrite W64.ultE hs => hl.
by rewrite W64.to_uintB 1:W64.uleE 1:hs; smt(W64.to_uint_cmp).
qed.

lemma _sha512_absorb_mem_proof _h _buf _total _in _inlen _ms _h_init _buf_init :
  _sha512_absorb_mem_spec _h _buf _total _in _inlen _ms _h_init _buf_init.
proof.
rewrite /_sha512_absorb_mem_spec; proc; sp.
seq 1 : (valid trace__sha512_absorb_mem /\ total_init /\ fill_init /\ in_init
         /\ inlen_init /\ ms_init /\ n_init /\ valid M.tmp__trace
         /\ total = _total + _inlen
         /\ BArray64.is_init h_init 0 64 /\ to_uint fill + to_uint n <= 128
         /\ BArray128.is_init buf_init 0 (to_uint fill + to_uint n)
         /\ (to_uint fill = 0 => to_uint n = 0)
         /\ (to_uint fill <> 0 => to_uint fill + to_uint n <> 128 => to_uint inlen = 0)
         /\ to_uint fill + to_uint n + to_uint inlen = to_uint _total %% 128 + to_uint _inlen
         /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint n + to_uint inlen)).
+ ecall (__fill128_mem_proof buf fill in_0 n ms buf_init).
  auto => /> &m hh hb hv hp0 hpl.
  pose f := _total `&` W64.of_int 127.
  pose n := if f = W64.of_int 0 then f
            else if _inlen \ult W64.of_int 128 - f then _inlen else W64.of_int 128 - f.
  have [#] hf hfn hnl hln hf0 hfl := absorb_head512 _total _inlen f n _ _ => //.
  have hfn' : to_uint (f + n) = to_uint f + to_uint n.
  + by rewrite W64.to_uintD_small; smt().
  rewrite !W64.uleE /= hfn' hln; move: hb; rewrite umodc // -hf => hb.
  split; 2: move=> _ _ _ _ _ _ _ r hr _.
  + by do !split => //; try (move=> i h1 h2; apply hv => /#); smt().
  by do !split => //; try (move=> i h1 h2; apply hv => /#); smt().
sp; seq 1 : (valid trace__sha512_absorb_mem /\ total_init /\ fill_init /\ in_init
             /\ inlen_init /\ ms_init /\ total = _total + _inlen
             /\ BArray64.is_init h_init 0 64 /\ to_uint fill < 128
             /\ BArray128.is_init buf_init 0 (to_uint fill)
             /\ (to_uint fill <> 0 => to_uint inlen = 0)
             /\ (to_uint fill + to_uint inlen) %% 128
                = (to_uint _total %% 128 + to_uint _inlen) %% 128
             /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint inlen)).
+ if.
  + wp; ecall (_sha512_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ in0 _ f0 _ _ _ _ _ _ _ _ _ hT hh hfn hb hf0 hfl hsum hv hp0 hpl hfull.
    have e64 : to_uint f0 + to_uint n{m} = 128.
    + by rewrite -W64.to_uintD_small 1:/# hfull W64.to_uint_small.
    have ein : to_uint (in0 + n{m}) = to_uint in0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    move: hb; rewrite e64 => hb; split => // _ r _ _; rewrite /protect_64 ein.
    have hm : to_uint inlen{m} %% 128 = (to_uint _total %% 128 + to_uint _inlen) %% 128.
    + by rewrite (_ : to_uint _total %% 128 + to_uint _inlen = to_uint inlen{m} + 1 * 128)
        1:/# modzMDr.
    do !split => //; try exact (full128_init 0 0); try (move=> i h1 h2; apply hv);
      smt(W64.to_uint_cmp).
  auto => /> &m _ in0 _ f0 _ _ _ _ _ _ _ _ _ hT hh hfn hb hf0 hfl hsum hv hp0 hpl hfull.
  have efn : to_uint (f0 + n{m}) = to_uint f0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  have ein : to_uint (in0 + n{m}) = to_uint in0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  have h64 : to_uint f0 + to_uint n{m} <> 128.
  + by move: hfull; rewrite W64.to_uint_eq efn W64.to_uint_small.
  rewrite efn ein; do !split => //; try (move=> i h1 h2; apply hv); smt(W64.to_uint_cmp).
sp; seq 1 : (valid trace__sha512_absorb_mem /\ total_init /\ fill_init /\ in_init
             /\ inlen_init /\ ms_init /\ off_init /\ total = _total + _inlen
             /\ BArray64.is_init h_init 0 64 /\ to_uint off <= to_uint inlen
             /\ to_uint fill + (to_uint inlen - to_uint off)
                = (to_uint _total %% 128 + to_uint _inlen) %% 128
             /\ BArray128.is_init buf_init 0 (to_uint fill)
             /\ is_valid (2 ^ 64) Glob.mem_v (to_uint in_0) (to_uint inlen)).
+ if.
  + wp; ecall (_sha512_compress_blocks_proof h in_0 n ms h_init).
    auto => /> &m _ _ _ _ _ _ _ hh hf hb hf0 hm hv hp0 hpl hnz.
    have hn : to_uint (inlen{m} `>>` W8.of_int 7) = to_uint inlen{m} %/ 128.
    + by have := shrc inlen{m} 7 _.
    have ho : to_uint ((inlen{m} `>>` W8.of_int 7) `<<` W8.of_int 7)
              = 128 * (to_uint inlen{m} %/ 128).
    + by have := blocksc inlen{m} 7 _.
    have hn1 := nonzero _ hnz.
    have e := mulc_small (inlen{m} `>>` W8.of_int 7) 128 _ _; 1,2: smt(W64.to_uint_cmp).
    have hdm := divz_eq (to_uint inlen{m}) 128.
    have hz : to_uint fill{m} = 0 by smt(W64.to_uint_cmp).
    rewrite /protect_64 e ho hn W64.ultE hn W64.to_uint_small //=.
    split; 1: by do !split; try (move=> i h1 h2; apply hv); smt(modz_ge0 W64.to_uint_cmp).
    move=> _ _ _ _ r _ _; split; 1: smt(modz_ge0).
    split; 1: by move: hm; rewrite hz /=; smt().
    split; 1: exact (full128_init 0 0).
    by move=> i h1 h2; apply hv.
  auto => /> &m _ _ _ _ _ _ _ hh hf hb hf0 hm hv hp0 hpl hz.
  have hn : to_uint inlen{m} %/ 128 = 0.
  + have := shrc inlen{m} 7 _; 1: done.
    by rewrite hz W64.to_uint0 => ->.
  have hl : to_uint inlen{m} < 128 by smt(divz_eq modz_ge0 ltz_pmod W64.to_uint_cmp).
  by rewrite -hm pmod_small; smt(W64.to_uint_cmp).
wp; ecall (__fill128_mem_proof buf fill in_0 inlen ms buf_init).
auto => /> &m _ _ _ _ _ _ _ hh ho hs hb hv hp0 hpl.
have e1 : to_uint (inlen{m} - off{m}) = to_uint inlen{m} - to_uint off{m}.
+ by rewrite W64.to_uintB 1:W64.uleE.
have e2 : to_uint (in_0{m} + off{m}) = to_uint in_0{m} + to_uint off{m}.
+ by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
have e3 : to_uint (fill{m} + (inlen{m} - off{m}))
          = to_uint fill{m} + (to_uint inlen{m} - to_uint off{m}).
+ by rewrite W64.to_uintD_small e1; smt(W64.to_uint_cmp modz_cmp).
have e4 : to_uint ((_total + _inlen) \umod W64.of_int 128)
          = (to_uint _total %% 128 + to_uint _inlen) %% 128.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 128) // modzDml.
have hlt : to_uint fill{m} + (to_uint inlen{m} - to_uint off{m}) < 128.
+ by rewrite hs; smt(modz_cmp).
rewrite !W64.uleE /= e1 e2 e3 e4 -hs.
split; 1: by do !split; try (move=> i h1 h2; apply hv); smt(W64.to_uint_cmp).
by move=> _ _ _ _ _ _ r h _.
qed.


(* ------------------------------------------------------------------ *)
(* Padding and output                                                 *)

(* src/sha512_DSIZE.jinc is compiled four times, for 28, 32, 48 and 64
   output bytes. The safety proofs differ only in the output loops and
   the output mask theory, so the short script is repeated per instance;
   only SHA-512/224 runs the half-word loop. *)

lemma _sha512___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha512___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
rewrite /_sha512___sha512_finalize_spec; proc; sp.
seq 1 : (valid trace__sha512___sha512_finalize /\ total_init /\ fill_init /\ ms_init
         /\ BArray64.is_init h_init 0 64 /\ to_uint fill <= 112
         /\ BArray128.is_init buf_init 0 (to_uint fill)).
+ if.
  + wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
    ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m hh hb _.
    have hf := and127 total{m}.
    have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
    + by rewrite addone_small hf //; smt(modz_cmp).
    move: hb; rewrite umodc // => hb.
    have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
    rewrite W64.uleE e hf /=; split; 1: by split; [smt(modz_cmp) | exact hs].
    by move=> _ _ r _ _ r0 _ _; split; [smt(modz_cmp) | exact (full128_init 0 0)].
  auto => /> &m hh hb.
  have hf := and127 total{m}.
  have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
  + by rewrite addone_small hf //; smt(modz_cmp).
  move: hb; rewrite umodc // => hb.
  have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
  rewrite W64.ultE e hf /= => h112.
  by do !split => //; smt(modz_cmp).
wp; while (valid trace__sha512___sha512_finalize /\ i_init /\ ms_init /\ i = 8
           /\ inc = 8 /\ h_init = full64 /\ buf_init = full128
           /\ BArray64.is_init out_init 0 64).
+ by wp; ecall (__bswap32_proof y); auto => />.
wp; while (valid trace__sha512___sha512_finalize /\ i_init /\ ms_init /\ 0 <= i <= 8
           /\ inc = 8 /\ h_init = full64 /\ buf_init = full128
           /\ BArray64.is_init out_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ _ hi0 hi8 ho hlt.
  have hm := mask64_set64 out_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full64_init hm /=; smt().
wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
ecall (__bswap64_proof t); wp; ecall (__bswap64_proof t); wp.
ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m _ _ _ _ hh hf hb.
rewrite W64.uleE /= hf /= => r hr _ _ _ _ _.
have hp1 := mask128_put64 r.`3 112 hr _ _ => //=.
have hp2 := mask128_put64 _ 120 hp1 _ _ => //=.
rewrite hp2 /= => r2 h2 _.
split; 1: by split; [exact full64E | exact (full64_init 0 0)].
move=> i0 o0 _ hi _ hi0 hi8 _ ho; split; 2: by move=> *; exact (full128_init 0 128).
by have <- : 8 * i0 = 64 by smt().
qed.

lemma _sha384___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha384___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
rewrite /_sha384___sha512_finalize_spec; proc; sp.
seq 1 : (valid trace__sha384___sha512_finalize /\ total_init /\ fill_init /\ ms_init
         /\ BArray64.is_init h_init 0 64 /\ to_uint fill <= 112
         /\ BArray128.is_init buf_init 0 (to_uint fill)).
+ if.
  + wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
    ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m hh hb _.
    have hf := and127 total{m}.
    have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
    + by rewrite addone_small hf //; smt(modz_cmp).
    move: hb; rewrite umodc // => hb.
    have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
    rewrite W64.uleE e hf /=; split; 1: by split; [smt(modz_cmp) | exact hs].
    by move=> _ _ r _ _ r0 _ _; split; [smt(modz_cmp) | exact (full128_init 0 0)].
  auto => /> &m hh hb.
  have hf := and127 total{m}.
  have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
  + by rewrite addone_small hf //; smt(modz_cmp).
  move: hb; rewrite umodc // => hb.
  have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
  rewrite W64.ultE e hf /= => h112.
  by do !split => //; smt(modz_cmp).
wp; while (valid trace__sha384___sha512_finalize /\ i_init /\ ms_init /\ i = 6
           /\ inc = 6 /\ h_init = full64 /\ buf_init = full128
           /\ BArray48.is_init out_init 0 48).
+ by wp; ecall (__bswap32_proof y); auto => />.
wp; while (valid trace__sha384___sha512_finalize /\ i_init /\ ms_init /\ 0 <= i <= 6
           /\ inc = 6 /\ h_init = full64 /\ buf_init = full128
           /\ BArray48.is_init out_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ _ hi0 hi8 ho hlt.
  have hm := mask48_set64 out_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full64_init hm /=; smt().
wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
ecall (__bswap64_proof t); wp; ecall (__bswap64_proof t); wp.
ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m _ _ _ _ hh hf hb.
rewrite W64.uleE /= hf /= => r hr _ _ _ _ _.
have hp1 := mask128_put64 r.`3 112 hr _ _ => //=.
have hp2 := mask128_put64 _ 120 hp1 _ _ => //=.
rewrite hp2 /= => r2 h2 _.
split; 1: by split; [exact full64E | exact (full48_init 0 0)].
move=> i0 o0 _ hi _ hi0 hi8 _ ho; split; 2: by move=> *; exact (full128_init 0 128).
by have <- : 8 * i0 = 48 by smt().
qed.

lemma _sha512_256___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha512_256___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
rewrite /_sha512_256___sha512_finalize_spec; proc; sp.
seq 1 : (valid trace__sha512_256___sha512_finalize /\ total_init /\ fill_init /\ ms_init
         /\ BArray64.is_init h_init 0 64 /\ to_uint fill <= 112
         /\ BArray128.is_init buf_init 0 (to_uint fill)).
+ if.
  + wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
    ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m hh hb _.
    have hf := and127 total{m}.
    have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
    + by rewrite addone_small hf //; smt(modz_cmp).
    move: hb; rewrite umodc // => hb.
    have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
    rewrite W64.uleE e hf /=; split; 1: by split; [smt(modz_cmp) | exact hs].
    by move=> _ _ r _ _ r0 _ _; split; [smt(modz_cmp) | exact (full128_init 0 0)].
  auto => /> &m hh hb.
  have hf := and127 total{m}.
  have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
  + by rewrite addone_small hf //; smt(modz_cmp).
  move: hb; rewrite umodc // => hb.
  have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
  rewrite W64.ultE e hf /= => h112.
  by do !split => //; smt(modz_cmp).
wp; while (valid trace__sha512_256___sha512_finalize /\ i_init /\ ms_init /\ i = 4
           /\ inc = 4 /\ h_init = full64 /\ buf_init = full128
           /\ BArray32.is_init out_init 0 32).
+ by wp; ecall (__bswap32_proof y); auto => />.
wp; while (valid trace__sha512_256___sha512_finalize /\ i_init /\ ms_init /\ 0 <= i <= 4
           /\ inc = 4 /\ h_init = full64 /\ buf_init = full128
           /\ BArray32.is_init out_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ _ hi0 hi8 ho hlt.
  have hm := mask32_set64 out_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full64_init hm /=; smt().
wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
ecall (__bswap64_proof t); wp; ecall (__bswap64_proof t); wp.
ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m _ _ _ _ hh hf hb.
rewrite W64.uleE /= hf /= => r hr _ _ _ _ _.
have hp1 := mask128_put64 r.`3 112 hr _ _ => //=.
have hp2 := mask128_put64 _ 120 hp1 _ _ => //=.
rewrite hp2 /= => r2 h2 _.
split; 1: by split; [exact full64E | exact (full32_init 0 0)].
move=> i0 o0 _ hi _ hi0 hi8 _ ho; split; 2: by move=> *; exact (full128_init 0 128).
by have <- : 8 * i0 = 32 by smt().
qed.


lemma _sha512_224___sha512_finalize_proof _out _h _buf _total _ms _out_init _h_init _buf_init :
  _sha512_224___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init.
proof.
rewrite /_sha512_224___sha512_finalize_spec; proc; sp.
seq 1 : (valid trace__sha512_224___sha512_finalize /\ total_init /\ fill_init /\ ms_init
         /\ BArray64.is_init h_init 0 64 /\ to_uint fill <= 112
         /\ BArray128.is_init buf_init 0 (to_uint fill)).
+ if.
  + wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
    ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m hh hb _.
    have hf := and127 total{m}.
    have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
    + by rewrite addone_small hf //; smt(modz_cmp).
    move: hb; rewrite umodc // => hb.
    have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
    rewrite W64.uleE e hf /=; split; 1: by split; [smt(modz_cmp) | exact hs].
    by move=> _ _ r _ _ r0 _ _; split; [smt(modz_cmp) | exact (full128_init 0 0)].
  auto => /> &m hh hb.
  have hf := and127 total{m}.
  have e : to_uint (total{m} `&` W64.of_int 127 + W64.one) = to_uint total{m} %% 128 + 1.
  + by rewrite addone_small hf //; smt(modz_cmp).
  move: hb; rewrite umodc // => hb.
  have hs := mask128_set8 _buf_init (to_uint total{m} %% 128) hb _; 1: smt(modz_cmp).
  rewrite W64.ultE e hf /= => h112.
  by do !split => //; smt(modz_cmp).
wp; while (valid trace__sha512_224___sha512_finalize /\ i_init /\ ms_init /\ 3 <= i <= 4
           /\ inc = 4 /\ h_init = full64 /\ buf_init = full128
           /\ BArray28.is_init out_init 0 (if i = 3 then 24 else 28)).
+ wp; ecall (__bswap32_proof y); auto => /> &m _ _ _ hi3 hi4 ho hlt.
  have e3 : i{m} = 3 by smt().
  move: ho; rewrite e3 /= => ho.
  have hm := mask28_set32 out_init{m} 6 ho _ _ => //=.
  by rewrite full64_init hm.
wp; while (valid trace__sha512_224___sha512_finalize /\ i_init /\ ms_init /\ 0 <= i <= 3
           /\ inc = 3 /\ h_init = full64 /\ buf_init = full128
           /\ BArray28.is_init out_init 0 (8 * i)).
+ wp; ecall (__bswap64_proof x); auto => /> &m _ _ _ hi0 hi8 ho hlt.
  have hm := mask28_set64 out_init{m} i{m} ho _ _; 1,2: smt().
  by rewrite full64_init hm /=; smt().
wp; ecall (_sha512_compress_proof h buf ms h_init buf_init); wp.
ecall (__bswap64_proof t); wp; ecall (__bswap64_proof t); wp.
ecall (__zero128_proof buf fill hi ms buf_init); auto => /> &m _ _ _ _ hh hf hb.
rewrite W64.uleE /= hf /= => r hr _ _ _ _ _.
have hp1 := mask128_put64 r.`3 112 hr _ _ => //=.
have hp2 := mask128_put64 _ 120 hp1 _ _ => //=.
rewrite hp2 /= => r2 h2 _.
split; 1: by split; [exact full64E | exact (full28_init 0 0)].
move=> i0 o0 _ hi _ hi0 hi3 _ ho; split; 1: by have <- : 8 * i0 = 24 by smt().
move=> i1 o1 _ hi1 _ h3 h4 ho1; split; 2: exact (full128_init 0 128).
by move: ho1; rewrite (_ : i1 <> 3) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* One-shot hashing                                                   *)

lemma _sha512____sha512_mem_from_proof _out _h _in _inlen _ms _out_init _h_init :
  _sha512____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init.
proof.
rewrite /_sha512____sha512_mem_from_spec; proc.
wp; ecall (_sha512___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (_sha512_absorb_mem_proof h buf total in_0 inlen ms h_init buf_init).
auto => /> &m _ _ _ _ j h1 h2.
by have := umodc W64.zero 128 _; rewrite // W64.to_uint0 /=; smt().
qed.

lemma _sha384____sha512_mem_from_proof _out _h _in _inlen _ms _out_init _h_init :
  _sha384____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init.
proof.
rewrite /_sha384____sha512_mem_from_spec; proc.
wp; ecall (_sha384___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (_sha512_absorb_mem_proof h buf total in_0 inlen ms h_init buf_init).
auto => /> &m _ _ _ _ j h1 h2.
by have := umodc W64.zero 128 _; rewrite // W64.to_uint0 /=; smt().
qed.

lemma _sha512_224____sha512_mem_from_proof _out _h _in _inlen _ms _out_init _h_init :
  _sha512_224____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init.
proof.
rewrite /_sha512_224____sha512_mem_from_spec; proc.
wp; ecall (_sha512_224___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (_sha512_absorb_mem_proof h buf total in_0 inlen ms h_init buf_init).
auto => /> &m _ _ _ _ j h1 h2.
by have := umodc W64.zero 128 _; rewrite // W64.to_uint0 /=; smt().
qed.

lemma _sha512_256____sha512_mem_from_proof _out _h _in _inlen _ms _out_init _h_init :
  _sha512_256____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init.
proof.
rewrite /_sha512_256____sha512_mem_from_spec; proc.
wp; ecall (_sha512_256___sha512_finalize_proof out h buf total ms out_init h_init buf_init).
wp; ecall (_sha512_absorb_mem_proof h buf total in_0 inlen ms h_init buf_init).
auto => /> &m _ _ _ _ j h1 h2.
by have := umodc W64.zero 128 _; rewrite // W64.to_uint0 /=; smt().
qed.

lemma _sha512_mem_proof _out _in _inlen _ms _out_init :
  _sha512_mem_spec _out _in _inlen _ms _out_init.
proof.
rewrite /_sha512_mem_spec; proc.
wp; ecall (_sha512____sha512_mem_from_proof out h in_0 inlen ms out_init h_init).
wp; ecall (__sha512_init_proof h h_init).
by auto => />.
qed.

lemma _sha384_mem_proof _out _in _inlen _ms _out_init :
  _sha384_mem_spec _out _in _inlen _ms _out_init.
proof.
rewrite /_sha384_mem_spec; proc.
wp; ecall (_sha384____sha512_mem_from_proof out h in_0 inlen ms out_init h_init).
wp; ecall (__sha384_init_proof h h_init).
by auto => />.
qed.

lemma _sha512_224_mem_proof _out _in _inlen _ms _out_init :
  _sha512_224_mem_spec _out _in _inlen _ms _out_init.
proof.
rewrite /_sha512_224_mem_spec; proc.
wp; ecall (_sha512_224____sha512_mem_from_proof out h in_0 inlen ms out_init h_init).
wp; ecall (__sha512_224_init_proof h h_init).
by auto => />.
qed.

lemma _sha512_256_mem_proof _out _in _inlen _ms _out_init :
  _sha512_256_mem_spec _out _in _inlen _ms _out_init.
proof.
rewrite /_sha512_256_mem_spec; proc.
wp; ecall (_sha512_256____sha512_mem_from_proof out h in_0 inlen ms out_init h_init).
wp; ecall (__sha512_256_init_proof h h_init).
by auto => />.
qed.
