(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyMulti.ec
 * ==============
 *
 * Safety of the multi-way front ends of src/sha256_x8.jinc and
 * src/sha512_x4.jinc: the interleaved initial state, the state taken
 * from a single-way prefix, absorbing equal-length lanes, padding and
 * output, and the one-shot over lanes. The lane kernels enter through
 * SafetyKX8 and SafetyKX4; the buffered head and tail of each lane go
 * through the single-way fill of SafetyFill.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyKX8 SafetyKX4.
require import SafetySha256 SafetySha512.
require import BArray32 BArray64 BArray128 BArray256 BArray512 NirapodSha2Safety.
require import SBArray512_64 SBArray512_128.

(* ------------------------------------------------------------------ *)
(* Lane masks                                                         *)

(* The buffer of n lanes of B bytes holds lane j at bytes B * j to
   B * j + B - 1. A loop over the lanes brings lanes below k to l'
   bytes while the others stay at l bytes. *)
op lanes (m : BArray512.t) (n b k l l' : int) =
  forall j, 0 <= j < n => BArray512.is_init m (b * j) (if j < k then l' else l).

lemma lanes_start (m : BArray512.t) n b l l' :
  lanes m n b n l l => lanes m n b 0 l l'.
proof. by move=> h j hj; have := h j hj; smt(). qed.

lemma lanes_end (m : BArray512.t) n b l l' :
  lanes m n b n l l' => lanes m n b n l' l'.
proof. by move=> h j hj; have := h j hj; smt(). qed.

lemma lanes_le (m : BArray512.t) n b k l l' :
  lanes m n b n l l => l' <= l => lanes m n b k l' l'.
proof.
move=> h hl j hj i hi0 hi1; have := h j hj; rewrite (_ : (if j < n then l else l) = l) 1:/#.
by move=> hm; apply hm; smt().
qed.

lemma lanes_full n b k l l' : lanes full512 n b k l l'.
proof. by move=> j hj; exact full512_init. qed.

(* Lane k through the 64-byte sub-array view. *)
lemma lanes64_get (m : BArray512.t) k l l' :
  lanes m 8 64 k l l' => 0 <= k < 8 => 0 <= l <= 64 =>
  BArray64.is_init (SBArray512_64.get_sub m (64 * k)) 0 l.
proof.
move=> h hk hl; apply (sub512_64_get _ _ 0 l) => //; 2..: smt().
by have := h k hk; rewrite ifF 1:/#.
qed.

lemma lanes64_set (m : BArray512.t) (s : BArray64.t) k l l' :
  lanes m 8 64 k l l' => 0 <= k < 8 => 0 <= l <= 64 => 0 <= l' <= 64 =>
  BArray64.is_init s 0 l' => lanes (SBArray512_64.set_sub m (64 * k) s) 8 64 (k + 1) l l'.
proof.
move=> h hk hl hl' hs j hj; case: (j = k) => [->> | hjk].
+ by rewrite ifT 1:/#; apply (sub512_64_set_in _ _ _ 0) => //; smt().
apply sub512_64_set_out; 2: smt().
by have := h j hj; rewrite (_ : (j < k + 1) = (j < k)) 1:/#.
qed.

lemma lanes128_get (m : BArray512.t) k l l' :
  lanes m 4 128 k l l' => 0 <= k < 4 => 0 <= l <= 128 =>
  BArray128.is_init (SBArray512_128.get_sub m (128 * k)) 0 l.
proof.
move=> h hk hl; apply (sub512_128_get _ _ 0 l) => //; 2..: smt().
by have := h k hk; rewrite ifF 1:/#.
qed.

lemma lanes128_set (m : BArray512.t) (s : BArray128.t) k l l' :
  lanes m 4 128 k l l' => 0 <= k < 4 => 0 <= l <= 128 => 0 <= l' <= 128 =>
  BArray128.is_init s 0 l' => lanes (SBArray512_128.set_sub m (128 * k) s) 4 128 (k + 1) l l'.
proof.
move=> h hk hl hl' hs j hj; case: (j = k) => [->> | hjk].
+ by rewrite ifT 1:/#; apply (sub512_128_set_in _ _ _ 0) => //; smt().
apply sub512_128_set_out; 2: smt().
by have := h j hj; rewrite (_ : (j < k + 1) = (j < k)) 1:/#.
qed.

(* The padding byte of lane k, at offset f of the lane, and the length
   word at its end. *)
lemma lanes8_set8 (m : BArray512.t) k f :
  lanes m 8 64 k f (f + 1) => 0 <= k < 8 => 0 <= f < 64 =>
  lanes (BArray512.set8 m (64 * k + f) (W8.of_int 255)) 8 64 (k + 1) f (f + 1).
proof.
move=> h hk hf j hj i hi0 hi1; rewrite BArray512.is_init_cellP /=.
case: (64 * k + f = i) => hi; 1: smt().
by have := h j hj i _ _; [smt() | smt() | smt()].
qed.

lemma lanes8_set64d (m : BArray512.t) k :
  lanes m 8 64 k 56 64 => 0 <= k < 8 =>
  lanes (BArray512.set64d m (64 * k + 56) (W64.of_int 18446744073709551615)) 8 64 (k + 1) 56 64.
proof.
move=> h hk j hj i hi0 hi1; rewrite BArray512.is_init_cell_set64d.
case: (64 * k + 56 <= i < 64 * k + 64) => hi; 1: by left; smt().
by right; have := h j hj i _ _; [smt() | smt() | smt()].
qed.

lemma lanes4_set8 (m : BArray512.t) k f :
  lanes m 4 128 k f (f + 1) => 0 <= k < 4 => 0 <= f < 128 =>
  lanes (BArray512.set8 m (128 * k + f) (W8.of_int 255)) 4 128 (k + 1) f (f + 1).
proof.
move=> h hk hf j hj i hi0 hi1; rewrite BArray512.is_init_cellP /=.
case: (128 * k + f = i) => hi; 1: smt().
by have := h j hj i _ _; [smt() | smt() | smt()].
qed.

lemma lanes4_set64d (m : BArray512.t) k :
  lanes m 4 128 k 120 128 => 0 <= k < 4 =>
  lanes (BArray512.set64d m (128 * k + 120) (W64.of_int 18446744073709551615)) 4 128 (k + 1) 120 128.
proof.
move=> h hk j hj i hi0 hi1; rewrite BArray512.is_init_cell_set64d.
case: (128 * k + 120 <= i < 128 * k + 128) => hi; 1: by left; smt().
by right; have := h j hj i _ _; [smt() | smt() | smt()].
qed.

(* The contracts list the lanes one by one. *)
lemma lanes8I (m : BArray512.t) l :
  BArray512.is_init m 0 l => BArray512.is_init m 64 l => BArray512.is_init m 128 l =>
  BArray512.is_init m 192 l => BArray512.is_init m 256 l => BArray512.is_init m 320 l =>
  BArray512.is_init m 384 l => BArray512.is_init m 448 l => lanes m 8 64 8 l l.
proof.
move=> h0 h1 h2 h3 h4 h5 h6 h7 j hj; rewrite (_ : (if j < 8 then l else l) = l) 1:/#.
have : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 \/ j = 4 \/ j = 5 \/ j = 6 \/ j = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

lemma lanes8E (m : BArray512.t) l : lanes m 8 64 8 l l =>
  BArray512.is_init m 0 l /\ BArray512.is_init m 64 l /\ BArray512.is_init m 128 l
  /\ BArray512.is_init m 192 l /\ BArray512.is_init m 256 l /\ BArray512.is_init m 320 l
  /\ BArray512.is_init m 384 l /\ BArray512.is_init m 448 l.
proof. by move=> h; do !split; [have := h 0 | have := h 1 | have := h 2 | have := h 3 | have := h 4 | have := h 5 | have := h 6 | have := h 7]. qed.

lemma lanes8_full (m : BArray512.t) : lanes m 8 64 8 64 64 => m = full512.
proof.
move=> h; apply full512E => i hi0 hi1.
by have := h (i %/ 64) _ i _ _; smt(divz_eq modz_ge0 ltz_pmod).
qed.

lemma lanes_valid8E mv (f : int -> int) l : lanes_valid mv 8 f l =>
  is_valid (2 ^ 64) mv (f 0) l /\ is_valid (2 ^ 64) mv (f 1) l /\ is_valid (2 ^ 64) mv (f 2) l
  /\ is_valid (2 ^ 64) mv (f 3) l /\ is_valid (2 ^ 64) mv (f 4) l /\ is_valid (2 ^ 64) mv (f 5) l
  /\ is_valid (2 ^ 64) mv (f 6) l /\ is_valid (2 ^ 64) mv (f 7) l.
proof. by move=> h; do 7!(split; 1: by apply h); apply h. qed.

(* ------------------------------------------------------------------ *)
(* Eight-way SHA-256: state                                           *)

(* Word 8 * j + k of the interleaved state is word j of lane k. The
   loops write lane-major within a word index, so after j outer steps
   the first 8 * j words are written. *)
lemma __sha256_x8_init_proof _h _h_init : __sha256_x8_init_spec _h _h_init.
proof.
rewrite /__sha256_x8_init_spec; proc.
while (valid trace___sha256_x8_init /\ j_init /\ 0 <= j <= 8 /\ iv_init = full32
       /\ BArray256.is_init h_init 0 (4 * (8 * j))).
+ wp; while (valid trace___sha256_x8_init /\ j_init /\ k_init /\ t_init /\ 0 <= j < 8
             /\ 0 <= k <= 8 /\ iv_init = full32 /\ BArray256.is_init h_init 0 (4 * (8 * j + k))).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hh hlt.
    have hm := mask256_set32 h_init{m} (8 * j{m} + k{m}) hh _ _; 1,2: smt().
    by rewrite (_ : 4 * (8 * j{m} + (k{m} + 1)) = 4 * (8 * j{m} + k{m} + 1)) 1:/#; smt().
  auto => /> &m _ _ hj0 hj8 hh hlt; split; 1: by rewrite full32_init /=; smt().
  move=> h0 k0 tr0 hlt0 _ hk0 hk8 hh0; split; 1: smt().
  by have <- : 4 * (8 * j{m} + k0) = 4 * (8 * (j{m} + 1)) by smt().
auto => /> *; split; 1: by move=> j /#.
by move=> h0 j0 tr0 hlt _ hj0 hj8 hh; have <- : 4 * (8 * j0) = 256 by smt().
qed.

(* The buffer holds lane k at bytes 64 * k to 64 * k + 63, and is
   written transposed: word i of every lane, then word i + 1. The mask
   invariant is stated per byte, by lane offset c %% 64. *)
lemma __sha256_x8_from_proof _h _buf _hs _bs _h_init _buf_init _hs_init _bs_init :
  __sha256_x8_from_spec _h _buf _hs _bs _h_init _buf_init _hs_init _bs_init.
proof.
rewrite /__sha256_x8_from_spec; proc.
while (valid trace___sha256_x8_from /\ i_init /\ 0 <= i <= 8 /\ BArray256.is_init h_init 0 256
       /\ BArray64.is_init bs_init 0 64
       /\ forall c, 0 <= c < 512 => c %% 64 < 8 * i => BArray512.is_init_cell buf_init c).
+ wp; while (valid trace___sha256_x8_from /\ i_init /\ k_init /\ t_init /\ 0 <= i < 8
             /\ 0 <= k <= 8 /\ BArray256.is_init h_init 0 256 /\ BArray64.is_init bs_init 0 64
             /\ forall c, 0 <= c < 512 => (c %% 64 < 8 * i \/ c %% 64 < 8 * i + 8 /\ c %/ 64 < k)
                  => BArray512.is_init_cell buf_init c).
  + auto => /> &m _ _ _ _ hi0 hi8 hk0 hk8 hh hbs hb hlt.
    split; 1: smt().
    split; 1: smt().
    move=> c hc0 hc1 hc.
    case: (c %% 64 < 8 * i{m} \/ c %% 64 < 8 * i{m} + 8 /\ c %/ 64 < k{m}) => hcase.
    + by right; apply hb.
    by left; smt(divz_eq modz_ge0 ltz_pmod).
  auto => /> &m _ _ hi0 hi8 hh hbs hb hlt.
  have hw : BArray64.is_init bs_init{m} (i{m} * 8) 8 by move=> j hj0 hj1; apply hbs => /#.
  split.
  + split; 1: smt().
    by move=> c hc0 hc1 [hc|hc]; [apply hb | smt()].
  move=> b0 k0 tr0 hlt0 _ hk0 hk8 hb0; split; 1: smt().
  move=> c hc0 hc1 hc; apply hb0 => //.
  case: (c %% 64 < 8 * i{m}) => hci; [by left | right; smt(divz_eq modz_ge0 ltz_pmod)].
wp; while (valid trace___sha256_x8_from /\ j_init /\ 0 <= j <= 8 /\ BArray32.is_init hs_init 0 32
           /\ BArray64.is_init bs_init 0 64 /\ BArray256.is_init h_init 0 (4 * (8 * j))).
+ wp; while (valid trace___sha256_x8_from /\ j_init /\ k_init /\ x_init /\ 0 <= j < 8
             /\ 0 <= k <= 8 /\ BArray32.is_init hs_init 0 32 /\ BArray64.is_init bs_init 0 64
             /\ BArray256.is_init h_init 0 (4 * (8 * j + k))).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hs hbs hh hlt.
    have hm := mask256_set32 h_init{m} (8 * j{m} + k{m}) hh _ _; 1,2: smt().
    by rewrite (_ : 4 * (8 * j{m} + (k{m} + 1)) = 4 * (8 * j{m} + k{m} + 1)) 1:/#; smt().
  auto => /> &m _ _ hj0 hj8 hs hbs hh hlt.
  have hw : BArray32.is_init hs_init{m} (j{m} * 4) 4 by move=> j hj0' hj1; apply hs => /#.
  split; 1: smt().
  move=> h0 k0 tr0 hlt0 _ hk0 hk8 hh0; split; 1: smt().
  by have <- : 4 * (8 * j{m} + k0) = 4 * (8 * (j{m} + 1)) by smt().
auto => /> hs hbs; split; 1: by move=> j /#.
move=> h0 j0 tr0 hlt _ hj0 hj8 hh.
have hh256 : BArray256.is_init h0 0 256 by have <- : 4 * (8 * j0) = 256 by smt().
split; 1: by split; [done | smt(modz_ge0)].
by move=> b0 i0 tr1 hlt1 _ hi0 hi8 _ hb c hc0 hc1; apply hb => //; smt(ltz_pmod).
qed.

(* ------------------------------------------------------------------ *)
(* Eight-way SHA-256: absorb                                          *)

(* The lane kernel contract with the per-lane conditions folded. *)
lemma _sha256_x8_compress_lanes_lv _h8 _in _off _n _ms _h8_init :
  hoare [M._sha256_x8_compress_lanes :
    h8 = _h8 /\ in_0 = _in /\ off = _off /\ n = _n /\ ms = _ms /\ h8_init = _h8_init
    /\ in_init = full64 /\ BArray256.is_init _h8_init 0 256
    /\ _n \ult W64.of_int 288230376151711744 /\ _off \ult W64.of_int 2305843009213693952
    /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i + _off))
         (to_uint (W64.of_int 64 * _n))
    ==> BArray256.is_init res.`3 0 256 /\ valid res.`4].
proof.
have := _sha256_x8_compress_lanes_proof _h8 _in _off _n _ms _h8_init full64.
rewrite /_sha256_x8_compress_lanes_spec => h; conseq h => />.
move=> &m _ _ _ _ _ _ -> hh hn ho hlv; have := lanes_valid8E _ _ _ hlv.
rewrite /is_valid /= => [#] *.
by do !split => //; try apply full64_init; move=> i h1 h2; smt().
qed.

(* The single-way absorb of SafetySha256, lane by lane: every lane has
   the same fill f and length, so one head computation serves all. *)
lemma _sha256_x8_absorb_lanes_proof _h _buf _total _in _inlen _ms _h_init _buf_init _in_init :
  _sha256_x8_absorb_lanes_spec _h _buf _total _in _inlen _ms _h_init _buf_init _in_init.
proof.
rewrite /_sha256_x8_absorb_lanes_spec; proc; sp.
seq 1 : (valid trace__sha256_x8_absorb_lanes /\ total_init /\ fill_init /\ inlen_init
         /\ ms_init /\ n_init /\ total = _total + _inlen /\ in_0 = _in /\ inlen = _inlen
         /\ h_init = full256 /\ in_init = full64 /\ _inlen \ult W64.of_int 2305843009213693952
         /\ to_uint fill = to_uint _total %% 64 /\ to_uint fill + to_uint n <= 64
         /\ to_uint n <= to_uint _inlen /\ (to_uint fill = 0 => to_uint n = 0)
         /\ (to_uint fill <> 0 => to_uint fill + to_uint n <> 64 => to_uint n = to_uint _inlen)
         /\ lanes buf_init 8 64 8 (to_uint fill + to_uint n) (to_uint fill + to_uint n)
         /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i)) (to_uint _inlen)).
