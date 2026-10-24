(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * ArrayInst.ec
 * ============
 *
 * The array instances of the array test unit tests/array/array.jazz,
 * sizes 1, 64, 128 and 333, extracted as ArraySha2. For each size s,
 * Theorems.ArrayTheorems is cloned with asize <= s; every extracted
 * procedure of the instance (the byte movers, the four absorbs and the
 * four one-shot test exports) is proved equivalent to its procedure in
 * the clone's AF.F by proc; sim, and the clone's theorem is stated again
 * on the extracted procedure. The equivalences relate the instance's own
 * copies of the portable kernels, init and finalize procedures to those
 * of this unit's model, which are the same text.
 *
 * Each statement is the one of Theorems.ArrayTheorems with the size and
 * the extracted procedure filled in.
 *)

require import AllCore List IntDiv.
from Jasmin require import JWord JUtils JMemory.
require import BArray1 BArray32 BArray64 BArray128 BArray256 BArray333 BArray512.
require import Bytes FIPS180_SHA2.
require NirapodSha2 ArraySha2 ArrayForms.
require import Theorems.

(* ------------------------------------------------------------------ *)
(* Size 1                                                           *)

clone Theorems.ArrayTheorems as T1 with op asize <= 1, theory BArrayA <= BArray1
proof asize_ok by done.

equiv a1_fill64_array_eq : ArraySha2.M.a1____fill64_array ~ T1.AF.F.fill64_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_fill64_array_total (b0 : BArray64.t) (a0 : BArray1.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a1____fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 64 /\ W64.to_uint o0 + W64.to_uint n0 <= 1 ==>
           forall i, 0 <= i < 64 =>
             BArray64.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray1.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray64.get8 b0 i] = 1%r.
