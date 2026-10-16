(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2X8Lanes.ec (aarch64/sha2)
 * =======================================
 *
 * Functional correctness, lane by lane, of _sha256_x8_compress_lanes of
 * the AArch64 SHA-256 instruction kernel (src/aarch64/sha2/
 * sha256_x8_compress.jinc, FEAT_SHA256): lane k absorbs the n blocks that
 * start at in[k] + off in memory, so it ends with the fold of compress
 * over them.
 *
 * The halves and the transposes are those of _sha256_x8_compress
 * (SHA256_A64Sha2X8.ec). Inside a half, pair r runs its n blocks to the
 * end before pair r + 1 starts; after j of them the two lanes of the pair
 * hold the fold over their first j blocks (pairat), and the other pairs
 * are untouched (others).
 *
 * Domain: for every lane k < 8, in[k] + off + 64 n < 2^64, so no lane's
 * buffer wraps the address space.
 *
 * Theorems:
 *     sha256_x8_compress_lanes_correct  lane k of the result is the fold
 *                                       of compress over lane k's blocks
 *                                       (partial correctness);
 *     sha256_x8_compress_lanes_total    the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Sha2Insn Lanes.
require import SHA256_A64Sha2 SHA256_A64Sha2Blocks SHA256_A64Sha2X8Block SHA256_A64Sha2X8.
require JWordList.
import SHA256 A256.

(* ------------------------------------------------------------------ *)
(* Lanes over memory                                                  *)

(* Start of lane k's blocks. *)
op addr (P : BArray64.t) (o : W64.t) (k : int) : int = W64.to_uint (BArray64.get64 P k + o).

(* Lane k after its first j blocks. *)
op Fo (H : BArray256.t) mem (P : BArray64.t) (o : W64.t) (k j : int) : W32.t list =
  foldl compress (lane8 (BArray256.get32 H) k)
        (parse (JWordList.memread mem (addr P o k) (64 * j))).

op RL (H : BArray256.t) mem (P : BArray64.t) (o n : W64.t) : int -> W32.t list =
  fun k => Fo H mem P o k (W64.to_uint n).

lemma size_Fo H mem P o k j : size (Fo H mem P o k j) = 8.
proof. by rewrite /Fo size_foldl_compress // size_lane. qed.

lemma Fo0 H mem P o k : Fo H mem P o k 0 = lane8 (BArray256.get32 H) k.
proof. by rewrite /Fo /= (_ : parse [] = []) // /parse /chunk /= mkseq0. qed.

lemma FoS H mem P o k j : 0 <= j =>
  compress (Fo H mem P o k j) (blockwords (JWordList.memread mem (addr P o k + 64 * j) 64))
  = Fo H mem P o k (j + 1).
proof. by move=> hj; rewrite /Fo parse_memreadS // foldl_rcons. qed.

(* The states and schedules of the two lanes of pair r of half f, after j
   blocks, the next blocks at a0 and a1. *)
op SL (H : BArray256.t) mem (P : BArray64.t) (o : W64.t) (f r j : int) : int -> state =
  fun l => to_state (Fo H mem P o (4 * f + (2 * r + l)) j).

op WL mem (a0 a1 : int) : int -> W32.t list =
  fun l => schedule (blockwords (JWordList.memread mem (if l = 0 then a0 else a1) 64)).

lemma sha256_x8_block2_mem (S : int -> state) mem (a0 a1 : int) (st0 : BArray128.t) (r0 : int) :
  hoare [M.__sha256_x8_block2 :
           st = st0 /\ r = r0 /\ 0 <= r0 < 2 /\ k = sHA256_K /\
           (forall l, 0 <= l < 2 =>
              lane_st S (WL mem a0 a1) st0 r0 l 0 /\ lane_win (WL mem a0 a1) m l 0) ==>
           (forall l, 0 <= l < 2 => lane_fin S (WL mem a0 a1) res.`1 r0 l) /\
           frame st0 res.`1 r0].
proof.
apply (sha256_x8_block2_correct S (WL mem a0 a1) st0 r0).
move=> l hl t ht; rewrite /WL /= /srec nth_schedule_hi //.
by rewrite size_blockwords // size_memread.
qed.

(* Pair r of half f after j blocks. *)
op pairat (st : BArray128.t) (H : BArray256.t) mem (P : BArray64.t) (o : W64.t) (f r j : int) =
  forall l, 0 <= l < 2 =>
    BArray128.get128 st (4 * r + 2 * l) = q4 (Fo H mem P o (4 * f + (2 * r + l)) j) 0 /\
    BArray128.get128 st (4 * r + 2 * l + 1) = q4 (Fo H mem P o (4 * f + (2 * r + l)) j) 1.

(* The pairs of half f other than r. *)
op others (st : BArray128.t) (H : BArray256.t) (Rf : int -> W32.t list) (f r : int) =
  forall l q, 0 <= l < 4 => 0 <= q < 2 => l %/ 2 <> r =>
    BArray128.get128 st (2 * l + q)
    = q4 (if l %/ 2 < r then Rf (4 * f + l) else lane8 (BArray256.get32 H) (4 * f + l)) q.

lemma rinv_split st H mem P o Rf f r : 0 <= r < 2 => rinv st H Rf f r =>
  others st H Rf f r /\ pairat st H mem P o f r 0.
proof.
move=> hr hst; split.
+ by move=> l q hl hq hne; apply hst.
move=> l hl; rewrite !Fo0.
have e0 := hst (2 * r + l) 0 _ _; 1,2: smt().
have e1 := hst (2 * r + l) 1 _ _; 1,2: smt().
move: e0 e1; rewrite (_ : (2 * r + l) %/ 2 < r <=> false) 1:/# /=.
by rewrite (_ : 2 * (2 * r + l) = 4 * r + 2 * l) 1:/# => -> ->.
qed.

lemma rinv_join st H mem P o n f r : 0 <= r < 2 =>
  others st H (RL H mem P o n) f r => pairat st H mem P o f r (W64.to_uint n) =>
  rinv st H (RL H mem P o n) f (r + 1).
proof.
move=> hr ho hp l q hl hq.
case: (l %/ 2 = r) => hlr.
+ rewrite ifT 1:/#.
  have [l0 [hl0 ->>]] : exists l0, 0 <= l0 < 2 /\ l = 2 * r + l0 by exists (l %% 2); smt().
  have [ea ee] := hp l0 hl0.
  have : q = 0 \/ q = 1 by smt().
  case=> ->> /=.
  + by rewrite (_ : 2 * (2 * r + l0) = 4 * r + 2 * l0) 1:/# ea /RL.
  by rewrite (_ : 2 * (2 * r + l0) + 1 = 4 * r + 2 * l0 + 1) 1:/# ee /RL.
rewrite ho //.
by rewrite (_ : (l %/ 2 < r + 1) = (l %/ 2 < r)) 1:/#.
qed.

(* One block of pair r. *)
lemma pair_step st st' H mem P o Rf f r j : 0 <= r < 2 => 0 <= j =>
  others st H Rf f r =>
  (forall l, 0 <= l < 2 =>
     lane_fin (SL H mem P o f r j)
              (WL mem (addr P o (4 * f + 2 * r) + 64 * j) (addr P o (4 * f + 2 * r + 1) + 64 * j))
              st' r l) =>
  frame st st' r =>
  others st' H Rf f r /\ pairat st' H mem P o f r (j + 1).
proof.
move=> hr hj ho hfin hfr; split.
+ move=> l q hl hq hne; rewrite hfr 1:/#.
  exact ho.
move=> l hl.
have [ea ee] := hfin l hl.
have [sa se] := st_step (Fo H mem P o (4 * f + (2 * r + l)) j)
                  (blockwords (JWordList.memread mem (addr P o (4 * f + (2 * r + l)) + 64 * j) 64))
                  (size_Fo H mem P o _ j).
move: ea ee; rewrite /SL /WL /=.
have -> : (if l = 0 then addr P o (4 * f + 2 * r) + 64 * j
           else addr P o (4 * f + 2 * r + 1) + 64 * j)
          = addr P o (4 * f + (2 * r + l)) + 64 * j.
+ have : l = 0 \/ l = 1 by smt().
  by case=> ->> //=; rewrite addzA.
by rewrite sa se FoS // !q4_a !q4_e.
qed.

lemma next_lt (a x n c M : int) : x = a + 64 * (n - c) => 0 < c => a + 64 * n < M =>
  x + 64 < M.
proof. smt(). qed.

(* No lane's buffer wraps the address space. *)
op bnd (P : BArray64.t) (o n : W64.t) =
  forall k, 0 <= k < 8 => addr P o k + 64 * W64.to_uint n < W64.modulus.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on eight lanes of blocks in memory          *)

lemma sha256_x8_compress_lanes_correct (H : BArray256.t) (P : BArray64.t) (o n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
           h8 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd P o n0 ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray64.get64 P k + o)) (64 * W64.to_uint n0)))].
