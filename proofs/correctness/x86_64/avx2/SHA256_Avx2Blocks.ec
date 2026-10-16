(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_Avx2Blocks.ec
 * ====================
 *
 * The entry points of the SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_compress.jinc) against FIPS 180-4 section
 * 6.2.2: one block from a 64-byte array, one or two blocks from memory,
 * and n blocks from memory, each with termination, so that every
 * statement also holds as total correctness.
 *
 * Each entry fills the schedule window x: for 128-bit word i of a block,
 * VPBROADCASTI128 copies it into both halves (or VINSERTI128 puts the
 * same word of the second block in the upper half), and VPSHUFB with the
 * 32-bit byte-reversal mask turns the little-endian loads into the
 * big-endian words of section 3.1. Lane 4L + c of x[i] is then word
 * 4i + c of block L.
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray8 BArray32 BArray64 BArray128 BArray256 BArray512.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes32 Arrays Rounds256 Mem.
require import SHA256_Avx2Rounds SHA256_Avx2.
require JWordList.
import SHA256.

clone Arrays.ArrayLanes as L64 with theory A <- BArray64.

(* ------------------------------------------------------------------ *)
(* Blocks and the byte-reversal mask                                   *)

op mblock (blk : BArray64.t) : W32.t list = map be32 (chunk 4 (BArray64.to_list blk)).

lemma size_mblock blk : size (mblock blk) = 16.
proof. by rewrite /mblock size_map size_chunk // BArray64.size_to_list. qed.

lemma nth_mblock (blk : BArray64.t) k : 0 <= k < 16 =>
  nth W32.zero (mblock blk) k = bswap32 (BArray64.get32 blk k).
proof.
move=> hk; rewrite /mblock (nth_map []) 1:size_chunk // 1:BArray64.size_to_list 1:/#.
rewrite nth_chunk4 1:BArray64.size_to_list 1:/#.
apply eq_sym; rewrite /bswap32 /be32 BArray64.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# BArray64.size_to_list /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray64.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray64.get_to_list.
by rewrite BArray64.nth_sub.
qed.

lemma bmask_kernel : twice (BArray32.get256 sHA256_AVX2_BSWAP 0) bswap_mask32.
proof.
move=> i hi; rewrite L32.get256_bits32 // BArray32.get32_of_list32 1:/# /bswap_mask32 p4_lane 1:/#.
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 \/ i = 4 \/ i = 5 \/ i = 6 \/ i = 7 by smt().
by case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]].
qed.

lemma lane_bcast (w : W128.t) (mask : W256.t) L c : twice mask bswap_mask32 => 0 <= L < 2 => 0 <= c < 4 =>
  VPSHUFB_256 (VPBROADCAST_2u128 w) mask \bits32 (4 * L + c) = bswap32 (w \bits32 c).
proof.
move=> hm hL hc; have [_ hd] := lcdiv L c hc.
by rewrite (vpshufb_bswap32w _ _ _ (lc8 _ _ hL hc) hm) (vpbroadcast32 _ _ (lc8 _ _ hL hc)) hd.
qed.

lemma lane_two (w0 w1 : W128.t) (mask : W256.t) L c : twice mask bswap_mask32 => 0 <= L < 2 => 0 <= c < 4 =>
  VPSHUFB_256 (VINSERTI128 (VPBROADCAST_2u128 w0) w1 (W8.of_int 1)) mask \bits32 (4 * L + c)
  = bswap32 ((if L = 0 then w0 else w1) \bits32 c).
proof.
move=> hm hL hc; have [_ hd] := lcdiv L c hc.
rewrite (vpshufb_bswap32w _ _ _ (lc8 _ _ hL hc) hm) (vinserti128_32 _ _ _ (lc8 _ _ hL hc)).
rewrite (vpbroadcast32 _ _ (lc8 _ _ hL hc)) hd.
case: (L = 0) => hL0.
+ by rewrite hL0 ifT 1:/#.
rewrite ifF; 1: smt().
have -> : 4 * L + c - 4 = c by smt().
by rewrite ?ifF.
qed.

