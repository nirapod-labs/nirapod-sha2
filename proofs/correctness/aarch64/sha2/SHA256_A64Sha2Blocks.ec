(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_A64Sha2Blocks.ec (aarch64/sha2)
 * ======================================
 *
 * Functional correctness of the memory entry point
 * _sha256_compress_blocks of the AArch64 SHA-256 instruction kernel
 * (src/aarch64/sha2/sha256_compress.jinc) against FIPS 180-4 section 6.2.2
 * (spec/FIPS180_SHA2.ec). The chaining value stays in abcd and efgh from
 * block to block; each iteration loads the block's four vectors with
 * LDR q and REV32 and runs __sha256_block_a64 (SHA256_A64Sha2.ec).
 *
 * Memory is viewed through memread of crypto-specs JWordList: the byte
 * list mem.[a], ..., mem.[a + len - 1]. n blocks must end below 2^64
 * (to_uint p + 64 n < 2^64), because the kernel advances p past the last
 * block; the address arithmetic of the kernel does not wrap.
 *
 * Theorems:
 *     sha256_compress_blocks_total  _sha256_compress_blocks folds compress
 *                                   over the n blocks at p, which is the
 *                                   parse of section 5.2.1 of those bytes;
 *     sha256_compress_blocks_ll     _sha256_compress_blocks terminates.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_armv8a.
require import BArray32 BArray64 BArray256.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Sha2Insn SHA256_A64Sha2.
require JWordList.
import SHA256 A256.

(* ------------------------------------------------------------------ *)
(* Lists of eight words and the state in two registers                *)

lemma list8 (H : W32.t list) : size H = 8 =>
  H = [nth W32.zero H 0; nth W32.zero H 1; nth W32.zero H 2; nth W32.zero H 3;
       nth W32.zero H 4; nth W32.zero H 5; nth W32.zero H 6; nth W32.zero H 7].
proof.
move=> hs; apply (eq_from_nth W32.zero); first by rewrite hs.
move=> i; rewrite hs => hi.
by have := range8 i hi; case=> [|[|[|[|[|[|[|]]]]]]] ->>.
qed.

lemma size_foldl_compress (h0 : W32.t list) (bs : W32.t list list) :
  size h0 = 8 => size (foldl compress h0 bs) = 8.
proof.
elim: bs h0 => [|b bs ih] h0 hs //=.
by apply ih; rewrite size_compress.
qed.

(* One block on the two registers is compress on the list. *)
lemma st_step (H mm : W32.t list) : size H = 8 =>
  VADD_4u32 (st4a (rounds (schedule mm) (to_state H) 0 64)) (st4a (to_state H))
  = st4a (to_state (compress H mm))
  /\ VADD_4u32 (st4e (rounds (schedule mm) (to_state H) 0 64)) (st4e (to_state H))
  = st4e (to_state (compress H mm)).
proof.
move=> hs; rewrite compress_rounds /ffwd.
move: (rounds (schedule mm) (to_state H) 0 64) => S.
case: S => a b c d e f g hh.
by rewrite (list8 H hs) /to_state /of_state /= !vadd4_pack.
qed.

lemma get128_st (h : BArray32.t) :
  BArray32.get128d h 0 = st4a (to_state (hwords h))
  /\ BArray32.get128d h 16 = st4e (to_state (hwords h)).
proof.
split.
+ by have := get128_lanes h 0; rewrite /= => ->; rewrite /to_state !nth_hwords.
by have := get128_lanes h 1; rewrite /= => ->; rewrite /to_state !nth_hwords.
qed.

lemma hwords_st (h : BArray32.t) (H : W32.t list) : size H = 8 =>
  hwords (BArray32.set128d (BArray32.set128d h 0 (st4a (to_state H))) 16 (st4e (to_state H))) = H.
proof.
move=> hs; apply (eq_from_nth W32.zero); first by rewrite size_hwords hs.
move=> k; rewrite size_hwords => hk.
rewrite nth_hwords // get32_set2 // /to_state.
by have := range8 k hk; case=> [|[|[|[|[|[|[|]]]]]]] ->> /=; rewrite ?p4_0 ?p4_1 ?p4_2 ?p4_3.
qed.

(* ------------------------------------------------------------------ *)
(* Address arithmetic                                                 *)

lemma uint_add16 (p : W64.t) (j : int) : 0 <= j < 4 =>
  W64.to_uint p + 64 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (16 * j)) = W64.to_uint p + 16 * j.
proof.
move=> hj hp.
have h16 : W64.to_uint (W64.of_int (16 * j)) = 16 * j.
+ by rewrite W64.of_uintK modz_small 1:/#.
have hs : W64.to_uint p + W64.to_uint (W64.of_int (16 * j)) < W64.modulus.
+ by rewrite h16; move: hj hp; smt().
by rewrite W64.to_uintD_small // h16.
qed.

lemma nz_pos (n : W64.t) : n <> W64.zero => 0 < W64.to_uint n.
proof. by move=> hn; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp). qed.