proof.
conseq a1_fill64_array_eq (T1.fill64_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_fill128_array_eq : ArraySha2.M.a1____fill128_array ~ T1.AF.F.fill128_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_fill128_array_total (b0 : BArray128.t) (a0 : BArray1.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a1____fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 128 /\ W64.to_uint o0 + W64.to_uint n0 <= 1 ==>
           forall i, 0 <= i < 128 =>
             BArray128.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray1.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray128.get8 b0 i] = 1%r.
proof.
conseq a1_fill128_array_eq (T1.fill128_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha256_absorb_array_eq : ArraySha2.M.a1___sha256_absorb_array ~ T1.AF.F.sha256_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha256_absorb_array_total (h0 : W32.t list) (m : bytes) (a0 : BArray1.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a1___sha256_absorb_array :
           sha256_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 1 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray1.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a1_sha256_absorb_array_eq (T1.sha256_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha512_absorb_array_eq : ArraySha2.M.a1___sha512_absorb_array ~ T1.AF.F.sha512_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha512_absorb_array_total (h0 : W64.t list) (m : bytes) (a0 : BArray1.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a1___sha512_absorb_array :
           sha512_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 1 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray1.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a1_sha512_absorb_array_eq (T1.sha512_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha256_x8_absorb_array_eq : ArraySha2.M.a1___sha256_x8_absorb_array ~ T1.AF.F.sha256_x8_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha256_x8_absorb_array_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArray1.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a1___sha256_x8_absorb_array :
           sha256_x8_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 1 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray1.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a1_sha256_x8_absorb_array_eq (T1.sha256_x8_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha512_x4_absorb_array_eq : ArraySha2.M.a1___sha512_x4_absorb_array ~ T1.AF.F.sha512_x4_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha512_x4_absorb_array_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArray1.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a1___sha512_x4_absorb_array :
           sha512_x4_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 1 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray1.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a1_sha512_x4_absorb_array_eq (T1.sha512_x4_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha256_eq : ArraySha2.M.a1__sha256 ~ T1.AF.F.sha256 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha256_total (a0 : BArray1.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a1__sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 1 /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res
           = SHA256.sha256 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray1.to_list a0)))] = 1%r.
proof.
conseq a1_sha256_eq (T1.sha256_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha512_eq : ArraySha2.M.a1__sha512 ~ T1.AF.F.sha512 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha512_total (a0 : BArray1.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a1__sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 1 /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res
           = SHA512.sha512 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray1.to_list a0)))] = 1%r.
proof.
conseq a1_sha512_eq (T1.sha512_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha256_x8_eq : ArraySha2.M.a1__sha256_x8 ~ T1.AF.F.sha256_x8 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha256_x8_total (a0 : BArray1.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a1__sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 1 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray1.to_list a0)))] = 1%r.
proof.
conseq a1_sha256_x8_eq (T1.sha256_x8_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a1_sha512_x4_eq : ArraySha2.M.a1__sha512_x4 ~ T1.AF.F.sha512_x4 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a1_sha512_x4_total (a0 : BArray1.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a1__sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 1 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray1.to_list a0)))] = 1%r.
proof.
conseq a1_sha512_x4_eq (T1.sha512_x4_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

(* ------------------------------------------------------------------ *)
(* Size 64                                                          *)

clone Theorems.ArrayTheorems as T64 with op asize <= 64, theory BArrayA <= BArray64
proof asize_ok by done.

equiv a64_fill64_array_eq : ArraySha2.M.a64____fill64_array ~ T64.AF.F.fill64_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_fill64_array_total (b0 : BArray64.t) (a0 : BArray64.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a64____fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 64 /\ W64.to_uint o0 + W64.to_uint n0 <= 64 ==>
           forall i, 0 <= i < 64 =>
             BArray64.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray64.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray64.get8 b0 i] = 1%r.
proof.
conseq a64_fill64_array_eq (T64.fill64_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_fill128_array_eq : ArraySha2.M.a64____fill128_array ~ T64.AF.F.fill128_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_fill128_array_total (b0 : BArray128.t) (a0 : BArray64.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a64____fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 128 /\ W64.to_uint o0 + W64.to_uint n0 <= 64 ==>
           forall i, 0 <= i < 128 =>
             BArray128.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray64.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray128.get8 b0 i] = 1%r.
proof.
conseq a64_fill128_array_eq (T64.fill128_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha256_absorb_array_eq : ArraySha2.M.a64___sha256_absorb_array ~ T64.AF.F.sha256_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha256_absorb_array_total (h0 : W32.t list) (m : bytes) (a0 : BArray64.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a64___sha256_absorb_array :
           sha256_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 64 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray64.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a64_sha256_absorb_array_eq (T64.sha256_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha512_absorb_array_eq : ArraySha2.M.a64___sha512_absorb_array ~ T64.AF.F.sha512_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha512_absorb_array_total (h0 : W64.t list) (m : bytes) (a0 : BArray64.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a64___sha512_absorb_array :
           sha512_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 64 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray64.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a64_sha512_absorb_array_eq (T64.sha512_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha256_x8_absorb_array_eq : ArraySha2.M.a64___sha256_x8_absorb_array ~ T64.AF.F.sha256_x8_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha256_x8_absorb_array_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArray64.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a64___sha256_x8_absorb_array :
           sha256_x8_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 64 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray64.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a64_sha256_x8_absorb_array_eq (T64.sha256_x8_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha512_x4_absorb_array_eq : ArraySha2.M.a64___sha512_x4_absorb_array ~ T64.AF.F.sha512_x4_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha512_x4_absorb_array_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArray64.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a64___sha512_x4_absorb_array :
           sha512_x4_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 64 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray64.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a64_sha512_x4_absorb_array_eq (T64.sha512_x4_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha256_eq : ArraySha2.M.a64__sha256 ~ T64.AF.F.sha256 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha256_total (a0 : BArray64.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a64__sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 64 /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res
           = SHA256.sha256 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray64.to_list a0)))] = 1%r.
proof.
conseq a64_sha256_eq (T64.sha256_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha512_eq : ArraySha2.M.a64__sha512 ~ T64.AF.F.sha512 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha512_total (a0 : BArray64.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a64__sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 64 /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res
           = SHA512.sha512 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray64.to_list a0)))] = 1%r.
proof.
conseq a64_sha512_eq (T64.sha512_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha256_x8_eq : ArraySha2.M.a64__sha256_x8 ~ T64.AF.F.sha256_x8 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha256_x8_total (a0 : BArray64.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a64__sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 64 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray64.to_list a0)))] = 1%r.
proof.
conseq a64_sha256_x8_eq (T64.sha256_x8_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a64_sha512_x4_eq : ArraySha2.M.a64__sha512_x4 ~ T64.AF.F.sha512_x4 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a64_sha512_x4_total (a0 : BArray64.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a64__sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 64 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray64.to_list a0)))] = 1%r.
proof.
conseq a64_sha512_x4_eq (T64.sha512_x4_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

(* ------------------------------------------------------------------ *)
(* Size 128                                                         *)

clone Theorems.ArrayTheorems as T128 with op asize <= 128, theory BArrayA <= BArray128
proof asize_ok by done.

equiv a128_fill64_array_eq : ArraySha2.M.a128____fill64_array ~ T128.AF.F.fill64_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_fill64_array_total (b0 : BArray64.t) (a0 : BArray128.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a128____fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 64 /\ W64.to_uint o0 + W64.to_uint n0 <= 128 ==>
           forall i, 0 <= i < 64 =>
             BArray64.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray128.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray64.get8 b0 i] = 1%r.
proof.
conseq a128_fill64_array_eq (T128.fill64_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_fill128_array_eq : ArraySha2.M.a128____fill128_array ~ T128.AF.F.fill128_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_fill128_array_total (b0 : BArray128.t) (a0 : BArray128.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a128____fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 128 /\ W64.to_uint o0 + W64.to_uint n0 <= 128 ==>
           forall i, 0 <= i < 128 =>
             BArray128.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray128.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray128.get8 b0 i] = 1%r.
proof.
conseq a128_fill128_array_eq (T128.fill128_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha256_absorb_array_eq : ArraySha2.M.a128___sha256_absorb_array ~ T128.AF.F.sha256_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha256_absorb_array_total (h0 : W32.t list) (m : bytes) (a0 : BArray128.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a128___sha256_absorb_array :
           sha256_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 128 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray128.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a128_sha256_absorb_array_eq (T128.sha256_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha512_absorb_array_eq : ArraySha2.M.a128___sha512_absorb_array ~ T128.AF.F.sha512_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha512_absorb_array_total (h0 : W64.t list) (m : bytes) (a0 : BArray128.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a128___sha512_absorb_array :
           sha512_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 128 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray128.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a128_sha512_absorb_array_eq (T128.sha512_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha256_x8_absorb_array_eq : ArraySha2.M.a128___sha256_x8_absorb_array ~ T128.AF.F.sha256_x8_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha256_x8_absorb_array_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArray128.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a128___sha256_x8_absorb_array :
           sha256_x8_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 128 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray128.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a128_sha256_x8_absorb_array_eq (T128.sha256_x8_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha512_x4_absorb_array_eq : ArraySha2.M.a128___sha512_x4_absorb_array ~ T128.AF.F.sha512_x4_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha512_x4_absorb_array_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArray128.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a128___sha512_x4_absorb_array :
           sha512_x4_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 128 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray128.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a128_sha512_x4_absorb_array_eq (T128.sha512_x4_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha256_eq : ArraySha2.M.a128__sha256 ~ T128.AF.F.sha256 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha256_total (a0 : BArray128.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a128__sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 128 /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res
           = SHA256.sha256 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray128.to_list a0)))] = 1%r.
proof.
conseq a128_sha256_eq (T128.sha256_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha512_eq : ArraySha2.M.a128__sha512 ~ T128.AF.F.sha512 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha512_total (a0 : BArray128.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a128__sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 128 /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res
           = SHA512.sha512 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray128.to_list a0)))] = 1%r.
proof.
conseq a128_sha512_eq (T128.sha512_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha256_x8_eq : ArraySha2.M.a128__sha256_x8 ~ T128.AF.F.sha256_x8 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha256_x8_total (a0 : BArray128.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a128__sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 128 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray128.to_list a0)))] = 1%r.
proof.
conseq a128_sha256_x8_eq (T128.sha256_x8_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a128_sha512_x4_eq : ArraySha2.M.a128__sha512_x4 ~ T128.AF.F.sha512_x4 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a128_sha512_x4_total (a0 : BArray128.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a128__sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 128 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray128.to_list a0)))] = 1%r.
proof.
conseq a128_sha512_x4_eq (T128.sha512_x4_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

(* ------------------------------------------------------------------ *)
(* Size 333                                                         *)

clone Theorems.ArrayTheorems as T333 with op asize <= 333, theory BArrayA <= BArray333
proof asize_ok by done.

equiv a333_fill64_array_eq : ArraySha2.M.a333____fill64_array ~ T333.AF.F.fill64_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_fill64_array_total (b0 : BArray64.t) (a0 : BArray333.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a333____fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 64 /\ W64.to_uint o0 + W64.to_uint n0 <= 333 ==>
           forall i, 0 <= i < 64 =>
             BArray64.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray333.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray64.get8 b0 i] = 1%r.
proof.
conseq a333_fill64_array_eq (T333.fill64_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_fill128_array_eq : ArraySha2.M.a333____fill128_array ~ T333.AF.F.fill128_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_fill128_array_total (b0 : BArray128.t) (a0 : BArray333.t) (d0 o0 n0 : W64.t) :
  phoare [ArraySha2.M.a333____fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           W64.to_uint d0 + W64.to_uint n0 <= 128 /\ W64.to_uint o0 + W64.to_uint n0 <= 333 ==>
           forall i, 0 <= i < 128 =>
             BArray128.get8 res.`1 i
             = if W64.to_uint d0 <= i < W64.to_uint d0 + W64.to_uint n0
               then BArray333.get8 a0 (W64.to_uint o0 + (i - W64.to_uint d0))
               else BArray128.get8 b0 i] = 1%r.
proof.
conseq a333_fill128_array_eq (T333.fill128_array_total b0 a0 d0 o0 n0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha256_absorb_array_eq : ArraySha2.M.a333___sha256_absorb_array ~ T333.AF.F.sha256_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha256_absorb_array_total (h0 : W32.t list) (m : bytes) (a0 : BArray333.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a333___sha256_absorb_array :
           sha256_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 333 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha256_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray333.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a333_sha256_absorb_array_eq (T333.sha256_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha512_absorb_array_eq : ArraySha2.M.a333___sha512_absorb_array ~ T333.AF.F.sha512_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha512_absorb_array_total (h0 : W64.t list) (m : bytes) (a0 : BArray333.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a333___sha512_absorb_array :
           sha512_state h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 333 /\ size m + W64.to_uint l0 < W64.modulus ==>
           sha512_state h0 (m ++ take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray333.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a333_sha512_absorb_array_eq (T333.sha512_absorb_array_total h0 m a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha256_x8_absorb_array_eq : ArraySha2.M.a333___sha256_x8_absorb_array ~ T333.AF.F.sha256_x8_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha256_x8_absorb_array_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArray333.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a333___sha256_x8_absorb_array :
           sha256_x8_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 333 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha256_x8_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray333.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a333_sha256_x8_absorb_array_eq (T333.sha256_x8_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha512_x4_absorb_array_eq : ArraySha2.M.a333___sha512_x4_absorb_array ~ T333.AF.F.sha512_x4_absorb_array : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha512_x4_absorb_array_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArray333.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a333___sha512_x4_absorb_array :
           sha512_x4_state h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 333 /\
           W64.to_uint total + W64.to_uint l0 < W64.modulus ==>
           sha512_x4_state h0
             (fun k => ms0 k ++ take (W64.to_uint l0)
                         (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray333.to_list a0)))
             res.`1 res.`2 res.`3] = 1%r.
proof.
conseq a333_sha512_x4_absorb_array_eq (T333.sha512_x4_absorb_array_total h0 ms0 a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha256_eq : ArraySha2.M.a333__sha256 ~ T333.AF.F.sha256 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha256_total (a0 : BArray333.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a333__sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 333 /\ W64.to_uint l0 < 2^61 ==>
           BArray32.to_list res
           = SHA256.sha256 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray333.to_list a0)))] = 1%r.
