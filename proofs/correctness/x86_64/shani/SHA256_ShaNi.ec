(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNi.ec
 * ===============
 *
 * Functional correctness of the SHA-256 kernel on the x86 SHA extensions
 * (src/x86_64/shani/sha256_compress.jinc) against FIPS 180-4 section
 * 6.2.2 as spec/FIPS180_SHA2.ec writes it, for its three entry points:
 *
 *   sha256_compress_total         _sha256_compress, one block from an array
 *   sha256_compress_one_total     _sha256_compress_one, one block from memory
 *   sha256_compress_blocks_total  _sha256_compress_blocks, n blocks from
 *                                 memory, folded as the parse of section
 *                                 5.2.1 of those bytes
 *
 * with the statements of the portable kernel's proofs. All are total
 * correctness (phoare ... = 1%r), from a hoare proof and a losslessness
 * proof.
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256Kernel root is
 * src/x86_64/shani (proofs/Makefile). The instruction lemmas are in
 * ShaNi.ec, the lane lemmas in Vec.ec.
 *
 * Invariants. The state is held as abef = F E B A and cdgh = H G D C
 * (ShaNi.abef, ShaNi.cdgh, lane 0 first). The schedule lives in the four
 * 128-bit words of w; before group g (rounds 4g .. 4g+3) word i holds the
 * schedule group grp g i, which is i while g <= 4 and otherwise the one
 * group among g-4 .. g-1 that is i modulo 4.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray16 BArray32 BArray64 BArray256.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 WordSpec Vec Arrays SpecRounds ShaNi Mem.
require JWordList.
import SHA256 R256.

clone Arrays.ArrayLanes as L16 with theory A <- BArray16.
clone Arrays.ArrayLanes as L32 with theory A <- BArray32.
clone Arrays.ArrayLanes as L64 with theory A <- BArray64.
clone Arrays.ArrayLanes as L256 with theory A <- BArray256.

op hwords (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).

lemma nth_hwords h k : 0 <= k < 8 => nth W32.zero (hwords h) k = BArray32.get32 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

lemma hwordsE h : hwords h = [BArray32.get32 h 0; BArray32.get32 h 1; BArray32.get32 h 2;
  BArray32.get32 h 3; BArray32.get32 h 4; BArray32.get32 h 5; BArray32.get32 h 6; BArray32.get32 h 7].
proof. by rewrite /hwords -iotaredE. qed.

(* ------------------------------------------------------------------ *)
(* The state registers                                                 *)

lemma load_state_spec (h0 : BArray32.t) :
  hoare [M.__shani_load_state : h = h0 ==>
         res = (abef (to_state (hwords h0)), cdgh (to_state (hwords h0)))].
proof.
proc; auto => />.
rewrite !L32.get128d_p4 /= vpshufd_b1 vpshufd_1b vpalignr8 vpblendw_f0 /=.
by rewrite /abef /cdgh /to_state !nth_hwords.
qed.

lemma store_state_spec (a b c d e f g h : W32.t) :
  hoare [M.__shani_store_state : abef = p4 f e b a /\ cdgh = p4 h g d c ==>
         hwords res = [a; b; c; d; e; f; g; h]].
proof.
proc; auto => /> &hr.
rewrite vpshufd_1b vpshufd_b1 vpblendw_f0 vpalignr8 /= hwordsE.
by rewrite !L32.get32d_set128d.
qed.

(* ------------------------------------------------------------------ *)
(* The round constants                                                 *)

lemma K256_kernel t : 0 <= t < 64 =>
  BArray256.get32 sHA256_K t = nth W32.zero K256 t.
proof.
move=> ht; rewrite BArray256.get32_of_list32 1://.
by congr; rewrite /K256 /=.
qed.

lemma K256_get128 g : 0 <= g < 16 =>
  BArray256.get128 sHA256_K g
  = p4 (nth W32.zero K256 (4 * g)) (nth W32.zero K256 (4 * g + 1))
       (nth W32.zero K256 (4 * g + 2)) (nth W32.zero K256 (4 * g + 3)).
proof. by move=> hg; rewrite L256.get128_p4 !K256_kernel 1..4:/#. qed.

(* ------------------------------------------------------------------ *)
(* The schedule window                                                 *)

(* The schedule group held in word i of w before group g. *)
op grp (g i : int) : int = if g <= 4 then i else g - 4 + (i - g) %% 4.

op wreg (w : BArray64.t) (m : W32.t list) (g : int) =
  forall i, 0 <= i < 4 => BArray64.get128 w i = wv m (4 * grp g i).

lemma modg (i g : int) : (i - g) %% 4 = (i - g %% 4) %% 4.
proof. by rewrite -modzDmr -modzNm modzDmr. qed.

lemma grp_win g j : 4 <= g => 0 <= j < 4 => grp g ((g + j) %% 4) = g - 4 + j.
proof.
move=> hg hj; rewrite /grp; case: (g <= 4) => h.
+ have ->: g = 4 by smt().
  by rewrite (_: 4 + j = j + 4) 1:/# modzDr pmod_small.
by rewrite modzDml (_: g + j - g = j) 1:/# pmod_small.
qed.

lemma grp_cur g : 0 <= g => grp (g + 1) (g %% 4) = g.
proof.
move=> hg; rewrite /grp; case: (g + 1 <= 4) => h; first by rewrite pmod_small /#.
by rewrite modzDml (_: g - (g + 1) = -1) 1:/# /#.
qed.

lemma grp_keep g i : 0 <= g => 0 <= i < 4 => i <> g %% 4 => grp (g + 1) i = grp g i.
proof.
move=> hg hi hne; rewrite /grp.
case: (g + 1 <= 4) => h1; first by rewrite ifT 1:/#.
rewrite modg (modg i g) (_: (g + 1) %% 4 = (g %% 4 + 1) %% 4) 1:modzDml //.
have : g %% 4 = 0 \/ g %% 4 = 1 \/ g %% 4 = 2 \/ g %% 4 = 3 by smt().
have : i = 0 \/ i = 1 \/ i = 2 \/ i = 3 by smt().
case: (g <= 4) => h2.
+ have hg4 : g = 4 by smt().
  by move=> hi4 _; subst; case: hi4 => [|[|[|]]] ->> /=; smt().
move=> hi4 hc4; case: hc4 => [hc|[hc|[hc|hc]]]; rewrite hc /=;
  by case: hi4 => [->>|[->>|[->>|->>]]] /=; smt().
qed.

lemma wreg_lo w m g : 0 <= g < 4 => wreg w m g => wreg w m (g + 1).
proof. by move=> hg hw i hi; rewrite hw // /grp /#. qed.

(* The four schedule steps of group g >= 4 move the window by one group. *)
lemma wstep (w : BArray64.t) m g :
  size m = 16 => 4 <= g < 16 => wreg w m g =>
  let r = g %% 4 in
  let w1 = BArray64.set128 w r (SHA256MSG1 (BArray64.get128 w r) (BArray64.get128 w ((g + 1) %% 4))) in
  let t = VPALIGNR_128 (BArray64.get128 w1 ((g + 3) %% 4)) (BArray64.get128 w1 ((g + 2) %% 4)) (W8.of_int 4) in
  let w2 = BArray64.set128 w1 r (VPADD_4u32 (BArray64.get128 w1 r) t) in
  let w3 = BArray64.set128 w2 r (SHA256MSG2 (BArray64.get128 w2 r) (BArray64.get128 w2 ((g + 3) %% 4))) in
  wreg w3 m (g + 1).
proof.
move=> hm hg hw /= i hi.
have hr : 0 <= g %% 4 < 4 by smt().
have hn1 : g %% 4 <> (g + 1) %% 4 by smt().
have hn2 : g %% 4 <> (g + 2) %% 4 by smt().
have hn3 : g %% 4 <> (g + 3) %% 4 by smt().
do !(rewrite BArray64.get_set128E 1,2:/#).
have -> /= : (g %% 4 = (g + 2) %% 4) = false by smt().
have -> /= : (g %% 4 = (g + 3) %% 4) = false by smt().
case: (g %% 4 = i) => [<-|hne] /=; last by rewrite hw // grp_keep /#.
rewrite grp_cur 1:/#.
have h0 := hw (g %% 4) hr; have h1 := hw ((g + 1) %% 4) _; 1: smt().
have h2 := hw ((g + 2) %% 4) _; 1: smt().
have h3 := hw ((g + 3) %% 4) _; 1: smt().
rewrite h0 h1 h2 h3.
have e0 : grp g (g %% 4) = g - 4 by have := grp_win g 0; smt().
rewrite e0 !grp_win // 1..3:/#.
rewrite (_: 4 * (g - 4) = 4 * g - 16) 1:/# (_: 4 * (g - 4 + 1) = 4 * g - 12) 1:/#.
rewrite (_: 4 * (g - 4 + 3) = 4 * g - 4) 1:/# (_: 4 * (g - 4 + 2) = 4 * g - 8) 1:/#.
by apply shani_sched4 => /#.
qed.

(* ------------------------------------------------------------------ *)
(* One block on the registers                                          *)

(* The working variables before group g, from s0. *)
op st (m : W32.t list) (s0 : state) (g : int) : state =
  foldl (round (schedule m)) s0 (range 0 (4 * g)).

lemma st0 m s0 : st m s0 0 = s0.
proof. by rewrite /st range_geq. qed.

lemma stS m s0 g : 0 <= g =>
  st m s0 (g + 1) = foldl (round (schedule m)) (st m s0 g) (range (4 * g) (4 * g + 4)).
proof. by move=> hg; rewrite /st (rounds_cat _ _ 0 (4 * g)) 1:/# (_: 4 * (g + 1) = 4 * g + 4) 1:/#. qed.

lemma block_correct (m : W32.t list) (s0 : state) :
  hoare [M.__shani_block :
    size m = 16 /\ abef = ShaNi.abef s0 /\ cdgh = ShaNi.cdgh s0 /\ wreg w m 0 /\ k = sHA256_K ==>
    res.`1 = VPADD_4u32 (ShaNi.abef (st m s0 16)) (ShaNi.abef s0) /\
    res.`2 = VPADD_4u32 (ShaNi.cdgh (st m s0 16)) (ShaNi.cdgh s0)].
proof.
proc; wp.
while (0 <= g <= 16 /\ size m = 16 /\ k = sHA256_K /\
       abef0 = ShaNi.abef s0 /\ cdgh0 = ShaNi.cdgh s0 /\ wreg w m g /\
       abef = ShaNi.abef (st m s0 g) /\ cdgh = ShaNi.cdgh (st m s0 g)).
+ seq 1 : (0 <= g < 16 /\ size m = 16 /\ k = sHA256_K /\
           abef0 = ShaNi.abef s0 /\ cdgh0 = ShaNi.cdgh s0 /\ wreg w m (g + 1) /\
           abef = ShaNi.abef (st m s0 g) /\ cdgh = ShaNi.cdgh (st m s0 g)).
  + if.
    + wp; skip => /> &hr hg0 _ hm hw hg16 hg4.
      by have /= := wstep w{hr} m g{hr} hm _ hw; 1: smt().
    by skip => /> &hr hg0 _ hm hw hg16 hg4; apply wreg_lo => /#.
  wp; skip => /> &hr hg0 hg16 hm hw.
  have hwk : VPADD_4u32 (BArray64.get128 w{hr} (g{hr} %% 4)) (BArray256.get128 sHA256_K g{hr})
             = wk4 (schedule m) (4 * g{hr}).
  + by rewrite hw 1:/# grp_cur // K256_get128 // /wv /wk4.
  have [h1 h2] /= := shani_rounds4 (schedule m) (4 * g{hr}) (st m s0 g{hr}).
  by rewrite hwk h1 h2 stS //= /#.
wp; skip => /> &hr hm hw; split; first by rewrite st0.
move=> g w hg1 _ hg2 _; have ->: g = 16 by smt().
by [].
qed.

(* ------------------------------------------------------------------ *)
(* One block on h in memory                                            *)

(* The store after the feed-forward of step 4. *)
lemma store_state_ff (s s0 : state) :
  hoare [M.__shani_store_state :
    abef = VPADD_4u32 (ShaNi.abef s) (ShaNi.abef s0) /\
    cdgh = VPADD_4u32 (ShaNi.cdgh s) (ShaNi.cdgh s0) ==>
    hwords res = [s.`1 + s0.`1; s.`2 + s0.`2; s.`3 + s0.`3; s.`4 + s0.`4;
                  s.`5 + s0.`5; s.`6 + s0.`6; s.`7 + s0.`7; s.`8 + s0.`8]].
proof.
conseq (store_state_spec (s.`1 + s0.`1) (s.`2 + s0.`2) (s.`3 + s0.`3) (s.`4 + s0.`4)
                         (s.`5 + s0.`5) (s.`6 + s0.`6) (s.`7 + s0.`7) (s.`8 + s0.`8)).
by move=> &hr [-> ->]; rewrite /abef /cdgh !vpadd4_pack.
qed.

lemma rounds_correct (h0 m : W32.t list) :
  hoare [M.__shani_rounds : hwords h = h0 /\ size m = 16 /\ wreg w m 0 ==>
         hwords res = compress h0 m].
proof.
proc.
ecall (store_state_ff (st m (to_state h0) 16) (to_state h0)).
ecall (block_correct m (to_state h0)).
wp; ecall (load_state_spec h).
auto => /> &hr hm hw.
move=> [a c w'] /= _ _ r ->.
by rewrite (compressE (hwords h{hr}) m) 1:size_hwords //=.
qed.

(* ------------------------------------------------------------------ *)
(* The message words of a block                                        *)

lemma mask_bswap : BArray16.get128d sHA256_SHANI_BSWAP 0 = bswap_mask32.
proof.
have := L16.get128_p4 sHA256_SHANI_BSWAP 0.
by rewrite !BArray16.get32_of_list32 //= => ->.
qed.

(* The words of a block, read big-endian (section 5.2.1). *)
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

(* Four message words as the kernel holds them: W_4j .. W_4j+3. *)
lemma wv_lo (m : W32.t list) j : size m = 16 => 0 <= j < 4 =>
  wv m (4 * j) = p4 (nth W32.zero m (4 * j)) (nth W32.zero m (4 * j + 1))
                    (nth W32.zero m (4 * j + 2)) (nth W32.zero m (4 * j + 3)).
proof. by move=> hm hj; rewrite /wv !nth_schedule_lo // /#. qed.

lemma wreg0 (w : BArray64.t) m : size m = 16 =>
  (forall j, 0 <= j < 4 => BArray64.get128 w j
     = p4 (nth W32.zero m (4 * j)) (nth W32.zero m (4 * j + 1))
          (nth W32.zero m (4 * j + 2)) (nth W32.zero m (4 * j + 3))) =>
  wreg w m 0.
proof. by move=> hm h i hi; rewrite /grp /= wv_lo // h. qed.

(* ------------------------------------------------------------------ *)
(* _sha256_compress                                                    *)

lemma sha256_compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))].
proof.
proc.
ecall (rounds_correct h0 (mblock blk)).
while (0 <= i <= 4 /\ hwords h = h0 /\ block = blk /\ mask = bswap_mask32 /\
       forall j, 0 <= j < i => BArray64.get128 w j
         = p4 (nth W32.zero (mblock blk) (4 * j)) (nth W32.zero (mblock blk) (4 * j + 1))
              (nth W32.zero (mblock blk) (4 * j + 2)) (nth W32.zero (mblock blk) (4 * j + 3))).
