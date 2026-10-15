(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2.ec (aarch64/sha2)
 * ================================
 *
 * Functional correctness of the one-block entry point _sha256_compress of
 * the AArch64 SHA-256 instruction kernel (src/aarch64/sha2/
 * sha256_compress.jinc, FEAT_SHA256) against FIPS 180-4 section 6.2.2 as
 * specified in spec/FIPS180_SHA2.ec. The entry point that reads blocks
 * from memory, _sha256_compress_blocks, is proven in
 * SHA256_A64Sha2Blocks.ec.
 *
 * Model. NirapodSha2 is the jasmin2ec model of a unit; this file is
 * checked on every unit whose Sha256Kernel root is src/aarch64/sha2
 * (proofs/Makefile). The instructions are used through the lemmas of
 * Sha2Insn (SHA256H, SHA256H2: four rounds; SHA256SU0, SHA256SU1: four
 * schedule words) and Vec (VADD_4u32, VREV32_16u8), so no proof below
 * unfolds an instruction model.
 *
 * Representation. The chaining value h is u32[8], H_0 .. H_7 as native
 * words (hwords); the kernel holds it as abcd = [a; b; c; d] and
 * efgh = [e; f; g; h], lane 0 lowest (p4). The message is a window of
 * four vectors m[0 .. 3]; group g (rounds 4g .. 4g + 3) reads W_4g ..
 * W_4g+3 from m[g mod 4], and for g < 12 replaces them by W_4g+16 ..
 * W_4g+19. So at the head of group g, m[j] holds the four words of the
 * group g + ((j - g) mod 4), the invariant of both loops.
 *
 * Theorems:
 *     sha256_block_a64_correct  __sha256_block_a64 computes the 64 rounds
 *                               and the feed-forward on a state held in
 *                               abcd, efgh, for any schedule that
 *                               satisfies the recurrence of step 1
 *                               (partial correctness);
 *     sha256_compress_correct   _sha256_compress computes compress on the
 *                               big-endian words of the 64-byte block
 *                               (partial correctness);
 *     sha256_compress_total     the same with termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray32 BArray64 BArray256.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Sha2Insn Arrays.
import SHA256 A256.

clone Arrays.Words as Arr32 with theory A <= BArray32.
clone Arrays.Words as Arr64 with theory A <= BArray64.
clone Arrays.Words as Arr256 with theory A <= BArray256.

op hwords (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).

lemma nth_hwords h k : 0 <= k < 8 => nth W32.zero (hwords h) k = BArray32.get32 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

(* ------------------------------------------------------------------ *)
(* The round-constant table, four constants per 128-bit read          *)

lemma K256_kernel t : 0 <= t < 64 =>
  BArray256.get32 sHA256_K t = nth W32.zero K256 t.
proof.
move=> ht; rewrite BArray256.get32_of_list32 1://.
by congr; rewrite /K256 /=.
qed.

lemma kvec g : 0 <= g < 16 =>
  BArray256.get128 sHA256_K g
  = p4 (nth W32.zero K256 (4 * g)) (nth W32.zero K256 (4 * g + 1))
       (nth W32.zero K256 (4 * g + 2)) (nth W32.zero K256 (4 * g + 3)).
proof.
move=> hg; rewrite {1}(p4_bits (BArray256.get128 sHA256_K g)).
rewrite !Arr256.get128d_bits32 //.
have e : forall i, 0 <= i < 4 =>
  BArray256.get32d sHA256_K (16 * g + 4 * i) = nth W32.zero K256 (4 * g + i).
+ move=> i hi; rewrite -K256_kernel 1:/#.
  by congr; ring.
by rewrite (e 0) // (e 1) // (e 2) // (e 3).
qed.

(* ------------------------------------------------------------------ *)
(* One group of four rounds                                           *)

(* Rounds t .. t + 3 from the state S, with K_t + W_t formed as the
   kernel forms it (sha256h_rounds4 with the schedule read as wv). *)
lemma group4 (ws : W32.t list) (S : state) (t : int) :
  SHA256H (p4 S.`1 S.`2 S.`3 S.`4) (p4 S.`5 S.`6 S.`7 S.`8)
    (VADD_4u32 (p4 (nth W32.zero K256 t) (nth W32.zero K256 (t + 1))
                   (nth W32.zero K256 (t + 2)) (nth W32.zero K256 (t + 3))) (wv ws t))
  = p4 (rounds ws S t (t + 4)).`1 (rounds ws S t (t + 4)).`2
       (rounds ws S t (t + 4)).`3 (rounds ws S t (t + 4)).`4
  /\ SHA256H2 (p4 S.`5 S.`6 S.`7 S.`8) (p4 S.`1 S.`2 S.`3 S.`4)
    (VADD_4u32 (p4 (nth W32.zero K256 t) (nth W32.zero K256 (t + 1))
                   (nth W32.zero K256 (t + 2)) (nth W32.zero K256 (t + 3))) (wv ws t))
  = p4 (rounds ws S t (t + 4)).`5 (rounds ws S t (t + 4)).`6
       (rounds ws S t (t + 4)).`7 (rounds ws S t (t + 4)).`8.
proof. exact (sha256h_rounds4 ws t S). qed.

lemma rounds_g (ws : W32.t list) (s : state) (g : int) : 0 <= g =>
  rounds ws s 0 (4 * (g + 1)) = rounds ws (rounds ws s 0 (4 * g)) (4 * g) (4 * g + 4).
proof.
move=> hg; rewrite (_ : 4 * (g + 1) = 4 * g + 4) 1:/#.
by rewrite (rounds_cat ws s 0 (4 * g) (4 * g + 4)) 1:/#.
qed.

(* ------------------------------------------------------------------ *)
(* The block                                                          *)

(* The window of the last four groups: m[j] holds group 12 + ((j - 12)
   mod 4), so group g reads its own words from m[g mod 4]. *)
(* m[(g + i) mod 4] holds group g + i at the head of group g. *)
lemma win_idx g i : 0 <= i < 4 => g + ((g + i) %% 4 - g) %% 4 = g + i.
proof.
move=> hi; rewrite modzDml (_ : g + i - g = i) 1:/#.
by rewrite modz_small 1:/#.
qed.

(* A slot other than m[g mod 4] keeps its group when the window moves. *)
lemma win_other g j : 0 <= j < 4 => g %% 4 <> j =>
  g + (j - g) %% 4 = g + 1 + (j - (g + 1)) %% 4.
proof.
move=> hj hne.
have e1 : (j - g) %% 4 = (j - g %% 4) %% 4.
+ rewrite {1}(divz_eq g 4).
  by rewrite (_ : j - (g %/ 4 * 4 + g %% 4) = (j - g %% 4) + (- (g %/ 4)) * 4) 1:/# modzMDr.
have e2 : (j - (g + 1)) %% 4 = (j - g %% 4 - 1) %% 4.
+ rewrite {1}(divz_eq g 4).
  by rewrite (_ : j - (g %/ 4 * 4 + g %% 4 + 1) = (j - g %% 4 - 1) + (- (g %/ 4)) * 4) 1:/# modzMDr.
rewrite e1 e2; move: hne.
have : g %% 4 = 0 \/ g %% 4 = 1 \/ g %% 4 = 2 \/ g %% 4 = 3 by smt().
have : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 by smt().
by move=> hjv hrv; smt().
qed.

(* Group g < 12 replaces its own words, in m[g mod 4], by those of group
   g + 4 (SHA256SU0, then SHA256SU1); the window moves by one group. *)
lemma win_step (m : BArray64.t) (ws : W32.t list) (g : int) :
  0 <= g < 12 => (forall t, 16 <= t < 64 => srec ws t) =>
  (forall j, 0 <= j < 4 => BArray64.get128 m j = wv ws (4 * (g + (j - g) %% 4))) =>
  forall j, 0 <= j < 4 =>
    BArray64.get128
      (BArray64.set128
        (BArray64.set128 m (g %% 4)
          (SHA256SU0 (BArray64.get128 m (g %% 4)) (BArray64.get128 m ((g + 1) %% 4))))
        (g %% 4)
        (SHA256SU1
          (BArray64.get128 (BArray64.set128 m (g %% 4)
            (SHA256SU0 (BArray64.get128 m (g %% 4)) (BArray64.get128 m ((g + 1) %% 4))))
            (g %% 4))
          (BArray64.get128 (BArray64.set128 m (g %% 4)
            (SHA256SU0 (BArray64.get128 m (g %% 4)) (BArray64.get128 m ((g + 1) %% 4))))
            ((g + 2) %% 4))
          (BArray64.get128 (BArray64.set128 m (g %% 4)
            (SHA256SU0 (BArray64.get128 m (g %% 4)) (BArray64.get128 m ((g + 1) %% 4))))
            ((g + 3) %% 4))))
      j
    = wv ws (4 * (g + 1 + (j - (g + 1)) %% 4)).
proof.
move=> hg hrec hm j hj.
have hw : forall i, 0 <= i < 4 => BArray64.get128 m ((g + i) %% 4) = wv ws (4 * (g + i)).
+ by move=> i hi; rewrite hm 1:/# win_idx.
have hi : 0 <= g %% 4 < 4 by smt().
rewrite BArray64.get_set128E 1,2:/#.
case: (g %% 4 = j) => hj'.
+ rewrite !BArray64.get_set128E 1..6:/# /=.
  rewrite (_ : g %% 4 = (g + 2) %% 4 <=> false) 1:/# (_ : g %% 4 = (g + 3) %% 4 <=> false) 1:/# /=.
  have := hw 0 _; 1: done; rewrite /= => ->.
  rewrite (hw 1) // (hw 2) // (hw 3) //.
  rewrite (_ : 4 * (g + 1) = 4 * g + 4) 1:/# (_ : 4 * (g + 2) = 4 * g + 8) 1:/#.
  rewrite (_ : 4 * (g + 3) = 4 * g + 12) 1:/#.
  rewrite sha256su_sched4 1..4:hrec 1..4:/#.
  by congr; rewrite -hj' /#.
rewrite BArray64.get_set128E 1,2:/# ifF 1:/# hm //.
by rewrite win_other.
qed.

lemma win_last g : 12 <= g < 16 => 12 + (g %% 4 - 12) %% 4 = g.
proof.
move=> hg; have : g = 12 \/ g = 13 \/ g = 14 \/ g = 15 by smt().
by case=> [->|[->|[->|->]]].
qed.

abbrev st4a (S : state) = p4 S.`1 S.`2 S.`3 S.`4.
abbrev st4e (S : state) = p4 S.`5 S.`6 S.`7 S.`8.

lemma sha256_block_a64_correct (s : state) (ws : W32.t list) :
  (forall t, 16 <= t < 64 => srec ws t) =>
  hoare [M.__sha256_block_a64 :
           abcd = st4a s /\ efgh = st4e s /\ k = sHA256_K /\
           (forall j, 0 <= j < 4 => BArray64.get128 m j = wv ws (4 * j)) ==>
           res.`1 = VADD_4u32 (st4a (rounds ws s 0 64)) (st4a s) /\
           res.`2 = VADD_4u32 (st4e (rounds ws s 0 64)) (st4e s)].
proof.
move=> hrec; proc.
wp.
while (12 <= g <= 16 /\ k = sHA256_K /\ abcd0 = st4a s /\ efgh0 = st4e s /\
       abcd = st4a (rounds ws s 0 (4 * g)) /\ efgh = st4e (rounds ws s 0 (4 * g)) /\
       forall j, 0 <= j < 4 => BArray64.get128 m j = wv ws (4 * (12 + (j - 12) %% 4))).
+ wp; skip => /> &hr hg12 _ hm hg16.
  rewrite kvec 1:/# hm 1:/#.
  rewrite win_last 1:/#.
  have [-> ->] := group4 ws (rounds ws s 0 (4 * g{hr})) (4 * g{hr}).
  by rewrite rounds_g 1:/#; smt().
wp.
while (0 <= g <= 12 /\ k = sHA256_K /\ abcd0 = st4a s /\ efgh0 = st4e s /\
       abcd = st4a (rounds ws s 0 (4 * g)) /\ efgh = st4e (rounds ws s 0 (4 * g)) /\
       forall j, 0 <= j < 4 => BArray64.get128 m j = wv ws (4 * (g + (j - g) %% 4))).
+ wp; skip => /> &hr hg0 _ hm hg12.
  have hw : forall i, 0 <= i < 4 =>
    BArray64.get128 m{hr} ((g{hr} + i) %% 4) = wv ws (4 * (g{hr} + i)).
  + by move=> i hi; rewrite hm 1:/# win_idx.
  have hw0 := hw 0 _; 1: done.
  rewrite /= in hw0.
  have hwin := win_step m{hr} ws g{hr} _ hrec hm; 1: smt().
  have [h1 h2] := group4 ws (rounds ws s 0 (4 * g{hr})) (4 * g{hr}).
  split; first smt().
  split; first by rewrite kvec 1:/# hw0 h1 rounds_g 1:/#.
  split; first by rewrite kvec 1:/# hw0 h2 rounds_g 1:/#.
  by move=> j hj1 hj2; apply hwin => /#.
wp; skip => /> &hr hm.
split.
+ rewrite rounds_nil //=.
  by move=> j hj0 hj4; rewrite hm 1:/# modz_small 1:/#.
move=> g0 m0 hlt hg0 hg12 hm0.
have ->> : g0 = 12 by smt().
split; first by move=> /= j hj0 hj4; rewrite hm0 1:/#.
move=> g1 hlt1 hg1 hg16 _.
by have ->> : g1 = 16 by smt().
qed.

(* ------------------------------------------------------------------ *)
(* The state and the message in q registers                           *)

lemma range8 (k : int) : 0 <= k < 8 =>
  k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7.
proof. smt(). qed.

lemma get128_lanes (h : BArray32.t) (o : int) :
  BArray32.get128 h o
  = p4 (BArray32.get32 h (4 * o)) (BArray32.get32 h (4 * o + 1))
       (BArray32.get32 h (4 * o + 2)) (BArray32.get32 h (4 * o + 3)).
proof.
rewrite {1}(p4_bits (BArray32.get128 h o)) !Arr32.get128d_bits32 //.
by congr; congr; ring.
qed.

lemma get32_set2 (h : BArray32.t) (a e : W128.t) (i : int) : 0 <= i < 8 =>
  BArray32.get32 (BArray32.set128d (BArray32.set128d h 0 a) 16 e) i
  = if i < 4 then a \bits32 i else e \bits32 (i - 4).
proof.
move=> hi /=; case: (i < 4) => hi4.
+ rewrite Arr32.get32d_set128d_out 1:/#.
  by have := Arr32.get32d_set128d_in h 0 i a _ _ _ => //= /#.
rewrite (_ : 4 * i = 16 + 4 * (i - 4)) 1:/#.
by rewrite Arr32.get32d_set128d_in // /#.
qed.

(* Message word k of the block, read big-endian (section 5.2.1). *)
lemma bswap_get32 (blk : BArray64.t) k : 0 <= k < 16 =>
  bswap32 (BArray64.get32 blk k) = be32 (take 4 (drop (4 * k) (BArray64.to_list blk))).
proof.
move=> hk; rewrite /bswap32 /be32 BArray64.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# BArray64.size_to_list /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray64.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray64.get_to_list.
by rewrite BArray64.nth_sub.
qed.

lemma msg_word (blk : BArray64.t) (k : int) : 0 <= k < 16 =>
  bswap32 (BArray64.get32 blk k)
  = nth W32.zero (schedule (blockwords (BArray64.to_list blk))) k.
proof.
move=> hk; rewrite nth_schedule_lo 1:size_blockwords 1:BArray64.size_to_list //.
by rewrite nth_blockwords 1:BArray64.size_to_list // bswap_get32.
qed.

lemma vrev_block (blk : BArray64.t) (j : int) : 0 <= j < 4 =>
  VREV32_16u8 (BArray64.get128 blk j)
  = wv (schedule (blockwords (BArray64.to_list blk))) (4 * j).
proof.
move=> hj; rewrite {1}(p4_bits (VREV32_16u8 (BArray64.get128 blk j))) /wv.
rewrite !vrev32_lane // !Arr64.get128d_bits32 //.
have e : forall i, 0 <= i < 4 =>
  bswap32 (BArray64.get32d blk (16 * j + 4 * i))
  = nth W32.zero (schedule (blockwords (BArray64.to_list blk))) (4 * j + i).
+ by move=> i hi; rewrite -msg_word 1:/#; congr; congr; ring.
by rewrite (e 0) // (e 1) // (e 2) // (e 3).
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on a 64-byte block                          *)