proof.
conseq a333_sha256_eq (T333.sha256_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha512_eq : ArraySha2.M.a333__sha512 ~ T333.AF.F.sha512 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha512_total (a0 : BArray333.t) (o0 l0 : W64.t) :
  phoare [ArraySha2.M.a333__sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\
           W64.to_uint o0 + W64.to_uint l0 <= 333 /\ W64.to_uint l0 < 2^61 ==>
           BArray64.to_list res
           = SHA512.sha512 (take (W64.to_uint l0) (drop (W64.to_uint o0) (BArray333.to_list a0)))] = 1%r.
proof.
conseq a333_sha512_eq (T333.sha512_total a0 o0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha256_x8_eq : ArraySha2.M.a333__sha256_x8 ~ T333.AF.F.sha256_x8 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha256_x8_total (a0 : BArray333.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a333__sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 7 * W64.to_uint s0 + W64.to_uint l0 <= 333 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             take 32 (drop (32 * k) (BArray256.to_list res))
             = SHA256.sha256 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray333.to_list a0)))] = 1%r.
proof.
conseq a333_sha256_x8_eq (T333.sha256_x8_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.

equiv a333_sha512_x4_eq : ArraySha2.M.a333__sha512_x4 ~ T333.AF.F.sha512_x4 : ={arg} ==> ={res}.
proof. by proc; sim. qed.
lemma a333_sha512_x4_total (a0 : BArray333.t) (o0 s0 l0 : W64.t) :
  phoare [ArraySha2.M.a333__sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           W64.to_uint o0 + 3 * W64.to_uint s0 + W64.to_uint l0 <= 333 /\ W64.to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             take 64 (drop (64 * k) (BArray256.to_list res))
             = SHA512.sha512 (take (W64.to_uint l0)
                 (drop (W64.to_uint o0 + k * W64.to_uint s0) (BArray333.to_list a0)))] = 1%r.
proof.
conseq a333_sha512_x4_eq (T333.sha512_x4_total a0 o0 s0 l0) => [&1 h | /#].
by exists arg{1}.
qed.