(* The two writes of x[i] in each entry's loop. *)
lemma xset (x : BArray128.t) i (B : W256.t) (mask : W256.t) r : 0 <= i < 4 => 0 <= r < 4 =>
  BArray128.get256 (BArray128.set256 (BArray128.set256 x i B) i
                      (VPSHUFB_256 (BArray128.get256 (BArray128.set256 x i B) i) mask)) r
  = if i = r then VPSHUFB_256 B mask else BArray128.get256 x r.
proof.
move=> hi hr; rewrite BArray128.get_set256E 1,2:/#.
rewrite (BArray128.get_set256E x i i) 1,2:/# /=.
by case: (i = r) => // hir; rewrite BArray128.get_set256E 1,2:/# ifF.
qed.

(* The three writes of x[i] in the loop of the two-block entry. *)
lemma xset3 (x : BArray128.t) i (B : W256.t) (w1 : W128.t) (mask : W256.t) r : 0 <= i < 4 => 0 <= r < 4 =>
  BArray128.get256
    (BArray128.set256
       (BArray128.set256 (BArray128.set256 x i B) i
          (VINSERTI128 (BArray128.get256 (BArray128.set256 x i B) i) w1 (W8.of_int 1))) i
       (VPSHUFB_256
          (BArray128.get256
             (BArray128.set256 (BArray128.set256 x i B) i
                (VINSERTI128 (BArray128.get256 (BArray128.set256 x i B) i) w1 (W8.of_int 1))) i)
          mask)) r
  = if i = r then VPSHUFB_256 (VINSERTI128 B w1 (W8.of_int 1)) mask else BArray128.get256 x r.
proof.
move=> hi hr; do !(rewrite BArray128.get_set256E 1,2:/#); rewrite /=.
by case: (i = r).
qed.

(* x holds the 16 words of blocks m0 (low halves) and m1 (high halves)
   in the window of group 0. *)
lemma win_init (x : BArray128.t) m0 m1 : size m0 = 16 => size m1 = 16 =>
  (forall r L c, 0 <= r < 4 => 0 <= L < 2 => 0 <= c < 4 =>
     BArray128.get256 x r \bits32 (4 * L + c) = nth W32.zero (lane L m0 m1) (4 * r + c)) =>
  win x m0 m1 0.
proof.
move=> hs0 hs1 hx r L c hr hL hc; rewrite /W nth_schedule_lo 1:size_lane // 1:/#.
by rewrite (_: (r - 0) %% 4 = r) 1:pmod_small //= hx.
qed.

(* ------------------------------------------------------------------ *)
(* One block from an array                                             *)

lemma sha256_compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==> hwords res.`1 = compress h0 (mblock blk)].
proof.
proc.
ecall (avx2_driver h0 (mblock blk) (mblock blk) 1).
while (0 <= i <= 4 /\ hwords h = h0 /\ block = blk /\ twice mask bswap_mask32 /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 4 =>
         BArray128.get256 x r \bits32 (4 * L + c) = nth W32.zero (mblock blk) (4 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset 1,2:/#.
  case: (i{hr} = r) => hir.
  + by rewrite (lane_bcast _ _ _ _ hm hL hc) L64.get128_bits32 // nth_mblock 1:/# -hir hb.
  by apply hx => //; smt().
wp; skip => &hr [hh hb]; split.
+ by rewrite hh hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ hm hx; split.
+ rewrite /= hh size_mblock /=; apply win_init; 1,2: exact size_mblock.
  by move=> r L c hr hL hc'; rewrite /lane; case: (L = 0) => _; apply hx => //; smt().
by move=> _ r /=.
qed.

(* ------------------------------------------------------------------ *)
(* One and two blocks from memory                                      *)

(* The block of 64 bytes at a. *)
op mblk (mem : global_mem_t) (a : int) : W32.t list = map be32 (chunk 4 (JWordList.memread mem a 64)).

lemma size_mblk mem a : size (mblk mem a) = 16.
proof. exact size_mblock_mem. qed.

lemma addr16 (p : W64.t) r : 0 <= r < 4 => W64.to_uint p + 64 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (16 * r)) = W64.to_uint p + 16 * r.
proof.
move=> hr hp; have h16 : W64.to_uint (W64.of_int (16 * r)) = 16 * r.
+ by rewrite W64.of_uintK pmod_small //; smt().
rewrite W64.to_uintD_small.
+ by rewrite h16; move: hp hr; clear h16; smt().
by rewrite h16.
qed.

lemma lane_mem mem (p : W64.t) r c : 0 <= r < 4 => 0 <= c < 4 => W64.to_uint p + 64 <= W64.modulus =>
  bswap32 (loadW128 mem (W64.to_uint (p + W64.of_int (16 * r))) \bits32 c)
  = nth W32.zero (mblk mem (W64.to_uint p)) (4 * r + c).
proof.
move=> hr hc hp; rewrite /mblk nth_mblock_mem 1:/# loadW128_bits32 // addr16 //.
by congr; congr; ring.
qed.

lemma sha256_compress_one_correct (h0 : W32.t list) (p0 : W64.t) :
  hoare [M._sha256_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus ==>
           hwords res.`1 = compress h0 (mblk Glob.mem (W64.to_uint p0))].
proof.
proc.
ecall (avx2_driver h0 (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0)) 1).
while (0 <= i <= 4 /\ hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus /\ twice mask bswap_mask32 /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 4 =>
         BArray128.get256 x r \bits32 (4 * L + c) = nth W32.zero (mblk Glob.mem (W64.to_uint p0)) (4 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hp hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset 1,2:/#.
  case: (i{hr} = r) => hir.
  + have hr4 : 0 <= i{hr} < 4 by move: hi0 hi; clear hx; smt().
    by rewrite (lane_bcast _ _ _ _ hm hL hc) -hir hp (lane_mem _ _ _ _ hr4 hc hb).
  by apply hx => //; smt().
wp; skip => &hr [hh [hp hb]]; split.
+ by rewrite hh hp hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ _ hm hx; split.
+ rewrite /= hh size_mblk /=; apply win_init; 1,2: exact size_mblk.
  by move=> r L c hr hL hc'; rewrite /lane; case: (L = 0) => _; apply hx => //; smt().
by move=> _ r /=.
qed.

lemma sha256_compress_two_correct (h0 : W32.t list) (p0 : W64.t) :
  hoare [M._sha256_compress_two :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus ==>
           hwords res.`1 = compress (compress h0 (mblk Glob.mem (W64.to_uint p0)))
                                    (mblk Glob.mem (W64.to_uint p0 + 64))].
proof.
proc.
ecall (avx2_driver h0 (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0 + 64)) 2).
while (0 <= i <= 4 /\ hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus /\ twice mask bswap_mask32 /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 4 =>
         BArray128.get256 x r \bits32 (4 * L + c)
         = nth W32.zero (lane L (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0 + 64)))
             (4 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hp hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset3 1,2:/#.
  case: (i{hr} = r) => hir; last by apply hx => //; smt().
  have hi4 : 0 <= i{hr} < 4 by move: hi0 hi; clear hx; smt().
  have hb1 : W64.to_uint p0 + 64 <= W64.modulus by move: hb; clear hx; smt().
  rewrite (lane_two _ _ _ _ _ hm hL hc) -hir hp /lane; case: (L = 0) => _.
  + by rewrite (lane_mem _ _ _ _ hi4 hc hb1).
  have h64 : W64.to_uint (p0 + W64.of_int 64) = W64.to_uint p0 + 64.
  + have h1 : W64.to_uint (W64.of_int 64) = 64 by rewrite W64.of_uintK pmod_small.
    by rewrite W64.to_uintD_small; [rewrite h1; move: hb; clear hx h1; smt() | rewrite h1].
  have hb2 : W64.to_uint (p0 + W64.of_int 64) + 64 <= W64.modulus.
  + by rewrite h64; move: hb; clear hx h64; smt().
  by rewrite (lane_mem _ _ _ _ hi4 hc hb2) h64.
wp; skip => &hr [hh [hp hb]]; split.
+ by rewrite hh hp hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ _ hm hx; split.
+ rewrite /= hh !size_mblk /=; apply win_init; 1,2: exact size_mblk.
  by move=> r L c hr hL hc'; apply hx => //; smt().
by move=> _ r /=.
qed.

(* ------------------------------------------------------------------ *)
(* n blocks from memory                                                *)

lemma fold1 h0 mem a k : 0 <= k =>
  foldl compress h0 (parse (JWordList.memread mem a (64 * (k + 1))))
  = compress (foldl compress h0 (parse (JWordList.memread mem a (64 * k)))) (mblk mem (a + 64 * k)).
proof. by move=> hk; rewrite parse_memreadS // foldl_rcons. qed.

lemma fold2 h0 mem a k : 0 <= k =>
  foldl compress h0 (parse (JWordList.memread mem a (64 * (k + 2))))
  = compress (compress (foldl compress h0 (parse (JWordList.memread mem a (64 * k))))
                       (mblk mem (a + 64 * k))) (mblk mem (a + 64 * k + 64)).
proof.
move=> hk; rewrite (_: k + 2 = k + 1 + 1) 1:/# fold1 1:/# fold1 //.
by have -> : a + 64 * (k + 1) = a + 64 * k + 64 by ring.
qed.

lemma ule2 (n : W64.t) : (W64.of_int 2 \ule n) = (2 <= W64.to_uint n).
proof. by rewrite W64.uleE W64.of_uintK pmod_small. qed.

(* The loop of _sha256_compress_blocks after n0 - n blocks. *)
op binv (h0 : W32.t list) (mem : global_mem_t) (p0 n0 : W64.t) (h : BArray32.t) (p n : W64.t) =
  0 <= W64.to_uint n <= W64.to_uint n0 /\
  W64.to_uint p = W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) /\
  W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus /\
  hwords h = foldl compress h0
    (parse (JWordList.memread mem (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n)))).

lemma binv_room h0 mem p0 n0 h p n : binv h0 mem p0 n0 h p n => 1 <= W64.to_uint n =>
  W64.to_uint p + 64 * W64.to_uint n < W64.modulus.
proof.
rewrite /binv => [#] hn0 hn1 hp hm _ h1; rewrite hp.
by have -> : W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) + 64 * W64.to_uint n
           = W64.to_uint p0 + 64 * W64.to_uint n0 by ring.
qed.

lemma binv_two h0 mem p0 n0 h p n h' :
  binv h0 mem p0 n0 h p n => 2 <= W64.to_uint n =>
  hwords h' = compress (compress (hwords h) (mblk mem (W64.to_uint p))) (mblk mem (W64.to_uint p + 64)) =>
  binv h0 mem p0 n0 h' (p + W64.of_int 128) (n - W64.of_int 2).
proof.
rewrite /binv => [#] hn0 hn1 hp hm hh h2 hh'.
have h2' : W64.to_uint (W64.of_int 2) = 2 by rewrite W64.of_uintK pmod_small.
have hs : W64.to_uint (n - W64.of_int 2) = W64.to_uint n - 2.
+ by rewrite W64.to_uintB 1:ule2 // h2'.
have h256 : W64.to_uint (W64.of_int 128) = 128 by rewrite W64.of_uintK pmod_small.
have ha : W64.to_uint (p + W64.of_int 128) = W64.to_uint p + 128.
+ rewrite W64.to_uintD_small h256 //; move: hp hm h2 hn1; clear hh hh' hs; smt().
rewrite hs ha; split; 1: by move: hn0 hn1 h2; clear hh hh' hp hm ha; smt().
split; 1: by rewrite hp; ring.
split; 1: exact hm.
rewrite hh' hh (_: W64.to_uint n0 - (W64.to_uint n - 2) = (W64.to_uint n0 - W64.to_uint n) + 2) 1:/#.
by rewrite fold2 1:/# hp.
qed.

lemma binv_one h0 mem p0 n0 h p n h' :
  binv h0 mem p0 n0 h p n => W64.to_uint n = 1 =>
  hwords h' = compress (hwords h) (mblk mem (W64.to_uint p)) =>
  hwords h' = foldl compress h0 (parse (JWordList.memread mem (W64.to_uint p0) (64 * W64.to_uint n0))).
proof.
rewrite /binv => [#] hn0 hn1 hp hm hh h1 hh'.
have e : 64 * W64.to_uint n0 = 64 * ((W64.to_uint n0 - W64.to_uint n) + 1) by rewrite h1; ring.
by rewrite hh' hh e fold1 1:/# hp.
qed.

lemma sha256_compress_blocks_correct (h0 : W32.t list) (p0 n0 : W64.t) :
  hoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))].
proof.
proc.
seq 4 : (binv h0 Glob.mem p0 n0 h p n /\ W64.to_uint n < 2 /\ more = (n <> W64.zero)).
+ wp; while (binv h0 Glob.mem p0 n0 h p n /\ more = (2 <= W64.to_uint n)).
  + wp; ecall (sha256_compress_two_correct (hwords h) p); wp; skip => &hr [[hI hm] hmore].
    have h2 : 2 <= W64.to_uint n{hr} by rewrite -hm.
    have hr8 := binv_room _ _ _ _ _ _ _ hI _; 1: by move: h2; clear hI; smt().
    split.
    + split; 1: done. split; 1: done. by move: hr8 h2; clear hI; smt().
    move=> _ r hr'; rewrite /SLH64.protect_64 /=.
    by split; [exact (binv_two _ _ _ _ _ _ _ _ hI h2 hr') | exact (ule2 _)].
  wp; skip => &hr /= [#] hh hp hn hb; split.
  + rewrite hp hn ule2 /=; rewrite /binv.
    split; 1: smt(W64.to_uint_cmp).
    split; 1: ring.
    split; 1: exact hb.
    by rewrite (_: 64 * (W64.to_uint n0 - W64.to_uint n0) = 0) 1:/# parse_memread0 /= hh.
  move=> h1 more0 n1 p1 hc [hI hm]; split; 1: exact hI.
  by move: hc; rewrite hm; clear hI; smt().
if.
+ wp; ecall (sha256_compress_one_correct (hwords h) p); wp; skip => &hr [[hI [hn2 hmore]] hc].
  have h1 : W64.to_uint n{hr} = 1.
  + have hne : n{hr} <> W64.zero by rewrite -hmore.
    have hn0 : 0 <= W64.to_uint n{hr} by move: hI => @/binv [#].
    case: (W64.to_uint n{hr} = 0) => hz; last by move: hn2 hn0 hz; clear hI; smt().
    by move: hne; rewrite W64.to_uint_eq hz W64.to_uint0.
  split.
  + split; 1: done. split; 1: done.
    have := binv_room _ _ _ _ _ _ _ hI _; 1: by rewrite h1.
    by rewrite h1 /=; apply ltzW.
  move=> _ r hr' /=.
  exact (binv_one _ _ _ _ _ _ _ _ hI h1 hr').
wp; skip => &hr [[hI [hn2 hmore]] hc].
have hz : n{hr} = W64.zero by move: hc; rewrite hmore.
move: hI => @/binv [_ [_ [_ hh]]].
by move: hh; rewrite hz W64.to_uint0 /=.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range or one that shrinks with n, so
   every procedure terminates on every input. *)
lemma round_ll : islossless M.__sha256_avx2_round.
proof. by proc; auto. qed.

lemma driver_ll : islossless M.__sha256_avx2.
proof.
proc.
while (true) (inc - l).
+ move=> z.
  wp; while (true) (8 - i); 1: by move=> z'; auto => /#.
  wp; while (true) (64 - t).
  + by move=> z'; wp; sp; if; [call round_ll | call round_ll]; auto => /#.
  by auto => /#.
wp; while (true) (8 - i); 1: by move=> z; auto => /#.
wp; while (true) (4 - i); 1: by move=> z; auto => /#.
by auto => /#.
qed.

lemma sha256_compress_ll : islossless M._sha256_compress.
proof.
proc; call driver_ll.
while (0 <= i <= 4) (4 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_one_ll : islossless M._sha256_compress_one.
proof.
proc; call driver_ll.
while (0 <= i <= 4) (4 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_two_ll : islossless M._sha256_compress_two.
proof.
proc; call driver_ll.
while (0 <= i <= 4) (4 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_blocks_ll : islossless M._sha256_compress_blocks.
proof.
proc.
seq 4 : true; 1: by conseq (_: true ==> true).
+ wp; while (more = (2 <= W64.to_uint n)) (W64.to_uint n).
  + move=> z; wp; call sha256_compress_two_ll; auto => /> &m hn.
    move=> r; rewrite /SLH64.protect_64 ule2 W64.to_uintB 1:ule2 //.
    have -> : W64.to_uint (W64.of_int 2) = 2 by rewrite W64.of_uintK pmod_small.
    smt().
  by auto; smt(ule2).
+ by if; [call sha256_compress_one_ll; auto | auto].
+ by hoare; conseq (_: true ==> true).
by [].
qed.

lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==> hwords res.`1 = compress h0 (mblock blk)] = 1%r.
proof. by conseq sha256_compress_ll (sha256_compress_correct h0 blk). qed.

lemma sha256_compress_one_total (h0 : W32.t list) (p0 : W64.t) :
  phoare [M._sha256_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus ==>
           hwords res.`1 = compress h0 (mblk Glob.mem (W64.to_uint p0))] = 1%r.
proof. by conseq sha256_compress_one_ll (sha256_compress_one_correct h0 p0). qed.

lemma sha256_compress_two_total (h0 : W32.t list) (p0 : W64.t) :
  phoare [M._sha256_compress_two :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus ==>
           hwords res.`1 = compress (compress h0 (mblk Glob.mem (W64.to_uint p0)))
                                    (mblk Glob.mem (W64.to_uint p0 + 64))] = 1%r.
proof. by conseq sha256_compress_two_ll (sha256_compress_two_correct h0 p0). qed.

lemma sha256_compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha256_compress_blocks_ll (sha256_compress_blocks_correct h0 p0 n0). qed.
