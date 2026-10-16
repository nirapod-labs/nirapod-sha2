(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4.ec
 * ============
 *
 * Functional correctness of the 4-way SHA-512 front end of
 * src/sha512_x4.jinc against FIPS 180-4 (spec/FIPS180_SHA2.ec), over the
 * unit's 4-way kernel as KX4 states it.
 *
 * Layout. Four messages of one common length are hashed side by side.
 * Word j of lane k of the chaining value is u64 cell 4 j + k of a 256-byte
 * array (l4 h k, the order the kernels use); lane k's pending block is
 * bytes [128 k, 128 k + 128) of a 512-byte array (sub4 buf k). The state
 * (h, buf, total) after the messages ms 0, ..., ms 3 have been absorbed
 * from the chaining value h0 satisfies stream4 h0 ms: total is the common
 * length, and every lane is the stream state of SHA512_Stream.ec for its
 * message.
 *
 * Theorems (total correctness):
 *     sha512_x4_init_total     every lane holds the initial hash value;
 *     sha512_x4_from_total     every lane holds one chaining value and one
 *                              pending block;
 *     sha512_x4_absorb_total   lane k absorbs l bytes at in[k];
 *     sha512_x4_finalize_total out holds the four digests, lane k's at
 *                              bytes [64 k, 64 k + 64);
 *     sha512_x4_lanes_total    the four one-shot digests.
 *
 * Domain: no input wraps the address space and the messages are below
 * 2^61 bytes.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray32 BArray64 BArray128 BArray256 BArray512 SBArray512_128.
require import NirapodSha2 ArchWord WordSpec.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill Lanes SHA512_Stream.
require JWordList KX4 SHA256_Stream.
import SHA512.

abbrev memread = JWordList.memread.

abbrev l4 (h : BArray256.t) (k : int) : W64.t list = lane4 (BArray256.get64 h) k.
abbrev sub4 (b : BArray512.t) (k : int) : BArray128.t = SBArray512_128.get_sub8 b (128 * k).
abbrev ptr (in0 : BArray32.t) (k : int) : int = to_uint (BArray32.get64 in0 k).

(* ------------------------------------------------------------------ *)
(* Lane views of the block array                                      *)

lemma sub4_block (b : BArray512.t) k : 0 <= k < 4 =>
  BArray128.to_list (sub4 b k) = lane_block 128 (BArray512.to_list b) k.
proof.
move=> hk; apply (eq_from_nth W8.zero).
+ by rewrite BArray128.size_to_list size_lane_block // 1:/# BArray512.size_to_list /#.
move=> i; rewrite BArray128.size_to_list => hi.
rewrite BArray128.get_to_list SBArray512_128.get8_get_sub hi /=.
by rewrite nth_lane_block // 1:/# BArray512.get_to_list.
qed.

lemma sub4_set_sub (b : BArray512.t) (a : BArray128.t) j k : 0 <= j < 4 => 0 <= k < 4 =>
  sub4 (SBArray512_128.set_sub8 b (128 * k) a) j = if j = k then a else sub4 b j.
proof.
move=> hj hk; apply BArray128.tP => i hi.
rewrite SBArray512_128.get8_get_sub hi /= SBArray512_128.get8_set_sub.
case: (j = k) => [<-|hne] /=.
+ by rewrite ifT 1:/#; congr; ring.
by rewrite ifF 1:/# SBArray512_128.get8_get_sub hi.
qed.

lemma sub4_set8 (b : BArray512.t) j k i x : 0 <= j < 4 => 0 <= k < 4 => 0 <= i < 128 =>
  sub4 (BArray512.set8 b (128 * k + i) x) j
  = if j = k then BArray128.set8 (sub4 b k) i x else sub4 b j.
proof.
move=> hj hk hi; apply BArray128.tP => i' hi'.
rewrite SBArray512_128.get8_get_sub hi' /= BArray512.get_setE 1:/#.
case: (j = k) => [<-|hne] /=.
+ by rewrite BArray128.get_setE 1:// SBArray512_128.get8_get_sub hi' /= /#.
by rewrite ifF 1:/# SBArray512_128.get8_get_sub hi'.
qed.

lemma sub4_set64d (b : BArray512.t) j k o t : 0 <= j < 4 => 0 <= k < 4 => 0 <= o <= 120 =>
  sub4 (BArray512.set64d b (128 * k + o) t) j
  = if j = k then BArray128.set64d (sub4 b k) o t else sub4 b j.
proof.
move=> hj hk ho; apply BArray128.tP => i hi.
rewrite SBArray512_128.get8_get_sub hi /= BArray512.get8_set64dE.
case: (j = k) => [<-|hne] /=.
+ rewrite BArray128.get8_set64dE SBArray512_128.get8_get_sub hi /=.
  case: (o <= i < o + 8) => h; first by rewrite !ifT 1,2:/#; congr; ring.
  by rewrite !ifF 1,2:/#.
by rewrite ifF 1:/# SBArray512_128.get8_get_sub hi.
qed.

(* ------------------------------------------------------------------ *)
(* The representation                                                 *)

op lanes4 (h0 : W64.t list) (ms : int -> bytes) (h : BArray256.t) (buf : BArray512.t) =
  forall k, 0 <= k < 4 =>
     l4 h k = foldl compress h0 (parse (ms k))
  /\ pend512 (sub4 buf k) (tail 128 (ms k)).

op stream4 (h0 : W64.t list) (ms : int -> bytes) (h : BArray256.t) (buf : BArray512.t) (total : W64.t) =
  (forall k, 0 <= k < 4 => to_uint total = size (ms k)) /\ lanes4 h0 ms h buf.

(* The bytes of lane k that complete its pending block, and lane k after
   them and the whole blocks that follow. *)
op nfx4 (t l : W64.t) : int = nfill 128 (to_uint t %% 128) (to_uint l).

op m1x4 mem (ms : int -> bytes) (in0 : BArray32.t) nf : int -> bytes =
  fun k => ms k ++ memread mem (ptr in0 k) nf.

op abx4 mem (ms : int -> bytes) (in0 : BArray32.t) nf l : int -> bytes =
  fun k => m1x4 mem ms in0 nf k ++ memread mem (ptr in0 k + nf) (128 * ((l - nf) %/ 128)).

(* Filling lane k's pending block leaves the other lanes as they were. *)
lemma pend_step (buf : BArray512.t) (b1 : BArray128.t) (t x : int -> bytes) k :
  0 <= k < 4 =>
  (forall j, 0 <= j < 4 => pend512 (sub4 buf j) (t j ++ if j < k then x j else [])) =>
  pend512 b1 (t k ++ x k) =>
  forall j, 0 <= j < 4 =>
    pend512 (sub4 (SBArray512_128.set_sub8 buf (128 * k) b1) j) (t j ++ if j < k + 1 then x j else []).
proof.
move=> hk hp hb j hj; rewrite sub4_set_sub //.
case: (j = k) => [->|hne] /=; first by rewrite ifT 1:/#.
by rewrite (_ : (j < k + 1) = (j < k)) 1:/#; apply hp.
qed.

(* A lane whose pending block the input completes. *)
lemma lane_close (h0 : W64.t list) (m x : bytes) (hv hv1 : W64.t list) (b : BArray128.t) :
  size (tail 128 m ++ x) = 128 => hv = foldl compress h0 (parse m) => pend512 b (tail 128 m ++ x) =>
  hv1 = compress hv (map be64 (chunk 8 (BArray128.to_list b))) =>
  hv1 = foldl compress h0 (parse (m ++ x)) /\ tail 128 (m ++ x) = [].
proof.
move=> hs hh hp ->; have [hc ht] := parse512_close m x hs.
by rewrite hc foldl_rcons -hh (pend512_full b _ hs hp) ht.
qed.

(* ------------------------------------------------------------------ *)
(* Absorbing four inputs                                              *)

lemma x4_absorb_inner (h0 : W64.t list) (ms0 : int -> bytes) (in0 : BArray32.t) (t0 l0 : W64.t) :
  hoare [M._sha512_x4_absorb_lanes :
           total = t0 /\ in_0 = in0 /\ inlen = l0 /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           lanes4 h0 ms0 h buf /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
           to_uint t0 + to_uint l0 < W64.modulus ==>
           to_uint res.`3 = to_uint t0 + to_uint l0 /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           lanes4 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1 res.`2].
proof.
proc.
seq 8 : (to_uint fill = to_uint t0 %% 128 /\ to_uint n = nfx4 t0 l0 /\
         to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\ k = 0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         lanes4 h0 ms0 h buf /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus).
+ auto => /> &hr hs hl hpl htl.
  have hr := modz_cmp (to_uint t0) 128.
  have hf : to_uint (t0 `&` W64.of_int 127) = to_uint t0 %% 128 by rewrite and127.
  have hn := fill_count512 (t0 `&` W64.of_int 127) l0 _; 1: by rewrite hf /#.
  by rewrite hf hn hf /nfx4 W64.to_uintD_small 1:/#.
seq 1 : (to_uint fill = to_uint t0 %% 128 /\ to_uint n = nfx4 t0 l0 /\
         to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
         (forall j, 0 <= j < 4 =>
            pend512 (sub4 buf j) (tail 128 (ms0 j) ++ memread Glob.mem (ptr in0 j) (nfx4 t0 l0)))).
+ while (0 <= k <= 4 /\ to_uint fill = to_uint t0 %% 128 /\ to_uint n = nfx4 t0 l0 /\
         to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
         (forall j, 0 <= j < 4 =>
            pend512 (sub4 buf j)
              (tail 128 (ms0 j) ++ if j < k then memread Glob.mem (ptr in0 j) (nfx4 t0 l0) else []))).
  + wp; ecall (fill128_correct (sub4 buf k) fill p n); auto => /> &hr hk0 _ hf hn _ hs hpl _ _ hp hk8.
    rewrite /protect_64.
    have hnb := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
    split; first by rewrite hf hn /nfx4; smt().
    move=> _ _ [b1 ms1] /= hb1; split; first smt().
    have := pend_step buf{hr} b1 (fun j => tail 128 (ms0 j))
              (fun j => memread Glob.mem{hr} (ptr in0 j) (nfx4 t0 l0)) k{hr} _ hp _; 1: smt().
    + have hsk : size (tail 128 (ms0 k{hr})) = to_uint t0 %% 128 by rewrite size_tail // hs 1:/#.
      rewrite /=; apply (pend512_fill (sub4 buf{hr} k{hr})); 1,2: by rewrite ?hsk /nfx4; smt().
      + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
      by rewrite hsk -hf -hn.
    by move=> h j hj0 hj1; apply h.
  auto => /> &hr _ _ _ _ hl _ _; split.
  + split => j hj0 hj1; have hj : 0 <= j < 4 by done.
    + by have [hh _] := hl j hj.
    by have [_ hp] := hl j hj; rewrite ifF 1:/# cats0.
  move=> b k0 hk hk0 hk8 _ hp j hj0 hj1.
  by have := hp j _; [smt() | rewrite ifT 1:/#].
seq 4 : (to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         to_uint off = nfx4 t0 l0 /\
         to_uint fill = (to_uint t0 + nfx4 t0 l0) %% 128 /\
         (to_uint l0 - nfx4 t0 l0 <> 0 => to_uint fill = 0) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (m1x4 Glob.mem ms0 in0 (nfx4 t0 l0) j))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j) (tail 128 (m1x4 Glob.mem ms0 in0 (nfx4 t0 l0) j)))).