+ while (valid trace__sha256_x8_absorb_lanes /\ total_init /\ fill_init /\ inlen_init
         /\ ms_init /\ n_init /\ k_init /\ 0 <= k <= 8 /\ total = _total + _inlen /\ in_0 = _in
         /\ inlen = _inlen /\ h_init = full256 /\ in_init = full64
         /\ _inlen \ult W64.of_int 2305843009213693952
         /\ to_uint fill = to_uint _total %% 64 /\ to_uint fill + to_uint n <= 64
         /\ to_uint n <= to_uint _inlen /\ (to_uint fill = 0 => to_uint n = 0)
         /\ (to_uint fill <> 0 => to_uint fill + to_uint n <> 64 => to_uint n = to_uint _inlen)
         /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + to_uint n)
         /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i)) (to_uint _inlen)).
  + wp; ecall (__fill64_mem_proof (SBArray512_64.get_sub8 buf (64 * k)) fill p n ms
                 (SBArray512_64.get_sub buf_init (1 * (64 * k)))).
    auto => /> &m _ _ _ _ _ _ _ hk0 hk8 hult hf hfn hnl hf0 hfl hl hlv hlt.
    have := hlv k{m} _; 1: smt().
    rewrite /is_valid /= => -[hv1 [hv2 hv3]].
    have efn : to_uint (fill{m} + n{m}) = to_uint fill{m} + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    rewrite /protect_64 !W64.uleE /= efn.
    split.
    + split.
      + split; 1: smt(W64.to_uint_cmp).
        by apply (lanes64_get _ _ _ _ hl); smt(W64.to_uint_cmp).
      by split; [move=> i h1 h2; apply hv1 | split]; smt().
    move=> _ _ _ _ _ _ _ r hr _; split; 1: by rewrite full64_init; smt().
    split; 1: smt().
    by apply (lanes64_set _ _ _ _ _ hl) => //; smt(W64.to_uint_cmp).
  auto => /> &m hi0 hi1 hi2 hi3 hi4 hi5 hi6 hi7 hh hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7 hult hin.
  move=> v00 v01 v02 v10 v11 v12 v20 v21 v22 v30 v31 v32 v40 v41 v42 v50 v51 v52.
  move=> v60 v61 v62 v70 v71 v72.
  pose f := _total `&` W64.of_int 63.
  pose nn := if f = W64.of_int 0 then f
             else if inlen{m} \ult W64.of_int 64 - f then inlen{m} else W64.of_int 64 - f.
  have [#] hf hfn hnl hln hf0 hfl := absorb_head256 _total inlen{m} f nn _ _ => //.
  have hl8 := lanes8I _ _ hb0 hb1 hb2 hb3 hb4 hb5 hb6 hb7.
  move: hl8; rewrite umodc // -hf => hl8.
  split.
  + split; 1: exact (full256E _ hh).
    split; 1: exact (full64E _ hin).
    do 5!(split; 1: done).
    split; 1: exact (lanes_start _ _ _ _ _ hl8).
    by apply lanes_valid8; rewrite /is_valid /=; do !split => //.
  move=> b0 k0 ms0 tr0 hlt _ _ hk0 hk8 _ _ _ _ _ _ _ hb hlv.
  have ->> : k0 = 8 by smt().
  exact (lanes_end _ _ _ _ _ hb).
sp; seq 1 : (valid trace__sha256_x8_absorb_lanes /\ total_init /\ fill_init /\ inlen_init
             /\ ms_init /\ off_init /\ total = _total + _inlen /\ in_0 = _in /\ inlen = _inlen
             /\ h_init = full256 /\ in_init = full64 /\ _inlen \ult W64.of_int 2305843009213693952
             /\ to_uint fill < 64 /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
             /\ to_uint off <= to_uint _inlen /\ (to_uint fill <> 0 => to_uint off = to_uint _inlen)
             /\ (to_uint fill + (to_uint _inlen - to_uint off)) %% 64
                = (to_uint _total %% 64 + to_uint _inlen) %% 64
             /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i)) (to_uint _inlen)).
