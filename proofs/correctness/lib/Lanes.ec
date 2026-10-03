(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Lanes.ec
 * ========
 *
 * Lane views of the interleaved multi-way state. The 8-way SHA-256 state
 * is u32[64] with H_j of lane k at index 8j + k; the 4-way SHA-512 state
 * is u64[32] with H_j of lane k at index 4j + k. Lane k's block is the
 * bytes B k .. B k + B - 1 of the block array (B = 64, 128), or B n bytes
 * of lane memory for the lanes forms.
 *
 * The views are written over a getter, get i being word i of the state
 * as the kernel reads it from its array or registers, so that no array
 * theory of a model is needed here and each kernel proof applies them to
 * its own representation:
 *
 *     lane8 get k   the eight words of lane k, H_0 first;
 *     lane4 get k   the same for four lanes.
 *
 * The lemmas say that a lane is decided by its own indices only: writing
 * the eight indices of one lane changes that lane and no other.
 *)

require import AllCore List IntDiv.

(* ------------------------------------------------------------------ *)
(* Index arithmetic                                                   *)

lemma lane_index (w i : int) : 0 < w => i = w * (i %/ w) + i %% w.
proof. by move=> hw; rewrite {1}(divz_eq i w); ring. qed.

lemma lane_inj (w j k j' k' : int) :
  0 <= k < w => 0 <= k' < w => w * j + k = w * j' + k' => j = j' /\ k = k'.
proof.
move=> hk hk' heq.
have hm : (w * j + k) %% w = (w * j' + k') %% w by rewrite heq.
have e1 : (w * j + k) %% w = k by rewrite mulzC modzMDl pmod_small.
have e2 : (w * j' + k') %% w = k' by rewrite mulzC modzMDl pmod_small.
have hkk : k = k' by rewrite -e1 -e2 hm.
by split => //; subst k'; smt().
qed.

lemma lane_of (w j k : int) : 0 <= k < w => (w * j + k) %% w = k.
proof. by move=> hk; rewrite mulzC modzMDl pmod_small. qed.

(* ------------------------------------------------------------------ *)
(* Lane views                                                         *)

op lane (w : int) (get : int -> 'a) (k : int) : 'a list =
  map (fun j => get (w * j + k)) (iota_ 0 8).

abbrev lane8 (get : int -> 'a) (k : int) : 'a list = lane 8 get k.
abbrev lane4 (get : int -> 'a) (k : int) : 'a list = lane 4 get k.

lemma size_lane w (get : int -> 'a) k : size (lane w get k) = 8.
proof. by rewrite /lane size_map size_iota. qed.

lemma nth_lane w (get : int -> 'a) k j (x0 : 'a) :
  0 <= j < 8 => nth x0 (lane w get k) j = get (w * j + k).
proof. by move=> hj; rewrite /lane (nth_map 0) 1:size_iota 1:/# nth_iota. qed.

(* Two getters that agree on lane k's indices give the same lane. *)
lemma lane_eq w (get get' : int -> 'a) k :
  (forall j, 0 <= j < 8 => get' (w * j + k) = get (w * j + k)) =>
  lane w get' k = lane w get k.
proof.
move=> h; apply (eq_from_nth witness); first by rewrite !size_lane.
by move=> j; rewrite size_lane => hj; rewrite !nth_lane // h.
qed.

(* A lane equals a list of eight values when each index holds its value. *)
lemma lane_list w (get : int -> 'a) k (vs : 'a list) :
  size vs = 8 =>
  (forall j, 0 <= j < 8 => get (w * j + k) = nth witness vs j) =>
  lane w get k = vs.
proof.
move=> hs h; apply (eq_from_nth witness); first by rewrite size_lane hs.
by move=> j; rewrite size_lane => hj; rewrite nth_lane // h.
qed.

(* Writes outside lane k leave lane k as it was. *)
lemma lane_frame w (get get' : int -> 'a) k :
  0 <= k < w =>
  (forall i, i %% w = k => get' i = get i) =>
  lane w get' k = lane w get k.
proof. by move=> hk h; apply lane_eq => j hj; apply h; rewrite lane_of. qed.

(* ------------------------------------------------------------------ *)
(* Lane blocks                                                        *)

(* Lane k's block of b bytes in a block array of the lanes laid end to end. *)
op lane_block (b : int) (bs : 'a list) (k : int) : 'a list = take b (drop (b * k) bs).

lemma size_lane_block b (bs : 'a list) k :
  0 <= b => 0 <= k => b * (k + 1) <= size bs => size (lane_block b bs k) = b.
proof.
move=> hb hk hs; rewrite /lane_block size_take // size_drop; 1: smt().
by rewrite /max; smt().
qed.

lemma nth_lane_block b (bs : 'a list) k i (x0 : 'a) :
  0 <= b => 0 <= k => 0 <= i < b =>
  nth x0 (lane_block b bs k) i = nth x0 bs (b * k + i).
proof.
by move=> hb hk hi; rewrite /lane_block nth_take // 1:/# nth_drop 1,2:/#.
qed.