+ sp; if.
  + wp; ecall (KX4.compress_correct h buf); auto => /> &hr f0 hf hn ht hs hpl htl hh hp hfull [h1 ms1] /= hh1.
    rewrite /protect_ptr.
    have hb := nfill_bounds 128 (to_uint t0 %% 128) (to_uint inlen{hr}) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
    have hsum : to_uint t0 %% 128 + nfx4 t0 inlen{hr} = 128.
    + have : to_uint (f0 + n{hr}) = 128 by rewrite hfull.
      by rewrite W64.to_uintD_small hf hn /nfx4; smt().
    have hl : forall j, 0 <= j < 4 =>
                l4 h1 j = foldl compress h0 (parse (m1x4 Glob.mem{hr} ms0 in_0{hr} (nfx4 t0 inlen{hr}) j))
                /\ tail 128 (m1x4 Glob.mem{hr} ms0 in_0{hr} (nfx4 t0 inlen{hr}) j) = [].
    + move=> j hj; apply (lane_close h0 _ _ (l4 h{hr} j) _ (sub4 buf{hr} j)).
      + by rewrite size_cat size_tail // hs // JWordList.size_memread /nfx4; smt().
      + exact (hh j hj).
      + exact (hp j hj).
      by rewrite sub4_block // hh1.
    split; first by rewrite -modzDml hsum.
    split => j hj0 hj1; have hj : 0 <= j < 4 by done.
    + by have [-> _] := hl j hj.
    by have [_ ->] := hl j hj; exact pend512_nil.
  auto => /> &hr f0 hf hn ht hs hpl htl hh hp hfull.
  have hb := nfill_bounds 128 (to_uint t0 %% 128) (to_uint inlen{hr}) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
  have hfn : to_uint (f0 + n{hr}) = to_uint t0 %% 128 + nfx4 t0 inlen{hr}.
  + by rewrite W64.to_uintD_small hf hn /nfx4; smt().
  have hlt : to_uint t0 %% 128 + nfx4 t0 inlen{hr} < 128.
  + have : to_uint (f0 + n{hr}) <> 128.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    by rewrite /nfx4; smt().
  have hl : forall j, 0 <= j < 4 =>
              parse (m1x4 Glob.mem{hr} ms0 in_0{hr} (nfx4 t0 inlen{hr}) j) = parse (ms0 j)
              /\ tail 128 (m1x4 Glob.mem{hr} ms0 in_0{hr} (nfx4 t0 inlen{hr}) j)
                 = tail 128 (ms0 j) ++ memread Glob.mem{hr} (ptr in_0{hr} j) (nfx4 t0 inlen{hr}).
  + move=> j hj; apply parse512_short.
    by rewrite size_cat size_tail // hs // JWordList.size_memread /nfx4; smt().
  split.
  + rewrite hfn -modzDml (pmod_small (to_uint t0 %% 128 + nfx4 t0 inlen{hr})) //.
    by have := modz_ge0 (to_uint t0) 128; smt().
  split.
  + move=> hin; rewrite hfn; move: hin hlt; rewrite /nfx4 /nfill.
    by case: (to_uint t0 %% 128 = 0) => hz /=; smt().
  split => j hj0 hj1; have hj : 0 <= j < 4 by done.
  + by have [-> _] := hl j hj; apply hh.
  by have [_ ->] := hl j hj; apply hp.
