(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * K256.ec
 * =======
 *
 * The SHA-256 kernel of this unit as the shared correctness proofs see it.
 * The shared layers call a single-way SHA-256 kernel only through
 * _sha256_compress and _sha256_compress_blocks, and use only the lemmas of
 * this theory, under these names, on every unit:
 *
 *     compress_correct, compress_ll, compress_total
 *         _sha256_compress h block = compress of FIPS 180-4 6.2.2 on the
 *         big-endian words of block;
 *     compress_blocks_correct, compress_blocks_ll, compress_blocks_total
 *         _sha256_compress_blocks h p n folds compress over the n blocks
 *         at p, for p + 64 n < 2^64.
 *
 * Here the kernel is the portable one (src/sha256_compress.jinc).
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray32 BArray64 NirapodSha2 FIPS180_SHA2 State.
require JWordList SHA256_Compress SHA256_Blocks.
import SHA256.

lemma hwordsE : SHA256_Compress.hwords = h256.
proof. by []. qed.

lemma compress_ll : islossless M._sha256_compress.
proof. exact SHA256_Compress.sha256_compress_ll. qed.

lemma compress_correct (h0 : W32.t list) (blk : BArray64.t) :
  hoare [M._sha256_compress :
           h256 h = h0 /\ block = blk ==>
           h256 res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))].
proof. by conseq (SHA256_Compress.sha256_compress_correct h0 blk) => &hr; rewrite hwordsE. qed.

lemma compress_total (h0 : W32.t list) (blk : BArray64.t) :
  phoare [M._sha256_compress :
           h256 h = h0 /\ block = blk ==>
           h256 res.`1 = compress h0 (map be32 (chunk 4 (BArray64.to_list blk)))] = 1%r.
proof. by conseq compress_ll (compress_correct h0 blk). qed.

lemma compress_blocks_ll : islossless M._sha256_compress_blocks.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call SHA256_Blocks.sha256_compress_one_ll; auto => /> &m hn.
  have h1 : 1 <= W64.to_uint n{m}.
  + have : W64.to_uint n{m} <> 0 by move: hn; apply contra => h; apply W64.to_uint_eq.
    smt(W64.to_uint_cmp).
  by rewrite /Jslh.SLH64.protect_64 W64.to_uintB 1:W64.uleE //=; smt().
auto => /> n1 hn; rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           h256 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           h256 res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq (SHA256_Blocks.sha256_compress_blocks_total h0 p0 n0) => &hr; rewrite hwordsE. qed.

lemma compress_blocks_correct (h0 : W32.t list) (p0 n0 : W64.t) :
  hoare [M._sha256_compress_blocks :
           h256 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           h256 res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))].
proof. by conseq (compress_blocks_total h0 p0 n0). qed.
