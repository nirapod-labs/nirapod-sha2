(*
 * SPDX-FileCopyrightText: nirapod-sha2 contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * ArrayForms.ec
 * =============
 *
 * Functional correctness of the array forms, src/fill_ASIZE.jinc,
 * src/sha256_ASIZE.jinc, src/sha512_ASIZE.jinc, src/sha256_x8_ASIZE.jinc
 * and src/sha512_x4_ASIZE.jinc, for any array size.
 *
 * Those files are instantiated inside a namespace that sets param int
 * _ASIZE, so each instance is its own copy of the same text over a
 * u8[_ASIZE] array. The abstract theory ArrayForm below takes the size as
 * an operator asize and the array as a clone of ByteArray of that size,
 * and its module F is the instance text as jasmin2ec extracts it, with
 * the array type left abstract: fill64_array, fill128_array, the four
 * absorbs, and the four one-shot hashes of tests/array/array.jazz built
 * from them. F calls the unit's kernels and its init and finalize
 * procedures through M, so the theorems hold for whichever kernel a unit
 * builds in, through K256, K512, KX8 and KX4 alone.
 *
 * An instance of size s is checked by cloning ArrayForm with asize <= s
 * and the s-byte array theory, and proving its extracted procedures
 * equivalent to those of F; the equivalence is what ties F to the text
 * that ships. correctness/units/<unit>/ArrayInst.ec does this for the
 * array test unit tests/array/array.jazz, sizes 1, 64, 128 and 333.
 *
 * The bytes the absorbs take are abytes a off len, the len cells of a
 * from off on; abytesE equates it with take len (drop off (to_list a)).
 *
 * Domain: off + len <= asize (multi-way: off + 7 stride + len <= asize),
 * asize < 2^64, and the stream length below 2^64 after the call.
 *)

require import AllCore List IntDiv StdOrder.
import IntOrder.
require BitEncoding.
import BitEncoding.BitChunking.
from Jasmin require import JWord JUtils JMemory Jslh JByte_array.
import SLH64.
require import BArray32 BArray64 BArray128 BArray256 BArray512 SBArray512_64 SBArray512_128.
require import NirapodSha2.
require import Bytes FIPS180_SHA2 StreamSpec SafetyLib State Fill Lanes SHA256_Stream SHA512_Stream.
require SHA256_X8 SHA512_X4 K256 K512 KX8 KX4.

(* ------------------------------------------------------------------ *)
(* One step of an absorb loop                                         *)

(* The count the loop body takes: what is left of the block, or of the
   input if that is shorter. *)
lemma step_count (f l : W64.t) : to_uint f < 64 => l <> W64.zero =>
  let n = if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f in
     to_uint n = min (to_uint l) (64 - to_uint f) /\ 1 <= to_uint n
  /\ to_uint (f + n) = to_uint f + to_uint n /\ to_uint (l - n) = to_uint l - to_uint n
  /\ to_uint (l - n) < to_uint l /\ to_uint (f + n) <= 64.
proof.
move=> hf hl /=; have hl1 := nonzero l hl.
have hs : to_uint (W64.of_int 64 - f) = 64 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
have hn : to_uint (if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f)
          = min (to_uint l) (64 - to_uint f).
+ by case: (l \ult W64.of_int 64 - f); rewrite W64.ultE hs /#.
rewrite hn; split; first done.
split; first smt().
have hfn : to_uint (f + (if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f))
           = to_uint f + min (to_uint l) (64 - to_uint f).
+ by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
have hln : to_uint (l - (if l \ult W64.of_int 64 - f then l else W64.of_int 64 - f))
           = to_uint l - min (to_uint l) (64 - to_uint f).
+ by rewrite W64.to_uintB 1:W64.uleE hn; smt().
by rewrite hfn hln; smt().
qed.

lemma step_count128 (f l : W64.t) : to_uint f < 128 => l <> W64.zero =>
  let n = if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f in
     to_uint n = min (to_uint l) (128 - to_uint f) /\ 1 <= to_uint n
  /\ to_uint (f + n) = to_uint f + to_uint n /\ to_uint (l - n) = to_uint l - to_uint n
  /\ to_uint (l - n) < to_uint l /\ to_uint (f + n) <= 128.
proof.
move=> hf hl /=; have hl1 := nonzero l hl.
have hs : to_uint (W64.of_int 128 - f) = 128 - to_uint f.
+ by rewrite W64.to_uintB 1:W64.uleE /= 1:/#.
have hn : to_uint (if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f)
          = min (to_uint l) (128 - to_uint f).
+ by case: (l \ult W64.of_int 128 - f); rewrite W64.ultE hs /#.
rewrite hn; split; first done.
split; first smt().
have hfn : to_uint (f + (if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f))
           = to_uint f + min (to_uint l) (128 - to_uint f).
+ by rewrite W64.to_uintD_small hn; smt(W64.to_uint_cmp).
have hln : to_uint (l - (if l \ult W64.of_int 128 - f then l else W64.of_int 128 - f))
           = to_uint l - min (to_uint l) (128 - to_uint f).
+ by rewrite W64.to_uintB 1:W64.uleE hn; smt().
by rewrite hfn hln; smt().
qed.

(* The words of one step: the offset and the remaining length move by n
   without wrapping, and the fill grows by n. *)
lemma step_words (o0 l0 off len fill n : W64.t) b :
  0 <= to_uint off - to_uint o0 => to_uint len = to_uint l0 - (to_uint off - to_uint o0) =>
  to_uint o0 + to_uint l0 < 18446744073709551616 =>
  to_uint n = min (to_uint len) (b - to_uint fill) => to_uint fill < b => b <= 128 =>
     to_uint (off + n) = to_uint off + to_uint n /\ to_uint (len - n) = to_uint len - to_uint n
  /\ to_uint (fill + n) = to_uint fill + to_uint n
  /\ (0 <= to_uint off + to_uint n - to_uint o0 <= to_uint l0)
  /\ to_uint len - to_uint n = to_uint l0 - (to_uint off + to_uint n - to_uint o0).
proof.
move=> hc hl hb hn hf hb128.
have hn0 := W64.to_uint_cmp n; have hf0 := W64.to_uint_cmp fill.
split; first by rewrite W64.to_uintD_small; smt().
split; first by rewrite W64.to_uintB 1:W64.uleE; smt().
split; first by rewrite W64.to_uintD_small; smt().
smt().
qed.

(* Lane k of q reads n bytes at off + k s, inside the array of A bytes. *)
lemma lane_bounds (o0 l0 off len fill n src s0 : W64.t) k (A b q : int) :
  0 <= k < q => to_uint src = to_uint off + k * to_uint s0 =>
  0 <= to_uint off - to_uint o0 => to_uint len = to_uint l0 - (to_uint off - to_uint o0) =>
  to_uint n = min (to_uint len) (b - to_uint fill) =>
  to_uint o0 + (q - 1) * to_uint s0 + to_uint l0 <= A => A < 18446744073709551616 =>
     to_uint fill + to_uint n <= b /\ to_uint src + to_uint n <= A
  /\ (k + 1 < q => to_uint (src + s0) = to_uint off + (k + 1) * to_uint s0).
proof.
move=> hk hsrc hc hl hn hA hA2.
have hs0 := W64.to_uint_cmp s0; have hn0 := W64.to_uint_cmp n.
have hks : k * to_uint s0 <= (q - 1) * to_uint s0 by apply ler_wpmul2r; smt().
split; first smt().
split; first smt().
move=> hk1; have hks1 : (k + 1) * to_uint s0 <= (q - 1) * to_uint s0 by apply ler_wpmul2r; smt().
rewrite W64.to_uintD_small hsrc; smt().
qed.

abstract theory ArrayForm.

op asize : int.

axiom asize_ok : 0 < asize < 18446744073709551616.

clone import ByteArray as BArrayA with op size <= asize.

