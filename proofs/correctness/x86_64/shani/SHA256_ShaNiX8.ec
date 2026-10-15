(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNiX8.ec
 * =================
 *
 * Functional correctness of the 8-way SHA-256 kernel on the x86 SHA
 * extensions (src/x86_64/shani/sha256_x8_compress.jinc) against FIPS
 * 180-4 section 6.2.2 as spec/FIPS180_SHA2.ec writes it, lane by lane,
 * for its two entry points:
 *
 *   x8_compress_total        _sha256_x8_compress, one block per lane from
 *                            an array of the eight blocks end to end
 *   x8_compress_lanes_total  _sha256_x8_compress_lanes, n blocks per lane
 *                            from lane memory, folded as the parse of
 *                            section 5.2.1 of those bytes
 *
 * with the statements of the portable 8-way kernel's proofs. All are
 * total correctness, from a hoare proof and a losslessness proof.
 *
 * Structure. The kernel runs the four pairs of lanes (4f + 2r,
 * 4f + 2r + 1) in turn: load the pair (SHA256_ShaNiX8Pair.load_pair_spec),
 * its blocks (SHA256_ShaNiX8Block.block2_correct), store the pair
 * (store_pair_spec). Before pair p = 2f + r, lanes below 2p hold their
 * result and the others their input.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Arrays SpecRounds ShaNi Mem Lanes.
require import SHA256_ShaNiX8Pair SHA256_ShaNiX8Block.
require JWordList SHA256_ShaNi.
import SHA256 R256.

clone Arrays.ArrayLanes as L512 with theory A <- BArray512.

(* ------------------------------------------------------------------ *)
(* The message words of lane k's block                                *)

abbrev mlane (blk : BArray512.t) (k : int) : W32.t list =
  map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)).

lemma size_mlane blk k : 0 <= k < 8 => size (mlane blk k) = 16.
proof.
by move=> hk; rewrite size_map size_chunk // size_lane_block // 1,2:/#.
qed.

lemma nth_mlane (blk : BArray512.t) k j : 0 <= k < 8 => 0 <= j < 16 =>
  nth W32.zero (mlane blk k) j = bswap32 (BArray512.get32 blk (16 * k + j)).
proof.
move=> hk hj; have hs : size (lane_block 64 (BArray512.to_list blk) k) = 64.
+ by rewrite size_lane_block // 1,2:/# BArray512.size_to_list /#.
rewrite (nth_map []) 1:size_chunk // 1:hs 1:/# nth_chunk4 1:hs 1:/#.
apply eq_sym; rewrite /bswap32 /be32 BArray512.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# hs /#.
move=> x; rewrite W4u8.size_to_list => hx.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray512.size_sub //.
have hi : 0 <= 4 * j + x < 64 by smt().
rewrite nth_take 1,2:/# nth_drop 1,2:/# nth_lane_block // 1:/#.
rewrite BArray512.get_to_list BArray512.nth_sub //.
by congr; ring.
qed.