lemma uint_sub1 (n : W64.t) : n <> W64.zero =>
  W64.to_uint (n - W64.one) = W64.to_uint n - 1.
proof.
move=> hn; rewrite W64.to_uintB.
+ by rewrite W64.uleE W64.to_uint1; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp).
by rewrite W64.to_uint1.
qed.

lemma uint_add64 (p : W64.t) : W64.to_uint p + 64 < W64.modulus =>
  W64.to_uint (p + W64.of_int 64) = W64.to_uint p + 64.
proof.
move=> hp; rewrite W64.to_uintD_small.
+ by rewrite W64.to_uint_small //; smt().
by rewrite W64.to_uint_small //; smt().
qed.

(* ------------------------------------------------------------------ *)
(* Memory as bytes                                                    *)

lemma size_memread mem a l : 0 <= l => size (JWordList.memread mem a l) = l.
proof. exact JWordList.size_memread. qed.

lemma bswap_load32 mem a :
  bswap32 (loadW32 mem a) = be32 (JWordList.memread mem a 4).
proof.
rewrite /bswap32 /be32; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W4u8.size_to_list size_memread.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW32_bits8.
qed.

lemma memread_word mem a k : 0 <= k < 16 =>
  take 4 (drop (4 * k) (JWordList.memread mem a 64)) = JWordList.memread mem (a + 4 * k) 4.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

(* The block's vector j, as LDR q and REV32 form it. *)
lemma vrev_load mem (a j : int) : 0 <= j < 4 =>
  VREV32_16u8 (loadW128 mem (a + 16 * j))
  = wv (schedule (blockwords (JWordList.memread mem a 64))) (4 * j).
proof.
move=> hj; rewrite {1}(p4_bits (VREV32_16u8 (loadW128 mem (a + 16 * j)))) /wv.
have hsz : size (JWordList.memread mem a 64) = 64 by rewrite size_memread.
have e : forall i, 0 <= i < 4 =>
  VREV32_16u8 (loadW128 mem (a + 16 * j)) \bits32 i
  = nth W32.zero (schedule (blockwords (JWordList.memread mem a 64))) (4 * j + i).
+ move=> i hi; rewrite vrev32_lane // loadW128_bits32 // bswap_load32.
  rewrite nth_schedule_lo 1:size_blockwords // 1:/# nth_blockwords // 1:/#.
  by rewrite memread_word 1:/#; congr; congr; ring.
by rewrite (e 0) // (e 1) // (e 2) // (e 3).
qed.

(* One more block of memory adds one block to the parse. *)
lemma parse_memreadS mem a k : 0 <= k =>
  parse (JWordList.memread mem a (64 * (k + 1)))
  = rcons (parse (JWordList.memread mem a (64 * k)))
          (blockwords (JWordList.memread mem (a + 64 * k) 64)).
proof.
move=> hk; rewrite /parse (_ : 64 * (k + 1) = 64 * k + 64) 1:/#.
rewrite JWordList.memread_add 1,2:/# chunk_cat; first by rewrite size_memread 1:/# dvdz_mulr.
have hne : JWordList.memread mem (a + 64 * k) 64 <> [] by rewrite -size_eq0 size_memread.
have := chunk_exact (JWordList.memread mem (a + 64 * k) 64) hne.
rewrite size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

lemma parse_memread0 mem a : parse (JWordList.memread mem a 0) = [].
proof. by rewrite /parse JWordList.memread0 /chunk /= mkseq0. qed.

(* The block lemma with the schedule of the block at a in memory. *)
lemma sha256_block_mem (s : state) mem (a : int) :
  hoare [M.__sha256_block_a64 :
           abcd = st4a s /\ efgh = st4e s /\ k = sHA256_K /\
           (forall j, 0 <= j < 4 =>
              BArray64.get128 m j = wv (schedule (blockwords (JWordList.memread mem a 64))) (4 * j)) ==>
           res.`1 = VADD_4u32 (st4a (rounds (schedule (blockwords (JWordList.memread mem a 64))) s 0 64)) (st4a s) /\
           res.`2 = VADD_4u32 (st4e (rounds (schedule (blockwords (JWordList.memread mem a 64))) s 0 64)) (st4e s)].
proof.
have hsz : size (blockwords (JWordList.memread mem a 64)) = 16.
+ by rewrite size_blockwords // size_memread.
apply (sha256_block_a64_correct s).
by move=> t ht; rewrite /srec (nth_schedule_hi _ _ hsz).
qed.

(* ------------------------------------------------------------------ *)
(* n blocks from memory                                               *)

lemma sha256_compress_blocks_correct (h0 : W32.t list) (p0 n0 : W64.t) :
  hoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))].
proof.
proc; wp.
while (0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
       W64.to_uint p = W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) /\
       W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus /\
       k = sHA256_K /\ size h0 = 8 /\
       abcd = st4a (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
                (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n)))))) /\
       efgh = st4e (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
                (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n))))))).
