(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SpecRounds.ec (x86_64)
 * ======================
 *
 * Facts about the specification (spec/FIPS180_SHA2.ec) that the x86-64
 * kernel proofs share: the message schedule of section 6.2.2 (6.4.2)
 * step 1 as a recurrence on nth, and the compression function as rounds
 * folded over a range, split at any round. No instruction and no model
 * is used here.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord.
require import Bytes FIPS180_SHA2.

theory R256.
import SHA256.

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

(* Section 6.2.2 step 1, the recurrence for W_t, 16 <= t < 64. *)
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

(* Rounds t0 .. t1 - 1 then t1 .. t2 - 1. *)
lemma rounds_cat (w : W32.t list) (s : state) t0 t1 t2 : t0 <= t1 <= t2 =>
  foldl (round w) s (range t0 t2) = foldl (round w) (foldl (round w) s (range t0 t1)) (range t1 t2).
proof. by move=> h; rewrite (range_cat t1) 1,2:/# foldl_cat. qed.

lemma range4 (w : W32.t list) (t : int) (s : state) :
  foldl (round w) s (range t (t + 4))
  = round w (round w (round w (round w s t) (t + 1)) (t + 2)) (t + 3).
proof.
by rewrite range_ltn 1:/# range_ltn 1:/# range_ltn 1:/# range_ltn 1:/# range_geq 1:/# /=.
qed.

(* Step 4: the feed-forward of the state after 64 rounds. *)
lemma compressE (hv m : W32.t list) : size hv = 8 =>
  let s = foldl (round (schedule m)) (to_state hv) (range 0 64) in
  compress hv m = [s.`1 + nth W32.zero hv 0; s.`2 + nth W32.zero hv 1;
                   s.`3 + nth W32.zero hv 2; s.`4 + nth W32.zero hv 3;
                   s.`5 + nth W32.zero hv 4; s.`6 + nth W32.zero hv 5;
                   s.`7 + nth W32.zero hv 6; s.`8 + nth W32.zero hv 7].
proof.
move=> hs /=; rewrite /compress /=.
case: (foldl _ _ _) => a b c d e f g h /=.
by move: hs; case: hv => [|h0 [|h1 [|h2 [|h3 [|h4 [|h5 [|h6 [|h7 [|h8 t]]]]]]]]] //=.
qed.

end R256.