+ wp; skip => /> &hr hi0 _ hj hi4; split; first smt().
  move=> j hj0 hj1; do !(rewrite BArray64.get_set128E 1,2:/#).
  case: (i{hr} = j) => [<-|ne] /=; last by apply hj => /#.
  rewrite vpunpckl_vmov64 pack2_bits32 vpshufb_bswap32 /=.
  rewrite !L64.get64d_bits32 // !nth_mblock 1..4:/#.
  by congr; congr; smt().
wp; skip => />; split; first by split; [exact mask_bswap | move=> /#].
move=> i w hi4 hi0 _ _ hj; rewrite size_mblock /=.
by apply wreg0; [rewrite size_mblock | move=> j hj'; apply hj => /#].
qed.

(* ------------------------------------------------------------------ *)
(* _sha256_compress_one                                                *)

lemma sha256_compress_one_correct (h0 : W32.t list) (p0 : W64.t) :
  hoare [M._sha256_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (memread Glob.mem (W64.to_uint p0) 64)))].
proof.
proc.
ecall (rounds_correct h0 (map be32 (chunk 4 (memread Glob.mem (W64.to_uint p0) 64)))).
while (0 <= i <= 4 /\ hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus /\
       mask = bswap_mask32 /\
       forall j, 0 <= j < i => BArray64.get128 w j
         = let mb = map be32 (chunk 4 (memread Glob.mem (W64.to_uint p0) 64)) in
           p4 (nth W32.zero mb (4 * j)) (nth W32.zero mb (4 * j + 1))
              (nth W32.zero mb (4 * j + 2)) (nth W32.zero mb (4 * j + 3))).
+ wp; skip => /> &hr hi0 _ hb hj hi4; split; first smt().
  move=> j hj0 hj1; do !(rewrite BArray64.get_set128E 1,2:/#).
  case: (i{hr} = j) => [<-|ne] /=; last by apply hj => /#.
  rewrite vpshufb_load128 !nth_mblock_mem 1..4:/#.
  have ->: W64.to_uint (p0 + W64.of_int (16 * i{hr})) = W64.to_uint p0 + 16 * i{hr}.
  + rewrite W64.to_uintD_small W64.of_uintK; smt(W64.to_uint_cmp pmod_small).
  by congr; congr; smt().
wp; skip => /> &hr hb; split; first by split; [exact mask_bswap | move=> /#].
move=> i w hi4 hi0 _ _ hj; rewrite size_mblock_mem /=.
by apply wreg0; [rewrite size_mblock_mem | move=> j hj'; apply hj => /#].
qed.

(* ------------------------------------------------------------------ *)
(* The chaining value between blocks, in the registers                 *)

lemma to_state_compress (hv m : W32.t list) : size hv = 8 =>
  to_state (compress hv m)
  = let s = st m (to_state hv) 16 in let s0 = to_state hv in
    (s.`1 + s0.`1, s.`2 + s0.`2, s.`3 + s0.`3, s.`4 + s0.`4,
     s.`5 + s0.`5, s.`6 + s0.`6, s.`7 + s0.`7, s.`8 + s0.`8).
proof. by move=> hs; rewrite compressE // /to_state /st. qed.

lemma size_compress (hv m : W32.t list) : size hv = 8 => size (compress hv m) = 8.
proof. by move=> hs; rewrite compressE. qed.

lemma size_foldl_compress (bs : W32.t list list) (hv : W32.t list) :
  size hv = 8 => size (foldl compress hv bs) = 8.
proof.
elim: bs hv => [|b bs ih] hv hs //=.
by apply ih; rewrite size_compress.
qed.

lemma to_stateK (hv : W32.t list) : size hv = 8 =>
  [(to_state hv).`1; (to_state hv).`2; (to_state hv).`3; (to_state hv).`4;
   (to_state hv).`5; (to_state hv).`6; (to_state hv).`7; (to_state hv).`8] = hv.
proof.
by case: hv => [|h0 [|h1 [|h2 [|h3 [|h4 [|h5 [|h6 [|h7 [|h8 t]]]]]]]]] //=; smt(size_ge0).
qed.

lemma ff_state (hv m : W32.t list) : size hv = 8 =>
  VPADD_4u32 (ShaNi.abef (st m (to_state hv) 16)) (ShaNi.abef (to_state hv))
    = ShaNi.abef (to_state (compress hv m)) /\
  VPADD_4u32 (ShaNi.cdgh (st m (to_state hv) 16)) (ShaNi.cdgh (to_state hv))
    = ShaNi.cdgh (to_state (compress hv m)).
proof. by move=> hs; rewrite to_state_compress // /abef /cdgh !vpadd4_pack. qed.

(* ------------------------------------------------------------------ *)
(* _sha256_compress_blocks                                             *)

(* The chaining value after the blocks consumed so far. *)
op hcur (mem : global_mem_t) (h0 : W32.t list) (p0 : W64.t) (k : int) : W32.t list =
  foldl compress h0 (parse (memread mem (W64.to_uint p0) (64 * k))).

lemma sha256_compress_blocks_correct (h0 : W32.t list) (p0 n0 : W64.t) :
  hoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))].
proof.
proc.
ecall (store_state_spec
  (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`1 (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`2
  (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`3 (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`4
  (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`5 (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`6
  (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`7 (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0))).`8).
wp.
while (0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
       W64.to_uint p = W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) /\
       W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus /\ size h0 = 8 /\
       k = sHA256_K /\ mask = bswap_mask32 /\
       abef = ShaNi.abef (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0 - W64.to_uint n))) /\
       cdgh = ShaNi.cdgh (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0 - W64.to_uint n)))).
