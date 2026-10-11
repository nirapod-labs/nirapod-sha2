(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Stream.ec
 * ================
 *
 * Functional correctness of the streaming SHA-224 and SHA-256 of
 * src/sha256.jinc against FIPS 180-4 sections 5.1.1, 5.2.1, 5.3.2, 5.3.3
 * and 6.2 (spec/FIPS180_SHA2.ec), over the unit's SHA-256 kernel as K256
 * states it.
 *
 * Stream state. After a message m has been absorbed from a starting
 * chaining value h0, the state (h, buf, total) satisfies stream256 h0 m:
 *
 *     total  = |m|
 *     h      = compress folded from h0 over the complete 64-byte blocks
 *              of m (parse m: chunk drops an incomplete last block)
 *     buf    holds the |m| mod 64 bytes after those blocks in its first
 *            cells (pending); the other cells are unconstrained
 *
 * Theorems (total correctness, phoare ... = 1%r):
 *     sha256_init_total, sha224_init_total
 *                          the initial hash value of section 5.3.3, 5.3.2
 *     sha256_absorb_mem_total
 *                          absorbing l bytes from memory at p extends m by
 *                          those bytes
 *     sha256_finalize_total, sha224_finalize_total
 *                          padding and the last one or two blocks give the
 *                          digest of m from h0, whole or truncated
 *     sha256_mem_from_total, sha224_mem_from_total
 *                          the digest of l bytes at p from h0
 *     sha256_mem_total, sha224_mem_total
 *                          the one-shot SHA-256 and SHA-224 of l bytes at p
 *
 * Domain: the input does not wrap the address space (p + l < 2^64, the
 * absorb advances its pointer past the last byte it reads) and messages
 * are below 2^61 bytes, so the length field 8 |m| fits in 64 bits.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray28 BArray32 BArray64.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill.
require JWordList K256 HMACSpec.
import SHA256.

abbrev memread = JWordList.memread.

(* ------------------------------------------------------------------ *)
(* The stream state                                                   *)

(* The first size r cells of buf are r. *)
op pending (buf : BArray64.t) (r : bytes) =
  forall i, 0 <= i < size r => BArray64.get8 buf i = nth W8.zero r i.

op stream256 (h0 : W32.t list) (m : bytes) (h : BArray32.t) (buf : BArray64.t) (total : W64.t) =
     to_uint total = size m
  /\ h256 h = foldl compress h0 (parse m)
  /\ pending buf (tail 64 m).

lemma pending_nil (buf : BArray64.t) : pending buf [].
proof. by move=> i /= /#. qed.

(* Filling cells [size t, size t + k) from memory extends the pending
   bytes t by the k bytes read. *)
lemma pending_fill (b0 b : BArray64.t) mem (t : bytes) p k :
  0 <= k => size t + k <= 64 => pending b0 t => fill64v b0 mem (size t) p (size t + k) b =>
  pending b (t ++ memread mem p k).
proof.
move=> hk hs hp hf i; rewrite size_cat JWordList.size_memread // => hi.
rewrite hf 1:/# nth_cat.
case: (i < size t) => hit.
+ by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# JWordList.nth_memread /#.
qed.

(* A pending block of 64 bytes is the whole buffer. *)
lemma pending_full (b : BArray64.t) (r : bytes) :
  size r = 64 => pending b r => BArray64.to_list b = r.
proof.
move=> hs hp; apply (eq_from_nth W8.zero); first by rewrite BArray64.size_to_list hs.
by move=> i; rewrite BArray64.size_to_list => hi; rewrite BArray64.get_to_list hp /#.
qed.

(* ------------------------------------------------------------------ *)
(* The three ways an absorb extends m (section 5.2.1)                 *)

lemma parse_close (m y : bytes) : size (tail 64 m ++ y) = 64 =>
  parse (m ++ y) = rcons (parse m) (map be32 (chunk 4 (tail 64 m ++ y)))
  /\ tail 64 (m ++ y) = [].
proof.
move=> hs; have [hc ht] := close_block 64 m y _ hs => //.
by rewrite /parse hc map_rcons.
qed.

lemma parse_short (m y : bytes) : size (tail 64 m ++ y) < 64 =>
  parse (m ++ y) = parse m /\ tail 64 (m ++ y) = tail 64 m ++ y.
proof. by move=> hs; have [hc ht] := short_ext 64 m y _ hs => //; rewrite /parse hc. qed.

lemma parse_blocks (m x : bytes) : tail 64 m = [] => 64 %| size x =>
  parse (m ++ x) = parse m ++ parse x /\ tail 64 (m ++ x) = [].
proof.
by move=> hm hx; have [hc ht] := blocks_ext 64 m x _ hm hx => //; rewrite /parse hc map_cat.
qed.

lemma tail_nil (m : bytes) : size m %% 64 = 0 => tail 64 m = [].
proof. by move=> h; apply size_eq0; rewrite size_tail. qed.

(* ------------------------------------------------------------------ *)
(* Absorbing bytes from memory                                        *)

(* The bytes the absorb takes into the pending block (nfill). *)
lemma fill_count (f l : W64.t) : to_uint f < 64 =>
  to_uint (if f = W64.zero then f
           else if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f)
  = nfill 64 (to_uint f) (to_uint l).
proof.
move=> hf; rewrite /nfill; case: (f = W64.zero) => [->|hz] //=.
have hf0 : to_uint f <> 0 by move: hz; apply contra => h; apply W64.to_uint_eq.
have hs : to_uint (W64.of_int 64 - f) = 64 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
rewrite hf0 /=; case: (l \ult W64.of_int 64 - f); rewrite W64.ultE hs /#.
qed.

op nf256 (m : bytes) (l : int) : int = nfill 64 (size m %% 64) l.

(* m after the first two phases: the pending block completed, then the
   whole blocks that follow. *)
op ab256 mem (m : bytes) p l : bytes =
  (m ++ memread mem p (nf256 m l))
  ++ memread mem (p + nf256 m l) (64 * ((l - nf256 m l) %/ 64)).

lemma sha256_absorb_mem_correct (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  hoare [M._sha256_absorb_mem :
           stream256 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\
           size m + to_uint l0 < W64.modulus ==>
           stream256 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0))
             res.`1 res.`2 res.`3].
proof.
proc.
seq 8 : (to_uint fill = size m %% 64 /\ to_uint n = nf256 m (to_uint l0) /\
         to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf256 m (to_uint l0) /\ in_0 = p0 /\
         h256 h = foldl compress h0 (parse m) /\ pending buf (tail 64 m) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ auto => /> &hr ht hh hp hpl hml.
  have hr := modz_cmp (size m) 64.
  have hf : to_uint (total{hr} `&` W64.of_int 63) = size m %% 64 by rewrite and63 ht.
  have hn := fill_count (total{hr} `&` W64.of_int 63) l0 _; 1: by rewrite hf /#.
  have hb := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  rewrite /nf256 -hf -hn W64.to_uintD_small 1:/# ht /=.
  by rewrite W64.to_uintB // W64.uleE hn hf; smt().
seq 1 : (to_uint fill = size m %% 64 /\ to_uint n = nf256 m (to_uint l0) /\
         to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf256 m (to_uint l0) /\ in_0 = p0 /\
         h256 h = foldl compress h0 (parse m) /\
         pending buf (tail 64 m ++ memread Glob.mem (to_uint p0) (nf256 m (to_uint l0))) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ ecall (fill64_correct buf fill in_0 n); auto => /> &hr hf hn ht hi hh hp hpl hml.
  have hr := modz_cmp (size m) 64.
  have hb := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  have hs : size (tail 64 m) = size m %% 64 by rewrite size_tail.
  split; first by rewrite hf hn /nf256; smt().
  move=> _ _ [b1 ms1] /= hb1; apply (pending_fill buf{hr}); 1,2: smt().
  + exact hp.
  by rewrite hs -hf -hn.
seq 4 : (to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf256 m (to_uint l0) /\
         to_uint in_0 = to_uint p0 + nf256 m (to_uint l0) /\
         h256 h = foldl compress h0 (parse (m ++ memread Glob.mem (to_uint p0) (nf256 m (to_uint l0)))) /\
         pending buf (tail 64 (m ++ memread Glob.mem (to_uint p0) (nf256 m (to_uint l0)))) /\
         to_uint fill = size (m ++ memread Glob.mem (to_uint p0) (nf256 m (to_uint l0))) %% 64 /\
         (to_uint inlen <> 0 => to_uint fill = 0) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ sp; if.
  + wp; ecall (K256.compress_correct (h256 h) buf); auto => /> &hr.
    move=> f0 hf hn ht hi hh hp hpl hml hfull [h1 ms1] /= hh1.
    rewrite /Jslh.SLH64.protect_64 /Jslh.SLH64.protect_ptr /=.
    have hr := modz_cmp (size m) 64.
    have hb := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
    have hsum : size m %% 64 + nf256 m (to_uint l0) = 64.
    + have : to_uint (f0 + n{hr}) = 64 by rewrite hfull.
      by rewrite W64.to_uintD_small hf hn /nf256; smt().
    pose x := memread Glob.mem{hr} (to_uint p0) (nf256 m (to_uint l0)).
    have hsx : size (tail 64 m ++ x) = 64.
    + by rewrite size_cat size_tail // JWordList.size_memread /nf256; smt().
    have [hpc htc] := parse_close m x hsx.
    do !split.
    + by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
    + by rewrite hpc foldl_rcons hh1 hh (pending_full buf{hr} _ hsx hp).
    + by rewrite htc; exact pending_nil.
    by rewrite size_cat JWordList.size_memread 1:/nf256 1:/# -modzDml hsum.
  auto => /> &hr f0 hf hn ht hi hh hp hpl hml hfull.
  have hr := modz_cmp (size m) 64.
  have hb := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  have hfn : to_uint (f0 + n{hr}) = size m %% 64 + nf256 m (to_uint l0).
  + by rewrite W64.to_uintD_small hf hn /nf256; smt().
  have hlt : size m %% 64 + nf256 m (to_uint l0) < 64.
  + have : to_uint (f0 + n{hr}) <> 64.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    by rewrite /nf256; smt().
  pose x := memread Glob.mem{hr} (to_uint p0) (nf256 m (to_uint l0)).
  have hsx : size (tail 64 m ++ x) < 64.
  + by rewrite size_cat size_tail // JWordList.size_memread /nf256; smt().
  have [hps hts] := parse_short m x hsx.
  do !split.
  + by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
  + by rewrite hps.
  + by rewrite hts.
  + rewrite hfn size_cat JWordList.size_memread 1:/nf256 1:/# -modzDml.
    by rewrite (pmod_small (size m %% 64 + nf256 m (to_uint l0))) 1:/#.
  move=> hin; rewrite hfn; move: hin hlt; rewrite hi /nf256 /nfill.
  by case: (size m %% 64 = 0) => hz /=; smt().
seq 7 : (to_uint total = size m + to_uint l0 /\
         to_uint inlen = (to_uint l0 - nf256 m (to_uint l0)) %% 64 /\
         to_uint in_0 = to_uint p0 + nf256 m (to_uint l0)
                        + 64 * ((to_uint l0 - nf256 m (to_uint l0)) %/ 64) /\
         h256 h = foldl compress h0 (parse (ab256 Glob.mem m (to_uint p0) (to_uint l0))) /\
         pending buf (tail 64 (ab256 Glob.mem m (to_uint p0) (to_uint l0))) /\
         to_uint fill = size (ab256 Glob.mem m (to_uint p0) (to_uint l0)) %% 64 /\
         (to_uint inlen <> 0 => to_uint fill = 0) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ sp; if.
  + wp; ecall (K256.compress_blocks_correct (h256 h) in_0 n); auto => /> &hr.
    move=> ht hi hin hh hp hf hz hpl hml hn0.
    rewrite /Jslh.SLH64.protect_64 /Jslh.SLH64.protect_ptr /=.
    have hb := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp modz_cmp).
    pose nf := nf256 m (to_uint l0).
    have hq : to_uint (inlen{hr} `>>` W8.of_int 6) = (to_uint l0 - nf) %/ 64 by rewrite shrc // hi.
    have hq1 : 1 <= (to_uint l0 - nf) %/ 64 by rewrite -hq; apply nonzero.
    have h64 : 64 * ((to_uint l0 - nf) %/ 64) <= to_uint l0 - nf by smt(divz_eq modz_ge0).
    have hoff : to_uint ((inlen{hr} `>>` W8.of_int 6) `<<` W8.of_int 6)
                = 64 * ((to_uint l0 - nf) %/ 64).
    + by rewrite blocksc // hi.
    have hf0 : to_uint fill{hr} = 0 by apply hz; smt().
    pose m1 := m ++ memread Glob.mem{hr} (to_uint p0) nf.
    pose x2 := memread Glob.mem{hr} (to_uint p0 + nf) (64 * ((to_uint l0 - nf) %/ 64)).
    have hm1 : size m1 %% 64 = 0 by rewrite -hf hf0.
    have hx2 : 64 %| size x2 by rewrite /x2 JWordList.size_memread 1:/# dvdz_mulr.
    have [hpb htb] := parse_blocks m1 x2 (tail_nil _ hm1) hx2.
    split; first by rewrite hq hin /nf; smt(). 
    move=> _ [h1 ms1] /= hh1.
    do !split.
    + rewrite W64.to_uintB 1:W64.uleE hoff hi //; smt(divz_eq).
    + rewrite W64.to_uintD_small hoff hin //; smt().
    + by rewrite /ab256 -/nf -/m1 -/x2 hpb foldl_cat -hh hh1 hq hin.
    + by rewrite /ab256 -/nf -/m1 -/x2 htb; exact pending_nil.
    rewrite /ab256 -/nf -/m1 -/x2 size_cat -modzDml hm1 /=.
    by rewrite /x2 JWordList.size_memread 1:/# modzMr.
  auto => /> &hr ht hi hin hh hp hf hz hpl hml hn0.
  pose nf := nf256 m (to_uint l0).
  have hq : (to_uint l0 - nf) %/ 64 = 0.
  + by have := shrc inlen{hr} 6 _; [done | rewrite hn0 hi /=; smt()].
  have hab : ab256 Glob.mem{hr} m (to_uint p0) (to_uint l0)
             = m ++ memread Glob.mem{hr} (to_uint p0) nf.
  + by rewrite /ab256 -/nf hq /= cats0.
  have hlt : 0 <= to_uint l0 - nf < 64.
  + split; first by rewrite -hi; smt(W64.to_uint_cmp).
    by move=> _; smt(divz_eq modz_ge0 modz_cmp).
  have -> : inlen{hr} - W64.zero = inlen{hr} by ring.
  rewrite hab hq /=.
  do !split => //.
  by rewrite hi pmod_small.
ecall (fill64_correct buf fill in_0 inlen); auto => /> &hr ht hi hin hh hp hf hz hpl hml.
have hnf : 0 <= nf256 m (to_uint l0) <= to_uint l0.
+ have := nfill_bounds 64 (size m %% 64) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp modz_cmp).
  by rewrite /nf256 /#.
pose nf := nf256 m (to_uint l0).
pose A := ab256 Glob.mem{hr} m (to_uint p0) (to_uint l0).
have hfA : to_uint fill{hr} < 64 by rewrite hf; smt(modz_cmp).
have hil : to_uint inlen{hr} < 64 by rewrite hi; smt(modz_cmp).
have hsum : to_uint fill{hr} + to_uint inlen{hr} < 64.
+ by case: (to_uint inlen{hr} = 0) => h0'; [smt() | rewrite hz].
have h64 : 64 * ((to_uint l0 - nf) %/ 64) + (to_uint l0 - nf) %% 64 = to_uint l0 - nf.
+ by rewrite mulzC -divz_eq.
split; first by split; [smt() | rewrite hin hi; smt()].
move=> _ _ [b1 ms1] /= hb1.
have hsplit := absorb_split 64 Glob.mem{hr} m (to_uint p0) (to_uint l0) nf _ _; 1,2: smt().
have hst : size (tail 64 A) = to_uint fill{hr} by rewrite size_tail // hf.
have hsx : size (tail 64 A ++ memread Glob.mem{hr} (to_uint in_0{hr}) (to_uint inlen{hr})) < 64.
+ by rewrite size_cat JWordList.size_memread 1:/# hst.
have [hps hts] := parse_short A _ hsx.
split; first by rewrite ht size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
rewrite hsplit -/A -hin -hi.
split; first by rewrite hps.
rewrite hts; apply (pending_fill buf{hr}); 1,2: smt().
+ exact hp.
by rewrite hst.
qed.
lemma sha256_absorb_mem_ll : islossless M._sha256_absorb_mem.
proof.
proc.
seq 9 : true 1%r 1%r 0%r 0%r => //; first by wp; call fill64_ll; auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call K256.compress_ll |]; auto.
seq 5 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call K256.compress_blocks_ll |]; auto.
by wp; call fill64_ll; auto.
qed.

lemma sha256_absorb_mem_total (h0 : W32.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha256_absorb_mem :
           stream256 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\
           size m + to_uint l0 < W64.modulus ==>
           stream256 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha256_absorb_mem_ll (sha256_absorb_mem_correct h0 m p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Initial hash values (sections 5.3.2, 5.3.3)                        *)

lemma IV256_kernel k : 0 <= k < 8 => BArray32.get32 sHA256_IV k = nth W32.zero H0_256 k.
proof. by move=> hk; rewrite BArray32.get32_of_list32 1://; congr; rewrite /H0_256 /=. qed.

lemma IV224_kernel k : 0 <= k < 8 => BArray32.get32 sHA224_IV k = nth W32.zero H0_224 k.
proof. by move=> hk; rewrite BArray32.get32_of_list32 1://; congr; rewrite /H0_224 /=. qed.

lemma h256_eq (h : BArray32.t) (iv : W32.t list) : size iv = 8 =>
  (forall k, 0 <= k < 8 => BArray32.get32 h k = nth W32.zero iv k) => h256 h = iv.
proof.
move=> hs hk; apply (eq_from_nth W32.zero); first by rewrite size_h256 hs.
by move=> k; rewrite size_h256 => hk'; rewrite nth_h256 // hk.
qed.

lemma sha256_init_correct : hoare [M.__sha256_init : true ==> h256 res = H0_256].
proof.
proc; while (0 <= i <= 8 /\ iv = sHA256_IV /\
             forall k, 0 <= k < i => BArray32.get32 h k = nth W32.zero H0_256 k).
+ auto => /> &hr hi0 hi8 hk hlt; split; first smt().
  move=> k hk0 hk1; rewrite BArray32.get_set32E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne]; [rewrite IV256_kernel /# | apply hk => /#].
auto => /> &hr; split; first smt().
move=> hv iv hn hi0 hi8 hk.
by apply h256_eq; [rewrite /H0_256 | move=> k hk'; apply hk => /#].
qed.

lemma sha224_init_correct : hoare [M.__sha224_init : true ==> h256 res = H0_224].
proof.
proc; while (0 <= i <= 8 /\ iv = sHA224_IV /\
             forall k, 0 <= k < i => BArray32.get32 h k = nth W32.zero H0_224 k).
+ auto => /> &hr hi0 hi8 hk hlt; split; first smt().
  move=> k hk0 hk1; rewrite BArray32.get_set32E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne]; [rewrite IV224_kernel /# | apply hk => /#].
auto => /> &hr; split; first smt().
move=> hv iv hn hi0 hi8 hk.
by apply h256_eq; [rewrite /H0_224 | move=> k hk'; apply hk => /#].
qed.

lemma sha256_init_ll : islossless M.__sha256_init.
proof. by proc; while (true) (8 - i); auto => /#. qed.

lemma sha224_init_ll : islossless M.__sha224_init.
proof. by proc; while (true) (8 - i); auto => /#. qed.

lemma sha256_init_total : phoare [M.__sha256_init : true ==> h256 res = H0_256] = 1%r.
proof. by conseq sha256_init_ll sha256_init_correct. qed.

lemma sha224_init_total : phoare [M.__sha224_init : true ==> h256 res = H0_224] = 1%r.
proof. by conseq sha224_init_ll sha224_init_correct. qed.

(* The empty message from any chaining value: a fresh stream. *)
lemma stream256_nil h0 (h : BArray32.t) (buf : BArray64.t) :
  h256 h = h0 => stream256 h0 [] h buf W64.zero.
proof.
move=> hh; rewrite /stream256 /= hh; split; first by rewrite /parse /= JWordList.chunk0.
by rewrite tail_short //; exact pending_nil.
qed.

(* ------------------------------------------------------------------ *)
(* Padding the buffer                                                 *)

lemma pending_set8 (b : BArray64.t) (r : bytes) x :
  size r < 64 => pending b r => pending (BArray64.set8 b (size r) x) (rcons r x).
proof.
move=> hs hp i; rewrite size_rcons => hi; have h0 := size_ge0 r.
rewrite BArray64.get_setE 1:/# nth_rcons.
by case: (i = size r) => [->|hne] /=; [done | rewrite ifT 1:/# hp /#].
qed.

lemma pending_zero (b0 b : BArray64.t) (r : bytes) hi :
  size r <= hi <= 64 => pending b0 r => zero64v b0 (size r) hi b =>
  pending b (r ++ zeros (hi - size r)).
proof.
move=> hs hp hz i; rewrite size_cat size_zeros => hi'; have h0 := size_ge0 r.
rewrite hz 1:/# nth_cat.
case: (i < size r) => hir; first by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# /zeros nth_nseq /#.
qed.

lemma bswap32_bits8 (x : W32.t) k : 0 <= k < 4 =>
  WordSpec.bswap32 x \bits8 k = nth W8.zero (w32_be x) k.
proof.
by move=> hk; rewrite /WordSpec.bswap32 /w32_be W4u8.get_pack4 // size_rev W4u8.size_to_list.
qed.

lemma bswap64_bits8 (x : W64.t) k : 0 <= k < 8 =>
  WordSpec.bswap64 x \bits8 k = nth W8.zero (be_bytes 8 (to_uint x)) k.
proof.
move=> hk; rewrite /WordSpec.bswap64 W8u8.get_pack8 1:size_rev 1:W8u8.size_to_list //.
rewrite nth_rev 1:W8u8.size_to_list // W8u8.size_to_list W8u8.nth_to_list.
rewrite W8u8.bits8_div 1:/# /be_bytes nth_mkseq //=.
by rewrite (_ : 8 * (8 - (k + 1)) = 8 * (8 - 1 - k)) 1:/# exprM.
qed.

(* The last block: 56 pending bytes, then the length field. *)
lemma len_block (buf : BArray64.t) (pre : bytes) (x : W64.t) :
  pending buf pre => size pre = 56 =>
  BArray64.to_list (BArray64.set64d buf 56 (WordSpec.bswap64 x))
  = pre ++ be_bytes 8 (to_uint x).
proof.
move=> hp hs; apply (eq_from_nth W8.zero).
+ by rewrite BArray64.size_to_list size_cat size_be_bytes hs.
move=> i; rewrite BArray64.size_to_list => hi.
rewrite BArray64.get_to_list BArray64.get8_set64dE nth_cat hs.
case: (56 <= i) => h56.
+ have -> : (i < 56) = false by smt().
  by rewrite /= ifT 1:/# bswap64_bits8 /#.
have -> : (i < 56) = true by smt().
by have := hp i _; smt().
qed.

lemma bswap32_ll : islossless M.__bswap32.
proof. by proc; auto. qed.

lemma bswap64_ll : islossless M.__bswap64.
proof. by proc; auto. qed.

lemma size_digest256 (hv : W32.t list) : size hv = 8 => size (flatten (map w32_be hv)) = 32.
proof.
move=> hs; rewrite (size_flatten_ctt 4); last by rewrite size_map hs.
by move=> x /mapP [y [_ ->]]; rewrite /w32_be size_rev W4u8.size_to_list.
qed.

(* ------------------------------------------------------------------ *)
(* Finalize and mem_from, once for every digest size                  *)

(* src/sha256.jinc writes __sha256_finalize and __sha256_mem_from once,
   with the digest size _DSIZE a parameter, and instantiates them for
   SHA-256 (32 bytes) and SHA-224 (28 bytes). The theory below is that
   text with the size abstract: the module F repeats the instance body
   with BArrayD for the output array and dsize for _DSIZE, and the proofs
   are stated over dsize. Each instance is a clone; `sim` then checks that
   the extracted instance and the clone's F are the same program, so a
   wrong copy fails to check instead of proving something else. *)
abstract theory Final256.

op dsize : int.

(* The constraint src/sha256.jinc puts on _DSIZE; each clone proves it. *)
axiom dsize_ok : 4 <= dsize <= 32 /\ dsize %% 4 = 0.

clone import ByteArray as BArrayD with op size <= dsize.

module F = {
    proc finalize (out : BArrayD.t, h : BArray32.t, buf : BArray64.t, total : W64.t, ms : W64.t) :
      BArrayD.t * BArray32.t * BArray64.t * W64.t = {
      var inc:int;
      var fill:W64.t;
      var t:W64.t;
      var two_blocks:bool;
      var hi:W64.t;
      var i:int;
      var x:W32.t;
      fill <- total;
      fill <- (fill `&` (W64.of_int 63));
      t <- (W64.of_int 128);
      buf <- (BArray64.set8 buf (W64.to_uint fill) (truncateu8 t));
      fill <- (fill + (W64.of_int 1));
      two_blocks <- ((W64.of_int 56) \ult fill);
      if (two_blocks) {
        ms <- (update_msf two_blocks ms);
        hi <- (W64.of_int 64);
        (buf, ms) <@ M.__zero64 (buf, fill, hi, ms);
        (h, ms) <@ M._sha256_compress (h, buf, ms);
        out <- (protect_ptr out ms);
        buf <- (protect_ptr buf ms);
        total <- (protect_64 total ms);
        fill <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! two_blocks) ms);
      }
      hi <- (W64.of_int 56);
      (buf, ms) <@ M.__zero64 (buf, fill, hi, ms);
      t <- total;
      t <- (t `<<` (W8.of_int 3));
      t <@ M.__bswap64 (t);
      buf <- (BArray64.set64d buf 56 t);
      (h, ms) <@ M._sha256_compress (h, buf, ms);
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      inc <- (dsize %/ 4);
      i <- 0;
      while ((i < inc)) {
        x <- (BArray32.get32 h i);
        x <@ M.__bswap32 (x);
        out <- (BArrayD.set32 out i x);
        i <- (i + 1);
      }
      return (out, h, buf, ms);
    }
    proc mem_from (out : BArrayD.t, h : BArray32.t, in_0 : W64.t, inlen : W64.t, ms : W64.t) :
      BArrayD.t * W64.t = {
      var buf_s:BArray64.t;
      var buf:BArray64.t;
      var total:W64.t;
      buf <- witness;
      buf_s <- witness;
      buf <- buf_s;
      total <- (W64.of_int 0);
      (h, buf, total, ms) <@ M._sha256_absorb_mem (h, buf, total, in_0, inlen, ms);
      (out, h, buf, ms) <@ finalize (out, h, buf, total, ms);
      return (out, ms);
    }
}.

(* The output: the first dsize / 4 words of h, each big-endian. *)
lemma out_bytes (out : BArrayD.t) (hv : W32.t list) :
  size hv = 8 =>
  (forall i, 0 <= i < dsize %/ 4 => BArrayD.get32 out i = WordSpec.bswap32 (nth W32.zero hv i)) =>
  BArrayD.to_list out = take dsize (flatten (map w32_be hv)).
proof.
move=> hs hk; have hd := dsize_ok.
have hsf : size (flatten (map w32_be hv)) = 32.
+ rewrite (size_flatten_ctt 4); last by rewrite size_map hs.
  by move=> x /mapP [y [_ ->]]; rewrite /w32_be size_rev W4u8.size_to_list.
apply (eq_from_nth W8.zero).
+ by rewrite BArrayD.size_to_list size_take 1:/# hsf /#.
move=> j; rewrite BArrayD.size_to_list => hj.
rewrite BArrayD.get_to_list nth_take 1,2:/# (BitEncoding.BitChunking.nth_flatten _ 4).
+ by rewrite allP => x /mapP [y [_ ->]] /=; rewrite /w32_be size_rev W4u8.size_to_list.
rewrite (nth_map W32.zero) 1:/#.
rewrite -bswap32_bits8 1:/# -(hk (j %/ 4)) 1:/# BArrayD.get32d_byte 1:/#.
by congr; smt(divz_eq).
qed.

lemma finalize_correct (h0 : W32.t list) (m : bytes) :
  hoare [F.finalize :
           stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArrayD.to_list res.`1 = take dsize (flatten (map w32_be (SHA256.hash h0 m)))].
