(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Stream.ec
 * ================
 *
 * Functional correctness of the streaming SHA-384, SHA-512, SHA-512/224
 * and SHA-512/256 of src/sha512.jinc against FIPS 180-4 sections 5.1.2,
 * 5.2.2, 5.3.4 to 5.3.6 and 6.4 to 6.7 (spec/FIPS180_SHA2.ec), over the
 * unit's SHA-512 kernel as K512 states it.
 *
 * The proofs follow SHA256_Stream.ec with 128-byte blocks, 64-bit words
 * and a 16-byte length field. After a message m has been absorbed from a
 * starting chaining value h0, the state (h, buf, total) satisfies
 * stream512 h0 m: total = |m|, h is compress folded from h0 over the
 * complete blocks of m, and the |m| mod 128 bytes after them are the first
 * cells of buf.
 *
 * Theorems (total correctness, phoare ... = 1%r):
 *     sha512_init_total, sha384_init_total, sha512_224_init_total,
 *     sha512_256_init_total
 *                          the initial hash values of section 5.3.4 to
 *                          5.3.6
 *     sha512_absorb_mem_total
 *                          absorbing l bytes from memory at p extends m by
 *                          those bytes
 *     sha512_finalize_total, sha384_..., sha512_224_..., sha512_256_...
 *                          the digest of m from h0, truncated to the
 *                          digest size
 *     sha512_mem_from_total and its three truncations
 *                          the digest of l bytes at p from h0
 *     sha512_mem_total, sha384_mem_total, sha512_224_mem_total,
 *     sha512_256_mem_total
 *                          the one-shot hashes of l bytes at p
 *
 * Domain: p + l < 2^64 and messages below 2^61 bytes.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray28 BArray32 BArray48 BArray64 BArray128.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill SHA256_Stream.
require JWordList K512 HMACSpec.
import SHA512.

(* ------------------------------------------------------------------ *)
(* The stream state                                                   *)

(* The first size r cells of buf are r. *)
op pend512 (buf : BArray128.t) (r : bytes) =
  forall i, 0 <= i < size r => BArray128.get8 buf i = nth W8.zero r i.

op stream512 (h0 : W64.t list) (m : bytes) (h : BArray64.t) (buf : BArray128.t) (total : W64.t) =
     to_uint total = size m
  /\ h512 h = foldl compress h0 (parse m)
  /\ pend512 buf (tail 128 m).

lemma pend512_nil (buf : BArray128.t) : pend512 buf [].
proof. by move=> i /= /#. qed.

(* Filling cells [size t, size t + k) from memory extends the pend512
   bytes t by the k bytes read. *)
lemma pend512_fill (b0 b : BArray128.t) mem (t : bytes) p k :
  0 <= k => size t + k <= 128 => pend512 b0 t => fill128v b0 mem (size t) p (size t + k) b =>
  pend512 b (t ++ memread mem p k).
proof.
move=> hk hs hp hf i; rewrite size_cat JWordList.size_memread // => hi.
rewrite hf 1:/# nth_cat.
case: (i < size t) => hit.
+ by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# JWordList.nth_memread /#.
qed.

(* A pend512 block of 128 bytes is the whole buffer. *)
lemma pend512_full (b : BArray128.t) (r : bytes) :
  size r = 128 => pend512 b r => BArray128.to_list b = r.
proof.
move=> hs hp; apply (eq_from_nth W8.zero); first by rewrite BArray128.size_to_list hs.
by move=> i; rewrite BArray128.size_to_list => hi; rewrite BArray128.get_to_list hp /#.
qed.

(* ------------------------------------------------------------------ *)
(* The three ways an absorb extends m (section 5.2.1)                 *)

lemma parse512_close (m y : bytes) : size (tail 128 m ++ y) = 128 =>
  parse (m ++ y) = rcons (parse m) (map be64 (chunk 8 (tail 128 m ++ y)))
  /\ tail 128 (m ++ y) = [].
proof.
move=> hs; have [hc ht] := close_block 128 m y _ hs => //.
by rewrite /parse hc map_rcons.
qed.

lemma parse512_short (m y : bytes) : size (tail 128 m ++ y) < 128 =>
  parse (m ++ y) = parse m /\ tail 128 (m ++ y) = tail 128 m ++ y.
proof. by move=> hs; have [hc ht] := short_ext 128 m y _ hs => //; rewrite /parse hc. qed.

lemma parse512_blocks (m x : bytes) : tail 128 m = [] => 128 %| size x =>
  parse (m ++ x) = parse m ++ parse x /\ tail 128 (m ++ x) = [].
proof.
by move=> hm hx; have [hc ht] := blocks_ext 128 m x _ hm hx => //; rewrite /parse hc map_cat.
qed.

lemma tail512_nil (m : bytes) : size m %% 128 = 0 => tail 128 m = [].
proof. by move=> h; apply size_eq0; rewrite size_tail. qed.

(* ------------------------------------------------------------------ *)
(* Absorbing bytes from memory                                        *)

(* The bytes the absorb takes into the pend512 block (nfill). *)
lemma fill_count512 (f l : W64.t) : to_uint f < 128 =>
  to_uint (if f = W64.zero then f
           else if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f)
  = nfill 128 (to_uint f) (to_uint l).
proof.
move=> hf; rewrite /nfill; case: (f = W64.zero) => [->|hz] //=.
have hf0 : to_uint f <> 0 by move: hz; apply contra => h; apply W64.to_uint_eq.
have hs : to_uint (W64.of_int 128 - f) = 128 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
rewrite hf0 /=; case: (l \ult W64.of_int 128 - f); rewrite W64.ultE hs /#.
qed.

op nf512 (m : bytes) (l : int) : int = nfill 128 (size m %% 128) l.

(* m after the first two phases: the pend512 block completed, then the
   whole blocks that follow. *)
op ab512 mem (m : bytes) p l : bytes =
  (m ++ memread mem p (nf512 m l))
  ++ memread mem (p + nf512 m l) (128 * ((l - nf512 m l) %/ 128)).

lemma sha512_absorb_mem_correct (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  hoare [M._sha512_absorb_mem :
           stream512 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\
           size m + to_uint l0 < W64.modulus ==>
           stream512 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0))
             res.`1 res.`2 res.`3].
proof.
proc.
seq 8 : (to_uint fill = size m %% 128 /\ to_uint n = nf512 m (to_uint l0) /\
         to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf512 m (to_uint l0) /\ in_0 = p0 /\
         h512 h = foldl compress h0 (parse m) /\ pend512 buf (tail 128 m) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ auto => /> &hr ht hh hp hpl hml.
  have hr := modz_cmp (size m) 128.
  have hf : to_uint (total{hr} `&` W64.of_int 127) = size m %% 128 by rewrite and127 ht.
  have hn := fill_count512 (total{hr} `&` W64.of_int 127) l0 _; 1: by rewrite hf /#.
  have hb := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  rewrite /nf512 -hf -hn W64.to_uintD_small 1:/# ht /=.
  by rewrite W64.to_uintB // W64.uleE hn hf; smt().
seq 1 : (to_uint fill = size m %% 128 /\ to_uint n = nf512 m (to_uint l0) /\
         to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf512 m (to_uint l0) /\ in_0 = p0 /\
         h512 h = foldl compress h0 (parse m) /\
         pend512 buf (tail 128 m ++ memread Glob.mem (to_uint p0) (nf512 m (to_uint l0))) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ ecall (fill128_correct buf fill in_0 n); auto => /> &hr hf hn ht hi hh hp hpl hml.
  have hr := modz_cmp (size m) 128.
  have hb := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  have hs : size (tail 128 m) = size m %% 128 by rewrite size_tail.
  split; first by rewrite hf hn /nf512; smt().
  move=> _ _ [b1 ms1] /= hb1; apply (pend512_fill buf{hr}); 1,2: smt().
  + exact hp.
  by rewrite hs -hf -hn.
seq 4 : (to_uint total = size m + to_uint l0 /\
         to_uint inlen = to_uint l0 - nf512 m (to_uint l0) /\
         to_uint in_0 = to_uint p0 + nf512 m (to_uint l0) /\
         h512 h = foldl compress h0 (parse (m ++ memread Glob.mem (to_uint p0) (nf512 m (to_uint l0)))) /\
         pend512 buf (tail 128 (m ++ memread Glob.mem (to_uint p0) (nf512 m (to_uint l0)))) /\
         to_uint fill = size (m ++ memread Glob.mem (to_uint p0) (nf512 m (to_uint l0))) %% 128 /\
         (to_uint inlen <> 0 => to_uint fill = 0) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ sp; if.
  + wp; ecall (K512.compress_correct (h512 h) buf); auto => /> &hr.
    move=> f0 hf hn ht hi hh hp hpl hml hfull [h1 ms1] /= hh1.
    rewrite /Jslh.SLH64.protect_64 /Jslh.SLH64.protect_ptr /=.
    have hr := modz_cmp (size m) 128.
    have hb := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
    have hsum : size m %% 128 + nf512 m (to_uint l0) = 128.
    + have : to_uint (f0 + n{hr}) = 128 by rewrite hfull.
      by rewrite W64.to_uintD_small hf hn /nf512; smt().
    pose x := memread Glob.mem{hr} (to_uint p0) (nf512 m (to_uint l0)).
    have hsx : size (tail 128 m ++ x) = 128.
    + by rewrite size_cat size_tail // JWordList.size_memread /nf512; smt().
    have [hpc htc] := parse512_close m x hsx.
    do !split.
    + by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
    + by rewrite hpc foldl_rcons hh1 hh (pend512_full buf{hr} _ hsx hp).
    + by rewrite htc; exact pend512_nil.
    by rewrite size_cat JWordList.size_memread 1:/nf512 1:/# -modzDml hsum.
  auto => /> &hr f0 hf hn ht hi hh hp hpl hml hfull.
  have hr := modz_cmp (size m) 128.
  have hb := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp).
  have hfn : to_uint (f0 + n{hr}) = size m %% 128 + nf512 m (to_uint l0).
  + by rewrite W64.to_uintD_small hf hn /nf512; smt().
  have hlt : size m %% 128 + nf512 m (to_uint l0) < 128.
  + have : to_uint (f0 + n{hr}) <> 128.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    by rewrite /nf512; smt().
  pose x := memread Glob.mem{hr} (to_uint p0) (nf512 m (to_uint l0)).
  have hsx : size (tail 128 m ++ x) < 128.
  + by rewrite size_cat size_tail // JWordList.size_memread /nf512; smt().
  have [hps hts] := parse512_short m x hsx.
  do !split.
  + by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
  + by rewrite hps.
  + by rewrite hts.
  + rewrite hfn size_cat JWordList.size_memread 1:/nf512 1:/# -modzDml.
    by rewrite (pmod_small (size m %% 128 + nf512 m (to_uint l0))) 1:/#.
  move=> hin; rewrite hfn; move: hin hlt; rewrite hi /nf512 /nfill.
  by case: (size m %% 128 = 0) => hz /=; smt().
seq 7 : (to_uint total = size m + to_uint l0 /\
         to_uint inlen = (to_uint l0 - nf512 m (to_uint l0)) %% 128 /\
         to_uint in_0 = to_uint p0 + nf512 m (to_uint l0)
                        + 128 * ((to_uint l0 - nf512 m (to_uint l0)) %/ 128) /\
         h512 h = foldl compress h0 (parse (ab512 Glob.mem m (to_uint p0) (to_uint l0))) /\
         pend512 buf (tail 128 (ab512 Glob.mem m (to_uint p0) (to_uint l0))) /\
         to_uint fill = size (ab512 Glob.mem m (to_uint p0) (to_uint l0)) %% 128 /\
         (to_uint inlen <> 0 => to_uint fill = 0) /\
         to_uint p0 + to_uint l0 < W64.modulus /\ size m + to_uint l0 < W64.modulus).
+ sp; if.
  + wp; ecall (K512.compress_blocks_correct (h512 h) in_0 n); auto => /> &hr.
    move=> ht hi hin hh hp hf hz hpl hml hn0.
    rewrite /Jslh.SLH64.protect_64 /Jslh.SLH64.protect_ptr /=.
    have hb := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp modz_cmp).
    pose nf := nf512 m (to_uint l0).
    have hq : to_uint (inlen{hr} `>>` W8.of_int 7) = (to_uint l0 - nf) %/ 128 by rewrite shrc // hi.
    have hq1 : 1 <= (to_uint l0 - nf) %/ 128 by rewrite -hq; apply nonzero.
    have h64 : 128 * ((to_uint l0 - nf) %/ 128) <= to_uint l0 - nf by smt(divz_eq modz_ge0).
    have hoff : to_uint ((inlen{hr} `>>` W8.of_int 7) `<<` W8.of_int 7)
                = 128 * ((to_uint l0 - nf) %/ 128).
    + by rewrite blocksc // hi.
    have hf0 : to_uint fill{hr} = 0 by apply hz; smt().
    pose m1 := m ++ memread Glob.mem{hr} (to_uint p0) nf.
    pose x2 := memread Glob.mem{hr} (to_uint p0 + nf) (128 * ((to_uint l0 - nf) %/ 128)).
    have hm1 : size m1 %% 128 = 0 by rewrite -hf hf0.
    have hx2 : 128 %| size x2 by rewrite /x2 JWordList.size_memread 1:/# dvdz_mulr.
    have [hpb htb] := parse512_blocks m1 x2 (tail512_nil _ hm1) hx2.
    split; first by rewrite hq hin /nf; smt(). 
    move=> _ [h1 ms1] /= hh1.
    do !split.
    + rewrite W64.to_uintB 1:W64.uleE hoff hi //; smt(divz_eq).
    + rewrite W64.to_uintD_small hoff hin //; smt().
    + by rewrite /ab512 -/nf -/m1 -/x2 hpb foldl_cat -hh hh1 hq hin.
    + by rewrite /ab512 -/nf -/m1 -/x2 htb; exact pend512_nil.
    rewrite /ab512 -/nf -/m1 -/x2 size_cat -modzDml hm1 /=.
    by rewrite /x2 JWordList.size_memread 1:/# modzMr.
  auto => /> &hr ht hi hin hh hp hf hz hpl hml hn0.
  pose nf := nf512 m (to_uint l0).
  have hq : (to_uint l0 - nf) %/ 128 = 0.
  + by have := shrc inlen{hr} 7 _; [done | rewrite hn0 hi /=; smt()].
  have hab : ab512 Glob.mem{hr} m (to_uint p0) (to_uint l0)
             = m ++ memread Glob.mem{hr} (to_uint p0) nf.
  + by rewrite /ab512 -/nf hq /= cats0.
  have hlt : 0 <= to_uint l0 - nf < 128.
  + split; first by rewrite -hi; smt(W64.to_uint_cmp).
    by move=> _; smt(divz_eq modz_ge0 modz_cmp).
  have -> : inlen{hr} - W64.zero = inlen{hr} by ring.
  rewrite hab hq /=.
  do !split => //.
  by rewrite hi pmod_small.
ecall (fill128_correct buf fill in_0 inlen); auto => /> &hr ht hi hin hh hp hf hz hpl hml.
have hnf : 0 <= nf512 m (to_uint l0) <= to_uint l0.
+ have := nfill_bounds 128 (size m %% 128) (to_uint l0) _ _; 1,2: smt(W64.to_uint_cmp modz_cmp).
  by rewrite /nf512 /#.
pose nf := nf512 m (to_uint l0).
pose A := ab512 Glob.mem{hr} m (to_uint p0) (to_uint l0).
have hfA : to_uint fill{hr} < 128 by rewrite hf; smt(modz_cmp).
have hil : to_uint inlen{hr} < 128 by rewrite hi; smt(modz_cmp).
have hsum : to_uint fill{hr} + to_uint inlen{hr} < 128.
+ by case: (to_uint inlen{hr} = 0) => h0'; [smt() | rewrite hz].
have h64 : 128 * ((to_uint l0 - nf) %/ 128) + (to_uint l0 - nf) %% 128 = to_uint l0 - nf.
+ by rewrite mulzC -divz_eq.
split; first by split; [smt() | rewrite hin hi; smt()].
move=> _ _ [b1 ms1] /= hb1.
have hsplit := absorb_split 128 Glob.mem{hr} m (to_uint p0) (to_uint l0) nf _ _; 1,2: smt().
have hst : size (tail 128 A) = to_uint fill{hr} by rewrite size_tail // hf.
have hsx : size (tail 128 A ++ memread Glob.mem{hr} (to_uint in_0{hr}) (to_uint inlen{hr})) < 128.
+ by rewrite size_cat JWordList.size_memread 1:/# hst.
have [hps hts] := parse512_short A _ hsx.
split; first by rewrite ht size_cat JWordList.size_memread //; smt(W64.to_uint_cmp).
rewrite hsplit -/A -hin -hi.
split; first by rewrite hps.
rewrite hts; apply (pend512_fill buf{hr}); 1,2: smt().
+ exact hp.
by rewrite hst.
qed.
lemma sha512_absorb_mem_ll : islossless M._sha512_absorb_mem.
proof.
proc.
seq 9 : true 1%r 1%r 0%r 0%r => //; first by wp; call fill128_ll; auto.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call K512.compress_ll |]; auto.
seq 5 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call K512.compress_blocks_ll |]; auto.
by wp; call fill128_ll; auto.
qed.

lemma sha512_absorb_mem_total (h0 : W64.t list) (m : bytes) (p0 l0 : W64.t) :
  phoare [M._sha512_absorb_mem :
           stream512 h0 m h buf total /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\
           size m + to_uint l0 < W64.modulus ==>
           stream512 h0 (m ++ memread Glob.mem (to_uint p0) (to_uint l0))
             res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha512_absorb_mem_ll (sha512_absorb_mem_correct h0 m p0 l0). qed.
(* ------------------------------------------------------------------ *)
(* Initial hash values (sections 5.3.4 to 5.3.6)                      *)

lemma h512_eq (h : BArray64.t) (iv : W64.t list) : size iv = 8 =>
  (forall k, 0 <= k < 8 => BArray64.get64 h k = nth W64.zero iv k) => h512 h = iv.
proof.
move=> hs hk; apply (eq_from_nth W64.zero); first by rewrite size_h512 hs.
by move=> k; rewrite size_h512 => hk'; rewrite nth_h512 // hk.
qed.

lemma load_iv_correct (iv0 : BArray64.t) :
  hoare [M.__sha512_load_iv : iv = iv0 ==> h512 res = h512 iv0].
proof.
proc; while (0 <= i <= 8 /\ iv = iv0 /\
             forall k, 0 <= k < i => BArray64.get64 h k = BArray64.get64 iv0 k).
+ auto => /> &hr hi0 hi8 hk hlt; split; first smt().
  move=> k hk0 hk1; rewrite BArray64.get_set64E 1,2:/#.
  by case: (i{hr} = k) => [<-|ne] //; apply hk => /#.
auto => /> &hr; split; first smt().
move=> h1 i1 hn hi0 hi8 hk.
by apply h512_eq; [exact size_h512 | move=> k hk'; rewrite nth_h512 // hk /#].
qed.

lemma load_iv_ll : islossless M.__sha512_load_iv.
proof. by proc; while (true) (8 - i); auto => /#. qed.

lemma IV512_kernel : h512 sHA512_IV = H0_512.
proof.
apply h512_eq; first by rewrite /H0_512.
by move=> k hk; rewrite BArray64.get64_of_list64 1://; congr; rewrite /H0_512 /=.
qed.

lemma IV384_kernel : h512 sHA384_IV = H0_384.
proof.
apply h512_eq; first by rewrite /H0_384.
by move=> k hk; rewrite BArray64.get64_of_list64 1://; congr; rewrite /H0_384 /=.
qed.

lemma IV512_224_kernel : h512 sHA512_224_IV = H0_512_224.
proof.
apply h512_eq; first by rewrite /H0_512_224.
by move=> k hk; rewrite BArray64.get64_of_list64 1://; congr; rewrite /H0_512_224 /=.
qed.

lemma IV512_256_kernel : h512 sHA512_256_IV = H0_512_256.
proof.
apply h512_eq; first by rewrite /H0_512_256.
by move=> k hk; rewrite BArray64.get64_of_list64 1://; congr; rewrite /H0_512_256 /=.
qed.

lemma sha512_init_correct : hoare [M.__sha512_init : true ==> h512 res = H0_512].
proof. by proc; ecall (load_iv_correct sHA512_IV); auto => /> r ->; exact IV512_kernel. qed.

lemma sha512_init_ll : islossless M.__sha512_init.
proof. by proc; call load_iv_ll. qed.

lemma sha512_init_total : phoare [M.__sha512_init : true ==> h512 res = H0_512] = 1%r.
proof. by conseq sha512_init_ll sha512_init_correct. qed.

lemma sha384_init_correct : hoare [M.__sha384_init : true ==> h512 res = H0_384].
proof. by proc; ecall (load_iv_correct sHA384_IV); auto => /> r ->; exact IV384_kernel. qed.

lemma sha384_init_ll : islossless M.__sha384_init.
proof. by proc; call load_iv_ll. qed.

lemma sha384_init_total : phoare [M.__sha384_init : true ==> h512 res = H0_384] = 1%r.
proof. by conseq sha384_init_ll sha384_init_correct. qed.

lemma sha512_224_init_correct : hoare [M.__sha512_224_init : true ==> h512 res = H0_512_224].
proof. by proc; ecall (load_iv_correct sHA512_224_IV); auto => /> r ->; exact IV512_224_kernel. qed.

lemma sha512_224_init_ll : islossless M.__sha512_224_init.
proof. by proc; call load_iv_ll. qed.

lemma sha512_224_init_total : phoare [M.__sha512_224_init : true ==> h512 res = H0_512_224] = 1%r.
proof. by conseq sha512_224_init_ll sha512_224_init_correct. qed.

lemma sha512_256_init_correct : hoare [M.__sha512_256_init : true ==> h512 res = H0_512_256].
proof. by proc; ecall (load_iv_correct sHA512_256_IV); auto => /> r ->; exact IV512_256_kernel. qed.

lemma sha512_256_init_ll : islossless M.__sha512_256_init.
proof. by proc; call load_iv_ll. qed.

lemma sha512_256_init_total : phoare [M.__sha512_256_init : true ==> h512 res = H0_512_256] = 1%r.
proof. by conseq sha512_256_init_ll sha512_256_init_correct. qed.

(* The empty message from any chaining value: a fresh stream. *)
lemma stream512_nil h0 (h : BArray64.t) (buf : BArray128.t) :
  h512 h = h0 => stream512 h0 [] h buf W64.zero.
proof.
move=> hh; rewrite /stream512 /= hh; split; first by rewrite /parse /= JWordList.chunk0.
by rewrite tail_short //; exact pend512_nil.
qed.

(* ------------------------------------------------------------------ *)
(* Padding the buffer                                                 *)

lemma pend512_set8 (b : BArray128.t) (r : bytes) x :
  size r < 128 => pend512 b r => pend512 (BArray128.set8 b (size r) x) (rcons r x).
proof.
move=> hs hp i; rewrite size_rcons => hi; have h0 := size_ge0 r.
rewrite BArray128.get_setE 1:/# nth_rcons.
by case: (i = size r) => [->|hne] /=; [done | rewrite ifT 1:/# hp /#].
qed.

lemma pend512_zero (b0 b : BArray128.t) (r : bytes) hi :
  size r <= hi <= 128 => pend512 b0 r => zero128v b0 (size r) hi b =>
  pend512 b (r ++ zeros (hi - size r)).
proof.
move=> hs hp hz i; rewrite size_cat size_zeros => hi'; have h0 := size_ge0 r.
rewrite hz 1:/# nth_cat.
case: (i < size r) => hir; first by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# /zeros nth_nseq /#.
qed.

(* The last block: 112 pending bytes, then the 16-byte length field as
   two big-endian words. *)
lemma len_block512 (buf : BArray128.t) (pre : bytes) (a b : W64.t) :
  pend512 buf pre => size pre = 112 =>
  BArray128.to_list
    (BArray128.set64d (BArray128.set64d buf 112 (WordSpec.bswap64 a)) 120 (WordSpec.bswap64 b))
  = pre ++ be_bytes 8 (to_uint a) ++ be_bytes 8 (to_uint b).
proof.
move=> hp hs; apply (eq_from_nth W8.zero).
+ by rewrite BArray128.size_to_list !size_cat !size_be_bytes hs.
move=> i; rewrite BArray128.size_to_list => hi.
have hs2 : size (pre ++ be_bytes 8 (to_uint a)) = 120 by rewrite size_cat size_be_bytes hs.
rewrite BArray128.get_to_list !BArray128.get8_set64dE !nth_cat hs2 hs.
case: (120 <= i) => h120.
+ by rewrite ifT 1:/# (ifF (i < 120)) 1:/# bswap64_bits8 /#.
rewrite ifF 1:/# (ifT (i < 120)) 1:/#.
case: (112 <= i) => h112.
+ by rewrite ifT 1:/# (ifF (i < 112)) 1:/# bswap64_bits8 /#.
by rewrite ifF 1:/# (ifT (i < 112)) 1:/#; apply hp; smt().
qed.

lemma size_digest512 (hv : W64.t list) : size hv = 8 => size (flatten (map w64_be hv)) = 64.
proof.
move=> hs; rewrite (size_flatten_ctt 8); last by rewrite size_map hs.
by move=> x /mapP [y [_ ->]]; rewrite /w64_be size_rev W8u8.size_to_list.
qed.

lemma bswap64_be (x : W64.t) k : 0 <= k < 8 =>
  WordSpec.bswap64 x \bits8 k = nth W8.zero (w64_be x) k.
proof.
by move=> hk; rewrite /WordSpec.bswap64 /w64_be W8u8.get_pack8 // size_rev W8u8.size_to_list.
qed.

(* The high half of a word, as SHA-512/224 writes its last four bytes. *)
lemma hi32_bits (x : W64.t) j : 0 <= j < 32 =>
  (truncateu32 (x `>>` W8.of_int 32)).[j] = x.[j + 32].
proof.
move=> hj; rewrite /truncateu32 W32.of_intwE /int_bit hj /= shrc //.
rewrite (W64.get_to_uint x) (_ : 0 <= j + 32 < 64) 1:/# /=.
have hx := W64.to_uint_cmp x.
have hlt : to_uint x %/ 4294967296 < 4294967296.
+ by rewrite ltz_divLR //; move: hx; rewrite w64_modulus /=.
rewrite (pmod_small (to_uint x %/ 4294967296)); first by split; [apply divz_ge0 | done]; smt().
have -> : 2 ^ (j + 32) = 4294967296 * 2 ^ j by rewrite exprD_nneg 1:/# // mulzC.
by rewrite -divz_mul.
qed.

lemma hi32_be (x : W64.t) k : 0 <= k < 4 =>
  WordSpec.bswap32 (truncateu32 (x `>>` W8.of_int 32)) \bits8 k = nth W8.zero (w64_be x) k.
proof.
move=> hk; rewrite bswap32_bits8 // /w32_be /w64_be.
rewrite !nth_rev ?W4u8.size_to_list ?W8u8.size_to_list 1,2:/#.
rewrite W4u8.nth_to_list W8u8.nth_to_list.
apply W8.wordP => j hj; rewrite !W4u8.bits8iE 1:// !W8u8.bits8iE 1://.
by rewrite hi32_bits 1:/#; congr; ring.
qed.

(* The digest bytes of a SHA-512 chaining value, word by word. *)
lemma nth_flat512 (h : BArray64.t) b : 0 <= b < 64 =>
  nth W8.zero (flatten (map w64_be (h512 h))) b
  = nth W8.zero (w64_be (BArray64.get64 h (b %/ 8))) (b %% 8).
proof.
move=> hb; rewrite (BitEncoding.BitChunking.nth_flatten _ 8).
+ by rewrite allP => x /mapP [y [_ ->]] /=; rewrite /w64_be size_rev W8u8.size_to_list.
by rewrite (nth_map W64.zero) 1:size_h512 1:/# nth_h512 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* Finalize and mem_from, once for every digest size                  *)

(* As for SHA-256 (SHA256_Stream.ec): src/sha512.jinc writes
   __sha512_finalize and __sha512_mem_from once over _DSIZE and
   instantiates them for SHA-512 (64 bytes), SHA-384 (48), SHA-512/256
   (32) and SHA-512/224 (28). The output is written as dsize / 8 whole
   words, then, when dsize is not a multiple of 8, the four high bytes of
   the next word. *)
abstract theory Final512.

op dsize : int.

(* The constraint src/sha512.jinc puts on _DSIZE; each clone proves it. *)
axiom dsize_ok : 4 <= dsize <= 64 /\ dsize %% 4 = 0.

clone import ByteArray as BArrayD with op size <= dsize.

module F = {
  proc finalize (out:BArrayD.t, h:BArray64.t, buf:BArray128.t, total:W64.t, ms:W64.t) :
    BArrayD.t * BArray64.t * BArray128.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    t <- (W64.of_int 128);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      (buf, ms) <@ M.__zero128 (buf, fill, hi, ms);
      (h, ms) <@ M._sha512_compress (h, buf, ms);
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    (buf, ms) <@ M.__zero128 (buf, fill, hi, ms);
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ M.__bswap64 (t);
    buf <- (BArray128.set64d buf 112 t);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ M.__bswap64 (t);
    buf <- (BArray128.set64d buf 120 t);
    (h, ms) <@ M._sha512_compress (h, buf, ms);
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (dsize %/ 8);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <@ M.__bswap64 (x);
      out <- (BArrayD.set64 out i x);
      i <- (i + 1);
    }
    inc <- ((dsize + 7) %/ 8);
    i <- (dsize %/ 8);
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <- (x `>>` (W8.of_int 32));
      y <- (truncateu32 x);
      y <@ M.__bswap32 (y);
      out <- (BArrayD.set32 out (2 * i) y);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc mem_from (out:BArrayD.t, h:BArray64.t, in_0:W64.t, inlen:W64.t, ms:W64.t) :
    BArrayD.t * W64.t = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (h, buf, total, ms) <@ M._sha512_absorb_mem (h, buf, total, in_0, inlen, ms);
    (out, h, buf, ms) <@ finalize (out, h, buf, total, ms);
    return (out, ms);
  }
}.

(* Bytes written by the two output loops when the second stops at i. *)
lemma cov_end :
  8 * (dsize %/ 8) + 4 * ((dsize + 7) %/ 8 - dsize %/ 8) = dsize.
proof.
have [h1 h2] := dsize_ok.
have hd := divz_eq dsize 8.
have hr : dsize %% 8 = 0 \/ dsize %% 8 = 4 by smt(modz_dvd modz_cmp).
have -> : (dsize + 7) %/ 8 = dsize %/ 8 + (dsize %% 8 + 7) %/ 8.
+ by rewrite {1}hd -addzA divzMDl.
by case: hr => hr; rewrite hr /=; smt().
qed.

lemma cov_step i : dsize %/ 8 <= i < (dsize + 7) %/ 8 =>
  i = dsize %/ 8 /\ 8 * i + 4 = dsize.
proof.
move=> hi; have := cov_end.
have [h1 h2] := dsize_ok.
have hd := divz_eq dsize 8.
have hr : dsize %% 8 = 0 \/ dsize %% 8 = 4 by smt(modz_dvd modz_cmp).
have he : (dsize + 7) %/ 8 = dsize %/ 8 + (dsize %% 8 + 7) %/ 8.
+ by rewrite {1}hd -addzA divzMDl.
by case: hr => hr; move: hi; rewrite he hr /=; smt().
qed.

lemma finalize_correct (h0 : W64.t list) (m : bytes) :
  hoare [F.finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArrayD.to_list res.`1 = take dsize (flatten (map w64_be (SHA512.hash h0 m)))].
