(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_Avx2Block.ec (x86_64, avx2)
 * ====================================
 *
 * Functional correctness of _sha256_x8_block, the rounds driver of the
 * 8-way SHA-256 AVX2 kernel (src/x86_64/avx2/sha256_x8_compress.jinc):
 * with the sixteen message words of lane L's block in lane L of w[0] ..
 * w[15], every lane of h8 receives the compression function of FIPS
 * 180-4 section 6.2.2 on its own block (block_x8). Termination is in
 * SHA256_X8_Avx2.ec (x8_block_ll).
 *
 * State. h8 is u32[64] with H_j of lane L at index 8 j + L (hl, the lane
 * view of correctness/lib/Lanes.ec). After T rounds, working variable k
 * of lane L is word k of vars (hl h0 L) W T (VS), in the register the
 * round lemma names (rv). Rounds 0 .. 15 are a loop over t; rounds 16 ..
 * 63 are three passes of a loop over t = 16 .. 31 with o = 512, 1024,
 * 1536, so the round of the specification is R = o / 32 + t - 16.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray256 BArray512 BArray2048.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Rounds256 Lanes.
require import SHA256_X8_Avx2Vec SHA256_X8_Avx2Rounds SHA256_X8_Avx2Sched.
import SHA256.

clone SHA256_X8_Avx2Vec.X8Lanes as A256 with theory A <- BArray256.

(* Lane L of the 8-way state: H_0 .. H_7 of instance L. *)
op hl (h : BArray256.t) (L : int) : W32.t list = lane 8 (BArray256.get32 h) L.

(* The working variables of every lane after T rounds, with ws L the
   schedule of lane L. The schedules and the constants kt are parameters
   rather than schedule (ms L) and K256: simplifying a goal that holds
   either unrolls the schedule or evaluates the 64-entry literal. *)
op VS (h0 : BArray256.t) (ws : int -> W32.t list) (T : int) : int -> W32.t list =
  fun L => vars (hl h0 L) (ws L) T.

(* The constant table, as the rounds read it. *)
op kok (kp : BArray2048.t) (kt : W32.t list) =
  forall R L, 0 <= R < 64 => 0 <= L < 8 => BArray2048.get256 kp R \bits32 L = nth W32.zero kt R.

(* The message words of every lane, in the window. *)
op msg (w : BArray512.t) (ms : int -> W32.t list) =
  forall L j, 0 <= L < 8 => 0 <= j < 16 => BArray512.get256 w j \bits32 L = nth W32.zero (ms L) j.

(* The carry b ^ c, in c0 before an even round and in c1 before an odd one. *)
op par (t : int) (c0 c1 : W256.t) (vs : int -> W32.t list) =
  forall L, 0 <= L < 8 => (if t %% 2 = 0 then c0 else c1) \bits32 L = bc (vs L).

(* The schedules ws are those of the blocks ms. *)
op wsok (ms ws : int -> W32.t list) =
  forall L, 0 <= L < 8 => size (ms L) = 16 /\ ws L = schedule (ms L).

lemma size_hl h L : size (hl h L) = 8.
proof. by rewrite /hl size_lane. qed.

lemma rv_ext v t (f g : int -> W32.t list) :
  (forall L, 0 <= L < 8 => f L = g L) => rv v t f => rv v t g.
proof. by move=> hfg hr L k hL hk; rewrite -hfg // hr. qed.

lemma VS_step h0 ws kt T : kt = K256 => 0 <= T =>
  forall L, 0 <= L < 8 =>
  (fun L => step (VS h0 ws T L) (nth W32.zero kt T + nth W32.zero (ws L) T)) L
  = VS h0 ws (T + 1) L.
proof. by move=> -> hT L hL; rewrite /VS /= vars_step. qed.

lemma bc_next hv w T : 0 <= T =>
  bc (vars hv w (T + 1)) = nth W32.zero (vars hv w T) 0 +^ nth W32.zero (vars hv w T) 1.
proof. by move=> hT; rewrite /bc varsS. qed.

lemma bc_VS h0 ws T L : 0 <= T =>
  bc (VS h0 ws (T + 1) L) = nth W32.zero (VS h0 ws T L) 0 +^ nth W32.zero (VS h0 ws T L) 1.
proof. by move=> hT; rewrite /VS /= bc_next. qed.

lemma rv0 v h0 ws :
  (forall j, 0 <= j < 8 => BArray256.get256 v j = BArray256.get256 h0 j) =>
  rv v 0 (VS h0 ws 0).
proof.
move=> hv L k hL hk.
by rewrite ix0 // hv // A256.get256_bits32 // /VS vars0 ?size_hl // /hl nth_lane.
qed.

lemma odd_next t : t %% 2 = 0 => (t + 1) %% 2 <> 0.
proof. by move=> h; rewrite -modzDml h. qed.

lemma even_next t : t %% 2 <> 0 => (t + 1) %% 2 = 0.
proof. by move=> h; rewrite -modzDml (_: t %% 2 = 1); 1: smt(modz_cmp). qed.

(* Sixteen rounds later every variable is back in its register. *)
lemma rv16 v t vs : rv v (t + 16) vs => rv v t vs.
proof. by move=> h L k hL hk; rewrite -ix16 h. qed.

(* The pass counter o of rounds 16 .. 63: 512, 1024, 1536, then 2048. *)
lemma o_cases o : 512 <= o <= 2048 => o %% 512 = 0 =>
  o = 512 \/ o = 1024 \/ o = 1536 \/ o = 2048.
proof. by move=> h1 h2; have := divz_eq o 512; rewrite h2 /=; smt(). qed.

(* In pass o, round t of the loop is round o / 32 + t - 16. *)
lemma o_round o t : o = 512 \/ o = 1024 \/ o = 1536 => 16 <= t < 32 =>
  t %% 16 = (o %/ 32 + t - 16) %% 16 /\ 16 <= o %/ 32 + t - 16 < 64 /\
  o + 32 * (t - 16) = 32 * (o %/ 32 + t - 16).
proof.
move=> ho ht; case: ho => [->|[->|->]] /=.
+ smt().
+ by rewrite (_: 16 + t = t + 1 * 16) 1:/# modzMDr; smt().
by rewrite (_: 32 + t = t + 2 * 16) 1:/# modzMDr; smt().
qed.

lemma o_add (o : W64.t) n : 0 <= n < 4096 => W64.to_uint o <= 2048 =>
  W64.to_uint (o + W64.of_int n) = W64.to_uint o + n.
proof.
move=> hn ho; rewrite W64.to_uintD_small !W64.of_uintK (pmod_small n) //; smt(W64.to_uint_cmp).
qed.

(* W_t = M_t in rounds 0 .. 15. *)
lemma ws_lo ms ws L t : wsok ms ws => 0 <= L < 8 => 0 <= t < 16 =>
  nth W32.zero (ws L) t = nth W32.zero (ms L) t.
proof. by move=> h hL ht; have [hs ->] := h L hL; rewrite nth_schedule_lo. qed.

lemma size_ffwd s (hv : W32.t list) : size hv = 8 => size (ffwd s hv) = 8.
proof. by move=> h; rewrite /ffwd size_map size_zip size_of_state h. qed.

lemma nth_ffwd s (hv : W32.t list) k : size hv = 8 => 0 <= k < 8 =>
  nth W32.zero (ffwd s hv) k = nth W32.zero (of_state s) k + nth W32.zero hv k.
proof.
move=> hs hk; rewrite /ffwd (nth_map (W32.zero, W32.zero)).
+ by rewrite size_zip size_of_state hs.
by rewrite nth_zip // size_of_state hs.
qed.

(* Before round 16 the window holds the message words. *)
lemma wins_init w ms ws : msg w ms => wsok ms ws => wins w ws 16.
proof.
move=> hm hws L hL j; rewrite /max /= => hj.
by rewrite /wg /= pmod_small // (hm L j hL hj) (ws_lo _ _ _ _ hws hL hj).
qed.

lemma block_x8g (h0 : BArray256.t) (ms0 ws : int -> W32.t list) (kt : W32.t list) :
  wsok ms0 ws => kt = K256 =>
  hoare [M._sha256_x8_block :
    h8 = h0 /\ msg w ms0 ==>
    forall L, 0 <= L < 8 => hl res.`1 L = ffwd (rounds (ws L) (to_state (hl h0 L)) 0 64) (hl h0 L)].
proof.
move=> hws hkt; proc.
(* v <- h8 *)
seq 4 : (h8 = h0 /\ msg w ms0 /\
         forall j, 0 <= j < 8 => BArray256.get256 v j = BArray256.get256 h0 j).
+ wp; while (0 <= i <= 8 /\ h8 = h0 /\ msg w ms0 /\
             forall j, 0 <= j < i => BArray256.get256 v j = BArray256.get256 h0 j).
  + wp; skip => &hr [#] hi0 hi1 -> hm hv hi /=; do !split => //; 1,2: smt().
    by move=> j hj; rewrite BArray256.get_set256E 1,2:/#; smt().
  by wp; skip => />; smt().
(* the table and the first carry *)
seq 3 : (t = 0 /\ h8 = h0 /\ msg w ms0 /\ kok kp kt /\
         rv v 0 (VS h0 ws 0) /\ par 0 c0 c1 (VS h0 ws 0)).
+ wp; skip => &hr [#] -> hm hv; split; 1: done.
  split; 1: done. split; 1: done.
  split; 1: by move=> R L hR hL; rewrite hkt; exact K8_kernel.
  have hr0 := rv0 _ _ ws hv; split; 1: done.
  move=> L hL /=.
  have h1 := hr0 L 1 hL _; 1: done.
  have h2 := hr0 L 2 hL _; 1: done.
  by move: h1 h2; rewrite !ix0 // => -> ->.
(* rounds 0 .. 15 *)
seq 1 : (t = 16 /\ h8 = h0 /\ msg w ms0 /\ kok kp kt /\
         rv v 16 (VS h0 ws 16) /\ par 16 c0 c1 (VS h0 ws 16)).
+ while (0 <= t <= 16 /\ h8 = h0 /\ msg w ms0 /\ kok kp kt /\
         rv v t (VS h0 ws t) /\ par t c0 c1 (VS h0 ws t)).
  + seq 2 : (0 <= t < 16 /\ h8 = h0 /\ msg w ms0 /\ kok kp kt /\
             rv v t (VS h0 ws t) /\ par t c0 c1 (VS h0 ws t) /\
             forall L, 0 <= L < 8 => wk \bits32 L = nth W32.zero kt t + nth W32.zero (ws L) t).
    + wp; skip => &hr [#] ht0 ht1 -> hm hk hr hp ht /=; do !split => //.
      move=> L hL; have ht16 : 0 <= t{hr} < 16 by done.
      have ht64 : 0 <= t{hr} < 64 by smt().
      by rewrite vpadd32 // (hm _ _ hL ht16) (hk _ _ ht64 hL) (ws_lo _ _ _ _ hws hL ht16) addrC.
    wp; if.
    + ecall (round_x8 t v (VS h0 ws t) (fun L => nth W32.zero kt t + nth W32.zero (ws L) t)).
      skip => &hr [#] ht0 ht1 -> hm hk hr hp hwk heven /=.
      split.
      + split; 1: exact hr. split; 1: exact hwk.
        by move=> L hL; have := hp L hL; rewrite heven.
      move=> _ r [hr1 hr2]; split; 1: smt(). split; 1: exact hm. split; 1: exact hk.
      split; 1: exact (rv_ext _ _ _ _ (VS_step h0 ws kt t{hr} hkt ht0) hr1).
      move=> L hL; have ho := odd_next _ heven.
      by rewrite ifF // hr2 // /VS /= bc_next.
    ecall (round_x8 t v (VS h0 ws t) (fun L => nth W32.zero kt t + nth W32.zero (ws L) t)).
    skip => &hr [#] ht0 ht1 -> hm hk hr hp hwk hodd /=.
    split.
    + split; 1: exact hr. split; 1: exact hwk.
      by move=> L hL; have := hp L hL; rewrite ifF.
    move=> _ r [hr1 hr2]; split; 1: smt(). split; 1: exact hm. split; 1: exact hk.
    split; 1: exact (rv_ext _ _ _ _ (VS_step h0 ws kt t{hr} hkt ht0) hr1).
    move=> L hL; have he := even_next _ hodd.
    by rewrite ifT // hr2 // /VS /= bc_next.
  skip => &hr [#] -> -> hm hk hr hp.
  split; 1: by do !split => //.
  move=> c0' c1' t' v' ht [#] h0' h1' _ hm' hk' hr' hp'.
  have ->> : t' = 16 by smt().
  by do !split => //.
(* rounds 16 .. 63 *)
seq 3 : (h8 = h0 /\ rv v 16 (VS h0 ws 64)).
+ while (h8 = h0 /\ kok kp kt /\ 512 <= to_uint o <= 2048 /\ to_uint o %% 512 = 0 /\
         more = (to_uint o <= 1536) /\
         rv v 16 (VS h0 ws (to_uint o %/ 32)) /\ par 16 c0 c1 (VS h0 ws (to_uint o %/ 32)) /\
         wins w ws (to_uint o %/ 32)).
  + wp.
    while (h8 = h0 /\ kok kp kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536) /\
           16 <= t <= 32 /\
           rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
           par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
           wins w ws (to_uint o %/ 32 + t - 16)).
    + seq 1 : (h8 = h0 /\ kok kp kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536) /\
               16 <= t < 32 /\
               rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               wins w ws (to_uint o %/ 32 + t - 16 + 1) /\
               forall L, 0 <= L < 8 => wk \bits32 L = nth W32.zero (ws L) (to_uint o %/ 32 + t - 16)).
      + ecall (schedule_x8 t (to_uint o %/ 32 + t - 16) w ms0 ws hws).
        skip => &hr [#] -> hk ho ht1 ht2 hr hp hw ht.
        have [h16 [hR _]] := o_round _ t{hr} ho _; 1: smt().
        split; 1: by do !split => //; smt().
        move=> _ r [hw' hwk]; do !split => //; smt().
      seq 1 : (h8 = h0 /\ kok kp kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536) /\
               16 <= t < 32 /\
               rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               wins w ws (to_uint o %/ 32 + t - 16 + 1) /\
               forall L, 0 <= L < 8 => wk \bits32 L =
                 nth W32.zero kt (to_uint o %/ 32 + t - 16) + nth W32.zero (ws L) (to_uint o %/ 32 + t - 16)).
      + wp; skip => &hr [#] -> hk ho ht1 ht2 hr hp hw hwk.
        have [h16 [hR hoR]] := o_round _ t{hr} ho _; 1: smt().
        have hoo : to_uint (o{hr} + W64.of_int (32 * (t{hr} - 16))) = 32 * (to_uint o{hr} %/ 32 + t{hr} - 16).
        + by rewrite o_add 1,2:/#; exact hoR.
        have hR0 : 0 <= to_uint o{hr} %/ 32 + t{hr} - 16 < 64 by smt().
        do 7!(split; 1: done).
        by move=> L hL; rewrite vpadd32 // hwk // hoo (hk _ _ hR0 hL) addrC.
      wp; if.
      + ecall (round_x8 t v (VS h0 ws (to_uint o %/ 32 + t - 16))
               (fun L => nth W32.zero kt (to_uint o %/ 32 + t - 16) + nth W32.zero (ws L) (to_uint o %/ 32 + t - 16))).
        skip => &hr [#] -> hk ho ht1 ht2 hr hp hw hwk heven /=.
        have [h16 [hR _]] := o_round _ t{hr} ho _; 1: smt().
        have hRS : to_uint o{hr} %/ 32 + (t{hr} + 1) - 16 = to_uint o{hr} %/ 32 + t{hr} - 16 + 1 by ring.
        split.
        + split; 1: exact hr. split; 1: exact hwk.
          by move=> L hL; have := hp L hL; rewrite heven.
        move=> _ r [hr1 hr2]; rewrite hRS; split; 1: exact hk. split; 1: exact ho. split; 1: smt().
        have hR0 : 0 <= to_uint o{hr} %/ 32 + t{hr} - 16 by smt().
        split; 1: exact (rv_ext _ _ _ _ (VS_step h0 ws kt _ hkt hR0) hr1).
        split; 2: exact hw.
        move=> L hL; have ho' := odd_next _ heven.
        by rewrite ifF // hr2 // bc_VS; smt().
      ecall (round_x8 t v (VS h0 ws (to_uint o %/ 32 + t - 16))
             (fun L => nth W32.zero kt (to_uint o %/ 32 + t - 16) + nth W32.zero (ws L) (to_uint o %/ 32 + t - 16))).
      skip => &hr [#] -> hk ho ht1 ht2 hr hp hw hwk hodd /=.
      have [h16 [hR _]] := o_round _ t{hr} ho _; 1: smt().
      have hRS : to_uint o{hr} %/ 32 + (t{hr} + 1) - 16 = to_uint o{hr} %/ 32 + t{hr} - 16 + 1 by ring.
      split.
      + split; 1: exact hr. split; 1: exact hwk.
        by move=> L hL; have := hp L hL; rewrite ifF.
      move=> _ r [hr1 hr2]; rewrite hRS; split; 1: exact hk. split; 1: exact ho. split; 1: smt().
      have hR0 : 0 <= to_uint o{hr} %/ 32 + t{hr} - 16 by smt().
        split; 1: exact (rv_ext _ _ _ _ (VS_step h0 ws kt _ hkt hR0) hr1).
      split; 2: exact hw.
      move=> L hL; have he := even_next _ hodd.
      by rewrite ifT // hr2 // bc_VS; smt().
    wp; skip => &hr [#] -> hk ho1 ho2 hom hmore hr hp hw hc.
    have hos : to_uint o{hr} = 512 \/ to_uint o{hr} = 1024 \/ to_uint o{hr} = 1536.
    + have := o_cases _ _ hom; 1: by split. smt().
    have h1616 : to_uint o{hr} %/ 32 + 16 - 16 = to_uint o{hr} %/ 32 by ring.
    split; 1: by rewrite h1616; do !split => //.
    move=> c0' c1' t' v' w' ht [#] _ _ _ ht1 ht2 hr' hp' hw' /=.
    have ->> : t' = 32 by smt().
    have hoa := o_add o{hr} 512 _ _; 1,2: smt().
    have hdiv : to_uint (o{hr} + W64.of_int 512) %/ 32 = to_uint o{hr} %/ 32 + 32 - 16.
    + by rewrite hoa; case: hos => [->|[->|->]].
    rewrite hdiv; split; 1: exact hk.
    split; 1: by rewrite hoa; smt().
    split; 1: by rewrite hoa; case: hos => [->|[->|->]].
    split; 1: by rewrite W64.uleE W64.of_uintK.
    split; 1: by apply rv16.
    split; 2: exact hw'.
    by move=> L hL /=; have /= := hp' L hL.
  wp; skip => &hr [#] _ -> hm hk hr hp /=.
  split.
  + split; 1: exact hk. split; 1: exact hr. split; 1: exact hp.
    exact (wins_init _ _ _ hm hws).
  move=> c0' c1' more' o' v' w' hm' [#] hk' ho1 ho2 hom hmo hr' hp' hw'.
  have h2048 : to_uint o' = 2048.
  + have := o_cases _ _ hom; 1: by split. smt().
  by move: hr'; rewrite h2048.
(* step 4: h8 <- h8 + v *)
wp; while (0 <= i <= 8 /\ rv v 16 (VS h0 ws 64) /\
           (forall j, 0 <= j < i =>
              BArray256.get256 h8 j = VPADD_8u32 (BArray256.get256 h0 j) (BArray256.get256 v j)) /\
           (forall j, i <= j < 8 => BArray256.get256 h8 j = BArray256.get256 h0 j)).
+ wp; skip => &hr [#] hi0 hi1 hr hd hu hi.
  split; 1: smt(). split; 1: exact hr. split.
  + move=> j hj; rewrite BArray256.get_set256E 1,2:/#.
    by case: (i{hr} = j) => [<-|hne]; [rewrite hu /# | rewrite hd /#].
  by move=> j hj; rewrite BArray256.get_set256E 1,2:/# ifF 1:/# hu /#.
wp; skip => &hr [#] -> hr; split; 1: by split; [smt() | split; [exact hr | smt()]].
move=> h8' i' hi [#] hi0 hi1 _ hd _ L hL.
have ->> : i' = 8 by smt().
apply (eq_from_nth W32.zero); first by rewrite size_hl size_ffwd // size_hl.
move=> k; rewrite size_hl => hk.
rewrite /= nth_ffwd ?size_hl // /hl !nth_lane //= -!A256.get256_bits32 // hd // vpadd32 //.
have := hr L k hL hk; rewrite (ix16 k 0) ix0 // /VS /vars => ->.
by rewrite addrC.
qed.

lemma block_x8 (h0 : BArray256.t) (ms0 : int -> W32.t list) :
  (forall L, 0 <= L < 8 => size (ms0 L) = 16) =>
  hoare [M._sha256_x8_block :
    h8 = h0 /\ msg w ms0 ==>
    forall L, 0 <= L < 8 => hl res.`1 L = compress (hl h0 L) (ms0 L)].
proof.
move=> hs; conseq (block_x8g h0 ms0 (fun L => schedule (ms0 L)) K256 _ _) => //.
+ by move=> &hr _ r h L hL; rewrite compress_rounds h.
qed.
