(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * StreamSpec.ec
 * =============
 *
 * Facts about messages as a stream of blocks, for the streaming,
 * one-shot, HMAC and context proofs. No model is involved.
 *
 * A streaming state that has absorbed a message m holds the chaining value
 * of the complete blocks of m and the bytes after them, tail b m, where b
 * is the block size (64 for SHA-224 and SHA-256, 128 for the SHA-512
 * family). The lemmas below are stated for any block size b > 0 over
 * chunk b, which is how parse of FIPS 180-4 section 5.2 cuts a message
 * (chunk drops an incomplete last block), and then for the two padding
 * rules of section 5.1:
 *
 *     tail b m             the size m mod b bytes after the whole blocks;
 *     chunk_cat_tail       the blocks of m ++ y are those of m, then those
 *                          of tail b m ++ y;
 *     close_block, short_ext, blocks_ext
 *                          the three ways an absorb extends m;
 *     nfill                the bytes that complete a pending block;
 *     mfin b l m           m with 0x80 appended, and zeros to the end of
 *                          the block when the l-byte length field no
 *                          longer fits (the state before the length is
 *                          written);
 *     pad256_fin, pad512_fin
 *                          SHA256.pad and SHA512.pad in those terms.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord.
require import Bytes FIPS180_SHA2.
require JWordList.

(* ------------------------------------------------------------------ *)
(* Blocks and tails                                                   *)

op tail (b : int) (m : 'a list) : 'a list = drop (b * (size m %/ b)) m.

lemma size_tail b (m : 'a list) : 0 < b => size (tail b m) = size m %% b.
proof. by move=> hb; rewrite /tail size_drop; smt(size_ge0 divz_eq modz_ge0 divz_ge0). qed.

lemma tail_short b (t : 'a list) : 0 < b => size t < b => tail b t = t.
proof.
move=> hb ht; rewrite /tail (_ : size t %/ b = 0); first smt(pdiv_small size_ge0).
by rewrite drop0.
qed.

lemma chunk_short b (t : 'a list) : 0 < b => size t < b => chunk b t = [].
proof. by move=> hb ht; rewrite JWordList.chunk0. qed.

lemma chunk_blocks_cat b (x z : 'a list) :
  0 < b => b %| size x => chunk b (x ++ z) = chunk b x ++ chunk b z.
proof. by move=> hb hx; rewrite chunk_cat. qed.

lemma tail_blocks_cat b (x z : 'a list) :
  0 < b => b %| size x => tail b (x ++ z) = tail b z.
proof.
move=> hb /dvdzP [q hq]; rewrite /tail size_cat hq.
rewrite (_ : (q * b + size z) %/ b = q + size z %/ b).
+ by rewrite divzMDl 1:/#.
have -> : b * (q + size z %/ b) = q * b + b * (size z %/ b) by ring.
have hge : 0 <= b * (size z %/ b) by apply mulr_ge0; smt(divz_ge0 size_ge0).
rewrite drop_cat hq ifF 1:/#.
by congr; ring.
qed.

lemma split_blocks b (m : 'a list) : m = take (b * (size m %/ b)) m ++ tail b m.
proof. by rewrite /tail cat_take_drop. qed.

lemma dvd_head b (m : 'a list) : 0 < b => b %| size (take (b * (size m %/ b)) m).
proof.
move=> hb; rewrite size_take; first smt(divz_ge0 size_ge0).
case: (b * (size m %/ b) < size m) => hlt; first by apply dvdz_mulr; apply dvdzz.
have -> : size m = b * (size m %/ b) by smt(divz_eq modz_ge0 size_ge0).
by apply dvdz_mulr; apply dvdzz.
qed.

(* The blocks of m ++ y: those of m, then those of its tail followed by y. *)
lemma chunk_cat_tail b (m y : 'a list) :
  0 < b => chunk b (m ++ y) = chunk b m ++ chunk b (tail b m ++ y).
proof.
move=> hb; have hm := split_blocks b m.
have -> : chunk b m = chunk b (take (b * (size m %/ b)) m).
+ rewrite {1}hm chunk_blocks_cat // 1:dvd_head // (chunk_short b (tail b m)) ?cats0 //.
  by rewrite size_tail //; smt(ltz_pmod).
by rewrite {1}hm -catA chunk_blocks_cat // dvd_head.
qed.

lemma tail_cat b (m y : 'a list) : 0 < b => tail b (m ++ y) = tail b (tail b m ++ y).
proof. by move=> hb; rewrite {1}(split_blocks b m) -catA tail_blocks_cat // dvd_head. qed.

lemma chunk_block b (x : 'a list) : 0 < b => size x = b => chunk b x = [x].
proof.
move=> hb hx; have hne : x <> [] by rewrite -size_eq0 hx /#.
by have := chunk_exact x hne; rewrite hx => ->.
qed.

(* Extending m so that its tail fills one block: one more block. *)
lemma close_block b (m y : 'a list) :
  0 < b => size (tail b m ++ y) = b =>
  chunk b (m ++ y) = rcons (chunk b m) (tail b m ++ y) /\ tail b (m ++ y) = [].
proof.
move=> hb hs; rewrite chunk_cat_tail // (chunk_block b _ hb hs) cats1 /=.
by rewrite tail_cat // /tail hs divzz /= (_: b <> 0) 1:/# /b2i /= drop_oversize 1:/#.
qed.

(* Extending m within its last block: no new block. *)
lemma short_ext b (m y : 'a list) :
  0 < b => size (tail b m ++ y) < b =>
  chunk b (m ++ y) = chunk b m /\ tail b (m ++ y) = tail b m ++ y.
proof.
move=> hb hs; rewrite chunk_cat_tail // (chunk_short b _ hb hs) cats0 /=.
by rewrite tail_cat // (tail_short b _ hb hs).
qed.

(* Extending a block-aligned m by whole blocks. *)
lemma blocks_ext b (m x : 'a list) :
  0 < b => tail b m = [] => b %| size x =>
  chunk b (m ++ x) = chunk b m ++ chunk b x /\ tail b (m ++ x) = [].
proof.
move=> hb hm hx; split; first by rewrite chunk_cat_tail // hm.
rewrite tail_cat // hm /= /tail; move: hx => /dvdzP [q hq].
by rewrite hq mulzK 1:/# (mulzC b) drop_oversize /#.
qed.

(* ------------------------------------------------------------------ *)
(* How an absorb cuts its input                                       *)

(* The bytes that complete a pending block of r bytes from an input of
   l bytes; none when nothing is pending. *)
op nfill (b r l : int) : int = if r = 0 then 0 else min l (b - r).

lemma nfill_bounds b r l : 0 <= r < b => 0 <= l =>
  0 <= nfill b r l <= l /\ r + nfill b r l <= b.
proof. by rewrite /nfill /#. qed.

(* nf bytes into the pending block, whole blocks, then the rest. *)
lemma absorb_split b mem (m : W8.t list) a l nf : 0 < b => 0 <= nf <= l =>
  m ++ JWordList.memread mem a l
  = ((m ++ JWordList.memread mem a nf)
     ++ JWordList.memread mem (a + nf) (b * ((l - nf) %/ b)))
    ++ JWordList.memread mem (a + nf + b * ((l - nf) %/ b)) ((l - nf) %% b).
proof.
move=> hb hnf.
have hl : l = nf + (b * ((l - nf) %/ b) + (l - nf) %% b) by smt(divz_eq).
have hq : 0 <= b * ((l - nf) %/ b) by apply mulr_ge0; smt(divz_ge0).
rewrite {1}hl JWordList.memread_add 1,2:/# JWordList.memread_add //; 1: smt(modz_ge0).
by rewrite !catA.
qed.

(* Masking with 2^k - 1 is reduction mod 2^k. *)
lemma and_mask (w : W64.t) k : 0 <= k < 64 =>
  W64.to_uint (w `&` W64.of_int (2 ^ k - 1)) = W64.to_uint w %% 2 ^ k.
proof.
move=> hk; rewrite W64.and_mod 1:/# W64.of_uintK.
have h1 : 0 < 2 ^ k by apply expr_gt0.
have h2 : 2 ^ k <= 2 ^ 64 by apply ler_weexpn2l => /#.
rewrite (pmod_small _ W64.modulus) //.
split; first by apply modz_ge0 => /#.
by move=> _; apply (ltr_le_trans (2 ^ k)) => //; apply ltz_pmod.
qed.

(* ------------------------------------------------------------------ *)
(* The length field                                                   *)

(* The k-byte encoding reads x modulo 256^k only. *)
lemma be_bytes_mod k x : 0 <= k => be_bytes k (x %% 256 ^ k) = be_bytes k x.
proof.
move=> hk; apply eq_in_mkseq => i hi /=.
have -> : (x %% 256 ^ k) %/ 256 ^ (k - 1 - i) = (x %/ 256 ^ (k - 1 - i)) %% 256 ^ (k - (k - 1 - i)).
+ by apply modz_pow_div => /#.
apply W8.to_uint_eq; rewrite !W8.of_uintK modz_dvd //.
rewrite (_ : k - (k - 1 - i) = (k - (k - 1 - i) - 1) + 1) 1:/# exprS 1:/#.
by apply dvdz_mulr; apply dvdzz.
qed.

(* An encoding of k + j bytes is the high k bytes, then the low j. *)
lemma be_bytes_cat k j x : 0 <= k => 0 <= j =>
  be_bytes (k + j) x = be_bytes k (x %/ 256 ^ j) ++ be_bytes j x.
proof.
move=> hk hj; rewrite /be_bytes mkseq_add //; congr.
+ apply eq_in_mkseq => i hi /=; congr.
  rewrite -divzMr; 1,2: smt(StdOrder.IntOrder.expr_ge0).
  have -> : k + j - 1 - i = j + (k - 1 - i) by ring.
  by rewrite exprD_nneg 1,2:/#.
apply eq_mkseq => i /=.
by have -> : k + j - 1 - (k + i) = j - 1 - i by ring.
qed.

(* 8 t as a 64-bit word, and as the high word of a 128-bit length. *)
lemma shl3E (t : W64.t) :
  W64.to_uint (t `<<` W8.of_int 3) = (8 * W64.to_uint t) %% 2 ^ 64.
proof. by rewrite /(`<<`) W64.to_uint_shl //= mulzC. qed.

lemma shr61E (t : W64.t) :
  W64.to_uint (t `>>` W8.of_int 61) = W64.to_uint t %/ 2 ^ 61.
proof. by rewrite /(`>>`) W64.to_uint_shr. qed.

lemma len8E (t : W64.t) :
  be_bytes 8 (8 * W64.to_uint t) = be_bytes 8 (W64.to_uint (t `<<` W8.of_int 3)).
proof. by rewrite shl3E (_ : 2 ^ 64 = 256 ^ 8) 1:// be_bytes_mod. qed.

lemma len16E (t : W64.t) :
  be_bytes 16 (8 * W64.to_uint t)
  = be_bytes 8 (W64.to_uint (t `>>` W8.of_int 61)) ++ be_bytes 8 (W64.to_uint (t `<<` W8.of_int 3)).
proof.
rewrite (_ : 16 = 8 + 8) 1:// be_bytes_cat // -len8E shr61E; congr; congr.
rewrite (_ : 256 ^ 8 = 8 * 2 ^ 61) 1:// divzMpl //.
qed.

(* ------------------------------------------------------------------ *)
(* Padding (section 5.1)                                              *)

(* The padding rule for block size b and an l-byte length field: 0x80,
   then zeros up to b - l mod b, then the bit length. *)
op padb (b l : int) (m : bytes) : bytes =
  m ++ [W8.of_int 0x80] ++ zeros ((b - l - 1 - size m) %% b) ++ be_bytes l (8 * size m).

lemma pad256E (m : bytes) : SHA256.pad m = padb 64 8 m.
proof. by rewrite /SHA256.pad /padb. qed.

lemma pad512E (m : bytes) : SHA512.pad m = padb 128 16 m.
proof. by rewrite /SHA512.pad /padb. qed.

(* m with its 0x80 byte and, when the length field no longer fits in that
   block, zeros to the end of the block: what the buffer and the chaining
   value hold before the length is written. *)
op mfin (b l : int) (m : bytes) : bytes =
  if size m %% b <= b - l - 1 then m ++ [W8.of_int 128]
  else m ++ [W8.of_int 128] ++ zeros (b - 1 - size m %% b).

lemma mod_shift b (a x : int) : 0 < b => 0 <= a - x %% b < b => (a - x) %% b = a - x %% b.
proof.
move=> hb h; rewrite {1}(divz_eq x b).
rewrite (_ : a - (x %/ b * b + x %% b) = (a - x %% b) + (- (x %/ b)) * b) 1:/#.
by rewrite modzMDr pmod_small.
qed.

lemma size_mfin b l (m : bytes) : 0 < l < b =>
  size (mfin b l m) %% b = if size m %% b <= b - l - 1 then size m %% b + 1 else 0.
proof.
move=> hl; have hr := ltz_pmod (size m) b _; 1: smt().
have hr0 := modz_ge0 (size m) b _; 1: smt().
rewrite /mfin; case: (size m %% b <= b - l - 1) => h /=.
+ by rewrite size_cat /= -modzDml pmod_small /#.
rewrite !size_cat size_zeros /= (_ : max 0 (b - 1 - size m %% b) = b - 1 - size m %% b) 1:/#.
rewrite {1}(divz_eq (size m) b).
rewrite (_ : size m %/ b * b + size m %% b + 1 + (b - 1 - size m %% b) = (size m %/ b + 1) * b) 1:/#.
exact modzMl.
qed.

lemma padb_fin b l (m : bytes) : 0 < l < b =>
  padb b l m = mfin b l m ++ (zeros (b - l - size (mfin b l m) %% b) ++ be_bytes l (8 * size m)).
proof.
move=> hl; have hr := ltz_pmod (size m) b _; 1: smt().
have hr0 := modz_ge0 (size m) b _; 1: smt().
rewrite size_mfin // /padb /mfin.
case: (size m %% b <= b - l - 1) => h /=.
+ by rewrite (mod_shift b) 1,2:/# !catA /#.
rewrite (_ : b - l - 1 - size m = (2 * b - l - 1 - size m) + (-1) * b) 1:/# modzMDr.
rewrite (mod_shift b) 1,2:/#.
rewrite /zeros (_ : 2 * b - l - 1 - size m %% b = (b - 1 - size m %% b) + (b - l)) 1:/#.
by rewrite -cat_nseq 1,2:/# !catA.
qed.

(* ------------------------------------------------------------------ *)
(* Digests                                                            *)

lemma size_w32_be (x : W32.t) : size (w32_be x) = 4.
proof. by rewrite /w32_be size_rev W4u8.size_to_list. qed.

lemma size_w64_be (x : W64.t) : size (w64_be x) = 8.
proof. by rewrite /w64_be size_rev W8u8.size_to_list. qed.

(* A digest truncated to n whole words is the encoding of the first n
   words of the chaining value (sections 6.3, 6.5 to 6.7). *)
lemma take_be32 (hv : W32.t list) n : 0 <= n =>
  take (4 * n) (flatten (map w32_be hv)) = flatten (map w32_be (take n hv)).
proof.
elim: hv n => [|x xs ih] n hn /=; first by rewrite flatten_nil.
rewrite !flatten_cons; case: (n = 0) => [->|hn0] /=; first by rewrite flatten_nil.
rewrite take_cat size_w32_be ifF 1:/# (_ : 4 * n - 4 = 4 * (n - 1)) 1:/# ih 1:/#.
by rewrite ifF 1:/# /= flatten_cons.
qed.

lemma take_be64 (hv : W64.t list) n : 0 <= n =>
  take (8 * n) (flatten (map w64_be hv)) = flatten (map w64_be (take n hv)).
proof.
elim: hv n => [|x xs ih] n hn /=; first by rewrite flatten_nil.
rewrite !flatten_cons; case: (n = 0) => [->|hn0] /=; first by rewrite flatten_nil.
rewrite take_cat size_w64_be ifF 1:/# (_ : 8 * n - 8 = 8 * (n - 1)) 1:/# ih 1:/#.
by rewrite ifF 1:/# /= flatten_cons.
qed.

(* ------------------------------------------------------------------ *)
(* Bytes through 64-bit registers                                     *)

lemma trunc_zext (b : W8.t) : truncateu8 (zeroextu64 b) = b.
proof.
apply W8.to_uint_eq; rewrite to_uint_truncateu8 to_uint_zeroextu64.
exact W8.to_uint_mod.
qed.

lemma trunc_const (x : int) : 0 <= x < 256 => truncateu8 (W64.of_int x) = W8.of_int x.
proof.
move=> hx; apply W8.to_uint_eq; rewrite to_uint_truncateu8 W64.of_uintK W8.of_uintK.
have h1 : x %% W64.modulus = x by rewrite pmod_small /#.
have h2 : x %% W8.modulus = x by rewrite pmod_small /#.
by rewrite h1 h2.
qed.
