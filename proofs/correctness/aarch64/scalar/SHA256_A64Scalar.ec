(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Scalar.ec (aarch64/scalar)
 * ====================================
 *
 * Functional correctness of the one-block entry point _sha256_compress of
 * the AArch64 scalar SHA-256 compression kernel
 * (src/aarch64/scalar/sha256_compress.jinc) against FIPS 180-4 section
 * 6.2.2 as specified in spec/FIPS180_SHA2.ec. The entry point that reads
 * blocks from memory, _sha256_compress_blocks, is proven in
 * SHA256_A64ScalarBlocks.ec. The specification-side lemmas (schedule,
 * working variables, compress) follow the portable kernel's proof
 * (correctness/portable/SHA256_Compress.ec).
 *
 * Model. NirapodSha2 is the jasmin2ec model of a unit; this file is
 * checked on every unit whose Sha256Kernel root is src/aarch64/scalar
 * (proofs/Makefile). The kernel computes the section 4.1.2 functions in
 * the A64 instruction forms of Scalar.ec: Ch as (e & f) + BIC(g, e), Maj
 * as b ^ ((a ^ b) & (b ^ c)), and the rotations and shifts of Σ and σ
 * directly. The byte reversal __bswap32 is REV, which this file uses
 * through bswap32_spec of ArchWord.
 *
 * Representation. The chaining value h is u32[8], H_0 .. H_7 as native
 * words (hwords); the message schedule window w is u32[16] (mwords). The
 * round procedure takes the 64-word constant table by pointer; its
 * parameter k is stated to be sHA256_K. The two values the A64 Maj form
 * reads, a ^ b and b ^ c, alternate between the two slots of abc, so the
 * round invariant states which of them each slot holds.
 *
 * Theorems:
 *     sha256_rounds_a64_correct  _sha256_rounds_a64 computes compress on
 *                                the message words already in w (Hoare
 *                                logic: partial correctness);
 *     sha256_compress_correct    _sha256_compress computes compress on
 *                                the big-endian words of the 64-byte
 *                                block (partial correctness);
 *     sha256_rounds_a64_total,   the same with termination: from every
 *     sha256_compress_total      initial state the procedure returns,
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
require import BArray32 BArray64 BArray256.
require import NirapodSha2 ArchWord.
require import Bytes FIPS180_SHA2 Scalar.
import SHA256 S256.

(* ------------------------------------------------------------------ *)
(* Views of the arrays as word lists                                  *)

op hwords (h : BArray32.t) : W32.t list = map (BArray32.get32 h) (iota_ 0 8).
op mwords (w : BArray64.t) : W32.t list = map (BArray64.get32 w) (iota_ 0 16).

lemma nth_hwords h k : 0 <= k < 8 => nth W32.zero (hwords h) k = BArray32.get32 h k.
proof. by move=> hk; rewrite /hwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma nth_mwords w k : 0 <= k < 16 => nth W32.zero (mwords w) k = BArray64.get32 w k.
proof. by move=> hk; rewrite /mwords (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

lemma size_hwords h : size (hwords h) = 8.
proof. by rewrite /hwords size_map size_iota. qed.

(* ------------------------------------------------------------------ *)
(* Facts about the specification                                      *)

(* The schedule of section 6.2.2 step 1 after W_0 .. W_{j-1} are known. *)
op sched_step (w : W32.t list) (t : int) : W32.t list =
  rcons w (ssig1 (nth W32.zero w (t - 2)) + nth W32.zero w (t - 7)
         + ssig0 (nth W32.zero w (t - 15)) + nth W32.zero w (t - 16)).

op sched (m : W32.t list) (j : int) : W32.t list = foldl sched_step m (range 16 j).

lemma schedE m : schedule m = sched m 64.
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
  nth W32.zero (sched m k) i = nth W32.zero (sched m j) i.
proof.
move=> hm [hj hjk] hi.
have h : forall d, 0 <= d => nth W32.zero (sched m (j + d)) i = nth W32.zero (sched m j) i.
+ elim/natind => [d hd hd' | d hd ih _]; first by have ->: d = 0 by smt().
  rewrite addzA schedS 1:/# /sched_step nth_rcons size_sched // 1:/#.
  by rewrite ifT 1:/# ih.
have := h (k - j) _; first by smt().
by have ->: j + (k - j) = k by ring.
qed.

lemma nth_schedule_lo m t :
  size m = 16 => 0 <= t < 16 => nth W32.zero (schedule m) t = nth W32.zero m t.
proof.
move=> hm ht; rewrite schedE (nth_sched_stable _ _ 16) // /sched.
by rewrite range_geq.
qed.

lemma nth_schedule_hi m t :
  size m = 16 => 16 <= t < 64 =>
  nth W32.zero (schedule m) t
  = ssig1 (nth W32.zero (schedule m) (t - 2)) + nth W32.zero (schedule m) (t - 7)
  + ssig0 (nth W32.zero (schedule m) (t - 15)) + nth W32.zero (schedule m) (t - 16).
proof.
move=> hm ht; rewrite !schedE.
have -> : nth W32.zero (sched m 64) t = nth W32.zero (sched m (t + 1)) t.
+ by rewrite (nth_sched_stable m t (t + 1) 64) // /#.
rewrite schedS 1:/# /sched_step nth_rcons size_sched // 1:/# /=.
rewrite -(nth_sched_stable m (t - 2) t 64) 1,2,3:/#.
rewrite -(nth_sched_stable m (t - 7) t 64) 1,2,3:/#.
rewrite -(nth_sched_stable m (t - 15) t 64) 1,2,3:/#.
by rewrite -(nth_sched_stable m (t - 16) t 64) 1,2,3:/#.
qed.

(* The working variables after t rounds, as the list [a; b; ...; h]. *)
op vars (hv w : W32.t list) (t : int) : W32.t list =
  of_state (foldl (round w) (to_state hv) (range 0 t)).

lemma vars0 hv w : size hv = 8 => vars hv w 0 = hv.
proof.
move=> hs; rewrite /vars range_geq //= /to_state /of_state /=.
apply (eq_from_nth W32.zero) => //= [|i hi]; first by rewrite hs.
by smt().
qed.

lemma size_vars hv w t : size (vars hv w t) = 8.
proof. by rewrite /vars /of_state; case: (foldl _ _ _). qed.

(* T1 and T2 of section 6.2.2 step 3, on the list of working variables. *)
op T1 (vs w : W32.t list) (t : int) : W32.t =
  nth W32.zero vs 7 + bsig1 (nth W32.zero vs 4)
  + ch (nth W32.zero vs 4) (nth W32.zero vs 5) (nth W32.zero vs 6)
  + nth W32.zero K256 t + nth W32.zero w t.

op T2 (vs : W32.t list) : W32.t =
  bsig0 (nth W32.zero vs 0) + maj (nth W32.zero vs 0) (nth W32.zero vs 1) (nth W32.zero vs 2).

(* One round on the list of working variables. *)
lemma varsS hv w t : 0 <= t =>
  vars hv w (t + 1) =
    let v = vars hv w t in
    [T1 v w t + T2 v; nth W32.zero v 0; nth W32.zero v 1; nth W32.zero v 2;
     nth W32.zero v 3 + T1 v w t; nth W32.zero v 4; nth W32.zero v 5; nth W32.zero v 6].
proof.
move=> ht; rewrite /vars rangeSr // -cats1 foldl_cat /=.
by case: (foldl _ _ _) => a b c d e f g h; rewrite /round /of_state /T1 /T2.
qed.

(* compress in terms of vars. *)
lemma compressE hv m :
  compress hv m
  = map (fun (xy : W32.t * W32.t) => xy.`1 + xy.`2) (zip (vars hv (schedule m) 64) hv).
proof. by rewrite /compress /vars. qed.

lemma nth_compress hv m k :
  size hv = 8 => 0 <= k < 8 =>
  nth W32.zero (compress hv m) k = nth W32.zero (vars hv (schedule m) 64) k + nth W32.zero hv k.
proof.
move=> hs hk; rewrite compressE (nth_map (W32.zero, W32.zero)).
+ by rewrite size_zip size_vars hs.
by rewrite nth_zip // size_vars hs.
qed.

lemma size_compress hv m : size hv = 8 => size (compress hv m) = 8.
proof. by move=> hs; rewrite compressE size_map size_zip size_vars hs. qed.

(* ------------------------------------------------------------------ *)
(* The two rewritten Boolean functions of the kernel                  *)

(* ------------------------------------------------------------------ *)
(* The round-constant table                                           *)

lemma K256_kernel t : 0 <= t < 64 =>
  BArray256.get32 sHA256_K t = nth W32.zero K256 t.
proof.
move=> ht; rewrite BArray256.get32_of_list32 1://.
by congr; rewrite /K256 /=.
qed.

(* ------------------------------------------------------------------ *)
(* The slot rotation                                                  *)

(* Invariant of the round loop: variable k (a = 0, ..., h = 7) of round t
   is in slot (k - t) mod 8, written ((k + 64) - t) %% 8 by the kernel. *)
op slots_ok (v : BArray32.t) (vs : W32.t list) (t : int) =
  forall k, 0 <= k < 8 => BArray32.get32 v ((k + 64 - t) %% 8) = nth W32.zero vs k.

lemma slots_step (v : BArray32.t) vs t t1 t2 :
  0 <= t < 64 => slots_ok v vs t =>
  slots_ok
    (BArray32.set32
       (BArray32.set32 v ((3 + 64 - t) %% 8) (BArray32.get32 v ((3 + 64 - t) %% 8) + t1))
       ((7 + 64 - t) %% 8) (t1 + t2))
    [t1 + t2; nth W32.zero vs 0; nth W32.zero vs 1; nth W32.zero vs 2;
     nth W32.zero vs 3 + t1; nth W32.zero vs 4; nth W32.zero vs 5; nth W32.zero vs 6] (t + 1).
proof.
move=> ht hok k hk.
rewrite !BArray32.get_set32E; 1..4: smt().
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
(* The kernel                                                         *)

(* Invariant of the schedule window at the head of round t: slot j mod 16
   holds W_j for every j in [max 0 (t - 16), max 16 t). *)
op window_ok (w : BArray64.t) (ws : W32.t list) (t : int) =
  forall j, max 0 (t - 16) <= j < max 16 t => BArray64.get32 w (j %% 16) = nth W32.zero ws j.

lemma mod16_eq t j : 0 <= t - j < 16 => t %% 16 = j %% 16 => j = t.
proof. smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma win_bounds t d : 16 <= t < 64 => 1 <= d <= 16 =>
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
lemma win_lo (w : BArray64.t) (ws : W32.t list) (t : int) :
  0 <= t < 16 => window_ok w ws t => BArray64.get32 w t = nth W32.zero ws t.
proof.
move=> ht hw.
have ht' : max 0 (t - 16) <= t < max 16 t by move: ht; rewrite /max; smt().
have e := hw t ht'.
by rewrite -e pmod_small 1:/#.
qed.

lemma win_lo_next (w : BArray64.t) (ws : W32.t list) (t : int) :
  0 <= t < 16 => window_ok w ws t => window_ok w ws (t + 1).
proof.
move=> ht hw j hj.
apply hw.
move: hj ht; rewrite /max; clear hw; smt().
qed.

(* One schedule step of the window: slot t mod 16 holds W_{t-16}, its last
   reader, and receives W_t. *)
lemma window_step (w : BArray64.t) m t :
  size m = 16 => 16 <= t < 64 => window_ok w (schedule m) t =>
  let wt = ssig1 (BArray64.get32 w ((t - 2) %% 16)) + ssig0 (BArray64.get32 w ((t - 15) %% 16))
         + BArray64.get32 w ((t - 7) %% 16) + BArray64.get32 w (t %% 16) in
  window_ok (BArray64.set32 w (t %% 16) wt) (schedule m) (t + 1) /\
  wt = nth W32.zero (schedule m) t.
proof.
move=> hm ht hw /=.
have hmod : (t - 16) %% 16 = t %% 16.
+ by rewrite (_: t - 16 = t + (-1) * 16) 1:/# modzMDr.
have e2  := hw (t - 2) (win_bounds t 2 ht _); first done.
have e15 := hw (t - 15) (win_bounds t 15 ht _); first done.
have e7  := hw (t - 7) (win_bounds t 7 ht _); first done.
have e16 := hw (t - 16) (win_bounds t 16 ht _); first done.
rewrite hmod in e16.
have hwt : ssig1 (BArray64.get32 w ((t - 2) %% 16)) + ssig0 (BArray64.get32 w ((t - 15) %% 16))
         + BArray64.get32 w ((t - 7) %% 16) + BArray64.get32 w (t %% 16)
         = nth W32.zero (schedule m) t.
+ rewrite e2 e15 e7 e16 (nth_schedule_hi m t hm ht); ring.
rewrite hwt /=; move=> j; rewrite /max /= => hj.
have hj' : 0 <= t - j < 16 by move: hj ht; clear hw e2 e15 e7 e16 hwt hmod; smt().
rewrite BArray64.get_set32E; 1,2: smt(modz_ge0 ltz_pmod).
case: (t %% 16 = j %% 16) => heq; first by rewrite (mod16_eq t j hj' heq).
apply hw; rewrite /max; move: hj ht heq; clear hw e2 e15 e7 e16 hwt hmod hj'; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Slot state inside a round                                          *)

(* The round overwrites the slots of h (7) and d (3) in place, so between
   its steps the array is described by their current values and by the
   other six slots, which still hold their round-t values. *)
abbrev rslots (v : BArray32.t) (vs : W32.t list) (t : int) (x7 x3 : W32.t) =
     BArray32.get32 v ((7 + 64 - t) %% 8) = x7
  /\ BArray32.get32 v ((3 + 64 - t) %% 8) = x3
  /\ forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
       BArray32.get32 v ((k + 64 - t) %% 8) = nth W32.zero vs k.

(* Distinct variables occupy distinct slots. *)
lemma slot7_ne3 (t : int) : 0 <= t => t < 64 =>
  (7 + 64 - t) %% 8 <> (3 + 64 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot3_ne7 (t : int) : 0 <= t => t < 64 =>
  (3 + 64 - t) %% 8 <> (7 + 64 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot7_ne (t k : int) : 0 <= k => k < 8 => k <> 7 => 0 <= t => t < 64 =>
  (7 + 64 - t) %% 8 <> (k + 64 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma slot3_ne (t k : int) : 0 <= k => k < 8 => k <> 3 => 0 <= t => t < 64 =>
  (3 + 64 - t) %% 8 <> (k + 64 - t) %% 8.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

(* Bounds of a slot for the array accessors. *)
lemma slot_bounds (i : int) : 0 <= i < 8 => 0 <= i /\ 4 * (i + 1) <= 32.
proof. by smt(). qed.

(* Reads of the slots the round writes, in the shapes the code produces. *)
lemma get_set32_same (v : BArray32.t) (i : int) (x : W32.t) :
  0 <= i < 8 => BArray32.get32 (BArray32.set32 v i x) i = x.
proof.
move=> hi.
rewrite BArray32.get_set32E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set32_other (v : BArray32.t) (i j : int) (x : W32.t) :
  0 <= i < 8 => i <> j =>
  BArray32.get32 (BArray32.set32 v i x) j = BArray32.get32 v j.
proof.
by move=> hi hne; rewrite BArray32.get_set32E_neq.
qed.

lemma get_set32_twice_same (v : BArray32.t) (i : int) (a b : W32.t) :
  0 <= i < 8 =>
  BArray32.get32 (BArray32.set32 (BArray32.set32 v i a) i b) i = b.
proof.
move=> hi.
rewrite BArray32.get_set32E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set32_twice_other (v : BArray32.t) (i j : int) (a b : W32.t) :
  0 <= i < 8 => i <> j =>
  BArray32.get32 (BArray32.set32 (BArray32.set32 v i a) i b) j
  = BArray32.get32 v j.
proof.
move=> hi hne.
rewrite BArray32.get_set32E_neq.
+ done.
by rewrite BArray32.get_set32E_neq.
qed.

lemma get_set8_same (a : BArray8.t) (i : int) (x : W32.t) :
  0 <= i < 2 => BArray8.get32 (BArray8.set32 a i x) i = x.
proof.
move=> hi.
rewrite BArray8.get_set32E_eq.
+ smt().
+ smt().
+ done.
+ done.
qed.

lemma get_set8_other (a : BArray8.t) (i j : int) (x : W32.t) :
  0 <= i < 2 => i <> j =>
  BArray8.get32 (BArray8.set32 a i x) j = BArray8.get32 a j.
proof.
by move=> hi hne; rewrite BArray8.get_set32E_neq.
qed.

(* The two cells of abc and their parity. *)
lemma mod2_bounds (t : int) : 0 <= t %% 2 < 2.
proof. by smt(modz_ge0 ltz_pmod). qed.

lemma mod2_ne (t : int) : t %% 2 <> (t + 1) %% 2.
proof. by smt(divz_eq modz_ge0 ltz_pmod). qed.

(* After the round the slots hold the variables of round t + 1. *)
lemma rslots_end (v : BArray32.t) (vs : W32.t list) (t : int) (x7 x3 : W32.t) :
  0 <= t < 64 =>
  BArray32.get32 v ((7 + 64 - t) %% 8) = x7 =>
  BArray32.get32 v ((3 + 64 - t) %% 8) = x3 =>
  (forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
     BArray32.get32 v ((k + 64 - t) %% 8) = nth W32.zero vs k) =>
  slots_ok v [x7; nth W32.zero vs 0; nth W32.zero vs 1; nth W32.zero vs 2;
              x3; nth W32.zero vs 4; nth W32.zero vs 5; nth W32.zero vs 6] (t + 1).
proof.
move=> ht h7 h3 hrest k hk.
have: k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
case=> [->|[->|[->|[->|[->|[->|[->|->]]]]]]] /=.
+ have he : (0 + 64 - (t + 1)) %% 8 = (7 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he.
+ have he : (1 + 64 - (t + 1)) %% 8 = (0 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (2 + 64 - (t + 1)) %% 8 = (1 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (3 + 64 - (t + 1)) %% 8 = (2 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (4 + 64 - (t + 1)) %% 8 = (3 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he.
+ have he : (5 + 64 - (t + 1)) %% 8 = (4 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
+ have he : (6 + 64 - (t + 1)) %% 8 = (5 + 64 - t) %% 8
    by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
  by rewrite he; apply hrest; smt().
have he : (7 + 64 - (t + 1)) %% 8 = (6 + 64 - t) %% 8
  by move: ht; clear h7 h3 hrest; smt(divz_eq modz_ge0 ltz_pmod).
by rewrite he; apply hrest; smt().
qed.

lemma sha256_rounds_a64_correct (h0 : W32.t list) (m : W32.t list) :
  hoare [M._sha256_rounds_a64 :
           hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA256_K ==>
           hwords res.`1 = compress h0 m].
proof.
proc.
seq 4 : (hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA256_K /\
         slots_ok v (vars h0 (schedule m) 0) 0).
+ while (0 <= i <= 8 /\ hwords h = h0 /\ mwords w = m /\
         forall k, 0 <= k < i => BArray32.get32 v k = nth W32.zero h0 k).
  + auto => /> &hr hi hi8 hk hlt; split; first smt().
    move=> k0 hk0 hk1.
    rewrite BArray32.get_set32E 1,2:/#.
    case: (i{hr} = k0) => [<-|ne]; last by rewrite hk /#.
    by rewrite nth_hwords.
  auto => /> &hr hsz; split.
  + by move=> k0 hk0 hklt; smt().
  move=> i0 v0 hlt hi0 hi8 hv k hk.
  rewrite (vars0 _ _ (size_hwords h{hr})) (_: (k + 64 - 0) %% 8 = k) 1:/#.
  by apply hv => /#.

(* abc[1] = b_0 ^ c_0, the first b ^ c the Maj form reads. *)
seq 1 : (hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA256_K /\
         slots_ok v (vars h0 (schedule m) 0) 0 /\
         BArray8.get32 abc 1
         = nth W32.zero (vars h0 (schedule m) 0) 1
           +^ nth W32.zero (vars h0 (schedule m) 0) 2).
+ wp; skip => /> &hr hsz hs.
  have h1 : BArray32.get32d v{hr} 4
          = nth W32.zero (vars (hwords h{hr}) (schedule (mwords w{hr})) 0) 1.
  + by have := hs 1 _; smt().
  have h2 : BArray32.get32d v{hr} 8
          = nth W32.zero (vars (hwords h{hr}) (schedule (mwords w{hr})) 0) 2.
  + by have := hs 2 _; smt().
  by rewrite h1 h2.

(* Rounds 0 .. 63. *)
seq 2 : (hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
         slots_ok v (vars h0 (schedule m) 64) 64).
+ while (0 <= t <= 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
         slots_ok v (vars h0 (schedule m) t) t /\ window_ok w (schedule m) t /\
         BArray8.get32 abc ((t + 1) %% 2)
         = nth W32.zero (vars h0 (schedule m) t) 1
           +^ nth W32.zero (vars h0 (schedule m) t) 2).
  + (* the seven slot indices *)
    seq 7 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             slots_ok v (vars h0 (schedule m) t) t /\ window_ok w (schedule m) t /\
             ia = (0 + 64 - t) %% 8 /\ ib = (1 + 64 - t) %% 8 /\
             id = (3 + 64 - t) %% 8 /\ ie = (4 + 64 - t) %% 8 /\
             iff = (5 + 64 - t) %% 8 /\ ig = (6 + 64 - t) %% 8 /\
             ih = (7 + 64 - t) %% 8 /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + by wp; skip.
    (* the schedule window step *)
    seq 1 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             slots_ok v (vars h0 (schedule m) t) t /\
             window_ok w (schedule m) (t + 1) /\ ia = (0 + 64 - t) %% 8 /\
             ib = (1 + 64 - t) %% 8 /\ id = (3 + 64 - t) %% 8 /\
             ie = (4 + 64 - t) %% 8 /\ iff = (5 + 64 - t) %% 8 /\
             ig = (6 + 64 - t) %% 8 /\ ih = (7 + 64 - t) %% 8 /\
             x = nth W32.zero (schedule m) t /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + if.
      + wp; skip => /> &hr ht0 ht64 hsz hs hw habc ht16.
        have [hw1 hwt] := window_step w{hr} m t{hr} hsz _ hw; 1: smt().
        split.
        + move=> j hj.
          rewrite BArray64.get_set32E; 1,2: smt(modz_ge0 ltz_pmod).
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
    seq 3 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             rslots v (vars h0 (schedule m) t) t
               (nth W32.zero (vars h0 (schedule m) t) 7
                + nth W32.zero K256 t + nth W32.zero (schedule m) t)
               (nth W32.zero (vars h0 (schedule m) t) 3) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 64 - t) %% 8 /\ ib = (1 + 64 - t) %% 8 /\
             id = (3 + 64 - t) %% 8 /\ ie = (4 + 64 - t) %% 8 /\
             iff = (5 + 64 - t) %% 8 /\ ig = (6 + 64 - t) %% 8 /\
             ih = (7 + 64 - t) %% 8 /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz hs hw habc.
      have e7 : BArray32.get32 v{hr} ((7 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 7
        by apply hs; smt().
      have e3 : BArray32.get32 v{hr} ((3 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 3
        by apply hs; smt().
      have er : forall k, 0 <= k < 8 => k <> 3 => k <> 7 =>
          BArray32.get32 v{hr} ((k + 64 - t{hr}) %% 8)
          = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) k
        by move=> k hk h3 h7; apply hs; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 64 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set32_twice_same v{hr} ((7 + 64 - t{hr}) %% 8) _ _ hi7).
        rewrite (get_set32_same v{hr} ((7 + 64 - t{hr}) %% 8) _ hi7).
        by rewrite e7 K256_kernel //; ring.
      split.
      + rewrite (get_set32_twice_other v{hr} ((7 + 64 - t{hr}) %% 8) ((3 + 64 - t{hr}) %% 8) _ _ hi7 hne).
        by rewrite e3.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
      rewrite (get_set32_twice_other v{hr} ((7 + 64 - t{hr}) %% 8) ((k + 64 - t{hr}) %% 8) _ _ hi7 hk').
      by rewrite er.

    seq 8 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t)
               (nth W32.zero (vars h0 (schedule m) t) 3) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 64 - t) %% 8 /\ ib = (1 + 64 - t) %% 8 /\
             id = (3 + 64 - t) %% 8 /\ ie = (4 + 64 - t) %% 8 /\
             iff = (5 + 64 - t) %% 8 /\ ig = (6 + 64 - t) %% 8 /\
             ih = (7 + 64 - t) %% 8 /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have e4 : BArray32.get32 v{hr} ((4 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 4
        by apply er; smt().
      have e5 : BArray32.get32 v{hr} ((5 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 5
        by apply er; smt().
      have e6 : BArray32.get32 v{hr} ((6 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 6
        by apply er; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 64 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set32_same v{hr} ((7 + 64 - t{hr}) %% 8) _ hi7).
        rewrite e7 e4 e5 e6.
        by rewrite /T1 -bsig1_ror -ch_bic; ring.
      split.
      + rewrite (get_set32_other v{hr} ((7 + 64 - t{hr}) %% 8) ((3 + 64 - t{hr}) %% 8) _ hi7 hne).
        by rewrite e3.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
      rewrite (get_set32_other v{hr} ((7 + 64 - t{hr}) %% 8) ((k + 64 - t{hr}) %% 8) _ hi7 hk').
      by rewrite er.

    (* e' = d + T1 *)
    seq 1 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t)
               (nth W32.zero (vars h0 (schedule m) t) 3
                + T1 (vars h0 (schedule m) t) (schedule m) t) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 64 - t) %% 8 /\ ib = (1 + 64 - t) %% 8 /\
             id = (3 + 64 - t) %% 8 /\ ie = (4 + 64 - t) %% 8 /\
             iff = (5 + 64 - t) %% 8 /\ ig = (6 + 64 - t) %% 8 /\
             ih = (7 + 64 - t) %% 8 /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have hne := slot3_ne7 t{hr} ht0 ht64.
      have hi3 : 0 <= (3 + 64 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      split.
      + rewrite (get_set32_other v{hr} ((3 + 64 - t{hr}) %% 8) ((7 + 64 - t{hr}) %% 8) _ hi3 hne).
        by rewrite e7.
      split.
      + rewrite (get_set32_same v{hr} ((3 + 64 - t{hr}) %% 8) _ hi3).
        by rewrite e3 e7.
      move=> k hk0 hk8 hk3 hk7.
      have hk' := slot3_ne t{hr} k hk0 hk8 hk3 ht0 ht64.
      rewrite (get_set32_other v{hr} ((3 + 64 - t{hr}) %% 8) ((k + 64 - t{hr}) %% 8) _ hi3 hk').
      by rewrite er.

    (* a' = T1 + (Sigma0(a) + Maj(a, b, c)) *)
    seq 8 : (0 <= t < 64 /\ hwords h = h0 /\ size m = 16 /\ k = sHA256_K /\
             rslots v (vars h0 (schedule m) t) t
               (T1 (vars h0 (schedule m) t) (schedule m) t
                + T2 (vars h0 (schedule m) t))
               (nth W32.zero (vars h0 (schedule m) t) 3
                + T1 (vars h0 (schedule m) t) (schedule m) t) /\
             window_ok w (schedule m) (t + 1) /\
             ia = (0 + 64 - t) %% 8 /\ ib = (1 + 64 - t) %% 8 /\
             id = (3 + 64 - t) %% 8 /\ ie = (4 + 64 - t) %% 8 /\
             iff = (5 + 64 - t) %% 8 /\ ig = (6 + 64 - t) %% 8 /\
             ih = (7 + 64 - t) %% 8 /\
             BArray8.get32 abc (t %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 0
               +^ nth W32.zero (vars h0 (schedule m) t) 1 /\
             BArray8.get32 abc ((t + 1) %% 2)
             = nth W32.zero (vars h0 (schedule m) t) 1
               +^ nth W32.zero (vars h0 (schedule m) t) 2).
    + wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw habc.
      have e0 : BArray32.get32 v{hr} ((0 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 0
        by apply er; smt().
      have e1 : BArray32.get32 v{hr} ((1 + 64 - t{hr}) %% 8)
              = nth W32.zero (vars (hwords h{hr}) (schedule m) t{hr}) 1
        by apply er; smt().
      have hne := slot7_ne3 t{hr} ht0 ht64.
      have hi7 : 0 <= (7 + 64 - t{hr}) %% 8 < 8 by smt(modz_ge0 ltz_pmod).
      have hi2 := mod2_bounds t{hr}.
      have hne2 := mod2_ne t{hr}.
      split.
      + split.
        + rewrite (get_set32_same v{hr} ((7 + 64 - t{hr}) %% 8) _ hi7).
          rewrite (get_set8_same abc{hr} (t{hr} %% 2) _ hi2).
          rewrite (get_set8_other abc{hr} (t{hr} %% 2) ((t{hr} + 1) %% 2) _ hi2 hne2).
          rewrite e7 e0 e1 habc.
          rewrite /T2 -bsig0_ror -maj_abc.
          by ring.
        split.
        + rewrite (get_set32_other v{hr} ((7 + 64 - t{hr}) %% 8) ((3 + 64 - t{hr}) %% 8) _ hi7 hne).
          by rewrite e3.
        move=> k hk0 hk8 hk3 hk7.
        have hk' := slot7_ne t{hr} k hk0 hk8 hk7 ht0 ht64.
        rewrite (get_set32_other v{hr} ((7 + 64 - t{hr}) %% 8) ((k + 64 - t{hr}) %% 8) _ hi7 hk').
        by rewrite er.
      split.
      + rewrite (get_set8_same abc{hr} (t{hr} %% 2) _ hi2).
        by rewrite e0 e1.
      rewrite (get_set8_other abc{hr} (t{hr} %% 2) ((t{hr} + 1) %% 2) _ hi2 hne2).
      by rewrite habc.

    (* t <- t + 1, and the round invariant at t + 1 *)
    wp; skip => /> &hr ht0 ht64 hsz e7 e3 er hw hab0 hab1.
    have hv1 : forall hv, vars hv (schedule m) (t{hr} + 1)
             = [T1 (vars hv (schedule m) t{hr}) (schedule m) t{hr}
                  + T2 (vars hv (schedule m) t{hr});
                nth W32.zero (vars hv (schedule m) t{hr}) 0;
                nth W32.zero (vars hv (schedule m) t{hr}) 1;
                nth W32.zero (vars hv (schedule m) t{hr}) 2;
                nth W32.zero (vars hv (schedule m) t{hr}) 3
                  + T1 (vars hv (schedule m) t{hr}) (schedule m) t{hr};
                nth W32.zero (vars hv (schedule m) t{hr}) 4;
                nth W32.zero (vars hv (schedule m) t{hr}) 5;
                nth W32.zero (vars hv (schedule m) t{hr}) 6].
    + by move=> hv; rewrite (varsS hv (schedule m) t{hr}) 1:/# /T2.
    split; first smt().
    split; first by rewrite hv1; apply rslots_end.
    rewrite hv1 /= -hab0.
    by congr; smt().

  (* after the loop: 64 rounds, the abc slots are no longer needed *)
  auto => /> &hr hsz hs habc; split.
  + move=> j; rewrite /max /= => hj.
    rewrite pmod_small 1:/# (nth_schedule_lo _ _ hsz) 1:/#.
    by rewrite nth_mwords.
  move=> abc0 t0 v0 w0 hlt ht0 ht64 hs0 _ _.
  by have <- : t0 = 64 by smt().

(* H(i) = H(i-1) + working variables, word by word. *)
while (0 <= i <= 8 /\ size m = 16 /\ size h0 = 8 /\
       slots_ok v (vars h0 (schedule m) 64) 64 /\
       (forall k, 0 <= k < i => BArray32.get32 h k = nth W32.zero (compress h0 m) k) /\
       (forall k, i <= k < 8 => BArray32.get32 h k = nth W32.zero h0 k)).
+ auto => /> &hr hi0 hi8 hm hs8 hs hdone hrest hlt; split; first smt().
  split => k hk1 hk2.
  + rewrite BArray32.get_set32E; 1,2: by move: hi0 hlt; clear hs hdone hrest; smt().
    case: (i{hr} = k) => [<-|ne]; last by apply hdone; move: hk1 hk2 ne; clear hs hdone hrest; smt().
    have hv := hs i{hr} _; first by move: hi0 hlt; clear hs hdone hrest; smt().
    have he : (i{hr} + 64 - 64) %% 8 = i{hr} by move: hi0 hlt; clear hs hdone hrest hv; smt().
    move: hv; rewrite he => hv.
    have hi' : 0 <= i{hr} < 8 by move: hi0 hlt; clear hs hdone hrest hv he; smt().
    rewrite (nth_compress _ _ _ hs8 hi') hv (hrest i{hr}) 1:/#.
    by ring.
  rewrite BArray32.get_set32E; 1,2: by move: hi0 hlt; clear hs hdone hrest; smt().
  rewrite ifF; first by move: hk1; clear hs hdone hrest; smt().
  by apply hrest; move: hk1 hk2; clear hs hdone hrest; smt().
auto => /> &hr hm hs; split.
+ split; first by rewrite size_hwords.
  split; first by move=> k hk1 hk2; move: hk1 hk2; clear hs; smt().
  by move=> k hk1 hk2; rewrite nth_hwords.
move=> h1 i0 hlt hi0 hi8 hsz hdone _.
apply (eq_from_nth W32.zero); first by rewrite size_hwords size_compress.
move=> k; rewrite size_hwords => hk.
by rewrite nth_hwords // hdone; move: hk hlt hi8; clear hs hdone; smt().
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on a 64-byte block                          *)

lemma nth_chunk4 (bs : W8.t list) k :
  0 <= k < size bs %/ 4 => nth [] (chunk 4 bs) k = take 4 (drop (4 * k) bs).
proof. by move=> hk; rewrite /chunk nth_mkseq. qed.

(* Message word k of the block, read big-endian (section 5.2.1). *)
lemma bswap_get32 (blk : BArray64.t) k : 0 <= k < 16 =>
  WordSpec.bswap32 (BArray64.get32 blk k) = be32 (take 4 (drop (4 * k) (BArray64.to_list blk))).
proof.
move=> hk; rewrite /WordSpec.bswap32 /be32 BArray64.get32dE; do 3!congr.
apply (eq_from_nth W8.zero).
+ by rewrite W4u8.size_to_list size_take // size_drop 1:/# BArray64.size_to_list /#.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list W4u8.get_pack4 1:BArray64.size_sub //.
rewrite nth_take // 1:/# nth_drop 1,2:/# BArray64.get_to_list.
by rewrite BArray64.nth_sub.
qed.

lemma sha256_compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))].
proof.
proc.
ecall (sha256_rounds_a64_correct h0 (map be32 (chunk 4 (BArray64.to_list blk)))).
wp.
while (0 <= i <= 16 /\ hwords h = h0 /\ block = blk /\
       forall k, 0 <= k < i =>
         BArray64.get32 w_s k = be32 (take 4 (drop (4 * k) (BArray64.to_list blk)))).
+ wp; ecall (bswap32_spec x); auto => /> &hr hi0 hi16 hk hlt; split; first smt().
  move=> k hk1 hk2; rewrite BArray64.get_set32E 1,2:/#.
  case: (i{hr} = k) => [<-|ne]; first by rewrite bswap_get32 /#.
  by apply hk => /#.
auto => />; split; first by move=> k hk1 hk2; move: hk1 hk2; smt().
move=> i w hlt hi0 hi16 hk.
have hsz : size (map be32 (chunk 4 (BArray64.to_list blk))) = 16.
+ by rewrite size_map size_chunk // BArray64.size_to_list.
split; last exact hsz.
apply (eq_from_nth W32.zero).
+ by rewrite /mwords size_map size_iota size_map size_chunk // BArray64.size_to_list.
move=> k; rewrite /mwords size_map size_iota => hk'.
rewrite (nth_map 0) 1:size_iota 1:/# nth_iota 1:/# (nth_map []).
+ by rewrite size_chunk // BArray64.size_to_list /#.
have hc : 0 <= k < size (BArray64.to_list blk) %/ 4 by rewrite BArray64.size_to_list /#.
by rewrite /= (nth_chunk4 _ _ hc) (hk k) /#.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* Every loop of the kernel runs over a constant range, so both
   procedures terminate on every input. *)
lemma sha256_rounds_a64_ll : islossless M._sha256_rounds_a64.
proof.
proc; inline *.
while (0 <= i <= 8) (8 - i); first by auto => /#.
wp; while (0 <= t <= 64) (64 - t); first by auto => /#.
wp; while (0 <= i <= 8) (8 - i); first by auto => /#.
by auto => /#.
qed.

lemma sha256_bswap32_ll : islossless M.__bswap32.
proof. by proc; auto. qed.

lemma sha256_compress_ll : islossless M._sha256_compress.
proof.
proc; call sha256_rounds_a64_ll; wp.
while (0 <= i <= 16) (16 - i).
+ move=> z; wp; call sha256_bswap32_ll; auto => /#.
by auto => /#.
qed.

lemma sha256_rounds_a64_total (h0 : W32.t list) (m : W32.t list) :
  phoare [M._sha256_rounds_a64 :
           hwords h = h0 /\ mwords w = m /\ size m = 16 /\ k = sHA256_K ==>
           hwords res.`1 = compress h0 m] = 1%r.
proof. by conseq sha256_rounds_a64_ll (sha256_rounds_a64_correct h0 m). qed.

lemma sha256_compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           hwords h = h0 /\ block = blk ==>
           hwords res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. by conseq sha256_compress_ll (sha256_compress_correct h0 blk). qed.
