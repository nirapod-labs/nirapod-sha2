(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_Avx2Tr.ec (x86_64, avx2)
 * =================================
 *
 * The transpose of the 8-way SHA-256 AVX2 kernel
 * (src/x86_64/avx2/sha256_x8_compress.jinc): eight rows of 32 bytes,
 * row L being eight message words of instance L, become eight schedule
 * registers, register j holding word j of every instance, each word
 * byte-reversed into the big-endian order of FIPS 180-4 section 3.1
 * (transpose_x8). The three instruction steps are stated one at a time
 * (tA, rB) so that no goal holds the whole data flow.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory JModel_x86.
require import BArray256.
require import NirapodSha2.
require import WordSpec SHA256_X8_Avx2Vec SHA256_X8_Avx2Rounds.

(* ------------------------------------------------------------------ *)
(* __sha256_x8_transpose                                              *)

(* Lane i of row m. *)
abbrev xr (r : BArray256.t) m i = BArray256.get256 r m \bits32 i.

(* After the VPUNPCK{L,H}DQ step: t[2k + h] interleaves rows 2k and
   2k + 1, dwords 2h, 2h + 1 of each 128-bit half. *)
op tA (r : BArray256.t) (n : int) : W256.t =
  let k = n %/ 2 in let h = n %% 2 in
  pk8 (xr r (2 * k) (2 * h)) (xr r (2 * k + 1) (2 * h)) (xr r (2 * k) (2 * h + 1)) (xr r (2 * k + 1) (2 * h + 1))
      (xr r (2 * k) (2 * h + 4)) (xr r (2 * k + 1) (2 * h + 4)) (xr r (2 * k) (2 * h + 5)) (xr r (2 * k + 1) (2 * h + 5)).

(* After the VPUNPCK{L,H}QDQ step: r[m] holds word m mod 4 (low half)
   and word m mod 4 + 4 (high half) of rows 4 (m / 4) .. 4 (m / 4) + 3. *)
op rB (r : BArray256.t) (m : int) : W256.t =
  let b = 4 * (m %/ 4) in let c = m %% 4 in
  pk8 (xr r b c) (xr r (b + 1) c) (xr r (b + 2) c) (xr r (b + 3) c)
      (xr r b (c + 4)) (xr r (b + 1) (c + 4)) (xr r (b + 2) (c + 4)) (xr r (b + 3) (c + 4)).

(* Column j of the result is word j of the eight rows, byte-swapped. *)
lemma transpose_x8 (r0 : BArray256.t) :
  hoare [M.__sha256_x8_transpose :
    r = r0 /\ mask = bswap_mask8 ==>
    forall j L, 0 <= j < 8 => 0 <= L < 8 =>
      BArray256.get256 res j \bits32 L = bswap32 (BArray256.get256 r0 L \bits32 j)].
proof.
proc; unroll for ^while; unroll for ^while.
seq 11 : (r = r0 /\ mask = bswap_mask8 /\
          BArray256.get256 t 0 = tA r0 0 /\ BArray256.get256 t 1 = tA r0 1 /\
          BArray256.get256 t 2 = tA r0 2 /\ BArray256.get256 t 3 = tA r0 3 /\
          BArray256.get256 t 4 = tA r0 4 /\ BArray256.get256 t 5 = tA r0 5 /\
          BArray256.get256 t 6 = tA r0 6 /\ BArray256.get256 t 7 = tA r0 7).
+ by wp; skip => &hr [-> ->] /=; rewrite /tA /= ?(unpckl32E, unpckh32E).
seq 8 : (mask = bswap_mask8 /\
         BArray256.get256 r 0 = rB r0 0 /\ BArray256.get256 r 1 = rB r0 1 /\
         BArray256.get256 r 2 = rB r0 2 /\ BArray256.get256 r 3 = rB r0 3 /\
         BArray256.get256 r 4 = rB r0 4 /\ BArray256.get256 r 5 = rB r0 5 /\
         BArray256.get256 r 6 = rB r0 6 /\ BArray256.get256 r 7 = rB r0 7).
+ wp; skip => &hr [#] _ -> h0 h1 h2 h3 h4 h5 h6 h7 /=.
  rewrite ?h0 ?h1 ?h2 ?h3 ?h4 ?h5 ?h6 ?h7 /tA /rB /= ?(unpckl64E, unpckh64E).
  by rewrite !pk8_lane.
wp; skip => &hr [#] -> h0 h1 h2 h3 h4 h5 h6 h7 /= j L hj hL.
rewrite ?h0 ?h1 ?h2 ?h3 ?h4 ?h5 ?h6 ?h7 /rB /= ?(perm20E, perm31E) !vpshufb_bswap8 /= !pk8_lane //=.
have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 j hj;
by have [->|[->|[->|[->|[->|[->|[->|->]]]]]]] := cases8 L hL.
qed.
