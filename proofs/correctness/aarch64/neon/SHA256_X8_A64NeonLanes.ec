(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * SHA256_X8_A64NeonLanes.ec (aarch64/neon)
 * ========================================
 *
 * Functional correctness, lane by lane, of _sha256_x8_compress_lanes of
 * the AArch64 Advanced SIMD 8-way SHA-256 kernel
 * (src/aarch64/neon/sha256_x8_compress.jinc): lane k absorbs the n blocks
 * that start at in[k] + off in memory, so it ends with the fold of compress
 * over them.
 *
 * Each iteration loads block j of lanes 4x .. 4x + 3 with
 * __sha256_x8_load_lanes, the memory form of the loads of
 * _sha256_x8_compress (SHA256_X8_A64Neon.ec): slot i of the four blocks,
 * byte-reversed and transposed by __sha256_x8_rows, becomes
 * w[16x + 4i .. 16x + 4i + 3]. _sha256_x8_block (SHA256_X8_A64NeonBlock.ec)
 * then runs one block on all eight lanes. After j iterations off = o + 64j
 * and lane k holds the fold over its first j blocks (Fo).
 *
 * Domain: for every lane k < 8, in[k] + off + 64 n < 2^64, so no lane's
 * buffer wraps the address space (bnd).
 *
 * Theorems:
 *     n8_load_lanes_correct              the loads of one half;
 *     sha256_x8_compress_lanes_correct   lane k of the result is the fold
 *                                        of compress over lane k's blocks
 *                                        (partial correctness);
 *     sha256_x8_compress_lanes_ll,       termination, and the same with
 *     sha256_x8_compress_lanes_total     termination.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory JModel_armv8a.
require import BArray64 BArray256 BArray512.
require import NirapodSha2 WordSpec.
require import Bytes FIPS180_SHA2 Rounds256 Vec Lanes.
require import SHA256_X8_A64NeonRound SHA256_X8_A64NeonBlock SHA256_X8_A64Neon.
require JWordList.
import SHA256.

(* ------------------------------------------------------------------ *)
(* Memory as bytes                                                    *)

lemma n8l_size_memread mem a l : 0 <= l => size (JWordList.memread mem a l) = l.
proof. exact JWordList.size_memread. qed.

lemma n8l_bswap_load32 mem a :
  bswap32 (loadW32 mem a) = be32 (JWordList.memread mem a 4).
proof.
rewrite /bswap32 /be32; do 3!congr.
apply (eq_from_nth (W8.of_int 0)); first by rewrite W4u8.size_to_list n8l_size_memread.
move=> j; rewrite W4u8.size_to_list => hj.
rewrite W4u8.nth_to_list /JWordList.memread nth_mkseq //=.
by rewrite loadW32_bits8.
qed.

lemma n8l_memread_word mem a k : 0 <= k < 16 =>
  take 4 (drop (4 * k) (JWordList.memread mem a 64)) = JWordList.memread mem (a + 4 * k) 4.
proof.
move=> hk; rewrite /JWordList.memread drop_mkseq 1:/# take_mkseq 1:/#.
by apply eq_mkseq => x /=; rewrite addzA.
qed.

(* One more block of memory adds one block to the parse. *)
lemma n8l_parse_memreadS mem a k : 0 <= k =>
  parse (JWordList.memread mem a (64 * (k + 1)))
  = rcons (parse (JWordList.memread mem a (64 * k)))
          (blockwords (JWordList.memread mem (a + 64 * k) 64)).
proof.
move=> hk; rewrite /parse (_ : 64 * (k + 1) = 64 * k + 64) 1:/#.
rewrite JWordList.memread_add 1,2:/# chunk_cat; first by rewrite n8l_size_memread 1:/# dvdz_mulr.
have hne : JWordList.memread mem (a + 64 * k) 64 <> [] by rewrite -size_eq0 n8l_size_memread.
have := chunk_exact (JWordList.memread mem (a + 64 * k) 64) hne.
rewrite n8l_size_memread // => ->.
by rewrite map_cat /= cats1.
qed.

lemma n8l_uint_add16 (p : W64.t) (i : int) : 0 <= i < 4 =>
  W64.to_uint p + 64 <= W64.modulus =>
  W64.to_uint (p + W64.of_int (16 * i)) = W64.to_uint p + 16 * i.
proof.
move=> hi hp.
have h16 : W64.to_uint (W64.of_int (16 * i)) = 16 * i.
+ by rewrite W64.of_uintK modz_small 1:/#.
have hs : W64.to_uint p + W64.to_uint (W64.of_int (16 * i)) < W64.modulus.
+ by rewrite h16; move: hi hp; smt().
by rewrite W64.to_uintD_small // h16.
qed.

(* Word 4i + kk of the block at a, as LDR q, REV32 and the transpose
   read it. *)
lemma n8l_load (mem : global_mem_t) (p : W64.t) (i kk : int) :
  W64.to_uint p + 64 <= W64.modulus => 0 <= i < 4 => 0 <= kk < 4 =>
  bswap32 (loadW128 mem (W64.to_uint (p + W64.of_int (16 * i))) \bits32 kk)
  = nth W32.zero (blockwords (JWordList.memread mem (W64.to_uint p) 64)) (4 * i + kk).
proof.
move=> hq hi hkk.
rewrite (n8l_uint_add16 p i hi hq) loadW128_bits32 // n8l_bswap_load32.
rewrite nth_blockwords 1:n8l_size_memread // 1:/# n8l_memread_word 1:/#.
by congr; congr; ring.
qed.

(* ------------------------------------------------------------------ *)
(* Lanes over memory                                                  *)

(* Start of lane k's blocks. *)
op addr (P : BArray64.t) (o : W64.t) (k : int) : int = W64.to_uint (BArray64.get64 P k + o).

(* No lane's buffer wraps the address space. *)
op bnd (P : BArray64.t) (o n : W64.t) =
  forall k, 0 <= k < 8 => addr P o k + 64 * W64.to_uint n < W64.modulus.

(* Lane k after its first j blocks. *)
op Fo (H : BArray256.t) mem (P : BArray64.t) (o : W64.t) (k j : int) : W32.t list =
  foldl compress (lane8 (BArray256.get32 H) k)
        (parse (JWordList.memread mem (addr P o k) (64 * j))).

lemma n8l_Fo0 H mem P o k : Fo H mem P o k 0 = lane8 (BArray256.get32 H) k.
proof. by rewrite /Fo /= (_ : parse [] = []) // /parse /chunk /= mkseq0. qed.

lemma n8l_FoS H mem P o k j : 0 <= j =>
  compress (Fo H mem P o k j) (blockwords (JWordList.memread mem (addr P o k + 64 * j) 64))
  = Fo H mem P o k (j + 1).
proof. by move=> hj; rewrite /Fo n8l_parse_memreadS // foldl_rcons. qed.

(* Block j of every lane. *)
op Mj mem (P : BArray64.t) (o : W64.t) (j k : int) : W32.t list =
  blockwords (JWordList.memread mem (addr P o k + 64 * j) 64).

lemma n8l_size_Mj mem P o j : forall k, 0 <= k < 8 => size (Mj mem P o j k) = 16.
proof. by move=> k hk; rewrite /Mj size_blockwords // n8l_size_memread. qed.

(* p + off, with off = o + 64j, is the start of block j of the lane. *)
lemma n8l_addr (P : BArray64.t) (o : W64.t) k j : 0 <= j =>
  addr P o k + 64 * j < W64.modulus =>
  W64.to_uint (BArray64.get64 P k + (o + W64.of_int (64 * j))) = addr P o k + 64 * j.
proof.
move=> hj hb.
have hp := W64.to_uint_cmp (BArray64.get64 P k + o).
have h64 : W64.to_uint (W64.of_int (64 * j)) = 64 * j.
+ by rewrite W64.of_uintK modz_small; move: hb; rewrite /addr; smt().
have hs : W64.to_uint (BArray64.get64 P k + o) + W64.to_uint (W64.of_int (64 * j)) < W64.modulus.
+ by rewrite h64; move: hb; rewrite /addr.
by rewrite addrA W64.to_uintD_small // h64.
qed.

lemma n8l_nz_pos (n : W64.t) : n <> W64.zero => 0 < W64.to_uint n.
proof. by move=> hn; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp). qed.

lemma n8l_uint_sub1 (n : W64.t) : n <> W64.zero =>
  W64.to_uint (n - W64.one) = W64.to_uint n - 1.
proof.
move=> hn; rewrite W64.to_uintB.
+ by rewrite W64.uleE W64.to_uint1; smt(W64.to_uint_eq W64.to_uint0 W64.to_uint_cmp).
by rewrite W64.to_uint1.
qed.

lemma n8l_off (o : W64.t) j :
  o + W64.of_int (64 * j) + W64.of_int 64 = o + W64.of_int (64 * (j + 1)).
proof. by rewrite -addrA -W64.of_intD; congr; congr; ring. qed.

(* ------------------------------------------------------------------ *)
(* The loads of one half                                              *)

lemma n8_load_lanes_correct (w0 : BArray512.t) (x0 : int) mem (a0 a1 a2 a3 : int) :
  hoare [M.__sha256_x8_load_lanes :
           w = w0 /\ x = x0 /\ 0 <= x0 < 2 /\ Glob.mem = mem /\
           W64.to_uint p0 = a0 /\ W64.to_uint p1 = a1 /\ W64.to_uint p2 = a2 /\ W64.to_uint p3 = a3 /\
           a0 + 64 <= W64.modulus /\ a1 + 64 <= W64.modulus /\
           a2 + 64 <= W64.modulus /\ a3 + 64 <= W64.modulus ==>
           (forall j c, 0 <= j < 16 => 0 <= c < 4 =>
              BArray512.get128 res (16 * x0 + j) \bits32 c
              = nth W32.zero (blockwords (JWordList.memread mem (nth 0 [a0; a1; a2; a3] c) 64)) j) /\
           (forall x' j, 0 <= x' < 2 => x' <> x0 => 0 <= j < 16 =>
              BArray512.get128 res (16 * x' + j) = BArray512.get128 w0 (16 * x' + j))].
proof.
proc.
while (0 <= i <= 4 /\ x = x0 /\ 0 <= x0 < 2 /\ Glob.mem = mem /\
       W64.to_uint p0 = a0 /\ W64.to_uint p1 = a1 /\ W64.to_uint p2 = a2 /\ W64.to_uint p3 = a3 /\
       a0 + 64 <= W64.modulus /\ a1 + 64 <= W64.modulus /\
       a2 + 64 <= W64.modulus /\ a3 + 64 <= W64.modulus /\
       (forall j c, 0 <= j < 4 * i => 0 <= c < 4 =>
          BArray512.get128 w (16 * x0 + j) \bits32 c
          = nth W32.zero (blockwords (JWordList.memread mem (nth 0 [a0; a1; a2; a3] c) 64)) j) /\
       (forall x' j, 0 <= x' < 2 => x' <> x0 => 0 <= j < 16 =>
          BArray512.get128 w (16 * x' + j) = BArray512.get128 w0 (16 * x' + j))).
+ unroll for 7; wp; ecall (n8_rows_correct r); wp.
  skip => &hr [#] hi0 hi4 ->> hx0 hx1 ->> <<- <<- <<- <<- ha0 ha1 ha2 ha3 hw hfr hlt /= r hr.
  have hi4' : 0 <= i{hr} < 4 by split.
  have hrow : forall kk c, 0 <= kk < 4 => 0 <= c < 4 =>
    BArray64.get128 r kk \bits32 c
    = nth W32.zero (blockwords (JWordList.memread mem
        (nth 0 [W64.to_uint p0{hr}; W64.to_uint p1{hr}; W64.to_uint p2{hr}; W64.to_uint p3{hr}] c) 64))
          (4 * i{hr} + kk).
  + move=> kk c hkk hc; rewrite hr //.
    by case: (n8_c4 c hc) => [|[|[|]]] ->> /=; rewrite n8l_load.
  clear hr.
  have hi' : 0 <= i{hr} + 1 && i{hr} + 1 <= 4 by split; [move: hi0 => /# | move: hlt => /#].
  rewrite hi' hx0 hx1 ha0 ha1 ha2 ha3 /=; split.
  + move=> j c hj hc; rewrite n8_w4 1..4:/#.
    case: (4 * i{hr} <= j < 4 * i{hr} + 4) => h /=; last by apply hw => // /#.
    have : j - 4 * i{hr} = 0 \/ j - 4 * i{hr} = 1 \/ j - 4 * i{hr} = 2 \/ j - 4 * i{hr} = 3 by smt().
    case=> [e|[e|[e|e]]]; rewrite e /=;
      [rewrite (hrow 0 c) // | rewrite (hrow 1 c) // | rewrite (hrow 2 c) // | rewrite (hrow 3 c) //];
      by congr; smt().
  move=> x' j hx' hne hj; rewrite n8_w4 1..4:/#.
  by rewrite ifF 1:/# hfr.
wp; skip => &hr [#] hw0 hx hx0 hx1 hm hp0 hp1 hp2 hp3 ha0 ha1 ha2 ha3 /=.
split; first by rewrite hx hm hp0 hp1 hp2 hp3 hw0 /=; do! split => // /#.
move=> i0 w1 hi [#] hi0 hi4 _ _ _ _ _ _ _ _ _ _ _ _ hw hfr.
have ->> : i0 = 4 by smt().
by split; [move=> j c hj hc; apply hw => // /# | move=> x' j hx' hne hj; rewrite hfr // hw0].
qed.

lemma n8_load_lanes_ll : islossless M.__sha256_x8_load_lanes.
proof.
proc; while (0 <= i <= 4) (4 - i).
+ move=> z; wp; while (0 <= k <= 4) (4 - k); first by auto => /#.
  by wp; call n8_rows_ll; auto => /#.
by auto => /#.
qed.

(* ------------------------------------------------------------------ *)
(* The kernel entry point on eight lanes of blocks in memory          *)

lemma n8l_ne01 : 0 <> 1 by done.

lemma n8l_jj (n0 n : W64.t) : n <> W64.zero => W64.to_uint n <= W64.to_uint n0 =>
  0 <= W64.to_uint n0 - W64.to_uint n /\ W64.to_uint n0 - W64.to_uint n + 1 <= W64.to_uint n0.
proof. by move=> hn hle; have := n8l_nz_pos n hn; smt(W64.to_uint_cmp). qed.

lemma n8l_bk (P : BArray64.t) (o n0 : W64.t) j k : bnd P o n0 => 0 <= k < 8 =>
  0 <= j => j + 1 <= W64.to_uint n0 =>
  addr P o k + 64 * j + 64 <= W64.modulus /\ addr P o k + 64 * j < W64.modulus.
proof. by move=> hb hk hj hjn; have := hb k hk; smt(). qed.

lemma sha256_x8_compress_lanes_correct (H : BArray256.t) (P : BArray64.t) (o n0 : W64.t) :
  hoare [M._sha256_x8_compress_lanes :
           h8 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd P o n0 ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray64.get64 P k + o)) (64 * W64.to_uint n0)))].
proof.
proc.
wp.
while (in_0 = P /\ bnd P o n0 /\ more = (n <> W64.zero) /\ W64.to_uint n <= W64.to_uint n0 /\
       off = o + W64.of_int (64 * (W64.to_uint n0 - W64.to_uint n)) /\
       forall k, 0 <= k < 8 =>
         lane8 (BArray256.get32 h8) k = Fo H Glob.mem P o k (W64.to_uint n0 - W64.to_uint n)).
+ wp.
  ecall (n8_block_correct h8 (Mj Glob.mem P o (W64.to_uint n0 - W64.to_uint n))
           (n8l_size_Mj Glob.mem P o (W64.to_uint n0 - W64.to_uint n))).
  ecall (n8_load_lanes_correct w 1 Glob.mem
           (addr P o 4 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 5 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 6 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 7 + 64 * (W64.to_uint n0 - W64.to_uint n))).
  ecall (n8_load_lanes_correct w 0 Glob.mem
           (addr P o 0 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 1 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 2 + 64 * (W64.to_uint n0 - W64.to_uint n))
           (addr P o 3 + 64 * (W64.to_uint n0 - W64.to_uint n))).
  wp; skip => &hr [#] -> hb hmore hn hoff hl hm /=.
  rewrite /SLH64.protect_64 /SLH64.protect_ptr /=.
  have hn0 : n{hr} <> W64.zero by rewrite -hmore.
  have [hj0 hjn] := n8l_jj n0 n{hr} hn0 hn.
  have hak : forall k, 0 <= k < 8 =>
    W64.to_uint (BArray64.get64 P k + off{hr})
    = addr P o k + 64 * (W64.to_uint n0 - W64.to_uint n{hr}).
  + move=> k hk; rewrite hoff n8l_addr //.
    by have [_ ->] := n8l_bk P o n0 (W64.to_uint n0 - W64.to_uint n{hr}) k hb hk hj0 hjn.
  have hbk : forall k, 0 <= k < 8 =>
    addr P o k + 64 * (W64.to_uint n0 - W64.to_uint n{hr}) + 64 <= W64.modulus.
  + by move=> k hk; have [-> _] := n8l_bk P o n0 (W64.to_uint n0 - W64.to_uint n{hr}) k hb hk hj0 hjn.
  have /= e0 := hak 0 _; first done. have /= e1 := hak 1 _; first done.
  have /= e2 := hak 2 _; first done. have /= e3 := hak 3 _; first done.
  have /= e4 := hak 4 _; first done. have /= e5 := hak 5 _; first done.
  have /= e6 := hak 6 _; first done. have /= e7 := hak 7 _; first done.
  rewrite e0 e1 e2 e3 !hbk //=.
  move=> w1 [hw1 hf1].
  rewrite e4 e5 e6 e7 //=.
  move=> w2 [hw2 hf2]; split.
  + move=> x j c hx hj hc; case: (n8_c2 x hx) => ->> /=.
    + have /= -> := hf2 0 j n8_x0 n8l_ne01 hj.
      by rewrite hw1 //; case: (n8_c4 c hc) => [|[|[|]]] ->>.
    by rewrite hw2 //; case: (n8_c4 c hc) => [|[|[|]]] ->>.
  move=> _ r hres; rewrite n8l_uint_sub1 //.
  have ejj : W64.to_uint n0 - (W64.to_uint n{hr} - 1) = (W64.to_uint n0 - W64.to_uint n{hr}) + 1 by ring.
  rewrite ejj hoff n8l_off /=; split; first done. split; first smt().
  move=> k hk; rewrite (hres k hk) (hl k hk) /Mj n8l_FoS //.
wp; skip => &hr [#] -> -> -> -> hb /=.
split.
+ split; first done.
  by move=> k hk; rewrite n8l_Fo0.
move=> h8_0 in_0_0 more0 n1 off0 hmore [#] _ _ hm hn1 _ hl k hk.
have hz : n1 = W64.zero by move: hmore; rewrite hm.
by rewrite (hl k hk) hz W64.to_uint0 /= /Fo /addr.
qed.

(* ------------------------------------------------------------------ *)
(* Termination and total correctness                                  *)

lemma sha256_x8_compress_lanes_ll : islossless M._sha256_x8_compress_lanes.
proof.
proc; wp; while (more = (n <> W64.zero)) (W64.to_uint n).
+ move=> z; wp; call n8_block_ll; call n8_load_lanes_ll; call n8_load_lanes_ll; wp; skip.
  move=> &m [[hm hg] hn]; rewrite /SLH64.protect_64 /=.
  have hn0 : n{m} <> W64.zero by rewrite -hm.
  by rewrite n8l_uint_sub1 //; smt().
auto => /> n1.
by rewrite W64.to_uint_eq /=; smt(W64.to_uint_cmp).
qed.

lemma sha256_x8_compress_lanes_total (H : BArray256.t) (P : BArray64.t) (o n0 : W64.t) :
  phoare [M._sha256_x8_compress_lanes :
           h8 = H /\ in_0 = P /\ off = o /\ n = n0 /\ bnd P o n0 ==>
           forall k, 0 <= k < 8 =>
             lane8 (BArray256.get32 res.`1) k
             = foldl compress (lane8 (BArray256.get32 H) k)
                 (parse (JWordList.memread Glob.mem
                    (W64.to_uint (BArray64.get64 P k + o)) (64 * W64.to_uint n0)))] = 1%r.
proof. by conseq sha256_x8_compress_lanes_ll (sha256_x8_compress_lanes_correct H P o n0). qed.
