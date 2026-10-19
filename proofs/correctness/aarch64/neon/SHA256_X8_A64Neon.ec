(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64Neon.ec (aarch64/neon)
 * ===================================
 *
 * Functional correctness, lane by lane, of the eight-way entry point
 * _sha256_x8_compress of the AArch64 Advanced SIMD 8-way SHA-256 kernel
 * (src/aarch64/neon/sha256_x8_compress.jinc) against FIPS 180-4 section
 * 6.2.2: every lane k ends with compress applied to its own chaining value
 * and its own block. The entry point that reads the blocks from memory is
 * proven in SHA256_X8_A64NeonLanes.ec.
 *
 * Representation. Block k is bytes 64k .. 64k + 63 of the 512-byte input
 * (lane_block of lib/Lanes.ec); its 128-bit slot 4k + i holds message
 * words 4i .. 4i + 3, little-endian in memory. For half x and quarter i,
 * the kernel reads slot i of blocks 4x .. 4x + 3 into r[0 .. 3], and
 * __sha256_x8_rows reverses the bytes of every 32-bit lane (VREV32,
 * section 5.2.1 reads words big-endian) and transposes the 4x4 matrix of
 * words (tr4 of Vec.ec): row kk of the result holds word 4i + kk of the
 * four blocks, block 4x + c in lane c. That row is w[16x + 4i + kk], the
 * layout _sha256_x8_block takes (SHA256_X8_A64NeonBlock.ec).
 *
 * Theorems:
 *     n8_rows_correct               the byte reversal and the transpose,
 *                                   lane by lane;
 *     sha256_x8_compress_correct    lane k of the result is compress of
 *                                   lane k and block k, for k < 8
 *                                   (partial correctness);
 *     sha256_x8_compress_ll,        termination, and the same with
 *     sha256_x8_compress_total      termination.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray64 BArray256 BArray512.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Lanes.
require import SHA256_X8_A64NeonRound SHA256_X8_A64NeonBlock.
require Arrays.
import SHA256.

clone Arrays.Words as N8A512 with theory A <= BArray512.

(* ------------------------------------------------------------------ *)
(* Byte reversal and transpose                                        *)

lemma n8_vrev (x : W128.t) :
  VREV32_16u8 x
  = p4 (bswap32 (x \bits32 0)) (bswap32 (x \bits32 1)) (bswap32 (x \bits32 2)) (bswap32 (x \bits32 3)).
proof.
by rewrite {1}(p4_bits (VREV32_16u8 x)) !vrev32_lane.
qed.

(* The four rows of tr4, one per lemma, on packed operands. *)
lemma n8_tr0 (a0 a1 a2 a3 b0 b1 b2 b3 c0 c1 c2 c3 d0 d1 d2 d3 : W32.t) :
  VTRN1_2u64 (VTRN1_4u32 (p4 a0 a1 a2 a3) (p4 b0 b1 b2 b3)) (VTRN1_4u32 (p4 c0 c1 c2 c3) (p4 d0 d1 d2 d3))
  = p4 a0 b0 c0 d0.
proof. by rewrite !vtrn1_4u32_p4 vtrn1_2u64_p4. qed.

lemma n8_tr1 (a0 a1 a2 a3 b0 b1 b2 b3 c0 c1 c2 c3 d0 d1 d2 d3 : W32.t) :
  VTRN1_2u64 (VTRN2_4u32 (p4 a0 a1 a2 a3) (p4 b0 b1 b2 b3)) (VTRN2_4u32 (p4 c0 c1 c2 c3) (p4 d0 d1 d2 d3))
  = p4 a1 b1 c1 d1.
proof. by rewrite !vtrn2_4u32_p4 vtrn1_2u64_p4. qed.

lemma n8_tr2 (a0 a1 a2 a3 b0 b1 b2 b3 c0 c1 c2 c3 d0 d1 d2 d3 : W32.t) :
  VTRN2_2u64 (VTRN1_4u32 (p4 a0 a1 a2 a3) (p4 b0 b1 b2 b3)) (VTRN1_4u32 (p4 c0 c1 c2 c3) (p4 d0 d1 d2 d3))
  = p4 a2 b2 c2 d2.
proof. by rewrite !vtrn1_4u32_p4 vtrn2_2u64_p4. qed.

lemma n8_tr3 (a0 a1 a2 a3 b0 b1 b2 b3 c0 c1 c2 c3 d0 d1 d2 d3 : W32.t) :
  VTRN2_2u64 (VTRN2_4u32 (p4 a0 a1 a2 a3) (p4 b0 b1 b2 b3)) (VTRN2_4u32 (p4 c0 c1 c2 c3) (p4 d0 d1 d2 d3))
  = p4 a3 b3 c3 d3.
proof. by rewrite !vtrn2_4u32_p4 vtrn2_2u64_p4. qed.

lemma n8_rows_correct (R : BArray64.t) :
  hoare [M.__sha256_x8_rows : r = R ==>
           forall kk c, 0 <= kk < 4 => 0 <= c < 4 =>
             BArray64.get128 res kk \bits32 c = bswap32 (BArray64.get128 R c \bits32 kk)].
proof.
proc; unroll for 3; wp; skip => &hr -> /= kk c hkk hc.
rewrite !n8_vrev n8_tr0 n8_tr1 n8_tr2 n8_tr3.
case: (n8_c4 kk hkk) => [|[|[|]]] ->> /=; rewrite n8_p4 //;
  by case: (n8_c4 c hc) => [|[|[|]]] ->>.
qed.

lemma n8_rows_ll : islossless M.__sha256_x8_rows.
proof. by proc; wp; while (0 <= k <= 4) (4 - k); auto => /#. qed.

(* ------------------------------------------------------------------ *)
(* The eight blocks                                                   *)

lemma n8_size_lb (B : BArray512.t) k : 0 <= k < 8 =>
  size (lane_block 64 (BArray512.to_list B) k) = 64.
proof.
move=> hk; apply size_lane_block; [done | smt() | by rewrite BArray512.size_to_list /#].
qed.

(* Message word t of block k, read big-endian (section 5.2.1). *)
lemma n8_bswap_lane (B : BArray512.t) (k t : int) : 0 <= k < 8 => 0 <= t < 16 =>
  bswap32 (BArray512.get32 B (16 * k + t))
  = be32 (take 4 (drop (4 * t) (lane_block 64 (BArray512.to_list B) k))).
proof.
move=> hk ht; rewrite /bswap32 /be32 BArray512.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# n8_size_lb // /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray512.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# nth_lane_block // 1,2:/# BArray512.get_to_list.
by rewrite BArray512.nth_sub //; congr; ring.
qed.

op n8_bw (B : BArray512.t) (k : int) : W32.t list =
  map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)).