proof.
proc.
seq 6 : (to_uint fill = size m %% 128 + 1 /\ two_blocks = (W64.of_int 112 \ult fill) /\
         to_uint total = size m /\ h512 h = foldl compress h0 (parse m) /\
         pend512 buf (rcons (tail 128 m) (W8.of_int 128)) /\ size m < 2^61).
+ auto => /> &hr ht hh hp hm.
  have hr := modz_cmp (size m) 128.
  have hf : to_uint (total{hr} `&` W64.of_int 127) = size m %% 128 by rewrite and127 ht.
  have hs : size (tail 128 m) = size m %% 128 by rewrite size_tail.
  rewrite W64.to_uintD_small hf /= 1:/# trunc_const // -hs.
  by apply pend512_set8 => //; rewrite hs /#.
seq 1 : (to_uint fill = size (mfin 128 16 m) %% 128 /\ size (mfin 128 16 m) %% 128 <= 112 /\
         to_uint total = size m /\ h512 h = foldl compress h0 (parse (mfin 128 16 m)) /\
         pend512 buf (tail 128 (mfin 128 16 m)) /\ size m < 2^61).
+ if.
  + wp; ecall (K512.compress_correct (h512 h) buf); wp; ecall (zero128_correct buf fill hi).
    auto => /> &hr hf ht hh hp hm h112.
    have hr := modz_cmp (size m) 128.
    have h112' : 112 < size m %% 128 + 1 by move: h112; rewrite W64.ultE hf.
    split; first smt().
    move=> _ [b1 ms1] /= hb1 [h1 ms2] /= hh1.
    rewrite /protect_ptr.
    pose y := [W8.of_int 128] ++ zeros (127 - size m %% 128).
    have hsr : size (rcons (tail 128 m) (W8.of_int 128)) = size m %% 128 + 1.
    + by rewrite size_rcons size_tail.
    have hpz := pend512_zero buf{hr} b1 (rcons (tail 128 m) (W8.of_int 128)) 128 _ hp _.
    + by rewrite hsr /#.
    + by rewrite hsr -hf.
    have hty : rcons (tail 128 m) (W8.of_int 128) ++ zeros (128 - size (rcons (tail 128 m) (W8.of_int 128)))
               = tail 128 m ++ y.
    + by rewrite hsr -cats1 -catA /y /#.
    have hsy : size (tail 128 m ++ y) = 128.
    + by rewrite size_cat size_tail // /y size_cat size_zeros /=; smt().
    have hl := pend512_full b1 _ hsy _; first by rewrite -hty.
    have [hc ht0] := parse512_close m y hsy.
    have hmf : mfin 128 16 m = m ++ y by rewrite /mfin ifF 1:/# -catA.
    rewrite size_mfin // ifF 1:/# /=.
    by rewrite hh1 hh hl hmf hc foldl_rcons ht0 /= pend512_nil.
  auto => /> &hr hf ht hh hp hm h111.
  have hr := modz_cmp (size m) 128.
  have h111' : size m %% 128 <= 111 by move: h111; rewrite W64.ultE hf /#.
  have hmf : mfin 128 16 m = m ++ [W8.of_int 128] by rewrite /mfin ifT 1:/#.
  have [hpm htm] := parse512_short m [W8.of_int 128] _.
  + by rewrite size_cat size_tail //=; smt().
  rewrite size_mfin // ifT 1:/# /= hmf hpm hh htm cats1 hp hf /=; smt().
