(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_ShaNiX8Pair.ec
 * =====================
 *
 * The pair layer of the 8-way SHA-256 kernel on the x86 SHA extensions
 * (src/x86_64/shani/sha256_x8_compress.jinc):
 *
 *   load_pair_spec   __shani_x8_load_pair, the chaining values of lanes
 *                    4f + 2r and 4f + 2r + 1 as [abef; cdgh; abef; cdgh]
 *   store_pair_spec  __shani_x8_store_pair, its inverse, writing those two
 *                    lanes back and leaving the other six as they were
 *
 * Model. NirapodSha2 is the model of a unit whose Sha256KernelX root is
 * src/x86_64/shani (proofs/Makefile).
 *
 * Layout. h8 holds H_j of lane k at 32-bit index 8j + k (Lanes.lane8), so
 * its 128-bit word 2j + f holds word j of lanes 4f .. 4f + 3, lane 4f in
 * the lowest dword.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JModel_x86.
require import BArray64 BArray256.
require import NirapodSha2.
require import FIPS180_SHA2 Vec Arrays ShaNi Lanes.
import SHA256.

clone Arrays.ArrayLanes as L256 with theory A <- BArray256.

(* The working variables of lane k of an 8-way state. *)
lemma to_state_lane8 (g : int -> W32.t) k :
  to_state (lane8 g k)
  = (g k, g (8 + k), g (16 + k), g (24 + k), g (32 + k), g (40 + k), g (48 + k), g (56 + k)).
proof. by rewrite /to_state !nth_lane. qed.

(* ------------------------------------------------------------------ *)
(* The load                                                            *)

lemma load_pair_spec (h0 : BArray256.t) (f0 r0 : int) :
  hoare [M.__shani_x8_load_pair :
    h8 = h0 /\ f = f0 /\ r = r0 /\ 0 <= f0 < 2 /\ 0 <= r0 < 2 ==>
    BArray64.get128 res 0 = abef (to_state (lane8 (BArray256.get32 h0) (4 * f0 + 2 * r0))) /\
    BArray64.get128 res 1 = cdgh (to_state (lane8 (BArray256.get32 h0) (4 * f0 + 2 * r0))) /\
    BArray64.get128 res 2 = abef (to_state (lane8 (BArray256.get32 h0) (4 * f0 + 2 * r0 + 1))) /\
    BArray64.get128 res 3 = cdgh (to_state (lane8 (BArray256.get32 h0) (4 * f0 + 2 * r0 + 1)))].
proof.
proc; unroll for ^while.
wp; skip => /> hf0 hf1 hr0 hr1.
rewrite !L256.get128d_p4 !vpunpckl4_p4 !vpunpckh4_p4 !vpunpckl2_p4 !vpunpckh2_p4.
rewrite !to_state_lane8 /abef /cdgh /=.
split => [->> /=|hr]; last have ->> /= : r0 = 1 by smt().
+ by do !split; congr; congr; ring.
by do !split; congr; congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* The store                                                           *)

(* The working variables as a list, a ... h. *)
op ofs (s : state) : W32.t list = [s.`1; s.`2; s.`3; s.`4; s.`5; s.`6; s.`7; s.`8].

lemma lane8E (g : int -> 'a) k :
  lane8 g k = [g k; g (8 + k); g (16 + k); g (24 + k); g (32 + k); g (40 + k); g (48 + k); g (56 + k)].
proof. by rewrite /lane -iotaredE. qed.

(* A blend of the two lanes' words into dwords 2r, 2r + 1 of row n. *)
lemma blend_set32 (t : BArray256.t) n r (a b : W32.t) i :
  0 <= n < 16 => 0 <= r < 2 =>
  get32d (set128d t (16 * n)
            (VPBLEND_8u16 (get128d t (16 * n)) (p4 a b a b) (W8.of_int (if r = 0 then 15 else 240))))
         (4 * i)
  = if i = 4 * n + 2 * r then a else if i = 4 * n + 2 * r + 1 then b else get32d t (4 * i).
proof.
move=> hn hr; rewrite L256.get32d_set128d 1,2:/#.
+ have -> : 4 * i - 16 * n = (i - 4 * n) * 4 by ring.
  by rewrite modzMl.
case: (16 * n <= 4 * i < 16 * n + 16) => hi; last by rewrite ifF 1:/# ifF 1:/#.
have [j [hj ->>]] : exists j, 0 <= j < 4 /\ i = 4 * n + j by exists (i - 4 * n); smt().
have -> : (4 * (4 * n + j) - 16 * n) %/ 4 = j by smt().
have hy : forall m, 0 <= m < 4 => get128d t (16 * n) \bits32 m = get32d t (4 * (4 * n + m)).
+ by move=> m hm; rewrite L256.get128d_bits32 //; congr; ring.
have : r = 0 \/ r = 1 by smt().
case => ->> /=; [rewrite vpblendw_0f | rewrite vpblendw_f0]; rewrite p4_lane //.
+ have : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 by smt().
  by case => [->>|[->>|[->>|->>]]] /=; rewrite ?hy //; smt().
have : j = 0 \/ j = 1 \/ j = 2 \/ j = 3 by smt().
by case => [->>|[->>|[->>|->>]]] /=; rewrite ?hy //; smt().
qed.

lemma store_pair_spec (h0 : BArray256.t) (f0 r0 : int) (sa sb : state) :
  hoare [M.__shani_x8_store_pair :
    h8 = h0 /\ f = f0 /\ r = r0 /\ 0 <= f0 < 2 /\ 0 <= r0 < 2 /\
    BArray64.get128 st 0 = abef sa /\ BArray64.get128 st 1 = cdgh sa /\
    BArray64.get128 st 2 = abef sb /\ BArray64.get128 st 3 = cdgh sb ==>
    lane8 (BArray256.get32 res) (4 * f0 + 2 * r0) = ofs sa /\
    lane8 (BArray256.get32 res) (4 * f0 + 2 * r0 + 1) = ofs sb /\
    forall k, 0 <= k < 8 => k <> 4 * f0 + 2 * r0 => k <> 4 * f0 + 2 * r0 + 1 =>
      lane8 (BArray256.get32 res) k = lane8 (BArray256.get32 h0) k].
proof.
proc; unroll for ^while; wp; skip => &hr [#] -> -> -> hf0 hf1 hr0 hr1 e0 e1 e2 e3 /=.
move: e0 e1 e2 e3 => /= -> -> -> ->.
rewrite /abef /cdgh !vpunpckh2_p4 !vpunpckl2_p4 !vpshufd_dd !vpshufd_88 !p4_0 !p4_1 !p4_2 !p4_3.
split; [|split; [|move=> k hk hne1 hne2]]; rewrite !lane8E /ofs /=;
  by do !(rewrite blend_set32 1,2:/#); smt().
qed.