module F = {
  proc fill64_array (buf:BArray64.t, dst_:W64.t, a:BArrayA.t,
                             off_:W64.t, n_:W64.t, ms:W64.t) : BArray64.t *
                                                               W64.t = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    dst <- dst_;
    off <- off_;
    n <- n_;
    head <- dst;
    head <- (- head);
    head <- (head `&` (W64.of_int 7));
    head <- ((n \ult head) ? n : head);
    n <- (n - head);
    end_0 <- dst;
    end_0 <- (end_0 + head);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (BArrayA.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArrayA.get64d a (W64.to_uint off));
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      dst <- (dst + (W64.of_int 8));
      off <- (off + (W64.of_int 8));
      n <- (n - (W64.of_int 8));
      more <- ((W64.of_int 8) \ule n);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- dst;
    end_0 <- (end_0 + n);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (BArrayA.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc fill128_array (buf:BArray128.t, dst_:W64.t, a:BArrayA.t,
                              off_:W64.t, n_:W64.t, ms:W64.t) : BArray128.t *
                                                                W64.t = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    dst <- dst_;
    off <- off_;
    n <- n_;
    head <- dst;
    head <- (- head);
    head <- (head `&` (W64.of_int 7));
    head <- ((n \ult head) ? n : head);
    n <- (n - head);
    end_0 <- dst;
    end_0 <- (end_0 + head);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (BArrayA.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArrayA.get64d a (W64.to_uint off));
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      dst <- (dst + (W64.of_int 8));
      off <- (off + (W64.of_int 8));
      n <- (n - (W64.of_int 8));
      more <- ((W64.of_int 8) \ule n);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- dst;
    end_0 <- (end_0 + n);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (BArrayA.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                   a:BArrayA.t, off:W64.t, len:W64.t,
                                   ms:W64.t) : BArray32.t * BArray64.t *
                                               W64.t * W64.t = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    total <- (total + len);
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      (buf, ms) <@ fill64_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        (h, ms) <@ M._sha256_compress (h, buf, ms);
        total <- (protect_64 total ms);
        a <- (protect_ptr a ms);
        off <- (protect_64 off ms);
        len <- (protect_64 len ms);
        buf <- (protect_ptr buf ms);
        fill <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! full) ms);
      }
      more <- (len <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    return (h, buf, total, ms);
  }
  proc sha512_absorb_array (h:BArray64.t, buf:BArray128.t,
                                   total:W64.t, a:BArrayA.t, off:W64.t,
                                   len:W64.t, ms:W64.t) : BArray64.t *
                                                          BArray128.t *
                                                          W64.t * W64.t = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    total <- (total + len);
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      (buf, ms) <@ fill128_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        (h, ms) <@ M._sha512_compress (h, buf, ms);
        total <- (protect_64 total ms);
        a <- (protect_ptr a ms);
        off <- (protect_64 off ms);
        len <- (protect_64 len ms);
        buf <- (protect_ptr buf ms);
        fill <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! full) ms);
      }
      more <- (len <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    return (h, buf, total, ms);
  }
  proc sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArrayA.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t = {
    var aux:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    total <- (total + len);
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ fill64_array ((SBArray512_64.get_sub8 
                                              buf (64 * k)),
        fill, a, src, n, ms);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        src <- (src + stride);
        k <- (k + 1);
      }
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        h <- (protect_ptr h ms);
        (h, ms) <@ M._sha256_x8_compress (h, buf, ms);
        a <- (protect_ptr a ms);
        off <- (protect_64 off ms);
        stride <- (protect_64 stride ms);
        len <- (protect_64 len ms);
        buf <- (protect_ptr buf ms);
        fill <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! full) ms);
      }
      more <- (len <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArrayA.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t = {
    var aux:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    total <- (total + len);
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ fill128_array ((SBArray512_128.get_sub8 
                                               buf (128 * k)),
        fill, a, src, n, ms);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        src <- (src + stride);
        k <- (k + 1);
      }
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        h <- (protect_ptr h ms);
        (h, ms) <@ M._sha512_x4_compress (h, buf, ms);
        a <- (protect_ptr a ms);
        off <- (protect_64 off ms);
        stride <- (protect_64 stride ms);
        len <- (protect_64 len ms);
        buf <- (protect_ptr buf ms);
        fill <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! full) ms);
      }
      more <- (len <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc sha256 (out:BArray32.t, a:BArrayA.t, off:W64.t, len:W64.t) : 
  BArray32.t = {
    var ms:W64.t;
    var h:BArray32.t;
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    ms <- (init_msf);
    out <- (protect_ptr out ms);
    a <- (protect_ptr a ms);
    off <- (protect_64 off ms);
    len <- (protect_64 len ms);
    h <@ M.__sha256_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (h, buf, total, ms) <@ sha256_absorb_array (h, buf, total, 
    a, off, len, ms);
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ M._sha256___sha256_finalize (out, h, buf, total, ms);
    return out;
  }
  proc sha512 (out:BArray64.t, a:BArrayA.t, off:W64.t, len:W64.t) : 
  BArray64.t = {
    var ms:W64.t;
    var h:BArray64.t;
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    ms <- (init_msf);
    out <- (protect_ptr out ms);
    a <- (protect_ptr a ms);
    off <- (protect_64 off ms);
    len <- (protect_64 len ms);
    h <@ M.__sha512_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (h, buf, total, ms) <@ sha512_absorb_array (h, buf, total, 
    a, off, len, ms);
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ M._sha512___sha512_finalize (out, h, buf, total, ms);
    return out;
  }
  proc sha256_x8 (out:BArray256.t, a:BArrayA.t, off:W64.t,
                        stride:W64.t, len:W64.t) : BArray256.t = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    ms <- (init_msf);
    out <- (protect_ptr out ms);
    a <- (protect_ptr a ms);
    off <- (protect_64 off ms);
    stride <- (protect_64 stride ms);
    len <- (protect_64 len ms);
    h <@ M.__sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (h, buf, total, ms) <@ sha256_x8_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ M._sha256_x8_finalize (out, h, buf, total, ms);
    return out;
  }
  proc sha512_x4 (out:BArray256.t, a:BArrayA.t, off:W64.t,
                        stride:W64.t, len:W64.t) : BArray256.t = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    ms <- (init_msf);
    out <- (protect_ptr out ms);
    a <- (protect_ptr a ms);
    off <- (protect_64 off ms);
    stride <- (protect_64 stride ms);
    len <- (protect_64 len ms);
    h <@ M.__sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (h, buf, total, ms) <@ sha512_x4_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ M._sha512_x4_finalize (out, h, buf, total, ms);
    return out;
  }
}.

(* ------------------------------------------------------------------ *)
(* The bytes of an array                                              *)

op abytes (a : BArrayA.t) (o k : int) : bytes = mkseq (fun i => BArrayA.get8 a (o + i)) k.

lemma size_abytes a o k : 0 <= k => size (abytes a o k) = k.
proof. by move=> hk; rewrite size_mkseq /#. qed.

lemma nth_abytes a o k i : 0 <= i < k => nth W8.zero (abytes a o k) i = BArrayA.get8 a (o + i).
proof. by move=> hi; rewrite nth_mkseq. qed.

lemma abytes_cat a o k1 k2 : 0 <= k1 => 0 <= k2 =>
  abytes a o k1 ++ abytes a (o + k1) k2 = abytes a o (k1 + k2).
proof.
move=> h1 h2; rewrite /abytes mkseq_add //; congr.
by apply eq_in_mkseq => i hi /=; congr; ring.
qed.

lemma abytesE a o k : 0 <= o => 0 <= k => o + k <= asize =>
  abytes a o k = take k (drop o (BArrayA.to_list a)).
proof.
move=> ho hk hs; apply (eq_from_nth W8.zero).
+ by rewrite size_abytes // size_take // size_drop // BArrayA.size_to_list /#.
move=> i; rewrite size_abytes // => hi.
by rewrite nth_abytes // nth_take // 1:/# nth_drop // 1:/# BArrayA.get_to_list.
qed.

(* b is b0 with cells [d, e) taken from a from offset o on. *)
op fill64a (b0 : BArray64.t) (a : BArrayA.t) (d o e : int) (b : BArray64.t) =
  forall i, 0 <= i < 64 =>
    BArray64.get8 b i = if d <= i < e then BArrayA.get8 a (o + (i - d)) else BArray64.get8 b0 i.

op fill128a (b0 : BArray128.t) (a : BArrayA.t) (d o e : int) (b : BArray128.t) =
  forall i, 0 <= i < 128 =>
    BArray128.get8 b i = if d <= i < e then BArrayA.get8 a (o + (i - d)) else BArray128.get8 b0 i.

lemma fill64a_nil b0 a d o : fill64a b0 a d o d b0.
proof. by move=> i hi /#. qed.

lemma fill128a_nil b0 a d o : fill128a b0 a d o d b0.
proof. by move=> i hi /#. qed.

lemma fill64a_set8 b b0 a d o e :
  0 <= d <= e < 64 => fill64a b0 a d o e b =>
  fill64a b0 a d o (e + 1) (BArray64.set8 b e (BArrayA.get8 a (o + (e - d)))).
proof.
move=> he hb i hi; rewrite BArray64.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma fill64a_set64 b b0 a d o e :
  0 <= d <= e => e + 8 <= 64 => fill64a b0 a d o e b =>
  fill64a b0 a d o (e + 8) (BArray64.set64d b e (BArrayA.get64d a (o + (e - d)))).
proof.
move=> he he8 hb i hi; rewrite BArray64.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=.
+ rewrite hi /= BArrayA.get64d_byte 1:/#; smt().
by rewrite hb //; smt().
qed.

lemma fill128a_set8 b b0 a d o e :
  0 <= d <= e < 128 => fill128a b0 a d o e b =>
  fill128a b0 a d o (e + 1) (BArray128.set8 b e (BArrayA.get8 a (o + (e - d)))).