proof.
proc.
seq 6 : (to_uint fill = size m %% 64 + 1 /\ two_blocks = (W64.of_int 56 \ult fill) /\
         to_uint total = size m /\ h256 h = foldl compress h0 (parse m) /\
         pending buf (rcons (tail 64 m) (W8.of_int 128)) /\ size m < 2^61).
+ auto => /> &hr ht hh hp hm.
  have hr := modz_cmp (size m) 64.
  have hf : to_uint (total{hr} `&` W64.of_int 63) = size m %% 64 by rewrite and63 ht.
  have hs : size (tail 64 m) = size m %% 64 by rewrite size_tail.
  rewrite W64.to_uintD_small hf /= 1:/# trunc_const // -hs.
  by apply pending_set8 => //; rewrite hs /#.
seq 1 : (to_uint fill = size (mfin 64 8 m) %% 64 /\ size (mfin 64 8 m) %% 64 <= 56 /\
         to_uint total = size m /\ h256 h = foldl compress h0 (parse (mfin 64 8 m)) /\
         pending buf (tail 64 (mfin 64 8 m)) /\ size m < 2^61).
+ if.
  + wp; ecall (K256.compress_correct (h256 h) buf); wp; ecall (zero64_correct buf fill hi).
    auto => /> &hr hf ht hh hp hm h56.
    have hr := modz_cmp (size m) 64.
    have h56' : 56 < size m %% 64 + 1 by move: h56; rewrite W64.ultE hf.
    split; first smt().
    move=> _ [b1 ms1] /= hb1 [h1 ms2] /= hh1.
    rewrite /protect_ptr.
    pose y := [W8.of_int 128] ++ zeros (63 - size m %% 64).
    have hsr : size (rcons (tail 64 m) (W8.of_int 128)) = size m %% 64 + 1.
    + by rewrite size_rcons size_tail.
    have hpz := pending_zero buf{hr} b1 (rcons (tail 64 m) (W8.of_int 128)) 64 _ hp _.
    + by rewrite hsr /#.
    + by rewrite hsr -hf.
    have hty : rcons (tail 64 m) (W8.of_int 128) ++ zeros (64 - size (rcons (tail 64 m) (W8.of_int 128)))
               = tail 64 m ++ y.
    + by rewrite hsr -cats1 -catA /y /#.
    have hsy : size (tail 64 m ++ y) = 64.
    + by rewrite size_cat size_tail // /y size_cat size_zeros /=; smt().
    have hl := pending_full b1 _ hsy _; first by rewrite -hty.
    have [hc ht0] := parse_close m y hsy.
    have hmf : mfin 64 8 m = m ++ y by rewrite /mfin ifF 1:/# -catA.
    rewrite size_mfin // ifF 1:/# /=.
    by rewrite hh1 hh hl hmf hc foldl_rcons ht0 /= pending_nil.
  auto => /> &hr hf ht hh hp hm h55.
  have hr := modz_cmp (size m) 64.
  have h55' : size m %% 64 <= 55 by move: h55; rewrite W64.ultE hf /#.
  have hmf : mfin 64 8 m = m ++ [W8.of_int 128] by rewrite /mfin ifT 1:/#.
  have [hpm htm] := parse_short m [W8.of_int 128] _.
  + by rewrite size_cat size_tail //=; smt().
  rewrite size_mfin // ifT 1:/# /= hmf hpm hh htm cats1 hp hf /=; smt().