seq 2 : (pend512 buf (tail 128 (mfin 128 16 m) ++ zeros (112 - size (mfin 128 16 m) %% 128)) /\
         size (mfin 128 16 m) %% 128 <= 112 /\ to_uint total = size m /\
         h512 h = foldl compress h0 (parse (mfin 128 16 m)) /\ size m < 2^61).
+ ecall (zero128_correct buf fill hi); auto => /> &hr hf hs ht hh hp hm.
  split; first smt(W64.to_uint_cmp).
  move=> _ [b1 ms1] /= hb1.
  have hst : size (tail 128 (mfin 128 16 m)) = size (mfin 128 16 m) %% 128 by rewrite size_tail.
  move: hb1; rewrite hf -hst => hb1.
  apply (pend512_zero buf{hr}) => //; smt(modz_ge0).
wp; while (dsize %/ 8 <= i <= (dsize + 7) %/ 8 /\ inc = (dsize + 7) %/ 8 /\
           h512 h = SHA512.hash h0 m /\
           forall b, 0 <= b < 8 * (dsize %/ 8) + 4 * (i - dsize %/ 8) =>
             BArrayD.get8 out b = nth W8.zero (flatten (map w64_be (h512 h))) b).
+ wp; ecall (bswap32_spec y); auto => /> &hr hi0 hi8 hh hk hlt.
  have [hiq h4] := cov_step i{hr} _; 1: done.
  have hd := dsize_ok.
  split; first smt().
  move=> b hb0 hb1.
  rewrite BArrayD.get8_set32dE.
  case: (2 * i{hr} * 4 <= b < 2 * i{hr} * 4 + 4) => hbi /=.
  + rewrite ifT 1:/# hi32_be 1:/# nth_flat512 1:/#.
    have hb8 : b %/ 8 = i{hr} by apply divz_eqP => //; clear hk hh; smt().
    have hb8' : b %% 8 = b - 4 * (2 * i{hr}) by rewrite modzE hb8; ring.
    by rewrite hb8 hb8'.
  rewrite ifF 1:/#.
  apply hk.
  split => //; move: hb1 hbi; rewrite -hiq; clear hk hh; smt().
