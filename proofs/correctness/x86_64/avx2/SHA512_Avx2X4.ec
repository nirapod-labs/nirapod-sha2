(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2X4.ec (x86_64, avx2)
 * ===============================
 *
 * Functional correctness and termination of the entry points of the
 * 4-way SHA-512 AVX2 kernel (src/x86_64/avx2/sha512_x4_compress.jinc)
 * against FIPS 180-4 section 6.4.2, lane by lane:
 *
 *   sha512_x4_compress_total        h4 <- compress on every lane, lane
 *                                   L's block being bytes 128 L .. 128 L
 *                                   + 127 of blocks
 *   sha512_x4_compress_lanes_total  n blocks of every lane from memory
 *                                   at in[L] + off, the fold of compress
 *                                   over their parse (section 5.2.2)
 *
 * with their hoare forms (_correct) and losslessness (_ll), and the 4 x 4
 * transpose of a quarter block into schedule words (transpose_x4).
 *
 * Domain of the lanes form: for every lane, in[L] + off + 128 n below
 * 2^64.
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray32 BArray256 BArray512 BArray2560.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Lanes64 Mem512 Rounds512 Lanes.
require import SHA512_Avx2X4Vec SHA512_Avx2X4Rounds SHA512_Avx2X4Sched SHA512_Avx2X4Block.
import SHA512.

clone SHA512_Avx2X4Vec.X4Lanes as B32 with theory A <- BArray32.
clone SHA512_Avx2X4Vec.X4Lanes as B512 with theory A <- BArray512.

(* ------------------------------------------------------------------ *)
(* __sha512_x4_transpose                                              *)

(* Column c of four rows: word c of each, byte-reversed. *)
op tc (a0 a1 a2 a3 : W256.t) (c : int) : W256.t =
  pk4 (bswap64 (a0 \bits64 c)) (bswap64 (a1 \bits64 c)) (bswap64 (a2 \bits64 c)) (bswap64 (a3 \bits64 c)).

lemma transpose_x4 (a0 a1 a2 a3 : W256.t) :
  hoare [M.__sha512_x4_transpose :
    r0 = a0 /\ r1 = a1 /\ r2 = a2 /\ r3 = a3 /\ mask = bswap_mask4 ==>
    res.`1 = tc a0 a1 a2 a3 0 /\ res.`2 = tc a0 a1 a2 a3 1 /\
    res.`3 = tc a0 a1 a2 a3 2 /\ res.`4 = tc a0 a1 a2 a3 3].
proof.
proc; wp; skip => &hr [#] -> -> -> -> -> /=.
by rewrite !(q4_perm20E, q4_perm31E) !vpshufb_bswap4 /tc !pk4_lane //=.
qed.

(* ------------------------------------------------------------------ *)
(* The message words                                                  *)

(* The sixteen big-endian words of lane L's block (section 5.2.2). *)
op bmsg4 (b : BArray512.t) (L : int) : W64.t list =
  blockwords (lane_block 128 (BArray512.to_list b) L).

lemma size_bmsg4 b L : 0 <= L < 4 => size (bmsg4 b L) = 16.
proof.
move=> hL; rewrite /bmsg4 size_blockwords // size_lane_block // 1:/#.
by rewrite BArray512.size_to_list /#.
qed.

lemma bswap_get64 (b : BArray512.t) i : 0 <= i < 64 =>
  bswap64 (BArray512.get64 b i) = be64 (take 8 (drop (8 * i) (BArray512.to_list b))).
proof.
move=> hi; rewrite /bswap64 /be64 BArray512.get64dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W8u8.size_to_list size_take // size_drop 1:/# BArray512.size_to_list /#.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list W8u8.get_pack8 1:BArray512.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray512.get_to_list.
by rewrite BArray512.nth_sub.
qed.

lemma slice8 (l : 'a list) a b : 0 <= a => a + 8 <= 128 => 0 <= b =>
  take 8 (drop a (take 128 (drop b l))) = take 8 (drop (b + a) l).
proof. by move=> ha h8 hb; rewrite drop_take // take_take ifT 1:/# drop_drop // addzC. qed.

(* Word 4 q + c of lane L's block is qword c of the 256-bit word 4 L + q
   of the block array, byte-reversed. *)
lemma bmsg4_nth b L q c : 0 <= L < 4 => 0 <= q < 4 => 0 <= c < 4 =>
  nth W64.zero (bmsg4 b L) (4 * q + c) = bswap64 (BArray512.get256 b (4 * L + q) \bits64 c).
proof.
move=> hL hq hc; rewrite /bmsg4 nth_blockwords 1:size_lane_block // 1,2,3:/#.
rewrite /lane_block slice8 1..3:/# B512.get256_bits64 // bswap_get64 1:/#.
by congr; congr; congr; ring.
qed.

(* Column c of quarter q: word 4 q + c of every lane. *)
op col4 (b : BArray512.t) (q c : int) : W256.t =
  tc (BArray512.get256 b q) (BArray512.get256 b (4 + q)) (BArray512.get256 b (8 + q))
     (BArray512.get256 b (12 + q)) c.

lemma col4_lane b q c L : 0 <= L < 4 => 0 <= q < 4 => 0 <= c < 4 =>
  col4 b q c \bits64 L = nth W64.zero (bmsg4 b L) (4 * q + c).
proof.
move=> hL hq hc; rewrite /col4 /tc pk4_lane // !bmsg4_nth //.
by have [->|[->|[->|->]]] := cases4 L hL.
qed.

lemma mask4E : BArray32.get256 sHA512_X4_BSWAP 0 = bswap_mask4.
proof.
apply W4u64.wordP => j hj.
by rewrite B32.get256_bits64 // BArray32.get64_of_list64 // /bswap_mask4 pk4_lane.
qed.

lemma cases16 j : 0 <= j < 16 =>
  j = 0 \/ j = 1 \/ j = 2 \/ j = 3 \/ j = 4 \/ j = 5 \/ j = 6 \/ j = 7 \/
  j = 8 \/ j = 9 \/ j = 10 \/ j = 11 \/ j = 12 \/ j = 13 \/ j = 14 \/ j = 15.
proof. smt(). qed.

(* The window after n quarters: word j of every lane in w[j], j < 4 n. *)
op wq (w b : BArray512.t) (n : int) =
  forall j, 0 <= j < 4 * n => BArray512.get256 w j = col4 b (j %/ 4) (j %% 4).

lemma wq_msg w b : wq w b 4 => msg w (bmsg4 b).
proof.
move=> h L j hL hj; rewrite h // col4_lane // 1,2:/#.
by rewrite {3}(divz_eq j 4); congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* _sha512_x4_compress                                                *)

lemma sha512_x4_compress_correct (h0 : BArray256.t) (b0 : BArray512.t) :
  hoare [M._sha512_x4_compress :
    h4 = h0 /\ blocks = b0 ==>
    forall L, 0 <= L < 4 => hl res.`1 L = compress (hl h0 L) (bmsg4 b0 L)].
proof.
proc; unroll for ^while.
seq 4 : (h4 = h0 /\ blocks = b0 /\ mask = bswap_mask4 /\ wq w b0 0).
+ by wp; skip => &hr [-> ->]; rewrite mask4E /= => j hj; smt().
seq 9 : (h4 = h0 /\ blocks = b0 /\ mask = bswap_mask4 /\ wq w b0 1).
+ wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] -> -> -> hw /=.
  move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]] j hj.
  have hj16 : 0 <= j < 16 by smt().
  move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
  by rewrite /=; try rewrite /col4 /=.
seq 9 : (h4 = h0 /\ blocks = b0 /\ mask = bswap_mask4 /\ wq w b0 2).
+ wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] -> -> -> hw /=.
  move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]] j hj.
  have hj16 : 0 <= j < 16 by smt().
  move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
  by rewrite /=; try rewrite /col4 /=.
seq 9 : (h4 = h0 /\ blocks = b0 /\ mask = bswap_mask4 /\ wq w b0 3).
+ wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] -> -> -> hw /=.
  move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]] j hj.
  have hj16 : 0 <= j < 16 by smt().
  move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
  by rewrite /=; try rewrite /col4 /=.
seq 9 : (h4 = h0 /\ blocks = b0 /\ mask = bswap_mask4 /\ wq w b0 4).
+ wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] -> -> -> hw /=.
  move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]] j hj.
  have hj16 : 0 <= j < 16 by smt().
  move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
  by rewrite /=; try rewrite /col4 /=.
ecall (block_x4 h0 (bmsg4 b0) (size_bmsg4 b0)); wp; skip => &hr [#] -> _ _ hw.
by split; [exact (wq_msg _ _ hw) | done].
qed.

(* ------------------------------------------------------------------ *)
(* _sha512_x4_compress_lanes                                          *)

abbrev memread = JWordList.memread.

(* Address of lane L's input. *)
op pL (in0 : BArray32.t) (off : W64.t) (L : int) : int = W64.to_uint (BArray32.get64 in0 L + off).

(* The sixteen words of the block at a (section 5.2.2). *)
op mbl4 (mem : global_mem_t) (a : int) : W64.t list = map be64 (chunk 8 (memread mem a 128)).

(* Lane L after i blocks. *)
op hcur4 (mem : global_mem_t) (h0 : BArray256.t) (in0 : BArray32.t) (off0 : W64.t) (i L : int) =
  foldl compress (hl h0 L) (parse (memread mem (pL in0 off0 L) (128 * i))).

op ldom (in0 : BArray32.t) (off0 n0 : W64.t) =
  forall L, 0 <= L < 4 => pL in0 off0 L + 128 * W64.to_uint n0 < W64.modulus.

(* What the block loop knows at the head of an iteration with n > 0. *)
op lfr (in_0 in0 : BArray32.t) (n n0 off off0 : W64.t) (more : bool) (h4 h0 : BArray256.t) mem =
  in_0 = in0 /\ 0 < W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
  off = off0 + W64.of_int (128 * (W64.to_uint n0 - W64.to_uint n)) /\ ldom in0 off0 n0 /\
  forall L, 0 <= L < 4 => hl h4 L = hcur4 mem h0 in0 off0 (W64.to_uint n0 - W64.to_uint n) L.

(* Address of lane L's current block. *)
op ad (in0 : BArray32.t) (off0 n0 n : W64.t) (L : int) : int =
  pL in0 off0 L + 128 * (W64.to_uint n0 - W64.to_uint n).

(* Column c of quarter q of the current blocks, as the transpose gives it. *)
op lc mem in0 off0 n0 n (q c : int) : W256.t =
  tc (loadW256 mem (ad in0 off0 n0 n 0 + 32 * q)) (loadW256 mem (ad in0 off0 n0 n 1 + 32 * q))
     (loadW256 mem (ad in0 off0 n0 n 2 + 32 * q)) (loadW256 mem (ad in0 off0 n0 n 3 + 32 * q)) c.

op wql (w : BArray512.t) mem in0 off0 n0 n (k : int) =
  forall j, 0 <= j < 4 * k => BArray512.get256 w j = lc mem in0 off0 n0 n (j %/ 4) (j %% 4).

lemma lc_lane mem in0 off0 n0 n q c L : 0 <= L < 4 => 0 <= q < 4 => 0 <= c < 4 =>
  lc mem in0 off0 n0 n q c \bits64 L = nth W64.zero (mbl4 mem (ad in0 off0 n0 n L)) (4 * q + c).
proof.
move=> hL hq hc; rewrite /lc /tc pk4_lane // /mbl4 nth_mblock512_mem 1:/#.
rewrite (_: ad in0 off0 n0 n L + 8 * (4 * q + c) = ad in0 off0 n0 n L + 32 * q + 8 * c) 1:/#.
by have [->|[->|[->|->]]] := cases4 L hL; rewrite /= loadW256_bits64.
qed.

lemma wql_msg w mem in0 off0 n0 n : wql w mem in0 off0 n0 n 4 =>
  msg w (fun L => mbl4 mem (ad in0 off0 n0 n L)).
proof.
move=> h L j hL hj; rewrite h // lc_lane // 1,2:/# /=.
by rewrite {3}(divz_eq j 4); congr; ring.
qed.

lemma addr_step (a off0 : W64.t) (i n0 : int) : 0 <= i => i < n0 =>
  W64.to_uint (a + off0) + 128 * n0 < W64.modulus =>
  W64.to_uint (a + (off0 + W64.of_int (128 * i))) = W64.to_uint (a + off0) + 128 * i.
proof.
move=> h0 h1 h2; have hc := W64.to_uint_cmp (a + off0).
have hm : 128 * i < W64.modulus by smt(pow2_64).
rewrite addrA W64.to_uintD_small !W64.of_uintK (pmod_small (128 * i)) //; smt(pow2_64).
qed.

lemma addr_small (p : W64.t) c : 0 <= c => W64.to_uint p + c < W64.modulus =>
  W64.to_uint (p + W64.of_int c) = W64.to_uint p + c.
proof. by move=> h0 h1; rewrite W64.to_uintD_small !W64.of_uintK (pmod_small c) //; smt(W64.to_uint_cmp pow2_64). qed.

lemma pt_ok (p : W64.t) in_0 in0 n n0 off off0 more h4 h0 mem L :
  lfr in_0 in0 n n0 off off0 more h4 h0 mem => 0 <= L < 4 =>
  p = BArray32.get64 in0 L + off => W64.to_uint p = ad in0 off0 n0 n L.
proof.
rewrite /lfr => -[#] _ hn0 hn1 _ -> hd _ hL ->.
have h0' : 0 <= W64.to_uint n0 - W64.to_uint n by smt().
have h1' : W64.to_uint n0 - W64.to_uint n < W64.to_uint n0 by smt().
exact (addr_step (BArray32.get64 in0 L) off0 _ _ h0' h1' (hd L hL)).
qed.

lemma bnd (x a b m q : int) : x = a => a + 128 <= b => b < m => 0 <= q < 4 => x + 32 * q < m.
proof. smt(). qed.

lemma pq_ok (p : W64.t) in_0 in0 n n0 off off0 more h4 h0 mem L q :
  lfr in_0 in0 n n0 off off0 more h4 h0 mem => 0 <= L < 4 => 0 <= q < 4 =>
  p = BArray32.get64 in0 L + off => W64.to_uint (p + W64.of_int (32 * q)) = ad in0 off0 n0 n L + 32 * q.
proof.
move=> hf hL hq hp; have tp := pt_ok _ _ _ _ _ _ _ _ _ _ _ _ hf hL hp.
move: hf; rewrite /lfr => -[#] _ hn0 hn1 _ _ hd _.
have hb1 : ad in0 off0 n0 n L + 128 <= pL in0 off0 L + 128 * W64.to_uint n0 by rewrite /ad; smt().
rewrite addr_small 1:/# 1:(bnd _ _ _ _ _ tp hb1 (hd L hL) hq).
by rewrite tp.
qed.

lemma hcur4S mem h0 in0 off0 i L : 0 <= i =>
  hcur4 mem h0 in0 off0 (i + 1) L = compress (hcur4 mem h0 in0 off0 i L) (mbl4 mem (pL in0 off0 L + 128 * i)).
proof. by move=> hi; rewrite /hcur4 parse512_memreadS // foldl_rcons. qed.

lemma size_mbl4_all mem (f : int -> int) : forall L, 0 <= L < 4 => size (mbl4 mem (f L)) = 16.
proof. by move=> L _; exact size_mblock512_mem. qed.

lemma sha512_x4_compress_lanes_correct (h0 : BArray256.t) (in0 : BArray32.t) (off0 n0 : W64.t) :
  hoare [M._sha512_x4_compress_lanes :
    h4 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ ldom in0 off0 n0 ==>
    forall L, 0 <= L < 4 =>
      hl res.`1 L = foldl compress (hl h0 L) (parse (memread Glob.mem (pL in0 off0 L) (128 * W64.to_uint n0)))].
proof.
proc.
wp; while (in_0 = in0 /\ 0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
           off = off0 + W64.of_int (128 * (W64.to_uint n0 - W64.to_uint n)) /\ ldom in0 off0 n0 /\
           forall L, 0 <= L < 4 => hl h4 L = hcur4 Glob.mem h0 in0 off0 (W64.to_uint n0 - W64.to_uint n) L).
+ unroll for ^while.
  (* lane pointers *)
  seq 15 : (lfr in_0 in0 n n0 off off0 more h4 h0 Glob.mem /\ mask = bswap_mask4 /\
            p0 = BArray32.get64 in0 0 + off /\ p1 = BArray32.get64 in0 1 + off /\
            p2 = BArray32.get64 in0 2 + off /\ p3 = BArray32.get64 in0 3 + off /\
            wql w Glob.mem in0 off0 n0 n 0).
  + wp; skip => &hr [[#] -> hn0 hn1 hmo hoff hd hh] hm.
    have hnz : 0 < W64.to_uint n{hr}.
    + have : n{hr} <> W64.zero by rewrite -hmo.
      by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
    rewrite mask4E /SLH64.protect_64 /=.
    split; 1: by do !split.
    by move=> j; smt().
  seq 9 : (lfr in_0 in0 n n0 off off0 more h4 h0 Glob.mem /\ mask = bswap_mask4 /\
            p0 = BArray32.get64 in0 0 + off /\ p1 = BArray32.get64 in0 1 + off /\
            p2 = BArray32.get64 in0 2 + off /\ p3 = BArray32.get64 in0 3 + off /\
            wql w Glob.mem in0 off0 n0 n 1).
  + wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] hf -> h0' h1' h2' h3' hw /=.
    have u0 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 0 hf _ h0'; 1: done.
    have u1 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 1 hf _ h1'; 1: done.
    have u2 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 2 hf _ h2'; 1: done.
    have u3 := pt_ok _ _ _ _ _ _ _ _ _ _ _ 3 hf _ h3'; 1: done.
    move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]]; rewrite ?u0 ?u1 ?u2 ?u3.
    do 5!(split; 1: done); move=> j hj.
    have hj16 : 0 <= j < 16 by smt().
    move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
    by rewrite /=; try rewrite /lc /=.
  seq 9 : (lfr in_0 in0 n n0 off off0 more h4 h0 Glob.mem /\ mask = bswap_mask4 /\
            p0 = BArray32.get64 in0 0 + off /\ p1 = BArray32.get64 in0 1 + off /\
            p2 = BArray32.get64 in0 2 + off /\ p3 = BArray32.get64 in0 3 + off /\
            wql w Glob.mem in0 off0 n0 n 2).
  + wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] hf -> h0' h1' h2' h3' hw /=.
    have u0 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 0 1 hf _ _ h0'; 1,2: done.
    have u1 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 1 1 hf _ _ h1'; 1,2: done.
    have u2 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 2 1 hf _ _ h2'; 1,2: done.
    have u3 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 3 1 hf _ _ h3'; 1,2: done.
    move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]]; rewrite ?u0 ?u1 ?u2 ?u3.
    do 5!(split; 1: done); move=> j hj.
    have hj16 : 0 <= j < 16 by smt().
    move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
    by rewrite /=; try rewrite /lc /=.
  seq 9 : (lfr in_0 in0 n n0 off off0 more h4 h0 Glob.mem /\ mask = bswap_mask4 /\
            p0 = BArray32.get64 in0 0 + off /\ p1 = BArray32.get64 in0 1 + off /\
            p2 = BArray32.get64 in0 2 + off /\ p3 = BArray32.get64 in0 3 + off /\
            wql w Glob.mem in0 off0 n0 n 3).
  + wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] hf -> h0' h1' h2' h3' hw /=.
    have u0 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 0 2 hf _ _ h0'; 1,2: done.
    have u1 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 1 2 hf _ _ h1'; 1,2: done.
    have u2 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 2 2 hf _ _ h2'; 1,2: done.
    have u3 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 3 2 hf _ _ h3'; 1,2: done.
    move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]]; rewrite ?u0 ?u1 ?u2 ?u3.
    do 5!(split; 1: done); move=> j hj.
    have hj16 : 0 <= j < 16 by smt().
    move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
    by rewrite /=; try rewrite /lc /=.
  seq 9 : (lfr in_0 in0 n n0 off off0 more h4 h0 Glob.mem /\ mask = bswap_mask4 /\
            p0 = BArray32.get64 in0 0 + off /\ p1 = BArray32.get64 in0 1 + off /\
            p2 = BArray32.get64 in0 2 + off /\ p3 = BArray32.get64 in0 3 + off /\
            wql w Glob.mem in0 off0 n0 n 4).
  + wp; ecall (transpose_x4 r0 r1 r2 r3); wp; skip => &hr [#] hf -> h0' h1' h2' h3' hw /=.
    have u0 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 0 3 hf _ _ h0'; 1,2: done.
    have u1 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 1 3 hf _ _ h1'; 1,2: done.
    have u2 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 2 3 hf _ _ h2'; 1,2: done.
    have u3 := pq_ok _ _ _ _ _ _ _ _ _ _ _ 3 3 hf _ _ h3'; 1,2: done.
    move=> [c0 c1 c2 c3] /= [-> [-> [-> ->]]]; rewrite ?u0 ?u1 ?u2 ?u3.
    do 5!(split; 1: done); move=> j hj.
    have hj16 : 0 <= j < 16 by smt().
    move: hj (hw j); have [->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|[->|->]]]]]]]]]]]]]]] := cases16 j hj16;
    by rewrite /=; try rewrite /lc /=.
  (* the rounds, and the next block *)
  wp; ecall (block_x4 h4 (fun L => mbl4 Glob.mem (ad in0 off0 n0 n L)) (size_mbl4_all Glob.mem (ad in0 off0 n0 n))).
  wp; skip => &hr [#] hf _ _ _ _ _ hw /=.
  split; 1: exact (wql_msg _ _ _ _ _ _ hw).
  move=> _ r hc.
  move: hf; rewrite /lfr => -[#] -> hn0 hn1 hmo hoff hd hh.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
  have hk : W64.to_uint n0 - (W64.to_uint n{hr} - 1) = (W64.to_uint n0 - W64.to_uint n{hr}) + 1 by ring.
  rewrite /SLH64.protect_ptr /SLH64.protect_64 hsub hk.
  split; 1: done. split; 1: smt().
  split; 1: by rewrite hoff -addrA -W64.of_intD; congr; congr; ring.
  split; 1: done.
  by move=> L hL; rewrite hcur4S 1:/# (hc L hL) (hh L hL) /ad.
wp; skip => &hr [#] -> -> -> -> hd; split.
+ have -> : W64.to_uint n0 - W64.to_uint n0 = 0 by ring.
  do 2!(split; 1: smt(W64.to_uint_cmp)). split; 1: done. split; 1: by rewrite /=.
  split; 1: done.
  have hp0 : parse [] = [] by rewrite /parse /chunk /= mkseq0.
  by move=> L hL; rewrite /hcur4 /= ?parse512_memread0 ?hp0.
move=> h4' in' more' ms' n' off' hm [#] _ hn0 hn1 hmo hoff _ hh L hL.
have hz : n' = W64.zero by smt().
by rewrite hh // hz /hcur4 /=.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range, except the block loop of
   _sha512_x4_compress_lanes, which runs n times, and the pass loop of
   the rounds, whose counter o goes from 512 to 2560 by 512. *)

lemma x4_round_ll : islossless M.__sha512_x4_round.
proof. by proc; inline *; auto. qed.

lemma x4_schedule_ll : islossless M.__sha512_x4_schedule.
proof. by proc; inline *; auto. qed.

lemma x4_schedule_true : hoare [M.__sha512_x4_schedule : true ==> true].
proof. by proc; inline *; auto. qed.

lemma x4_transpose_ll : islossless M.__sha512_x4_transpose.
proof. by proc; auto. qed.

lemma x4_block_ll : islossless M._sha512_x4_block.
proof.
proc; while (true) (8 - i); 1: by move=> z; auto => /#.
wp; while (more = (W64.to_uint o <= 2048) /\ 0 <= W64.to_uint o <= 2560) (2560 - W64.to_uint o).
+ move=> z; wp.
  while (true) (32 - t).
  + move=> z'; case (t %% 2 = 0).
    + rcondt ^if; 1: by wp; call x4_schedule_true; auto.
      by wp; call x4_round_ll; wp; call x4_schedule_ll; auto => /#.
    rcondf ^if; 1: by wp; call x4_schedule_true; auto.
    by wp; call x4_round_ll; wp; call x4_schedule_ll; auto => /#.
  auto => /> &hr ho0 ho1 hm t; have hoa := o_add o{hr} 512 _ _; 1,2: smt().
  by rewrite W64.uleE hoa W64.of_uintK /=; smt().
wp; while (true) (16 - t).
+ move=> z; case (t %% 2 = 0).
  + by rcondt ^if; [auto | wp; call x4_round_ll; auto => /#].
  by rcondf ^if; [auto | wp; call x4_round_ll; auto => /#].
wp; while (true) (8 - i); 1: by move=> z; auto => /#.
by auto => />; smt().
qed.

lemma sha512_x4_compress_ll : islossless M._sha512_x4_compress.
proof.
proc; call x4_block_ll; unroll for ^while.
by wp; call x4_transpose_ll; wp; call x4_transpose_ll; wp; call x4_transpose_ll; wp; call x4_transpose_ll; auto.
qed.

lemma sha512_x4_compress_lanes_ll : islossless M._sha512_x4_compress_lanes.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call x4_block_ll; unroll for ^while.
  wp; call x4_transpose_ll; wp; call x4_transpose_ll; wp; call x4_transpose_ll; wp; call x4_transpose_ll.
  auto => /> &hr hne.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + case: (W64.to_uint n{hr} = 0) => h1; last smt(W64.to_uint_cmp).
    by move: hne; rewrite W64.to_uint_eq h1.
  by rewrite /SLH64.protect_64 W64.to_uintB 1:W64.uleE /= /#.
auto => /> more n.
by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma sha512_x4_compress_total (h0 : BArray256.t) (b0 : BArray512.t) :
  phoare [M._sha512_x4_compress :
    h4 = h0 /\ blocks = b0 ==>
    forall L, 0 <= L < 4 => hl res.`1 L = compress (hl h0 L) (bmsg4 b0 L)] = 1%r.
proof. by conseq sha512_x4_compress_ll (sha512_x4_compress_correct h0 b0). qed.

lemma sha512_x4_compress_lanes_total (h0 : BArray256.t) (in0 : BArray32.t) (off0 n0 : W64.t) :
  phoare [M._sha512_x4_compress_lanes :
    h4 = h0 /\ in_0 = in0 /\ off = off0 /\ n = n0 /\ ldom in0 off0 n0 ==>
    forall L, 0 <= L < 4 =>
      hl res.`1 L = foldl compress (hl h0 L) (parse (memread Glob.mem (pL in0 off0 L) (128 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha512_x4_compress_lanes_ll (sha512_x4_compress_lanes_correct h0 in0 off0 n0). qed.
