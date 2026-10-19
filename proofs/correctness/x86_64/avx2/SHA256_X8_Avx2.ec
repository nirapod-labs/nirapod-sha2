(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_Avx2.ec (x86_64, avx2)
 * ===============================
 *
 * Functional correctness and termination of the entry points of the
 * 8-way SHA-256 AVX2 kernel (src/x86_64/avx2/sha256_x8_compress.jinc)
 * against FIPS 180-4 section 6.2.2, lane by lane:
 *
 *   sha256_x8_compress_total        h8 <- compress on every lane, lane
 *                                   L's block being bytes 64 L .. 64 L
 *                                   + 63 of blocks
 *   sha256_x8_compress_lanes_total  n blocks of every lane from memory
 *                                   at in[L] + off, the fold of compress
 *                                   over their parse (section 5.2.1)
 *
 * with their hoare forms (_correct) and losslessness (_ll).
 *
 * Domain of the lanes form: for every lane, in[L] + off + 64 n below
 * 2^64.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray32 BArray64 BArray256 BArray512 BArray2048.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Mem Rounds256 Lanes.
require import SHA256_X8_Avx2Vec SHA256_X8_Avx2Rounds SHA256_X8_Avx2Sched SHA256_X8_Avx2Block SHA256_X8_Avx2Tr.
import SHA256.

clone SHA256_X8_Avx2Vec.X8Lanes as A32 with theory A <- BArray32.
clone SHA256_X8_Avx2Vec.X8Lanes as A512 with theory A <- BArray512.

(* ------------------------------------------------------------------ *)
(* The message words                                                  *)

(* The sixteen big-endian words of lane L's block (section 5.2.1). *)
op bmsg (b : BArray512.t) (L : int) : W32.t list =
  blockwords (lane_block 64 (BArray512.to_list b) L).

lemma size_bmsg b L : 0 <= L < 8 => size (bmsg b L) = 16.
proof.
move=> hL; rewrite /bmsg size_blockwords // size_lane_block // 1:/#.
by rewrite BArray512.size_to_list /#.
qed.

lemma bswap_get32 (b : BArray512.t) i : 0 <= i < 128 =>
  bswap32 (BArray512.get32 b i) = be32 (take 4 (drop (4 * i) (BArray512.to_list b))).
proof.
move=> hi; rewrite /bswap32 /be32 BArray512.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# BArray512.size_to_list /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray512.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray512.get_to_list.
by rewrite BArray512.nth_sub.
qed.

lemma slice4 (l : 'a list) a b : 0 <= a => a + 4 <= 64 => 0 <= b =>
  take 4 (drop a (take 64 (drop b l))) = take 4 (drop (b + a) l).
proof. by move=> ha h4 hb; rewrite drop_take // take_take ifT 1:/# drop_drop // addzC. qed.

(* Word 8 q + k of lane L's block is dword k of the 256-bit word 2 L + q
   of the block array, byte-reversed. *)
lemma bmsg_nth b L q k : 0 <= L < 8 => 0 <= q < 2 => 0 <= k < 8 =>
  nth W32.zero (bmsg b L) (8 * q + k) = bswap32 (BArray512.get256 b (2 * L + q) \bits32 k).
proof.
move=> hL hq hk; rewrite /bmsg nth_blockwords 1:size_lane_block // 1,2,3:/#.
rewrite /lane_block slice4 1..3:/# A512.get256_bits32 // bswap_get32 1:/#.
by congr; congr; congr; ring.
qed.

lemma mask8_pk : bswap_mask8 =
  pk8 (W32.of_int 66051) (W32.of_int 67438087) (W32.of_int 134810123) (W32.of_int 202182159)
      (W32.of_int 66051) (W32.of_int 67438087) (W32.of_int 134810123) (W32.of_int 202182159).
proof. by apply W32u8.allP; rewrite /bswap_mask8 /bswap_mask32 /p4 /pk8 /=. qed.

lemma mask8E : BArray32.get256 sHA256_X8_BSWAP 0 = bswap_mask8.
proof.
rewrite mask8_pk; apply W8u32.wordP => j hj.
by rewrite A32.get256_bits32 // BArray32.get32_of_list32 // pk8_lane.
qed.


lemma cases8_8 j : 8 <= j < 16 =>
  j = 8 \/ j = 9 \/ j = 10 \/ j = 11 \/ j = 12 \/ j = 13 \/ j = 14 \/ j = 15.
proof. smt(). qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_compress                                                *)

lemma sha256_x8_compress_correct (h0 : BArray256.t) (b0 : BArray512.t) :
  hoare [M._sha256_x8_compress :
    h8 = h0 /\ blocks = b0 ==>
    forall L, 0 <= L < 8 => hl res.`1 L = compress (hl h0 L) (bmsg b0 L)].
proof.
proc; unroll for ^while; do 4!(unroll for ^while).
(* rows of the first half: bytes 64 L .. 64 L + 31 *)
seq 14 : (h8 = h0 /\ blocks = b0 /\ mask = bswap_mask8 /\
          forall L, 0 <= L < 8 => BArray256.get256 r L = BArray512.get256 b0 (2 * L)).
+ wp; skip => &hr [-> ->]; rewrite mask8E /= => L hL.
  by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL.
seq 1 : (h8 = h0 /\ blocks = b0 /\ mask = bswap_mask8 /\
         forall j L, 0 <= j < 8 => 0 <= L < 8 =>
           BArray256.get256 r j \bits32 L = bswap32 (BArray512.get256 b0 (2 * L) \bits32 j)).
+ ecall (transpose_x8 r); skip => &hr [#] -> -> -> hr /= r1 h1 j L hj hL.
  by rewrite h1 // hr.
(* words 0 .. 7 into the window; rows of the second half *)
seq 18 : (h8 = h0 /\ blocks = b0 /\ mask = bswap_mask8 /\
          (forall L j, 0 <= L < 8 => 0 <= j < 8 =>
             BArray512.get256 w j \bits32 L = nth W32.zero (bmsg b0 L) j) /\
          forall L, 0 <= L < 8 => BArray256.get256 r L = BArray512.get256 b0 (2 * L + 1)).
+ wp; skip => &hr [#] -> -> -> hr /=; split => [L j hL hj | L hL].
  + have e1 := hr j L hj hL; have e2 := bmsg_nth b0 L 0 j hL _ hj; 1: done.
    by move: e1 e2; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 j hj; rewrite /= => -> ->.
  by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL.
seq 1 : (h8 = h0 /\ blocks = b0 /\
         (forall L j, 0 <= L < 8 => 0 <= j < 8 =>
            BArray512.get256 w j \bits32 L = nth W32.zero (bmsg b0 L) j) /\
         forall j L, 0 <= j < 8 => 0 <= L < 8 =>
           BArray256.get256 r j \bits32 L = bswap32 (BArray512.get256 b0 (2 * L + 1) \bits32 j)).
+ ecall (transpose_x8 r); skip => &hr [#] -> -> -> hw hr /=.
  by move=> r1 h1; split; [exact hw | move=> j L hj hL; rewrite h1 // hr].
(* words 8 .. 15, then the rounds *)
ecall (block_x8 h0 (bmsg b0) (size_bmsg b0)).
wp; skip => &hr [#] -> _ hw hr /=; split => // L j hL hj.
have [hlo|hhi] : j < 8 \/ 8 <= j by smt().
+ have hj8 : 0 <= j < 8 by smt().
  have e1 := hw L j hL hj8.
  by move: e1; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 j hj8; rewrite /=.
have e1 := hr (j - 8) L _ hL; 1: smt().
have e2 := bmsg_nth b0 L 1 (j - 8) hL _ _; 1,2: smt().
move: e1 e2; rewrite (_: 8 * 1 + (j - 8) = j) 1:/#.
have hj16 : 8 <= j < 16 by smt().
by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8_8 j hj16; rewrite /= => -> ->.
qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_compress_lanes                                          *)

(* Address of lane L's input. *)
op pL (in0 : BArray64.t) (off : W64.t) (L : int) : int = W64.to_uint (BArray64.get64 in0 L + off).

(* The sixteen words of the block at a (section 5.2.1). *)
op mbl (mem : global_mem_t) (a : int) : W32.t list = map be32 (chunk 4 (memread mem a 64)).

(* Lane L after i blocks. *)
op hcur8 (mem : global_mem_t) (h0 : BArray256.t) (in0 : BArray64.t) (off0 : W64.t) (i L : int) =
  foldl compress (hl h0 L) (parse (memread mem (pL in0 off0 L) (64 * i))).

op ldom (in0 : BArray64.t) (off0 n0 : W64.t) =
  forall L, 0 <= L < 8 => pL in0 off0 L + 64 * W64.to_uint n0 < W64.modulus.

lemma addr_step (a off0 : W64.t) (i n0 : int) : 0 <= i => i < n0 =>
  W64.to_uint (a + off0) + 64 * n0 < W64.modulus =>
  W64.to_uint (a + (off0 + W64.of_int (64 * i))) = W64.to_uint (a + off0) + 64 * i.
proof.
move=> h0 h1 h2; have hc := W64.to_uint_cmp (a + off0).
have hm : 64 * i < W64.modulus by smt(pow2_64).
rewrite addrA W64.to_uintD_small !W64.of_uintK (pmod_small (64 * i)) //; smt(pow2_64).
qed.

lemma addr_small (p : W64.t) c : 0 <= c => W64.to_uint p + c < W64.modulus =>
  W64.to_uint (p + W64.of_int c) = W64.to_uint p + c.
proof. by move=> h0 h1; rewrite W64.to_uintD_small !W64.of_uintK (pmod_small c) //; smt(W64.to_uint_cmp pow2_64). qed.

(* Word 8 q + j of the block at a is dword j of the 256-bit load at
   a + 32 q, byte-reversed. *)
lemma mrow mem a q j : 0 <= q < 2 => 0 <= j < 8 =>
  bswap32 (loadW256 mem (a + 32 * q) \bits32 j) = nth W32.zero (mbl mem a) (8 * q + j).
proof. move=> hq hj; rewrite loadW256_bits32 // /mbl nth_mblock_mem 1:/#; congr; congr; ring. qed.

lemma addr_L in0 off0 i n0 L : 0 <= i < n0 => pL in0 off0 L + 64 * n0 < W64.modulus =>
  W64.to_uint (BArray64.get64 in0 L + (off0 + W64.of_int (64 * i))) = pL in0 off0 L + 64 * i.
proof. by move=> [h0 h1] hd; exact (addr_step _ _ _ _ h0 h1 hd). qed.

lemma size_mbl mem a : size (mbl mem a) = 16.
proof. exact size_mblock_mem. qed.

lemma size_mbl_all mem (f : int -> int) : forall L, 0 <= L < 8 => size (mbl mem (f L)) = 16.
proof. by move=> L _; exact size_mbl. qed.

(* One more block of every lane. *)
lemma hcur8S mem h0 in0 off0 i L : 0 <= i =>
  hcur8 mem h0 in0 off0 (i + 1) L = compress (hcur8 mem h0 in0 off0 i L) (mbl mem (pL in0 off0 L + 64 * i)).
proof. by move=> hi; rewrite /hcur8 parse_memreadS // foldl_rcons. qed.

(* What the block loop knows at the head of an iteration with n > 0. *)
op lfr (in_0 in0 : BArray64.t) (n n0 off off0 : W64.t) (more : bool) (h8 h0 : BArray256.t) mem =
  in_0 = in0 /\ 0 < W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
  off = off0 + W64.of_int (64 * (W64.to_uint n0 - W64.to_uint n)) /\ ldom in0 off0 n0 /\
  forall L, 0 <= L < 8 => hl h8 L = hcur8 mem h0 in0 off0 (W64.to_uint n0 - W64.to_uint n) L.

(* Address of lane L's current block. *)
op ad (in0 : BArray64.t) (off0 n0 n : W64.t) (L : int) : int =
  pL in0 off0 L + 64 * (W64.to_uint n0 - W64.to_uint n).

lemma pt_ok (p : W64.t) in_0 in0 n n0 off off0 more h8 h0 mem L :
  lfr in_0 in0 n n0 off off0 more h8 h0 mem => 0 <= L < 8 =>
  p = BArray64.get64 in0 L + off => W64.to_uint p = ad in0 off0 n0 n L.
proof.
rewrite /lfr => -[#] _ hn0 hn1 _ -> hd _ hL ->.
by rewrite /ad; apply (addr_L _ _ _ (W64.to_uint n0)); [smt() | exact (hd L hL)].
qed.

lemma ad_bound in_0 in0 n n0 off off0 more h8 h0 mem L :
  lfr in_0 in0 n n0 off off0 more h8 h0 mem => 0 <= L < 8 =>
  0 <= ad in0 off0 n0 n L /\ ad in0 off0 n0 n L + 64 <= pL in0 off0 L + 64 * W64.to_uint n0 /\
  pL in0 off0 L + 64 * W64.to_uint n0 < W64.modulus.
proof.
rewrite /lfr => -[#] _ hn0 hn1 _ _ hd _ hL; have := hd L hL; rewrite /ad /pL.
by have := W64.to_uint_cmp (BArray64.get64 in0 L + off0); smt().
qed.

lemma bnd32 (x a b m : int) : x = a => a + 64 <= b => b < m => x + 32 < m.
proof. smt(). qed.

lemma sha256_x8_compress_lanes_correct (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
    h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ ldom in0 off0 n0 ==>
    forall L, 0 <= L < 8 =>
      hl res.`1 L = foldl compress (hl h0 L) (parse (memread Glob.mem (pL in0 off0 L) (64 * W64.to_uint n0)))].
proof.
proc.
wp; while (in_0 = in0 /\ 0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
           off = off0 + W64.of_int (64 * (W64.to_uint n0 - W64.to_uint n)) /\ ldom in0 off0 n0 /\
           forall L, 0 <= L < 8 => hl h8 L = hcur8 Glob.mem h0 in0 off0 (W64.to_uint n0 - W64.to_uint n) L).
+ unroll for ^while; do 2!(unroll for ^while).
  (* lane pointers *)
  seq 27 : (in_0 = in0 /\ 0 < W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
            off = off0 + W64.of_int (64 * (W64.to_uint n0 - W64.to_uint n)) /\ ldom in0 off0 n0 /\
            (forall L, 0 <= L < 8 => hl h8 L = hcur8 Glob.mem h0 in0 off0 (W64.to_uint n0 - W64.to_uint n) L) /\
            mask = bswap_mask8 /\
            p0 = BArray64.get64 in0 0 + off /\ p1 = BArray64.get64 in0 1 + off /\
            p2 = BArray64.get64 in0 2 + off /\ p3 = BArray64.get64 in0 3 + off /\
            p4 = BArray64.get64 in0 4 + off /\ p5 = BArray64.get64 in0 5 + off /\
            p6 = BArray64.get64 in0 6 + off /\ p7 = BArray64.get64 in0 7 + off).
  + wp; skip => &hr [[#] -> hn0 hn1 hmo hoff hd hh] hm.
    have hnz : 0 < W64.to_uint n{hr}.
    + have : n{hr} <> W64.zero by rewrite -hmo.
      by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
    rewrite mask8E /SLH64.protect_64 /=.
    by do !split => //.
  (* rows of the first half *)
  seq 8 : (lfr in_0 in0 n n0 off off0 more h8 h0 Glob.mem /\ mask = bswap_mask8 /\
           p0 = BArray64.get64 in0 0 + off /\ p1 = BArray64.get64 in0 1 + off /\
           p2 = BArray64.get64 in0 2 + off /\ p3 = BArray64.get64 in0 3 + off /\
           p4 = BArray64.get64 in0 4 + off /\ p5 = BArray64.get64 in0 5 + off /\
           p6 = BArray64.get64 in0 6 + off /\ p7 = BArray64.get64 in0 7 + off /\
           forall L, 0 <= L < 8 => BArray256.get256 r L = loadW256 Glob.mem (ad in0 off0 n0 n L)).
  + wp; skip => &hr [#] hi hn0 hn1 hmo hoff hd hh hm h0' h1' h2' h3' h4' h5' h6' h7'.
    have hf : lfr in_0{hr} in0 n{hr} n0 off{hr} off0 more{hr} h8{hr} h0 Glob.mem{hr} by do !split.
    have t0 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 0 hf _ h0'; 1: done.
    have t1 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 1 hf _ h1'; 1: done.
    have t2 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 2 hf _ h2'; 1: done.
    have t3 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 3 hf _ h3'; 1: done.
    have t4 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 4 hf _ h4'; 1: done.
    have t5 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 5 hf _ h5'; 1: done.
    have t6 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 6 hf _ h6'; 1: done.
    have t7 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 7 hf _ h7'; 1: done.
    do 10!(split; 1: done).
    move=> L hL; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL;
    by rewrite /= ?(t0, t1, t2, t3, t4, t5, t6, t7).
  seq 1 : (lfr in_0 in0 n n0 off off0 more h8 h0 Glob.mem /\ mask = bswap_mask8 /\
           p0 = BArray64.get64 in0 0 + off /\ p1 = BArray64.get64 in0 1 + off /\
           p2 = BArray64.get64 in0 2 + off /\ p3 = BArray64.get64 in0 3 + off /\
           p4 = BArray64.get64 in0 4 + off /\ p5 = BArray64.get64 in0 5 + off /\
           p6 = BArray64.get64 in0 6 + off /\ p7 = BArray64.get64 in0 7 + off /\
           forall j L, 0 <= j < 8 => 0 <= L < 8 =>
             BArray256.get256 r j \bits32 L = bswap32 (loadW256 Glob.mem (ad in0 off0 n0 n L) \bits32 j)).
  + ecall (transpose_x8 r); skip => &hr /= [#] hf -> h0' h1' h2' h3' h4' h5' h6' h7' hr /=.
    by move=> r1 h1; do 9!(split; 1: done); move=> j L hj hL; rewrite h1 // hr.
  (* words 0 .. 7; rows of the second half *)
  seq 17 : (lfr in_0 in0 n n0 off off0 more h8 h0 Glob.mem /\ mask = bswap_mask8 /\
            (forall L j, 0 <= L < 8 => 0 <= j < 8 =>
               BArray512.get256 w j \bits32 L = nth W32.zero (mbl Glob.mem (ad in0 off0 n0 n L)) j) /\
            forall L, 0 <= L < 8 => BArray256.get256 r L = loadW256 Glob.mem (ad in0 off0 n0 n L + 32)).
  + wp; skip => &hr [#] hf -> h0' h1' h2' h3' h4' h5' h6' h7' hr /=.
    split; 1: done. split.
    + move=> L j hL hj; have e1 := hr j L hj hL.
      have e2 := mrow Glob.mem{hr} (ad in0 off0 n0 n{hr} L) 0 j _ hj; 1: done.
      move: e1 e2; rewrite /= => <- <-.
      by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 j hj.
    have u : forall (p : W64.t) L, 0 <= L < 8 => p = BArray64.get64 in0 L + off{hr} =>
      W64.to_uint (p + W64.of_int 32) = ad in0 off0 n0 n{hr} L + 32.
    + move=> p L hL hp; have [hb0 [hb1 hb2]] := ad_bound in_0{hr} in0 n{hr} n0 off{hr} off0 more{hr} h8{hr} h0 Glob.mem{hr} L hf hL.
      have tp := pt_ok _ _ _ _ _ _ _ _ _ _ _ _ hf hL hp.
      by rewrite addr_small // 1:(bnd32 _ _ _ _ tp hb1 hb2) tp.
    move=> L hL; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL; rewrite /=.
    + by rewrite (u _ 0 _ h0'). + by rewrite (u _ 1 _ h1'). + by rewrite (u _ 2 _ h2').
    + by rewrite (u _ 3 _ h3'). + by rewrite (u _ 4 _ h4'). + by rewrite (u _ 5 _ h5').
    + by rewrite (u _ 6 _ h6'). + by rewrite (u _ 7 _ h7').
  seq 1 : (lfr in_0 in0 n n0 off off0 more h8 h0 Glob.mem /\
           (forall L j, 0 <= L < 8 => 0 <= j < 8 =>
              BArray512.get256 w j \bits32 L = nth W32.zero (mbl Glob.mem (ad in0 off0 n0 n L)) j) /\
           forall j L, 0 <= j < 8 => 0 <= L < 8 =>
             BArray256.get256 r j \bits32 L = bswap32 (loadW256 Glob.mem (ad in0 off0 n0 n L + 32) \bits32 j)).
  + ecall (transpose_x8 r); skip => &hr [#] hf -> hw hr /=.
    by move=> r1 h1; split; 1: done; split; 1: done; move=> j L hj hL; rewrite h1 // hr.
  (* words 8 .. 15, the rounds, and the next block *)
  wp; ecall (block_x8 h8 (fun L => mbl Glob.mem (ad in0 off0 n0 n L)) (size_mbl_all Glob.mem (ad in0 off0 n0 n))).
  wp; skip => &hr [#] hf hw hr /=.
  split.
  + move=> L j hL hj; have [hlo|hhi] : j < 8 \/ 8 <= j by smt().
    + have hj8 : 0 <= j < 8 by smt().
      have e1 := hw L j hL hj8.
      by move: e1; have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 j hj8; rewrite /=.
    have e1 := hr (j - 8) L _ hL; 1: smt().
    have e2 := mrow Glob.mem{hr} (ad in0 off0 n0 n{hr} L) 1 (j - 8) _ _; 1,2: smt().
    move: e1 e2; rewrite (_: 8 * 1 + (j - 8) = j) 1:/#.
    have hj16 : 8 <= j < 16 by smt().
    by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8_8 j hj16; rewrite /= => -> <-.
  move=> _ r hc.
  move: hf; rewrite /lfr => -[#] -> hn0 hn1 hmo hoff hd hh.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
  have hk : W64.to_uint n0 - (W64.to_uint n{hr} - 1) = (W64.to_uint n0 - W64.to_uint n{hr}) + 1 by ring.
  rewrite /SLH64.protect_ptr /SLH64.protect_64 hsub hk.
  split; 1: done. split; 1: smt().
  split; 1: by rewrite hoff -addrA -W64.of_intD; congr; congr; ring.
  split; 1: done.
  by move=> L hL; rewrite hcur8S 1:/# (hc L hL) (hh L hL) /ad.
wp; skip => &hr [#] -> -> -> -> hd; split.
+ have -> : W64.to_uint n0 - W64.to_uint n0 = 0 by ring.
  do 2!(split; 1: smt(W64.to_uint_cmp)). split; 1: done. split; 1: by rewrite /=.
  split; 1: done.
  have hp0 : parse [] = [] by rewrite /parse /chunk /= mkseq0.
  by move=> L hL; rewrite /hcur8 /= ?parse_memread0 ?hp0.
move=> h8' in' more' ms' n' off' hm [#] _ hn0 hn1 hmo hoff _ hh L hL.
have hz : n' = W64.zero by smt().
by rewrite hh // hz /hcur8 /=.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range, except the block loop of
   _sha256_x8_compress_lanes, which runs n times, and the pass loop of
   the rounds, whose counter o goes from 512 to 2048 by 512. *)

lemma x8_round_ll : islossless M.__sha256_x8_round.
proof. by proc; inline *; auto. qed.

lemma x8_schedule_ll : islossless M.__sha256_x8_schedule.
proof. by proc; inline *; auto. qed.

lemma x8_transpose_ll : islossless M.__sha256_x8_transpose.
proof. by proc; unroll for ^while; unroll for ^while; auto. qed.

lemma x8_schedule_true : hoare [M.__sha256_x8_schedule : true ==> true].
proof. by proc; inline *; auto. qed.

lemma x8_block_ll : islossless M._sha256_x8_block.
proof.
proc; while (true) (8 - i); 1: by move=> z; auto => /#.
wp; while (more = (W64.to_uint o <= 1536) /\ 0 <= W64.to_uint o <= 2048) (2048 - W64.to_uint o).
+ move=> z; wp.
  while (true) (32 - t).
  + move=> z'; case (t %% 2 = 0).
    + rcondt ^if; 1: by wp; call x8_schedule_true; auto.
      by wp; call x8_round_ll; wp; call x8_schedule_ll; auto => /#.
    rcondf ^if; 1: by wp; call x8_schedule_true; auto.
    by wp; call x8_round_ll; wp; call x8_schedule_ll; auto => /#.
  auto => /> &hr ho0 ho1 hm t; have hoa := o_add o{hr} 512 _ _; 1,2: smt().
  by rewrite W64.uleE hoa W64.of_uintK /=; smt().
wp; while (true) (16 - t).
+ move=> z; case (t %% 2 = 0).
  + by rcondt ^if; [auto | wp; call x8_round_ll; auto => /#].
  by rcondf ^if; [auto | wp; call x8_round_ll; auto => /#].
wp; while (true) (8 - i); 1: by move=> z; auto => /#.
by auto => />; smt().
qed.

lemma sha256_x8_compress_ll : islossless M._sha256_x8_compress.
proof.
proc; call x8_block_ll; unroll for ^while; do 4!(unroll for ^while).
by wp; call x8_transpose_ll; wp; call x8_transpose_ll; auto.
qed.

lemma sha256_x8_compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call x8_block_ll; unroll for ^while; do 2!(unroll for ^while).
  wp; call x8_transpose_ll; wp; call x8_transpose_ll; auto => /> &hr hne.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + case: (W64.to_uint n{hr} = 0) => h1; last smt(W64.to_uint_cmp).
    by move: hne; rewrite W64.to_uint_eq h1.
  by rewrite /SLH64.protect_64 W64.to_uintB 1:W64.uleE /= /#.
auto => /> more n.
by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma sha256_x8_compress_total (h0 : BArray256.t) (b0 : BArray512.t) :
  phoare [M._sha256_x8_compress :
    h8 = h0 /\ blocks = b0 ==>
    forall L, 0 <= L < 8 => hl res.`1 L = compress (hl h0 L) (bmsg b0 L)] = 1%r.
proof. by conseq sha256_x8_compress_ll (sha256_x8_compress_correct h0 b0). qed.

lemma sha256_x8_compress_lanes_total (h0 : BArray256.t) (in0 : BArray64.t) (off0 n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
    h8 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ ldom in0 off0 n0 ==>
    forall L, 0 <= L < 8 =>
      hl res.`1 L = foldl compress (hl h0 L) (parse (memread Glob.mem (pL in0 off0 L) (64 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha256_x8_compress_lanes_ll (sha256_x8_compress_lanes_correct h0 in0 off0 n0). qed.
