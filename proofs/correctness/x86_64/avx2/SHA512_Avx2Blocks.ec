(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_Avx2Blocks.ec
 * ====================
 *
 * The entry points of the SHA-512 AVX2 kernel
 * (src/x86_64/avx2/sha512_compress.jinc) against FIPS 180-4 section
 * 6.4.2: one block from a 128-byte array, one or two blocks from memory,
 * and n blocks from memory, each with termination, so that every
 * statement also holds as total correctness.
 *
 * Each entry fills the schedule window x: for 128-bit word i of a block,
 * VPBROADCASTI128 copies it into both halves (or VINSERTI128 puts the
 * same word of the second block in the upper half), and VPSHUFB with the
 * 64-bit byte-reversal mask turns the little-endian loads into the
 * big-endian words of section 3.1. Lane 2L + c of x[i] is then word
 * 2i + c of block L.
 *
 * Model. NirapodSha2 is the model of a unit whose Sha512Kernel root is
 * src/x86_64/avx2 (proofs/Makefile).
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray32 BArray64 BArray128 BArray256 BArray640 BArray1280.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Bmi Lanes64 Arrays Rounds512 Mem512.
require import SHA512_Avx2Rounds SHA512_Avx2.
require JWordList.
import SHA512.

clone Arrays.ArrayLanes as L32 with theory A <- BArray32.
clone Arrays.ArrayLanes as L128 with theory A <- BArray128.

(* ------------------------------------------------------------------ *)
(* Blocks and the byte-reversal mask                                   *)

(* Word k of a block array, read big-endian. *)
lemma bswap_get64 (blk : BArray128.t) k : 0 <= k < 16 =>
  WordSpec.bswap64 (BArray128.get64 blk k) = be64 (take 8 (drop (8 * k) (BArray128.to_list blk))).
proof.
move=> hk; rewrite /WordSpec.bswap64 /be64 BArray128.get64dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W8u8.size_to_list size_take // size_drop 1:/# BArray128.size_to_list /#.
move=> j; rewrite W8u8.size_to_list => hj.
rewrite W8u8.nth_to_list W8u8.get_pack8 1:BArray128.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray128.get_to_list.
by rewrite BArray128.nth_sub.
qed.

op mblock (blk : BArray128.t) : W64.t list = map be64 (chunk 8 (BArray128.to_list blk)).

lemma nth_mblock (blk : BArray128.t) k : 0 <= k < 16 =>
  nth W64.zero (mblock blk) k = WordSpec.bswap64 (BArray128.get64 blk k).
proof.
move=> hk; rewrite /mblock (nth_map []); first by rewrite size_chunk // BArray128.size_to_list /#.
by rewrite nth_chunk8 1:BArray128.size_to_list 1:/# bswap_get64.
qed.

lemma size_mblock (blk : BArray128.t) : size (mblock blk) = 16.
proof. by rewrite /mblock size_map size_chunk // BArray128.size_to_list. qed.

op bmask (m : W256.t) =
  m \bits64 0 = W64.of_int 283686952306183 /\ m \bits64 1 = W64.of_int 579005069656919567 /\
  m \bits64 2 = W64.of_int 283686952306183 /\ m \bits64 3 = W64.of_int 579005069656919567.

lemma bmask_kernel : bmask (BArray32.get256 sHA512_AVX2_BSWAP 0).
proof. by rewrite /bmask !L32.get256_bits64 // !BArray32.get64_of_list64. qed.

lemma lane_bcast (w : W128.t) (mask : W256.t) L c : bmask mask => 0 <= L < 2 => 0 <= c < 2 =>
  VPSHUFB_256 (VPBROADCAST_2u128 w) mask \bits64 (2 * L + c) = WordSpec.bswap64 (w \bits64 c).
proof.
rewrite /bmask => [#] h0 h1 h2 h3 hL hc.
by rewrite (vpshufb_bswap64 _ _ _ (lc4 _ _ hL hc) h0 h1 h2 h3) (vpbroadcast64 _ _ (lc4 _ _ hL hc)) (lc2 _ _ hc).
qed.

lemma lane_two (w0 w1 : W128.t) (mask : W256.t) L c : bmask mask => 0 <= L < 2 => 0 <= c < 2 =>
  VPSHUFB_256 (VINSERTI128 (VPBROADCAST_2u128 w0) w1 (W8.of_int 1)) mask \bits64 (2 * L + c)
  = WordSpec.bswap64 ((if L = 0 then w0 else w1) \bits64 c).
proof.
rewrite /bmask => [#] h0 h1 h2 h3 hL hc.
rewrite (vpshufb_bswap64 _ _ _ (lc4 _ _ hL hc) h0 h1 h2 h3) (vinserti128_64 _ _ _ (lc4 _ _ hL hc)).
rewrite (vpbroadcast64 _ _ (lc4 _ _ hL hc)) (lc2 _ _ hc).
case: (L = 0) => hL0.
+ by rewrite hL0 ifT 1:/#.
rewrite ifF; 1: smt().
have -> : 2 * L + c - 2 = c by smt().
by rewrite ?ifF.
qed.

(* The two writes of x[i] in each entry's loop. *)
lemma xset (x : BArray256.t) i (B : W256.t) (mask : W256.t) r : 0 <= i < 8 => 0 <= r < 8 =>
  BArray256.get256 (BArray256.set256 (BArray256.set256 x i B) i
                      (VPSHUFB_256 (BArray256.get256 (BArray256.set256 x i B) i) mask)) r
  = if i = r then VPSHUFB_256 B mask else BArray256.get256 x r.
proof.
move=> hi hr; rewrite BArray256.get_set256E 1,2:/#.
rewrite (BArray256.get_set256E x i i) 1,2:/# /=.
by case: (i = r) => // hir; rewrite BArray256.get_set256E 1,2:/# ifF.
qed.

(* x holds the 16 words of blocks m0 (low halves) and m1 (high halves)
   in the window of group 0. *)
lemma win0 (x : BArray256.t) m0 m1 : size m0 = 16 => size m1 = 16 =>
  (forall r L c, 0 <= r < 8 => 0 <= L < 2 => 0 <= c < 2 =>
     BArray256.get256 x r \bits64 (2 * L + c) = nth W64.zero (lane L m0 m1) (2 * r + c)) =>
  win x m0 m1 0.
proof.
move=> hs0 hs1 hx r L c hr hL hc; rewrite /W nth_schedule_lo 1:size_lane // 1:/#.
by rewrite (_: (r - 0) %% 8 = r) 1:pmod_small //= hx.
qed.

(* ------------------------------------------------------------------ *)
(* One block from an array                                             *)

lemma sha512_compress_correct (h0 : W64.t list) (blk : BArray128.t) :
  hoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==> hwords res.`1 = compress h0 (mblock blk)].
proof.
proc.
ecall (avx2_driver h0 (mblock blk) (mblock blk) 1).
while (0 <= i <= 8 /\ hwords h = h0 /\ block = blk /\ bmask mask /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 2 =>
         BArray256.get256 x r \bits64 (2 * L + c) = nth W64.zero (mblock blk) (2 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset 1,2:/#.
  case: (i{hr} = r) => hir.
  + by rewrite (lane_bcast _ _ _ _ hm hL hc) L128.get128_bits64 // nth_mblock 1:/# -hir hb.
  by apply hx => //; smt().
wp; skip => &hr [hh hb]; split.
+ by rewrite hh hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ hm hx; split.
+ rewrite /= hh size_mblock /=; apply win0; 1,2: exact size_mblock.
  by move=> r L c hr hL hc'; rewrite /lane; case: (L = 0) => _; apply hx => //; smt().
by move=> _ r /=.
qed.

(* The three writes of x[i] in the loop of the two-block entry. *)
lemma xset3 (x : BArray256.t) i (B : W256.t) (w1 : W128.t) (mask : W256.t) r : 0 <= i < 8 => 0 <= r < 8 =>
  BArray256.get256
    (BArray256.set256
       (BArray256.set256 (BArray256.set256 x i B) i
          (VINSERTI128 (BArray256.get256 (BArray256.set256 x i B) i) w1 (W8.of_int 1))) i
       (VPSHUFB_256
          (BArray256.get256
             (BArray256.set256 (BArray256.set256 x i B) i
                (VINSERTI128 (BArray256.get256 (BArray256.set256 x i B) i) w1 (W8.of_int 1))) i)
          mask)) r
  = if i = r then VPSHUFB_256 (VINSERTI128 B w1 (W8.of_int 1)) mask else BArray256.get256 x r.
proof.
move=> hi hr; do !(rewrite BArray256.get_set256E 1,2:/#); rewrite /=.
by case: (i = r).
qed.

(* ------------------------------------------------------------------ *)
(* One and two blocks from memory                                      *)

(* The block of 128 bytes at a. *)
op mblk (mem : global_mem_t) (a : int) : W64.t list = map be64 (chunk 8 (JWordList.memread mem a 128)).

lemma size_mblk mem a : size (mblk mem a) = 16.
proof. exact size_mblock512_mem. qed.

lemma addr16 (p : W64.t) r : 0 <= r < 8 => W64.to_uint p + 128 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (16 * r)) = W64.to_uint p + 16 * r.
proof.
move=> hr hp; have h16 : W64.to_uint (W64.of_int (16 * r)) = 16 * r.
+ by rewrite W64.of_uintK pmod_small //; smt().
rewrite W64.to_uintD_small.
+ by rewrite h16; move: hp hr; clear h16; smt().
by rewrite h16.
qed.

lemma lane_mem mem (p : W64.t) r c : 0 <= r < 8 => 0 <= c < 2 => W64.to_uint p + 128 <= W64.modulus =>
  WordSpec.bswap64 (loadW128 mem (W64.to_uint (p + W64.of_int (16 * r))) \bits64 c)
  = nth W64.zero (mblk mem (W64.to_uint p)) (2 * r + c).
proof.
move=> hr hc hp; rewrite /mblk nth_mblock512_mem 1:/# loadW128_bits64 // addr16 //.
by congr; congr; ring.
qed.

lemma sha512_compress_one_correct (h0 : W64.t list) (p0 : W64.t) :
  hoare [M._sha512_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus ==>
           hwords res.`1 = compress h0 (mblk Glob.mem (W64.to_uint p0))].
proof.
proc.
ecall (avx2_driver h0 (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0)) 1).
while (0 <= i <= 8 /\ hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus /\ bmask mask /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 2 =>
         BArray256.get256 x r \bits64 (2 * L + c) = nth W64.zero (mblk Glob.mem (W64.to_uint p0)) (2 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hp hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset 1,2:/#.
  case: (i{hr} = r) => hir.
  + by rewrite (lane_bcast _ _ _ _ hm hL hc) -hir hp lane_mem // /#.
  by apply hx => //; smt().
wp; skip => &hr [hh [hp hb]]; split.
+ by rewrite hh hp hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ _ hm hx; split.
+ rewrite /= hh size_mblk /=; apply win0; 1,2: exact size_mblk.
  by move=> r L c hr hL hc'; rewrite /lane; case: (L = 0) => _; apply hx => //; smt().
by move=> _ r /=.
qed.

lemma sha512_compress_two_correct (h0 : W64.t list) (p0 : W64.t) :
  hoare [M._sha512_compress_two :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 256 <= W64.modulus ==>
           hwords res.`1 = compress (compress h0 (mblk Glob.mem (W64.to_uint p0)))
                                    (mblk Glob.mem (W64.to_uint p0 + 128))].
proof.
proc.
ecall (avx2_driver h0 (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0 + 128)) 2).
while (0 <= i <= 8 /\ hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 256 <= W64.modulus /\ bmask mask /\
       forall r L c, 0 <= r < i => 0 <= L < 2 => 0 <= c < 2 =>
         BArray256.get256 x r \bits64 (2 * L + c)
         = nth W64.zero (lane L (mblk Glob.mem (W64.to_uint p0)) (mblk Glob.mem (W64.to_uint p0 + 128)))
             (2 * r + c)).
+ wp; skip => &hr [#] hi0 hi1 hh hp hb hm hx hi.
  split; 1: smt(). split; 1: done. split; 1: done. split; 1: done. split; 1: done.
  move=> r L c hr hL hc; rewrite xset3 1,2:/#.
  case: (i{hr} = r) => hir; last by apply hx => //; smt().
  have hi8 : 0 <= i{hr} < 8 by move: hi0 hi; clear hx; smt().
  have hb1 : W64.to_uint p0 + 128 <= W64.modulus by move: hb; clear hx; smt().
  rewrite (lane_two _ _ _ _ _ hm hL hc) -hir hp /lane; case: (L = 0) => _.
  + by rewrite (lane_mem _ _ _ _ hi8 hc hb1).
  have h128 : W64.to_uint (p0 + W64.of_int 128) = W64.to_uint p0 + 128.
  + have h1 : W64.to_uint (W64.of_int 128) = 128 by rewrite W64.of_uintK pmod_small.
    by rewrite W64.to_uintD_small; [rewrite h1; move: hb; clear hx h1; smt() | rewrite h1].
  have hb2 : W64.to_uint (p0 + W64.of_int 128) + 128 <= W64.modulus.
  + by rewrite h128; move: hb; clear hx h128; smt().
  by rewrite (lane_mem _ _ _ _ hi8 hc hb2) h128.
wp; skip => &hr [hh [hp hb]]; split.
+ by rewrite hh hp hb bmask_kernel /=; smt().
move=> i x hc [#] hi0 hi1 _ _ _ hm hx; split.
+ rewrite /= hh !size_mblk /=; apply win0; 1,2: exact size_mblk.
  by move=> r L c hr hL hc'; apply hx => //; smt().
by move=> _ r /=.
qed.

(* ------------------------------------------------------------------ *)
(* n blocks from memory                                                *)

lemma fold1 h0 mem a k : 0 <= k =>
  foldl compress h0 (parse (JWordList.memread mem a (128 * (k + 1))))
  = compress (foldl compress h0 (parse (JWordList.memread mem a (128 * k)))) (mblk mem (a + 128 * k)).
proof. by move=> hk; rewrite parse512_memreadS // foldl_rcons. qed.

lemma fold2 h0 mem a k : 0 <= k =>
  foldl compress h0 (parse (JWordList.memread mem a (128 * (k + 2))))
  = compress (compress (foldl compress h0 (parse (JWordList.memread mem a (128 * k))))
                       (mblk mem (a + 128 * k))) (mblk mem (a + 128 * k + 128)).
proof.
move=> hk; rewrite (_: k + 2 = k + 1 + 1) 1:/# fold1 1:/# fold1 //.
by have -> : a + 128 * (k + 1) = a + 128 * k + 128 by ring.
qed.

lemma ule2 (n : W64.t) : (W64.of_int 2 \ule n) = (2 <= W64.to_uint n).
proof. by rewrite W64.uleE W64.of_uintK pmod_small. qed.

(* The loop of _sha512_compress_blocks after n0 - n blocks. *)
op binv (h0 : W64.t list) (mem : global_mem_t) (p0 n0 : W64.t) (h : BArray64.t) (p n : W64.t) =
  0 <= W64.to_uint n <= W64.to_uint n0 /\
  W64.to_uint p = W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) /\
  W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus /\
  hwords h = foldl compress h0
    (parse (JWordList.memread mem (W64.to_uint p0) (128 * (W64.to_uint n0 - W64.to_uint n)))).

lemma binv_room h0 mem p0 n0 h p n : binv h0 mem p0 n0 h p n => 1 <= W64.to_uint n =>
  W64.to_uint p + 128 * W64.to_uint n < W64.modulus.
proof.
rewrite /binv => [#] hn0 hn1 hp hm _ h1; rewrite hp.
by have -> : W64.to_uint p0 + 128 * (W64.to_uint n0 - W64.to_uint n) + 128 * W64.to_uint n
           = W64.to_uint p0 + 128 * W64.to_uint n0 by ring.
qed.

lemma binv_two h0 mem p0 n0 h p n h' :
  binv h0 mem p0 n0 h p n => 2 <= W64.to_uint n =>
  hwords h' = compress (compress (hwords h) (mblk mem (W64.to_uint p))) (mblk mem (W64.to_uint p + 128)) =>
  binv h0 mem p0 n0 h' (p + W64.of_int 256) (n - W64.of_int 2).
proof.
rewrite /binv => [#] hn0 hn1 hp hm hh h2 hh'.
have h2' : W64.to_uint (W64.of_int 2) = 2 by rewrite W64.of_uintK pmod_small.
have hs : W64.to_uint (n - W64.of_int 2) = W64.to_uint n - 2.
+ by rewrite W64.to_uintB 1:ule2 // h2'.
have h256 : W64.to_uint (W64.of_int 256) = 256 by rewrite W64.of_uintK pmod_small.
have ha : W64.to_uint (p + W64.of_int 256) = W64.to_uint p + 256.
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
  hwords h' = foldl compress h0 (parse (JWordList.memread mem (W64.to_uint p0) (128 * W64.to_uint n0))).
proof.
rewrite /binv => [#] hn0 hn1 hp hm hh h1 hh'.
have e : 128 * W64.to_uint n0 = 128 * ((W64.to_uint n0 - W64.to_uint n) + 1) by rewrite h1; ring.
by rewrite hh' hh e fold1 1:/# hp.
qed.

lemma sha512_compress_blocks_correct (h0 : W64.t list) (p0 n0 : W64.t) :
  hoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))].
proof.
proc.
seq 4 : (binv h0 Glob.mem p0 n0 h p n /\ W64.to_uint n < 2 /\ more = (n <> W64.zero)).
+ wp; while (binv h0 Glob.mem p0 n0 h p n /\ more = (2 <= W64.to_uint n)).
  + wp; ecall (sha512_compress_two_correct (hwords h) p); wp; skip => &hr [[hI hm] hmore].
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
    by rewrite (_: 128 * (W64.to_uint n0 - W64.to_uint n0) = 0) 1:/# parse512_memread0 /= hh.
  move=> h1 more0 n1 p1 hc [hI hm]; split; 1: exact hI.
  by move: hc; rewrite hm; clear hI; smt().
if.
+ wp; ecall (sha512_compress_one_correct (hwords h) p); wp; skip => &hr [[hI [hn2 hmore]] hc].
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
lemma round_ll : islossless M.__sha512_avx2_round.
proof. by proc; auto. qed.

lemma driver_ll : islossless M.__sha512_avx2.
proof.
proc.
while (true) (inc - l).
+ move=> z.
  wp; while (true) (8 - i); 1: by move=> z'; auto => /#.
  wp; while (true) (80 - t).
  + by move=> z'; wp; sp; if; [call round_ll | call round_ll]; auto => /#.
  by auto => /#.
wp; while (true) (8 - i); 1: by move=> z; auto => /#.
wp; while (true) (8 - i); 1: by move=> z; auto => /#.
by auto => /#.
qed.

lemma sha512_compress_ll : islossless M._sha512_compress.
proof.
proc; call driver_ll.
while (0 <= i <= 8) (8 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha512_compress_one_ll : islossless M._sha512_compress_one.
proof.
proc; call driver_ll.
while (0 <= i <= 8) (8 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha512_compress_two_ll : islossless M._sha512_compress_two.
proof.
proc; call driver_ll.
while (0 <= i <= 8) (8 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha512_compress_blocks_ll : islossless M._sha512_compress_blocks.
proof.
proc.
seq 4 : true; 1: by conseq (_: true ==> true).
+ wp; while (more = (2 <= W64.to_uint n)) (W64.to_uint n).
  + move=> z; wp; call sha512_compress_two_ll; auto => /> &m hn.
    move=> r; rewrite /SLH64.protect_64 ule2 W64.to_uintB 1:ule2 //.
    have -> : W64.to_uint (W64.of_int 2) = 2 by rewrite W64.of_uintK pmod_small.
    smt().
  by auto; smt(ule2).
+ by if; [call sha512_compress_one_ll; auto | auto].
+ by hoare; conseq (_: true ==> true).
by [].
qed.

lemma sha512_compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==> hwords res.`1 = compress h0 (mblock blk)] = 1%r.
proof. by conseq sha512_compress_ll (sha512_compress_correct h0 blk). qed.

lemma sha512_compress_one_total (h0 : W64.t list) (p0 : W64.t) :
  phoare [M._sha512_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 128 <= W64.modulus ==>
           hwords res.`1 = compress h0 (mblk Glob.mem (W64.to_uint p0))] = 1%r.
proof. by conseq sha512_compress_one_ll (sha512_compress_one_correct h0 p0). qed.

lemma sha512_compress_two_total (h0 : W64.t list) (p0 : W64.t) :
  phoare [M._sha512_compress_two :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 256 <= W64.modulus ==>
           hwords res.`1 = compress (compress h0 (mblk Glob.mem (W64.to_uint p0)))
                                    (mblk Glob.mem (W64.to_uint p0 + 128))] = 1%r.
proof. by conseq sha512_compress_two_ll (sha512_compress_two_correct h0 p0). qed.

lemma sha512_compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha512_compress_blocks_ll (sha512_compress_blocks_correct h0 p0 n0). qed.