wp; while (0 <= i <= dsize %/ 8 /\ inc = dsize %/ 8 /\ h512 h = SHA512.hash h0 m /\
           forall b, 0 <= b < 8 * i =>
             BArrayD.get8 out b = nth W8.zero (flatten (map w64_be (h512 h))) b).
+ wp; ecall (bswap64_spec x); auto => /> &hr hi0 hi8 hh hk hlt.
  have hd := dsize_ok.
  split; first smt().
  move=> b hb0 hb1.
  rewrite BArrayD.get8_set64dE.
  case: (8 * i{hr} <= b < 8 * i{hr} + 8) => hbi /=.
    have hk8 : 0 <= b - 8 * i{hr} < 8 by clear hk hh; smt().
    have hq : dsize %/ 8 * 8 <= dsize by apply lez_floor.
    have hbd : 0 <= b < dsize by clear hk hh; smt().
    have hb64 : 0 <= b < 64 by clear hk hh; smt().
    rewrite ifT 1:/# bswap64_be // nth_flat512 //.
    have hb8 : b %/ 8 = i{hr} by apply divz_eqP => //; clear hk hh; smt().
    have hb8' : b %% 8 = b - 8 * i{hr} by rewrite modzE hb8; ring.
    by rewrite hb8 hb8'.
  by apply hk; split => //; move: hb1 hbi; clear hk hh; smt().
