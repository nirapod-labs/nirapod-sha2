(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA512_X4_KernelSafety.ec
 * =========================
 *
 * Safety of the portable 4-way SHA-512 kernel, src/sha512_x4_compress.jinc:
 * four single-way compressions, one per lane, through the unit's SHA-512
 * kernel, whose safety lemmas come from SafetyK512. Checked on every unit
 * whose 4-way kernel is the portable one.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyK512.
require import BArray32 BArray64 BArray256 BArray512 SBArray512_128 NirapodSha2Safety.

lemma _sha512_x4_compress_proof _h4 _blocks _ms _h4_init _blocks_init :
  _sha512_x4_compress_spec _h4 _blocks _ms _h4_init _blocks_init.
proof.
rewrite /_sha512_x4_compress_spec; proc.
wp; while (valid trace__sha512_x4_compress /\ k_init /\ ms_init /\ 0 <= k <= 4
       /\ h4_init = full256 /\ blocks_init = full512).
+ wp; while (valid trace__sha512_x4_compress /\ j_init /\ k_init /\ ms_init /\ 0 <= j <= 8
         /\ 0 <= k < 4 /\ h4_init = full256 /\ blocks_init = full512
         /\ BArray64.is_init h_init 0 64).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hh hlt.
    have hi : BArray64.is_init h_init{m} (j{m} * 8) 8 by move=> i hi1 hi2; apply hh => /#.
    by rewrite full256_set64d hi /=; smt().
  wp; ecall (_sha512_compress_proof h (SBArray512_128.get_sub8 blocks (128 * k)) ms h_init
               (SBArray512_128.get_sub blocks_init (1 * (128 * k)))).
  wp; while (valid trace__sha512_x4_compress /\ j_init /\ k_init /\ ms_init /\ 0 <= j <= 8
         /\ 0 <= k < 4 /\ h4_init = full256 /\ blocks_init = full512
         /\ BArray64.is_init h_init 0 (8 * j)).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hh hlt.
    have hm := mask64_set64 h_init{m} j{m} hh _ _; 1,2: smt().
    by rewrite full256_init hm /=; smt().
  auto => /> &m _ _ _ hk0 hk8 hlt; split; 1: by move=> i /#.
  move=> hi0 j0 tr0 hlt0 _ hj0 hj8 hh.
  have hh32 : BArray64.is_init hi0 0 64 by have <- : 8 * j0 = 64 by smt().
  have hsub := sub512_128_get full512 (128 * k{m}) 0 128 (full512_init _ _) _ _ _ _; 1..4: smt().
  by rewrite hh32 hsub /=; smt().
auto => /> hh hb.
split; 1: by rewrite (full256E _ hh) (full512E _ hb).
by move=> *; exact (full256_init 0 256).
qed.

lemma _sha512_x4_compress_lanes_proof _h4 _in _off _n _ms _h4_init _in_init :
  _sha512_x4_compress_lanes_spec _h4 _in _off _n _ms _h4_init _in_init.
proof.
rewrite /_sha512_x4_compress_lanes_spec; proc.
wp; while (valid trace__sha512_x4_compress_lanes /\ k_init /\ ms_init /\ off_init /\ n_init
       /\ 0 <= k <= 4 /\ h4_init = full256 /\ in_init = full32 /\ in_0 = _in /\ off = _off
       /\ n = _n /\ _n \ult W64.of_int 144115188075855872
       /\ lanes_valid Glob.mem_v 4 (fun i => to_uint (BArray32.get64 _in i + _off))
            (to_uint (W64.of_int 128 * _n))).
+ wp; while (valid trace__sha512_x4_compress_lanes /\ j_init /\ k_init /\ ms_init /\ off_init
         /\ n_init /\ 0 <= j <= 8 /\ 0 <= k < 4 /\ h4_init = full256 /\ in_init = full32
         /\ in_0 = _in /\ off = _off /\ n = _n /\ _n \ult W64.of_int 144115188075855872
         /\ lanes_valid Glob.mem_v 4 (fun i => to_uint (BArray32.get64 _in i + _off))
              (to_uint (W64.of_int 128 * _n))
         /\ BArray64.is_init h_init 0 64).
  + auto => /> &m _ _ _ _ _ _ hj0 hj8 hk0 hk8 hn hlv hh hlt.
    have hi : BArray64.is_init h_init{m} (j{m} * 8) 8 by move=> i hi1 hi2; apply hh => /#.
    by rewrite full256_set64d hi /=; smt().
  wp; ecall (_sha512_compress_blocks_proof h p n ms h_init).
  wp; while (valid trace__sha512_x4_compress_lanes /\ j_init /\ k_init /\ ms_init /\ off_init
         /\ n_init /\ 0 <= j <= 8 /\ 0 <= k < 4 /\ h4_init = full256 /\ in_init = full32
         /\ in_0 = _in /\ off = _off /\ n = _n /\ _n \ult W64.of_int 144115188075855872
         /\ lanes_valid Glob.mem_v 4 (fun i => to_uint (BArray32.get64 _in i + _off))
              (to_uint (W64.of_int 128 * _n))
         /\ BArray64.is_init h_init 0 (8 * j)).
  + auto => /> &m _ _ _ _ _ _ hj0 hj8 hk0 hk8 hn hlv hh hlt.
    have hm := mask64_set64 h_init{m} j{m} hh _ _; 1,2: smt().
    by rewrite full256_init hm /=; smt().
  auto => /> &m _ _ _ _ _ hk0 hk8 hn hlv hlt.
  split; 1: by move=> i /#.
  move=> hi0 j0 tr0 hlt0 _ hj0 hj8 hh.
  have hh32 : BArray64.is_init hi0 0 64 by have <- : 8 * j0 = 64 by smt().
  have := hlv k{m} _; 1: smt().
  rewrite /is_valid /protect_64 /= => -[hv1 [hv2 hv3]].
  split; 1: by rewrite hh32 /=; do !split => // i h1 h2; apply hv1.
  move=> _ _ _ _ r hr1 hr2; rewrite full32_init /=; split; 1: smt().
  by move=> *; smt().
auto => /> &m *; split.
+ do !split; 1,2: by apply full256E || apply full32E.
  by apply lanes_valid4; rewrite /is_valid /=; do !split => //.
by move=> *; exact (full256_init 0 256).
qed.
