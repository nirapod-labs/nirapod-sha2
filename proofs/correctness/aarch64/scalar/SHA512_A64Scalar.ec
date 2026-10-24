(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_A64Scalar.ec (aarch64/scalar)
 * ====================================
 *
 * Functional correctness of the one-block entry point _sha512_compress of
 * the AArch64 scalar SHA-512 compression kernel
 * (src/aarch64/scalar/sha512_compress.jinc) against FIPS 180-4 section
 * 6.4.2 as specified in spec/FIPS180_SHA2.ec. The entry point that reads
 * blocks from memory, _sha512_compress_blocks, is proven in
 * SHA512_A64ScalarBlocks.ec. The specification-side lemmas (schedule,
 * working variables, compress) follow the portable kernel's proof
 * (correctness/portable/SHA512_Compress.ec).
 *
 * Model. NirapodSha2 is the jasmin2ec model of a unit; this file is
 * checked on every unit whose Sha512Kernel root is src/aarch64/scalar
 * (proofs/Makefile). The kernel computes the section 4.1.3 functions in
 * the A64 instruction forms of Scalar.ec: Ch as (e & f) + BIC(g, e), Maj
 * as b ^ ((a ^ b) & (b ^ c)), and the rotations and shifts of Σ and σ
 * directly. The byte reversal __bswap64 is REV, which this file uses
 * through bswap64_spec of ArchWord.
 *
 * Representation. The chaining value h is u64[8], H_0 .. H_7 as native
 * words (hwords); the message schedule window w is u64[16] (mwords). The
 * round procedure takes the 80-word constant table by pointer; its
 * parameter k is stated to be sHA512_K. The two values the A64 Maj form
 * reads, a ^ b and b ^ c, alternate between the two slots of abc, so the
 * round invariant states which of them each slot holds.
 *
 * Theorems:
 *     sha512_rounds_a64_correct  _sha512_rounds_a64 computes compress on
 *                                the message words already in w (Hoare
 *                                logic: partial correctness);
 *     sha512_compress_correct    _sha512_compress computes compress on
 *                                the big-endian words of the 128-byte
 *                                block (partial correctness);
 *     sha512_rounds_a64_total,   the same with termination: from every
 *     sha512_compress_total      initial state the procedure returns,
 *                                with the specified result.
 *
 * The kernel keeps a 16-word schedule window and rotates the working
 * variables over eight slots instead of shifting them; the loop invariants
 * below state both correspondences.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JModel_armv8a.
require import BArray64 BArray128 BArray640.
require import NirapodSha2 ArchWord.
require import Bytes FIPS180_SHA2 Scalar.
import SHA512 S512.

(* ------------------------------------------------------------------ *)
(* Views of the arrays as word lists                                  *)

op hwords (h : BArray64.t) : W64.t list = map (BArray64.get64 h) (iota_ 0 8).
op mwords (w : BArray128.t) : W64.t list = map (BArray128.get64 w) (iota_ 0 16).

lemma nth_hwords h k : 0 <= k < 8 => nth W64.zero (hwords h) k = BArray64.get64 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma nth_mwords w k : 0 <= k < 16 => nth W64.zero (mwords w) k = BArray128.get64 w k.
proof. by move=> hk; rewrite /mwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

(* ------------------------------------------------------------------ *)
(* Facts about the specification                                      *)

(* The schedule of section 6.2.2 step 1 after W_0 .. W_{j-1} are known. *)
op sched_step (w : W64.t list) (t : int) : W64.t list =
  rcons w (ssig1 (nth W64.zero w (t - 2)) + nth W64.zero w (t - 7)
         + ssig0 (nth W64.zero w (t - 15)) + nth W64.zero w (t - 16)).

op sched (m : W64.t list) (j : int) : W64.t list = foldl sched_step m (range 16 j).

lemma schedE m : schedule m = sched m 80.
proof. by rewrite /schedule /sched /sched_step. qed.

lemma schedS m j : 16 <= j => sched m (j + 1) = sched_step (sched m j) j.
proof. by move=> hj; rewrite /sched rangeSr 1:/# -cats1 foldl_cat. qed.

lemma size_sched m j : size m = 16 => 16 <= j => size (sched m j) = j.
proof.
move=> hm; elim/natind: j => [j hj hb | j hj ih hb]; first by smt().
case: (j = 15) => [->> /=|ne]; first by rewrite /sched range_geq.
by rewrite schedS 1:/# /sched_step size_rcons ih /#.
qed.

(* Elements already computed never change. *)
lemma nth_sched_stable m i j k :
  size m = 16 => 16 <= j <= k => 0 <= i < j =>
  nth W64.zero (sched m k) i = nth W64.zero (sched m j) i.
proof.
move=> hm [hj hjk] hi.
have h : forall d, 0 <= d => nth W64.zero (sched m (j + d)) i = nth W64.zero (sched m j) i.
+ elim/natind => [d hd hd' | d hd ih _]; first by have ->: d = 0 by smt().
  rewrite addzA schedS 1:/# /sched_step nth_rcons size_sched // 1:/#.
  by rewrite ifT 1:/# ih.
have := h (k - j) _; first by smt().
by have ->: j + (k - j) = k by ring.
qed.

lemma nth_schedule_lo m t :
  size m = 16 => 0 <= t < 16 => nth W64.zero (schedule m) t = nth W64.zero m t.
proof.
move=> hm ht; rewrite schedE (nth_sched_stable _ _ 16) // /sched.
by rewrite range_geq.
qed.

lemma nth_schedule_hi m t :
  size m = 16 => 16 <= t < 80 =>
  nth W64.zero (schedule m) t
  = ssig1 (nth W64.zero (schedule m) (t - 2)) + nth W64.zero (schedule m) (t - 7)
  + ssig0 (nth W64.zero (schedule m) (t - 15)) + nth W64.zero (schedule m) (t - 16).
proof.
move=> hm ht; rewrite !schedE.
have -> : nth W64.zero (sched m 80) t = nth W64.zero (sched m (t + 1)) t.
+ by rewrite (nth_sched_stable m t (t + 1) 80) // /#.
rewrite schedS 1:/# /sched_step nth_rcons size_sched // 1:/# /=.
rewrite -(nth_sched_stable m (t - 2) t 80) 1,2,3:/#.
rewrite -(nth_sched_stable m (t - 7) t 80) 1,2,3:/#.
rewrite -(nth_sched_stable m (t - 15) t 80) 1,2,3:/#.
by rewrite -(nth_sched_stable m (t - 16) t 80) 1,2,3:/#.
qed.

(* The working variables after t rounds, as the list [a; b; ...; h]. *)
op vars (hv w : W64.t list) (t : int) : W64.t list =
  of_state (foldl (round w) (to_state hv) (range 0 t)).

lemma vars0 hv w : size hv = 8 => vars hv w 0 = hv.
proof.
move=> hs; rewrite /vars range_geq //= /to_state /of_state /=.
apply (eq_from_nth W64.zero) => //= [|i hi]; first by rewrite hs.
by smt().
qed.

lemma size_vars hv w t : size (vars hv w t) = 8.
proof. by rewrite /vars /of_state; case: (foldl _ _ _). qed.

(* T1 and T2 of section 6.2.2 step 3, on the list of working variables. *)
op T1 (vs w : W64.t list) (t : int) : W64.t =
  nth W64.zero vs 7 + bsig1 (nth W64.zero vs 4)
  + ch (nth W64.zero vs 4) (nth W64.zero vs 5) (nth W64.zero vs 6)
  + nth W64.zero K512 t + nth W64.zero w t.

op T2 (vs : W64.t list) : W64.t =
  bsig0 (nth W64.zero vs 0) + maj (nth W64.zero vs 0) (nth W64.zero vs 1) (nth W64.zero vs 2).

(* One round on the list of working variables. *)
lemma varsS hv w t : 0 <= t =>
  vars hv w (t + 1) =
    let v = vars hv w t in
    [T1 v w t + T2 v; nth W64.zero v 0; nth W64.zero v 1; nth W64.zero v 2;
     nth W64.zero v 3 + T1 v w t; nth W64.zero v 4; nth W64.zero v 5; nth W64.zero v 6].
proof.
move=> ht; rewrite /vars rangeSr // -cats1 foldl_cat /=.
by case: (foldl _ _ _) => a b c d e f g h; rewrite /round /of_state /T1 /T2.
qed.

(* compress in terms of vars. *)
lemma compressE hv m :
  compress hv m
  = map (fun (xy : W64.t * W64.t) => xy.`1 + xy.`2) (zip (vars hv (schedule m) 80) hv).
proof. by rewrite /compress /vars. qed.

lemma nth_compress hv m k :
  size hv = 8 => 0 <= k < 8 =>
  nth W64.zero (compress hv m) k = nth W64.zero (vars hv (schedule m) 80) k + nth W64.zero hv k.
proof.
move=> hs hk; rewrite compressE (nth_map (W64.zero, W64.zero)).
+ by rewrite size_zip size_vars hs.
by rewrite nth_zip // size_vars hs.
qed.

lemma size_compress hv m : size hv = 8 => size (compress hv m) = 8.
proof. by move=> hs; rewrite compressE size_map size_zip size_vars hs. qed.

(* ------------------------------------------------------------------ *)
(* The two rewritten Boolean functions of the kernel                  *)

(* ------------------------------------------------------------------ *)
(* The round-constant table                                           *)

lemma K512_kernel t : 0 <= t < 80 =>
  BArray640.get64 sHA512_K t = nth W64.zero K512 t.
proof.
move=> ht; rewrite BArray640.get64_of_list64 1://.
by congr; rewrite /K512 /=.
qed.

(* ------------------------------------------------------------------ *)
(* The slot rotation                                                  *)

(* Invariant of the round loop: variable k (a = 0, ..., h = 7) of round t
   is in slot (k - t) mod 8, written ((k + 80) - t) %% 8 by the kernel. *)
op slots_ok (v : BArray64.t) (vs : W64.t list) (t : int) =
  forall k, 0 <= k < 8 => BArray64.get64 v ((k + 80 - t) %% 8) = nth W64.zero vs k.

lemma slots_step (v : BArray64.t) vs t t1 t2 :
  0 <= t < 80 => slots_ok v vs t =>
  slots_ok
    (BArray64.set64
       (BArray64.set64 v ((3 + 80 - t) %% 8) (BArray64.get64 v ((3 + 80 - t) %% 8) + t1))
       ((7 + 80 - t) %% 8) (t1 + t2))
    [t1 + t2; nth W64.zero vs 0; nth W64.zero vs 1; nth W64.zero vs 2;
     nth W64.zero vs 3 + t1; nth W64.zero vs 4; nth W64.zero vs 5; nth W64.zero vs 6] (t + 1).
proof.
move=> ht hok k hk.
rewrite !BArray64.get_set64E; 1..4: smt().
have: k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
+ by rewrite ifT 1:/#.
+ by rewrite ifF 1:/# ifF 1:/# -(hok 0) // /#.
+ by rewrite ifF 1:/# ifF 1:/# -(hok 1) // /#.
+ by rewrite ifF 1:/# ifF 1:/# -(hok 2) // /#.
+ by rewrite ifF 1:/# ifT 1:/# (hok 3) // /#.
+ by rewrite ifF 1:/# ifF 1:/# -(hok 4) // /#.
+ by rewrite ifF 1:/# ifF 1:/# -(hok 5) // /#.
by rewrite ifF 1:/# ifF 1:/# -(hok 6) // /#.
qed.

(* ------------------------------------------------------------------ *)
(* Slot state inside a round                                          *)

(* The round overwrites the slots of h (7) and d (3) in place, so between
   its steps the array is described by their current values and by the
   other six slots, which still hold their round-t values. *)
abbrev rslots (v : BArray64.t) (vs : W64.t list) (t : int) (x7 x3 : W64.t) =
     BArray64.get64 v ((7 + 80 - t) %% 8) = x7
  /\ BArray64.get64 v ((3 + 80 - t) %% 8) = x3
  /\ forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
       BArray64.get64 v ((k + 80 - t) %% 8) = nth W64.zero vs k.

(* Distinct variables occupy distinct slots. *)
lemma slot7_ne3 (t : int) : 0 <= t => t < 80 =>
  (7 + 80 - t) %% 8 <> (3 + 80 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot3_ne7 (t : int) : 0 <= t => t < 80 =>
  (3 + 80 - t) %% 8 <> (7 + 80 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot7_ne (t k : int) : 0 <= k => k < 8 => k <> 7 => 0 <= t => t < 80 =>
  (7 + 80 - t) %% 8 <> (k + 80 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot3_ne (t k : int) : 0 <= k => k < 8 => k <> 3 => 0 <= t => t < 80 =>
  (3 + 80 - t) %% 8 <> (k + 80 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

(* Reads of the slots the round writes, in the shapes the code produces. *)
lemma get_set64_same (v : BArray64.t) (i : int) (x : W64.t) :
  0 <= i < 8 => BArray64.get64 (BArray64.set64 v i x) i = x.
proof.
move=> hi.
rewrite BArray64.get_set64E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set64_other (v : BArray64.t) (i j : int) (x : W64.t) :
  0 <= i < 8 => i <> j =>
  BArray64.get64 (BArray64.set64 v i x) j = BArray64.get64 v j.
proof.
by move=> hi hne; rewrite BArray64.get_set64E_neq.
qed.

lemma get_set64_twice_same (v : BArray64.t) (i : int) (a b : W64.t) :
  0 <= i < 8 =>
  BArray64.get64 (BArray64.set64 (BArray64.set64 v i a) i b) i = b.
proof.
move=> hi.
rewrite BArray64.get_set64E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set64_twice_other (v : BArray64.t) (i j : int) (a b : W64.t) :
  0 <= i < 8 => i <> j =>
  BArray64.get64 (BArray64.set64 (BArray64.set64 v i a) i b) j
  = BArray64.get64 v j.
proof.
move=> hi hne.
rewrite BArray64.get_set64E_neq.
+ done.
by rewrite BArray64.get_set64E_neq.
qed.

lemma get_set16_same (a : BArray16.t) (i : int) (x : W64.t) :
  0 <= i < 2 => BArray16.get64 (BArray16.set64 a i x) i = x.
proof.
move=> hi.
rewrite BArray16.get_set64E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set16_other (a : BArray16.t) (i j : int) (x : W64.t) :
  0 <= i < 2 => i <> j =>
  BArray16.get64 (BArray16.set64 a i x) j = BArray16.get64 a j.
proof.
by move=> hi hne; rewrite BArray16.get_set64E_neq.
qed.

(* The two cells of abc and their parity. *)
lemma mod2_bounds (t : int) : 0 <= t %% 2 < 2.
proof. by smt(modz_ge0 ltz_pmod). qed.

lemma mod2_ne (t : int) : t %% 2 <> (t + 1) %% 2.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

(* After the round the slots hold the variables of round t + 1. *)
lemma rslots_end (v : BArray64.t) (vs : W64.t list) (t : int) (x7 x3 : W64.t) :
  0 <= t < 80 =>
  BArray64.get64 v ((7 + 80 - t) %% 8) = x7 =>
  BArray64.get64 v ((3 + 80 - t) %% 8) = x3 =>
  (forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
     BArray64.get64 v ((k + 80 - t) %% 8) = nth W64.zero vs k) =>
  slots_ok v [x7; nth W64.zero vs 0; nth W64.zero vs 1; nth W64.zero vs 2;
              x3; nth W64.zero vs 4; nth W64.zero vs 5; nth W64.zero vs 6] (t + 1).
proof.
move=> ht h7 h3 hrest k hk.
have: k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
+ have he : (0 + 80 - (t + 1)) %% 8 = (7 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he.
+ have he : (1 + 80 - (t + 1)) %% 8 = (0 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (2 + 80 - (t + 1)) %% 8 = (1 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (3 + 80 - (t + 1)) %% 8 = (2 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (4 + 80 - (t + 1)) %% 8 = (3 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he.
+ have he : (5 + 80 - (t + 1)) %% 8 = (4 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (6 + 80 - (t + 1)) %% 8 = (5 + 80 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
have he : (7 + 80 - (t + 1)) %% 8 = (6 + 80 - t) %% 8
  by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
by rewrite he; apply hrest; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The kernel                                                         *)

(* Invariant of the schedule window at the head of round t: slot j mod 16
   holds W_j for every j in [max 0 (t - 16), max 16 t). *)
op window_ok (w : BArray128.t) (ws : W64.t list) (t : int) =
  forall j, max 0 (t - 16) <= j < max 16 t => BArray128.get64 w (j %% 16) = nth W64.zero ws j.

lemma mod16_eq t j : 0 <= t - j < 16 => t %% 16 = j %% 16 => j = t.
proof. smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma win_bounds t d : 16 <= t < 80 => 1 <= d <= 16 =>
  max 0 (t - 16) <= t - d < max 16 t.
proof. by move=> ht hd; rewrite /max /#. qed.

(* An index in the window of round t + 1 is one of the last sixteen words
   of the schedule. *)
lemma win_range t j : 16 <= t =>
  max 0 (t + 1 - 16) <= j < max 16 (t + 1) => 0 <= t - j < 16.
proof. by move=> ht hj; smt(). qed.

(* A different slot from the one the step writes is still in the window of
   the previous round. *)
lemma win_range_prev t j : 16 <= t =>
  max 0 (t + 1 - 16) <= j < max 16 (t + 1) => t %% 16 <> j %% 16 =>
  max 0 (t - 16) <= j < max 16 t.
proof. by move=> ht hj hne; smt(divz_eq modz_ge0 ltz_pmod). qed.

(* Before the first schedule step the window is the whole schedule prefix. *)
lemma win_lo (w : BArray128.t) (ws : W64.t list) (t : int) :
  0 <= t < 16 => window_ok w ws t => BArray128.get64 w t = nth W64.zero ws t.
proof.
move=> ht hw.
have ht' : max 0 (t - 16) <= t < max 16 t by move: ht; rewrite /max; smt().
have e := hw t ht'.
by rewrite -e pmod_small 1:/#.
qed.

lemma win_lo_next (w : BArray128.t) (ws : W64.t list) (t : int) :
  0 <= t < 16 => window_ok w ws t => window_ok w ws (t + 1).
proof.
move=> ht hw j hj.
apply hw.
move: hj ht; rewrite /max; clear hw; smt().
qed.

(* One schedule step of the window: slot t mod 16 holds W_{t-16}, its last
   reader, and receives W_t. *)
lemma window_step (w : BArray128.t) m t :
  size m = 16 => 16 <= t < 80 => window_ok w (schedule m) t =>
  let wt = ssig1 (BArray128.get64 w ((t - 2) %% 16)) + ssig0 (BArray128.get64 w ((t - 15) %% 16))
         + BArray128.get64 w ((t - 7) %% 16) + BArray128.get64 w (t %% 16) in
  window_ok (BArray128.set64 w (t %% 16) wt) (schedule m) (t + 1) /\
  wt = nth W64.zero (schedule m) t.
proof.
move=> hm ht hw /=.
have hmod : (t - 16) %% 16 = t %% 16.
+ by rewrite (_: t - 16 = t + (-1) * 16) 1:/# modzMDr.
have e2  := hw (t - 2) (win_bounds t 2 ht _); first done.
have e15 := hw (t - 15) (win_bounds t 15 ht _); first done.
have e7  := hw (t - 7) (win_bounds t 7 ht _); first done.
have e16 := hw (t - 16) (win_bounds t 16 ht _); first done.
rewrite hmod in e16.
have hwt : ssig1 (BArray128.get64 w ((t - 2) %% 16)) + ssig0 (BArray128.get64 w ((t - 15) %% 16))
         + BArray128.get64 w ((t - 7) %% 16) + BArray128.get64 w (t %% 16)
         = nth W64.zero (schedule m) t.
+ rewrite e2 e15 e7 e16 (nth_schedule_hi m t hm ht); ring.
rewrite hwt /=; move=> j; rewrite /max /= => hj.
have hj' : 0 <= t - j < 16 by move: hj ht; clear hw e2 e15 e7 e16 hwt hmod; smt().
rewrite BArray128.get_set64E; 1,2: smt(modz_ge0 ltz_pmod).
case: (t %% 16 = j %% 16) => heq; first by rewrite (mod16_eq t j hj' heq).
apply hw; rewrite /max; move: hj ht heq; clear hw e2 e15 e7 e16 hwt hmod hj'; smt().
qed.

lemma sha512_rounds_a64_correct (h0 : W64.t list) (m : W64.t list) :
  hoare [M._sha512_rounds_a64 :
           hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA512_K ==>
           hwords res.`1 = compress h0 m].
proof.
proc.
seq 4 : (hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA512_K /\
         slots_ok v (vars h0 (schedule m) 0) 0).
+ while (0 <= i <= 8 /\ hwords h = h0 /\ mwords w = m /\
         forall k, 0 <= k < i => BArray64.get64 v k = nth W64.zero h0 k).
  + auto => /> &hr hi hi8 hk hlt; split; first smt().
    move=> k0 hk0 hk1.
    rewrite BArray64.get_set64E 1,2:/#.
    case: (i{hr} = k0) => [<-|ne]; last by rewrite hk /#.
    by rewrite nth_hwords.
  auto => /> &hr hsz; split.
  + by move=> k0 hk0 hklt; smt().
  move=> i0 v0 hlt hi0 hi8 hv k hk.
  rewrite (vars0 _ _ (size_hwords h{hr})) (_: (k + 80 - 0) %% 8 = k) 1:/#.
  by apply hv => /#.

(* abc[1] = b_0 ^ c_0, the first b ^ c the Maj form reads. *)
seq 1 : (hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA512_K /\
         slots_ok v (vars h0 (schedule m) 0) 0 /\
         BArray16.get64 abc 1
         = nth W64.zero (vars h0 (schedule m) 0) 1
           +^ nth W64.zero (vars h0 (schedule m) 0) 2).
+ wp; skip => /> &hr hsz hs.
  have h1 : BArray64.get64 v{hr} 1
         = nth W64.zero (vars (hwords h{hr}) (schedule (mwords w{hr})) 0) 1.
  + by have := hs 1 _; smt().
  have h2 : BArray64.get64 v{hr} 2
         = nth W64.zero (vars (hwords h{hr}) (schedule (mwords w{hr})) 0) 2.
  + by have := hs 2 _; smt().
  by rewrite h1 h2.

(* Rounds 0 .. 63. *)
seq 2 : (hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
         slots_ok v (vars h0 (schedule m) 80) 80).
+ while (0 <= t <= 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
         slots_ok v (vars h0 (schedule m) t) t /\ window_ok w (schedule m) t /\
         BArray16.get64 abc ((t + 1) %% 2)
         = nth W64.zero (vars h0 (schedule m) t) 1
           +^ nth W64.zero (vars h0 (schedule m) t) 2).
  + (* the seven slot indices *)
    seq 7 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             slots_ok v (vars h0 (schedule m) t) t /\ window_ok w (schedule m) t /\
             ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\
             id = (3 + 80 - t) %% 8 /\ ie = (4 + 80 - t) %% 8 /\
             iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
             ih = (7 + 80 - t) %% 8 /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + by wp; skip.
    (* the schedule window step *)
    seq 1 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             slots_ok v (vars h0 (schedule m) t) t /\
             window_ok w (schedule m) (t + 1) /\ ia = (0 + 80 - t) %% 8 /\
             ib = (1 + 80 - t) %% 8 /\ id = (3 + 80 - t) %% 8 /\
             ie = (4 + 80 - t) %% 8 /\ iff = (5 + 80 - t) %% 8 /\
             ig = (6 + 80 - t) %% 8 /\ ih = (7 + 80 - t) %% 8 /\
             x = nth W64.zero (schedule m) t /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + if.
      + wp; skip => /> &hr ht0 ht64 hsz hs hw habc ht16.
        have [hw1 hwt] := window_step w{hr} m t{hr} hsz _ hw; 1: smt().
        split.
        + move=> j hj.
          rewrite BArray128.get_set64E; 1,2: smt(modz_ge0 ltz_pmod).
          have hj' := win_range t{hr} j ht16 hj.
          case: (t{hr} %% 16 = j %% 16) => heq.
          + by rewrite (mod16_eq t{hr} j hj' heq) -hwt ssig0_ror ssig1_ror; ring.
          by apply hw; apply (win_range_prev t{hr} j ht16 hj heq).
        by rewrite -hwt ssig0_ror ssig1_ror; ring.
      + wp; skip => /> &hr ht0 ht64 hsz hs hw habc ht16.
        have hts : 0 <= t{hr} < 16 by move: ht0 ht16; clear hw hs habc hsz ht64; smt().
        split.
        + exact (win_lo_next w{hr} (schedule m) t{hr} hts hw).
        by rewrite (win_lo w{hr} (schedule m) t{hr} hts hw).

    (* T1 = (h + K_t + W_t) + (Sigma1(e) + Ch(e, f, g)) *)
    seq 3 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             rslots v (vars h0 (schedule m) t) t
               (nth W64.zero (vars h0 (schedule m) t) 7
                + nth W64.zero K512 t + nth W64.zero (schedule m) t)
               (nth W64.zero (vars h0 (schedule m) t) 3) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\
             id = (3 + 80 - t) %% 8 /\ ie = (4 + 80 - t) %% 8 /\
             iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
             ih = (7 + 80 - t) %% 8 /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz hs hw habc.
      have e7 : BArray64.get64 v{hr} ((7 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 7
        by apply hs; smt().
      have e3 : BArray64.get64 v{hr} ((3 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 3
        by apply hs; smt().
      have er : forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
          BArray64.get64 v{hr} ((k + 80 - t{hr}) %% 8)
          = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) k
        by move=> k hk h3 h7; apply hs; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 80 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set64_twice_same v{hr} ((7 + 80 - t{hr}) %% 8) _ _ hi7).
        rewrite (get_set64_same v{hr} ((7 + 80 - t{hr}) %% 8) _ hi7).
        by rewrite e7 K512_kernel //; ring.
      split.
      + rewrite (get_set64_twice_other v{hr} ((7 + 80 - t{hr}) %% 8) ((3 + 80 - t{hr}) %% 8) _ _ hi7 hne).
        by rewrite e3.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
      rewrite (get_set64_twice_other v{hr} ((7 + 80 - t{hr}) %% 8) ((k + 80 - t{hr}) %% 8) _ _ hi7 hk').
      by rewrite er.

    seq 8 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t)
               (nth W64.zero (vars h0 (schedule m) t) 3) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\
             id = (3 + 80 - t) %% 8 /\ ie = (4 + 80 - t) %% 8 /\
             iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
             ih = (7 + 80 - t) %% 8 /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have e4 : BArray64.get64 v{hr} ((4 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 4
        by apply er; smt().
      have e5 : BArray64.get64 v{hr} ((5 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 5
        by apply er; smt().
      have e6 : BArray64.get64 v{hr} ((6 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 6
        by apply er; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 80 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set64_same v{hr} ((7 + 80 - t{hr}) %% 8) _ hi7).
        rewrite e7 e4 e5 e6.
        by rewrite /T1 -bsig1_ror -ch_bic; ring.
      split.
      + rewrite (get_set64_other v{hr} ((7 + 80 - t{hr}) %% 8) ((3 + 80 - t{hr}) %% 8) _ hi7 hne).
        by rewrite e3.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
      rewrite (get_set64_other v{hr} ((7 + 80 - t{hr}) %% 8) ((k + 80 - t{hr}) %% 8) _ hi7 hk').
      by rewrite er.

    (* e' = d + T1 *)
    seq 1 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t)
               (nth W64.zero (vars h0 (schedule m) t) 3
                + T1 (vars h0 (schedule m) t) (schedule m) t) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\
             id = (3 + 80 - t) %% 8 /\ ie = (4 + 80 - t) %% 8 /\
             iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
             ih = (7 + 80 - t) %% 8 /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have hne := slot3_ne7 t{hr} ht0 ht64.
      have hi3 : 0 <= (3 + 80 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set64_other v{hr} ((3 + 80 - t{hr}) %% 8) ((7 + 80 - t{hr}) %% 8) _ hi3 hne).
        by rewrite e7.
      split.
      + rewrite (get_set64_same v{hr} ((3 + 80 - t{hr}) %% 8) _ hi3).
        by rewrite e3 e7.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot3_ne t{hr} k hk0 hk8 hk3 ht0 ht64.
      rewrite (get_set64_other v{hr} ((3 + 80 - t{hr}) %% 8) ((k + 80 - t{hr}) %% 8) _ hi3 hk').
      by rewrite er.

    (* a' = T1 + (Sigma0(a) + Maj(a, b, c)) *)
    seq 8 : (0 <= t < 80 /\ hwords h = h0 /\ size m = 16 /\ k = sHA512_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t
                + T2 (vars h0 (schedule m) t))
               (nth W64.zero (vars h0 (schedule m) t) 3
                + T1 (vars h0 (schedule m) t) (schedule m) t) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 80 - t) %% 8 /\ ib = (1 + 80 - t) %% 8 /\
             id = (3 + 80 - t) %% 8 /\ ie = (4 + 80 - t) %% 8 /\
             iff = (5 + 80 - t) %% 8 /\ ig = (6 + 80 - t) %% 8 /\
             ih = (7 + 80 - t) %% 8 /\
             BArray16.get64 abc (t %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 0
               +^ nth W64.zero (vars h0 (schedule m) t) 1 /\
             BArray16.get64 abc ((t + 1) %% 2)
             = nth W64.zero (vars h0 (schedule m) t) 1
               +^ nth W64.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have e0 : BArray64.get64 v{hr} ((0 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 0
        by apply er; smt().
      have e1 : BArray64.get64 v{hr} ((1 + 80 - t{hr}) %% 8)
              = nth W64.zero (vars (hwords h{hr}) (schedule m) t{hr}) 1
        by apply er; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 80 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      have hi2 := mod2_bounds t{hr}.
      have hne2 := mod2_ne t{hr}.
      split.
      + split.
        + rewrite (get_set64_same v{hr} ((7 + 80 - t{hr}) %% 8) _ hi7).
          rewrite (get_set16_same abc{hr} (t{hr} %% 2) _ hi2).
          rewrite (get_set16_other abc{hr} (t{hr} %% 2) ((t{hr} + 1) %% 2) _ hi2 hne2).
          rewrite e7 e0 e1 habc.
          rewrite /T2 -bsig0_ror -maj_abc.
          by ring.
        split.
        + rewrite (get_set64_other v{hr} ((7 + 80 - t{hr}) %% 8) ((3 + 80 - t{hr}) %% 8) _ hi7 hne).
          by rewrite e3.
        move=> k hk0 hk8 hk3 hk7.
        have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
        rewrite (get_set64_other v{hr} ((7 + 80 - t{hr}) %% 8) ((k + 80 - t{hr}) %% 8) _ hi7 hk').
        by rewrite er.
      split.
      + rewrite (get_set16_same abc{hr} (t{hr} %% 2) _ hi2).
        by rewrite e0 e1.
      rewrite (get_set16_other abc{hr} (t{hr} %% 2) ((t{hr} + 1) %% 2) _ hi2 hne2).
      by rewrite habc.

    (* t <- t + 1, and the round invariant at t + 1 *)
    wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw hab0 hab1.
    have hv1 : forall hv, vars hv (schedule m) (t{hr} + 1)
             = [T1 (vars hv (schedule m) t{hr}) (schedule m) t{hr}
                  + T2 (vars hv (schedule m) t{hr});
                nth W64.zero (vars hv (schedule m) t{hr}) 0;
                nth W64.zero (vars hv (schedule m) t{hr}) 1;
                nth W64.zero (vars hv (schedule m) t{hr}) 2;
                nth W64.zero (vars hv (schedule m) t{hr}) 3
                  + T1 (vars hv (schedule m) t{hr}) (schedule m) t{hr};
                nth W64.zero (vars hv (schedule m) t{hr}) 4;
                nth W64.zero (vars hv (schedule m) t{hr}) 5;
                nth W64.zero (vars hv (schedule m) t{hr}) 6].
    + by move=> hv; rewrite (varsS hv (schedule m) t{hr}) 1:/# /T2.
    split; first smt().
    split; first by rewrite hv1; apply rslots_end.
    rewrite hv1 /= -hab0.
    by congr; smt().

  (* after the loop: 80 rounds, the abc slots are no longer needed *)
  auto => /> &hr hsz hs habc; split.
  + move=> j; rewrite /max /= => hj.
    rewrite pmod_small 1:/# (nth_schedule_lo _ _ hsz) 1:/#.
    by rewrite nth_mwords.
  move=> abc0 t0 v0 w0 hlt ht0 ht80 hs0 _ _.
  by have <- : t0 = 80 by smt().

(* H(i) = H(i-1) + working variables, word by word. *)
while (0 <= i <= 8 /\ size m = 16 /\ size h0 = 8 /\
       slots_ok v (vars h0 (schedule m) 80) 80 /\
       (forall k, 0 <= k < i => BArray64.get64 h k = nth W64.zero (compress h0 m) k) /\
       (forall k, i <= k < 8 => BArray64.get64 h k = nth W64.zero h0 k)).
+ auto => /> &hr hi0 hi8 hm hs8 hs hdone hrest hlt; split; first smt().
  split => k hk1 hk2.
  + rewrite BArray64.get_set64E; 1,2: by move: hi0 hlt; clear hs hdone hrest; smt().
    case: (i{hr} = k) => [<-|ne]; last by apply hdone; move: hk1 hk2 ne; clear hs hdone hrest; smt().
    have hv := hs i{hr} _; first by move: hi0 hlt; clear hs hdone hrest; smt().
    have he : (i{hr} + 80 - 80) %% 8 = i{hr} by move: hi0 hlt; clear hs hdone hrest hv; smt().
    move: hv; rewrite he => hv.
    have hi' : 0 <= i{hr} < 8 by move: hi0 hlt; clear hs hdone hrest hv he; smt().
    rewrite (nth_compress _ _ _ hs8 hi') hv (hrest i{hr}) 1:/#.
    by ring.
  rewrite BArray64.get_set64E; 1,2: by move: hi0 hlt; clear hs hdone hrest; smt().
  rewrite ifF; first by move: hk1; clear hs hdone hrest; smt().
  by apply hrest; move: hk1 hk2; clear hs hdone hrest; smt().
auto => /> &hr hm hs; split.
+ split; first by rewrite size_hwords.
  split; first by move=> k hk1 hk2; move: hk1 hk2; clear hs; smt().
  by move=> k hk1 hk2; rewrite nth_hwords.
move=> h1 i0 hlt hi0 hi8 hsz hdone _.
apply (eq_from_nth W64.zero); first by rewrite size_hwords size_compress.
move=> k; rewrite size_hwords => hk.
by rewrite nth_hwords // hdone; move: hk hlt hi8; clear hs hdone; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on a 128-byte block                          *)

lemma nth_chunk8 (bs : W8.t list) k :
  0 <= k < size bs %/ 8 => nth [] (chunk 8 bs) k = take 8 (drop (8 * k) bs).
proof. by move=> hk; rewrite /chunk nth_mkseq. qed.

(* Message word k of the block, read big-endian (section 5.2.1). *)
lemma bswap_get32 (blk : BArray128.t) k : 0 <= k < 16 =>
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

lemma sha512_compress_correct (h0 : W64.t list) (blk : BArray128.t) :
  hoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))].
proof.
proc.
ecall (sha512_rounds_a64_correct h0 (map be64 (chunk 8 (BArray128.to_list blk)))).
wp.
while (0 <= i <= 16 /\ hwords h = h0 /\ block = blk /\
       forall k, 0 <= k < i =>
         BArray128.get64 w_s k = be64 (take 8 (drop (8 * k) (BArray128.to_list blk)))).
+ wp; ecall (bswap64_spec x); auto => /> &hr hi0 hi16 hk hlt; split; first smt().
  move=> k hk1 hk2; rewrite BArray128.get_set64E 1,2:/#.
  case: (i{hr} = k) => [<-|ne]; first by rewrite bswap_get32 /#.
  by apply hk => /#.
auto => />; split; first by move=> k hk1 hk2; move: hk1 hk2; smt().
move=> i w hlt hi0 hi16 hk.
have hsz : size (map be64 (chunk 8 (BArray128.to_list blk))) = 16.
+ by rewrite size_map size_chunk // BArray128.size_to_list.
split; last exact hsz.
apply (eq_from_nth W64.zero).
+ by rewrite /mwords size_map size_iota size_map size_chunk // BArray128.size_to_list.
move=> k; rewrite /mwords size_map size_iota => hk'.
rewrite (nth_map 0) 1:size_iota 1:/# nth_iota 1:/# (nth_map []).
+ by rewrite size_chunk // BArray128.size_to_list /#.
have hc : 0 <= k < size (BArray128.to_list blk) %/ 8 by rewrite BArray128.size_to_list /#.
by rewrite /= (nth_chunk8 _ _ hc) (hk k) /#.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop of the kernel runs over a constant range, so both
   procedures terminate on every input. *)
lemma sha512_rounds_a64_ll : islossless M._sha512_rounds_a64.
proof.
proc; inline *.
while (0 <= i <= 8) (8 - i); first by auto => /#.
wp; while (0 <= t <= 80) (80 - t); first by auto => /#.
wp; while (0 <= i <= 8) (8 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha512_bswap64_ll : islossless M.__bswap64.
proof. by proc; auto. qed.

lemma sha512_compress_ll : islossless M._sha512_compress.
proof.
proc; call sha512_rounds_a64_ll; wp.
while (0 <= i <= 16) (16 - i).
+ move=> z; wp; call sha512_bswap64_ll; auto => /#.
by auto => /#.
qed.

lemma sha512_rounds_a64_total (h0 : W64.t list) (m : W64.t list) :
  phoare [M._sha512_rounds_a64 :
           hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA512_K ==>
           hwords res.`1 = compress h0 m] = 1%r.
proof. by conseq sha512_rounds_a64_ll (sha512_rounds_a64_correct h0 m). qed.

lemma sha512_compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))] = 1%r.
proof. by conseq sha512_compress_ll (sha512_compress_correct h0 blk). qed.