wp; ecall (K512.compress_correct (h512 h) buf); wp; ecall (bswap64_spec t); wp; ecall (bswap64_spec t).
auto => /> &hr hp hs ht hh hm [h1 ms1] /= hh1.
have hd := dsize_ok.
pose mf := mfin 128 16 m.
have hsz : size (tail 128 mf ++ zeros (112 - size mf %% 128)) = 112.
+ by rewrite size_cat size_tail // size_zeros; smt(modz_ge0).
have hl := len_block512 _ _ (total{hr} `>>` W8.of_int 61) (total{hr} `<<` W8.of_int 3) hp hsz.
have hlen : be_bytes 8 (to_uint (total{hr} `>>` W8.of_int 61)) ++ be_bytes 8 (to_uint (total{hr} `<<` W8.of_int 3))
            = be_bytes 16 (8 * size m) by rewrite -ht len16E.
have hsy : size (tail 128 mf ++ (zeros (112 - size mf %% 128) ++ be_bytes 16 (8 * size m))) = 128.
+ by rewrite catA size_cat hsz size_be_bytes.
have [hc _] := parse512_close mf _ hsy.
have hhash : SHA512.hash h0 m = h512 h1.
+ rewrite hh1 hl -catA hlen hh /SHA512.hash pad512E padb_fin //=.
  by rewrite -/mf hc foldl_rcons -catA.
