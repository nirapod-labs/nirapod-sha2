require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

require import
BArray1 BArray28 BArray32 BArray48 BArray64 BArray128 BArray256 BArray333
BArray512 BArray640 SBArray512_64 SBArray512_128.

abbrev sHA512_256_IV =
(BArray64.of_list64
[(W64.of_int 2463787394917988140); (W64.of_int (-6965556091613846334));
(W64.of_int 2563595384472711505); (W64.of_int (-7622211418569250115));
(W64.of_int (-7626776825740460061)); (W64.of_int (-4729309413028513390));
(W64.of_int 3098927326965381290); (W64.of_int 1060366662362279074)]).

abbrev sHA512_224_IV =
(BArray64.of_list64
[(W64.of_int (-8341449602262348382)); (W64.of_int 8350123849800275158);
(W64.of_int 2160240930085379202); (W64.of_int 7466358040605728719);
(W64.of_int 1111592415079452072); (W64.of_int 8638871050018654530);
(W64.of_int 4583966954114332360); (W64.of_int 1230299281376055969)]).

abbrev sHA384_IV =
(BArray64.of_list64
[(W64.of_int (-3766243637369397544)); (W64.of_int 7105036623409894663);
(W64.of_int (-7973340178411365097)); (W64.of_int 1526699215303891257);
(W64.of_int 7436329637833083697); (W64.of_int (-8163818279084223215));
(W64.of_int (-2662702644619276377)); (W64.of_int 5167115440072839076)]).

abbrev sHA512_IV =
(BArray64.of_list64
[(W64.of_int 7640891576956012808); (W64.of_int (-4942790177534073029));
(W64.of_int 4354685564936845355); (W64.of_int (-6534734903238641935));
(W64.of_int 5840696475078001361); (W64.of_int (-7276294671716946913));
(W64.of_int 2270897969802886507); (W64.of_int 6620516959819538809)]).

abbrev sHA512_K =
(BArray640.of_list64
[(W64.of_int 4794697086780616226); (W64.of_int 8158064640168781261);
(W64.of_int (-5349999486874862801)); (W64.of_int (-1606136188198331460));
(W64.of_int 4131703408338449720); (W64.of_int 6480981068601479193);
(W64.of_int (-7908458776815382629)); (W64.of_int (-6116909921290321640));
(W64.of_int (-2880145864133508542)); (W64.of_int 1334009975649890238);
(W64.of_int 2608012711638119052); (W64.of_int 6128411473006802146);
(W64.of_int 8268148722764581231); (W64.of_int (-9160688886553864527));
(W64.of_int (-7215885187991268811)); (W64.of_int (-4495734319001033068));
(W64.of_int (-1973867731355612462)); (W64.of_int (-1171420211273849373));
(W64.of_int 1135362057144423861); (W64.of_int 2597628984639134821);
(W64.of_int 3308224258029322869); (W64.of_int 5365058923640841347);
(W64.of_int 6679025012923562964); (W64.of_int 8573033837759648693);
(W64.of_int (-7476448914759557205)); (W64.of_int (-6327057829258317296));
(W64.of_int (-5763719355590565569)); (W64.of_int (-4658551843659510044));
(W64.of_int (-4116276920077217854)); (W64.of_int (-3051310485924567259));
(W64.of_int 489312712824947311); (W64.of_int 1452737877330783856);
(W64.of_int 2861767655752347644); (W64.of_int 3322285676063803686);
(W64.of_int 5560940570517711597); (W64.of_int 5996557281743188959);
(W64.of_int 7280758554555802590); (W64.of_int 8532644243296465576);
(W64.of_int (-9096487096722542874)); (W64.of_int (-7894198246740708037));
(W64.of_int (-6719396339535248540)); (W64.of_int (-6333637450476146687));
(W64.of_int (-4446306890439682159)); (W64.of_int (-4076793802049405392));
(W64.of_int (-3345356375505022440)); (W64.of_int (-2983346525034927856));
(W64.of_int (-860691631967231958)); (W64.of_int 1182934255886127544);
(W64.of_int 1847814050463011016); (W64.of_int 2177327727835720531);
(W64.of_int 2830643537854262169); (W64.of_int 3796741975233480872);
(W64.of_int 4115178125766777443); (W64.of_int 5681478168544905931);
(W64.of_int 6601373596472566643); (W64.of_int 7507060721942968483);
(W64.of_int 8399075790359081724); (W64.of_int 8693463985226723168);
(W64.of_int (-8878714635349349518)); (W64.of_int (-8302665154208450068));
(W64.of_int (-8016688836872298968)); (W64.of_int (-6606660893046293015));
(W64.of_int (-4685533653050689259)); (W64.of_int (-4147400797238176981));
(W64.of_int (-3880063495543823972)); (W64.of_int (-3348786107499101689));
(W64.of_int (-1523767162380948706)); (W64.of_int (-757361751448694408));
(W64.of_int 500013540394364858); (W64.of_int 748580250866718886);
(W64.of_int 1242879168328830382); (W64.of_int 1977374033974150939);
(W64.of_int 2944078676154940804); (W64.of_int 3659926193048069267);
(W64.of_int 4368137639120453308); (W64.of_int 4836135668995329356);
(W64.of_int 5532061633213252278); (W64.of_int 6448918945643986474);
(W64.of_int 6902733635092675308); (W64.of_int 7801388544844847127)]).

abbrev sHA224_IV =
(BArray32.of_list32
[(W32.of_int (-1056596264)); (W32.of_int 914150663); (W32.of_int 812702999);
(W32.of_int (-150054599)); (W32.of_int (-4191439)); (W32.of_int 1750603025);
(W32.of_int 1694076839); (W32.of_int (-1090891868))]).

abbrev sHA256_IV =
(BArray32.of_list32
[(W32.of_int 1779033703); (W32.of_int (-1150833019));
(W32.of_int 1013904242); (W32.of_int (-1521486534)); (W32.of_int 1359893119);
(W32.of_int (-1694144372)); (W32.of_int 528734635); (W32.of_int 1541459225)]).

abbrev sHA256_K =
(BArray256.of_list32
[(W32.of_int 1116352408); (W32.of_int 1899447441);
(W32.of_int (-1245643825)); (W32.of_int (-373957723));
(W32.of_int 961987163); (W32.of_int 1508970993); (W32.of_int (-1841331548));
(W32.of_int (-1424204075)); (W32.of_int (-670586216));
(W32.of_int 310598401); (W32.of_int 607225278); (W32.of_int 1426881987);
(W32.of_int 1925078388); (W32.of_int (-2132889090));
(W32.of_int (-1680079193)); (W32.of_int (-1046744716));
(W32.of_int (-459576895)); (W32.of_int (-272742522)); (W32.of_int 264347078);
(W32.of_int 604807628); (W32.of_int 770255983); (W32.of_int 1249150122);
(W32.of_int 1555081692); (W32.of_int 1996064986); (W32.of_int (-1740746414));
(W32.of_int (-1473132947)); (W32.of_int (-1341970488));
(W32.of_int (-1084653625)); (W32.of_int (-958395405));
(W32.of_int (-710438585)); (W32.of_int 113926993); (W32.of_int 338241895);
(W32.of_int 666307205); (W32.of_int 773529912); (W32.of_int 1294757372);
(W32.of_int 1396182291); (W32.of_int 1695183700); (W32.of_int 1986661051);
(W32.of_int (-2117940946)); (W32.of_int (-1838011259));
(W32.of_int (-1564481375)); (W32.of_int (-1474664885));
(W32.of_int (-1035236496)); (W32.of_int (-949202525));
(W32.of_int (-778901479)); (W32.of_int (-694614492));
(W32.of_int (-200395387)); (W32.of_int 275423344); (W32.of_int 430227734);
(W32.of_int 506948616); (W32.of_int 659060556); (W32.of_int 883997877);
(W32.of_int 958139571); (W32.of_int 1322822218); (W32.of_int 1537002063);
(W32.of_int 1747873779); (W32.of_int 1955562222); (W32.of_int 2024104815);
(W32.of_int (-2067236844)); (W32.of_int (-1933114872));
(W32.of_int (-1866530822)); (W32.of_int (-1538233109));
(W32.of_int (-1090935817)); (W32.of_int (-965641998))]).