+ if.
  + wp; ecall (_sha256_x8_compress_proof h buf ms h_init buf_init).
    auto => /> &m _ f0 _ _ _ _ _ _ _ hult hf hfn hnl hf0 hfl hl hlv hfull.
    have efn : to_uint (f0 + n{m}) = to_uint f0 + to_uint n{m}.
    + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
    have e64 : to_uint f0 + to_uint n{m} = 64 by rewrite -efn hfull.
    move: hl; rewrite e64 => hl; rewrite (lanes8_full _ hl).
    split; 1: by split; [exact (full256_init 0 256) | exact (full512_init 0 512)].
    move=> _ _ r h3 _; split; 1: exact (full256E _ h3).
    split; 1: exact (lanes_full 8 64 8 0 0).
    rewrite /protect_64 (_ : to_uint _total %% 64 + to_uint inlen{m}
                             = (to_uint inlen{m} - to_uint n{m}) + 1 * 64) 1:/#.
    by rewrite modzMDr.
  auto => /> &m _ f0 _ _ _ _ _ _ _ hult hf hfn hnl hf0 hfl hl hlv hfull.
  have efn : to_uint (f0 + n{m}) = to_uint f0 + to_uint n{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  have h64 : to_uint f0 + to_uint n{m} <> 64.
  + by move: hfull; rewrite W64.to_uint_eq efn W64.to_uint_small.
  rewrite efn; split; 1: smt().
  split; 1: exact hl.
  by split; smt().
sp; seq 1 : (valid trace__sha256_x8_absorb_lanes /\ total_init /\ fill_init /\ inlen_init
             /\ ms_init /\ off_init /\ total = _total + _inlen /\ in_0 = _in /\ inlen = _inlen
             /\ h_init = full256 /\ in_init = full64 /\ to_uint off <= to_uint _inlen
             /\ to_uint fill + (to_uint _inlen - to_uint off)
                = (to_uint _total %% 64 + to_uint _inlen) %% 64
             /\ lanes buf_init 8 64 8 (to_uint fill) (to_uint fill)
             /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i)) (to_uint _inlen)).