have hq0 : 0 <= dsize %/ 8 by apply divz_ge0 => //; smt().
split; first by rewrite hhash /=; smt().
move=> i out1 hn hi0 hi8 _ hk.
have hie : i = dsize %/ 8 by rewrite eqz_leq hi8 lezNgt.
have hqq : dsize %/ 8 <= (dsize + 7) %/ 8 by apply leq_div2r => //; smt().
split; first by split => // b hb0 hb1; apply hk; rewrite hie.
move=> i2 out2 hn2 hi20 hi21 hk2.
have hie2 : i2 = (dsize + 7) %/ 8 by rewrite eqz_leq hi21 lezNgt.
have h4 : 4 <= dsize by case: hd => [[]].
have h64 : dsize <= 64 by case: hd => [[]].
have hd0 : 0 <= dsize by exact (lez_trans 4).
apply (eq_from_nth W8.zero).
+ rewrite BArrayD.size_to_list size_take 1:/# hhash size_digest512 1:size_h512 //.
  rewrite /max ifT; first exact (ltr_le_trans 4).
  case: (dsize < 64) => // h; apply eqz_leq; split => //.
  by rewrite lezNgt h.
move=> b; rewrite BArrayD.size_to_list /max ifT; first exact (ltr_le_trans 4).
move=> hb; rewrite BArrayD.get_to_list nth_take //; first by case: hb.
by rewrite hhash hk2 // hie2 cov_end.
qed.