proof.
move=> he hb i hi; rewrite BArray128.get_setE 1:/#.
by case: (i = e) => [->|hne] /=; [smt() | rewrite hb //; smt()].
qed.

lemma fill128a_set64 b b0 a d o e :
  0 <= d <= e => e + 8 <= 128 => fill128a b0 a d o e b =>
  fill128a b0 a d o (e + 8) (BArray128.set64d b e (BArrayA.get64d a (o + (e - d)))).
proof.
move=> he he8 hb i hi; rewrite BArray128.get8_set64dE.
case: (e <= i < e + 8) => hi8 /=.
+ rewrite hi /= BArrayA.get64d_byte 1:/#; smt().
by rewrite hb //; smt().
qed.

(* ------------------------------------------------------------------ *)
(* fill64_array, fill128_array                                        *)

lemma fill64_correct (b0 : BArray64.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  hoare [F.fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 64 /\ to_uint o0 + to_uint n0 <= asize ==>
           fill64a b0 a0 (to_uint d0) (to_uint o0) (to_uint d0 + to_uint n0) res.`1].
proof.
have ha := asize_ok.
proc.
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hd' he hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill64a_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (W64.of_int 8 \ule n)
       /\ to_uint d0 <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hsum hp hPN hDN hb hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  rewrite subc_small 1:/# hp; do !split; 1..3: smt().
  by apply fill64a_set64 => //; smt(W64.to_uint_cmp).
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 64
       /\ fill64a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hd' hsum hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill64a_set8 => //; smt(W64.to_uint_cmp).
auto => /> hDN hPN.
have := fill_head d0 n0 _; 1: smt(W64.to_uint_cmp).
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first by do !split; [smt(W64.to_uint_cmp) | smt() | exact fill64a_nil].
move=> b1 d1 m1 o1 hn1 hm1 hd1 hd1' hsum1 hp1 hb1.
have he1 : to_uint d1 = to_uint d0 + to_uint (if n0 \ult (-d0) `&` W64.of_int 7 then n0
                                              else (-d0) `&` W64.of_int 7).
+ by move: hm1; rewrite eq_sym W64.ultE hdh /#.
split; first smt().
move=> b2 d2 m2 n2 o2 hn2 hm2 hd2 hsum2 hp2 hb2.
have hs2 : to_uint (d2 + n2) = to_uint d2 + to_uint n2.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite hs2 hsum2 /=; split; first smt(W64.to_uint_cmp).
move=> b3 d3 m3 o3 hn3 hm3 hd3 hd3' hp3 hb3.
have -> : to_uint d0 + to_uint n0 = to_uint d3.
+ by move: hm3; rewrite eq_sym W64.ultE; smt().
exact hb3.
qed.

lemma fill64_ll : islossless F.fill64_array.
proof.
proc.
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (W64.of_int 8 \ule n)) (to_uint n).
+ move=> z; auto => /> &m hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite subc_small; smt().
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m d1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ d2 m2 n2; split; first by rewrite W64.uleE /=; smt().
move=> _ _ d3 m3; rewrite W64.ultE; smt().
qed.

lemma fill64_total (b0 : BArray64.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  phoare [F.fill64_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 64 /\ to_uint o0 + to_uint n0 <= asize ==>
           fill64a b0 a0 (to_uint d0) (to_uint o0) (to_uint d0 + to_uint n0) res.`1] = 1%r.
proof. by conseq fill64_ll (fill64_correct b0 a0 d0 o0 n0). qed.

lemma fill128_correct (b0 : BArray128.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  hoare [F.fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 128 /\ to_uint o0 + to_uint n0 <= asize ==>
           fill128a b0 a0 (to_uint d0) (to_uint o0) (to_uint d0 + to_uint n0) res.`1].
proof.
have ha := asize_ok.
proc.
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hd' he hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill128a_set8 => //; smt(W64.to_uint_cmp).
wp; while (more = (W64.of_int 8 \ule n)
       /\ to_uint d0 <= to_uint dst
       /\ to_uint dst + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hsum hp hPN hDN hb hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite !addc_small //; 1,2: smt(W64.to_uint_cmp).
  rewrite subc_small 1:/# hp; do !split; 1..3: smt().
  by apply fill128a_set64 => //; smt(W64.to_uint_cmp).
wp; while (more = (dst \ult end_0)
       /\ to_uint d0 <= to_uint dst <= to_uint end_0
       /\ to_uint end_0 + to_uint n = to_uint d0 + to_uint n0
       /\ to_uint off = to_uint o0 + (to_uint dst - to_uint d0)
       /\ to_uint o0 + to_uint n0 <= asize /\ to_uint d0 + to_uint n0 <= 128
       /\ fill128a b0 a (to_uint d0) (to_uint o0) (to_uint dst) buf).
+ auto => /> &m hd hd' hsum hp hPN hDN hb hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite !addone_small; 1,2: smt(W64.to_uint_cmp).
  rewrite trunc_zext hp; do !split; 1..3: smt().
  by apply fill128a_set8 => //; smt(W64.to_uint_cmp).
auto => /> hDN hPN.
have := fill_head d0 n0 _; 1: smt(W64.to_uint_cmp).
move=> /= [hh [hdh hnh]]; rewrite hdh hnh /=.
split; first by do !split; [smt(W64.to_uint_cmp) | smt() | exact fill128a_nil].
move=> b1 d1 m1 o1 hn1 hm1 hd1 hd1' hsum1 hp1 hb1.
have he1 : to_uint d1 = to_uint d0 + to_uint (if n0 \ult (-d0) `&` W64.of_int 7 then n0
                                              else (-d0) `&` W64.of_int 7).
+ by move: hm1; rewrite eq_sym W64.ultE hdh /#.
split; first smt().
move=> b2 d2 m2 n2 o2 hn2 hm2 hd2 hsum2 hp2 hb2.
have hs2 : to_uint (d2 + n2) = to_uint d2 + to_uint n2.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite hs2 hsum2 /=; split; first smt(W64.to_uint_cmp).
move=> b3 d3 m3 o3 hn3 hm3 hd3 hd3' hp3 hb3.
have -> : to_uint d0 + to_uint n0 = to_uint d3.
+ by move: hm3; rewrite eq_sym W64.ultE; smt().
exact hb3.
qed.

lemma fill128_ll : islossless F.fill128_array.
proof.
proc.
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
wp; while (more = (W64.of_int 8 \ule n)) (to_uint n).
+ move=> z; auto => /> &m hle.
  have hn8 : 8 <= to_uint n{m} by move: hle; rewrite W64.uleE.
  rewrite subc_small; smt().
wp; while (more = (dst \ult end_0)) (to_uint end_0 - to_uint dst).
+ move=> z; auto => /> &m hlt.
  have hlt' : to_uint dst{m} < to_uint end_0{m} by rewrite -W64.ultE.
  rewrite addone_small; smt(W64.to_uint_cmp w64_modulus).
auto => /> &m d1 m1; split; first by rewrite W64.ultE; smt().
move=> _ _ d2 m2 n2; split; first by rewrite W64.uleE /=; smt().
move=> _ _ d3 m3; rewrite W64.ultE; smt().
qed.

lemma fill128_total (b0 : BArray128.t) (a0 : BArrayA.t) (d0 o0 n0 : W64.t) :
  phoare [F.fill128_array :
           buf = b0 /\ a = a0 /\ dst_ = d0 /\ off_ = o0 /\ n_ = n0 /\
           to_uint d0 + to_uint n0 <= 128 /\ to_uint o0 + to_uint n0 <= asize ==>
           fill128a b0 a0 (to_uint d0) (to_uint o0) (to_uint d0 + to_uint n0) res.`1] = 1%r.
proof. by conseq fill128_ll (fill128_correct b0 a0 d0 o0 n0). qed.

(* ------------------------------------------------------------------ *)
(* _sha256_absorb_array                                               *)

(* m followed by the first c bytes of a from o. *)
op mx (a : BArrayA.t) (m : bytes) (o c : int) : bytes = m ++ abytes a o c.

lemma mx_cat a m o c n : 0 <= c => 0 <= n => mx a m o (c + n) = mx a m o c ++ abytes a (o + c) n.
proof. by move=> hc hn; rewrite /mx -catA abytes_cat. qed.

lemma mx0 a m o : mx a m o 0 = m.
proof. by rewrite /mx /abytes mkseq0 cats0. qed.

(* off0 + n bytes into the array, as the loop takes them. *)
lemma mx_step a m (o0 off0 n : W64.t) :
  to_uint o0 <= to_uint off0 => 
  mx a m (to_uint o0) (to_uint off0 + to_uint n - to_uint o0)
  = mx a m (to_uint o0) (to_uint off0 - to_uint o0) ++ abytes a (to_uint off0) (to_uint n).
proof.
move=> ho; rewrite (_ : to_uint off0 + to_uint n - to_uint o0 = (to_uint off0 - to_uint o0) + to_uint n) 1:/#.
have hn := W64.to_uint_cmp n.
by rewrite mx_cat 1,2:/#; congr; congr; ring.
qed.

lemma size_mx a m o c : 0 <= c => size (mx a m o c) = size m + c.
proof. by move=> hc; rewrite /mx size_cat size_abytes. qed.

lemma pending_filla (b0 b : BArray64.t) a (t : bytes) o k :
  0 <= k => size t + k <= 64 => pending b0 t => fill64a b0 a (size t) o (size t + k) b =>
  pending b (t ++ abytes a o k).
proof.
move=> hk hs hp hf i; rewrite size_cat size_abytes // => hi.
rewrite hf 1:/# nth_cat.
case: (i < size t) => hit.
+ by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# nth_abytes /#.
qed.

lemma pend512_filla (b0 b : BArray128.t) a (t : bytes) o k :
  0 <= k => size t + k <= 128 => pend512 b0 t => fill128a b0 a (size t) o (size t + k) b =>
  pend512 b (t ++ abytes a o k).
proof.
move=> hk hs hp hf i; rewrite size_cat size_abytes // => hi.
rewrite hf 1:/# nth_cat.
case: (i < size t) => hit.
+ by rewrite ifF 1:/#; apply hp; smt(size_ge0).
by rewrite ifT 1:/# nth_abytes /#.
qed.

lemma sha256_absorb_correct (h0 : W32.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  hoare [F.sha256_absorb_array :
           stream256 h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus ==>
           stream256 h0 (m ++ abytes a0 (to_uint o0) (to_uint l0)) res.`1 res.`2 res.`3].
proof.
have ha := asize_ok.
proc.
wp; while (more = (len <> W64.zero) /\ a = a0 /\
       0 <= to_uint off - to_uint o0 <= to_uint l0 /\
       to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
       to_uint total = size m + to_uint l0 /\
       to_uint fill = size (mx a0 m (to_uint o0) (to_uint off - to_uint o0)) %% 64 /\
       h256 h = foldl SHA256.compress h0 (SHA256.parse (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
       pending buf (tail 64 (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
       to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus).
+ seq 5 : (len <> W64.zero /\ a = a0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = size m + to_uint l0 /\
           to_uint fill = size (mx a0 m (to_uint o0) (to_uint off - to_uint o0)) %% 64 /\
           to_uint n = min (to_uint len) (64 - to_uint fill) /\
           h256 h = foldl SHA256.compress h0 (SHA256.parse (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
           pending buf (tail 64 (mx a0 m (to_uint o0) (to_uint off - to_uint o0))
                        ++ abytes a0 (to_uint off) (to_uint n)) /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus).
  + ecall (fill64_correct buf a fill off n); auto => /> &hr hc0 hc1 hl ht hf hh hp hpl hml hz.
    have hf64 : to_uint fill{hr} < 64 by rewrite hf; smt(modz_cmp).
    have [hn [hn1 _]] := step_count fill{hr} len{hr} hf64 hz.
    have hsc : size (tail 64 (mx a0 m (to_uint o0) (to_uint off{hr} - to_uint o0))) = to_uint fill{hr}.
    + by rewrite size_tail // hf.
    rewrite hn; split; first by move: hl hpl hf64; clear hh hp hsc hf hn hn1; smt().
    move=> _ _ [b1 ms1] /= hb1.
    apply (pending_filla buf{hr}); 1,2: by have := W64.to_uint_cmp len{hr}; move: hsc hf64; clear hh hp hb1 hf hn hn1; smt().
    + exact hp.
    by rewrite hsc; exact hb1.
  sp; if.
  + wp; ecall (K256.compress_correct (h256 h) buf).
    auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hh hp hpl hml hfull [h1 ms1] /= hh1.
    rewrite /protect_64 /protect_ptr /=.
    have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 64 _ _ _ _ _ _; 1..6: smt().
    have hsum : to_uint fill0 + to_uint n{hr} = 64 by rewrite -hfn hfull.
    have hmx := mx_step a{hr} m o0 off0 n{hr} _; 1: smt().
    have hsx : size (tail 64 (mx a{hr} m (to_uint o0) (to_uint off0 - to_uint o0))
                     ++ abytes a{hr} (to_uint off0) (to_uint n{hr})) = 64.
    + by rewrite size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
    have [hpc htc] := parse_close _ _ hsx.
    rewrite hoff hmx hlen hr1; do !split; 1,2: by case: hr0.
    + by rewrite -size_tail // htc.
    + by rewrite hpc foldl_rcons hh1 hh (pending_full buf{hr} _ hsx hp).
    by rewrite htc; exact pending_nil.
  auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hh hp hpl hml hfull.
  have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 64 _ _ _ _ _ _; 1..6: smt().
  have hlt : to_uint fill0 + to_uint n{hr} < 64.
  + have : to_uint (fill0 + n{hr}) <> 64.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  have hmx := mx_step a{hr} m o0 off0 n{hr} _; 1: smt().
  have hsx : size (tail 64 (mx a{hr} m (to_uint o0) (to_uint off0 - to_uint o0))
                   ++ abytes a{hr} (to_uint off0) (to_uint n{hr})) < 64.
  + by rewrite size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
  have [hps hts] := parse_short _ _ hsx.
  rewrite hoff hmx hfn hlen hr1; do !split; 1,2: by case: hr0.
  + by rewrite -size_tail // hts size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
  + by rewrite hps.
  by rewrite hts.
auto => /> &hr ht hh hp hpl hml.
rewrite mx0 W64.to_uintD_small 1:/# and63 ht /=; split; first smt(W64.to_uint_cmp).
move=> b1 f1 h1 l1 m1 o1 t1 hm1 hl1 hc0 hc1 hl ht1 hf1 hh1 hp1.
have hc : to_uint o1 - to_uint o0 = to_uint l0.
+ have : l1 = W64.zero by move: hl1 => /#.
  by move=> hz; move: hl; rewrite hz /=; smt().
have -> : m ++ abytes a0 (to_uint o0) (to_uint l0) = mx a0 m (to_uint o0) (to_uint o1 - to_uint o0).
+ by rewrite /mx hc.
by rewrite size_mx 1:/# ht1 hh1 hp1 /=; smt().
qed.

lemma sha256_absorb_ll : islossless F.sha256_absorb_array.
proof.
proc.
wp; while (more = (len <> W64.zero) /\ to_uint fill < 64) (to_uint len).
+ move=> z.
  seq 9 : (to_uint len < z /\ to_uint fill <= 64 /\ full = (fill = W64.of_int 64)) 1%r 1%r 0%r 0%r => //.
  + wp; call fill64_ll; auto => /> &m hf hz.
    by have := step_count fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
  + if; [wp; call K256.compress_ll |]; auto => /> &m hl hf hne.
    have : to_uint fill{m} <> 64 by move: hne; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  hoare; wp; call (: true) => //; auto => /> &m hf hz.
  by have := step_count fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
auto => /> &m; split; first by rewrite and63; smt(modz_cmp).
move=> f1 l1 _ h; apply W64.to_uint_eq => /=; have := W64.to_uint_cmp l1; smt().
qed.

lemma sha256_absorb_total (h0 : W32.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [F.sha256_absorb_array :
           stream256 h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus ==>
           stream256 h0 (m ++ abytes a0 (to_uint o0) (to_uint l0)) res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha256_absorb_ll (sha256_absorb_correct h0 m a0 o0 l0). qed.

lemma sha512_absorb_correct (h0 : W64.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  hoare [F.sha512_absorb_array :
           stream512 h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus ==>
           stream512 h0 (m ++ abytes a0 (to_uint o0) (to_uint l0)) res.`1 res.`2 res.`3].
proof.
have ha := asize_ok.
proc.
wp; while (more = (len <> W64.zero) /\ a = a0 /\
       0 <= to_uint off - to_uint o0 <= to_uint l0 /\
       to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
       to_uint total = size m + to_uint l0 /\
       to_uint fill = size (mx a0 m (to_uint o0) (to_uint off - to_uint o0)) %% 128 /\
       h512 h = foldl SHA512.compress h0 (SHA512.parse (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
       pend512 buf (tail 128 (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
       to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus).
+ seq 5 : (len <> W64.zero /\ a = a0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = size m + to_uint l0 /\
           to_uint fill = size (mx a0 m (to_uint o0) (to_uint off - to_uint o0)) %% 128 /\
           to_uint n = min (to_uint len) (128 - to_uint fill) /\
           h512 h = foldl SHA512.compress h0 (SHA512.parse (mx a0 m (to_uint o0) (to_uint off - to_uint o0))) /\
           pend512 buf (tail 128 (mx a0 m (to_uint o0) (to_uint off - to_uint o0))
                        ++ abytes a0 (to_uint off) (to_uint n)) /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus).
  + ecall (fill128_correct buf a fill off n); auto => /> &hr hc0 hc1 hl ht hf hh hp hpl hml hz.
    have hf128 : to_uint fill{hr} < 128 by rewrite hf; smt(modz_cmp).
    have [hn [hn1 _]] := step_count128 fill{hr} len{hr} hf128 hz.
    have hsc : size (tail 128 (mx a0 m (to_uint o0) (to_uint off{hr} - to_uint o0))) = to_uint fill{hr}.
    + by rewrite size_tail // hf.
    rewrite hn; split; first by move: hl hpl hf128; clear hh hp hsc hf hn hn1; smt().
    move=> _ _ [b1 ms1] /= hb1.
    apply (pend512_filla buf{hr}); 1,2: by have := W64.to_uint_cmp len{hr}; move: hsc hf128; clear hh hp hb1 hf hn hn1; smt().
    + exact hp.
    by rewrite hsc; exact hb1.
  sp; if.
  + wp; ecall (K512.compress_correct (h512 h) buf).
    auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hh hp hpl hml hfull [h1 ms1] /= hh1.
    rewrite /protect_64 /protect_ptr /=.
    have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 128 _ _ _ _ _ _; 1..6: smt().
    have hsum : to_uint fill0 + to_uint n{hr} = 128 by rewrite -hfn hfull.
    have hmx := mx_step a{hr} m o0 off0 n{hr} _; 1: smt().
    have hsx : size (tail 128 (mx a{hr} m (to_uint o0) (to_uint off0 - to_uint o0))
                     ++ abytes a{hr} (to_uint off0) (to_uint n{hr})) = 128.
    + by rewrite size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
    have [hpc htc] := parse512_close _ _ hsx.
    rewrite hoff hmx hlen hr1; do !split; 1,2: by case: hr0.
    + by rewrite -size_tail // htc.
    + by rewrite hpc foldl_rcons hh1 hh (pend512_full buf{hr} _ hsx hp).
    by rewrite htc; exact pend512_nil.
  auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hh hp hpl hml hfull.
  have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 128 _ _ _ _ _ _; 1..6: smt().
  have hlt : to_uint fill0 + to_uint n{hr} < 128.
  + have : to_uint (fill0 + n{hr}) <> 128.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  have hmx := mx_step a{hr} m o0 off0 n{hr} _; 1: smt().
  have hsx : size (tail 128 (mx a{hr} m (to_uint o0) (to_uint off0 - to_uint o0))
                   ++ abytes a{hr} (to_uint off0) (to_uint n{hr})) < 128.
  + by rewrite size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
  have [hps hts] := parse512_short _ _ hsx.
  rewrite hoff hmx hfn hlen hr1; do !split; 1,2: by case: hr0.
  + by rewrite -size_tail // hts size_cat size_tail // -hf size_abytes; smt(W64.to_uint_cmp).
  + by rewrite hps.
  by rewrite hts.
auto => /> &hr ht hh hp hpl hml.
rewrite mx0 W64.to_uintD_small 1:/# and127 ht /=; split; first smt(W64.to_uint_cmp).
move=> b1 f1 h1 l1 m1 o1 t1 hm1 hl1 hc0 hc1 hl ht1 hf1 hh1 hp1.
have hc : to_uint o1 - to_uint o0 = to_uint l0.
+ have : l1 = W64.zero by move: hl1 => /#.
  by move=> hz; move: hl; rewrite hz /=; smt().
have -> : m ++ abytes a0 (to_uint o0) (to_uint l0) = mx a0 m (to_uint o0) (to_uint o1 - to_uint o0).
+ by rewrite /mx hc.
by rewrite size_mx 1:/# ht1 hh1 hp1 /=; smt().
qed.

lemma sha512_absorb_ll : islossless F.sha512_absorb_array.
proof.
proc.
wp; while (more = (len <> W64.zero) /\ to_uint fill < 128) (to_uint len).
+ move=> z.
  seq 9 : (to_uint len < z /\ to_uint fill <= 128 /\ full = (fill = W64.of_int 128)) 1%r 1%r 0%r 0%r => //.
  + wp; call fill128_ll; auto => /> &m hf hz.
    by have := step_count128 fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
  + if; [wp; call K512.compress_ll |]; auto => /> &m hl hf hne.
    have : to_uint fill{m} <> 128 by move: hne; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  hoare; wp; call (: true) => //; auto => /> &m hf hz.
  by have := step_count128 fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
auto => /> &m; split; first by rewrite and127; smt(modz_cmp).
move=> f1 l1 _ h; apply W64.to_uint_eq => /=; have := W64.to_uint_cmp l1; smt().
qed.

lemma sha512_absorb_total (h0 : W64.t list) (m : bytes) (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [F.sha512_absorb_array :
           stream512 h0 m h buf total /\ a = a0 /\ off = o0 /\ len = l0 /\
           to_uint o0 + to_uint l0 <= asize /\ size m + to_uint l0 < W64.modulus ==>
           stream512 h0 (m ++ abytes a0 (to_uint o0) (to_uint l0)) res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha512_absorb_ll (sha512_absorb_correct h0 m a0 o0 l0). qed.

(* ------------------------------------------------------------------ *)
(* _sha256_x8_absorb_array                                            *)

(* Lane j after c bytes: ms j followed by the c bytes of a at o + j s. *)
op mxl (a : BArrayA.t) (ms : int -> bytes) (o s c : int) : int -> bytes =
  fun j => mx a (ms j) (o + j * s) c.

lemma mxl_step a ms (o0 off n : W64.t) s j :
  to_uint o0 <= to_uint off =>
  mxl a ms (to_uint o0) s (to_uint off + to_uint n - to_uint o0) j
  = mxl a ms (to_uint o0) s (to_uint off - to_uint o0) j ++ abytes a (to_uint off + j * s) (to_uint n).
proof.
move=> ho; rewrite /mxl /= (_ : to_uint off + to_uint n - to_uint o0 = (to_uint off - to_uint o0) + to_uint n) 1:/#.
have hn := W64.to_uint_cmp n.
by rewrite mx_cat 1,2:/#; congr; congr; ring.
qed.

lemma mxl0 a ms o s : mxl a ms o s 0 = ms.
proof. by apply fun_ext => j; rewrite /mxl /= mx0. qed.

lemma x8_absorb_inner (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (t0 o0 s0 l0 : W64.t) :
  hoare [F.sha256_x8_absorb_array :
           total = t0 /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           (forall k, 0 <= k < 8 => size (ms0 k) = to_uint t0) /\
           SHA256_X8.lanes8 h0 ms0 h buf /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus ==>
           to_uint res.`3 = to_uint t0 + to_uint l0 /\
           SHA256_X8.lanes8 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2].
proof.
have ha := asize_ok.
proc.
wp; while (more = (len <> W64.zero) /\ a = a0 /\ stride = s0 /\
       0 <= to_uint off - to_uint o0 <= to_uint l0 /\
       to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
       to_uint total = to_uint t0 + to_uint l0 /\
       to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 64 /\
       (forall k, 0 <= k < 8 => size (ms0 k) = to_uint t0) /\
       SHA256_X8.lanes8 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0)) h buf /\
       to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus).
+ seq 6 : (len <> W64.zero /\ a = a0 /\ stride = s0 /\ src = off /\ k = 0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 64 /\
           to_uint n = min (to_uint len) (64 - to_uint fill) /\
           (forall k, 0 <= k < 8 => size (ms0 k) = to_uint t0) /\
           SHA256_X8.lanes8 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0)) h buf /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus).
  + auto => /> &hr hc0 hc1 hl ht hf hs hlan hpl htl hz.
    have hf64 : to_uint fill{hr} < 64 by rewrite hf; smt(modz_cmp).
    by have [-> _] := step_count fill{hr} len{hr} hf64 hz.
  seq 1 : (len <> W64.zero /\ a = a0 /\ stride = s0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 64 /\
           to_uint n = min (to_uint len) (64 - to_uint fill) /\
           (forall k, 0 <= k < 8 => size (ms0 k) = to_uint t0) /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus /\
           (forall j, 0 <= j < 8 => SHA256_X8.l8 h j = foldl SHA256.compress h0 (SHA256.parse (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j))) /\
           (forall j, 0 <= j < 8 =>
              pending (SHA256_X8.sub8 buf j) (tail 64 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j) ++ abytes a0 (to_uint off + j * to_uint s0) (to_uint n)))).
  + while (0 <= k <= 8 /\ (k < 8 => to_uint src = to_uint off + k * to_uint s0) /\
           len <> W64.zero /\ a = a0 /\ stride = s0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 64 /\
           to_uint n = min (to_uint len) (64 - to_uint fill) /\
           (forall k, 0 <= k < 8 => size (ms0 k) = to_uint t0) /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus /\
           (forall j, 0 <= j < 8 => SHA256_X8.l8 h j = foldl SHA256.compress h0 (SHA256.parse (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j))) /\
           (forall j, 0 <= j < 8 =>
              pending (SHA256_X8.sub8 buf j)
                (tail 64 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j) ++ if j < k then abytes a0 (to_uint off + j * to_uint s0) (to_uint n) else []))).
    + wp; ecall (fill64_correct (SHA256_X8.sub8 buf k) a fill src n).
      auto => /> &hr hk0 hk8 hsrc hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hk.
      have [hb1 [hb2 hb3]] := lane_bounds o0 l0 off{hr} len{hr} fill{hr} n{hr} src{hr} s0 k{hr} asize 64 8
                                _ (hsrc hk) hc0 hl hn hpl _; 1,2: smt().
      split; first by split.
      move=> _ _ [b1 ms1] /= hb.
      split; first smt().
      split; first exact hb3.
      have hsk : size (tail 64 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off{hr} - to_uint o0) k{hr}))
                 = to_uint fill{hr}.
      + by rewrite size_tail // /mxl /= size_mx // hs 1:/# hf.
      have := SHA256_X8.pend_step buf{hr} b1
                (fun j => tail 64 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off{hr} - to_uint o0) j))
                (fun j => abytes a0 (to_uint off{hr} + j * to_uint s0) (to_uint n{hr})) k{hr} _ hp _; 1: smt().
      + rewrite /=; apply (pending_filla (SHA256_X8.sub8 buf{hr} k{hr})).
        + smt(W64.to_uint_cmp).
        + by rewrite hsk.
        + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
        by rewrite hsk -(hsrc hk).
      by move=> h j hj0 hj1; apply h.
    auto => /> &hr hz hc0 hc1 hl ht hf hn hs hlan hpl htl; split.
    + split => j hj0 hj1; have hj : 0 <= j < 8 by done.
      + by have [hh _] := hlan j hj.
      by have [_ hp] := hlan j hj; rewrite ifF 1:/# cats0.
    move=> b k0 hk hk0 hk8 _ hp j hj0 hj1.
    by have := hp j _; [smt() | rewrite ifT 1:/#].
  sp; if.
  + wp; ecall (KX8.compress_correct h buf).
    auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hfull [h1 ms1] /=.
    rewrite /protect_64 /protect_ptr /= => hh1.
    have hf64 : to_uint fill0 < 64 by rewrite hf; smt(modz_cmp).
    have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 64 hc0 hl _ hn hf64 _; 1,2: smt(W64.to_uint_cmp).
    have hsum : to_uint fill0 + to_uint n{hr} = 64 by rewrite -hfn hfull.
    have hn0 := W64.to_uint_cmp n{hr}.
    rewrite hoff hlen hr1; do !split; 1,2: by case: hr0.
    + rewrite (_ : to_uint t0 + (to_uint off0 + to_uint n{hr} - to_uint o0)
                   = (to_uint t0 + (to_uint off0 - to_uint o0)) + to_uint n{hr}) 1:/#.
      by rewrite -modzDml -hf hsum.
    move=> j hj; rewrite mxl_step 1:/#.
    have hsx : size (tail 64 (mxl a{hr} ms0 (to_uint o0) (to_uint stride{hr}) (to_uint off0 - to_uint o0) j)
                     ++ abytes a{hr} (to_uint off0 + j * to_uint stride{hr}) (to_uint n{hr})) = 64.
    + by rewrite size_cat size_tail // /mxl /= size_mx // hs // -hf size_abytes 1:/# hsum.
    have := SHA256_X8.lane_close h0 _ _ (SHA256_X8.l8 h{hr} j) (SHA256_X8.l8 h1 j) (SHA256_X8.sub8 buf{hr} j)
              hsx (hh j hj) (hp j hj) _.
    + by rewrite SHA256_X8.sub8_block // hh1.
    by move=> [-> ->]; split; [done | exact pending_nil].
  auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hfull.
  have hf64 : to_uint fill0 < 64 by rewrite hf; smt(modz_cmp).
  have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 64 hc0 hl _ hn hf64 _; 1,2: smt(W64.to_uint_cmp).
  have hlt : to_uint fill0 + to_uint n{hr} < 64.
  + have : to_uint (fill0 + n{hr}) <> 64.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  have hn0 := W64.to_uint_cmp n{hr}.
  rewrite hoff hlen hr1 hfn; do !split; 1,2: by case: hr0.
  + rewrite (_ : to_uint t0 + (to_uint off0 + to_uint n{hr} - to_uint o0)
                 = (to_uint t0 + (to_uint off0 - to_uint o0)) + to_uint n{hr}) 1:/#.
    by rewrite -modzDml -hf pmod_small; smt(W64.to_uint_cmp).
  move=> j hj; rewrite mxl_step 1:/#.
  have hsx : size (tail 64 (mxl a{hr} ms0 (to_uint o0) (to_uint stride{hr}) (to_uint off0 - to_uint o0) j)
                   ++ abytes a{hr} (to_uint off0 + j * to_uint stride{hr}) (to_uint n{hr})) < 64.
  + by rewrite size_cat size_tail // /mxl /= size_mx // hs // -hf size_abytes 1:/#.
  have [hps hts] := parse_short _ _ hsx.
  by split; [rewrite hps; exact (hh j hj) | rewrite hts; exact (hp j hj)].
auto => /> &hr hs hlan hpl htl.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have htl' : to_uint (t0 + l0) = to_uint t0 + to_uint l0.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite mxl0 and63; split; first by do !split.
move=> b1 f1 h1 l1 m1 ms1 o1 hm1 hl1 hc0 hc1 hl _ hf hlan1.
have hc : to_uint o1 - to_uint o0 = to_uint l0.
+ have : l1 = W64.zero by move: hl1 => /#.
  by move=> hz; move: hl; rewrite hz /=; smt().
by rewrite -hc /protect_ptr.
qed.

lemma sha256_x8_absorb_correct (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  hoare [F.sha256_x8_absorb_array :
           SHA256_X8.stream8 h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint total + to_uint l0 < W64.modulus ==>
           SHA256_X8.stream8 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2 res.`3].
proof.
exists* total; elim* => t0.
conseq (x8_absorb_inner h0 ms0 a0 t0 o0 s0 l0).
+ move=> &m [-> [[hs hl] [-> [-> [-> [-> [hpl htl]]]]]]]; do !split => //.
  by move=> k hk; rewrite (hs k hk).
move=> &m [-> [[hs _] _]] r [ht hl]; split => // k hk /=.
by rewrite ht /mxl /= size_mx ?(hs k hk) //; case: (W64.to_uint_cmp l0).
qed.

lemma sha256_x8_absorb_ll : islossless F.sha256_x8_absorb_array.
proof.
proc.
wp; while (more = (len <> W64.zero) /\ to_uint fill < 64) (to_uint len).
+ move=> z.
  seq 11 : (to_uint len < z /\ to_uint fill <= 64 /\ full = (fill = W64.of_int 64)) 1%r 1%r 0%r 0%r => //.
  + wp; while (0 <= k <= 8) (8 - k); first by move=> z'; wp; call fill64_ll; auto => /#.
    auto => /> &m hf hz k0; split; first smt().
    by have := step_count fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
  + if; [wp; call KX8.compress_ll |]; auto => /> &m hl hf hne.
    have : to_uint fill{m} <> 64 by move: hne; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  hoare; wp; while (true); first by wp; call (: true) => //; auto.
  auto => /> &m hf hz k0 _.
  by have := step_count fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
auto => /> &m; split; first by rewrite and63; smt(modz_cmp).
move=> f1 l1 _ h; apply W64.to_uint_eq => /=; have := W64.to_uint_cmp l1; smt().
qed.

lemma sha256_x8_absorb_total (h0 : W32.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [F.sha256_x8_absorb_array :
           SHA256_X8.stream8 h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint total + to_uint l0 < W64.modulus ==>
           SHA256_X8.stream8 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha256_x8_absorb_ll (sha256_x8_absorb_correct h0 ms0 a0 o0 s0 l0). qed.

lemma x4_absorb_inner (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (t0 o0 s0 l0 : W64.t) :
  hoare [F.sha512_x4_absorb_array :
           total = t0 /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           SHA512_X4.lanes4 h0 ms0 h buf /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus ==>
           to_uint res.`3 = to_uint t0 + to_uint l0 /\
           SHA512_X4.lanes4 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2].
proof.
have ha := asize_ok.
proc.
wp; while (more = (len <> W64.zero) /\ a = a0 /\ stride = s0 /\
       0 <= to_uint off - to_uint o0 <= to_uint l0 /\
       to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
       to_uint total = to_uint t0 + to_uint l0 /\
       to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 128 /\
       (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
       SHA512_X4.lanes4 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0)) h buf /\
       to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus).
+ seq 6 : (len <> W64.zero /\ a = a0 /\ stride = s0 /\ src = off /\ k = 0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 128 /\
           to_uint n = min (to_uint len) (128 - to_uint fill) /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           SHA512_X4.lanes4 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0)) h buf /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus).
  + auto => /> &hr hc0 hc1 hl ht hf hs hlan hpl htl hz.
    have hf64 : to_uint fill{hr} < 128 by rewrite hf; smt(modz_cmp).
    by have [-> _] := step_count128 fill{hr} len{hr} hf64 hz.
  seq 1 : (len <> W64.zero /\ a = a0 /\ stride = s0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 128 /\
           to_uint n = min (to_uint len) (128 - to_uint fill) /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus /\
           (forall j, 0 <= j < 4 => SHA512_X4.l4 h j = foldl SHA512.compress h0 (SHA512.parse (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j))) /\
           (forall j, 0 <= j < 4 =>
              pend512 (SHA512_X4.sub4 buf j) (tail 128 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j) ++ abytes a0 (to_uint off + j * to_uint s0) (to_uint n)))).
  + while (0 <= k <= 4 /\ (k < 4 => to_uint src = to_uint off + k * to_uint s0) /\
           len <> W64.zero /\ a = a0 /\ stride = s0 /\
           0 <= to_uint off - to_uint o0 <= to_uint l0 /\
           to_uint len = to_uint l0 - (to_uint off - to_uint o0) /\
           to_uint total = to_uint t0 + to_uint l0 /\
           to_uint fill = (to_uint t0 + (to_uint off - to_uint o0)) %% 128 /\
           to_uint n = min (to_uint len) (128 - to_uint fill) /\
           (forall k, 0 <= k < 4 => size (ms0 k) = to_uint t0) /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint t0 + to_uint l0 < W64.modulus /\
           (forall j, 0 <= j < 4 => SHA512_X4.l4 h j = foldl SHA512.compress h0 (SHA512.parse (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j))) /\
           (forall j, 0 <= j < 4 =>
              pend512 (SHA512_X4.sub4 buf j)
                (tail 128 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off - to_uint o0) j) ++ if j < k then abytes a0 (to_uint off + j * to_uint s0) (to_uint n) else []))).
    + wp; ecall (fill128_correct (SHA512_X4.sub4 buf k) a fill src n).
      auto => /> &hr hk0 hk8 hsrc hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hk.
      have [hb1 [hb2 hb3]] := lane_bounds o0 l0 off{hr} len{hr} fill{hr} n{hr} src{hr} s0 k{hr} asize 128 4
                                _ (hsrc hk) hc0 hl hn hpl _; 1,2: smt().
      split; first by split.
      move=> _ _ [b1 ms1] /= hb.
      split; first smt().
      split; first exact hb3.
      have hsk : size (tail 128 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off{hr} - to_uint o0) k{hr}))
                 = to_uint fill{hr}.
      + by rewrite size_tail // /mxl /= size_mx // hs 1:/# hf.
      have := SHA512_X4.pend_step buf{hr} b1
                (fun j => tail 128 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint off{hr} - to_uint o0) j))
                (fun j => abytes a0 (to_uint off{hr} + j * to_uint s0) (to_uint n{hr})) k{hr} _ hp _; 1: smt().
      + rewrite /=; apply (pend512_filla (SHA512_X4.sub4 buf{hr} k{hr})).
        + smt(W64.to_uint_cmp).
        + by rewrite hsk.
        + by have := hp k{hr} _; [smt() | rewrite ifF 1:/# cats0].
        by rewrite hsk -(hsrc hk).
      by move=> h j hj0 hj1; apply h.
    auto => /> &hr hz hc0 hc1 hl ht hf hn hs hlan hpl htl; split.
    + split => j hj0 hj1; have hj : 0 <= j < 4 by done.
      + by have [hh _] := hlan j hj.
      by have [_ hp] := hlan j hj; rewrite ifF 1:/# cats0.
    move=> b k0 hk hk0 hk8 _ hp j hj0 hj1.
    by have := hp j _; [smt() | rewrite ifT 1:/#].
  sp; if.
  + wp; ecall (KX4.compress_correct h buf).
    auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hfull [h1 ms1] /=.
    rewrite /protect_64 /protect_ptr /= => hh1.
    have hf64 : to_uint fill0 < 128 by rewrite hf; smt(modz_cmp).
    have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 128 hc0 hl _ hn hf64 _; 1,2: smt(W64.to_uint_cmp).
    have hsum : to_uint fill0 + to_uint n{hr} = 128 by rewrite -hfn hfull.
    have hn0 := W64.to_uint_cmp n{hr}.
    rewrite hoff hlen hr1; do !split; 1,2: by case: hr0.
    + rewrite (_ : to_uint t0 + (to_uint off0 + to_uint n{hr} - to_uint o0)
                   = (to_uint t0 + (to_uint off0 - to_uint o0)) + to_uint n{hr}) 1:/#.
      by rewrite -modzDml -hf hsum.
    move=> j hj; rewrite mxl_step 1:/#.
    have hsx : size (tail 128 (mxl a{hr} ms0 (to_uint o0) (to_uint stride{hr}) (to_uint off0 - to_uint o0) j)
                     ++ abytes a{hr} (to_uint off0 + j * to_uint stride{hr}) (to_uint n{hr})) = 128.
    + by rewrite size_cat size_tail // /mxl /= size_mx // hs // -hf size_abytes 1:/# hsum.
    have := SHA512_X4.lane_close h0 _ _ (SHA512_X4.l4 h{hr} j) (SHA512_X4.l4 h1 j) (SHA512_X4.sub4 buf{hr} j)
              hsx (hh j hj) (hp j hj) _.
    + by rewrite SHA512_X4.sub4_block // hh1.
    by move=> [-> ->]; split; [done | exact pend512_nil].
  auto => /> &hr len0 off0 fill0 hz hc0 hc1 hl ht hf hn hs hpl htl hh hp hfull.
  have hf64 : to_uint fill0 < 128 by rewrite hf; smt(modz_cmp).
  have [hoff [hlen [hfn [hr0 hr1]]]] := step_words o0 l0 off0 len0 fill0 n{hr} 128 hc0 hl _ hn hf64 _; 1,2: smt(W64.to_uint_cmp).
  have hlt : to_uint fill0 + to_uint n{hr} < 128.
  + have : to_uint (fill0 + n{hr}) <> 128.
    + by move: hfull; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  have hn0 := W64.to_uint_cmp n{hr}.
  rewrite hoff hlen hr1 hfn; do !split; 1,2: by case: hr0.
  + rewrite (_ : to_uint t0 + (to_uint off0 + to_uint n{hr} - to_uint o0)
                 = (to_uint t0 + (to_uint off0 - to_uint o0)) + to_uint n{hr}) 1:/#.
    by rewrite -modzDml -hf pmod_small; smt(W64.to_uint_cmp).
  move=> j hj; rewrite mxl_step 1:/#.
  have hsx : size (tail 128 (mxl a{hr} ms0 (to_uint o0) (to_uint stride{hr}) (to_uint off0 - to_uint o0) j)
                   ++ abytes a{hr} (to_uint off0 + j * to_uint stride{hr}) (to_uint n{hr})) < 128.
  + by rewrite size_cat size_tail // /mxl /= size_mx // hs // -hf size_abytes 1:/#.
  have [hps hts] := parse512_short _ _ hsx.
  by split; [rewrite hps; exact (hh j hj) | rewrite hts; exact (hp j hj)].
auto => /> &hr hs hlan hpl htl.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have htl' : to_uint (t0 + l0) = to_uint t0 + to_uint l0.
+ by rewrite W64.to_uintD_small //; smt(W64.to_uint_cmp).
rewrite mxl0 and127; split; first by do !split.
move=> b1 f1 h1 l1 m1 ms1 o1 hm1 hl1 hc0 hc1 hl _ hf hlan1.
have hc : to_uint o1 - to_uint o0 = to_uint l0.
+ have : l1 = W64.zero by move: hl1 => /#.
  by move=> hz; move: hl; rewrite hz /=; smt().
by rewrite -hc /protect_ptr.
qed.

lemma sha512_x4_absorb_correct (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  hoare [F.sha512_x4_absorb_array :
           SHA512_X4.stream4 h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint total + to_uint l0 < W64.modulus ==>
           SHA512_X4.stream4 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2 res.`3].
proof.
exists* total; elim* => t0.
conseq (x4_absorb_inner h0 ms0 a0 t0 o0 s0 l0).
+ move=> &m [-> [[hs hl] [-> [-> [-> [-> [hpl htl]]]]]]]; do !split => //.
  by move=> k hk; rewrite (hs k hk).
move=> &m [-> [[hs _] _]] r [ht hl]; split => // k hk /=.
by rewrite ht /mxl /= size_mx ?(hs k hk) //; case: (W64.to_uint_cmp l0).
qed.

lemma sha512_x4_absorb_ll : islossless F.sha512_x4_absorb_array.
proof.
proc.
wp; while (more = (len <> W64.zero) /\ to_uint fill < 128) (to_uint len).
+ move=> z.
  seq 11 : (to_uint len < z /\ to_uint fill <= 128 /\ full = (fill = W64.of_int 128)) 1%r 1%r 0%r 0%r => //.
  + wp; while (0 <= k <= 4) (4 - k); first by move=> z'; wp; call fill128_ll; auto => /#.
    auto => /> &m hf hz k0; split; first smt().
    by have := step_count128 fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
  + if; [wp; call KX4.compress_ll |]; auto => /> &m hl hf hne.
    have : to_uint fill{m} <> 128 by move: hne; apply contra => h; apply W64.to_uint_eq; rewrite h.
    smt().
  hoare; wp; while (true); first by wp; call (: true) => //; auto.
  auto => /> &m hf hz k0 _.
  by have := step_count128 fill{m} len{m} hf hz; move=> /= [_ [_ [_ [_ [-> ->]]]]].
auto => /> &m; split; first by rewrite and127; smt(modz_cmp).
move=> f1 l1 _ h; apply W64.to_uint_eq => /=; have := W64.to_uint_cmp l1; smt().
qed.

lemma sha512_x4_absorb_total (h0 : W64.t list) (ms0 : int -> bytes) (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [F.sha512_x4_absorb_array :
           SHA512_X4.stream4 h0 ms0 h buf total /\ a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint total + to_uint l0 < W64.modulus ==>
           SHA512_X4.stream4 h0 (mxl a0 ms0 (to_uint o0) (to_uint s0) (to_uint l0)) res.`1 res.`2 res.`3] = 1%r.
proof. by conseq sha512_x4_absorb_ll (sha512_x4_absorb_correct h0 ms0 a0 o0 s0 l0). qed.

(* ------------------------------------------------------------------ *)
(* The one-shot hashes of the array test unit                         *)

lemma sha256_correct (a0 : BArrayA.t) (o0 l0 : W64.t) :
  hoare [F.sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\ to_uint o0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res = SHA256.sha256 (abytes a0 (to_uint o0) (to_uint l0))].
proof.
proc.
ecall (sha256_finalize_correct SHA256.H0_256 (abytes a0 (to_uint o0) (to_uint l0))).
wp; ecall (sha256_absorb_correct SHA256.H0_256 [] a0 o0 l0).
wp; call sha256_init_correct.
auto => /> hpl hl h1 hh1.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have := stream256_nil SHA256.H0_256 h1 witness<:BArray64.t> hh1; rewrite /stream256 => -[_ [hh0 hp0]].
split; first by do !split => //; smt().
move=> _ _ _ _ _ _ r _ _ _; rewrite size_abytes //; split; first smt().
by move=> _ o ->; rewrite take_oversize // size_digest256 // HMACSpec.size_hash256.
qed.

lemma sha512_correct (a0 : BArrayA.t) (o0 l0 : W64.t) :
  hoare [F.sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\ to_uint o0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res = SHA512.sha512 (abytes a0 (to_uint o0) (to_uint l0))].
proof.
proc.
ecall (sha512_finalize_correct SHA512.H0_512 (abytes a0 (to_uint o0) (to_uint l0))).
wp; ecall (sha512_absorb_correct SHA512.H0_512 [] a0 o0 l0).
wp; call sha512_init_correct.
auto => /> hpl hl h1 hh1.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have := stream512_nil SHA512.H0_512 h1 witness<:BArray128.t> hh1; rewrite /stream512 => -[_ [hh0 hp0]].
split; first by do !split => //; smt().
move=> _ _ _ _ _ _ r _ _ _; rewrite size_abytes //; split; first smt().
by move=> _ o ->; rewrite /SHA512.sha512 /digest take_oversize // size_digest512 // HMACSpec.size_hash512.
qed.

lemma sha256_x8_correct (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  hoare [F.sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             lane_block 32 (BArray256.to_list res) k
             = SHA256.sha256 (abytes a0 (to_uint o0 + k * to_uint s0) (to_uint l0))].
proof.
proc.
ecall (SHA256_X8.sha256_x8_finalize_correct SHA256.H0_256 (mxl a0 (fun _ => []) (to_uint o0) (to_uint s0) (to_uint l0))).
wp; ecall (sha256_x8_absorb_correct SHA256.H0_256 (fun _ => []) a0 o0 s0 l0).
wp; ecall (SHA256_X8.sha256_x8_init_correct).
auto => /> hpl hl h1 hh1.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have [_ hs0] := SHA256_X8.stream8_nil SHA256.H0_256 h1 witness<:BArray512.t> hh1.
split; first by split => //; smt(W64.to_uint_cmp).
move=> _ _ _ _ _ _ r hs _; split.
+ by rewrite (hs 0) // /mxl /= size_mx //; smt(W64.to_uint_cmp).
by move=> _ o hr k hk0 hk1; rewrite /SHA256.sha256 hr // /mxl /mx.
qed.

lemma sha512_x4_correct (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  hoare [F.sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res) k
             = SHA512.sha512 (abytes a0 (to_uint o0 + k * to_uint s0) (to_uint l0))].
proof.
proc.
ecall (SHA512_X4.sha512_x4_finalize_correct SHA512.H0_512 (mxl a0 (fun _ => []) (to_uint o0) (to_uint s0) (to_uint l0))).
wp; ecall (sha512_x4_absorb_correct SHA512.H0_512 (fun _ => []) a0 o0 s0 l0).
wp; ecall (SHA512_X4.sha512_x4_init_correct).
auto => /> hpl hl h1 hh1.
have hl0 : 0 <= to_uint l0 by case: (W64.to_uint_cmp l0).
have [_ hs0] := SHA512_X4.stream4_nil SHA512.H0_512 h1 witness<:BArray512.t> hh1.
split; first by split => //; smt(W64.to_uint_cmp).
move=> _ _ _ _ _ _ r hs _; split.
+ by rewrite (hs 0) // /mxl /= size_mx //; smt(W64.to_uint_cmp).
by move=> _ o hr k hk0 hk1; rewrite /SHA512.sha512 hr // /mxl /mx.
qed.

lemma sha256_ll : islossless F.sha256.
proof. by proc; call sha256_finalize_ll; wp; call sha256_absorb_ll; wp; call sha256_init_ll; auto. qed.

lemma sha256_total (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [F.sha256 :
           a = a0 /\ off = o0 /\ len = l0 /\ to_uint o0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           BArray32.to_list res = SHA256.sha256 (abytes a0 (to_uint o0) (to_uint l0))] = 1%r.
proof. by conseq sha256_ll (sha256_correct a0 o0 l0). qed.

lemma sha512_ll : islossless F.sha512.
proof. by proc; call sha512_finalize_ll; wp; call sha512_absorb_ll; wp; call sha512_init_ll; auto. qed.

lemma sha512_total (a0 : BArrayA.t) (o0 l0 : W64.t) :
  phoare [F.sha512 :
           a = a0 /\ off = o0 /\ len = l0 /\ to_uint o0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           BArray64.to_list res = SHA512.sha512 (abytes a0 (to_uint o0) (to_uint l0))] = 1%r.
proof. by conseq sha512_ll (sha512_correct a0 o0 l0). qed.

lemma sha256_x8_ll : islossless F.sha256_x8.
proof. by proc; call SHA256_X8.sha256_x8_finalize_ll; wp; call sha256_x8_absorb_ll; wp; call SHA256_X8.sha256_x8_init_ll; auto. qed.

lemma sha256_x8_total (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [F.sha256_x8 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 7 * to_uint s0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 8 =>
             lane_block 32 (BArray256.to_list res) k
             = SHA256.sha256 (abytes a0 (to_uint o0 + k * to_uint s0) (to_uint l0))] = 1%r.
proof. by conseq sha256_x8_ll (sha256_x8_correct a0 o0 s0 l0). qed.

lemma sha512_x4_ll : islossless F.sha512_x4.
proof. by proc; call SHA512_X4.sha512_x4_finalize_ll; wp; call sha512_x4_absorb_ll; wp; call SHA512_X4.sha512_x4_init_ll; auto. qed.

lemma sha512_x4_total (a0 : BArrayA.t) (o0 s0 l0 : W64.t) :
  phoare [F.sha512_x4 :
           a = a0 /\ off = o0 /\ stride = s0 /\ len = l0 /\
           to_uint o0 + 3 * to_uint s0 + to_uint l0 <= asize /\ to_uint l0 < 2^61 ==>
           forall k, 0 <= k < 4 =>
             lane_block 64 (BArray256.to_list res) k
             = SHA512.sha512 (abytes a0 (to_uint o0 + k * to_uint s0) (to_uint l0))] = 1%r.
proof. by conseq sha512_x4_ll (sha512_x4_correct a0 o0 s0 l0). qed.

end ArrayForm.