lemma sha256_compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))].
proof.
have hsz : size (blockwords (BArray64.to_list blk)) = 16.
+ by rewrite size_blockwords // BArray64.size_to_list.
have hrec : forall t, 16 <= t < 64 => srec (schedule (blockwords (BArray64.to_list blk))) t.
+ by move=> t ht; rewrite /srec (nth_schedule_hi _ _ hsz).
proc.
wp.
ecall (sha256_block_a64_correct (to_state h0) (schedule (blockwords (BArray64.to_list blk))) hrec).
wp.
while (0 <= j <= 4 /\ hwords h = h0 /\ block = blk /\
       forall i, 0 <= i < j => BArray64.get128 m i = VREV32_16u8 (BArray64.get128 blk i)).
+ wp; skip => /> &hr hj0 _ hi hj4; split; first smt().
  move=> i hi0 hi1.
  rewrite BArray64.get_set128E 1,2:/#.
  case: (j{hr} = i) => [<-|ne]; first by rewrite BArray64.get_set128E 1,2:/#.
  by rewrite BArray64.get_set128E 1,2:/# ne /= hi /#.
wp; skip => /> &hr.
split; first smt().
move=> j0 m0 hlt hj0 hj4 hm0.
have hm : forall j1, 0 <= j1 < 4 =>
  BArray64.get128 m0 j1 = wv (schedule (blockwords (BArray64.to_list blk))) (4 * j1).