module M = {
  proc __bswap32 (x:W32.t) : W32.t = {
    
    x <- (REV_32 x);
    return x;
  }
  proc __bswap64 (x:W64.t) : W64.t = {
    
    x <- (REV_64 x);
    return x;
  }
  proc __fill64_mem (buf:BArray64.t, dst_:W64.t, p_:W64.t, n_:W64.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var dst:W64.t;
    var p:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    dst <- dst_;
    p <- p_;
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
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      p <- (p + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (loadW64 Glob.mem (W64.to_uint p));
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      dst <- (dst + (W64.of_int 8));
      p <- (p + (W64.of_int 8));
      n <- (n - (W64.of_int 8));
      more <- ((W64.of_int 8) \ule n);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- dst;
    end_0 <- (end_0 + n);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      p <- (p + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc __fill128_mem (buf:BArray128.t, dst_:W64.t, p_:W64.t, n_:W64.t,
                      ms:W64.t) : BArray128.t * W64.t = {
    var dst:W64.t;
    var p:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    dst <- dst_;
    p <- p_;
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
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      p <- (p + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (loadW64 Glob.mem (W64.to_uint p));
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      dst <- (dst + (W64.of_int 8));
      p <- (p + (W64.of_int 8));
      n <- (n - (W64.of_int 8));
      more <- ((W64.of_int 8) \ule n);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- dst;
    end_0 <- (end_0 + n);
    more <- (dst \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      p <- (p + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc __zero64 (buf:BArray64.t, lo_:W64.t, hi:W64.t, ms:W64.t) : BArray64.t *
                                                                  W64.t = {
    var lo:W64.t;
    var z:W64.t;
    var end_0:W64.t;
    var more:bool;
    lo <- lo_;
    z <- (W64.of_int 0);
    end_0 <- lo;
    end_0 <- (end_0 + (W64.of_int 7));
    end_0 <- (end_0 `&` (W64.of_int (- 8)));
    end_0 <- ((hi \ult end_0) ? hi : end_0);
    more <- (lo \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray64.set8 buf (W64.to_uint lo) (truncateu8 z));
      lo <- (lo + (W64.of_int 1));
      more <- (lo \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- lo;
    end_0 <- (end_0 + (W64.of_int 8));
    more <- (end_0 \ule hi);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray64.set64d buf (W64.to_uint lo) z);
      lo <- (lo + (W64.of_int 8));
      end_0 <- lo;
      end_0 <- (end_0 + (W64.of_int 8));
      more <- (end_0 \ule hi);
    }
    ms <- (update_msf (! more) ms);
    more <- (lo \ult hi);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray64.set8 buf (W64.to_uint lo) (truncateu8 z));
      lo <- (lo + (W64.of_int 1));
      more <- (lo \ult hi);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc __zero128 (buf:BArray128.t, lo_:W64.t, hi:W64.t, ms:W64.t) : BArray128.t *
                                                                    W64.t = {
    var lo:W64.t;
    var z:W64.t;
    var end_0:W64.t;
    var more:bool;
    lo <- lo_;
    z <- (W64.of_int 0);
    end_0 <- lo;
    end_0 <- (end_0 + (W64.of_int 7));
    end_0 <- (end_0 `&` (W64.of_int (- 8)));
    end_0 <- ((hi \ult end_0) ? hi : end_0);
    more <- (lo \ult end_0);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray128.set8 buf (W64.to_uint lo) (truncateu8 z));
      lo <- (lo + (W64.of_int 1));
      more <- (lo \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    end_0 <- lo;
    end_0 <- (end_0 + (W64.of_int 8));
    more <- (end_0 \ule hi);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray128.set64d buf (W64.to_uint lo) z);
      lo <- (lo + (W64.of_int 8));
      end_0 <- lo;
      end_0 <- (end_0 + (W64.of_int 8));
      more <- (end_0 \ule hi);
    }
    ms <- (update_msf (! more) ms);
    more <- (lo \ult hi);
    while (more) {
      ms <- (update_msf more ms);
      buf <- (BArray128.set8 buf (W64.to_uint lo) (truncateu8 z));
      lo <- (lo + (W64.of_int 1));
      more <- (lo \ult hi);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc __Sigma0_256 (x:W32.t) : W32.t = {
    var r:W32.t;
    var t:W32.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 2));
    t <- x;
    t <- (t `|>>|` (W8.of_int 13));
    r <- (r `^` t);
    t <- x;
    t <- (t `|>>|` (W8.of_int 22));
    r <- (r `^` t);
    return r;
  }
  proc __Sigma1_256 (x:W32.t) : W32.t = {
    var r:W32.t;
    var t:W32.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 6));
    t <- x;
    t <- (t `|>>|` (W8.of_int 11));
    r <- (r `^` t);
    t <- x;
    t <- (t `|>>|` (W8.of_int 25));
    r <- (r `^` t);
    return r;
  }
  proc __sigma0_256 (x:W32.t) : W32.t = {
    var r:W32.t;
    var t:W32.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 7));
    t <- x;
    t <- (t `|>>|` (W8.of_int 18));
    r <- (r `^` t);
    t <- x;
    t <- (t `>>` (W8.of_int 3));
    r <- (r `^` t);
    return r;
  }
  proc __sigma1_256 (x:W32.t) : W32.t = {
    var r:W32.t;
    var t:W32.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 17));
    t <- x;
    t <- (t `|>>|` (W8.of_int 19));
    r <- (r `^` t);
    t <- x;
    t <- (t `>>` (W8.of_int 10));
    r <- (r `^` t);
    return r;
  }
  proc __sha256_rounds (h:BArray32.t, w:BArray64.t) : BArray32.t = {
    var i:int;
    var v:BArray32.t;
    var t:int;
    var t1:W32.t;
    var x:W32.t;
    var k:BArray256.t;
    var y:W32.t;
    k <- witness;
    v <- witness;
    i <- 0;
    while ((i < 8)) {
      v <- (BArray32.set32 v i (BArray32.get32 h i));
      i <- (i + 1);
    }
    t <- 0;
    while ((t < 64)) {
      if ((16 <= t)) {
        x <- (BArray64.get32 w ((t - 2) %% 16));
        t1 <@ __sigma1_256 (x);
        x <- (BArray64.get32 w ((t - 15) %% 16));
        x <@ __sigma0_256 (x);
        t1 <- (t1 + x);
        x <- (BArray64.get32 w ((t - 7) %% 16));
        t1 <- (t1 + x);
        x <- (BArray64.get32 w (t %% 16));
        t1 <- (t1 + x);
        w <- (BArray64.set32 w (t %% 16) t1);
      } else {
        t1 <- (BArray64.get32 w t);
      }
      t1 <- (t1 + (BArray32.get32 v (((7 + 64) - t) %% 8)));
      x <@ __Sigma1_256 ((BArray32.get32 v (((4 + 64) - t) %% 8)));
      t1 <- (t1 + x);
      x <- (BArray32.get32 v (((5 + 64) - t) %% 8));
      x <- (x `^` (BArray32.get32 v (((6 + 64) - t) %% 8)));
      x <- (x `&` (BArray32.get32 v (((4 + 64) - t) %% 8)));
      x <- (x `^` (BArray32.get32 v (((6 + 64) - t) %% 8)));
      t1 <- (t1 + x);
      k <- sHA256_K;
      x <- (BArray256.get32 k t);
      t1 <- (t1 + x);
      v <-
      (BArray32.set32 v (((3 + 64) - t) %% 8)
      ((BArray32.get32 v (((3 + 64) - t) %% 8)) + t1));
      x <@ __Sigma0_256 ((BArray32.get32 v (((0 + 64) - t) %% 8)));
      t1 <- (t1 + x);
      x <- (BArray32.get32 v (((0 + 64) - t) %% 8));
      x <- (x `^` (BArray32.get32 v (((1 + 64) - t) %% 8)));
      x <- (x `&` (BArray32.get32 v (((2 + 64) - t) %% 8)));
      y <- (BArray32.get32 v (((0 + 64) - t) %% 8));
      y <- (y `&` (BArray32.get32 v (((1 + 64) - t) %% 8)));
      x <- (x `^` y);
      t1 <- (t1 + x);
      v <- (BArray32.set32 v (((7 + 64) - t) %% 8) t1);
      t <- (t + 1);
    }
    i <- 0;
    while ((i < 8)) {
      x <- (BArray32.get32 h i);
      x <- (x + (BArray32.get32 v i));
      h <- (BArray32.set32 h i x);
      i <- (i + 1);
    }
    return h;
  }
  proc _sha256_compress (h:BArray32.t, block:BArray64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var i:int;
    var x:W32.t;
    var w:BArray64.t;
    w <- witness;
    i <- 0;
    while ((i < 16)) {
      x <- (BArray64.get32 block i);
      x <@ __bswap32 (x);
      w <- (BArray64.set32 w i x);
      i <- (i + 1);
    }
    h <@ __sha256_rounds (h, w);
    return (h, ms);
  }
  proc _sha256_compress_one (h:BArray32.t, p:W64.t, ms:W64.t) : BArray32.t *
                                                                W64.t = {
    var i:int;
    var x:W32.t;
    var w:BArray64.t;
    w <- witness;
    i <- 0;
    while ((i < 16)) {
      x <- (loadW32 Glob.mem (W64.to_uint (p + (W64.of_int (4 * i)))));
      x <@ __bswap32 (x);
      w <- (BArray64.set32 w i x);
      i <- (i + 1);
    }
    h <@ __sha256_rounds (h, w);
    return (h, ms);
  }
  proc _sha256_compress_blocks (h:BArray32.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var more:bool;
    more <- (n <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress_one (h, p, ms);
      (* Erased call to unspill *)
      p <- (protect_64 p ms);
      n <- (protect_64 n ms);
      p <- (p + (W64.of_int 64));
      n <- (n - (W64.of_int 1));
      more <- (n <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    return (h, ms);
  }
  proc __sha256_init (h:BArray32.t) : BArray32.t = {
    var iv:BArray32.t;
    var i:int;
    var t:W32.t;
    iv <- witness;
    iv <- sHA256_IV;
    i <- 0;
    while ((i < 8)) {
      t <- (BArray32.get32 iv i);
      h <- (BArray32.set32 h i t);
      i <- (i + 1);
    }
    return h;
  }
  proc __sha224_init (h:BArray32.t) : BArray32.t = {
    var iv:BArray32.t;
    var i:int;
    var t:W32.t;
    iv <- witness;
    iv <- sHA224_IV;
    i <- 0;
    while ((i < 8)) {
      t <- (BArray32.get32 iv i);
      h <- (BArray32.set32 h i t);
      i <- (i + 1);
    }
    return h;
  }
  proc _sha256_absorb_mem (h:BArray32.t, buf:BArray64.t, total:W64.t,
                           in_0:W64.t, inlen:W64.t, ms:W64.t) : BArray32.t *
                                                                BArray64.t *
                                                                W64.t * W64.t = {
    var fill:W64.t;
    var n:W64.t;
    var full:bool;
    var off:W64.t;
    var more:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    total <- (total + inlen);
    n <- (W64.of_int 64);
    n <- (n - fill);
    n <- ((inlen \ult n) ? inlen : n);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    inlen <- (inlen - n);
    (buf, ms) <@ __fill64_mem (buf, fill, in_0, n, ms);
    fill <- (fill + n);
    in_0 <- (in_0 + n);
    full <- (fill = (W64.of_int 64));
    if (full) {
      ms <- (update_msf full ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress (h, buf, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_64 in_0 ms);
      inlen <- (protect_64 inlen ms);
      buf <- (protect_ptr buf ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! full) ms);
    }
    off <- (W64.of_int 0);
    n <- inlen;
    n <- (n `>>` (W8.of_int 6));
    more <- (n <> (W64.of_int 0));
    if (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress_blocks (h, in_0, n, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_64 in_0 ms);
      inlen <- (protect_64 inlen ms);
      buf <- (protect_ptr buf ms);
      off <- inlen;
      off <- (off `>>` (W8.of_int 6));
      off <- (off `<<` (W8.of_int 6));
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! more) ms);
    }
    inlen <- (inlen - off);
    in_0 <- (in_0 + off);
    (buf, ms) <@ __fill64_mem (buf, fill, in_0, inlen, ms);
    return (h, buf, total, ms);
  }
  proc _sha256___sha256_finalize (out:BArray32.t, h:BArray32.t,
                                  buf:BArray64.t, total:W64.t, ms:W64.t) : 
  BArray32.t * BArray32.t * BArray64.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    t <- (W64.of_int 128);
    buf <- (BArray64.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 56) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 64);
      (buf, ms) <@ __zero64 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 56);
    (buf, ms) <@ __zero64 (buf, fill, hi, ms);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray64.set64d buf 56 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha256_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (32 %/ 4);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray32.get32 h i);
      x <@ __bswap32 (x);
      out <- (BArray32.set32 out i x);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha256____sha256_mem_from (out:BArray32.t, h:BArray32.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t) : BArray32.t *
                                                            W64.t = {
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha256_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha256___sha256_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc _sha224___sha256_finalize (out:BArray28.t, h:BArray32.t,
                                  buf:BArray64.t, total:W64.t, ms:W64.t) : 
  BArray28.t * BArray32.t * BArray64.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    t <- (W64.of_int 128);
    buf <- (BArray64.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 56) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 64);
      (buf, ms) <@ __zero64 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 56);
    (buf, ms) <@ __zero64 (buf, fill, hi, ms);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray64.set64d buf 56 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha256_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (28 %/ 4);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray32.get32 h i);
      x <@ __bswap32 (x);
      out <- (BArray28.set32 out i x);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha224____sha256_mem_from (out:BArray28.t, h:BArray32.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t) : BArray28.t *
                                                            W64.t = {
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha256_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha224___sha256_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc _sha256_mem (out:BArray32.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var h:BArray32.t;
    h <- witness;
    h <@ __sha256_init (h);
    (out, ms) <@ _sha256____sha256_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc _sha224_mem (out:BArray28.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray28.t * W64.t = {
    var h:BArray32.t;
    h <- witness;
    h <@ __sha224_init (h);
    (out, ms) <@ _sha224____sha256_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc __Sigma0_512 (x:W64.t) : W64.t = {
    var r:W64.t;
    var t:W64.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 28));
    t <- x;
    t <- (t `|>>|` (W8.of_int 34));
    r <- (r `^` t);
    t <- x;
    t <- (t `|>>|` (W8.of_int 39));
    r <- (r `^` t);
    return r;
  }
  proc __Sigma1_512 (x:W64.t) : W64.t = {
    var r:W64.t;
    var t:W64.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 14));
    t <- x;
    t <- (t `|>>|` (W8.of_int 18));
    r <- (r `^` t);
    t <- x;
    t <- (t `|>>|` (W8.of_int 41));
    r <- (r `^` t);
    return r;
  }
  proc __sigma0_512 (x:W64.t) : W64.t = {
    var r:W64.t;
    var t:W64.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 1));
    t <- x;
    t <- (t `|>>|` (W8.of_int 8));
    r <- (r `^` t);
    t <- x;
    t <- (t `>>` (W8.of_int 7));
    r <- (r `^` t);
    return r;
  }
  proc __sigma1_512 (x:W64.t) : W64.t = {
    var r:W64.t;
    var t:W64.t;
    r <- x;
    r <- (r `|>>|` (W8.of_int 19));
    t <- x;
    t <- (t `|>>|` (W8.of_int 61));
    r <- (r `^` t);
    t <- x;
    t <- (t `>>` (W8.of_int 6));
    r <- (r `^` t);
    return r;
  }
  proc __sha512_rounds (h:BArray64.t, w:BArray128.t) : BArray64.t = {
    var i:int;
    var v:BArray64.t;
    var t:int;
    var t1:W64.t;
    var x:W64.t;
    var k:BArray640.t;
    var y:W64.t;
    k <- witness;
    v <- witness;
    i <- 0;
    while ((i < 8)) {
      v <- (BArray64.set64 v i (BArray64.get64 h i));
      i <- (i + 1);
    }
    t <- 0;
    while ((t < 80)) {
      if ((16 <= t)) {
        x <- (BArray128.get64 w ((t - 2) %% 16));
        t1 <@ __sigma1_512 (x);
        x <- (BArray128.get64 w ((t - 15) %% 16));
        x <@ __sigma0_512 (x);
        t1 <- (t1 + x);
        x <- (BArray128.get64 w ((t - 7) %% 16));
        t1 <- (t1 + x);
        x <- (BArray128.get64 w (t %% 16));
        t1 <- (t1 + x);
        w <- (BArray128.set64 w (t %% 16) t1);
      } else {
        t1 <- (BArray128.get64 w t);
      }
      t1 <- (t1 + (BArray64.get64 v (((7 + 80) - t) %% 8)));
      x <@ __Sigma1_512 ((BArray64.get64 v (((4 + 80) - t) %% 8)));
      t1 <- (t1 + x);
      x <- (BArray64.get64 v (((5 + 80) - t) %% 8));
      x <- (x `^` (BArray64.get64 v (((6 + 80) - t) %% 8)));
      x <- (x `&` (BArray64.get64 v (((4 + 80) - t) %% 8)));
      x <- (x `^` (BArray64.get64 v (((6 + 80) - t) %% 8)));
      t1 <- (t1 + x);
      k <- sHA512_K;
      x <- (BArray640.get64 k t);
      t1 <- (t1 + x);
      v <-
      (BArray64.set64 v (((3 + 80) - t) %% 8)
      ((BArray64.get64 v (((3 + 80) - t) %% 8)) + t1));
      x <@ __Sigma0_512 ((BArray64.get64 v (((0 + 80) - t) %% 8)));
      t1 <- (t1 + x);
      x <- (BArray64.get64 v (((0 + 80) - t) %% 8));
      x <- (x `^` (BArray64.get64 v (((1 + 80) - t) %% 8)));
      x <- (x `&` (BArray64.get64 v (((2 + 80) - t) %% 8)));
      y <- (BArray64.get64 v (((0 + 80) - t) %% 8));
      y <- (y `&` (BArray64.get64 v (((1 + 80) - t) %% 8)));
      x <- (x `^` y);
      t1 <- (t1 + x);
      v <- (BArray64.set64 v (((7 + 80) - t) %% 8) t1);
      t <- (t + 1);
    }
    i <- 0;
    while ((i < 8)) {
      x <- (BArray64.get64 h i);
      x <- (x + (BArray64.get64 v i));
      h <- (BArray64.set64 h i x);
      i <- (i + 1);
    }
    return h;
  }
  proc _sha512_compress (h:BArray64.t, block:BArray128.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var i:int;
    var x:W64.t;
    var w:BArray128.t;
    w <- witness;
    i <- 0;
    while ((i < 16)) {
      x <- (BArray128.get64 block i);
      x <@ __bswap64 (x);
      w <- (BArray128.set64 w i x);
      i <- (i + 1);
    }
    h <@ __sha512_rounds (h, w);
    return (h, ms);
  }
  proc _sha512_compress_one (h:BArray64.t, p:W64.t, ms:W64.t) : BArray64.t *
                                                                W64.t = {
    var i:int;
    var x:W64.t;
    var w:BArray128.t;
    w <- witness;
    i <- 0;
    while ((i < 16)) {
      x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
      x <@ __bswap64 (x);
      w <- (BArray128.set64 w i x);
      i <- (i + 1);
    }
    h <@ __sha512_rounds (h, w);
    return (h, ms);
  }
  proc _sha512_compress_blocks (h:BArray64.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var more:bool;
    more <- (n <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress_one (h, p, ms);
      (* Erased call to unspill *)
      p <- (protect_64 p ms);
      n <- (protect_64 n ms);
      p <- (p + (W64.of_int 128));
      n <- (n - (W64.of_int 1));
      more <- (n <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    return (h, ms);
  }
  proc __sha512_load_iv (h:BArray64.t, iv:BArray64.t) : BArray64.t = {
    var i:int;
    var t:W64.t;
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 iv i);
      h <- (BArray64.set64 h i t);
      i <- (i + 1);
    }
    return h;
  }
  proc __sha512_init (h:BArray64.t) : BArray64.t = {
    
    h <@ __sha512_load_iv (h, sHA512_IV);
    return h;
  }
  proc __sha384_init (h:BArray64.t) : BArray64.t = {
    
    h <@ __sha512_load_iv (h, sHA384_IV);
    return h;
  }
  proc __sha512_224_init (h:BArray64.t) : BArray64.t = {
    
    h <@ __sha512_load_iv (h, sHA512_224_IV);
    return h;
  }
  proc __sha512_256_init (h:BArray64.t) : BArray64.t = {
    
    h <@ __sha512_load_iv (h, sHA512_256_IV);
    return h;
  }
  proc _sha512_absorb_mem (h:BArray64.t, buf:BArray128.t, total:W64.t,
                           in_0:W64.t, inlen:W64.t, ms:W64.t) : BArray64.t *
                                                                BArray128.t *
                                                                W64.t * W64.t = {
    var fill:W64.t;
    var n:W64.t;
    var full:bool;
    var off:W64.t;
    var more:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    total <- (total + inlen);
    n <- (W64.of_int 128);
    n <- (n - fill);
    n <- ((inlen \ult n) ? inlen : n);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    inlen <- (inlen - n);
    (buf, ms) <@ __fill128_mem (buf, fill, in_0, n, ms);
    fill <- (fill + n);
    in_0 <- (in_0 + n);
    full <- (fill = (W64.of_int 128));
    if (full) {
      ms <- (update_msf full ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h, buf, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_64 in_0 ms);
      inlen <- (protect_64 inlen ms);
      buf <- (protect_ptr buf ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! full) ms);
    }
    off <- (W64.of_int 0);
    n <- inlen;
    n <- (n `>>` (W8.of_int 7));
    more <- (n <> (W64.of_int 0));
    if (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress_blocks (h, in_0, n, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_64 in_0 ms);
      inlen <- (protect_64 inlen ms);
      buf <- (protect_ptr buf ms);
      off <- inlen;
      off <- (off `>>` (W8.of_int 7));
      off <- (off `<<` (W8.of_int 7));
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! more) ms);
    }
    inlen <- (inlen - off);
    in_0 <- (in_0 + off);
    (buf, ms) <@ __fill128_mem (buf, fill, in_0, inlen, ms);
    return (h, buf, total, ms);
  }
  proc _sha512___sha512_finalize (out:BArray64.t, h:BArray64.t,
                                  buf:BArray128.t, total:W64.t, ms:W64.t) : 
  BArray64.t * BArray64.t * BArray128.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    t <- (W64.of_int 128);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      (buf, ms) <@ __zero128 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    (buf, ms) <@ __zero128 (buf, fill, hi, ms);
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 112 t);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 120 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha512_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (64 %/ 8);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <@ __bswap64 (x);
      out <- (BArray64.set64 out i x);
      i <- (i + 1);
    }
    inc <- ((64 + 7) %/ 8);
    i <- (64 %/ 8);
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <- (x `>>` (W8.of_int 32));
      y <- (truncateu32 x);
      y <@ __bswap32 (y);
      out <- (BArray64.set32 out (2 * i) y);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha512____sha512_mem_from (out:BArray64.t, h:BArray64.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t) : BArray64.t *
                                                            W64.t = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha512_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha512___sha512_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc _sha384___sha512_finalize (out:BArray48.t, h:BArray64.t,
                                  buf:BArray128.t, total:W64.t, ms:W64.t) : 
  BArray48.t * BArray64.t * BArray128.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    t <- (W64.of_int 128);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      (buf, ms) <@ __zero128 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    (buf, ms) <@ __zero128 (buf, fill, hi, ms);
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 112 t);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 120 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha512_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (48 %/ 8);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <@ __bswap64 (x);
      out <- (BArray48.set64 out i x);
      i <- (i + 1);
    }
    inc <- ((48 + 7) %/ 8);
    i <- (48 %/ 8);
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <- (x `>>` (W8.of_int 32));
      y <- (truncateu32 x);
      y <@ __bswap32 (y);
      out <- (BArray48.set32 out (2 * i) y);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha384____sha512_mem_from (out:BArray48.t, h:BArray64.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t) : BArray48.t *
                                                            W64.t = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha512_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha384___sha512_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc _sha512_224___sha512_finalize (out:BArray28.t, h:BArray64.t,
                                      buf:BArray128.t, total:W64.t, ms:W64.t) : 
  BArray28.t * BArray64.t * BArray128.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    t <- (W64.of_int 128);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      (buf, ms) <@ __zero128 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    (buf, ms) <@ __zero128 (buf, fill, hi, ms);
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 112 t);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 120 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha512_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (28 %/ 8);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <@ __bswap64 (x);
      out <- (BArray28.set64 out i x);
      i <- (i + 1);
    }
    inc <- ((28 + 7) %/ 8);
    i <- (28 %/ 8);
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <- (x `>>` (W8.of_int 32));
      y <- (truncateu32 x);
      y <@ __bswap32 (y);
      out <- (BArray28.set32 out (2 * i) y);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha512_224____sha512_mem_from (out:BArray28.t, h:BArray64.t,
                                       in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray28.t * W64.t = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha512_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha512_224___sha512_finalize (out, h, buf, 
    total, ms);
    return (out, ms);
  }
  proc _sha512_256___sha512_finalize (out:BArray32.t, h:BArray64.t,
                                      buf:BArray128.t, total:W64.t, ms:W64.t) : 
  BArray32.t * BArray64.t * BArray128.t * W64.t = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    t <- (W64.of_int 128);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      (buf, ms) <@ __zero128 (buf, fill, hi, ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    (buf, ms) <@ __zero128 (buf, fill, hi, ms);
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 112 t);
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    buf <- (BArray128.set64d buf 120 t);
    (* Erased call to spill *)
    (h, ms) <@ _sha512_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    inc <- (32 %/ 8);
    i <- 0;
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <@ __bswap64 (x);
      out <- (BArray32.set64 out i x);
      i <- (i + 1);
    }
    inc <- ((32 + 7) %/ 8);
    i <- (32 %/ 8);
    while ((i < inc)) {
      x <- (BArray64.get64 h i);
      x <- (x `>>` (W8.of_int 32));
      y <- (truncateu32 x);
      y <@ __bswap32 (y);
      out <- (BArray32.set32 out (2 * i) y);
      i <- (i + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha512_256____sha512_mem_from (out:BArray32.t, h:BArray64.t,
                                       in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha512_absorb_mem (h, buf, total, in_0, inlen,
    ms);
    (* Erased call to unspill *)
    (out, h, buf, ms) <@ _sha512_256___sha512_finalize (out, h, buf, 
    total, ms);
    return (out, ms);
  }
  proc _sha512_mem (out:BArray64.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var h:BArray64.t;
    h <- witness;
    h <@ __sha512_init (h);
    (out, ms) <@ _sha512____sha512_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc _sha384_mem (out:BArray48.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray48.t * W64.t = {
    var h:BArray64.t;
    h <- witness;
    h <@ __sha384_init (h);
    (out, ms) <@ _sha384____sha512_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc _sha512_224_mem (out:BArray28.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray28.t * W64.t = {
    var h:BArray64.t;
    h <- witness;
    h <@ __sha512_224_init (h);
    (out, ms) <@ _sha512_224____sha512_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc _sha512_256_mem (out:BArray32.t, in_0:W64.t, inlen:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var h:BArray64.t;
    h <- witness;
    h <@ __sha512_256_init (h);
    (out, ms) <@ _sha512_256____sha512_mem_from (out, h, in_0, inlen, ms);
    return (out, ms);
  }
  proc _sha256_x8_compress (h8:BArray256.t, blocks:BArray512.t, ms:W64.t) : 
  BArray256.t * W64.t = {
    var k:int;
    var j:int;
    var x:W32.t;
    var h:BArray32.t;
    h <- witness;
    k <- 0;
    while ((k < 8)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get32 h8 ((8 * j) + k));
        h <- (BArray32.set32 h j x);
        j <- (j + 1);
      }
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress (h,
      (SBArray512_64.get_sub8 blocks (64 * k)), ms);
      (* Erased call to unspill *)
      h8 <- (protect_ptr h8 ms);
      blocks <- (protect_ptr blocks ms);
      j <- 0;
      while ((j < 8)) {
        x <- (BArray32.get32 h j);
        h8 <- (BArray256.set32 h8 ((8 * j) + k) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (h8, ms);
  }
  proc _sha256_x8_compress_lanes (h8:BArray256.t, in_0:BArray64.t, off:W64.t,
                                  n:W64.t, ms:W64.t) : BArray256.t * W64.t = {
    var k:int;
    var j:int;
    var x:W32.t;
    var h:BArray32.t;
    var p:W64.t;
    h <- witness;
    k <- 0;
    while ((k < 8)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get32 h8 ((8 * j) + k));
        h <- (BArray32.set32 h j x);
        j <- (j + 1);
      }
      p <- (BArray64.get64 in_0 k);
      p <- (protect_64 p ms);
      p <- (p + off);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_compress_blocks (h, p, n, ms);
      (* Erased call to unspill *)
      h8 <- (protect_ptr h8 ms);
      in_0 <- (protect_ptr in_0 ms);
      off <- (protect_64 off ms);
      n <- (protect_64 n ms);
      j <- 0;
      while ((j < 8)) {
        x <- (BArray32.get32 h j);
        h8 <- (BArray256.set32 h8 ((8 * j) + k) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (h8, ms);
  }
  proc __sha256_x8_init (h:BArray256.t) : BArray256.t = {
    var iv:BArray32.t;
    var j:int;
    var t:W32.t;
    var k:int;
    iv <- witness;
    iv <- sHA256_IV;
    j <- 0;
    while ((j < 8)) {
      t <- (BArray32.get32 iv j);
      k <- 0;
      while ((k < 8)) {
        h <- (BArray256.set32 h ((8 * j) + k) t);
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    return h;
  }
  proc __sha256_x8_from (h:BArray256.t, buf:BArray512.t, hs:BArray32.t,
                         bs:BArray64.t) : BArray256.t * BArray512.t = {
    var j:int;
    var x:W32.t;
    var k:int;
    var i:int;
    var t:W64.t;
    j <- 0;
    while ((j < 8)) {
      x <- (BArray32.get32 hs j);
      k <- 0;
      while ((k < 8)) {
        h <- (BArray256.set32 h ((8 * j) + k) x);
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 bs i);
      k <- 0;
      while ((k < 8)) {
        buf <- (BArray512.set64d buf ((64 * k) + (8 * i)) t);
        k <- (k + 1);
      }
      i <- (i + 1);
    }
    return (h, buf);
  }
  proc _sha256_x8_absorb_lanes (h:BArray256.t, buf:BArray512.t, total:W64.t,
                                in_0:BArray64.t, inlen:W64.t, ms:W64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t = {
    var aux:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var n:W64.t;
    var k:int;
    var p:W64.t;
    var off:W64.t;
    var full:bool;
    var more:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    total <- (total + inlen);
    n <- (W64.of_int 64);
    n <- (n - fill);
    n <- ((inlen \ult n) ? inlen : n);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    k <- 0;
    while ((k < 8)) {
      p <- (BArray64.get64 in_0 k);
      p <- (protect_64 p ms);
      (aux, aux_0) <@ __fill64_mem ((SBArray512_64.get_sub8 buf (64 * k)),
      fill, p, n, ms);
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    fill <- (fill + n);
    off <- n;
    full <- (fill = (W64.of_int 64));
    if (full) {
      ms <- (update_msf full ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_x8_compress (h, buf, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_ptr in_0 ms);
      inlen <- (protect_64 inlen ms);
      off <- (protect_64 off ms);
      buf <- (protect_ptr buf ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! full) ms);
    }
    n <- inlen;
    n <- (n - off);
    n <- (n `>>` (W8.of_int 6));
    more <- (n <> (W64.of_int 0));
    if (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha256_x8_compress_lanes (h, in_0, off, n, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_ptr in_0 ms);
      inlen <- (protect_64 inlen ms);
      off <- (protect_64 off ms);
      buf <- (protect_ptr buf ms);
      n <- inlen;
      n <- (n - off);
      n <- (n `>>` (W8.of_int 6));
      n <- (n `<<` (W8.of_int 6));
      off <- (off + n);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! more) ms);
    }
    n <- inlen;
    n <- (n - off);
    k <- 0;
    while ((k < 8)) {
      p <- (BArray64.get64 in_0 k);
      p <- (protect_64 p ms);
      p <- (p + off);
      (aux, aux_0) <@ __fill64_mem ((SBArray512_64.get_sub8 buf (64 * k)),
      fill, p, n, ms);
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    return (h, buf, total, ms);
  }
  proc _sha256_x8_finalize (out:BArray256.t, h:BArray256.t, buf:BArray512.t,
                            total:W64.t, ms:W64.t) : BArray256.t *
                                                     BArray256.t *
                                                     BArray512.t * W64.t = {
    var aux:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var at:W64.t;
    var t:W64.t;
    var k:int;
    var two_blocks:bool;
    var hi:W64.t;
    var j:int;
    var x:W32.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 63));
    at <- fill;
    t <- (W64.of_int 128);
    k <- 0;
    while ((k < 8)) {
      buf <- (BArray512.set8 buf (W64.to_uint at) (truncateu8 t));
      at <- (at + (W64.of_int 64));
      k <- (k + 1);
    }
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 56) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 64);
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ __zero64 ((SBArray512_64.get_sub8 buf (64 * k)),
        fill, hi, ms);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        k <- (k + 1);
      }
      (* Erased call to spill *)
      (h, ms) <@ _sha256_x8_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 56);
    k <- 0;
    while ((k < 8)) {
      (aux, aux_0) <@ __zero64 ((SBArray512_64.get_sub8 buf (64 * k)), 
      fill, hi, ms);
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    t <- total;
    t <- (t `<<` (W8.of_int 3));
    t <@ __bswap64 (t);
    k <- 0;
    while ((k < 8)) {
      buf <- (BArray512.set64d buf ((64 * k) + 56) t);
      k <- (k + 1);
    }
    (* Erased call to spill *)
    (h, ms) <@ _sha256_x8_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    k <- 0;
    while ((k < 8)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get32 h ((8 * j) + k));
        x <@ __bswap32 (x);
        out <- (BArray256.set32 out ((8 * k) + j) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha256_x8_lanes (out:BArray256.t, in_0:BArray64.t, len:W64.t,
                         ms:W64.t) : BArray256.t * W64.t = {
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    h <@ __sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha256_x8_absorb_lanes (h, buf, total, in_0, 
    len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256_x8_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc _sha512_x4_compress (h4:BArray256.t, blocks:BArray512.t, ms:W64.t) : 
  BArray256.t * W64.t = {
    var k:int;
    var j:int;
    var x:W64.t;
    var h:BArray64.t;
    h <- witness;
    k <- 0;
    while ((k < 4)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get64 h4 ((4 * j) + k));
        h <- (BArray64.set64 h j x);
        j <- (j + 1);
      }
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress (h,
      (SBArray512_128.get_sub8 blocks (128 * k)), ms);
      (* Erased call to unspill *)
      h4 <- (protect_ptr h4 ms);
      blocks <- (protect_ptr blocks ms);
      j <- 0;
      while ((j < 8)) {
        x <- (BArray64.get64 h j);
        h4 <- (BArray256.set64 h4 ((4 * j) + k) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (h4, ms);
  }
  proc _sha512_x4_compress_lanes (h4:BArray256.t, in_0:BArray32.t, off:W64.t,
                                  n:W64.t, ms:W64.t) : BArray256.t * W64.t = {
    var k:int;
    var j:int;
    var x:W64.t;
    var h:BArray64.t;
    var p:W64.t;
    h <- witness;
    k <- 0;
    while ((k < 4)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get64 h4 ((4 * j) + k));
        h <- (BArray64.set64 h j x);
        j <- (j + 1);
      }
      p <- (BArray32.get64 in_0 k);
      p <- (protect_64 p ms);
      p <- (p + off);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress_blocks (h, p, n, ms);
      (* Erased call to unspill *)
      h4 <- (protect_ptr h4 ms);
      in_0 <- (protect_ptr in_0 ms);
      off <- (protect_64 off ms);
      n <- (protect_64 n ms);
      j <- 0;
      while ((j < 8)) {
        x <- (BArray64.get64 h j);
        h4 <- (BArray256.set64 h4 ((4 * j) + k) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (h4, ms);
  }
  proc __sha512_x4_init (h:BArray256.t) : BArray256.t = {
    var iv:BArray64.t;
    var j:int;
    var t:W64.t;
    var k:int;
    iv <- witness;
    iv <- sHA512_IV;
    j <- 0;
    while ((j < 8)) {
      t <- (BArray64.get64 iv j);
      k <- 0;
      while ((k < 4)) {
        h <- (BArray256.set64 h ((4 * j) + k) t);
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    return h;
  }
  proc __sha512_x4_from (h:BArray256.t, buf:BArray512.t, hs:BArray64.t,
                         bs:BArray128.t) : BArray256.t * BArray512.t = {
    var j:int;
    var x:W64.t;
    var k:int;
    var i:int;
    var t:W64.t;
    j <- 0;
    while ((j < 8)) {
      x <- (BArray64.get64 hs j);
      k <- 0;
      while ((k < 4)) {
        h <- (BArray256.set64 h ((4 * j) + k) x);
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    i <- 0;
    while ((i < 16)) {
      t <- (BArray128.get64 bs i);
      k <- 0;
      while ((k < 4)) {
        buf <- (BArray512.set64d buf ((128 * k) + (8 * i)) t);
        k <- (k + 1);
      }
      i <- (i + 1);
    }
    return (h, buf);
  }
  proc _sha512_x4_absorb_lanes (h:BArray256.t, buf:BArray512.t, total:W64.t,
                                in_0:BArray32.t, inlen:W64.t, ms:W64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t = {
    var aux:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var n:W64.t;
    var k:int;
    var p:W64.t;
    var off:W64.t;
    var full:bool;
    var more:bool;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    total <- (total + inlen);
    n <- (W64.of_int 128);
    n <- (n - fill);
    n <- ((inlen \ult n) ? inlen : n);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    k <- 0;
    while ((k < 4)) {
      p <- (BArray32.get64 in_0 k);
      p <- (protect_64 p ms);
      (aux, aux_0) <@ __fill128_mem ((SBArray512_128.get_sub8 buf (128 * k)),
      fill, p, n, ms);
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    fill <- (fill + n);
    off <- n;
    full <- (fill = (W64.of_int 128));
    if (full) {
      ms <- (update_msf full ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_x4_compress (h, buf, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_ptr in_0 ms);
      inlen <- (protect_64 inlen ms);
      off <- (protect_64 off ms);
      buf <- (protect_ptr buf ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! full) ms);
    }
    n <- inlen;
    n <- (n - off);
    n <- (n `>>` (W8.of_int 7));
    more <- (n <> (W64.of_int 0));
    if (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_x4_compress_lanes (h, in_0, off, n, ms);
      (* Erased call to unspill *)
      total <- (protect_64 total ms);
      in_0 <- (protect_ptr in_0 ms);
      inlen <- (protect_64 inlen ms);
      off <- (protect_64 off ms);
      buf <- (protect_ptr buf ms);
      n <- inlen;
      n <- (n - off);
      n <- (n `>>` (W8.of_int 7));
      n <- (n `<<` (W8.of_int 7));
      off <- (off + n);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! more) ms);
    }
    n <- inlen;
    n <- (n - off);
    k <- 0;
    while ((k < 4)) {
      p <- (BArray32.get64 in_0 k);
      p <- (protect_64 p ms);
      p <- (p + off);
      (aux, aux_0) <@ __fill128_mem ((SBArray512_128.get_sub8 buf (128 * k)),
      fill, p, n, ms);
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    return (h, buf, total, ms);
  }
  proc _sha512_x4_finalize (out:BArray256.t, h:BArray256.t, buf:BArray512.t,
                            total:W64.t, ms:W64.t) : BArray256.t *
                                                     BArray256.t *
                                                     BArray512.t * W64.t = {
    var aux:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var at:W64.t;
    var t:W64.t;
    var k:int;
    var two_blocks:bool;
    var hi:W64.t;
    var u:W64.t;
    var j:int;
    var x:W64.t;
    fill <- total;
    fill <- (fill `&` (W64.of_int 127));
    at <- fill;
    t <- (W64.of_int 128);
    k <- 0;
    while ((k < 4)) {
      buf <- (BArray512.set8 buf (W64.to_uint at) (truncateu8 t));
      at <- (at + (W64.of_int 128));
      k <- (k + 1);
    }
    fill <- (fill + (W64.of_int 1));
    two_blocks <- ((W64.of_int 112) \ult fill);
    if (two_blocks) {
      ms <- (update_msf two_blocks ms);
      hi <- (W64.of_int 128);
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ __zero128 ((SBArray512_128.get_sub8 buf (128 * k)),
        fill, hi, ms);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        k <- (k + 1);
      }
      (* Erased call to spill *)
      (h, ms) <@ _sha512_x4_compress (h, buf, ms);
      (* Erased call to unspill *)
      out <- (protect_ptr out ms);
      buf <- (protect_ptr buf ms);
      total <- (protect_64 total ms);
      fill <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! two_blocks) ms);
    }
    hi <- (W64.of_int 112);
    k <- 0;
    while ((k < 4)) {
      (aux, aux_0) <@ __zero128 ((SBArray512_128.get_sub8 buf (128 * k)),
      fill, hi, ms);
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      k <- (k + 1);
    }
    t <- total;
    t <- (t `>>` (W8.of_int 61));
    t <@ __bswap64 (t);
    u <- total;
    u <- (u `<<` (W8.of_int 3));
    u <@ __bswap64 (u);
    k <- 0;
    while ((k < 4)) {
      buf <- (BArray512.set64d buf ((128 * k) + 112) t);
      buf <- (BArray512.set64d buf ((128 * k) + 120) u);
      k <- (k + 1);
    }
    (* Erased call to spill *)
    (h, ms) <@ _sha512_x4_compress (h, buf, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    buf <- (protect_ptr buf ms);
    k <- 0;
    while ((k < 4)) {
      j <- 0;
      while ((j < 8)) {
        x <- (BArray256.get64 h ((4 * j) + k));
        x <@ __bswap64 (x);
        out <- (BArray256.set64 out ((8 * k) + j) x);
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    return (out, h, buf, ms);
  }
  proc _sha512_x4_lanes (out:BArray256.t, in_0:BArray32.t, len:W64.t,
                         ms:W64.t) : BArray256.t * W64.t = {
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    buf <- witness;
    buf_s <- witness;
    h <- witness;
    h <@ __sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ _sha512_x4_absorb_lanes (h, buf, total, in_0, 
    len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512_x4_finalize (out, h, buf, total, ms);
    return (out, ms);
  }
  proc a1____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray1.t,
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
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray1.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a1____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray1.t,
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
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray1.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a1___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                 a:BArray1.t, off:W64.t, len:W64.t, ms:W64.t) : 
  BArray32.t * BArray64.t * W64.t * W64.t = {
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
      (buf, ms) <@ a1____fill64_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a1___sha512_absorb_array (h:BArray64.t, buf:BArray128.t, total:W64.t,
                                 a:BArray1.t, off:W64.t, len:W64.t, ms:W64.t) : 
  BArray64.t * BArray128.t * W64.t * W64.t = {
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
      (buf, ms) <@ a1____fill128_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a1___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                    total:W64.t, a:BArray1.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ a1____fill64_array ((SBArray512_64.get_sub8 buf
                                            (64 * k)),
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_x8_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a1___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                    total:W64.t, a:BArray1.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ a1____fill128_array ((SBArray512_128.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_x4_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a1__sha256 (out:BArray32.t, a:BArray1.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha256_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a1___sha256_absorb_array (h, buf, total, a, 
    off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256___sha256_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a1__sha512 (out:BArray64.t, a:BArray1.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha512_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a1___sha512_absorb_array (h, buf, total, a, 
    off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512___sha512_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a1__sha256_x8 (out:BArray256.t, a:BArray1.t, off:W64.t, stride:W64.t,
                      len:W64.t) : BArray256.t = {
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
    h <@ __sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a1___sha256_x8_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256_x8_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a1__sha512_x4 (out:BArray256.t, a:BArray1.t, off:W64.t, stride:W64.t,
                      len:W64.t) : BArray256.t = {
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
    h <@ __sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a1___sha512_x4_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512_x4_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a64____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray64.t,
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
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray64.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a64____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray64.t,
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
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray64.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a64___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                  a:BArray64.t, off:W64.t, len:W64.t,
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
      (buf, ms) <@ a64____fill64_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a64___sha512_absorb_array (h:BArray64.t, buf:BArray128.t, total:W64.t,
                                  a:BArray64.t, off:W64.t, len:W64.t,
                                  ms:W64.t) : BArray64.t * BArray128.t *
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
      (buf, ms) <@ a64____fill128_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a64___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                     total:W64.t, a:BArray64.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ a64____fill64_array ((SBArray512_64.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_x8_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a64___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                     total:W64.t, a:BArray64.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ a64____fill128_array ((SBArray512_128.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_x4_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a64__sha256 (out:BArray32.t, a:BArray64.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha256_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a64___sha256_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256___sha256_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a64__sha512 (out:BArray64.t, a:BArray64.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha512_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a64___sha512_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512___sha512_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a64__sha256_x8 (out:BArray256.t, a:BArray64.t, off:W64.t,
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
    h <@ __sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a64___sha256_x8_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256_x8_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a64__sha512_x4 (out:BArray256.t, a:BArray64.t, off:W64.t,
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
    h <@ __sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a64___sha512_x4_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512_x4_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a128____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray128.t,
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
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray128.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a128____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray128.t,
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
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray128.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a128___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                   a:BArray128.t, off:W64.t, len:W64.t,
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
      (buf, ms) <@ a128____fill64_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a128___sha512_absorb_array (h:BArray64.t, buf:BArray128.t,
                                   total:W64.t, a:BArray128.t, off:W64.t,
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
      (buf, ms) <@ a128____fill128_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a128___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray128.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ a128____fill64_array ((SBArray512_64.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_x8_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a128___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray128.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ a128____fill128_array ((SBArray512_128.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_x4_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a128__sha256 (out:BArray32.t, a:BArray128.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha256_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a128___sha256_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256___sha256_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a128__sha512 (out:BArray64.t, a:BArray128.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha512_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a128___sha512_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512___sha512_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a128__sha256_x8 (out:BArray256.t, a:BArray128.t, off:W64.t,
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
    h <@ __sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a128___sha256_x8_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256_x8_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a128__sha512_x4 (out:BArray256.t, a:BArray128.t, off:W64.t,
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
    h <@ __sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a128___sha512_x4_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512_x4_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a333____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray333.t,
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
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray333.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a333____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray333.t,
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
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    more <- ((W64.of_int 8) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      t <- (BArray333.get64d a (W64.to_uint off));
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
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      dst <- (dst + (W64.of_int 1));
      off <- (off + (W64.of_int 1));
      more <- (dst \ult end_0);
    }
    ms <- (update_msf (! more) ms);
    return (buf, ms);
  }
  proc a333___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                   a:BArray333.t, off:W64.t, len:W64.t,
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
      (buf, ms) <@ a333____fill64_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 64));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a333___sha512_absorb_array (h:BArray64.t, buf:BArray128.t,
                                   total:W64.t, a:BArray333.t, off:W64.t,
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
      (buf, ms) <@ a333____fill128_array (buf, fill, a, off, n, ms);
      fill <- (fill + n);
      off <- (off + n);
      len <- (len - n);
      full <- (fill = (W64.of_int 128));
      if (full) {
        ms <- (update_msf full ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_compress (h, buf, ms);
        (* Erased call to unspill *)
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
  proc a333___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray333.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 64);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 8)) {
        (aux, aux_0) <@ a333____fill64_array ((SBArray512_64.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha256_x8_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a333___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray333.t, off:W64.t,
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
    (* Erased call to spill *)
    more <- (len <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      n <- (W64.of_int 128);
      n <- (n - fill);
      n <- ((len \ult n) ? len : n);
      src <- off;
      k <- 0;
      while ((k < 4)) {
        (aux, aux_0) <@ a333____fill128_array ((SBArray512_128.get_sub8 
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
        (* Erased call to unspill *)
        h <- (protect_ptr h ms);
        (* Erased call to spill *)
        (h, ms) <@ _sha512_x4_compress (h, buf, ms);
        (* Erased call to unspill *)
        (* Erased call to spill *)
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
    (* Erased call to unspill *)
    h <- (protect_ptr h ms);
    total <- (protect_64 total ms);
    return (h, buf, total, ms);
  }
  proc a333__sha256 (out:BArray32.t, a:BArray333.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha256_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a333___sha256_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256___sha256_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a333__sha512 (out:BArray64.t, a:BArray333.t, off:W64.t, len:W64.t) : 
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
    h <@ __sha512_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a333___sha512_absorb_array (h, buf, total, 
    a, off, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512___sha512_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a333__sha256_x8 (out:BArray256.t, a:BArray333.t, off:W64.t,
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
    h <@ __sha256_x8_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a333___sha256_x8_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha256_x8_finalize (out, h, buf, total, ms);
    return out;
  }
  proc a333__sha512_x4 (out:BArray256.t, a:BArray333.t, off:W64.t,
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
    h <@ __sha512_x4_init (h);
    buf <- buf_s;
    total <- (W64.of_int 0);
    (* Erased call to spill *)
    (h, buf, total, ms) <@ a333___sha512_x4_absorb_array (h, buf, total, 
    a, off, stride, len, ms);
    (* Erased call to unspill *)
    out <- (protect_ptr out ms);
    (out, h, buf, ms) <@ _sha512_x4_finalize (out, h, buf, total, ms);
    return out;
  }
}.