(* Lane l's window before group 0: its sixteen words in order. *)
lemma wreg8_0 (w : BArray128.t) o (m : W32.t list) : size m = 16 =>
  (forall j, 0 <= j < 4 => BArray128.get128 w (o + j)
     = p4 (nth W32.zero m (4 * j)) (nth W32.zero m (4 * j + 1))
          (nth W32.zero m (4 * j + 2)) (nth W32.zero m (4 * j + 3))) =>
  wreg8 w o m 0.
proof. by move=> hm h i hi; rewrite /SHA256_ShaNi.grp /= SHA256_ShaNi.wv_lo // h. qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_compress                                                *)

(* Lane q before pair p / 2: compressed if q < p, else as it came in. *)
op cur (h0 : BArray256.t) (blk : BArray512.t) (p q : int) : W32.t list =
  if q < p then compress (lane8 (BArray256.get32 h0) q) (mlane blk q)
  else lane8 (BArray256.get32 h0) q.

op done8 (h0 : BArray256.t) (blk : BArray512.t) (h8 : BArray256.t) (p : int) =
  forall q, 0 <= q < 8 => lane8 (BArray256.get32 h8) q = cur h0 blk p q.

(* The loop context of pair (f, r), unchanged by its block loads. *)
op ctx (blk : BArray512.t) (f r : int) (blocks : BArray512.t) (k : BArray256.t) (mask_p : BArray16.t) =
  0 <= f < 2 /\ 0 <= r < 2 /\ blocks = blk /\ k = sHA256_K /\ mask_p = sHA256_X8_SHANI_BSWAP.

lemma ctxE blk f r blocks k mask_p : ctx blk f r blocks k mask_p =>
  0 <= f < 2 /\ 0 <= r < 2 /\ blocks = blk.
proof. by rewrite /ctx. qed.

lemma ctxK blk f r blocks k mask_p : ctx blk f r blocks k mask_p => k = sHA256_K.
proof. by rewrite /ctx. qed.

lemma cur_lo h0 blk p q : q < p => cur h0 blk p q = compress (lane8 (BArray256.get32 h0) q) (mlane blk q).
proof. by move=> h; rewrite /cur h. qed.

lemma cur_hi h0 blk p q : p <= q => cur h0 blk p q = lane8 (BArray256.get32 h0) q.
proof. by move=> h; rewrite /cur ifF 1:/#. qed.

(* The store of a pair: lanes p and p + 1 compressed, the others kept. *)
lemma done8_step h0 blk (h8 h8' : BArray256.t) p :
  0 <= p => p + 1 < 8 => done8 h0 blk h8 p =>
  lane8 (BArray256.get32 h8') p = compress (lane8 (BArray256.get32 h8) p) (mlane blk p) =>
  lane8 (BArray256.get32 h8') (p + 1)
    = compress (lane8 (BArray256.get32 h8) (p + 1)) (mlane blk (p + 1)) =>
  (forall q, 0 <= q < 8 => q <> p => q <> p + 1 =>
     lane8 (BArray256.get32 h8') q = lane8 (BArray256.get32 h8) q) =>
  done8 h0 blk h8' (p + 2).
proof.
move=> hp0 hp1 hd ha hb hq q hq8.
case: (q = p) => [->>|hne0].
+ by rewrite ha hd 1:/# (cur_hi h0 blk p p) // (cur_lo h0 blk (p + 2) p) /#.
case: (q = p + 1) => [->>|hne1].
+ rewrite hb hd 1:/# (cur_hi h0 blk p (p + 1)) 1:/#.
  by rewrite (cur_lo h0 blk (p + 2) (p + 1)) /#.
rewrite hq // hd // /cur.
have e : (q < p + 2) = (q < p).
+ by move: hne0 hne1; clear hd ha hb hq; smt().
by rewrite e.
qed.

(* Message rows 0 .. n - 1 of both lanes of the pair. *)
op wrows (w : BArray128.t) (ma mb : W32.t list) (n : int) =
  forall j, 0 <= j < n =>
    BArray128.get128 w j
    = p4 (nth W32.zero ma (4 * j)) (nth W32.zero ma (4 * j + 1))
         (nth W32.zero ma (4 * j + 2)) (nth W32.zero ma (4 * j + 3)) /\
    BArray128.get128 w (4 + j)
    = p4 (nth W32.zero mb (4 * j)) (nth W32.zero mb (4 * j + 1))
         (nth W32.zero mb (4 * j + 2)) (nth W32.zero mb (4 * j + 3)).

lemma x8_compress_correct (h0 : BArray256.t) (blk : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 h0) k)
                 (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))].
proof.
proc.
while (0 <= f <= 2 /\ blocks = blk /\ k = sHA256_K /\ mask_p = sHA256_X8_SHANI_BSWAP /\
       done8 h0 blk h8 (4 * f)).
+ wp.
  while (0 <= f < 2 /\ 0 <= r <= 2 /\ blocks = blk /\ k = sHA256_K /\
         mask_p = sHA256_X8_SHANI_BSWAP /\ done8 h0 blk h8 (4 * f + 2 * r)).
  + wp.
    ecall (store_pair_spec h8 f r
      (to_state (compress (lane8 (BArray256.get32 h8) (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r))))
      (to_state (compress (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1)) (mlane blk (4 * f + 2 * r + 1))))).
    ecall (block2_correct sHA256_K (mlane blk (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r + 1))
      (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r)))
      (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1))) SHA256_ShaNi.K256_get128).
    while (0 <= i <= 4 /\ mask = bswap_mask32 /\ ctx blk f r blocks k mask_p /\
           done8 h0 blk h8 (4 * f + 2 * r) /\
           regs st (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r)))
                   (to_state (lane8 (BArray256.get32 h8) (4 * f + 2 * r + 1))) /\
           wrows w (mlane blk (4 * f + 2 * r)) (mlane blk (4 * f + 2 * r + 1)) i).
    + wp; skip => &hr [#] hi0 _ hmk hc hd hst hw hi4.
      have [#] hf0 hf1 hr0 hr1 hb := ctxE _ _ _ _ _ _ hc.
      rewrite /=; split; first smt().
      do 4!(split; first done).
      rewrite hmk hb => j hj; do !(rewrite BArray128.get_set128E 1,2:/#).
      have -> /= : (i{hr} = 4 + i{hr}) = false by smt().
      have -> /= : (4 + i{hr} = 4 + j) = (i{hr} = j) by smt().
      have -> /= : (i{hr} = 4 + j) = false by smt().
      have -> /= : (4 + i{hr} = j) = false by smt().
      case: (i{hr} = j) => [<<- /=|hne /=]; last by apply hw => /#.
      rewrite !L512.get128_p4 !vpshufb_bswap32 !p4_0 !p4_1 !p4_2 !p4_3 !nth_mlane 1..16:/#.
      smt().
    wp; ecall (load_pair_spec h8 f r); wp; skip => &hr [#] hf0 hf1 hr0 _ hb hk hm hd hr2.
    have hp : 0 <= 4 * f{hr} + 2 * r{hr} < 8 by move: hf0 hf1 hr0 hr2; clear hk hm hd; smt().
    have hp1 : 0 <= 4 * f{hr} + 2 * r{hr} + 1 < 8 by move: hf0 hf1 hr0 hr2; clear hk hm hd; smt().
    have hr' : 0 <= r{hr} + 1 <= 2 by move: hr0 hr2; clear hk hm hd; smt().
    split; first smt().
    move=> _ st [#] e0 e1 e2 e3; split.
    + split; first done.
      split; first by rewrite hm SHA256_ShaNi.mask_bswap.
      split; first by rewrite /ctx; do !split => //.
      split; first done.
      by rewrite /regs e0 e1 e2 e3 /= => j /#.
    move=> i w hi4 [#] hi0 hi1 hmk hc hd' hst hw.
    have hk' := ctxK _ _ _ _ _ _ hc.
    have ->> : i = 4 by smt().
    split.
    + rewrite (size_mlane _ _ hp) (size_mlane _ _ hp1) /= hk' hst /=.
      split.
      + apply wreg8_0; first exact (size_mlane _ _ hp).
        by move=> j hj /=; have [-> _] := hw j hj.
      apply wreg8_0; first exact (size_mlane _ _ hp1).
      by move=> j hj; have [_ ->] := hw j hj.
    move=> _ [st' w'] /= [#] p0 p1 p2 p3.
    have [fa1 fa2] := SHA256_ShaNi.ff_state (lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr}))
                        (mlane blk (4 * f{hr} + 2 * r{hr})) (size_lane _ _ _).
    have [fb1 fb2] := SHA256_ShaNi.ff_state (lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr} + 1))
                        (mlane blk (4 * f{hr} + 2 * r{hr} + 1)) (size_lane _ _ _).
    split; first by rewrite /= p0 p1 p2 p3 fa1 fa2 fb1 fb2; do !split => //.
    move=> _ h8' [#] l0 l1 lfr.
    have e : 4 * f{hr} + 2 * (r{hr} + 1) = (4 * f{hr} + 2 * r{hr}) + 2 by ring.
    rewrite /= e hb hk hm /=; split; first by split.
    split; first exact hr'.
    apply (done8_step h0 blk h8{hr} h8' (4 * f{hr} + 2 * r{hr})) => //; 1,2: smt().
    + by rewrite l0 /ofs SHA256_ShaNi.to_stateK // SHA256_ShaNi.size_compress // size_lane.
    by rewrite l1 /ofs SHA256_ShaNi.to_stateK // SHA256_ShaNi.size_compress // size_lane.
  wp; skip => &hr [#] hf0 _ hb hk hm hd hf2; split.
  + by rewrite hb hk hm /=; do !split => //.
  move=> h8' r' hr2 [#] _ _ hr0 hr1 hb' hk' hm' hd'.
  have ->> : r' = 2 by move: hr0 hr1 hr2; clear hk hm hk' hm' hd hd'; smt().
  rewrite hb' hk' hm' /=; split; first by move: hf0 hf2; clear hk hm hk' hm' hd hd'; smt().
  by have <- : 4 * f{hr} + 2 * 2 = 4 * (f{hr} + 1) by ring.
wp; skip => &hr [#] -> ->; split.
+ by do !split => // q hq; rewrite /cur ifF 1:/#.
move=> f' h8' hf [#] hf0 hf1 _ _ _ hd q hq.
have ->> : f' = 2 by move: hf hf0 hf1; clear hd; smt().
by rewrite /= hd // cur_lo /#.
qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_compress_lanes                                          *)

(* The sixteen words of the block at a, big-endian (section 5.2.1). *)
abbrev mblk (mem : global_mem_t) (a : int) : W32.t list = map be32 (chunk 4 (memread mem a 64)).

(* Lane q's blocks start at in0[q] + off0. *)
op base (in0 : BArray64.t) (off0 : W64.t) (q : int) : int =
  to_uint (BArray64.get64 in0 q) + to_uint off0.

(* Lane q's chaining value after its first c blocks. *)
op hl (mem : global_mem_t) (h0 : BArray256.t) (in0 : BArray64.t) (off0 : W64.t) (c q : int) =
  foldl compress (lane8 (BArray256.get32 h0) q) (parse (memread mem (base in0 off0 q) (64 * c))).

lemma hl0 mem h0 in0 off0 q : hl mem h0 in0 off0 0 q = lane8 (BArray256.get32 h0) q.
proof. by rewrite /hl (_ : 64 * 0 = 0) // parse_memread0. qed.

lemma hlS mem h0 in0 off0 c q : 0 <= c =>
  hl mem h0 in0 off0 (c + 1) q = compress (hl mem h0 in0 off0 c q) (mblk mem (base in0 off0 q + 64 * c)).
proof. by move=> hc; rewrite /hl parse_memreadS // foldl_rcons. qed.

lemma size_hl mem h0 in0 off0 c q : size (hl mem h0 in0 off0 c q) = 8.
proof. by rewrite /hl SHA256_ShaNi.size_foldl_compress // size_lane. qed.

(* Lane q before pair p / 2: its n0 blocks done if q < p, else as it came in. *)
op curl (mem : global_mem_t) (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) (p q : int) =
  if q < p then hl mem h0 in0 off0 (to_uint n0) q else lane8 (BArray256.get32 h0) q.

op done8l mem h0 in0 off0 n0 (h8 : BArray256.t) p =
  forall q, 0 <= q < 8 => lane8 (BArray256.get32 h8) q = curl mem h0 in0 off0 n0 p q.

lemma done8l_step mem h0 in0 off0 n0 (h8 h8' : BArray256.t) p :
  0 <= p => p + 1 < 8 => done8l mem h0 in0 off0 n0 h8 p =>
  lane8 (BArray256.get32 h8') p = hl mem h0 in0 off0 (to_uint n0) p =>
  lane8 (BArray256.get32 h8') (p + 1) = hl mem h0 in0 off0 (to_uint n0) (p + 1) =>
  (forall q, 0 <= q < 8 => q <> p => q <> p + 1 =>
     lane8 (BArray256.get32 h8') q = lane8 (BArray256.get32 h8) q) =>
  done8l mem h0 in0 off0 n0 h8' (p + 2).
proof.
move=> hp0 hp1 hd ha hb hq q hq8.
case: (q = p) => [->>|hne0]; first by rewrite ha /curl ifT 1:/#.
case: (q = p + 1) => [->>|hne1]; first by rewrite hb /curl ifT 1:/#.
rewrite hq // hd // /curl.
have e : (q < p + 2) = (q < p).
+ by move: hne0 hne1; clear hd ha hb hq; smt().
by rewrite e.
qed.

(* The context of every loop: arguments, constants and the domain. *)
op cl (in0 : BArray64.t) (off0 n0 : W64.t) (in_0 : BArray64.t) (off n : W64.t)
      (k : BArray256.t) (mask_p : BArray16.t) =
  in_0 = in0 /\ off = off0 /\ n = n0 /\ k = sHA256_K /\ mask_p = sHA256_X8_SHANI_BSWAP /\
  forall q, 0 <= q < 8 =>
    to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus.

lemma clE in0 off0 n0 in_0 off n k mask_p : cl in0 off0 n0 in_0 off n k mask_p =>
  in_0 = in0 /\ off = off0 /\ n = n0 /\ mask_p = sHA256_X8_SHANI_BSWAP.
proof. by rewrite /cl. qed.

lemma clK in0 off0 n0 in_0 off n k mask_p : cl in0 off0 n0 in_0 off n k mask_p => k = sHA256_K.
proof. by rewrite /cl. qed.

lemma clO in0 off0 n0 in_0 off n k mask_p : cl in0 off0 n0 in_0 off n k mask_p =>
  forall q, 0 <= q < 8 => base in0 off0 q + 64 * to_uint n0 < W64.modulus.
proof. by rewrite /cl /base. qed.

(* The state of the block loop of pair (f, r). *)
op binv mem h0 in0 off0 n0 (f r : int) (h8 : BArray256.t) (c p q : W64.t) (st : BArray64.t) =
  done8l mem h0 in0 off0 n0 h8 (4 * f + 2 * r) /\
  0 <= to_uint c <= to_uint n0 /\
  to_uint p = base in0 off0 (4 * f + 2 * r) + 64 * (to_uint n0 - to_uint c) /\
  to_uint q = base in0 off0 (4 * f + 2 * r + 1) + 64 * (to_uint n0 - to_uint c) /\
  regs st (to_state (hl mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r)))
          (to_state (hl mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r + 1))).

lemma binvE mem h0 in0 off0 n0 f r h8 (c p q : W64.t) st :
  binv mem h0 in0 off0 n0 f r h8 c p q st =>
  done8l mem h0 in0 off0 n0 h8 (4 * f + 2 * r) /\
  0 <= to_uint c <= to_uint n0 /\
  to_uint p = base in0 off0 (4 * f + 2 * r) + 64 * (to_uint n0 - to_uint c) /\
  to_uint q = base in0 off0 (4 * f + 2 * r + 1) + 64 * (to_uint n0 - to_uint c) /\
  regs st (to_state (hl mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r)))
          (to_state (hl mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r + 1))).
proof. by rewrite /binv. qed.

lemma base_ge0 in0 off0 q : 0 <= base in0 off0 q.
proof. by rewrite /base; smt(W64.to_uint_cmp). qed.

(* One more block of a lane: the pointer and the count move without
   wrapping. *)
lemma room (c p n0 : W64.t) (b : int) :
  0 <= b => to_uint c <= to_uint n0 => c <> W64.zero =>
  to_uint p = b + 64 * (to_uint n0 - to_uint c) => b + 64 * to_uint n0 < W64.modulus =>
  to_uint p + 64 <= W64.modulus /\ to_uint (p + W64.of_int 64) = to_uint p + 64 /\
  to_uint (c - W64.one) = to_uint c - 1 /\ 1 <= to_uint c.
proof.
move=> hb hcn hc hp hov.
have hc1 : 1 <= to_uint c.
+ case: (to_uint c = 0) => h1; last smt(W64.to_uint_cmp).
  by move: hc; rewrite W64.to_uint_eq h1.
split; first by move: hp hov hc1 hcn; clear hc; smt().
split.
+ rewrite W64.to_uintD_small; move: hp hov hc1 hcn; clear hc; rewrite /=; smt(W64.to_uint_cmp).
split; last done.
rewrite W64.to_uintB //; rewrite W64.uleE /=; move: hc1; smt().
qed.

(* A 16-byte step within a block of 64 bytes that fits below the top. *)
lemma addr16 (p : W64.t) i : to_uint p + 64 <= W64.modulus => 0 <= i < 4 =>
  to_uint (p + W64.of_int (16 * i)) = to_uint p + 16 * i.
proof.
move=> hp hi; have h16 : to_uint (W64.of_int (16 * i)) = 16 * i.
+ by rewrite W64.of_uintK pmod_small //; move: hp; rewrite /=; smt(W64.to_uint_cmp).
by rewrite W64.to_uintD_small h16 //; move: hp; rewrite /=; smt(W64.to_uint_cmp).
qed.

lemma x8_compress_lanes_correct (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0)
                           (64 * to_uint n0)))].
proof.
proc.
while (0 <= f <= 2 /\ cl in0 off0 n0 in_0 off n k mask_p /\
       done8l Glob.mem h0 in0 off0 n0 h8 (4 * f)).
+ wp.
  while (0 <= f < 2 /\ 0 <= r <= 2 /\ cl in0 off0 n0 in_0 off n k mask_p /\
         done8l Glob.mem h0 in0 off0 n0 h8 (4 * f + 2 * r)).
  + wp.
    ecall (store_pair_spec h8 f r
      (to_state (hl Glob.mem h0 in0 off0 (to_uint n0) (4 * f + 2 * r)))
      (to_state (hl Glob.mem h0 in0 off0 (to_uint n0) (4 * f + 2 * r + 1)))).
    wp.
    while (0 <= f < 2 /\ 0 <= r < 2 /\ cl in0 off0 n0 in_0 off n k mask_p /\
           more = (c <> W64.zero) /\ binv Glob.mem h0 in0 off0 n0 f r h8 c p q st).
    + wp.
      ecall (block2_correct sHA256_K (mblk Glob.mem (to_uint p)) (mblk Glob.mem (to_uint q))
        (to_state (hl Glob.mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r)))
        (to_state (hl Glob.mem h0 in0 off0 (to_uint n0 - to_uint c) (4 * f + 2 * r + 1)))
        SHA256_ShaNi.K256_get128).
      while (0 <= i <= 4 /\ mask = bswap_mask32 /\ 0 <= f < 2 /\ 0 <= r < 2 /\
             cl in0 off0 n0 in_0 off n k mask_p /\ c <> W64.zero /\
             binv Glob.mem h0 in0 off0 n0 f r h8 c p q st /\
             to_uint p + 64 <= W64.modulus /\ to_uint q + 64 <= W64.modulus /\
             wrows w (mblk Glob.mem (to_uint p)) (mblk Glob.mem (to_uint q)) i).
      + wp; skip => &hr [#] hi0 _ hmk hf0 hf1 hr0 hr1 hc hne hb hp hq hw hi4.
        rewrite /=; split; first by move: hi0 hi4; clear hc hb hw; smt().
        do 8!(split; first done).
        rewrite hmk => j hj; do !(rewrite BArray128.get_set128E 1,2:/#).
        have -> /= : (i{hr} = 4 + i{hr}) = false by smt().
        have -> /= : (4 + i{hr} = 4 + j) = (i{hr} = j) by smt().
        have -> /= : (i{hr} = 4 + j) = false by smt().
        have -> /= : (4 + i{hr} = j) = false by smt().
        case: (i{hr} = j) => [<<- /=|hij /=]; last by apply hw => /#.
        have ep := addr16 p{hr} i{hr} hp _; 1: by split.
        have eq := addr16 q{hr} i{hr} hq _; 1: by split.
        rewrite ep eq !vpshufb_load128 !nth_mblock_mem 1..8:/#.
        smt().
      wp; skip => &hr [#] hf0 hf1 hr0 hr1 hc hmore hb hm.
      have [#] hin hoff hn hmp := clE _ _ _ _ _ _ _ _ hc.
      have hk := clK _ _ _ _ _ _ _ _ hc.
      have hov := clO _ _ _ _ _ _ _ _ hc.
      have [#] hd hc0 hcn hpv hqv hst := binvE _ _ _ _ _ _ _ _ _ _ _ _ hb.
      have hne : c{hr} <> W64.zero by rewrite -hmore.
      have hpa : 0 <= 4 * f{hr} + 2 * r{hr} < 8 by move: hf0 hf1 hr0 hr1; clear hc hov hb hd hst; smt().
      have hpb : 0 <= 4 * f{hr} + 2 * r{hr} + 1 < 8 by move: hf0 hf1 hr0 hr1; clear hc hov hb hd hst; smt().
      have [rp [up [uc hc1]]] := room c{hr} p{hr} n0 _ (base_ge0 _ _ _) hcn hne hpv (hov _ hpa).
      have [rq [uq _]] := room c{hr} q{hr} n0 _ (base_ge0 _ _ _) hcn hne hqv (hov _ hpb).
      split.
      + split; first done.
        split; first by rewrite hmp SHA256_ShaNi.mask_bswap.
        do 6!(split; first done).
        by split; [done | move=> j /#].
      move=> i w hi4 [#] hi0 hi1 hmk _ _ _ _ _ _ _ _ _ hw.
      have ->> : i = 4 by smt().
      split.
      + rewrite !size_mblock_mem /= hk hst /=.
        split.
        + apply wreg8_0; first exact size_mblock_mem.
          by move=> j hj /=; have [-> _] := hw j hj.
        apply wreg8_0; first exact size_mblock_mem.
        by move=> j hj; have [_ ->] := hw j hj.
      move=> _ [st' w'] /= [#] p0 p1 p2 p3.
      do 3!(split; first done).
      rewrite /binv uc up uq; split; first done.
      split; first by move: hc1 hcn; clear hc hov hb hd hst; smt().
      have e : to_uint n0 - (to_uint c{hr} - 1) = (to_uint n0 - to_uint c{hr}) + 1 by ring.
      rewrite e hpv hqv; split; first ring.
      split; first ring.
      have hk0 : 0 <= to_uint n0 - to_uint c{hr} by move: hcn; clear hc hov hb hd hst; smt().
      rewrite !hlS // -hpv -hqv.
      have [fa1 fa2] := SHA256_ShaNi.ff_state
        (hl Glob.mem{hr} h0 in0 off0 (to_uint n0 - to_uint c{hr}) (4 * f{hr} + 2 * r{hr}))
        (mblk Glob.mem{hr} (to_uint p{hr})) (size_hl _ _ _ _ _ _).
      have [fb1 fb2] := SHA256_ShaNi.ff_state
        (hl Glob.mem{hr} h0 in0 off0 (to_uint n0 - to_uint c{hr}) (4 * f{hr} + 2 * r{hr} + 1))
        (mblk Glob.mem{hr} (to_uint q{hr})) (size_hl _ _ _ _ _ _).
      by rewrite /regs /= p0 p1 p2 p3 fa1 fa2 fb1 fb2.
    wp; ecall (load_pair_spec h8 f r); wp; skip => &hr [#] hf0 hf1 hr0 _ hc hd hr2.
    have [#] hin hoff hn hmp := clE _ _ _ _ _ _ _ _ hc.
    have hov := clO _ _ _ _ _ _ _ _ hc.
    have hpa : 0 <= 4 * f{hr} + 2 * r{hr} < 8 by move: hf0 hf1 hr0 hr2; clear hc hov hd; smt().
    have hpb : 0 <= 4 * f{hr} + 2 * r{hr} + 1 < 8 by move: hf0 hf1 hr0 hr2; clear hc hov hd; smt().
    have hr' : 0 <= r{hr} + 1 <= 2 by move: hr0 hr2; clear hc hov hd; smt().
    split; first by rewrite /=; do !split => //.
    move=> _ st [#] e0 e1 e2 e3.
    have epa : to_uint (SLH64.protect_64 (BArray64.get64 in_0{hr} (4 * f{hr} + 2 * r{hr})) ms{hr} + off{hr})
               = base in0 off0 (4 * f{hr} + 2 * r{hr}).
    + rewrite /SLH64.protect_64 hin hoff /base W64.to_uintD_small //.
      by move: (hov _ hpa); rewrite /base; clear hc hov hd; smt(W64.to_uint_cmp).
    have epb : to_uint (SLH64.protect_64 (BArray64.get64 in_0{hr} (4 * f{hr} + 2 * r{hr} + 1)) ms{hr} + off{hr})
               = base in0 off0 (4 * f{hr} + 2 * r{hr} + 1).
    + rewrite /SLH64.protect_64 hin hoff /base W64.to_uintD_small //.
      by move: (hov _ hpb); rewrite /base; clear hc hov hd; smt(W64.to_uint_cmp).
    have la : lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr})
              = lane8 (BArray256.get32 h0) (4 * f{hr} + 2 * r{hr}).
    + by rewrite hd // /curl ltzz.
    have lb : lane8 (BArray256.get32 h8{hr}) (4 * f{hr} + 2 * r{hr} + 1)
              = lane8 (BArray256.get32 h0) (4 * f{hr} + 2 * r{hr} + 1).
    + rewrite hd // /curl ifF //.
      by move: hpa; clear hc hov hd e0 e1 e2 e3; smt().
    split.
    + do 4!(split; first done).
      rewrite /binv epa epb hn; split; first done.
      split; first by clear hc hov hd e0 e1 e2 e3; smt(W64.to_uint_cmp).
      have -> : to_uint n0 - to_uint n0 = 0 by ring.
      split; first ring.
      split; first ring.
      by rewrite !hl0 /regs -la -lb e0 e1 e2 e3.
    move=> c0 more0 p0 q0 st0 hm [#] _ _ _ _ _ hmo hb0.
    have [#] _ _ _ _ _ hst0 := binvE _ _ _ _ _ _ _ _ _ _ _ _ hb0.
    have hz : c0 = W64.zero by move: hm; rewrite hmo.
    move: hst0; rewrite hz /= => hst0.
    split.
    + by move: hst0; rewrite /regs /= => [#] -> -> -> ->; do !split => //.
    move=> _ h8' [#] l0 l1 lfr.
    have e : 4 * f{hr} + 2 * (r{hr} + 1) = (4 * f{hr} + 2 * r{hr}) + 2 by ring.
    rewrite /= e; split; first by split.
    split; first exact hr'.
    split; first exact hc.
    apply (done8l_step Glob.mem{hr} h0 in0 off0 n0 h8{hr} h8' (4 * f{hr} + 2 * r{hr})) => //.
    + by move: hpa; clear hc hov hd e0 e1 e2 e3; smt().
    + by move: hpb; clear hc hov hd e0 e1 e2 e3; smt().
    + by rewrite l0 /ofs SHA256_ShaNi.to_stateK // size_hl.
    by rewrite l1 /ofs SHA256_ShaNi.to_stateK // size_hl.
  wp; skip => &hr [#] hf0 _ hc hd hf2; split.
  + do 3!(split; first done).
    by have -> : 4 * f{hr} + 2 * 0 = 4 * f{hr} by ring.
  move=> h8' r' hr2 [#] _ _ hr0 hr1 _ hd'.
  have ->> : r' = 2 by move: hr0 hr1 hr2; clear hc hd hd'; smt().
  rewrite /=; split; first by move: hf0 hf2; clear hc hd hd'; smt().
  split; first done.
  by have <- : 4 * f{hr} + 2 * 2 = 4 * (f{hr} + 1) by ring.
wp; skip => &hr [#] -> -> -> -> hov; split.
+ split; first done.
  split; first by rewrite /cl; do !split => //.
  move=> q hq; rewrite /curl ifF //.
  by move: hq; clear hov; smt().
move=> f' h8' ms' hf [#] hf0 hf1 _ hd q hq.
have ->> : f' = 2 by move: hf hf0 hf1; clear hd hov; smt().
rewrite /= hd // /curl ifT; first by move: hq; clear hd hov; smt().
by rewrite /hl /base.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range, except the block loop of
   _sha256_x8_compress_lanes, which runs n times per pair. *)
lemma load_pair_ll : islossless M.__shani_x8_load_pair.
proof. by proc; while (true) (2 - q); auto => /#. qed.

lemma store_pair_ll : islossless M.__shani_x8_store_pair.
proof. by proc; while (true) (2 - q); auto => /#. qed.

lemma block2_ll : islossless M.__shani_x8_block2.
proof.
proc; wp; while (true) (4 - j); first by auto => /#.
wp; while (true) (16 - g).
+ move=> z; wp; while (true) (2 - l); first by auto => /#.
  wp; while (true) (2 - l); first by move=> z'; auto => /#.
  by auto => /#.
wp; while (true) (4 - j); first by auto => /#.
by auto => /#.
qed.

lemma x8_compress_ll : islossless M._sha256_x8_compress.
proof.
proc; while (true) (2 - f).
+ move=> z; wp; while (true) (2 - r).
  + move=> z'; wp; call store_pair_ll; call block2_ll.
    while (true) (4 - i); first by auto => /#.
    by wp; call load_pair_ll; auto => /#.
  by auto => /#.
by auto => /#.
qed.

lemma x8_compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof.
proc; while (true) (2 - f).
+ move=> z; wp; while (true) (2 - r).
  + move=> z'; wp; call store_pair_ll; wp.
    while (more = (c <> W64.zero)) (to_uint c).
    + move=> z''; wp; call block2_ll.
      while (true) (4 - i); first by auto => /#.
      auto => /> &hr hne i; split; first smt().
      move=> _.
      have hn1 : 1 <= to_uint c{hr}.
      + case: (to_uint c{hr} = 0) => h1; last smt(W64.to_uint_cmp).
        by move: hne; rewrite W64.to_uint_eq h1.
      by rewrite W64.to_uintB 1:W64.uleE /= /#.
    wp; call load_pair_ll; auto => /> &hr more c.
    by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
  by auto => /#.
by auto => /#.
qed.

lemma x8_compress_total (h0 : BArray256.t) (blk : BArray512.t) :
  phoare [M._sha256_x8_compress :
           h8 = h0 /\ blocks = blk ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 h0) k)
                 (map be32 (chunk 4 (lane_block 64 (BArray512.to_list blk) k)))] = 1%r.
proof. by conseq x8_compress_ll (x8_compress_correct h0 blk). qed.

lemma x8_compress_lanes_total (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
           h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\
           (forall q, 0 <= q < 8 =>
              to_uint (BArray64.get64 in0 q) + to_uint off0 + 64 * to_uint n0 < W64.modulus) ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 h0) k)
                 (parse (JWordList.memread Glob.mem (to_uint (BArray64.get64 in0 k) + to_uint off0)
                           (64 * to_uint n0)))] = 1%r.
proof. by conseq x8_compress_lanes_ll (x8_compress_lanes_correct h0 in0 off0 n0). qed.