lemma finalize_ll : islossless F.finalize.
proof.
proc.
seq 6 : (to_uint fill <= 128 /\ two_blocks = (W64.of_int 112 \ult fill)) 1%r 1%r 0%r 0%r => //.
+ by auto => /> &hr; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
+ seq 1 : (to_uint fill <= 112) 1%r 1%r 0%r 0%r => //.
  + if.
    + by wp; call K512.compress_ll; call zero128_ll; auto => />.
    by auto => /> &hr h64; rewrite W64.ultE /=; smt().
  + wp; while (true) (inc - i).
    + by move=> z; wp; call bswap32_ll; auto => /#.
    wp; while (true) (inc - i).
    + by move=> z; wp; call bswap64_ll; auto => /#.
    wp; call K512.compress_ll; wp; call bswap64_ll; wp; call bswap64_ll; wp; call zero128_ll.
    by auto => /#.
  hoare; if.
  + by wp; call (: true) => //; call (: true) => //; auto.
  by auto => /> &hr h64; rewrite W64.ultE /=; smt().
by hoare; auto => /> &hr; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
qed.

lemma mem_from_correct (h0 : W64.t list) (p0 l0 : W64.t) :
  hoare [F.mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArrayD.to_list res.`1
           = take dsize (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha512_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream512_nil (h512 h{hr}) h{hr} witness<:BArray128.t> _ => //.
rewrite /stream512 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma mem_from_ll : islossless F.mem_from.
proof. by proc; call finalize_ll; call sha512_absorb_mem_ll; auto. qed.

end Final512.

clone Final512 as Finsha512 with op dsize <= 64, theory BArrayD <= BArray64
proof dsize_ok by done.

clone Final512 as Finsha384 with op dsize <= 48, theory BArrayD <= BArray48
proof dsize_ok by done.

clone Final512 as Finsha512_224 with op dsize <= 28, theory BArrayD <= BArray28
proof dsize_ok by done.

clone Final512 as Finsha512_256 with op dsize <= 32, theory BArrayD <= BArray32
proof dsize_ok by done.

(* The instances against the theory, as for SHA-256 (SHA256_Stream.ec):
   the compress calls are related through their result alone, and the
   equivalences relate the outputs, not the returned flag. *)

lemma h512_inj (a b : BArray64.t) : h512 a = h512 b => a = b.
proof.
move=> heq; apply BArray64.tP => i hi.
have hw : BArray64.get64 a (i %/ 8) = BArray64.get64 b (i %/ 8).
+ by rewrite -!nth_h512 1,2:/# heq.
have -> : i = 8 * (i %/ 8) + i %% 8 by smt(divz_eq).
by rewrite -!BArray64.get64d_byte 1,2:/# hw.
qed.

equiv compress512_eq : M._sha512_compress ~ M._sha512_compress : ={h, block} ==> res{1}.`1 = res{2}.`1.
proof.
proc*; exists* h{1}, block{1}; elim* => h1 b1.
call{1} (K512.compress_total (h512 h1) b1); call{2} (K512.compress_total (h512 h1) b1).
by auto => /> r1 hr1 r2 hr2; apply h512_inj; rewrite hr1 hr2.
qed.

equiv zero128_eq : M.__zero128 ~ M.__zero128 :
  ={buf, lo_, hi} /\ to_uint lo_{1} <= to_uint hi{1} <= 128 ==> res{1}.`1 = res{2}.`1.
proof.
proc*; exists* buf{1}, lo_{1}, hi{1}; elim* => b1 l1 u1.
call{1} (zero128_total b1 l1 u1); call{2} (zero128_total b1 l1 u1).
auto => /> hl hu r1 hr1 r2 hr2; apply BArray128.tP => i hi.
by rewrite hr1 // hr2.
qed.

equiv fin_sha512_eq : M._sha512___sha512_finalize ~ Finsha512.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

lemma sha512_finalize_ll : islossless M._sha512___sha512_finalize.
proof. by conseq fin_sha512_eq Finsha512.finalize_ll => /#. qed.

lemma sha512_finalize_correct (h0 : W64.t list) (m : bytes) :
  hoare [M._sha512___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray64.to_list res.`1 = take 64 (flatten (map w64_be (SHA512.hash h0 m)))].
proof. by conseq fin_sha512_eq (Finsha512.finalize_correct h0 m) => /#. qed.

lemma sha512_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray64.to_list res.`1 = take 64 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq sha512_finalize_ll (sha512_finalize_correct h0 m). qed.

lemma sha512_mem_from_ll : islossless M._sha512____sha512_mem_from.
proof. by proc; call sha512_finalize_ll; call sha512_absorb_mem_ll; auto. qed.

lemma sha512_mem_from_correct (h0 : W64.t list) (p0 l0 : W64.t) :
  hoare [M._sha512____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = take 64 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (sha512_finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha512_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream512_nil (h512 h{hr}) h{hr} witness<:BArray128.t> _ => //.
rewrite /stream512 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma sha512_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1
           = take 64 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha512_mem_from_ll (sha512_mem_from_correct h0 p0 l0). qed.

equiv fin_sha384_eq : M._sha384___sha512_finalize ~ Finsha384.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

lemma sha384_finalize_ll : islossless M._sha384___sha512_finalize.
proof. by conseq fin_sha384_eq Finsha384.finalize_ll => /#. qed.

lemma sha384_finalize_correct (h0 : W64.t list) (m : bytes) :
  hoare [M._sha384___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray48.to_list res.`1 = take 48 (flatten (map w64_be (SHA512.hash h0 m)))].
proof. by conseq fin_sha384_eq (Finsha384.finalize_correct h0 m) => /#. qed.

lemma sha384_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha384___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray48.to_list res.`1 = take 48 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq sha384_finalize_ll (sha384_finalize_correct h0 m). qed.

lemma sha384_mem_from_ll : islossless M._sha384____sha512_mem_from.
proof. by proc; call sha384_finalize_ll; call sha512_absorb_mem_ll; auto. qed.

lemma sha384_mem_from_correct (h0 : W64.t list) (p0 l0 : W64.t) :
  hoare [M._sha384____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1
           = take 48 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (sha384_finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha512_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream512_nil (h512 h{hr}) h{hr} witness<:BArray128.t> _ => //.
rewrite /stream512 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma sha384_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha384____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1
           = take 48 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha384_mem_from_ll (sha384_mem_from_correct h0 p0 l0). qed.

equiv fin_sha512_224_eq : M._sha512_224___sha512_finalize ~ Finsha512_224.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

lemma sha512_224_finalize_ll : islossless M._sha512_224___sha512_finalize.
proof. by conseq fin_sha512_224_eq Finsha512_224.finalize_ll => /#. qed.

lemma sha512_224_finalize_correct (h0 : W64.t list) (m : bytes) :
  hoare [M._sha512_224___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w64_be (SHA512.hash h0 m)))].
proof. by conseq fin_sha512_224_eq (Finsha512_224.finalize_correct h0 m) => /#. qed.

lemma sha512_224_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_224___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray28.to_list res.`1 = take 28 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq sha512_224_finalize_ll (sha512_224_finalize_correct h0 m). qed.

lemma sha512_224_mem_from_ll : islossless M._sha512_224____sha512_mem_from.
proof. by proc; call sha512_224_finalize_ll; call sha512_absorb_mem_ll; auto. qed.