seq 5 : (to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         to_uint off = nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128) /\
         to_uint fill = (to_uint t0 + nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128)) %% 128 /\
         to_uint fill + (to_uint l0 - nfx4 t0 l0) %% 128 < 128 /\
         (forall j, 0 <= j < 4 =>
            l4 h j = foldl compress h0 (parse (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j))) /\
         (forall j, 0 <= j < 4 =>
            pend512 (sub4 buf j) (tail 128 (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j)))).
+ sp; if.
  + wp; ecall (KX4.compress_lanes_correct h in_0 off n); auto => /> &hr ht hs hpl htl hoff hf hz hh hp hn0.
    rewrite /protect_64 /protect_ptr /=.
    have hb := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
    pose nf := nfx4 t0 l0.
    have hsub : to_uint (l0 - off{hr}) = to_uint l0 - nf.
    + by rewrite W64.to_uintB 1:W64.uleE hoff /nfx4; smt().
    have hq : to_uint (l0 - off{hr} `>>` W8.of_int 7) = (to_uint l0 - nf) %/ 128 by rewrite shrc // hsub.
    have hq1 : 1 <= (to_uint l0 - nf) %/ 128 by rewrite -hq; apply nonzero.
    have h64 : 128 * ((to_uint l0 - nf) %/ 128) <= to_uint l0 - nf by smt(divz_eq modz_ge0).
    have hblk : to_uint ((l0 - off{hr} `>>` W8.of_int 7) `<<` W8.of_int 7) = 128 * ((to_uint l0 - nf) %/ 128).
    + by rewrite blocksc // hsub.
    have hf0 : to_uint fill{hr} = 0 by apply hz; smt().
    split; first by move=> q hq0 hq8; rewrite hq hoff; have := hpl q _; smt().
    move=> _ [h1 ms1] /= hh1.
    have hl : forall j, 0 <= j < 4 =>
                parse (abx4 Glob.mem{hr} ms0 in0 nf (to_uint l0) j)
                = parse (m1x4 Glob.mem{hr} ms0 in0 nf j)
                  ++ parse (memread Glob.mem{hr} (ptr in0 j + nf) (128 * ((to_uint l0 - nf) %/ 128)))
                /\ tail 128 (abx4 Glob.mem{hr} ms0 in0 nf (to_uint l0) j) = [].
    + move=> j hj; apply parse512_blocks.
      + apply tail512_nil; rewrite /m1x4 /= size_cat hs // JWordList.size_memread 1:/#.
        by rewrite -hf hf0.
      by rewrite JWordList.size_memread 1:/# dvdz_mulr.
    split; first by rewrite W64.to_uintD_small hblk hoff //; smt(W64.to_uint_cmp).
    split; first by rewrite (mulzC 128) modzMDr -hf hf0.
    split; first smt(modz_cmp).
    split => j hj0 hj1; have hj : 0 <= j < 4 by done.
    + by have [-> _] := hl j hj; rewrite foldl_cat -(hh j hj) (hh1 j hj) hq hoff.
    by have [_ ->] := hl j hj; exact pend512_nil.
  auto => /> &hr ht hs hpl htl hoff hf hz hh hp hn0.
  have hb := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
  pose nf := nfx4 t0 l0.
  have hsub : to_uint (l0 - off{hr}) = to_uint l0 - nf.
  + by rewrite W64.to_uintB 1:W64.uleE hoff /nfx4; smt().
  have hq : (to_uint l0 - nf) %/ 128 = 0.
  + by have := shrc (l0 - off{hr}) 7 _; [done | rewrite hn0 hsub /=; smt()].
  have hab : forall j, abx4 Glob.mem{hr} ms0 in0 nf (to_uint l0) j = m1x4 Glob.mem{hr} ms0 in0 nf j.
  + by move=> j; rewrite /abx4 /= hq /= cats0.
  have hnf : 0 <= nf <= to_uint l0 by rewrite /nf /nfx4; smt().
  have hlt : 0 <= to_uint l0 - nf < 128 by smt(divz_eq modz_ge0 modz_cmp).
  rewrite hq /=; do !split => //.
  + by rewrite pmod_small //; smt().
  + by move=> j hj0 hj1; rewrite hab; apply hh.
  by move=> j hj0 hj1; rewrite hab; apply hp.
seq 3 : (to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         to_uint off = nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128) /\
         to_uint fill = (to_uint t0 + nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128)) %% 128 /\
         to_uint fill + (to_uint l0 - nfx4 t0 l0) %% 128 < 128 /\
         to_uint n = (to_uint l0 - nfx4 t0 l0) %% 128 /\
         (forall j, 0 <= j < 4 =>
            l4 h j = foldl compress h0 (parse (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j))) /\
         k = 0 /\
         (forall j, 0 <= j < 4 =>
            pend512 (sub4 buf j) (tail 128 (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j)))).
+ auto => /> &hr ht hs hpl htl hoff hf hsum hh hp.
  have hnf : 0 <= nfx4 t0 l0 <= to_uint l0.
  + have := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
    by rewrite /nfx4 /#.
  rewrite W64.to_uintB 1:W64.uleE hoff; smt(divz_eq modz_ge0).
while (0 <= k <= 4 /\ to_uint total = to_uint t0 + to_uint l0 /\ in_0 = in0 /\ inlen = l0 /\
         (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
         (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
         to_uint t0 + to_uint l0 < W64.modulus /\
         to_uint off = nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128) /\
         to_uint fill = (to_uint t0 + nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128)) %% 128 /\
         to_uint fill + (to_uint l0 - nfx4 t0 l0) %% 128 < 128 /\
         to_uint n = (to_uint l0 - nfx4 t0 l0) %% 128 /\
         (forall j, 0 <= j < 4 =>
            l4 h j = foldl compress h0 (parse (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j))) /\
       (forall j, 0 <= j < 4 =>
          pend512 (sub4 buf j)
            (tail 128 (abx4 Glob.mem ms0 in0 (nfx4 t0 l0) (to_uint l0) j)
             ++ if j < k then memread Glob.mem (to_uint (BArray32.get64 in0 j + off)) (to_uint n) else []))).