lemma n8_size_bw B : forall k, 0 <= k < 8 => size (n8_bw B k) = 16.
proof. by move=> k hk; rewrite /n8_bw -/(blockwords _) size_blockwords // n8_size_lb. qed.

(* Word 4i + kk of block 4x + c is lane kk of slot 4(4x + c) + i, reversed. *)
lemma n8_bw_slot (B : BArray512.t) x c i kk : 0 <= x < 2 => 0 <= c < 4 => 0 <= i < 4 => 0 <= kk < 4 =>
  bswap32 (BArray512.get128 B (4 * (4 * x + c) + i) \bits32 kk)
  = nth W32.zero (n8_bw B (4 * x + c)) (4 * i + kk).
proof.
move=> hx hc hi hkk; rewrite N8A512.get128d_bits32 //.
rewrite /n8_bw -/(blockwords _) (nth_blockwords _ _ (n8_size_lb B (4 * x + c) _)) 1,2:/#.
rewrite -(n8_bswap_lane B (4 * x + c) (4 * i + kk)) 1,2:/#.
by congr; congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* The entry point                                                    *)

(* The four writes of one quarter i of half x into w. *)
lemma n8_w4 (w : BArray512.t) x i y0 y1 y2 y3 x' j :
  0 <= x < 2 => 0 <= i < 4 => 0 <= x' < 2 => 0 <= j < 16 =>
  BArray512.get128
    (BArray512.set128 (BArray512.set128 (BArray512.set128 (BArray512.set128 w
       (16 * x + 4 * i) y0) (16 * x + 4 * i + 1) y1) (16 * x + 4 * i + 2) y2) (16 * x + 4 * i + 3) y3)
    (16 * x' + j)
  = if x' = x /\ 4 * i <= j < 4 * i + 4 then nth W128.zero [y0; y1; y2; y3] (j - 4 * i)
    else BArray512.get128 w (16 * x' + j).
proof.
move=> hx hi hx' hj; rewrite !BArray512.get_set128E 1..8:/#.
case: (x' = x /\ 4 * i <= j < 4 * i + 4) => h.
+ have : j - 4 * i = 0 \/ j - 4 * i = 1 \/ j - 4 * i = 2 \/ j - 4 * i = 3 by smt().
  by case=> [e|[e|[e|e]]]; rewrite e /=; smt().
by rewrite !ifF 1..4:/#.
qed.

op n8_wpart (w : BArray512.t) (B : BArray512.t) (n : int) =
  forall x' j c, 0 <= x' < 2 => 0 <= j < 16 => 0 <= c < 4 => 16 * x' + j < n =>
    BArray512.get128 w (16 * x' + j) \bits32 c = nth W32.zero (n8_bw B (4 * x' + c)) j.

lemma sha256_x8_compress_correct (H : BArray256.t) (B : BArray512.t) :
  hoare [M._sha256_x8_compress :
           h8 = H /\ blocks = B ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 H) k)
                        (map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)))].