lemma sha512_224_mem_from_correct (h0 : W64.t list) (p0 l0 : W64.t) :
  hoare [M._sha512_224____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (sha512_224_finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha512_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream512_nil (h512 h{hr}) h{hr} witness<:BArray128.t> _ => //.
rewrite /stream512 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma sha512_224_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512_224____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1
           = take 28 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha512_224_mem_from_ll (sha512_224_mem_from_correct h0 p0 l0). qed.

equiv fin_sha512_256_eq : M._sha512_256___sha512_finalize ~ Finsha512_256.F.finalize : ={arg} ==>
  res{1}.`1 = res{2}.`1 /\ res{1}.`2 = res{2}.`2 /\ res{1}.`3 = res{2}.`3.
proof.
proc.
seq 6 6 : (={out, h, buf, total, fill, two_blocks, ms} /\ to_uint fill{1} <= 128 /\
           two_blocks{1} = (W64.of_int 112 \ult fill{1})).
+ by auto => /> &2; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp W64.to_uint_cmp).
seq 1 1 : (={out, h, buf, total, fill} /\ to_uint fill{1} <= 112).
+ if => //; last by auto => /> &2 h64; rewrite W64.ultE /=; smt().
  by wp; call compress512_eq; call zero128_eq; auto => /> &2 h64 h56.
wp; while (={i, inc, out, h}); first by wp; call bswap32_eq; auto.
wp; while (={i, inc, out, h}); first by wp; call bswap64_eq; auto.
wp; call compress512_eq; wp; call bswap64_eq; wp; call bswap64_eq; wp; call zero128_eq.
by auto => /> &2 h56; rewrite /protect_ptr; smt(W64.to_uint_cmp).
qed.

lemma sha512_256_finalize_ll : islossless M._sha512_256___sha512_finalize.
proof. by conseq fin_sha512_256_eq Finsha512_256.finalize_ll => /#. qed.

lemma sha512_256_finalize_correct (h0 : W64.t list) (m : bytes) :
  hoare [M._sha512_256___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w64_be (SHA512.hash h0 m)))].
proof. by conseq fin_sha512_256_eq (Finsha512_256.finalize_correct h0 m) => /#. qed.

lemma sha512_256_finalize_total (h0 : W64.t list) (m : bytes) :
  phoare [M._sha512_256___sha512_finalize :
           stream512 h0 m h buf total /\ size m < 2^61 ==>
           BArray32.to_list res.`1 = take 32 (flatten (map w64_be (SHA512.hash h0 m)))] = 1%r.
proof. by conseq sha512_256_finalize_ll (sha512_256_finalize_correct h0 m). qed.

lemma sha512_256_mem_from_ll : islossless M._sha512_256____sha512_mem_from.
proof. by proc; call sha512_256_finalize_ll; call sha512_absorb_mem_ll; auto. qed.

lemma sha512_256_mem_from_correct (h0 : W64.t list) (p0 l0 : W64.t) :
  hoare [M._sha512_256____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))].
proof.
proc.
ecall (sha512_256_finalize_correct h0 (memread Glob.mem (to_uint p0) (to_uint l0))).
ecall (sha512_absorb_mem_correct h0 [] p0 l0); auto => /> &hr hpl hl.
have := stream512_nil (h512 h{hr}) h{hr} witness<:BArray128.t> _ => //.
rewrite /stream512 /= => [#] h1 h2.
split; first by rewrite h1 h2 /=; smt(W64.to_uint_cmp).
by move=> _ _ _ r _ _ _; rewrite JWordList.size_memread; smt(W64.to_uint_cmp).
qed.

lemma sha512_256_mem_from_total (h0 : W64.t list) (p0 l0 : W64.t) :
  phoare [M._sha512_256____sha512_mem_from :
           h512 h = h0 /\ in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1
           = take 32 (flatten (map w64_be
                (SHA512.hash h0 (memread Glob.mem (to_uint p0) (to_uint l0)))))] = 1%r.
proof. by conseq sha512_256_mem_from_ll (sha512_256_mem_from_correct h0 p0 l0). qed.

(* ------------------------------------------------------------------ *)
(* One-shot hashes of a memory buffer                                 *)

lemma sha512_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha512_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1 = SHA512.sha512 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha512_mem_from_correct H0_512 p0 l0); call sha512_init_correct.
auto => /> &hr hpl hl h1 hh1 r ->.
by rewrite /SHA512.sha512 /digest take_oversize // size_digest512 // HMACSpec.size_hash512.
qed.

lemma sha512_mem_ll : islossless M._sha512_mem.
proof. by proc; call sha512_mem_from_ll; call sha512_init_ll; auto. qed.

lemma sha512_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res.`1 = SHA512.sha512 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha512_mem_ll (sha512_mem_correct p0 l0). qed.

lemma sha384_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha384_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1 = SHA512.sha384 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha384_mem_from_correct H0_384 p0 l0); call sha384_init_correct.
by auto => /> &hr hpl hl h1 hh1 r ->.
qed.

lemma sha384_mem_ll : islossless M._sha384_mem.
proof. by proc; call sha384_mem_from_ll; call sha384_init_ll; auto. qed.

lemma sha384_mem_total (p0 l0 : W64.t) :
  phoare [M._sha384_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray48.to_list res.`1 = SHA512.sha384 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha384_mem_ll (sha384_mem_correct p0 l0). qed.

lemma sha512_224_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha512_224_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA512.sha512_224 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha512_224_mem_from_correct H0_512_224 p0 l0); call sha512_224_init_correct.
by auto => /> &hr hpl hl h1 hh1 r ->.
qed.

lemma sha512_224_mem_ll : islossless M._sha512_224_mem.
proof. by proc; call sha512_224_mem_from_ll; call sha512_224_init_ll; auto. qed.

lemma sha512_224_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_224_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray28.to_list res.`1 = SHA512.sha512_224 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha512_224_mem_ll (sha512_224_mem_correct p0 l0). qed.

lemma sha512_256_mem_correct (p0 l0 : W64.t) :
  hoare [M._sha512_256_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA512.sha512_256 (memread Glob.mem (to_uint p0) (to_uint l0))].
proof.
proc; ecall (sha512_256_mem_from_correct H0_512_256 p0 l0); call sha512_256_init_correct.
by auto => /> &hr hpl hl h1 hh1 r ->.
qed.

lemma sha512_256_mem_ll : islossless M._sha512_256_mem.
proof. by proc; call sha512_256_mem_from_ll; call sha512_256_init_ll; auto. qed.

lemma sha512_256_mem_total (p0 l0 : W64.t) :
  phoare [M._sha512_256_mem :
           in_0 = p0 /\ inlen = l0 /\
           to_uint p0 + to_uint l0 < W64.modulus /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res.`1 = SHA512.sha512_256 (memread Glob.mem (to_uint p0) (to_uint l0))]
  = 1%r.
proof. by conseq sha512_256_mem_ll (sha512_256_mem_correct p0 l0). qed.

