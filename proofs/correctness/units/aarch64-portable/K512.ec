(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * K512.ec
 * =======
 *
 * The SHA-512 kernel of this unit as the shared correctness proofs see it.
 * The shared layers call a single-way SHA-512 kernel only through
 * _sha512_compress and _sha512_compress_blocks, and use only the lemmas of
 * this theory, under these names, on every unit:
 *
 *     compress_correct, compress_ll, compress_total
 *         _sha512_compress h block = compress of FIPS 180-4 6.4.2 on the
 *         big-endian words of block;
 *     compress_blocks_correct, compress_blocks_ll, compress_blocks_total
 *         _sha512_compress_blocks h p n folds compress over the n blocks
 *         at p, for p + 128 n < 2^64.
 *
 * Here the kernel is the portable one (src/sha512_compress.jinc).
 *)

require import AllCore List IntDiv.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory.
require import BArray64 BArray128 NirapodSha2 FIPS180_SHA2 State.
require JWordList SHA512_Compress SHA512_Blocks.
import SHA512.

lemma hwordsE : SHA512_Compress.hwords = h512.
proof. by []. qed.

lemma compress_ll : islossless M._sha512_compress.
proof. exact SHA512_Compress.sha512_compress_ll. qed.

lemma compress_correct (h0 : W64.t list) (blk : BArray128.t) :
  hoare [M._sha512_compress :
           h512 h = h0 /\ block = blk ==>
           h512 res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))].
proof. by conseq (SHA512_Compress.sha512_compress_correct h0 blk) => &hr; rewrite hwordsE. qed.

lemma compress_total (h0 : W64.t list) (blk : BArray128.t) :
  phoare [M._sha512_compress :
           h512 h = h0 /\ block = blk ==>
           h512 res.`1 = compress h0 (map be64 (chunk 8 (BArray128.to_list blk)))] = 1%r.
proof. by conseq compress_ll (compress_correct h0 blk). qed.

lemma compress_blocks_ll : islossless M._sha512_compress_blocks.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call SHA512_Blocks.sha512_compress_one_ll; auto => /> &m hn.
  have h1 : 1 <= W64.to_uint n{m}.
  + have : W64.to_uint n{m} <> 0 by move: hn; apply contra => h; apply W64.to_uint_eq.
    smt(W64.to_uint_cmp).
  by rewrite /Jslh.SLH64.protect_64 W64.to_uintB 1:W64.uleE //=; smt().
auto => /> n1 hn; rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma compress_blocks_total (h0 : W64.t list) (p0 n0 : W64.t) :
  phoare [M._sha512_compress_blocks :
           h512 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           h512 res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq (SHA512_Blocks.sha512_compress_blocks_total h0 p0 n0) => &hr; rewrite hwordsE. qed.

lemma compress_blocks_correct (h0 : W64.t list) (p0 n0 : W64.t) :
  hoare [M._sha512_compress_blocks :
           h512 h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 128 * W64.to_uint n0 < W64.modulus ==>
           h512 res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (128 * W64.to_uint n0)))].
proof. by conseq (compress_blocks_total h0 p0 n0). qed.