proof.
proc.
wp.
while (0 <= f <= 2 /\ k = sHA256_K /\ in_0 = P /\ off = o /\ n = n0 /\ bnd P o n0 /\
       hfin h8 H (RL H Glob.mem P o n0) f).
+ wp; ecall (sha256_x8_store_half_correct h8 st f).
  while (0 <= r <= 2 /\ 0 <= f < 2 /\ k = sHA256_K /\ in_0 = P /\ off = o /\ n = n0 /\
         bnd P o n0 /\ hfin h8 H (RL H Glob.mem P o n0) f /\
         rinv st H (RL H Glob.mem P o n0) f r).
  + wp.
    while (0 <= r < 2 /\ 0 <= f < 2 /\ k = sHA256_K /\ in_0 = P /\ off = o /\ n = n0 /\
           bnd P o n0 /\ hfin h8 H (RL H Glob.mem P o n0) f /\
           more = (c <> W64.zero) /\ W64.to_uint c <= W64.to_uint n0 /\
           W64.to_uint p = addr P o (4 * f + 2 * r) + 64 * (W64.to_uint n0 - W64.to_uint c) /\
           W64.to_uint q = addr P o (4 * f + 2 * r + 1) + 64 * (W64.to_uint n0 - W64.to_uint c) /\
           others st H (RL H Glob.mem P o n0) f r /\
           pairat st H Glob.mem P o f r (W64.to_uint n0 - W64.to_uint c)).
    + wp.
      ecall (sha256_x8_block2_mem (SL H Glob.mem P o f r (W64.to_uint n0 - W64.to_uint c))
               Glob.mem (W64.to_uint p) (W64.to_uint q) st r).
      while (0 <= r < 2 /\ 0 <= f < 2 /\ k = sHA256_K /\ in_0 = P /\ off = o /\ n = n0 /\
             bnd P o n0 /\ hfin h8 H (RL H Glob.mem P o n0) f /\
             more = (c <> W64.zero) /\ c <> W64.zero /\ W64.to_uint c <= W64.to_uint n0 /\
             W64.to_uint p = addr P o (4 * f + 2 * r) + 64 * (W64.to_uint n0 - W64.to_uint c) /\
             W64.to_uint q = addr P o (4 * f + 2 * r + 1) + 64 * (W64.to_uint n0 - W64.to_uint c) /\
             others st H (RL H Glob.mem P o n0) f r /\
             pairat st H Glob.mem P o f r (W64.to_uint n0 - W64.to_uint c) /\
             0 <= i <= 4 /\
             forall i', 0 <= i' < i =>
               BArray128.get128 m i' = VREV32_16u8 (loadW128 Glob.mem (W64.to_uint p + 16 * i')) /\
               BArray128.get128 m (4 + i') = VREV32_16u8 (loadW128 Glob.mem (W64.to_uint q + 16 * i'))).
      + wp; skip => /> &hr hr0 hr2 hf0 hf2 hb hh hc hcn hp hq ho hpa hi0 _ hm hi4.
        have hcp := nz_pos c{hr} hc.
        have hb0 := hb (4 * f{hr} + 2 * r{hr}) _; 1: smt().
        have hb1 := hb (4 * f{hr} + 2 * r{hr} + 1) _; 1: smt().
        have hp64 := ltrW _ _ (next_lt _ _ _ _ _ hp hcp hb0).
        have hq64 := ltrW _ _ (next_lt _ _ _ _ _ hq hcp hb1).
        rewrite (uint_add16 p{hr} i{hr} _ hp64) 1:/# (uint_add16 q{hr} i{hr} _ hq64) 1:/#.
        split; first smt().
        move=> i' hi'0 hi'1.
        have /= [e0 e1] := mfill m{hr} i{hr} i'
          (loadW128 Glob.mem{hr} (W64.to_uint p{hr} + 16 * i{hr}))
          (loadW128 Glob.mem{hr} (W64.to_uint q{hr} + 16 * i{hr})) _ _; 1,2: smt().
        rewrite e0 e1; case: (i' = i{hr}) => [->> //|ne].
        by apply hm => /#.
      wp; skip => /> &hr hr0 hr2 hf0 hf2 hb hh hcn hp hq ho hpa hc.
      split; first smt().
      move=> i0 m0 hi hi0 hi4 hm.
      have ->> : i0 = 4 by smt().
      have hcp := nz_pos c{hr} hc.
      have hj : 0 <= W64.to_uint n0 - W64.to_uint c{hr} by smt().
      have hb0 := hb (4 * f{hr} + 2 * r{hr}) _; 1: smt().
      have hb1 := hb (4 * f{hr} + 2 * r{hr} + 1) _; 1: smt().
      have hpl := next_lt _ _ _ _ _ hp hcp hb0.
      have hql := next_lt _ _ _ _ _ hq hcp hb1.
      split.
      + move=> l hl0 hl2; split.
        + rewrite /SL /= !rounds_nil // q4_a q4_e.
          by have [-> ->] := hpa l _; 1: smt().
        rewrite /lane_win => j' hj'; rewrite wg0 // /WL /=.
        have [e0 e1] := hm j' hj'.
        have : l = 0 \/ l = 1 by smt().
        case=> ->> /=.
        + by rewrite e0 vrev_load.
        by rewrite e1 vrev_load.
      move=> _ o2 hfin hfr.
      have hsub := uint_sub1 c{hr} hc.
      rewrite hsub (uint_add64 p{hr} hpl) (uint_add64 q{hr} hql).
      have [ho' hpa'] := pair_step st{hr} o2.`1 H Glob.mem{hr} P o (RL H Glob.mem{hr} P o n0)
                           f{hr} r{hr} (W64.to_uint n0 - W64.to_uint c{hr}) _ hj ho _ hfr.
      + smt().
      + by rewrite -hp -hq.
      rewrite (_ : W64.to_uint n0 - (W64.to_uint c{hr} - 1)
                 = W64.to_uint n0 - W64.to_uint c{hr} + 1) 1:/#.
      do! split => //; smt().
    wp; skip => /> &hr hr0 hr2 hf0 hf2 hb hh hrv hr.
    split.
    + by apply (rinv_split st{hr} H Glob.mem{hr} P o (RL H Glob.mem{hr} P o n0) f{hr} r{hr});
        [smt() | exact hrv].
    move=> c0 more0 p0 q0 st0 hm hc hcn hp hq ho hpa.
    have hc0 : c0 = W64.zero by smt().
    move: hpa; rewrite hc0 W64.to_uint0 /= => hpa.
    split; first smt().
    by apply (rinv_join st0 H Glob.mem{hr} P o n0 f{hr} r{hr}) => //; smt().
  wp; ecall (sha256_x8_load_half_correct h8 f); skip => />.
  move=> &hr hf0 hf2 hb hh hf st1 hst1.
  have hfr : 0 <= f{hr} < 2 by smt().
  split.
  + apply (rinv0 st1 H (RL H Glob.mem{hr} P o n0) f{hr} hfr) => q hq.
    by rewrite hst1 // (hfin_half h8{hr} H (RL H Glob.mem{hr} P o n0) f{hr} hfr hh q hq).
  move=> r0 st0 hr hr0 hr2 hrv h' hn ho.
  have ->> : r0 = 2 by smt().
  split; first smt().
  apply (hfin_step h8{hr} h' H (RL H Glob.mem{hr} P o n0) f{hr} hfr hh _ ho) => q hq.
  have e0 := hrv 0 q _ hq; 1: done.
  have e1 := hrv 1 q _ hq; 1: done.
  have e2 := hrv 2 q _ hq; 1: done.
  have e3 := hrv 3 q _ hq; 1: done.
  move: e0 e1 e2 e3; rewrite /= => e0 e1 e2 e3.
  by rewrite hn // /tq /= e0 e1 e2 e3.
wp; skip => /> &hr hb.
split; first exact hfin0.
move=> f0 h80 hf hf0 hf2 hh k0 hk0 hk8.
have ->> : f0 = 2 by smt().
have hs : forall k, 0 <= k < 8 => size (RL H Glob.mem{hr} P o n0 k) = 8.
+ by move=> k hk; rewrite /RL /= size_Fo.
by rewrite (hfin_lanes h80 H (RL H Glob.mem{hr} P o n0) hs hh k0 _) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha256_x8_compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof.
proc; wp; while (0 <= f <= 2) (2 - f).
+ move=> z; wp; call sha256_x8_store_half_ll.
  while (0 <= r <= 2) (2 - r).
  + move=> z'; wp.
    while (more = (c <> W64.zero)) (W64.to_uint c).
    + move=> z2; wp; call sha256_x8_block2_ll.
      while (0 <= i <= 4) (4 - i); first by auto => /#.
      auto => /> &m hc i0; split; first smt().
      by move=> _ _ _; rewrite uint_sub1 //; smt().
    auto => /> &m hr0 hr2 hr.
    by move=> c0; rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
  by wp; call sha256_x8_load_half_ll; auto => /#.
by auto => /#.
qed.

lemma sha256_x8_compress_lanes_total (H : BArray256.t) (P : BArray64.t) (o n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
           h8 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd P o n0 ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray64.get64 P k + o)) (64 * W64.to_uint n0)))] = 1%r.
proof. by conseq sha256_x8_compress_lanes_ll (sha256_x8_compress_lanes_correct H P o n0). qed.
