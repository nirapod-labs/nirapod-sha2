(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * HMACSpec.ec
 * ===========
 *
 * Facts about HMAC of FIPS 198-1 (spec/FIPS198_HMAC.ec) for the HMAC
 * proofs over SHA-256 and SHA-512. No model is involved.
 *
 * The code computes K0 (steps 1 to 3) for a key of any length, then the
 * two hashes of step 9 from the blocks K0 ^ ipad and K0 ^ opad. The
 * lemmas below give K0 in each of the three cases of step 1 to 3, the
 * size of K0, HMAC as the two hashes around K0, and the bytes of the
 * padded blocks as the code forms them, eight at a time from the 64-bit
 * words 0x3636...36 and 0x5c5c...5c.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord.
require import Bytes FIPS180_SHA2 FIPS198_HMAC.
require import Rounds256 Rounds512 StreamSpec.

(* ------------------------------------------------------------------ *)
(* Digest sizes                                                       *)

lemma size_hash256 h0 (m : bytes) : size h0 = 8 => size (SHA256.hash h0 m) = 8.
proof.
move=> hs; rewrite /SHA256.hash; elim: (SHA256.parse (SHA256.pad m)) h0 hs => //=.
by move=> b bs ih h0 hs; apply ih; apply Rounds256.size_compress.
qed.

lemma size_hash512 h0 (m : bytes) : size h0 = 8 => size (SHA512.hash h0 m) = 8.
proof.
move=> hs; rewrite /SHA512.hash; elim: (SHA512.parse (SHA512.pad m)) h0 hs => //=.
by move=> b bs ih h0 hs; apply ih; apply Rounds512.size_compress.
qed.

lemma size_flatten_be32 (hv : W32.t list) : size (flatten (map w32_be hv)) = 4 * size hv.
proof.
elim: hv => [|x xs ih] /=; first by rewrite flatten_nil.
by rewrite flatten_cons size_cat ih size_w32_be; ring.
qed.

lemma size_flatten_be64 (hv : W64.t list) : size (flatten (map w64_be hv)) = 8 * size hv.
proof.
elim: hv => [|x xs ih] /=; first by rewrite flatten_nil.
by rewrite flatten_cons size_cat ih size_w64_be; ring.
qed.

lemma size_sha256 (m : bytes) : size (SHA256.sha256 m) = 32.
proof. by rewrite /SHA256.sha256 size_flatten_be32 size_hash256. qed.

lemma size_sha512 (m : bytes) : size (SHA512.sha512 m) = 64.
proof. by rewrite /SHA512.sha512 /SHA512.digest size_flatten_be64 size_hash512. qed.

(* ------------------------------------------------------------------ *)
(* K0, steps 1 to 3                                                   *)

lemma hmac_key_short (hash : bytes -> bytes) b (k : bytes) : size k <= b =>
  hmac_key hash b k = k ++ zeros (b - size k).
proof.
move=> hk; rewrite /hmac_key; case: (size k = b) => hb.
+ by rewrite hb /zeros nseq0 cats0.
by rewrite ifF 1:/#.
qed.

lemma hmac_key_long (hash : bytes -> bytes) b (k : bytes) : b < size k =>
  hmac_key hash b k = hash k ++ zeros (b - size (hash k)).
proof. by move=> hk; rewrite /hmac_key ifF 1:/# ifT 1:/#. qed.

lemma size_hmac_key (hash : bytes -> bytes) b (k : bytes) :
  (b < size k => size (hash k) <= b) => size (hmac_key hash b k) = b.
proof.
move=> hh; case: (size k <= b) => hk.
+ by rewrite hmac_key_short // size_cat size_zeros /#.
by rewrite hmac_key_long 1:/# size_cat size_zeros; smt().
qed.

lemma size_key256 (k : bytes) : size (hmac_key SHA256.sha256 64 k) = 64.
proof. by apply size_hmac_key => _; rewrite size_sha256. qed.

lemma size_key512 (k : bytes) : size (hmac_key SHA512.sha512 128 k) = 128.
proof. by apply size_hmac_key => _; rewrite size_sha512. qed.

(* ------------------------------------------------------------------ *)
(* Step 9: two hashes around K0                                       *)

lemma hmac_unfold (hash : bytes -> bytes) b (k text : bytes) :
  hmac hash b k text
  = hash (xorb (hmac_key hash b k) (opad b) ++ hash (xorb (hmac_key hash b k) (ipad b) ++ text)).
proof. by rewrite /hmac. qed.

(* ------------------------------------------------------------------ *)
(* The padded blocks, byte by byte                                    *)

lemma size_xorb (x y : bytes) : size x = size y => size (xorb x y) = size x.
proof. by move=> hs; rewrite /xorb size_map size_zip /#. qed.

lemma nth_xorb (x y : bytes) j : size x = size y => 0 <= j < size x =>
  nth W8.zero (xorb x y) j = nth W8.zero x j +^ nth W8.zero y j.
proof.
move=> hs hj; rewrite /xorb (nth_map (W8.zero, W8.zero)) 1:size_zip 1:/#.
by rewrite nth_zip.
qed.

lemma size_xorb_pad (x : bytes) b c : 0 <= b => size x = b =>
  size (xorb x (nseq b c)) = b.
proof. by move=> hb hx; rewrite size_xorb ?size_nseq /#. qed.

lemma nth_xorb_pad (x : bytes) b c j : 0 <= b => size x = b => 0 <= j < b =>
  nth W8.zero (xorb x (nseq b c)) j = nth W8.zero x j +^ c.
proof. by move=> hb hx hj; rewrite nth_xorb 1:size_nseq 1,2:/# nth_nseq. qed.

(* The bytes of the code's pad words. *)
lemma mi_bits8 k : 0 <= k < 8 => W64.of_int 3906369333256140342 \bits8 k = W8.of_int 0x36.
proof.
move=> hk; rewrite W8u8.of_int_bits8_div //.
have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
by move=> [|[|[|[|[|[|[|]]]]]]] ->; apply W8.to_uint_eq; rewrite !W8.of_uintK.
qed.

lemma mo_bits8 k : 0 <= k < 8 => W64.of_int 6655295901103053916 \bits8 k = W8.of_int 0x5c.
proof.
move=> hk; rewrite W8u8.of_int_bits8_div //.
have : k = 0 \/ k = 1 \/ k = 2 \/ k = 3 \/ k = 4 \/ k = 5 \/ k = 6 \/ k = 7 by smt().
by move=> [|[|[|[|[|[|[|]]]]]]] ->; apply W8.to_uint_eq; rewrite !W8.of_uintK.
qed.
