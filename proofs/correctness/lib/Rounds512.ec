(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Rounds512.ec
 * ============
 *
 * Facts about the SHA-512 compression function of FIPS 180-4 section
 * 6.4.2 (spec/FIPS180_SHA2.ec) that every SHA-512 kernel proof uses. No
 * model is involved: the statements are about the specification and about
 * the word operators the kernels compute with, so this file is checked
 * once and each kernel proof applies its lemmas to its own arrays and
 * registers.
 *
 * Contents:
 *     the message schedule, step 1: sched, the first j words of W, and
 *     the recurrence for W_t as a statement about nth;
 *     the rounds, step 3: rounds w s a b, rounds a .. b - 1 from state s,
 *     with splitting at any point, and vars, the working variables after
 *     t rounds as the list [a; b; c; d; e; f; g; h];
 *     compress, step 4, as the feed-forward of rounds 0 .. 79;
 *     the logical functions in the forms the kernels compute them;
 *     the 16-word schedule window, for kernels that keep W_{t-16} ..
 *     W_{t-1} in a circular buffer indexed by t mod 16;
 *     the big-endian message words of a 128-byte block (section 5.2.2).
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord.
require import Bytes FIPS180_SHA2.
import SHA512.

(* ------------------------------------------------------------------ *)
(* Step 1: the message schedule                                       *)

(* The schedule after W_0 .. W_{j-1} are known, one word at a time. *)
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

lemma size_schedule m : size m = 16 => size (schedule m) = 80.
proof. by move=> hm; rewrite schedE size_sched. qed.

(* A word already computed never changes. *)
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

(* W_t = M_t for t < 16. *)
lemma nth_schedule_lo m t :
  size m = 16 => 0 <= t < 16 => nth W64.zero (schedule m) t = nth W64.zero m t.
proof.
move=> hm ht; rewrite schedE (nth_sched_stable _ _ 16) // /sched.
by rewrite range_geq.
qed.

(* W_t = σ1(W_{t-2}) + W_{t-7} + σ0(W_{t-15}) + W_{t-16} for 16 <= t < 80. *)
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

(* ------------------------------------------------------------------ *)
(* Step 3: the rounds                                                 *)

(* Rounds a .. b - 1 of step 3 from state s, with schedule w. *)
op rounds (w : W64.t list) (s : state) (a b : int) : state =
  foldl (round w) s (range a b).

lemma rounds_nil w s a b : b <= a => rounds w s a b = s.
proof. by move=> hab; rewrite /rounds range_geq. qed.

lemma rounds_cat w s a b c :
  a <= b <= c => rounds w s a c = rounds w (rounds w s a b) b c.
proof. by move=> [hab hbc]; rewrite /rounds (range_cat b) // foldl_cat. qed.

lemma rounds1 w s t : rounds w s t (t + 1) = round w s t.
proof. by rewrite /rounds rangeS. qed.

lemma roundsS w s a b :
  a <= b => rounds w s a (b + 1) = round w (rounds w s a b) b.
proof. by move=> hab; rewrite (rounds_cat w s a b (b + 1)) 1:/# rounds1. qed.

(* Groups of two and four rounds, as the instruction kernels take them. *)
lemma rounds2 w s t :
  rounds w s t (t + 2) = round w (round w s t) (t + 1).
proof. by rewrite (roundsS w s t (t + 1)) 1:/# rounds1. qed.

lemma rounds4 w s t :
  rounds w s t (t + 4)
  = round w (round w (round w (round w s t) (t + 1)) (t + 2)) (t + 3).
proof.
rewrite (roundsS w s t (t + 3)) 1:/# (roundsS w s t (t + 2)) 1:/#.
by rewrite rounds2.
qed.

lemma to_stateK s : to_state (of_state s) = s.
proof. by case: s => a b c d e f g h. qed.

lemma of_stateK hv : size hv = 8 => of_state (to_state hv) = hv.
proof.
move=> hs; apply (eq_from_nth W64.zero); first by rewrite /to_state /of_state /= hs.
by rewrite /to_state /of_state /= => i hi; smt().
qed.

lemma size_of_state s : size (of_state s) = 8.
proof. by case: s. qed.

(* The working variables after t rounds, as the list [a; b; ...; h]. *)
op vars (hv w : W64.t list) (t : int) : W64.t list =
  of_state (rounds w (to_state hv) 0 t).

lemma vars0 hv w : size hv = 8 => vars hv w 0 = hv.
proof. by move=> hs; rewrite /vars rounds_nil // of_stateK. qed.

lemma size_vars hv w t : size (vars hv w t) = 8.
proof. by rewrite /vars size_of_state. qed.

(* T1 and T2 of step 3, on the list of working variables. *)
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
move=> ht; rewrite /vars roundsS //=.
by case: (rounds _ _ _ _) => a b c d e f g h; rewrite /round /of_state /T1 /T2.
qed.

(* ------------------------------------------------------------------ *)
(* Step 4: compress as the feed-forward of rounds 0 .. 79             *)

(* H(i) = s + H(i-1), word by word. *)
op ffwd (s : state) (hv : W64.t list) : W64.t list =
  map (fun (xy : W64.t * W64.t) => xy.`1 + xy.`2) (zip (of_state s) hv).

lemma compress_rounds hv m :
  compress hv m = ffwd (rounds (schedule m) (to_state hv) 0 80) hv.
proof. by rewrite /compress /ffwd /rounds. qed.

lemma compressE hv m :
  compress hv m
  = map (fun (xy : W64.t * W64.t) => xy.`1 + xy.`2) (zip (vars hv (schedule m) 80) hv).
proof. by rewrite compress_rounds /ffwd /vars. qed.

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
(* The logical functions of section 4.1.3 in the kernels' forms       *)

(* Ch with one AND fewer, and Maj with two ANDs, as the portable and
   scalar kernels compute them. *)
lemma ch_kernel (e f g : W64.t) : ((f +^ g) `&` e) +^ g = ch e f g.
proof.
rewrite /ch; apply W64.wordP => i hi.
by rewrite !(W64.xorwE, W64.andwE, W64.invwE) hi /=; smt().
qed.

lemma maj_kernel (a b c : W64.t) : ((a +^ b) `&` c) +^ (a `&` b) = maj a b c.
proof.
rewrite /maj; apply W64.wordP => i hi.
by rewrite !(W64.xorwE, W64.andwE) /=; smt().
qed.

(* Maj as (x AND y) OR ((x OR y) AND z). *)
lemma maj_or (a b c : W64.t) : (a `&` b) `|` ((a `|` b) `&` c) = maj a b c.
proof.
rewrite /maj; apply W64.wordP => i hi.
by rewrite !(W64.orwE, W64.xorwE, W64.andwE) /=; smt().
qed.

(* Rotations by a W8 count, as `|>>|` extracts. *)
lemma Sigma0_kernel (x : W64.t) :
  (x `|>>|` W8.of_int 28) +^ (x `|>>|` W8.of_int 34) +^ (x `|>>|` W8.of_int 39) = bsig0 x.
proof. by rewrite /bsig0 /(`|>>|`) !W8.of_uintK. qed.

lemma Sigma1_kernel (x : W64.t) :
  (x `|>>|` W8.of_int 14) +^ (x `|>>|` W8.of_int 18) +^ (x `|>>|` W8.of_int 41) = bsig1 x.
proof. by rewrite /bsig1 /(`|>>|`) !W8.of_uintK. qed.

lemma sigma0_kernel (x : W64.t) :
  (x `|>>|` W8.of_int 1) +^ (x `|>>|` W8.of_int 8) +^ (x `>>` W8.of_int 7) = ssig0 x.
proof. by rewrite /ssig0 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

lemma sigma1_kernel (x : W64.t) :
  (x `|>>|` W8.of_int 19) +^ (x `|>>|` W8.of_int 61) +^ (x `>>` W8.of_int 6) = ssig1 x.
proof. by rewrite /ssig1 /(`|>>|`) /(`>>`) !W8.of_uintK. qed.

(* ------------------------------------------------------------------ *)
(* The 16-word schedule window                                        *)

(* A kernel that keeps the schedule in 16 slots holds, at the head of
   round t, W_j in slot j mod 16 for every j in [max 0 (t - 16), max 16 t).
   get k is the content of slot k, read from whatever array or registers
   the kernel uses. *)
op window_ok (get : int -> W64.t) (ws : W64.t list) (t : int) =
  forall j, max 0 (t - 16) <= j < max 16 t => get (j %% 16) = nth W64.zero ws j.

lemma mod16_eq t j : 0 <= t - j < 16 => t %% 16 = j %% 16 => j = t.
proof. smt(divz_eq modz_ge0 ltz_pmod). qed.

lemma win_bounds t d : 16 <= t < 80 => 1 <= d <= 16 =>
  max 0 (t - 16) <= t - d < max 16 t.
proof. by move=> ht hd; rewrite /max /#. qed.

(* Before round 0 the window is the message block. *)
lemma window_init (get : int -> W64.t) m :
  size m = 16 => (forall k, 0 <= k < 16 => get k = nth W64.zero m k) =>
  window_ok get (schedule m) 0.
proof.
move=> hm hg j; rewrite /max /= => hj.
by rewrite pmod_small 1:/# nth_schedule_lo // 1:/# hg /#.
qed.

(* In rounds 0 .. 15 the slot of W_t already holds it, and nothing moves. *)
lemma window_lo (get : int -> W64.t) ws t :
  0 <= t < 16 => window_ok get ws t => get t = nth W64.zero ws t.
proof. by move=> ht hw; rewrite -(pmod_small t 16) 1:/# hw /#. qed.

lemma window_lo_next (get : int -> W64.t) ws t :
  0 <= t < 16 => window_ok get ws t => window_ok get ws (t + 1).
proof. by move=> ht hw j hj; apply hw; move: hj; rewrite /max /#. qed.

(* From round 16 on, slot t mod 16 holds W_{t-16}, the last word that
   reads it, and the schedule step computes W_t from four slots. *)
lemma window_wt (get : int -> W64.t) m t :
  size m = 16 => 16 <= t < 80 => window_ok get (schedule m) t =>
  ssig1 (get ((t - 2) %% 16)) + ssig0 (get ((t - 15) %% 16))
  + get ((t - 7) %% 16) + get (t %% 16)
  = nth W64.zero (schedule m) t.
proof.
move=> hm ht hw.
have hmod : (t - 16) %% 16 = t %% 16.
+ by rewrite (_: t - 16 = t + (-1) * 16) 1:/# modzMDr.
have e2  := hw (t - 2) (win_bounds t 2 ht _); first done.
have e15 := hw (t - 15) (win_bounds t 15 ht _); first done.
have e7  := hw (t - 7) (win_bounds t 7 ht _); first done.
have e16 := hw (t - 16) (win_bounds t 16 ht _); first done.
rewrite hmod in e16.
by rewrite e2 e15 e7 e16 (nth_schedule_hi m t hm ht); ring.
qed.

(* Writing W_t to slot t mod 16, and nothing else, moves the window on. *)
lemma window_set (get get' : int -> W64.t) ws t :
  16 <= t => window_ok get ws t =>
  get' (t %% 16) = nth W64.zero ws t =>
  (forall k, 0 <= k < 16 => k <> t %% 16 => get' k = get k) =>
  window_ok get' ws (t + 1).
proof.
move=> ht hw hnew hold j; rewrite /max /= => hj.
have hj' : 0 <= t - j < 16 by move: hj ht; smt().
case: (t %% 16 = j %% 16) => heq; first by rewrite -heq hnew (mod16_eq t j hj' heq).
rewrite hold; 1,2: smt(modz_ge0 ltz_pmod).
by apply hw; move: hj ht heq; rewrite /max; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Section 5.2.2: the sixteen big-endian words of a block             *)

op blockwords (bs : bytes) : W64.t list = map be64 (chunk 8 bs).

lemma parse_blockwords (p : bytes) : parse p = map blockwords (chunk 128 p).
proof. by rewrite /parse /blockwords. qed.

lemma size_blockwords (bs : bytes) : size bs = 128 => size (blockwords bs) = 16.
proof. by move=> hs; rewrite /blockwords size_map size_chunk // hs. qed.

lemma nth_blockwords (bs : bytes) k :
  size bs = 128 => 0 <= k < 16 =>
  nth W64.zero (blockwords bs) k = be64 (take 8 (drop (8 * k) bs)).
proof.
move=> hs hk; rewrite /blockwords (nth_map []) 1:size_chunk // 1:hs 1:/#.
by rewrite /chunk nth_mkseq 1:hs 1:/#.
qed.