+ wp; ecall (fill128_correct (sub4 buf k) fill p n); auto => /> &hr hk0 _ ht hs hpl htl hoff hf hsum hn hh hp hk8.
  rewrite /protect_64.
  have hnf : 0 <= nfx4 t0 l0 <= to_uint l0.
  + have := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
    by rewrite /nfx4 /#.
  have hoffl : to_uint off{hr} + to_uint n{hr} = to_uint l0 by rewrite hoff hn; smt(divz_eq).
  have hpk : to_uint (BArray32.get64 in0 k{hr} + off{hr}) = ptr in0 k{hr} + to_uint off{hr}.
  + by rewrite W64.to_uintD_small //; have := hpl k{hr} _; smt(W64.to_uint_cmp).
  have hpk8 := hpl k{hr} _; 1: smt().
  split; first by split; [rewrite hn; smt() | rewrite hpk; smt()].
  move=> _ _ [b1 ms1] /= hb1; split; first smt().
  have := pend_step buf{hr} b1 (fun j => tail 128 (abx4 Glob.mem{hr} ms0 in0 (nfx4 t0 l0) (to_uint l0) j))
            (fun j => memread Glob.mem{hr} (to_uint (BArray32.get64 in0 j + off{hr})) (to_uint n{hr}))
            k{hr} _ hp _; 1: smt().
  + have hsk : size (tail 128 (abx4 Glob.mem{hr} ms0 in0 (nfx4 t0 l0) (to_uint l0) k{hr})) = to_uint fill{hr}.
    + rewrite size_tail // hf /abx4 /m1x4 /= !size_cat hs 1:/# JWordList.size_memread 1:/#.
      rewrite JWordList.size_memread //; smt(divz_ge0).
    rewrite /=; apply (pend512_fill (sub4 buf{hr} k{hr})); 1,2: by rewrite ?hsk; smt(W64.to_uint_cmp).
    + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
    by rewrite hsk.
  by move=> h j hj0 hj1; apply h.
auto => /> &hr ht hs hpl htl hoff hf hsum hn hh hp; split.
+ by move=> j hj0 hj1; rewrite ifF 1:/# cats0; apply hp.
move=> b k0 hk hk0 hk8 hp2; rewrite /lanes4 => j hj /=.
have hpj := hpl j hj.
have hnf : 0 <= nfx4 t0 l0 <= to_uint l0.
+ have := nfill_bounds 128 (to_uint t0 %% 128) (to_uint l0) _ _; 1,2: smt(modz_cmp W64.to_uint_cmp).
  by rewrite /nfx4 /#.
have hsplit := absorb_split 128 Glob.mem{hr} (ms0 j) (ptr in0 j) (to_uint l0) (nfx4 t0 l0) _ _; 1,2: smt().
have hpk : to_uint (BArray32.get64 in0 j + off{hr})
           = ptr in0 j + nfx4 t0 l0 + 128 * ((to_uint l0 - nfx4 t0 l0) %/ 128).
+ by rewrite W64.to_uintD_small hoff; smt(W64.to_uint_cmp divz_eq modz_ge0).
have hA : abx4 Glob.mem{hr} ms0 in0 (nfx4 t0 l0) (to_uint l0) j
          = (ms0 j ++ memread Glob.mem{hr} (ptr in0 j) (nfx4 t0 l0))
            ++ memread Glob.mem{hr} (ptr in0 j + nfx4 t0 l0) (128 * ((to_uint l0 - nfx4 t0 l0) %/ 128)).
+ by rewrite /abx4 /m1x4.
have hst : size (tail 128 (abx4 Glob.mem{hr} ms0 in0 (nfx4 t0 l0) (to_uint l0) j)) = to_uint fill{hr}.
+ rewrite size_tail // hf hA !size_cat hs // JWordList.size_memread 1:/#.
  rewrite JWordList.size_memread //; smt(divz_ge0).
have hsx : size (tail 128 (abx4 Glob.mem{hr} ms0 in0 (nfx4 t0 l0) (to_uint l0) j)
                 ++ memread Glob.mem{hr} (to_uint (BArray32.get64 in0 j + off{hr})) (to_uint n{hr})) < 128.
+ by rewrite size_cat JWordList.size_memread 1:/# hst hn.
have [hps hts] := parse512_short _ _ hsx.
rewrite hsplit -hA -hpk -hn.
split; first by rewrite hps; apply hh.
by rewrite hts; have := hp2 j hj; rewrite ifT 1:/#.
qed.

lemma sha512_x4_absorb_correct (h0 : W64.t list) (ms0 : int -> bytes) (in0 : BArray32.t) (l0 : W64.t) :
  hoare [M._sha512_x4_absorb_lanes :
           stream4 h0 ms0 h buf total /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
           to_uint total + to_uint l0 < W64.modulus ==>
           stream4 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1 res.`2 res.`3].
proof.
exists* total; elim* => t0.
conseq (x4_absorb_inner h0 ms0 in0 t0 l0).
+ move=> &m [-> [[hs hl] [-> [-> [hpl htl]]]]]; do !split => //.
  by move=> k hk; rewrite (hs k hk).
move=> &m [-> [[hs _] _]] r [ht [_ hl]]; split => // k hk /=.
by rewrite ht size_cat (hs k hk) JWordList.size_memread //; smt(W64.to_uint_cmp).
qed.

lemma sha512_x4_absorb_ll : islossless M._sha512_x4_absorb_lanes.
proof.
proc.
seq 9 : true 1%r 1%r 0%r 0%r => //.
+ while (0 <= k <= 4) (4 - k); first by move=> z; wp; call fill128_ll; auto => /#.
  by auto => /#.
seq 4 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call KX4.compress_ll |]; auto.
seq 5 : true 1%r 1%r 0%r 0%r => //; first by sp; if; [wp; call KX4.compress_lanes_ll |]; auto.
wp; while (0 <= k <= 4) (4 - k); first by move=> z; wp; call fill128_ll; auto => /#.
by auto => /#.
qed.