proof.
proc.
ecall (n8_block_correct H (n8_bw B) (n8_size_bw B)).
while (0 <= x <= 2 /\ h8 = H /\ blocks = B /\ n8_wpart w B (16 * x)).
+ wp; while (0 <= x < 2 /\ 0 <= i <= 4 /\ h8 = H /\ blocks = B /\ n8_wpart w B (16 * x + 4 * i)).
  + unroll for 5; unroll for 2.
    wp; ecall (n8_rows_correct r); wp; skip => &hr [#] hx0 hx1 hi0 hi1 -> -> hw hlt /= r hr.
    have hrow : forall kk c, 0 <= kk < 4 => 0 <= c < 4 =>
      BArray64.get128 r kk \bits32 c = nth W32.zero (n8_bw B (4 * x{hr} + c)) (4 * i{hr} + kk).
    + move=> kk c hkk hc; rewrite hr //.
      case: (n8_c4 c hc) => [|[|[|]]] ->> /=;
        [rewrite (_: 4 * x{hr} = 4 * x{hr} + 0) 1:// | idtac | idtac | idtac];
        by rewrite n8_bw_slot // /#.
    clear hr; have hi' : 0 <= i{hr} + 1 && i{hr} + 1 <= 4 by split; [move: hi0 => /# | move: hlt => /#].
    rewrite hx0 hx1 hi' /=.
    move=> x' j c hx' hj hc hlt'; rewrite n8_w4 1..4:/#.
    case: (x' = x{hr} /\ 4 * i{hr} <= j < 4 * i{hr} + 4) => h /=; last by apply hw => // /#.
    have [->> hj'] := h.
    have : j - 4 * i{hr} = 0 \/ j - 4 * i{hr} = 1 \/ j - 4 * i{hr} = 2 \/ j - 4 * i{hr} = 3 by smt().
    case=> [e|[e|[e|e]]]; rewrite e /=;
      [rewrite (hrow 0 c) // | rewrite (hrow 1 c) // | rewrite (hrow 2 c) // | rewrite (hrow 3 c) //];
      by congr; smt().
  wp; skip => /> &hr hx0 _ _ hx1 i0 w0 hi0 hi1 hi2 hw.
  have ->> : i0 = 4 by smt().
  by split; [smt() | rewrite (_: 16 * (x{hr} + 1) = 16 * x{hr} + 4 * 4) 1:/#].
wp; skip => />; split.
+ by rewrite /n8_wpart => x' j c hx' hj hc hlt; smt().
move=> w0 x0 hx0 hx0' hx0'' hw0; split.
+ by move=> x1 j c hx1 hx1' hj hj' hc hc'; apply hw0 => // /#.
by move=> _ r hres k hk hk'; have := hres k _; [done | rewrite /n8_bw].
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha256_x8_compress_ll : islossless M._sha256_x8_compress.
proof.
proc; call n8_block_ll.
while (0 <= x <= 2) (2 - x).
+ move=> z; wp; while (0 <= i <= 4) (4 - i).
  + move=> z'; wp; while (0 <= k <= 4) (4 - k); first by auto => /#.
    wp; call n8_rows_ll; wp; while (0 <= k <= 4) (4 - k); first by auto => /#.
    by auto => /#.
  by auto => /#.
by auto => /#.
qed.

lemma sha256_x8_compress_total (H : BArray256.t) (B : BArray512.t) :
  phoare [M._sha256_x8_compress :
           h8 = H /\ blocks = B ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = compress (lane8 (BArray256.get32 H) k)
                        (map be32 (chunk 4 (lane_block 64 (BArray512.to_list B) k)))] = 1%r.
proof. by conseq sha256_x8_compress_ll (sha256_x8_compress_correct H B). qed.