+ by move=> j1 hj; rewrite hm0 1:/# vrev_block.
have ha : BArray32.get128d h{hr} 0 = st4a (to_state (hwords h{hr})).
+ by have := get128_lanes h{hr} 0; rewrite /= => ->; rewrite /to_state !nth_hwords.
have he : BArray32.get128d h{hr} 16 = st4e (to_state (hwords h{hr})).
+ by have := get128_lanes h{hr} 1; rewrite /= => ->; rewrite /to_state !nth_hwords.
split; first by rewrite ha he /= => j1 hj1 hj2; apply hm.
move=> _ _ _ r -> ->.
rewrite (_ : map be32 (chunk 4 (BArray64.to_list blk)) = blockwords (BArray64.to_list blk)) //.
apply (eq_from_nth W32.zero); first by rewrite size_hwords size_compress // size_hwords.
move=> k; rewrite size_hwords => hk.
rewrite nth_hwords // get32_set2 // nth_compress ?size_hwords // /vars.
move: (rounds (schedule (blockwords (BArray64.to_list blk))) (to_state (hwords h{hr})) 0 64) => S.
case: S => a b c d e f g hh /=.
rewrite !vadd4_pack /to_state /=.
have := range8 k hk.
by case=> [|[|[|[|[|[|[|]]]]]]] ->> /=; rewrite ?p4_0 ?p4_1 ?p4_2 ?p4_3.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop runs over a constant range. *)
lemma sha256_block_a64_ll : islossless M.__sha256_block_a64.
proof.
proc; wp.
while (12 <= g <= 16) (16 - g); first by auto => /#.
wp; while (0 <= g <= 12) (12 - g); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_ll : islossless M._sha256_compress.
proof.
proc; wp; call sha256_block_a64_ll; wp.
while (0 <= j <= 4) (4 - j); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. by conseq sha256_compress_ll (sha256_compress_correct h0 blk). qed.