+ wp.
  ecall (sha256_block_mem
           (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
              (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n))))))
           Glob.mem (W64.to_uint p)).
  while (0 <= j <= 4 /\ n <> W64.zero /\
         0 <= W64.to_uint n <= W64.to_uint n0 /\ more = (n <> W64.zero) /\
         W64.to_uint p = W64.to_uint p0 + 64 * (W64.to_uint n0 - W64.to_uint n) /\
         W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus /\
         k = sHA256_K /\ size h0 = 8 /\
         abcd = st4a (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
                  (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n)))))) /\
         efgh = st4e (to_state (foldl compress h0 (parse (JWordList.memread Glob.mem
                  (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n)))))) /\
         forall i, 0 <= i < j =>
           BArray64.get128 m i = VREV32_16u8 (loadW128 Glob.mem (W64.to_uint p + 16 * i))).
  + wp; skip => /> &hr hj0 _ hnz hn0 hnn hp hb hs hm hj4.
    have hp64 : W64.to_uint p{hr} + 64 <= W64.modulus by smt(nz_pos).
    split; first smt().
    move=> i hi0 hi1.
    rewrite BArray64.get_set128E 1,2:/#.
    case: (j{hr} = i) => [<-|ne].
    + by rewrite BArray64.get_set128E 1,2:/# /= uint_add16 1:/#.
    by rewrite BArray64.get_set128E 1,2:/# ne /= hm /#.
  wp; skip => /> &hr hn0 hnn hp hb hs hnz.
  split; first smt().
  move=> j0 m0 hlt hj0 hj4 hm0.
  have hmw : forall j1, 0 <= j1 < 4 =>
    BArray64.get128 m0 j1
    = wv (schedule (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 64))) (4 * j1).
  + by move=> j1 hj1; rewrite hm0 1:/# vrev_load.
  split; first by move=> j1 hj1 hj2; apply hmw.
  move=> _ r hr1 hr2.
  have hsub := uint_sub1 n{hr} hnz.
  have hplt : W64.to_uint p{hr} + 64 < W64.modulus by smt(nz_pos).
  have hadd := uint_add64 p{hr} hplt.
  have hF := size_foldl_compress h0 (parse (JWordList.memread Glob.mem{hr}
               (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n{hr})))) hs.
  have [e1 e2] := st_step _ (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 64)) hF.
  have hpar : foldl compress h0 (parse (JWordList.memread Glob.mem{hr} (W64.to_uint p0)
                (64 * (W64.to_uint n0 - (W64.to_uint n{hr} - 1)))))
            = compress (foldl compress h0 (parse (JWordList.memread Glob.mem{hr}
                (W64.to_uint p0) (64 * (W64.to_uint n0 - W64.to_uint n{hr})))))
                (blockwords (JWordList.memread Glob.mem{hr} (W64.to_uint p{hr}) 64)).
  + rewrite (_ : W64.to_uint n0 - (W64.to_uint n{hr} - 1)
               = (W64.to_uint n0 - W64.to_uint n{hr}) + 1) 1:/#.
    by rewrite parse_memreadS 1:/# foldl_rcons hp.
  rewrite hsub hadd hr1 hr2 e1 e2 hpar /=.
  by move: (nz_pos n{hr} hnz) hnn hp; smt().
wp; skip => /> &hr hb.
have [ha he] := get128_st h{hr}.
have hp0 : parse [] = [] by rewrite /parse /chunk /= mkseq0.
rewrite ha he hp0 /=.
split; first by rewrite size_hwords /=; smt(W64.to_uint_cmp).
move=> more1 n1 p1 hm1 hn1 hn1n0 hmore hp1 _.
have hz : W64.to_uint n1 = 0.
+ by have -> : n1 = W64.zero by smt(); rewrite W64.to_uint0.
by rewrite hz /= hwords_st // size_foldl_compress // size_hwords.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

(* The outer loop counts n down to 0; the inner loops run over constant
   ranges. *)
lemma sha256_compress_blocks_ll : islossless M._sha256_compress_blocks.
proof.
proc; wp.
while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call sha256_block_a64_ll; wp.
  while (0 <= j <= 4) (4 - j); first by auto => /#.
  auto => /> &hr hnz.
  move=> j0; split; first smt().
  by move=> _ _ _; rewrite (uint_sub1 n{hr} hnz); smt().
by auto => /> n1 h0; apply W64.to_uint_eq; smt(W64.to_uint_cmp).
qed.

lemma sha256_compress_blocks_total (h0 : W32.t list) (p0 n0 : W64.t) :
  phoare [M._sha256_compress_blocks :
           hwords h = h0 /\ p = p0 /\ n = n0 /\
           W64.to_uint p0 + 64 * W64.to_uint n0 < W64.modulus ==>
           hwords res.`1
           = foldl compress h0 (parse (JWordList.memread Glob.mem (W64.to_uint p0) (64 * W64.to_uint n0)))]
  = 1%r.
proof. by conseq sha256_compress_blocks_ll (sha256_compress_blocks_correct h0 p0 n0). qed.