lemma sha512_x4_absorb_total (h0 : W64.t list) (ms0 : int -> bytes) (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_absorb_lanes :
           stream4 h0 ms0 h buf total /\ in_0 = in0 /\ inlen = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\
           to_uint total + to_uint l0 < W64.modulus ==>
           stream4 h0 (fun k => ms0 k ++ memread Glob.mem (ptr in0 k) (to_uint l0)) res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha512_x4_absorb_ll (sha512_x4_absorb_correct h0 ms0 in0 l0). qed.

(* ------------------------------------------------------------------ *)
(* Initial states                                                     *)

(* Cell 4 j + k of a lane-major array is word j of lane k. *)
lemma lane_inj4 j k j' k' : 0 <= k < 4 => 0 <= k' < 4 => 4 * j + k = 4 * j' + k' => j = j' /\ k = k'.
proof. by move=> hk hk' h; apply (lane_inj 4). qed.

lemma IV512_word j : 0 <= j < 8 => BArray64.get64 sHA512_IV j = nth witness H0_512 j.
proof.
move=> hj; rewrite -IV512_kernel -nth_h512 //.
by apply nth_change_dfl; rewrite size_h512.
qed.

lemma sha512_x4_init_correct :
  hoare [M.__sha512_x4_init : true ==> forall k, 0 <= k < 4 => l4 res k = H0_512].
proof.
proc.
while (0 <= j <= 8 /\ iv = sHA512_IV /\
       forall j' k', 0 <= j' < j => 0 <= k' < 4 => BArray256.get64 h (4 * j' + k') = BArray64.get64 iv j').
+ wp; while (0 <= k <= 4 /\ 0 <= j < 8 /\ iv = sHA512_IV /\ t = BArray64.get64 iv j /\
             (forall j' k', 0 <= j' < j => 0 <= k' < 4 => BArray256.get64 h (4 * j' + k') = BArray64.get64 iv j') /\
             forall k', 0 <= k' < k => BArray256.get64 h (4 * j + k') = BArray64.get64 iv j).
  + auto => /> &hr hk0 _ hj0 hj8 hold hnew hk8; split; first smt().
    split => [j' k' *|k' *].
    + by rewrite BArray256.get_set64E 1,2:/# ifF 1:/#; apply hold; smt().
    rewrite BArray256.get_set64E 1,2:/#.
    case: (k' = k{hr}) => h; first by rewrite ifT 1:/#.
    by rewrite ifF 1:/#; apply hnew; smt().
  auto => /> &hr hj0 _ hold hj8; split; first smt().
  move=> h1 k1 hk1 hk10 hk18 hold1 hnew1; split; first smt().
  move=> j' k' *; case: (j' = j{hr}) => [->|hne]; first by apply hnew1; smt().
  by apply hold1; smt().
auto => /> &hr; split; first smt().
move=> h1 j1 hj1 hj10 hj18 hall k hk0 hk8.
apply lane_list; first by rewrite /H0_512.
by move=> j hj /=; rewrite hall 1,2:/# IV512_word.
qed.

lemma sha512_x4_init_ll : islossless M.__sha512_x4_init.
proof.
proc; while (0 <= j <= 8) (8 - j).
+ by move=> z; wp; while (0 <= k <= 4) (4 - k); auto => /#.
by auto => /#.
qed.

lemma sha512_x4_init_total :
  phoare [M.__sha512_x4_init : true ==> forall k, 0 <= k < 4 => l4 res k = H0_512] = 1%r.
proof. by conseq sha512_x4_init_ll sha512_x4_init_correct. qed.

(* Every lane from one chaining value hs0 and one pending block bs0. *)
lemma sha512_x4_from_correct (hs0 : BArray64.t) (bs0 : BArray128.t) :
  hoare [M.__sha512_x4_from :
           hs = hs0 /\ bs = bs0 ==>
           (forall k, 0 <= k < 4 => l4 res.`1 k = h512 hs0) /\
           (forall k, 0 <= k < 4 => sub4 res.`2 k = bs0)].
proof.
proc.
seq 2 : (bs = bs0 /\ forall k, 0 <= k < 4 => l4 h k = h512 hs0).
+ while (0 <= j <= 8 /\ hs = hs0 /\ bs = bs0 /\
         forall j' k', 0 <= j' < j => 0 <= k' < 4 => BArray256.get64 h (4 * j' + k') = BArray64.get64 hs j').
  + wp; while (0 <= k <= 4 /\ 0 <= j < 8 /\ hs = hs0 /\ bs = bs0 /\ x = BArray64.get64 hs j /\
               (forall j' k', 0 <= j' < j => 0 <= k' < 4 => BArray256.get64 h (4 * j' + k') = BArray64.get64 hs j') /\
               forall k', 0 <= k' < k => BArray256.get64 h (4 * j + k') = BArray64.get64 hs j).
    + auto => /> &hr hk0 _ hj0 hj8 hold hnew hk8; split; first smt().
      split => [j' k' *|k' *].
      + by rewrite BArray256.get_set64E 1,2:/# ifF 1:/#; apply hold; smt().
      rewrite BArray256.get_set64E 1,2:/#.
      case: (k' = k{hr}) => h; first by rewrite ifT 1:/#.
      by rewrite ifF 1:/#; apply hnew; smt().
    auto => /> &hr hj0 _ hold hj8; split; first smt().
    move=> h1 k1 hk1 hk10 hk18 hold1 hnew1; split; first smt().
    move=> j' k' *; case: (j' = j{hr}) => [->|hne]; first by apply hnew1; smt().
    by apply hold1; smt().
  auto => /> &hr; split; first smt().
  move=> h1 j1 hj1 hj10 hj18 hall k hk0 hk8.
  apply lane_list; first exact size_h512.
  move=> j hj /=; rewrite hall 1,2:/# -nth_h512 //.
  by apply nth_change_dfl; rewrite size_h512.
while (0 <= i <= 16 /\ bs = bs0 /\ (forall k, 0 <= k < 4 => l4 h k = h512 hs0) /\
       forall k' x, 0 <= k' < 4 => 0 <= x < 8 * i => BArray512.get8 buf (128 * k' + x) = BArray128.get8 bs x).
+ wp; while (0 <= k <= 4 /\ 0 <= i < 16 /\ bs = bs0 /\ t = BArray128.get64 bs i /\
             (forall k, 0 <= k < 4 => l4 h k = h512 hs0) /\
             (forall k' x, 0 <= k' < 4 => 0 <= x < 8 * i =>
                BArray512.get8 buf (128 * k' + x) = BArray128.get8 bs x) /\
             forall k' x, 0 <= k' < k => 0 <= x < 8 * i + 8 =>
                BArray512.get8 buf (128 * k' + x) = BArray128.get8 bs x).
  + auto => /> &hr hk0 _ hi0 hi8 hh hold hnew hk8; split; first smt().
    split => [k' x *|k' x *].
    + by rewrite BArray512.get8_set64dE ifF 1:/#; apply hold; smt().
    rewrite BArray512.get8_set64dE; case: (k' = k{hr}) => [->|hne].
    + case: (8 * i{hr} <= x) => hx.
      + rewrite ifT 1:/# BArray128.get64d_byte 1:/#.
        by congr; ring.
      by rewrite ifF 1:/#; apply hold; smt().
    by rewrite ifF 1:/#; apply hnew; smt().
  auto => /> &hr hi0 _ hh hold hi8; split; first smt().
  move=> b1 k1 hk1 hk10 hk18 hold1 hnew1; split; first smt().
  by move=> k' x *; apply hnew1; smt().
auto => /> &hr hh; split; first smt().
move=> b1 i1 hi1 hi10 hi18 hall k hk0 hk8.
apply BArray128.tP => x hx; rewrite SBArray512_128.get8_get_sub hx /=.
by apply hall; smt().
qed.

lemma sha512_x4_from_ll : islossless M.__sha512_x4_from.
proof.
proc; while (0 <= i <= 16) (16 - i).
+ by move=> z; wp; while (0 <= k <= 4) (4 - k); auto => /#.
wp; while (0 <= j <= 8) (8 - j).
+ by move=> z; wp; while (0 <= k <= 4) (4 - k); auto => /#.
by auto => /#.
qed.

lemma sha512_x4_from_total (hs0 : BArray64.t) (bs0 : BArray128.t) :
  phoare [M.__sha512_x4_from :
           hs = hs0 /\ bs = bs0 ==>
           (forall k, 0 <= k < 4 => l4 res.`1 k = h512 hs0) /\
           (forall k, 0 <= k < 4 => sub4 res.`2 k = bs0)] = 1%r.
proof. by conseq sha512_x4_from_ll (sha512_x4_from_correct hs0 bs0). qed.

(* ------------------------------------------------------------------ *)
(* Padding and the digests                                            *)

(* Lane k's digest is bytes [64 k, 64 k + 64) of the output. *)
lemma out_lane4 (out : BArray256.t) (hv : W64.t list) k : 0 <= k < 4 => size hv = 8 =>
  (forall j, 0 <= j < 8 => BArray256.get64 out (8 * k + j) = WordSpec.bswap64 (nth W64.zero hv j)) =>
  lane_block 64 (BArray256.to_list out) k = flatten (map w64_be hv).
proof.
move=> hk hs hj.
have hsf := size_digest512 hv hs.
have hsl : size (lane_block 64 (BArray256.to_list out) k) = 64.
+ by apply size_lane_block; [done | smt() | rewrite BArray256.size_to_list /#].
apply (eq_from_nth W8.zero); first by rewrite hsl hsf.
move=> i; rewrite hsl => hi.
rewrite nth_lane_block // 1:/# BArray256.get_to_list (BitEncoding.BitChunking.nth_flatten _ 8).
+ by rewrite allP => x /mapP [y [_ ->]] /=; rewrite /w64_be size_rev W8u8.size_to_list.
rewrite (nth_map W64.zero) 1:/# -bswap64_be 1:/# -(hj (i %/ 8)) 1:/# BArray256.get64d_byte 1:/#.
by congr; smt(divz_eq).
qed.

(* The last block of a lane: what remains of its padded message. *)
lemma lane_last (h0 : W64.t list) (m : bytes) (hv hv1 : W64.t list) (b : bytes) :
  size (mfin 128 16 m) %% 128 <= 112 =>
  hv = foldl compress h0 (parse (mfin 128 16 m)) =>
  b = tail 128 (mfin 128 16 m) ++ zeros (112 - size (mfin 128 16 m) %% 128) ++ be_bytes 16 (8 * size m) =>
  hv1 = compress hv (map be64 (chunk 8 b)) =>
  hv1 = SHA512.hash h0 m.
proof.
move=> hs hh -> ->.
have hsy : size (tail 128 (mfin 128 16 m) ++ (zeros (112 - size (mfin 128 16 m) %% 128) ++ be_bytes 16 (8 * size m))) = 128.
+ by rewrite size_cat size_tail // size_cat size_zeros size_be_bytes; smt(modz_ge0).
have [hc _] := parse512_close (mfin 128 16 m) _ hsy.
rewrite hh /SHA512.hash pad512E padb_fin //.
by rewrite (_ : 128 - 16 - size (mfin 128 16 m) %% 128 = 112 - size (mfin 128 16 m) %% 128) 1:/# hc foldl_rcons -catA.
qed.

lemma sha512_x4_finalize_correct (h0 : W64.t list) (ms0 : int -> bytes) :
  hoare [M._sha512_x4_finalize :
           stream4 h0 ms0 h buf total /\ to_uint total < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res.`1) k = flatten (map w64_be (SHA512.hash h0 (ms0 k)))].
proof.
proc.
seq 5 : (to_uint fill = to_uint total %% 128 /\ at = fill /\ t = W64.of_int 128 /\ k = 0 /\
         stream4 h0 ms0 h buf total /\ to_uint total < 2^61).
+ by auto => /> &hr hs hl ht; rewrite and127.
seq 1 : (to_uint fill = to_uint total %% 128 /\ to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j) (rcons (tail 128 (ms0 j)) (W8.of_int 128)))).
+ while (0 <= k <= 4 /\ to_uint fill = to_uint total %% 128 /\ to_uint at = to_uint fill + 128 * k /\
         t = W64.of_int 128 /\ to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j)
            (if j < k then rcons (tail 128 (ms0 j)) (W8.of_int 128) else tail 128 (ms0 j)))).
  + auto => /> &hr hk0 _ hf hat ht hs hh hp hk8.
    have hr := modz_cmp (to_uint total{hr}) 128.
    split; first smt().
    split; first by rewrite W64.to_uintD_small hat /=; smt().
    move=> j hj0 hj1.
    have -> : to_uint at{hr} = 128 * k{hr} + to_uint total{hr} %% 128 by smt().
    rewrite sub4_set8 1,2,3:/# trunc_const //.
    case: (j = k{hr}) => [->|hne] /=.
    + have := hp k{hr} _; 1: smt().
      rewrite ifF 1:/# => hpk.
      have hst : size (tail 128 (ms0 k{hr})) = to_uint total{hr} %% 128.
      + by rewrite size_tail // (hs k{hr}) 1:/#.
      by rewrite ifT 1:/# -hst; apply pend512_set8; [rewrite hst /# | exact hpk].
    have := hp j _; 1: smt().
    by case: (j < k{hr}) => h; [rewrite ifT 1:/# | rewrite ifF 1:/#].
  auto => /> &hr hf hs hl ht; split.
  + split => j hj0 hj1; have hj : 0 <= j < 4 by done.
    + by have [hh _] := hl j hj.
    by have [_ hp] := hl j hj; rewrite ifF 1:/#.
  move=> a b k0 hk hk0 hk8 _ _ hp j hj0 hj1.
  by have := hp j _; [smt() | rewrite ifT 1:/#].
seq 2 : (to_uint fill = to_uint total %% 128 + 1 /\ two_blocks = (W64.of_int 112 \ult fill) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j) (rcons (tail 128 (ms0 j)) (W8.of_int 128)))).
+ auto => /> &hr hf ht hs hh hp.
  by rewrite W64.to_uintD_small hf /=; smt(modz_cmp).
seq 1 : ((forall j, 0 <= j < 4 => to_uint fill = size (mfin 128 16 (ms0 j)) %% 128) /\
         (forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j) (tail 128 (mfin 128 16 (ms0 j))))).
+ if.
  + wp; ecall (KX4.compress_correct h buf).
    while (0 <= k <= 4 /\ to_uint fill = to_uint total %% 128 + 1 /\ 112 < to_uint fill /\ hi = W64.of_int 128 /\
           to_uint total < 2^61 /\
           (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
           (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (ms0 j))) /\
           (forall j, 0 <= j < 4 => pend512 (sub4 buf j)
              (rcons (tail 128 (ms0 j)) (W8.of_int 128)
               ++ if j < k then zeros (128 - (to_uint total %% 128 + 1)) else []))).
    + wp; ecall (zero128_correct (sub4 buf k) fill hi); auto => /> &hr hk0 _ hf h56 ht hs hh hp hk8.
      have hr := modz_cmp (to_uint total{hr}) 128.
      split; first smt().
      move=> _ [b1 ms1] /= hb1; split; first smt().
      have := pend_step buf{hr} b1 (fun j => rcons (tail 128 (ms0 j)) (W8.of_int 128))
                (fun _ => zeros (128 - (to_uint total{hr} %% 128 + 1))) k{hr} _ hp _; 1: smt().
      + have hsr : size (rcons (tail 128 (ms0 k{hr})) (W8.of_int 128)) = to_uint total{hr} %% 128 + 1.
        + by rewrite size_rcons size_tail // (hs k{hr}) 1:/#.
        rewrite /= -hsr; apply (pend512_zero (sub4 buf{hr} k{hr})); 1: smt().
        + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
        by rewrite hsr -hf.
      by move=> h j hj0 hj1; apply h.
    auto => /> &hr hf ht hs hh hp h56.
    have h56' : 112 < to_uint fill{hr} by move: h56; rewrite W64.ultE.
    have hr := modz_cmp (to_uint total{hr}) 128.
    split.
    + split => // j hj0 hj1; rewrite ifF 1:/# cats0; apply hp => /#.
    move=> b k0 hk hk0 hk8 _ hpz [h1 ms1] /= hh1.
    rewrite /protect_64 /protect_ptr.
    have hmf : forall j, 0 <= j < 4 => mfin 128 16 (ms0 j)
               = ms0 j ++ ([W8.of_int 128] ++ zeros (128 - (to_uint total{hr} %% 128 + 1))).
    + move=> j hj; rewrite /mfin -(hs j hj) ifF 1:/# -catA.
      by rewrite (_ : 128 - 1 - to_uint total{hr} %% 128 = 128 - (to_uint total{hr} %% 128 + 1)) 1:/#.
    have hl : forall j, 0 <= j < 4 =>
                l4 h1 j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))
                /\ tail 128 (mfin 128 16 (ms0 j)) = [].
    + move=> j hj; rewrite hmf //; apply (lane_close h0 _ _ (l4 h{hr} j) _ (sub4 b j)).
      + by rewrite size_cat size_tail // -(hs j hj) size_cat size_zeros /=; smt().
      + exact (hh j hj).
      + have := hpz j hj; rewrite ifT 1:/#.
        by rewrite -cats1 -catA.
      by rewrite sub4_block // hh1.
    do !split.
    + by move=> j hj0 hj1; rewrite size_mfin // -(hs j _) 1:/# ifF 1:/#.
    + by move=> j hj0 hj1; rewrite size_mfin // -(hs j _) 1:/# ifF 1:/#.
    + by move=> j hj0 hj1; apply hs.
    + move=> j hj0 hj1; have hj : 0 <= j < 4 by done.
      by have [h2 _] := hl j hj; exact h2.
    move=> j hj0 hj1; have hj : 0 <= j < 4 by done.
    by have [_ ->] := hl j hj; exact pend512_nil.
  auto => /> &hr hf ht hs hh hp h55.
  have h55' : to_uint total{hr} %% 128 <= 111 by move: h55; rewrite W64.ultE hf /#.
  have hmf : forall j, 0 <= j < 4 => mfin 128 16 (ms0 j) = ms0 j ++ [W8.of_int 128].
  + by move=> j hj; rewrite /mfin -(hs j hj) ifT 1:/#.
  have hl : forall j, 0 <= j < 4 =>
              parse (mfin 128 16 (ms0 j)) = parse (ms0 j)
              /\ tail 128 (mfin 128 16 (ms0 j)) = tail 128 (ms0 j) ++ [W8.of_int 128].
  + move=> j hj; rewrite hmf //; apply parse512_short.
    by rewrite size_cat size_tail // -(hs j hj) /=; smt().
  do !split.
  + by move=> j hj0 hj1; rewrite size_mfin // -(hs j _) 1:/# ifT 1:/#.
  + by move=> j hj0 hj1; rewrite size_mfin // -(hs j _) 1:/# ifT 1:/#; smt().
  + move=> j hj0 hj1; have hj : 0 <= j < 4 by done.
    by have [-> _] := hl j hj; apply hh.
  move=> j hj0 hj1; have hj : 0 <= j < 4 by done.
  by have [_ ->] := hl j hj; rewrite cats1; apply hp.
seq 3 : ((forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j)
            (tail 128 (mfin 128 16 (ms0 j)) ++ zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)))).
+ while (0 <= k <= 4 /\ hi = W64.of_int 112 /\
         (forall j, 0 <= j < 4 => to_uint fill = size (mfin 128 16 (ms0 j)) %% 128) /\
         (forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j)
            (tail 128 (mfin 128 16 (ms0 j))
             ++ if j < k then zeros (112 - size (mfin 128 16 (ms0 j)) %% 128) else []))).
  + wp; ecall (zero128_correct (sub4 buf k) fill hi); auto => /> &hr hk0 _ hf h56 ht hs hh hp hk8.
    have hfk := hf k{hr} _; 1: smt().
    split; first by rewrite hfk; smt(modz_ge0).
    move=> _ [b1 ms1] /= hb1; split; first smt().
    have := pend_step buf{hr} b1 (fun j => tail 128 (mfin 128 16 (ms0 j)))
              (fun j => zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)) k{hr} _ hp _; 1: smt().
    + have hst : size (tail 128 (mfin 128 16 (ms0 k{hr}))) = size (mfin 128 16 (ms0 k{hr})) %% 128.
      + by rewrite size_tail.
      rewrite /= -hst; apply (pend512_zero (sub4 buf{hr} k{hr})); 1: smt(modz_ge0).
      + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
      by rewrite hst -hfk.
    by move=> h j hj0 hj1; apply h.
  auto => /> &hr hf h56 ht hs hh hp; split.
  + by move=> j hj0 hj1; rewrite ifF 1:/# cats0; apply hp => /#.
  move=> b k0 hk hk0 hk8 hpz j hj0 hj1.
  by have := hpz j _; [smt() | rewrite ifT 1:/#].
seq 7 : (k = 0 /\ t = WordSpec.bswap64 (total `>>` W8.of_int 61) /\
         u = WordSpec.bswap64 (total `<<` W8.of_int 3) /\
         (forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => pend512 (sub4 buf j)
            (tail 128 (mfin 128 16 (ms0 j)) ++ zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)))).
+ by wp; ecall (bswap64_spec u); wp; ecall (bswap64_spec t); auto.
seq 1 : ((forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => BArray128.to_list (sub4 buf j)
            = tail 128 (mfin 128 16 (ms0 j)) ++ zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)
              ++ be_bytes 8 (to_uint (total `>>` W8.of_int 61)) ++ be_bytes 8 (to_uint (total `<<` W8.of_int 3)))).
+ while (0 <= k <= 4 /\ t = WordSpec.bswap64 (total `>>` W8.of_int 61) /\
         u = WordSpec.bswap64 (total `<<` W8.of_int 3) /\
         (forall j, 0 <= j < 4 => size (mfin 128 16 (ms0 j)) %% 128 <= 112) /\
         to_uint total < 2^61 /\
         (forall j, 0 <= j < 4 => to_uint total = size (ms0 j)) /\
         (forall j, 0 <= j < 4 => l4 h j = foldl compress h0 (parse (mfin 128 16 (ms0 j)))) /\
         (forall j, 0 <= j < 4 => j < k => BArray128.to_list (sub4 buf j)
            = tail 128 (mfin 128 16 (ms0 j)) ++ zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)
              ++ be_bytes 8 (to_uint (total `>>` W8.of_int 61)) ++ be_bytes 8 (to_uint (total `<<` W8.of_int 3))) /\
         (forall j, 0 <= j < 4 => k <= j => pend512 (sub4 buf j)
            (tail 128 (mfin 128 16 (ms0 j)) ++ zeros (112 - size (mfin 128 16 (ms0 j)) %% 128)))).
  + auto => /> &hr hk0 _ h56 ht hs hh hd hp hk8; split; first smt().
    split => j hj0 hj1 hjk; rewrite (sub4_set64d _ j k{hr} 120) 1,2,3:/#.
    + case: (j = k{hr}) => [->|hne] /=.
      + rewrite (sub4_set64d _ k{hr} k{hr} 112) 1,2,3:/# /=.
        apply len_block512; first by apply hp => /#.
        by rewrite size_cat size_tail // size_zeros; smt(modz_ge0).
      by rewrite (sub4_set64d _ j k{hr} 112) 1,2,3:/# ifF 1:/#; apply hd => /#.
    by rewrite ifF 1:/# (sub4_set64d _ j k{hr} 112) 1,2,3:/# ifF 1:/#; apply hp => /#.
  auto => /> &hr h56 ht hs hh hp; split; first smt().
  move=> b k0 hk hk0 hk8 hd _ j hj0 hj1; apply hd; smt().
seq 3 : ((forall j, 0 <= j < 4 => l4 h j = SHA512.hash h0 (ms0 j))).
+ wp; ecall (KX4.compress_correct h buf); auto => /> &hr h56 ht hs hh hd [h1 ms1] /= hh1 j hj0 hj1.
  have hj : 0 <= j < 4 by done.
  apply (lane_last h0 (ms0 j) (l4 h{hr} j) _ (BArray128.to_list (sub4 buf{hr} j))); 1,2: smt().
  + by rewrite (hd j hj) -(hs j hj) len16E catA.
  by rewrite sub4_block // hh1.
while (0 <= k <= 4 /\ (forall j, 0 <= j < 4 => l4 h j = SHA512.hash h0 (ms0 j)) /\
       forall k' j', 0 <= k' < k => 0 <= j' < 8 =>
         BArray256.get64 out (8 * k' + j') = WordSpec.bswap64 (BArray256.get64 h (4 * j' + k'))).
+ wp; while (0 <= j <= 8 /\ 0 <= k < 4 /\ (forall j, 0 <= j < 4 => l4 h j = SHA512.hash h0 (ms0 j)) /\
             (forall k' j', 0 <= k' < k => 0 <= j' < 8 =>
                BArray256.get64 out (8 * k' + j') = WordSpec.bswap64 (BArray256.get64 h (4 * j' + k'))) /\
             forall j', 0 <= j' < j =>
                BArray256.get64 out (8 * k + j') = WordSpec.bswap64 (BArray256.get64 h (4 * j' + k))).
  + wp; ecall (bswap64_spec x); auto => /> &hr hj0 _ hk0 hk8 hh hold hnew hj8; split; first smt().
    split => [k' j' *|j' *].
    + by rewrite BArray256.get_set64E 1,2:/# ifF 1:/#; apply hold; smt().
    rewrite BArray256.get_set64E 1,2:/#.
    case: (j' = j{hr}) => hjj; first by rewrite ifT 1:/# hjj.
    by rewrite ifF 1:/#; apply hnew; smt().
  auto => /> &hr hk0 _ hh hold hk8; split; first smt().
  move=> o1 j1 hj1 hj10 hj18 hold1 hnew1; split; first smt().
  move=> k' j' *; case: (k' = k{hr}) => [->|hne]; first by apply hnew1; smt().
  by apply hold1; smt().
auto => /> &hr hh; split; first smt().
move=> o1 k1 hk1 hk10 hk18 hall k hk0 hk8.
rewrite -(hh k) 1:/#; apply out_lane4 => //; first exact size_lane.
by move=> j hj; rewrite nth_lane // hall 1,2:/#.
qed.

lemma sha512_x4_finalize_ll : islossless M._sha512_x4_finalize.
proof.
proc.
seq 8 : (to_uint fill <= 128 /\ two_blocks = (W64.of_int 112 \ult fill)) 1%r 1%r 0%r 0%r => //.
+ wp; while (to_uint fill < 128) (4 - k); first by move=> z; auto => /#.
  auto => /> &hr; rewrite and127; split; first smt(modz_cmp).
  move=> k0; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp).
+ seq 1 : (to_uint fill <= 112) 1%r 1%r 0%r 0%r => //.
  + if.
    + wp; call KX4.compress_ll; while (to_uint fill <= 128 /\ hi = W64.of_int 128) (4 - k).
      + by move=> z; wp; call zero128_ll; auto => /> *; smt().
      by auto => /#.
    by auto => /> &hr h64; rewrite W64.ultE /=; smt().
  + while (0 <= k <= 4) (4 - k).
    + move=> z; wp; while (0 <= j <= 8) (8 - j); first by move=> z'; wp; call SHA256_Stream.bswap64_ll; auto => /#.
      by auto => /#.
    wp; call KX4.compress_ll; while (true) (4 - k); first by move=> z; auto => /#.
    wp; call SHA256_Stream.bswap64_ll; wp; call SHA256_Stream.bswap64_ll; wp; while (to_uint fill <= 112 /\ hi = W64.of_int 112) (4 - k).
    + by move=> z; wp; call zero128_ll; auto => /> *; smt().
    by auto => /#.
  hoare; if.
  + by wp; call (: true) => //; while (true); auto; call (: true).
  by auto => /> &hr h64; rewrite W64.ultE /=; smt().
hoare; wp; while (to_uint fill < 128); first by auto.
auto => /> &hr; rewrite and127; split; first smt(modz_cmp).
move=> k0; rewrite W64.to_uintD_small and127 /=; smt(modz_cmp).
qed.

lemma sha512_x4_finalize_total (h0 : W64.t list) (ms0 : int -> bytes) :
  phoare [M._sha512_x4_finalize :
           stream4 h0 ms0 h buf total /\ to_uint total < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res.`1) k = flatten (map w64_be (SHA512.hash h0 (ms0 k)))] = 1%r.
proof. by conseq sha512_x4_finalize_ll (sha512_x4_finalize_correct h0 ms0). qed.

(* ------------------------------------------------------------------ *)
(* Four one-shot digests                                              *)

lemma stream4_nil h0 (h : BArray256.t) (buf : BArray512.t) :
  (forall k, 0 <= k < 4 => l4 h k = h0) => stream4 h0 (fun _ => []) h buf W64.zero.
proof.
move=> hh; split => // k hk /=; split; first by rewrite hh // /parse /= JWordList.chunk0.
by rewrite tail_short //; exact pend512_nil.
qed.

lemma sha512_x4_lanes_correct (in0 : BArray32.t) (l0 : W64.t) :
  hoare [M._sha512_x4_lanes :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res.`1) k
             = SHA512.sha512 (memread Glob.mem (ptr in0 k) (to_uint l0))].
proof.
proc.
ecall (sha512_x4_finalize_correct H0_512 (fun k => memread Glob.mem (ptr in0 k) (to_uint l0))).
wp; ecall (sha512_x4_absorb_correct H0_512 (fun _ => []) in0 l0).
wp; ecall (sha512_x4_init_correct).
auto => /> &hr hpl hl h1 hh1.
have [_ hs0] := stream4_nil H0_512 h1 witness<:BArray512.t> hh1.
split; first by split => //; smt(W64.to_uint_cmp).
move=> _ _ r hs _; split.
+ by rewrite (hs 0) // JWordList.size_memread //; smt(W64.to_uint_cmp).
by move=> _ o hr k hk0 hk1; rewrite /sha512 hr.
qed.

lemma sha512_x4_lanes_ll : islossless M._sha512_x4_lanes.
proof. by proc; call sha512_x4_finalize_ll; wp; call sha512_x4_absorb_ll; wp; call sha512_x4_init_ll; auto. qed.

lemma sha512_x4_lanes_total (in0 : BArray32.t) (l0 : W64.t) :
  phoare [M._sha512_x4_lanes :
           in_0 = in0 /\ len = l0 /\
           (forall q, 0 <= q < 4 => ptr in0 q + to_uint l0 < W64.modulus) /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res.`1) k
             = SHA512.sha512 (memread Glob.mem (ptr in0 k) (to_uint l0))] = 1%r.
proof. by conseq sha512_x4_lanes_ll (sha512_x4_lanes_correct in0 l0). qed.
