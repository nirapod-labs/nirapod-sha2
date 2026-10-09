(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_KernelSafety.ec
 * =========================
 *
 * Safety of the portable 8-way SHA-256 kernel, src/sha256_x8_compress.jinc:
 * eight single-way compressions, one per lane, through the unit's SHA-256
 * kernel, whose safety lemmas come from SafetyK256. Checked on every unit
 * whose 8-way kernel is the portable one.
 *)

require import AllCore IntDiv CoreMap List Distr.
from Jasmin require import JWord JUtils JMemory Jcheck JSafety.
require import SafetyLib SafetyMask SafetySub SafetyK256.
require import BArray32 BArray64 BArray256 BArray512 SBArray512_64 NirapodSha2Safety.

lemma _sha256_x8_compress_proof _h8 _blocks _ms _h8_init _blocks_init :
  _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init.
proof.
rewrite /_sha256_x8_compress_spec; proc.
wp; while (valid trace__sha256_x8_compress /\ k_init /\ ms_init /\ 0 <= k <= 8
       /\ h8_init = full256 /\ blocks_init = full512).
+ wp; while (valid trace__sha256_x8_compress /\ j_init /\ k_init /\ ms_init /\ 0 <= j <= 8
         /\ 0 <= k < 8 /\ h8_init = full256 /\ blocks_init = full512
         /\ BArray32.is_init h_init 0 32).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hh hlt.
    have hi : BArray32.is_init h_init{m} (j{m} * 4) 4 by move=> i hi1 hi2; apply hh => /#.
    by rewrite full256_set32d hi /=; smt().
  wp; ecall (_sha256_compress_proof h (SBArray512_64.get_sub8 blocks (64 * k)) ms h_init
               (SBArray512_64.get_sub blocks_init (1 * (64 * k)))).
  wp; while (valid trace__sha256_x8_compress /\ j_init /\ k_init /\ ms_init /\ 0 <= j <= 8
         /\ 0 <= k < 8 /\ h8_init = full256 /\ blocks_init = full512
         /\ BArray32.is_init h_init 0 (4 * j)).
  + auto => /> &m _ _ _ _ hj0 hj8 hk0 hk8 hh hlt.
    have hm := mask32_set32 h_init{m} j{m} hh _ _; 1,2: smt().
    by rewrite full256_init hm /=; smt().
  auto => /> &m _ _ _ hk0 hk8 hlt; split; 1: by move=> i /#.
  move=> hi0 j0 tr0 hlt0 _ hj0 hj8 hh.
  have hh32 : BArray32.is_init hi0 0 32 by have <- : 4 * j0 = 32 by smt().
  have hsub := sub512_64_get full512 (64 * k{m}) 0 64 (full512_init _ _) _ _ _ _; 1..4: smt().
  by rewrite hh32 hsub /=; smt().
auto => /> hh hb.
split; 1: by rewrite (full256E _ hh) (full512E _ hb).
by move=> *; exact (full256_init 0 256).
qed.

lemma _sha256_x8_compress_lanes_proof _h8 _in _off _n _ms _h8_init _in_init :
  _sha256_x8_compress_lanes_spec _h8 _in _off _n _ms _h8_init _in_init.
proof.
rewrite /_sha256_x8_compress_lanes_spec; proc.
wp; while (valid trace__sha256_x8_compress_lanes /\ k_init /\ ms_init /\ off_init /\ n_init
       /\ 0 <= k <= 8 /\ h8_init = full256 /\ in_init = full64 /\ in_0 = _in /\ off = _off
       /\ n = _n /\ _n \ult W64.of_int 288230376151711744
       /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i + _off))
            (to_uint (W64.of_int 64 * _n))).
+ wp; while (valid trace__sha256_x8_compress_lanes /\ j_init /\ k_init /\ ms_init /\ off_init
         /\ n_init /\ 0 <= j <= 8 /\ 0 <= k < 8 /\ h8_init = full256 /\ in_init = full64
         /\ in_0 = _in /\ off = _off /\ n = _n /\ _n \ult W64.of_int 288230376151711744
         /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i + _off))
              (to_uint (W64.of_int 64 * _n))
         /\ BArray32.is_init h_init 0 32).
  + auto => /> &m _ _ _ _ _ _ hj0 hj8 hk0 hk8 hn hlv hh hlt.
    have hi : BArray32.is_init h_init{m} (j{m} * 4) 4 by move=> i hi1 hi2; apply hh => /#.
    by rewrite full256_set32d hi /=; smt().
  wp; ecall (_sha256_compress_blocks_proof h p n ms h_init).
  wp; while (valid trace__sha256_x8_compress_lanes /\ j_init /\ k_init /\ ms_init /\ off_init
         /\ n_init /\ 0 <= j <= 8 /\ 0 <= k < 8 /\ h8_init = full256 /\ in_init = full64
         /\ in_0 = _in /\ off = _off /\ n = _n /\ _n \ult W64.of_int 288230376151711744
         /\ lanes_valid Glob.mem_v 8 (fun i => to_uint (BArray64.get64 _in i + _off))
              (to_uint (W64.of_int 64 * _n))
         /\ BArray32.is_init h_init 0 (4 * j)).
  + auto => /> &m _ _ _ _ _ _ hj0 hj8 hk0 hk8 hn hlv hh hlt.
    have hm := mask32_set32 h_init{m} j{m} hh _ _; 1,2: smt().
    by rewrite full256_init hm /=; smt().
  auto => /> &m _ _ _ _ _ hk0 hk8 hn hlv hlt.
  split; 1: by move=> i /#.
  move=> hi0 j0 tr0 hlt0 _ hj0 hj8 hh.
  have hh32 : BArray32.is_init hi0 0 32 by have <- : 4 * j0 = 32 by smt().
  have := hlv k{m} _; 1: smt().
  rewrite /is_valid /protect_64 /= => -[hv1 [hv2 hv3]].
  split; 1: by rewrite hh32 /=; do !split => // i h1 h2; apply hv1.
  move=> _ _ _ _ r hr1 hr2; rewrite full64_init /=; split; 1: smt().
  by move=> *; smt().
auto => /> &m *; split.
+ do !split; 1,2: by apply full256E || apply full64E.
  by apply lanes_valid8; rewrite /is_valid /=; do !split => //.
by move=> *; exact (full256_init 0 256).
qed.