+ if.
  + wp; ecall (_sha256_x8_compress_lanes_lv h in_0 off n ms h_init).
    auto => /> &m _ _ _ _ _ _ _ hult hf hl ho hf0 hm hlv hnz.
    have eLO : to_uint (inlen{m} - off{m}) = to_uint inlen{m} - to_uint off{m}.
    + by rewrite W64.to_uintB 1:W64.uleE.
    have hn : to_uint (inlen{m} - off{m} `>>` W8.of_int 6)
              = (to_uint inlen{m} - to_uint off{m}) %/ 64.
    + by rewrite -eLO; have := shrc (inlen{m} - off{m}) 6 _.
    have hn1 := nonzero _ hnz.
    have hdm := divz_eq (to_uint inlen{m} - to_uint off{m}) 64.
    have hmd := modz_ge0 (to_uint inlen{m} - to_uint off{m}) 64 _; 1: done.
    have hlt : to_uint inlen{m} < 2305843009213693952 by move: hult; rewrite W64.ultE.
    have e := mulc_small (inlen{m} - off{m} `>>` W8.of_int 6) 64 _ _; 1: done.
    + by rewrite hn; smt(W64.to_uint_cmp).
    have hb : to_uint ((inlen{m} - off{m} `>>` W8.of_int 6) `<<` W8.of_int 6)
              = 64 * ((to_uint inlen{m} - to_uint off{m}) %/ 64).
    + by rewrite -eLO; have := blocksc (inlen{m} - off{m}) 6 _.
    split.
    + split; 1: exact (full256_init 0 256).
      split; 1: by rewrite W64.ultE hn; smt(W64.to_uint_cmp).
      split; 1: by rewrite W64.ultE; smt(W64.to_uint_cmp).
      move=> k hk; have := hlv k hk; rewrite /is_valid /= => -[hv1 [hv2 hv3]].
      have ep : to_uint (get64d in_0{m} (8 * k) + off{m})
                = to_uint (get64d in_0{m} (8 * k)) + to_uint off{m}.
      + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
      rewrite /is_valid /= ep e hn; split; [move=> i hi; apply hv1 | split]; smt(W64.to_uint_cmp).
    move=> _ _ _ _ r h3 _; rewrite /protect_64.
    have eo : to_uint (off{m} + ((inlen{m} - off{m} `>>` W8.of_int 6) `<<` W8.of_int 6))
              = to_uint off{m} + 64 * ((to_uint inlen{m} - to_uint off{m}) %/ 64).
    + by rewrite W64.to_uintD_small hb; smt(W64.to_uint_cmp).
    rewrite eo; split; 1: exact (full256E _ h3).
    have hz : to_uint fill{m} = 0 by smt(W64.to_uint_cmp).
    split; 1: smt().
    split; 2: exact (lanes_full 8 64 8 0 0).
    rewrite (_ : to_uint inlen{m} - (to_uint off{m} + 64 * ((to_uint inlen{m} - to_uint off{m}) %/ 64))
                 = (to_uint inlen{m} - to_uint off{m}) %% 64) 1:/#.
    by move: hm; rewrite hz.
  auto => /> &m _ _ _ _ _ _ _ hult hf hl ho hf0 hm hlv hz.
  have eLO : to_uint (inlen{m} - off{m}) = to_uint inlen{m} - to_uint off{m}.
  + by rewrite W64.to_uintB 1:W64.uleE.
  have hn : (to_uint inlen{m} - to_uint off{m}) %/ 64 = 0.
  + have := shrc (inlen{m} - off{m}) 6 _; 1: done.
    by rewrite hz W64.to_uint0 eLO => ->.
  have hl64 : to_uint inlen{m} - to_uint off{m} < 64 by smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite -hm pmod_small; smt(W64.to_uint_cmp).
