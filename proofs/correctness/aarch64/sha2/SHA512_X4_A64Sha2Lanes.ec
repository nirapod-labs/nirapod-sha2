(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4_A64Sha2Lanes.ec (aarch64/sha2)
 * =======================================
 *
 * Functional correctness, lane by lane, of _sha512_x4_compress_lanes of
 * the AArch64 SHA-512 instruction kernel (src/aarch64/sha2/
 * sha512_x4_compress.jinc, FEAT_SHA512): lane k absorbs the n blocks that
 * start at in[k] + off in memory, so it ends with the fold of compress
 * over them.
 *
 * The transposes are those of _sha512_x4_compress (SHA512_X4_A64Sha2.ec).
 * Pair i runs its n blocks to the end before pair i + 1 starts; after j of
 * them its two lanes hold the fold over their first j blocks.
 *
 * Domain: for every lane k < 4, in[k] + off + 128 n < 2^64, so no lane's
 * buffer wraps the address space.
 *
 * Theorems:
 *     sha512_x4_compress_lanes_correct  lane k of the result is the fold
 *                                       of compress over lane k's blocks
 *                                       (partial correctness);
 *     sha512_x4_compress_lanes_total    the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray128 BArray160 BArray256 BArray512 BArray640.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds512 Vec Sha2Insn Lanes.
require import SHA512_A64Sha2 SHA512_A64Sha2Blocks SHA512_X4_A64Sha2Block SHA512_X4_A64Sha2.
require JWordList.
import SHA512 A512.

(* ------------------------------------------------------------------ *)
(* Lanes over memory                                                  *)

(* Start of lane k's blocks. *)
op addr4 (P : BArray32.t) (o : W64.t) (k : int) : int = W64.to_uint (BArray32.get64 P k + o).

(* Lane k after its first j blocks. *)
op Fo4 (H : BArray256.t) mem (P : BArray32.t) (o : W64.t) (k j : int) : W64.t list =
  foldl compress (lane4 (BArray256.get64 H) k)
        (parse (JWordList.memread mem (addr4 P o k) (128 * j))).

op RL4 (H : BArray256.t) mem (P : BArray32.t) (o n : W64.t) : int -> W64.t list =
  fun k => Fo4 H mem P o k (W64.to_uint n).

lemma size_Fo4 H mem P o k j : size (Fo4 H mem P o k j) = 8.
proof. by rewrite /Fo4 size_foldl_compress // size_lane. qed.

lemma Fo4_0 H mem P o k : Fo4 H mem P o k 0 = lane4 (BArray256.get64 H) k.
proof. by rewrite /Fo4 /= (_ : parse [] = []) // /parse /chunk /= mkseq0. qed.

lemma Fo4S H mem P o k j : 0 <= j =>
  compress (Fo4 H mem P o k j) (blockwords (JWordList.memread mem (addr4 P o k + 128 * j) 128))
  = Fo4 H mem P o k (j + 1).
proof. by move=> hj; rewrite /Fo4 parse_memreadS // foldl_rcons. qed.

(* The states and schedules of lanes 2i, 2i + 1 after j blocks, the next
   blocks at a0 and a1. *)
op SL4 (H : BArray256.t) mem (P : BArray32.t) (o : W64.t) (i j : int) : int -> state =
  fun l => to_state (Fo4 H mem P o (2 * i + l) j).

op WL4 mem (a0 a1 : int) : int -> W64.t list =
  fun l => schedule (blockwords (JWordList.memread mem (if l = 0 then a0 else a1) 128)).

lemma sha512_x4_block2_mem (S : int -> state) mem (a0 a1 : int) :
  hoare [M.__sha512_x4_block2 :
           k = sHA512_K /\
           (forall l, 0 <= l < 2 =>
              (forall j, 0 <= j < 4 => BArray160.get128 s (5 * l + j) = spair (S l) j) /\
              (forall j, 0 <= j < 8 =>
                 BArray256.get128 m (8 * l + j) = wv2 (WL4 mem a0 a1 l) (2 * j))) ==>
           forall l, 0 <= l < 2 => forall j, 0 <= j < 4 =>
             BArray160.get128 res.`1 (5 * l + j)
             = VADD_2u64 (spair (rounds (WL4 mem a0 a1 l) (S l) 0 80) j) (spair (S l) j)].
proof.
apply (sha512_x4_block2_correct S (WL4 mem a0 a1)).
move=> l hl t ht; rewrite /WL4 /= /srec nth_schedule_hi //.
by rewrite size_blockwords // size_memread.
qed.

(* Lanes 2i, 2i + 1 after j blocks. *)
op pairat4 (s : BArray160.t) (H : BArray256.t) mem (P : BArray32.t) (o : W64.t) (i j : int) =
  forall l j', 0 <= l < 2 => 0 <= j' < 4 =>
    BArray160.get128 s (5 * l + j') = spair (SL4 H mem P o i j l) j'.

(* One block of the pair. *)
lemma pair4_step (s' : BArray160.t) H mem P o i j : 0 <= j =>
  (forall l, 0 <= l < 2 => forall j', 0 <= j' < 4 =>
     BArray160.get128 s' (5 * l + j')
     = VADD_2u64 (spair (rounds (WL4 mem (addr4 P o (2 * i) + 128 * j)
                                       (addr4 P o (2 * i + 1) + 128 * j) l)
                               (SL4 H mem P o i j l) 0 80) j')
                 (spair (SL4 H mem P o i j l) j')) =>
  pairat4 s' H mem P o i (j + 1).
proof.
move=> hj hfin l j' hl hj'.
rewrite hfin // /SL4 /WL4 /= st_step ?size_Fo4 1,2:/#.
+ smt().
have -> : (if l = 0 then addr4 P o (2 * i) + 128 * j else addr4 P o (2 * i + 1) + 128 * j)
          = addr4 P o (2 * i + l) + 128 * j.
+ by have := x4_range2 l hl; case=> ->> //=.
by rewrite Fo4S.
qed.

lemma next_lt4 (a x n c M : int) : x = a + 128 * (n - c) => 0 < c => a + 128 * n < M =>
  x + 128 < M.
proof. smt(). qed.

(* No lane's buffer wraps the address space. *)
op bnd4 (P : BArray32.t) (o n : W64.t) =
  forall k, 0 <= k < 4 => addr4 P o k + 128 * W64.to_uint n < W64.modulus.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on four lanes of blocks in memory           *)

lemma sha512_x4_compress_lanes_correct (H : BArray256.t) (P : BArray32.t) (o n0 : W64.t) :
  hoare [M._sha512_x4_compress_lanes :
           h4 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd4 P o n0 ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = foldl compress (lane4 (BArray256.get64 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray32.get64 P k + o)) (128 * W64.to_uint n0)))].
proof.
proc.
wp.
while (0 <= i <= 2 /\ k = sHA512_K /\ in_0 = P /\ off = o /\ n = n0 /\ bnd4 P o n0 /\
       hfin4 h4 H (RL4 H Glob.mem P o n0) i).
+ wp; ecall (sha512_x4_store_pair_correct h4 s i).
  wp.
  while (0 <= i < 2 /\ k = sHA512_K /\ in_0 = P /\ off = o /\ n = n0 /\ bnd4 P o n0 /\
         hfin4 h4 H (RL4 H Glob.mem P o n0) i /\
         more = (c <> W64.zero) /\ W64.to_uint c <= W64.to_uint n0 /\
         W64.to_uint p = addr4 P o (2 * i) + 128 * (W64.to_uint n0 - W64.to_uint c) /\
         W64.to_uint q = addr4 P o (2 * i + 1) + 128 * (W64.to_uint n0 - W64.to_uint c) /\
         pairat4 s H Glob.mem P o i (W64.to_uint n0 - W64.to_uint c)).
  + wp.
    ecall (sha512_x4_block2_mem (SL4 H Glob.mem P o i (W64.to_uint n0 - W64.to_uint c))
             Glob.mem (W64.to_uint p) (W64.to_uint q)).
    while (0 <= i < 2 /\ k = sHA512_K /\ in_0 = P /\ off = o /\ n = n0 /\ bnd4 P o n0 /\
           hfin4 h4 H (RL4 H Glob.mem P o n0) i /\
           more = (c <> W64.zero) /\ c <> W64.zero /\ W64.to_uint c <= W64.to_uint n0 /\
           W64.to_uint p = addr4 P o (2 * i) + 128 * (W64.to_uint n0 - W64.to_uint c) /\
           W64.to_uint q = addr4 P o (2 * i + 1) + 128 * (W64.to_uint n0 - W64.to_uint c) /\
           pairat4 s H Glob.mem P o i (W64.to_uint n0 - W64.to_uint c) /\
           0 <= j <= 8 /\
           forall j', 0 <= j' < j =>
             BArray256.get128 m j' = VREV64_16u8 (loadW128 Glob.mem (W64.to_uint p + 16 * j')) /\
             BArray256.get128 m (8 + j') = VREV64_16u8 (loadW128 Glob.mem (W64.to_uint q + 16 * j'))).
    + wp; skip => /> &hr hi0 hi2 hb hh hc hcn hp hq hpa hj0 _ hm hj8.
      have hcp := nz_pos c{hr} hc.
      have hb0 := hb (2 * i{hr}) _; 1: smt().
      have hb1 := hb (2 * i{hr} + 1) _; 1: smt().
      have hp64 := ltrW _ _ (next_lt4 _ _ _ _ _ hp hcp hb0).
      have hq64 := ltrW _ _ (next_lt4 _ _ _ _ _ hq hcp hb1).
      rewrite (uint_add16 p{hr} j{hr} _ hp64) 1:/# (uint_add16 q{hr} j{hr} _ hq64) 1:/#.
      split; first smt().
      move=> j' hj'0 hj'1.
      have /= [e0 e1] := mfill4 m{hr} j{hr} j'
        (loadW128 Glob.mem{hr} (W64.to_uint p{hr} + 16 * j{hr}))
        (loadW128 Glob.mem{hr} (W64.to_uint q{hr} + 16 * j{hr})) _ _; 1,2: smt().
      rewrite e0 e1; case: (j' = j{hr}) => [->> //|ne].
      by apply hm => /#.
    wp; skip => /> &hr hi0 hi2 hb hh hcn hp hq hpa hc.
    split; first smt().
    move=> j0 m0 hjl hj0 hj8 hm.
    have ->> : j0 = 8 by smt().
    have hcp := nz_pos c{hr} hc.
    have hj : 0 <= W64.to_uint n0 - W64.to_uint c{hr} by smt().
    have hb0 := hb (2 * i{hr}) _; 1: smt().
    have hb1 := hb (2 * i{hr} + 1) _; 1: smt().
    have hpl := next_lt4 _ _ _ _ _ hp hcp hb0.
    have hql := next_lt4 _ _ _ _ _ hq hcp hb1.
    split.
    + move=> l hl0 hl2; split; first by move=> j1 h0 h1; apply hpa => /#.
      move=> j1 h0 h1; rewrite /WL4 /=.
      have [e0 e1] := hm j1 _; 1: smt().
      have := x4_range2 l _; 1: smt().
      case=> ->> /=.
      + by rewrite e0 vrev_load.
      by rewrite e1 vrev_load.
    move=> _ o2 hfin.
    have hsub := uint_sub1 c{hr} hc.
    rewrite hsub (uint_add128 p{hr} hpl) (uint_add128 q{hr} hql).
    have hpa' := pair4_step o2.`1 H Glob.mem{hr} P o i{hr} (W64.to_uint n0 - W64.to_uint c{hr}) hj _.
    + by rewrite -hp -hq.
    rewrite (_ : W64.to_uint n0 - (W64.to_uint c{hr} - 1)
               = W64.to_uint n0 - W64.to_uint c{hr} + 1) 1:/#.
    do! split => //; smt().
  wp; ecall (sha512_x4_load_pair_correct h4 i); skip => />.
  move=> &hr hi0 hi2 hb hh hi s1 hs1.
  have hir : 0 <= i{hr} < 2 by smt().
  split.
  + move=> l j' hl hj'; rewrite /SL4 /= Fo4_0.
    by have := pair_pre s1 h4{hr} H (RL4 H Glob.mem{hr} P o n0) i{hr} hir hh hs1 l j' hl hj'.
  move=> c0 more0 p0 q0 s0 hm hc hcn hp hq hpa h' hn ho.
  have hc0 : c0 = W64.zero by smt().
  move: hpa; rewrite hc0 W64.to_uint0 /= => hpa.
  split; first smt().
  apply (hfin4_step h4{hr} h' H (RL4 H Glob.mem{hr} P o n0) i{hr} hir hh _ ho) => q1 hq1.
  have ea := hpa 0 q1 _ hq1; 1: done.
  have eb := hpa 1 q1 _ hq1; 1: done.
  move: ea eb; rewrite /SL4 /= => ea eb.
  have [sa sb] := store_lanes (Fo4 H Glob.mem{hr} P o (2 * i{hr}) (W64.to_uint n0))
                    (Fo4 H Glob.mem{hr} P o (2 * i{hr} + 1) (W64.to_uint n0)) q1 hq1.
  by have [-> ->] := hn q1 hq1; rewrite ea eb sa sb /RL4.
wp; skip => /> &hr hb.
split; first exact hfin4_0.
move=> h40 i0 hi hi0 hi2 hh k0 hk0 hk4.
have ->> : i0 = 2 by smt().
have hs : forall k, 0 <= k < 4 => size (RL4 H Glob.mem{hr} P o n0 k) = 8.
+ by move=> k hk; rewrite /RL4 /= size_Fo4.
by rewrite (hfin4_lanes h40 H (RL4 H Glob.mem{hr} P o n0) hs hh k0 _) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha512_x4_compress_lanes_ll : islossless M._sha512_x4_compress_lanes.
proof.
proc; wp; while (0 <= i <= 2) (2 - i).
+ move=> z; wp; call sha512_x4_store_pair_ll.
  wp; while (more = (c <> W64.zero)) (W64.to_uint c).
  + move=> z2; wp; call sha512_x4_block2_ll.
    while (0 <= j <= 8) (8 - j); first by auto => /#.
    auto => /> &m hc j0; split; first smt().
    by move=> _ _ _; rewrite uint_sub1 //; smt().
  wp; call sha512_x4_load_pair_ll; auto => /> &m hi0 hi2 hi.
  by move=> c0; rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
by auto => /#.
qed.

lemma sha512_x4_compress_lanes_total (H : BArray256.t) (P : BArray32.t) (o n0 : W64.t) :
  phoare [M._sha512_x4_compress_lanes :
           h4 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd4 P o n0 ==>
           forall k, 0 <= k < 4 =>
             lane4 (BArray256.get64 res.`1) k
             = foldl compress (lane4 (BArray256.get64 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray32.get64 P k + o)) (128 * W64.to_uint n0)))] = 1%r.
proof. by conseq sha512_x4_compress_lanes_ll (sha512_x4_compress_lanes_correct H P o n0). qed.