seq 2 : (pending buf (tail 64 (mfin 64 8 m) ++ zeros (56 - size (mfin 64 8 m) %% 64)) /\
         size (mfin 64 8 m) %% 64 <= 56 /\ to_uint total = size m /\
         h256 h = foldl compress h0 (parse (mfin 64 8 m)) /\ size m < 2^61).
+ ecall (zero64_correct buf fill hi); auto => /> &hr hf hs ht hh hp hm.
  split; first smt(W64.to_uint_cmp).
  move=> _ [b1 ms1] /= hb1.
  have hst : size (tail 64 (mfin 64 8 m)) = size (mfin 64 8 m) %% 64 by rewrite size_tail.
  move: hb1; rewrite hf -hst => hb1.
  apply (pending_zero buf{hr}) => //; smt(modz_ge0).
wp; while (0 <= i <= dsize %/ 4 /\ inc = dsize %/ 4 /\ h256 h = SHA256.hash h0 m /\
           forall k, 0 <= k < i => BArrayD.get32 out k = WordSpec.bswap32 (BArray32.get32 h k)).
+ wp; ecall (bswap32_spec x); auto => /> &hr hi0 hi8 hh hk hlt; split; first smt().
  have hd := dsize_ok.
  move=> k hk0 hk1; rewrite BArrayD.get_set32E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne] //; apply hk => /#.
