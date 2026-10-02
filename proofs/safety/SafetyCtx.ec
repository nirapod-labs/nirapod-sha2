(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SafetyCtx.ec
 * ============
 *
 * Safety of the incremental contexts of src/ctx.jinc and its sized
 * instances: the context header, the length room, loading and storing
 * the hash state, update and final for the six hashes, and the HMAC
 * contexts. The hashes enter through SafetySha256, SafetySha512 and
 * SafetyHmac.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyFill SafetyK256 SafetyK512.
require import SafetySha256 SafetySha512 SafetyHmac.
require import BArray16 BArray28 BArray32 BArray48 BArray64 BArray112 BArray128.
require import BArray144 BArray208 BArray272 NirapodSha2Safety.
require import SBArray112_16 SBArray112_32 SBArray112_64 SBArray144_112 SBArray144_16.
require import SBArray208_128 SBArray208_16 SBArray208_64 SBArray272_16 SBArray272_208.

(* ------------------------------------------------------------------ *)
(* Context header and length room                                     *)

lemma __sha2_tag_proof _f : __sha2_tag_spec _f.
proof. by rewrite /__sha2_tag_spec; proc; auto. qed.

lemma __sha2_ctx_open_proof _head _ms _head_init :
  __sha2_ctx_open_spec _head _ms _head_init.
proof.
rewrite /__sha2_ctx_open_spec; proc; auto => /> hh.
by rewrite (full16E _ hh) !full16_init.
qed.

lemma __sha2_room_proof _total : __sha2_room_spec _total.
proof. by rewrite /__sha2_room_spec; proc; auto. qed.

(* ------------------------------------------------------------------ *)
(* Hash state                                                         *)

lemma __sha256_ctx_load_proof _h _buf _ctx _h_init _buf_init _ctx_init :
  __sha256_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init.
proof.
rewrite /__sha256_ctx_load_spec; proc.
while (valid trace___sha256_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full112
       /\ BArray32.is_init h_init 0 32 /\ BArray64.is_init buf_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hb hlt.
  have hm := mask64_set64 buf_init{m} i{m} hb _ _; 1,2: smt().
  by rewrite full112_init hm /=; smt().
wp; while (valid trace___sha256_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full112
           /\ BArray32.is_init h_init 0 (4 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask32_set32 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full112_init hm /=; smt().
auto => /> hc; split; 1: by split; [exact full112E | move=> j /#].
move=> h0 i0 tr0 hlt _ _ hi8 _ hh; split.
+ by split; [have <- : 4 * i0 = 32 by smt() | move=> j /#].
by move=> b0 i1 tr1 hlt1 _ _ hi1 _ hb; have <- : 8 * i1 = 64 by smt().
qed.

lemma __sha512_ctx_load_proof _h _buf _ctx _h_init _buf_init _ctx_init :
  __sha512_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init.
proof.
rewrite /__sha512_ctx_load_spec; proc.
while (valid trace___sha512_ctx_load /\ i_init /\ 0 <= i <= 16 /\ ctx_init = full208
       /\ BArray64.is_init h_init 0 64 /\ BArray128.is_init buf_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hb hlt.
  have hm := mask128_set64 buf_init{m} i{m} hb _ _; 1,2: smt().
  by rewrite full208_init hm /=; smt().
wp; while (valid trace___sha512_ctx_load /\ i_init /\ 0 <= i <= 8 /\ ctx_init = full208
           /\ BArray64.is_init h_init 0 (8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hlt.
  have hm := mask64_set64 h_init{m} i{m} hh _ _; 1,2: smt().
  by rewrite full208_init hm /=; smt().
auto => /> hc; split; 1: by split; [exact full208E | move=> j /#].
move=> h0 i0 tr0 hlt _ _ hi8 _ hh; split.
+ by split; [have <- : 8 * i0 = 64 by smt() | move=> j /#].
by move=> b0 i1 tr1 hlt1 _ _ hi1 _ hb; have <- : 8 * i1 = 128 by smt().
qed.

(* A word written at byte offset k into a mask initialised below k.
   The context layouts place words at offsets that are not multiples
   of the word size of the array index, so the byte-offset form is
   the one the stores need. *)
lemma mask112_set32d (m : BArray112.t) k :
  BArray112.is_init m 0 k => 0 <= k => k + 4 <= 112 =>
  BArray112.is_init (BArray112.set32d m k (W32.of_int 4294967295)) 0 (k + 4).
proof.
move=> hm hk hb j hj0 hj; rewrite BArray112.is_init_cell_set32d.
by case: (j < k) => hjk; [right; apply hm | left] => /#.
qed.

lemma mask112_set64d (m : BArray112.t) k :
  BArray112.is_init m 0 k => 0 <= k => k + 8 <= 112 =>
  BArray112.is_init (BArray112.set64d m k (W64.of_int 18446744073709551615)) 0 (k + 8).
proof.
move=> hm hk hb j hj0 hj; rewrite BArray112.is_init_cell_set64d.
by case: (j < k) => hjk; [right; apply hm | left] => /#.
qed.

lemma __sha256_ctx_init_proof _ctx _h _tag _total _ctx_init _h_init :
  __sha256_ctx_init_spec _ctx _h _tag _total _ctx_init _h_init.
proof.
rewrite /__sha256_ctx_init_spec; proc.
while (valid trace___sha256_ctx_init /\ i_init /\ z_init /\ 0 <= i <= 8
       /\ BArray112.is_init ctx_init 0 (48 + 8 * i)).
+ auto => /> &m _ _ _ hi0 hi8 hc hlt.
  have hm := mask112_set64d ctx_init{m} (48 + 8 * i{m}) hc _ _; 1,2: smt().
  by rewrite (_ : 48 + 8 * (i{m} + 1) = 48 + 8 * i{m} + 8) 1:/#; smt().
wp; while (valid trace___sha256_ctx_init /\ i_init /\ 0 <= i <= 8
           /\ BArray32.is_init h_init 0 32 /\ BArray112.is_init ctx_init 0 (16 + 4 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hc hlt.
  have hm := mask112_set32d ctx_init{m} (16 + 4 * i{m}) hc _ _; 1,2: smt().
  rewrite (_ : 16 + 4 * (i{m} + 1) = 16 + 4 * i{m} + 4) 1:/#.
  have hw : BArray32.is_init h_init{m} (i{m} * 4) 4 by move=> j hj0 hj1; apply hh => /#.
  by smt().
auto => /> hh.
have h0 := mask112_set64d _ctx_init 0 _ _ _; 1..3: by move=> // j /#.
have h8 := mask112_set64d _ 8 h0 _ _; 1,2: done.
split; 1: exact h8.
move=> c0 i0 tr0 hlt _ hi0 hi8 hc; split; 1: by have <- : 16 + 4 * i0 = 48 by smt().
by move=> c1 i1 tr1 hlt1 _ hi1 hi18 hc1; have <- : 48 + 8 * i1 = 112 by smt().
qed.

lemma mask208_set64d (m : BArray208.t) k :
  BArray208.is_init m 0 k => 0 <= k => k + 8 <= 208 =>
  BArray208.is_init (BArray208.set64d m k (W64.of_int 18446744073709551615)) 0 (k + 8).
proof.
move=> hm hk hb j hj0 hj; rewrite BArray208.is_init_cell_set64d.
by case: (j < k) => hjk; [right; apply hm | left] => /#.
qed.

lemma __sha512_ctx_init_proof _ctx _h _tag _total _ctx_init _h_init :
  __sha512_ctx_init_spec _ctx _h _tag _total _ctx_init _h_init.
proof.
rewrite /__sha512_ctx_init_spec; proc.
while (valid trace___sha512_ctx_init /\ i_init /\ z_init /\ 0 <= i <= 16
       /\ BArray208.is_init ctx_init 0 (80 + 8 * i)).
+ auto => /> &m _ _ _ hi0 hi8 hc hlt.
  have hm := mask208_set64d ctx_init{m} (80 + 8 * i{m}) hc _ _; 1,2: smt().
  by rewrite (_ : 80 + 8 * (i{m} + 1) = 80 + 8 * i{m} + 8) 1:/#; smt().
wp; while (valid trace___sha512_ctx_init /\ i_init /\ 0 <= i <= 8
           /\ BArray64.is_init h_init 0 64 /\ BArray208.is_init ctx_init 0 (16 + 8 * i)).
+ auto => /> &m _ _ hi0 hi8 hh hc hlt.
  have hm := mask208_set64d ctx_init{m} (16 + 8 * i{m}) hc _ _; 1,2: smt().
  rewrite (_ : 16 + 8 * (i{m} + 1) = 16 + 8 * i{m} + 8) 1:/#.
  have hw : BArray64.is_init h_init{m} (i{m} * 8) 8 by move=> j hj0 hj1; apply hh => /#.
  by smt().
auto => /> hh.
have h0 := mask208_set64d _ctx_init 0 _ _ _; 1..3: by move=> // j /#.
have h8 := mask208_set64d _ 8 h0 _ _; 1,2: done.
split; 1: exact h8.
move=> c0 i0 tr0 hlt _ hi0 hi8 hc; split; 1: by have <- : 16 + 8 * i0 = 80 by smt().
by move=> c1 i1 tr1 hlt1 _ hi1 hi18 hc1; have <- : 80 + 8 * i1 = 208 by smt().
qed.

(* ------------------------------------------------------------------ *)
(* Update                                                             *)

(* The context stores the block buffer whole, so its mask is the full
   mask on entry. The absorb contracts only promise the buffered
   prefix; these lemmas add that a full buffer mask stays full, which
   the stores back into the context need. *)
lemma __fill64_mem_full :
  hoare [M.__fill64_mem : buf_init = full64 ==> res.`3 = full64].
proc; wp; while (buf_init = full64); 1: by auto => /> &m _; rewrite full64_set8.
wp; while (buf_init = full64); 1: by auto => /> &m _; rewrite full64_set64d.
by wp; while (buf_init = full64); auto => /> &m _; rewrite full64_set8.
qed.

lemma _sha256_absorb_mem_fullm :
  hoare [M._sha256_absorb_mem : buf_init = full64 ==> res.`6 = full64].
proof.
proc; sp; seq 1 : (buf_init = full64); 1: by call __fill64_mem_full; auto.
sp; seq 1 : (buf_init = full64).
+ by if; [wp; call (: true ==> true) => //; auto | auto].
sp; seq 1 : (buf_init = full64).
+ by if; [wp; call (: true ==> true) => //; auto | auto].
by sp; seq 1 : (buf_init = full64); [call __fill64_mem_full; auto | auto].
qed.

lemma _sha256_absorb_mem_full _h _buf _total _in _inlen _ms _h_init :
  hoare [M._sha256_absorb_mem :
    (full64 = buf_init /\ _h_init = h_init /\ _ms = ms /\ _inlen = inlen /\ _in = in_0
     /\ _total = total /\ _buf = buf /\ _h = h)
    /\ BArray32.is_init _h_init 0 32
    /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)
    ==> res.`5 = full32 /\ res.`6 = full64 /\ valid res.`7].
proof.
have := _sha256_absorb_mem_proof _h _buf _total _in _inlen _ms _h_init full64.
rewrite /_sha256_absorb_mem_spec => ha.
conseq ha _sha256_absorb_mem_fullm => />.
+ by move=> &m hb *; split; [exact full64_init | rewrite hb].
by move=> &m _ _ _ _ _ _ _ _ _ _ _ _ r h5 *; exact (full32E _ h5).
qed.

lemma set_sub112_32_full o :
  0 <= o => o + 32 <= 112 => SBArray112_32.set_sub full112 o full32 = full112.
proof.
move=> h0 h1; apply full112E => j hj0 hj1; rewrite SBArray112_32.is_init_cell_set.
case: (o <= j < o + 32) => hj.
+ by rewrite ifT 1:/#; apply (full32_init 0 32) => /#.
by rewrite ifF 1:/#; apply (full112_init 0 112).
qed.

lemma set_sub112_64_full o :
  0 <= o => o + 64 <= 112 => SBArray112_64.set_sub full112 o full64 = full112.
proof.
move=> h0 h1; apply full112E => j hj0 hj1; rewrite SBArray112_64.is_init_cell_set.
case: (o <= j < o + 64) => hj.
+ by rewrite ifT 1:/#; apply (full64_init 0 64) => /#.
by rewrite ifF 1:/#; apply (full112_init 0 112).
qed.

lemma _sha256_ctx_update_proof _ctx _in _inlen _expect _ms _ctx_init :
  _sha256_ctx_update_spec _ctx _in _inlen _expect _ms _ctx_init.
proof.
rewrite /_sha256_ctx_update_spec; proc; sp.
seq 1 : (valid trace__sha256_ctx_update /\ valid M.tmp__trace /\ ctx_init = full112
         /\ in_init /\ inlen_init /\ ms_init /\ expect_init
         /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint in_0) (W64.to_uint inlen)).
+ ecall (__sha2_ctx_open_proof (SBArray112_16.get_sub8 ctx 0) ms (SBArray112_16.get_sub ctx_init 0)).
  auto => /> &m hc *; rewrite (full112E _ hc) /=.
  by apply (sub112_16_get _ 0 0 16) => //; exact full112_init.
sp; if; last by auto => /> *; exact (full112_init 0 112).
sp; seq 1 : (valid trace__sha256_ctx_update /\ valid M.tmp__trace /\ ctx_init = full112
             /\ in_init /\ inlen_init /\ ms_init /\ total_init
             /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint in_0) (W64.to_uint inlen)).
+ by ecall (__sha2_room_proof total); auto.
sp; if; last by auto => /> *; exact (full112_init 0 112).
wp; ecall (_sha256_absorb_mem_full (SBArray112_32.get_sub32 ctx 4) (SBArray112_64.get_sub8 ctx 48)
            total in_0 inlen ms (SBArray112_32.get_sub ctx_init (4 * 4))).
auto => /> &m tr *.
have h48 : SBArray112_64.get_sub full112 48 = full64.
+ by apply full64E; apply (sub112_64_get _ 48 0 64) => //; exact full112_init.
have h16 : BArray112.is_init full112 (16 + 0) 32 by exact full112_init.
rewrite h48 (sub112_32_get _ 16 0 32 h16) //= => r -> -> _.
by rewrite set_sub112_32_full // set_sub112_64_full // full112_set64d; exact (full112_init 0 112).
qed.

(* SHA-512: the same scripts over the 208-byte context. *)

lemma __fill128_mem_full :
  hoare [M.__fill128_mem : buf_init = full128 ==> res.`3 = full128].
proc; wp; while (buf_init = full128); 1: by auto => /> &m _; rewrite full128_set8.
wp; while (buf_init = full128); 1: by auto => /> &m _; rewrite full128_set64d.
by wp; while (buf_init = full128); auto => /> &m _; rewrite full128_set8.
qed.

lemma _sha512_absorb_mem_fullm :
  hoare [M._sha512_absorb_mem : buf_init = full128 ==> res.`6 = full128].
proof.
proc; sp; seq 1 : (buf_init = full128); 1: by call __fill128_mem_full; auto.
sp; seq 1 : (buf_init = full128).
+ by if; [wp; call (: true ==> true) => //; auto | auto].
sp; seq 1 : (buf_init = full128).
+ by if; [wp; call (: true ==> true) => //; auto | auto].
by sp; seq 1 : (buf_init = full128); [call __fill128_mem_full; auto | auto].
qed.

lemma _sha512_absorb_mem_full _h _buf _total _in _inlen _ms _h_init :
  hoare [M._sha512_absorb_mem :
    (full128 = buf_init /\ _h_init = h_init /\ _ms = ms /\ _inlen = inlen /\ _in = in_0
     /\ _total = total /\ _buf = buf /\ _h = h)
    /\ BArray64.is_init _h_init 0 64
    /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)
    ==> res.`5 = full64 /\ res.`6 = full128 /\ valid res.`7].
proof.
have := _sha512_absorb_mem_proof _h _buf _total _in _inlen _ms _h_init full128.
rewrite /_sha512_absorb_mem_spec => ha.
conseq ha _sha512_absorb_mem_fullm => />.
+ by move=> &m hb *; split; [exact full128_init | rewrite hb].
by move=> &m _ _ _ _ _ _ _ _ _ _ _ _ r h5 *; exact (full64E _ h5).
qed.

lemma set_sub208_64_full o :
  0 <= o => o + 64 <= 208 => SBArray208_64.set_sub full208 o full64 = full208.
proof.
move=> h0 h1; apply full208E => j hj0 hj1; rewrite SBArray208_64.is_init_cell_set.
case: (o <= j < o + 64) => hj.
+ by rewrite ifT 1:/#; apply (full64_init 0 64) => /#.
by rewrite ifF 1:/#; apply (full208_init 0 208).
qed.

lemma set_sub208_128_full o :
  0 <= o => o + 128 <= 208 => SBArray208_128.set_sub full208 o full128 = full208.
proof.
move=> h0 h1; apply full208E => j hj0 hj1; rewrite SBArray208_128.is_init_cell_set.
case: (o <= j < o + 128) => hj.
+ by rewrite ifT 1:/#; apply (full128_init 0 128) => /#.
by rewrite ifF 1:/#; apply (full208_init 0 208).
qed.

lemma _sha512_ctx_update_proof _ctx _in _inlen _expect _ms _ctx_init :
  _sha512_ctx_update_spec _ctx _in _inlen _expect _ms _ctx_init.
proof.
rewrite /_sha512_ctx_update_spec; proc; sp.
seq 1 : (valid trace__sha512_ctx_update /\ valid M.tmp__trace /\ ctx_init = full208
         /\ in_init /\ inlen_init /\ ms_init /\ expect_init
         /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint in_0) (W64.to_uint inlen)).
+ ecall (__sha2_ctx_open_proof (SBArray208_16.get_sub8 ctx 0) ms (SBArray208_16.get_sub ctx_init 0)).
  auto => /> &m hc *; rewrite (full208E _ hc) /=.
  by apply (sub208_16_get _ 0 0 16) => //; exact full208_init.
sp; if; last by auto => /> *; exact (full208_init 0 208).
sp; seq 1 : (valid trace__sha512_ctx_update /\ valid M.tmp__trace /\ ctx_init = full208
             /\ in_init /\ inlen_init /\ ms_init /\ total_init
             /\ is_valid (2 ^ 64) Glob.mem_v (W64.to_uint in_0) (W64.to_uint inlen)).
+ by ecall (__sha2_room_proof total); auto.
sp; if; last by auto => /> *; exact (full208_init 0 208).
wp; ecall (_sha512_absorb_mem_full (SBArray208_64.get_sub64 ctx 2) (SBArray208_128.get_sub8 ctx 80)
            total in_0 inlen ms (SBArray208_64.get_sub ctx_init (8 * 2))).
auto => /> &m tr *.
have h48 : SBArray208_128.get_sub full208 80 = full128.
+ by apply full128E; apply (sub208_128_get _ 80 0 128) => //; exact full208_init.
have h16 : BArray208.is_init full208 (16 + 0) 64 by exact full208_init.
rewrite h48 (sub208_64_get _ 16 0 64 h16) //= => r -> -> _.
by rewrite set_sub208_64_full // set_sub208_128_full // full208_set64d; exact (full208_init 0 208).
qed.

(* ------------------------------------------------------------------ *)
(* Final                                                              *)

(* A failed final reports status 1, so its digest mask covers nothing. *)
lemma one_neq_zero : W64.one <> W64.zero.
proof. by rewrite W64.to_uint_eq to_uint_one. qed.

lemma ctx112_h : SBArray112_32.get_sub full112 16 = full32.
proof. by apply full32E; apply (sub112_32_get _ 16 0 32) => //; exact full112_init. qed.

lemma ctx112_buf : SBArray112_64.get_sub full112 48 = full64.
proof. by apply full64E; apply (sub112_64_get _ 48 0 64) => //; exact full112_init. qed.

lemma ctx112_store (a : BArray32.t) (b : BArray64.t) :
  BArray32.is_init a 0 32 => BArray64.is_init b 0 64 =>
  SBArray112_64.set_sub (SBArray112_32.set_sub full112 16 a) 48 b = full112.
proof.
move=> ha hb; rewrite (full32E _ ha) (full64E _ hb).
by rewrite set_sub112_32_full // set_sub112_64_full.
qed.

lemma _sha224_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha224_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha224_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha224___sha256_finalize_proof digest (SBArray112_32.get_sub32 ctx 4)
         (SBArray112_64.get_sub8 ctx 48) total ms digest_init
         (SBArray112_32.get_sub ctx_init (4 * 4)) (SBArray112_64.get_sub ctx_init (1 * 48))).
auto => /> hc; rewrite (full112E _ hc) /= ctx112_h ctx112_buf.
split; 1: by split; [exact full32_init | exact full64_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx112_store //; exact full112_init.
qed.

lemma _sha224_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha224_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha224_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha224_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full112
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray112_16.get_sub8 ctx 0) ms (SBArray112_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full112E _ hc) /=.
  by apply (sub112_16_get _ 0 0 16) => //; exact full112_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full112_init 0 112).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha224_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray112.is_init ctx_init 0 112 /\ BArray28.is_init digest_init 0 28 /\ ms_init).
+ ecall (_sha224_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full112_init 0 112).
wp; while (valid trace__sha224_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 14 /\ 0 <= i <= 14
       /\ ctx_init = full112 /\ BArray28.is_init digest_init 0 28).
+ by auto => /> &m *; rewrite full112_set64d; smt().
auto => /> &m *; split; 1: smt(full112E).
by move=> *; exact (full112_init 0 112).
qed.

lemma _sha256_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha256_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha256_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha256___sha256_finalize_proof digest (SBArray112_32.get_sub32 ctx 4)
         (SBArray112_64.get_sub8 ctx 48) total ms digest_init
         (SBArray112_32.get_sub ctx_init (4 * 4)) (SBArray112_64.get_sub ctx_init (1 * 48))).
auto => /> hc; rewrite (full112E _ hc) /= ctx112_h ctx112_buf.
split; 1: by split; [exact full32_init | exact full64_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx112_store //; exact full112_init.
qed.

lemma _sha256_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha256_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha256_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha256_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full112
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray112_16.get_sub8 ctx 0) ms (SBArray112_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full112E _ hc) /=.
  by apply (sub112_16_get _ 0 0 16) => //; exact full112_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full112_init 0 112).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha256_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray112.is_init ctx_init 0 112 /\ BArray32.is_init digest_init 0 32 /\ ms_init).
+ ecall (_sha256_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full112_init 0 112).
wp; while (valid trace__sha256_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 14 /\ 0 <= i <= 14
       /\ ctx_init = full112 /\ BArray32.is_init digest_init 0 32).
+ by auto => /> &m *; rewrite full112_set64d; smt().
auto => /> &m *; split; 1: smt(full112E).
by move=> *; exact (full112_init 0 112).
qed.

(* SHA-384, SHA-512, SHA-512/224 and SHA-512/256 over the 208-byte context. *)

lemma ctx208_h : SBArray208_64.get_sub full208 16 = full64.
proof. by apply full64E; apply (sub208_64_get _ 16 0 64) => //; exact full208_init. qed.

lemma ctx208_buf : SBArray208_128.get_sub full208 80 = full128.
proof. by apply full128E; apply (sub208_128_get _ 80 0 128) => //; exact full208_init. qed.

lemma ctx208_store (a : BArray64.t) (b : BArray128.t) :
  BArray64.is_init a 0 64 => BArray128.is_init b 0 128 =>
  SBArray208_128.set_sub (SBArray208_64.set_sub full208 16 a) 80 b = full208.
proof.
move=> ha hb; rewrite (full64E _ ha) (full128E _ hb).
by rewrite set_sub208_64_full // set_sub208_128_full.
qed.

lemma _sha384_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha384_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha384_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha384___sha512_finalize_proof digest (SBArray208_64.get_sub64 ctx 2)
         (SBArray208_128.get_sub8 ctx 80) total ms digest_init
         (SBArray208_64.get_sub ctx_init (8 * 2)) (SBArray208_128.get_sub ctx_init (1 * 80))).
auto => /> hc; rewrite (full208E _ hc) /= ctx208_h ctx208_buf.
split; 1: by split; [exact full64_init | exact full128_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx208_store //; exact full208_init.
qed.

lemma _sha384_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha384_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha384_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha384_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full208
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray208_16.get_sub8 ctx 0) ms (SBArray208_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full208E _ hc) /=.
  by apply (sub208_16_get _ 0 0 16) => //; exact full208_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full208_init 0 208).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha384_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray208.is_init ctx_init 0 208 /\ BArray48.is_init digest_init 0 48 /\ ms_init).
+ ecall (_sha384_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full208_init 0 208).
wp; while (valid trace__sha384_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 26 /\ 0 <= i <= 26
       /\ ctx_init = full208 /\ BArray48.is_init digest_init 0 48).
+ by auto => /> &m *; rewrite full208_set64d; smt().
auto => /> &m *; split; 1: smt(full208E).
by move=> *; exact (full208_init 0 208).
qed.

lemma _sha512_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha512_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha512___sha512_finalize_proof digest (SBArray208_64.get_sub64 ctx 2)
         (SBArray208_128.get_sub8 ctx 80) total ms digest_init
         (SBArray208_64.get_sub ctx_init (8 * 2)) (SBArray208_128.get_sub ctx_init (1 * 80))).
auto => /> hc; rewrite (full208E _ hc) /= ctx208_h ctx208_buf.
split; 1: by split; [exact full64_init | exact full128_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx208_store //; exact full208_init.
qed.

lemma _sha512_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha512_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha512_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full208
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray208_16.get_sub8 ctx 0) ms (SBArray208_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full208E _ hc) /=.
  by apply (sub208_16_get _ 0 0 16) => //; exact full208_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full208_init 0 208).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha512_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray208.is_init ctx_init 0 208 /\ BArray64.is_init digest_init 0 64 /\ ms_init).
+ ecall (_sha512_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full208_init 0 208).
wp; while (valid trace__sha512_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 26 /\ 0 <= i <= 26
       /\ ctx_init = full208 /\ BArray64.is_init digest_init 0 64).
+ by auto => /> &m *; rewrite full208_set64d; smt().
auto => /> &m *; split; 1: smt(full208E).
by move=> *; exact (full208_init 0 208).
qed.

lemma _sha512_224_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha512_224_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_224_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha512_224___sha512_finalize_proof digest (SBArray208_64.get_sub64 ctx 2)
         (SBArray208_128.get_sub8 ctx 80) total ms digest_init
         (SBArray208_64.get_sub ctx_init (8 * 2)) (SBArray208_128.get_sub ctx_init (1 * 80))).
auto => /> hc; rewrite (full208E _ hc) /= ctx208_h ctx208_buf.
split; 1: by split; [exact full64_init | exact full128_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx208_store //; exact full208_init.
qed.

lemma _sha512_224_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha512_224_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_224_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha512_224_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full208
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray208_16.get_sub8 ctx 0) ms (SBArray208_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full208E _ hc) /=.
  by apply (sub208_16_get _ 0 0 16) => //; exact full208_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full208_init 0 208).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha512_224_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray208.is_init ctx_init 0 208 /\ BArray28.is_init digest_init 0 28 /\ ms_init).
+ ecall (_sha512_224_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full208_init 0 208).
wp; while (valid trace__sha512_224_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 26 /\ 0 <= i <= 26
       /\ ctx_init = full208 /\ BArray28.is_init digest_init 0 28).
+ by auto => /> &m *; rewrite full208_set64d; smt().
auto => /> &m *; split; 1: smt(full208E).
by move=> *; exact (full208_init 0 208).
qed.

lemma _sha512_256_ctx____ctx_finalize_proof _ctx _digest _total _ms _ctx_init _digest_init :
  _sha512_256_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_256_ctx____ctx_finalize_spec; proc; wp.
ecall (_sha512_256___sha512_finalize_proof digest (SBArray208_64.get_sub64 ctx 2)
         (SBArray208_128.get_sub8 ctx 80) total ms digest_init
         (SBArray208_64.get_sub ctx_init (8 * 2)) (SBArray208_128.get_sub ctx_init (1 * 80))).
auto => /> hc; rewrite (full208E _ hc) /= ctx208_h ctx208_buf.
split; 1: by split; [exact full64_init | exact full128_init].
by move=> _ _ r _ h6 h7 _; rewrite ctx208_store //; exact full208_init.
qed.

lemma _sha512_256_ctx___sha2_ctx_final_proof _ctx _digest _expect _ms _ctx_init _digest_init :
  _sha512_256_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init.
proof.
rewrite /_sha512_256_ctx___sha2_ctx_final_spec; proc; sp.
seq 1 : (valid trace__sha512_256_ctx___sha2_ctx_final /\ valid M.tmp__trace /\ ctx_init = full208
         /\ ms_init /\ expect_init).
+ ecall (__sha2_ctx_open_proof (SBArray208_16.get_sub8 ctx 0) ms (SBArray208_16.get_sub ctx_init 0)).
  auto => /> hc; rewrite (full208E _ hc) /=.
  by apply (sub208_16_get _ 0 0 16) => //; exact full208_init.
sp; if; last first.
+ auto => /> &m *; split; 1: exact (full208_init 0 208).
  have -> : (W64.one = W64.zero) = false by smt(one_neq_zero).
  by move=> j /#.
sp; seq 1 : (valid trace__sha512_256_ctx___sha2_ctx_final /\ valid M.tmp__trace
             /\ BArray208.is_init ctx_init 0 208 /\ BArray32.is_init digest_init 0 32 /\ ms_init).
+ ecall (_sha512_256_ctx____ctx_finalize_proof ctx digest total ms ctx_init digest_init); auto => /> *.
  exact (full208_init 0 208).
wp; while (valid trace__sha512_256_ctx___sha2_ctx_final /\ i_init /\ z_init /\ inc = 26 /\ 0 <= i <= 26
       /\ ctx_init = full208 /\ BArray32.is_init digest_init 0 32).
+ by auto => /> &m *; rewrite full208_set64d; smt().
auto => /> &m *; split; 1: smt(full208E).
by move=> *; exact (full208_init 0 208).
qed.