+ wp.
  ecall (block_correct (map be32 (chunk 4 (memread Glob.mem (W64.to_uint p) 64)))
           (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0 - W64.to_uint n)))).
  while (0 <= i <= 4 /\ 0 <= W64.to_uint n <= W64.to_uint n0 /\ n <> W64.zero /\
       W64.to_uint p = W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) /\
       W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus /\ size h0 = 8 /\
       k = sHA256_K /\ mask = bswap_mask32 /\
       abef = ShaNi.abef (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0 - W64.to_uint n))) /\
       cdgh = ShaNi.cdgh (to_state (hcur Glob.mem h0 p0 (W64.to_uint n0 - W64.to_uint n))) /\
       forall j, 0 <= j < i => BArray64.get128 w j
         = let mb = map be32 (chunk 4 (memread Glob.mem (W64.to_uint p) 64)) in
           p4 (nth W32.zero mb (4 * j)) (nth W32.zero mb (4 * j + 1))
              (nth W32.zero mb (4 * j + 2)) (nth W32.zero mb (4 * j + 3))).
  + wp; skip => /> &hr hi0 _ hn0 hnn hne hp hb hs hj hi4; split; first smt().
    move=> j hj0 hj1; do !(rewrite BArray64.get_set128E 1,2:/#).
    case: (i{hr} = j) => [<-|ne] /=; last by apply hj => /#.
    have hn1 : 1 <= W64.to_uint n{hr}.
    + case: (W64.to_uint n{hr} = 0) => h1; last smt().
      by move: hne; rewrite W64.to_uint_eq h1.
    rewrite vpshufb_load128 !nth_mblock_mem 1..4:/#.
    have ->: W64.to_uint (p{hr} + W64.of_int (16 * i{hr})) = W64.to_uint p{hr} + 16 * i{hr}.
    + rewrite W64.to_uintD_small W64.of_uintK; smt(W64.to_uint_cmp pmod_small).
    by congr; congr; smt().
  wp; skip => /> &hr hn0 hnn hp hb hs hne; split; first smt().
  move=> i w hi4 hi0 _ hj.
  split; first by rewrite size_mblock_mem /=; apply wreg0; [rewrite size_mblock_mem | move=> j hj'; apply hj => /#].
  move=> _ _ [a c w'] /= -> -> {a c w'}.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + case: (W64.to_uint n{hr} = 0) => h1; last smt().
    by move: hne; rewrite W64.to_uint_eq h1.
  have hsub : W64.to_uint (n{hr} - W64.one) = W64.to_uint n{hr} - 1.
  + by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
  have hadd : W64.to_uint (p{hr} + W64.of_int 64) = W64.to_uint p{hr} + 64.
  + by rewrite W64.to_uintD_small /= /#.
  have hk : W64.to_uint n0 - (W64.to_uint n{hr} - 1) = (W64.to_uint n0 - W64.to_uint n{hr}) + 1 by ring.
  have hc : hcur Glob.mem{hr} h0 p0 (W64.to_uint n0 - W64.to_uint n{hr} + 1)
            = compress (hcur Glob.mem{hr} h0 p0 (W64.to_uint n0 - W64.to_uint n{hr}))
                       (map be32 (chunk 4 (memread Glob.mem{hr} (W64.to_uint p{hr}) 64))).
  + by rewrite /hcur parse_memreadS 1:/# foldl_rcons hp.
  have hsc : size (hcur Glob.mem{hr} h0 p0 (W64.to_uint n0 - W64.to_uint n{hr})) = 8.
  + by rewrite /hcur size_foldl_compress.
  have [ha hd] := ff_state _ (map be32 (chunk 4 (memread Glob.mem{hr} (W64.to_uint p{hr}) 64))) hsc.
  rewrite hsub hadd hk hc ha hd /=; do! split; smt().
wp; ecall (load_state_spec h); wp; skip => /> &hr hb.
split.
+ have hp0 : parse [] = [] by rewrite /parse /chunk /= mkseq0.
  rewrite /hcur /= hp0 /= mask_bswap size_hwords /=; smt(W64.to_uint_cmp).
move=> more n p _ _ _ hmore _ _ _.
have -> : n = W64.zero by smt().
split; first by rewrite /abef /cdgh.
by move=> _ _ r ->; rewrite to_stateK // /hcur size_foldl_compress // size_hwords.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop of the kernel runs over a constant range, except the
   block loop of _sha256_compress_blocks, which runs n times. *)
lemma load_state_ll : islossless M.__shani_load_state.
proof. by proc; auto. qed.

lemma store_state_ll : islossless M.__shani_store_state.
proof. by proc; auto. qed.

lemma block_ll : islossless M.__shani_block.
proof.
proc; wp; while (true) (16 - g).
+ by move=> z; auto => /#.
by auto => /#.
qed.

lemma rounds_ll : islossless M.__shani_rounds.
proof. by proc; call store_state_ll; call block_ll; wp; call load_state_ll; auto. qed.

lemma sha256_compress_ll : islossless M._sha256_compress.
proof.
proc; call rounds_ll.
while (true) (4 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_one_ll : islossless M._sha256_compress_one.
proof.
proc; call rounds_ll.
while (true) (4 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_compress_blocks_ll : islossless M._sha256_compress_blocks.
proof.
proc; call store_state_ll; wp.
while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call block_ll.
  while (true) (4 - i); first by auto => /#.
  auto => /> &hr hne i; split; first smt().
  move=> _.
  have hn1 : 1 <= W64.to_uint n{hr}.
  + case: (W64.to_uint n{hr} = 0) => h1; last smt(W64.to_uint_cmp).
    by move: hne; rewrite W64.to_uint_eq h1.
  by rewrite W64.to_uintB 1:W64.uleE /= /#.
wp; call load_state_ll; auto => /> more n.
by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. by conseq sha256_compress_ll (sha256_compress_correct h0 blk). qed.

lemma sha256_compress_one_total (h0 : W32.t list) (p0 : W64.t) :
  phoare [M._sha256_compress_one :
           hwords h = h0 /\ p = p0 /\ W64.to_uint p0 + 64 <= W64.modulus ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (memread Glob.mem (W64.to_uint p0) 64)))]
  = 1%r.
proof. by conseq sha256_compress_one_ll (sha256_compress_one_correct h0 p0). qed.

lemma sha256_compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha256_compress_blocks_ll (sha256_compress_blocks_correct h0 p0 n0). qed.