wp; ecall (K256.compress_correct (h256 h) buf); wp; ecall (bswap64_spec t).
auto => /> &hr hp hs ht hh hm [h1 ms1] /= hh1.
have hd := dsize_ok.
pose mf := mfin 64 8 m.
have hsz : size (tail 64 mf ++ zeros (56 - size mf %% 64)) = 56.
+ by rewrite size_cat size_tail // size_zeros; smt(modz_ge0).
have hl := len_block _ _ (total{hr} `<<` W8.of_int 3) hp hsz.
have hlen : to_uint (total{hr} `<<` W8.of_int 3) = 8 * size m.
+ by rewrite shl3E ht pmod_small //; smt(size_ge0).
have hsy : size (tail 64 mf ++ (zeros (56 - size mf %% 64) ++ be_bytes 8 (8 * size m))) = 64.
+ by rewrite catA size_cat hsz size_be_bytes.
have [hc _] := parse_close mf _ hsy.
have hhash : SHA256.hash h0 m = h256 h1.
+ rewrite hh1 hl hlen -catA hh /SHA256.hash pad256E padb_fin //.
  by rewrite -/mf hc foldl_rcons.
split; first by rewrite hhash; smt().
move=> i out1 hn hi0 hi8 _ hk.
have hq8 : dsize %/ 4 <= 8 by smt(divz_eq).
rewrite hhash; apply out_bytes; first exact size_h256.
move=> k [hk0 hk1]; have hk8 : k < 8 by exact (ltr_le_trans (dsize %/ 4)).
have hdi : dsize %/ 4 <= i by rewrite lezNgt.
have hki : k < i by exact (ltr_le_trans (dsize %/ 4)).
by rewrite nth_h256 // hk.
qed.

