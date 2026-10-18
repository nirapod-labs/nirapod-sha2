(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4_Avx2Block.ec (x86_64, avx2)
 * ====================================
 *
 * Functional correctness of _sha512_x4_block, the rounds driver of the
 * 4-way SHA-512 AVX2 kernel (src/x86_64/avx2/sha512_x4_compress.jinc):
 * with the sixteen message words of lane L's block in lane L of w[0] ..
 * w[15], every lane of h4 receives the compression function of FIPS
 * 180-4 section 6.4.2 on its own block (block_x4). Termination is in
 * SHA512_X4_Avx2.ec (x4_block_ll).
 *
 * State. h4 is u64[32] with H_j of lane L at index 4 j + L (hl, the lane
 * view of correctness/lib/Lanes.ec). After T rounds, working variable k
 * of lane L is word k of vars (hl h0 L) W T (VS), in the register the
 * round lemma names (rv). Rounds 0 .. 15 are a loop over t; rounds 16 ..
 * 79 are four passes of a loop over t = 16 .. 31 with o = 512, 1024,
 * 1536, 2048, so the round of the specification is R = o / 32 + t - 16.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray256 BArray512 BArray2560.
require import NirapodSha2.
require import FIPS180_SHA2 WordSpec Lanes64 Rounds512 Lanes.
require import SHA512_X4_Avx2Vec SHA512_X4_Avx2Rounds SHA512_X4_Avx2Sched.
import SHA512.

clone SHA512_X4_Avx2Vec.X4Lanes as A256 with theory A <- BArray256.

(* Lane L of the 8-way state: H_0 .. H_7 of instance L. *)
op hl (h : BArray256.t) (L : int) : W64.t list = lane 4 (BArray256.get64 h) L.

(* The working variables of every lane after T rounds, with ws L the
   schedule of lane L. The schedules and the constants kt are parameters
   rather than schedule (ms L) and K512: simplifying a goal that holds
   either unrolls the schedule or evaluates the 80-entry literal. *)
op VS (h0 : BArray256.t) (ws : int -> W64.t list) (T : int) : int -> W64.t list =
  fun L => vars (hl h0 L) (ws L) T.

(* The constant table and the ROTR^8 mask, as the rounds read them. *)
(* A quantifier at the head, so that split leaves it whole. *)
op kok (kp : BArray2560.t) (m : W256.t) (kt : W64.t list) =
  forall R L, m = ror8_mask4 /\
    (0 <= R < 80 => 0 <= L < 4 => BArray2560.get256 kp R \bits64 L = nth W64.zero kt R).

lemma kokM kp m kt : kok kp m kt => m = ror8_mask4.
proof. by move=> h; have [h1 _] := h 0 0; exact h1. qed.

lemma kokK kp m kt R L : kok kp m kt => 0 <= R < 80 => 0 <= L < 4 =>
  BArray2560.get256 kp R \bits64 L = nth W64.zero kt R.
proof. by move=> h hR hL; have [_ h2] := h R L; exact (h2 hR hL). qed.

(* The message words of every lane, in the window. *)
op msg (w : BArray512.t) (ms : int -> W64.t list) =
  forall L j, 0 <= L < 4 => 0 <= j < 16 => BArray512.get256 w j \bits64 L = nth W64.zero (ms L) j.

(* The carry b ^ c, in c0 before an even round and in c1 before an odd one. *)
op par (t : int) (c0 c1 : W256.t) (vs : int -> W64.t list) =
  forall L, 0 <= L < 4 => (if t %% 2 = 0 then c0 else c1) \bits64 L = bc (vs L).

(* The schedules ws are those of the blocks ms. *)
op wsok (ms ws : int -> W64.t list) =
  forall L, 0 <= L < 4 => size (ms L) = 16 /\ ws L = schedule (ms L).

lemma size_hl h L : size (hl h L) = 8.
proof. by rewrite /hl size_lane. qed.

lemma rv_ext v t (f g : int -> W64.t list) :
  (forall L, 0 <= L < 4 => f L = g L) => rv v t f => rv v t g.
proof. by move=> hfg hr L k hL hk; rewrite -hfg // hr. qed.

lemma VS_step h0 ws kt T : kt = K512 => 0 <= T =>
  forall L, 0 <= L < 4 =>
  (fun L => step (VS h0 ws T L) (nth W64.zero kt T + nth W64.zero (ws L) T)) L
  = VS h0 ws (T + 1) L.
proof. by move=> -> hT L hL; rewrite /VS /= vars_step. qed.

lemma bc_next hv w T : 0 <= T =>
  bc (vars hv w (T + 1)) = nth W64.zero (vars hv w T) 0 +^ nth W64.zero (vars hv w T) 1.
proof. by move=> hT; rewrite /bc varsS. qed.

lemma bc_VS h0 ws T L : 0 <= T =>
  bc (VS h0 ws (T + 1) L) = nth W64.zero (VS h0 ws T L) 0 +^ nth W64.zero (VS h0 ws T L) 1.
proof. by move=> hT; rewrite /VS /= bc_next. qed.

lemma rv0 v h0 ws :
  (forall j, 0 <= j < 8 => BArray256.get256 v j = BArray256.get256 h0 j) =>
  rv v 0 (VS h0 ws 0).
proof.
move=> hv L k hL hk.
by rewrite ix0 // hv // A256.get256_bits64 // /VS vars0 ?size_hl // /hl nth_lane.
qed.

lemma odd_next t : t %% 2 = 0 => (t + 1) %% 2 <> 0.
proof. by move=> h; rewrite -modzDml h. qed.

lemma even_next t : t %% 2 <> 0 => (t + 1) %% 2 = 0.
proof. by move=> h; rewrite -modzDml (_: t %% 2 = 1); 1: smt(modz_cmp). qed.

(* Sixteen rounds later every variable is back in its register. *)
lemma rv16 v t vs : rv v (t + 16) vs => rv v t vs.
proof. by move=> h L k hL hk; rewrite -ix16 h. qed.

(* The pass counter o of rounds 16 .. 79: 512, 1024, 1536, 2048, then 2560. *)
lemma o_cases o : 512 <= o <= 2560 => o %% 512 = 0 =>
  o = 512 \/ o = 1024 \/ o = 1536 \/ o = 2048 \/ o = 2560.
proof. by move=> h1 h2; have := divz_eq o 512; rewrite h2 /=; smt(). qed.

(* In pass o, round t of the loop is round o / 32 + t - 16. *)
lemma o_round o t : o = 512 \/ o = 1024 \/ o = 1536 \/ o = 2048 => 16 <= t < 32 =>
  t %% 16 = (o %/ 32 + t - 16) %% 16 /\ 16 <= o %/ 32 + t - 16 < 80 /\
  o + 32 * (t - 16) = 32 * (o %/ 32 + t - 16).
proof.
move=> ho ht; case: ho => [->|[->|[->|->]]] /=.
+ smt().
+ by rewrite (_: 16 + t = t + 1 * 16) 1:/# modzMDr; smt().
+ by rewrite (_: 32 + t = t + 2 * 16) 1:/# modzMDr; smt().
by rewrite (_: 48 + t = t + 3 * 16) 1:/# modzMDr; smt().
qed.

lemma o_add (o : W64.t) n : 0 <= n < 4096 => W64.to_uint o <= 2048 =>
  W64.to_uint (o + W64.of_int n) = W64.to_uint o + n.
proof.
move=> hn ho; rewrite W64.to_uintD_small !W64.of_uintK (pmod_small n) //; smt(W64.to_uint_cmp).
qed.

(* W_t = M_t in rounds 0 .. 15. *)
lemma ws_lo ms ws L t : wsok ms ws => 0 <= L < 4 => 0 <= t < 16 =>
  nth W64.zero (ws L) t = nth W64.zero (ms L) t.
proof. by move=> h hL ht; have [hs ->] := h L hL; rewrite nth_schedule_lo. qed.

lemma size_ffwd s (hv : W64.t list) : size hv = 8 => size (ffwd s hv) = 8.
proof. by move=> h; rewrite /ffwd size_map size_zip size_of_state h. qed.

lemma nth_ffwd s (hv : W64.t list) k : size hv = 8 => 0 <= k < 8 =>
  nth W64.zero (ffwd s hv) k = nth W64.zero (of_state s) k + nth W64.zero hv k.
proof.
move=> hs hk; rewrite /ffwd (nth_map (W64.zero, W64.zero)).
+ by rewrite size_zip size_of_state hs.
by rewrite nth_zip // size_of_state hs.
qed.

(* Before round 16 the window holds the message words. *)
lemma wins_init w ms ws : msg w ms => wsok ms ws => wins w ws 16.
proof.
move=> hm hws L hL j; rewrite /max /= => hj.
by rewrite /wg /= pmod_small // (hm L j hL hj) (ws_lo _ _ _ _ hws hL hj).
qed.

lemma block_x4g (h0 : BArray256.t) (ms0 ws : int -> W64.t list) (kt : W64.t list) :
  wsok ms0 ws => kt = K512 =>
  hoare [M._sha512_x4_block :
    h4 = h0 /\ msg w ms0 ==>
    forall L, 0 <= L < 4 => hl res.`1 L = ffwd (rounds (ws L) (to_state (hl h0 L)) 0 80) (hl h0 L)].
proof.
move=> hws hkt; proc.
(* v <- h4 *)
seq 5 : (h4 = h0 /\ msg w ms0 /\
         forall j, 0 <= j < 8 => BArray256.get256 v j = BArray256.get256 h0 j).
+ wp; while (0 <= i <= 8 /\ h4 = h0 /\ msg w ms0 /\
             forall j, 0 <= j < i => BArray256.get256 v j = BArray256.get256 h0 j).
  + wp; skip => &hr [#] hi0 hi1 -> hm hv hi /=; do !split => //; 1,2: smt().
    by move=> j hj; rewrite BArray256.get_set256E 1,2:/#; smt().
  by wp; skip => />; smt().
(* the table and the first carry *)
seq 5 : (t = 0 /\ h4 = h0 /\ msg w ms0 /\ kok kp ror8 kt /\
         rv v 0 (VS h0 ws 0) /\ par 0 c0 c1 (VS h0 ws 0)).
+ wp; skip => &hr [#] -> hm hv; split; 1: done.
  split; 1: done. split; 1: done.
  split; 1: by move=> R L; split; [exact ror8E | move=> hR hL; rewrite hkt; exact K4_kernel].
  have hr0 := rv0 _ _ ws hv; split; 1: done.
  move=> L hL /=.
  have h1 := hr0 L 1 hL _; 1: done.
  have h2 := hr0 L 2 hL _; 1: done.
  by move: h1 h2; rewrite !ix0 // => -> ->.
(* rounds 0 .. 15 *)
seq 1 : (t = 16 /\ h4 = h0 /\ msg w ms0 /\ kok kp ror8 kt /\
         rv v 16 (VS h0 ws 16) /\ par 16 c0 c1 (VS h0 ws 16)).
+ while (0 <= t <= 16 /\ h4 = h0 /\ msg w ms0 /\ kok kp ror8 kt /\
         rv v t (VS h0 ws t) /\ par t c0 c1 (VS h0 ws t)).
  + seq 2 : (0 <= t < 16 /\ h4 = h0 /\ msg w ms0 /\ kok kp ror8 kt /\
             rv v t (VS h0 ws t) /\ par t c0 c1 (VS h0 ws t) /\
             forall L, 0 <= L < 4 => wk \bits64 L = nth W64.zero kt t + nth W64.zero (ws L) t).
    + wp; skip => &hr [#] ht0 ht1 -> hm hk hr hp ht /=; do !split => //.
      move=> L hL; have ht16 : 0 <= t{hr} < 16 by done.
      have ht64 : 0 <= t{hr} < 80 by smt().
      by rewrite vpadd64 // (hm _ _ hL ht16) (kokK _ _ _ _ _ hk ht64 hL) (ws_lo _ _ _ _ hws hL ht16) addrC.
    wp; if.
    + ecall (round_x4 t v (VS h0 ws t) (fun L => nth W64.zero kt t + nth W64.zero (ws L) t)).
      skip => &hr [#] ht0 ht1 -> hm hk hr hp hwk heven /=.
      split.
      + split; 1: exact hr. split; 1: exact hwk.
        by move=> L hL; have := hp L hL; rewrite heven.
      move=> _ r [hr1 hr2]; split; 1: smt(). split; 1: exact hm. split; 1: exact hk.
      split; 1: exact (rv_ext _ _ _ _ (VS_step h0 ws kt t{hr} hkt ht0) hr1).
      move=> L hL; have ho := odd_next _ heven.
      by rewrite ifF // hr2 // /VS /= bc_next.
    ecall (round_x4 t v (VS h0 ws t) (fun L => nth W64.zero kt t + nth W64.zero (ws L) t)).
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
seq 3 : (h4 = h0 /\ rv v 16 (VS h0 ws 80)).
+ while (h4 = h0 /\ kok kp ror8 kt /\ 512 <= to_uint o <= 2560 /\ to_uint o %% 512 = 0 /\
         more = (to_uint o <= 2048) /\
         rv v 16 (VS h0 ws (to_uint o %/ 32)) /\ par 16 c0 c1 (VS h0 ws (to_uint o %/ 32)) /\
         wins w ws (to_uint o %/ 32)).
  + wp.
    while (h4 = h0 /\ kok kp ror8 kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536 \/ to_uint o = 2048) /\
           16 <= t <= 32 /\
           rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
           par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
           wins w ws (to_uint o %/ 32 + t - 16)).
    + seq 1 : (h4 = h0 /\ kok kp ror8 kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536 \/ to_uint o = 2048) /\
               16 <= t < 32 /\
               rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               wins w ws (to_uint o %/ 32 + t - 16 + 1) /\
               forall L, 0 <= L < 4 => wk \bits64 L = nth W64.zero (ws L) (to_uint o %/ 32 + t - 16)).
      + ecall (schedule_x4 t (to_uint o %/ 32 + t - 16) w ms0 ws hws).
        skip => &hr [#] -> hk ho ht1 ht2 hr hp hw ht.
        have hm8 := kokM _ _ _ hk.
        have [h16 [hR _]] := o_round _ t{hr} ho _; 1: smt().
        split; 1: by do !split => //; smt().
        move=> _ r [hw' hwk]; do !split => //; smt().
      seq 1 : (h4 = h0 /\ kok kp ror8 kt /\ (to_uint o = 512 \/ to_uint o = 1024 \/ to_uint o = 1536 \/ to_uint o = 2048) /\
               16 <= t < 32 /\
               rv v t (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               par t c0 c1 (VS h0 ws (to_uint o %/ 32 + t - 16)) /\
               wins w ws (to_uint o %/ 32 + t - 16 + 1) /\
               forall L, 0 <= L < 4 => wk \bits64 L =
                 nth W64.zero kt (to_uint o %/ 32 + t - 16) + nth W64.zero (ws L) (to_uint o %/ 32 + t - 16)).
      + wp; skip => &hr [#] -> hk ho ht1 ht2 hr hp hw hwk.
        have [h16 [hR hoR]] := o_round _ t{hr} ho _; 1: smt().
        have hoo : to_uint (o{hr} + W64.of_int (32 * (t{hr} - 16))) = 32 * (to_uint o{hr} %/ 32 + t{hr} - 16).
        + have hle : to_uint o{hr} <= 2048 by case: ho => [->|[->|[->|->]]].
          have h4096 : 0 <= 32 * (t{hr} - 16) < 4096 by smt().
          by rewrite (o_add _ _ h4096 hle); exact hoR.
        have hR0 : 0 <= to_uint o{hr} %/ 32 + t{hr} - 16 < 80 by smt().
        do 7!(split; 1: done).
        by move=> L hL; rewrite vpadd64 // hwk // hoo (kokK _ _ _ _ _ hk hR0 hL) addrC.
      wp; if.
      + ecall (round_x4 t v (VS h0 ws (to_uint o %/ 32 + t - 16))
               (fun L => nth W64.zero kt (to_uint o %/ 32 + t - 16) + nth W64.zero (ws L) (to_uint o %/ 32 + t - 16))).
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
      ecall (round_x4 t v (VS h0 ws (to_uint o %/ 32 + t - 16))
             (fun L => nth W64.zero kt (to_uint o %/ 32 + t - 16) + nth W64.zero (ws L) (to_uint o %/ 32 + t - 16))).
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
    have hos : to_uint o{hr} = 512 \/ to_uint o{hr} = 1024 \/ to_uint o{hr} = 1536 \/ to_uint o{hr} = 2048.
    + have := o_cases _ _ hom; 1: by split. smt().
    have h1616 : to_uint o{hr} %/ 32 + 16 - 16 = to_uint o{hr} %/ 32 by ring.
    split; 1: by rewrite h1616; do !split => //.
    move=> c0' c1' t' v' w' ht [#] _ _ _ ht1 ht2 hr' hp' hw' /=.
    have ->> : t' = 32 by smt().
    have hoa := o_add o{hr} 512 _ _; 1,2: smt().
    have hdiv : to_uint (o{hr} + W64.of_int 512) %/ 32 = to_uint o{hr} %/ 32 + 32 - 16.
    + by rewrite hoa; case: hos => [->|[->|[->|->]]].
    rewrite hdiv; split; 1: exact hk.
    split; 1: by rewrite hoa; smt().
    split; 1: by rewrite hoa; case: hos => [->|[->|[->|->]]].
    split; 1: by rewrite W64.uleE W64.of_uintK.
    split; 1: by apply rv16.
    split; 2: exact hw'.
    by move=> L hL /=; have /= := hp' L hL.
  wp; skip => &hr [#] _ -> hm hk hr hp /=.
  split.
  + split; 1: exact hk. split; 1: exact hr. split; 1: exact hp.
    exact (wins_init _ _ _ hm hws).
  move=> c0' c1' more' o' v' w' hm' [#] hk' ho1 ho2 hom hmo hr' hp' hw'.
  have h2048 : to_uint o' = 2560.
  + have := o_cases _ _ hom; 1: by split. smt().
  by move: hr'; rewrite h2048.
(* step 4: h4 <- h4 + v *)
wp; while (0 <= i <= 8 /\ rv v 16 (VS h0 ws 80) /\
           (forall j, 0 <= j < i =>
              BArray256.get256 h4 j = VPADD_4u64 (BArray256.get256 h0 j) (BArray256.get256 v j)) /\
           (forall j, i <= j < 8 => BArray256.get256 h4 j = BArray256.get256 h0 j)).
+ wp; skip => &hr [#] hi0 hi1 hr hd hu hi.
  split; 1: smt(). split; 1: exact hr. split.
  + move=> j hj; rewrite BArray256.get_set256E 1,2:/#.
    by case: (i{hr} = j) => [<-|hne]; [rewrite hu /# | rewrite hd /#].
  by move=> j hj; rewrite BArray256.get_set256E 1,2:/# ifF 1:/# hu /#.
wp; skip => &hr [#] -> hr; split; 1: by split; [smt() | split; [exact hr | smt()]].
move=> h4' i' hi [#] hi0 hi1 _ hd _ L hL.
have ->> : i' = 8 by smt().
apply (eq_from_nth W64.zero); first by rewrite size_hl size_ffwd // size_hl.
move=> k; rewrite size_hl => hk.
rewrite /= nth_ffwd ?size_hl // /hl !nth_lane //= -!A256.get256_bits64 // hd // vpadd64 //.
have := hr L k hL hk; rewrite (ix16 k 0) ix0 // /VS /vars => ->.
by rewrite addrC.
qed.

lemma block_x4 (h0 : BArray256.t) (ms0 : int -> W64.t list) :
  (forall L, 0 <= L < 4 => size (ms0 L) = 16) =>
  hoare [M._sha512_x4_block :
    h4 = h0 /\ msg w ms0 ==>
    forall L, 0 <= L < 4 => hl res.`1 L = compress (hl h0 L) (ms0 L)].
proof.
move=> hs; conseq (block_x4g h0 ms0 (fun L => schedule (ms0 L)) K512 _ _) => //.
+ by move=> &hr _ r h L hL; rewrite compress_rounds h.
qed.