wp; while (valid trace__sha256_x8_absorb_lanes /\ total_init /\ fill_init /\ inlen_init
           /\ ms_init /\ off_init /\ n_init /\ k_init /\ 0 <= k <= 8 /\ total = _total + _inlen
           /\ in_0 = _in /\ inlen = _inlen /\ h_init = full256 /\ in_init = full64
           /\ n = _inlen - off /\ to_uint off <= to_uint _inlen
           /\ to_uint fill + (to_uint _inlen - to_uint off)
              = (to_uint _total %% 64 + to_uint _inlen) %% 64
           /\ lanes buf_init 8 64 k (to_uint fill) (to_uint fill + (to_uint _inlen - to_uint off))
           /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i)) (to_uint _inlen)).
+ wp; ecall (__fill64_mem_proof (SBArray512_64.get_sub8 buf (64 * k)) fill p n ms
               (SBArray512_64.get_sub buf_init (1 * (64 * k)))).
  auto => /> &m _ _ _ _ _ _ _ _ hk0 hk8 ho hs hl hlv hlt.
  have := hlv k{m} _; 1: smt().
  rewrite /is_valid /= => -[hv1 [hv2 hv3]].
  have eLO : to_uint (_inlen - off{m}) = to_uint _inlen - to_uint off{m}.
  + by rewrite W64.to_uintB 1:W64.uleE.
  have hfl : to_uint fill{m} + (to_uint _inlen - to_uint off{m}) < 64 by rewrite hs; smt(modz_cmp).
  have efn : to_uint (fill{m} + (_inlen - off{m}))
             = to_uint fill{m} + (to_uint _inlen - to_uint off{m}).
  + by rewrite W64.to_uintD_small eLO; smt(W64.to_uint_cmp).
  have ep : to_uint (get64d _in (8 * k{m}) + off{m})
            = to_uint (get64d _in (8 * k{m})) + to_uint off{m}.
  + by rewrite W64.to_uintD_small; smt(W64.to_uint_cmp).
  rewrite /protect_64 !W64.uleE /= efn eLO ep.
  split.
  + split.
    + split; 1: smt(W64.to_uint_cmp).
      by apply (lanes64_get _ _ _ _ hl); smt(W64.to_uint_cmp).
    by split; [move=> i h1 h2; apply hv1 | split]; smt(W64.to_uint_cmp).
  move=> _ _ _ _ _ _ _ r hr _; split; 1: by rewrite full64_init; smt().
  split; 1: smt().
  by apply (lanes64_set _ _ _ _ _ hl) => //; smt(W64.to_uint_cmp).
auto => /> &m _ _ _ _ _ _ ho hs hl hlv; split; 1: exact (lanes_start _ _ _ _ _ hl).
move=> b0 k0 ms0 tr0 hlt _ _ hk0 hk8 hb.
have ->> : k0 = 8 by smt().
have e4 : to_uint ((_total + _inlen) \umod W64.of_int 64)
          = (to_uint _total %% 64 + to_uint _inlen) %% 64.
+ rewrite umodc // W64.to_uintD w64_modulus.
  by rewrite (modz_dvd _ _ 64) // modzDml.
rewrite e4 -hs.
have [#] h0 h1 h2 h3 h4 h5 h6 h7 := lanes8E _ _ (lanes_end _ _ _ _ _ hb).
by rewrite (full256_init 0 256) h0 h1 h2 h3 h4 h5 h6 h7.
qed.