lemma finalize_ll : islossless F.finalize.
proof.
proc.
seq 6 : (to_uint fill <= 64 /\ two_blocks = (W64.of_int 56 \ult fill)) 1%r 1%r 0%r 0%r => //.
+ by auto => /> &hr; rewrite W64.to_uintD_small and63 /=; smt(modz_cmp W64.to_uint_cmp).
+ seq 1 : (to_uint fill <= 56) 1%r 1%r 0%r 0%r => //.
  + if.
    + by wp; call K256.compress_ll; call zero64_ll; auto => /> &hr h64.
    by auto => /> &hr h64; rewrite W64.ultE /=; smt().
  + wp; while (true) (inc - i).
    + by move=> z; wp; call bswap32_ll; auto => /#.
    wp; call K256.compress_ll; wp; call bswap64_ll; wp; call zero64_ll.
    by auto => /#.
  hoare; if.
  + by wp; call (: true) => //; call (: true) => //; auto.
  by auto => /> &hr h64; rewrite W64.ultE /=; smt().
by hoare; auto => /> &hr; rewrite W64.to_uintD_small and63 /=; smt(modz_cmp W64.to_uint_cmp).
qed.

lemma mem_from_correct (h0 : W32.t list) (p0 l0 : W64.t) :
  hoare [F.mem_from :
           h256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArrayD.to_list res.`1
           = take dsize (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha256_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream256_nil (h256 h{hr}) h{hr} witness<:BArray64.t> _ => //.
rewrite /stream256 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma mem_from_ll : islossless F.mem_from.
proof. by proc; call finalize_ll; call sha256_absorb_mem_ll; auto. qed.

end Final256.

clone Final256 as Fin256 with op dsize <= 32, theory BArrayD <= BArray32
proof dsize_ok by done.

clone Final256 as Fin224 with op dsize <= 28, theory BArrayD <= BArray28
proof dsize_ok by done.

equiv fin256_eq : M._sha256___sha256_finalize ~ Fin256.F.finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

equiv fin224_eq : M._sha224___sha256_finalize ~ Fin224.F.finalize : ={arg} ==> ={res}.
proof. by proc; sim. qed.

equiv mf256_eq : M._sha256____sha256_mem_from ~ Fin256.F.mem_from :
  ={arg, Glob.mem} ==> ={res, Glob.mem}.
proof. by proc; call fin256_eq; call (: ={Glob.mem}); [sim | auto]. qed.

equiv mf224_eq : M._sha224____sha256_mem_from ~ Fin224.F.mem_from :
  ={arg, Glob.mem} ==> ={res, Glob.mem}.
proof. by proc; call fin224_eq; call (: ={Glob.mem}); [sim | auto]. qed.

(* The instances, moved across the equivalences. *)

lemma sha256_finalize_ll : islossless M._sha256___sha256_finalize.
proof. by conseq fin256_eq Fin256.finalize_ll => /#. qed.

lemma sha224_finalize_ll : islossless M._sha224___sha256_finalize.
proof. by conseq fin224_eq Fin224.finalize_ll => /#. qed.

lemma sha256_finalize_correct (h0 : W32.t list) (m : bytes) :
  hoare [M._sha256___sha256_finalize :
           stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w32_be (SHA256.hash h0 m)))].
proof. by conseq fin256_eq (Fin256.finalize_correct h0 m) => /#. qed.

lemma sha256_finalize_total (h0 : W32.t list) (m : bytes) :
  phoare [M._sha256___sha256_finalize :
           stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w32_be (SHA256.hash h0 m)))] = 1%r.
proof. by conseq sha256_finalize_ll (sha256_finalize_correct h0 m). qed.

lemma sha224_finalize_correct (h0 : W32.t list) (m : bytes) :
  hoare [M._sha224___sha256_finalize :
           stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w32_be (SHA256.hash h0 m)))].
proof. by conseq fin224_eq (Fin224.finalize_correct h0 m) => /#. qed.

lemma sha224_finalize_total (h0 : W32.t list) (m : bytes) :
  phoare [M._sha224___sha256_finalize :
           stream256 h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w32_be (SHA256.hash h0 m)))] = 1%r.
proof. by conseq sha224_finalize_ll (sha224_finalize_correct h0 m). qed.

lemma sha256_mem_from_ll : islossless M._sha256____sha256_mem_from.
proof. by conseq mf256_eq Fin256.mem_from_ll => /#. qed.

lemma sha224_mem_from_ll : islossless M._sha224____sha256_mem_from.
proof. by conseq mf224_eq Fin224.mem_from_ll => /#. qed.

lemma sha256_mem_from_correct (h0 : W32.t list) (p0 l0 : W64.t) :
  hoare [M._sha256____sha256_mem_from :
           h256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
conseq mf256_eq (Fin256.mem_from_correct h0 p0 l0) => [&1 h | /#].
by exists Glob.mem{1} arg{1}.
qed.

lemma sha224_mem_from_correct (h0 : W32.t list) (p0 l0 : W64.t) :
  hoare [M._sha224____sha256_mem_from :
           h256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
conseq mf224_eq (Fin224.mem_from_correct h0 p0 l0) => [&1 h | /#].
by exists Glob.mem{1} arg{1}.
qed.

lemma sha256_mem_from_total (h0 : W32.t list) (p0 l0 : W64.t) :
  phoare [M._sha256____sha256_mem_from :
           h256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha256_mem_from_ll (sha256_mem_from_correct h0 p0 l0). qed.

lemma sha224_mem_from_total (h0 : W32.t list) (p0 l0 : W64.t) :
  phoare [M._sha224____sha256_mem_from :
           h256 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w32_be
                (SHA256.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha224_mem_from_ll (sha224_mem_from_correct h0 p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* One-shot SHA-256 and SHA-224 of a memory buffer                    *)

lemma sha256_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha256_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA256.sha256 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha256_mem_from_correct H0_256 p0 l0); call sha256_init_correct.
auto => /> &hr hpl hl h1 hh1 r ->.
by rewrite take_oversize // size_digest256 // HMACSpec.size_hash256.
qed.

lemma sha224_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha224_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA256.sha224 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha224_mem_from_correct H0_224 p0 l0); call sha224_init_correct.
by auto => /> &hr hpl hl h1 hh1 r ->.
qed.

lemma sha256_mem_ll : islossless M._sha256_mem.
proof. by proc; call sha256_mem_from_ll; call sha256_init_ll; auto. qed.

lemma sha224_mem_ll : islossless M._sha224_mem.
proof. by proc; call sha224_mem_from_ll; call sha224_init_ll; auto. qed.

lemma sha256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha256_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA256.sha256 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha256_mem_ll (sha256_mem_correct p0 l0). qed.

lemma sha224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha224_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA256.sha224 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha224_mem_ll (sha224_mem_correct p0 l0). qed.
