require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

require import
BArray16 BArray28 BArray32 BArray48 BArray64 BArray80 BArray112 BArray128
BArray144 BArray160 BArray208 BArray256 BArray272 BArray512 BArray640
BArray784 SBArray112_16 SBArray144_16 SBArray208_16 SBArray272_16
SBArray784_16 SBArray112_32 SBArray112_64 SBArray208_64 SBArray512_64
SBArray144_112 SBArray208_128 SBArray512_128 SBArray272_208 SBArray784_256
SBArray784_512.

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
  proc __sha256_block_a64 (abcd:W128.t, efgh:W128.t, m:BArray64.t,
                           k:BArray256.t) : W128.t * W128.t * BArray64.t = {
    var abcd0:W128.t;
    var efgh0:W128.t;
    var g:int;
    var wk:W128.t;
    var prev:W128.t;
    abcd0 <- abcd;
    efgh0 <- efgh;
    g <- 0;
    while ((g < 12)) {
      wk <- (BArray256.get128 k g);
      wk <- (VADD_4u32 wk (BArray64.get128 m (g %% 4)));
      m <-
      (BArray64.set128 m (g %% 4)
      (SHA256SU0 (BArray64.get128 m (g %% 4))
      (BArray64.get128 m ((g + 1) %% 4))));
      m <-
      (BArray64.set128 m (g %% 4)
      (SHA256SU1 (BArray64.get128 m (g %% 4))
      (BArray64.get128 m ((g + 2) %% 4)) (BArray64.get128 m ((g + 3) %% 4))));
      prev <- abcd;
      abcd <- (SHA256H abcd efgh wk);
      efgh <- (SHA256H2 efgh prev wk);
      g <- (g + 1);
    }
    g <- 12;
    while ((g < 16)) {
      wk <- (BArray256.get128 k g);
      wk <- (VADD_4u32 wk (BArray64.get128 m (g %% 4)));
      prev <- abcd;
      abcd <- (SHA256H abcd efgh wk);
      efgh <- (SHA256H2 efgh prev wk);
      g <- (g + 1);
    }
    abcd <- (VADD_4u32 abcd abcd0);
    efgh <- (VADD_4u32 efgh efgh0);
    return (abcd, efgh, m);
  }
  proc _sha256_compress (h:BArray32.t, block:BArray64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var abcd:W128.t;
    var efgh:W128.t;
    var j:int;
    var m:BArray64.t;
    var k:BArray256.t;
    k <- witness;
    m <- witness;
    abcd <- (BArray32.get128 h 0);
    efgh <- (BArray32.get128 h 1);
    j <- 0;
    while ((j < 4)) {
      m <- (BArray64.set128 m j (BArray64.get128 block j));
      m <- (BArray64.set128 m j (VREV32_16u8 (BArray64.get128 m j)));
      j <- (j + 1);
    }
    k <- sHA256_K;
    (abcd, efgh, m) <@ __sha256_block_a64 (abcd, efgh, m, k);
    h <- (BArray32.set128 h 0 abcd);
    h <- (BArray32.set128 h 1 efgh);
    return (h, ms);
  }
  proc _sha256_compress_blocks (h:BArray32.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var abcd:W128.t;
    var efgh:W128.t;
    var k:BArray256.t;
    var more:bool;
    var j:int;
    var m:BArray64.t;
    k <- witness;
    m <- witness;
    abcd <- (BArray32.get128 h 0);
    efgh <- (BArray32.get128 h 1);
    k <- sHA256_K;
    more <- (n <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      j <- 0;
      while ((j < 4)) {
        m <-
        (BArray64.set128 m j
        (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
        m <- (BArray64.set128 m j (VREV32_16u8 (BArray64.get128 m j)));
        j <- (j + 1);
      }
      (abcd, efgh, m) <@ __sha256_block_a64 (abcd, efgh, m, k);
      p <- (p + (W64.of_int 64));
      n <- (n - (W64.of_int 1));
      more <- (n <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    h <- (BArray32.set128 h 0 abcd);
    h <- (BArray32.set128 h 1 efgh);
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
  proc __sha512_block_a64 (s:BArray80.t, m:BArray128.t, k:BArray640.t) : 
  BArray80.t * BArray128.t = {
    var j:int;
    var s0:BArray64.t;
    var i0:int;
    var i1:int;
    var i2:int;
    var i3:int;
    var i4:int;
    var g:int;
    var wk:W128.t;
    var x:W128.t;
    var y:W128.t;
    var z:W128.t;
    var t:int;
    s0 <- witness;
    j <- 0;
    while ((j < 4)) {
      s0 <- (BArray64.set128 s0 j (BArray80.get128 s j));
      j <- (j + 1);
    }
    i0 <- 0;
    i1 <- 1;
    i2 <- 2;
    i3 <- 3;
    i4 <- 4;
    g <- 0;
    while ((g < 32)) {
      j <- (g %% 8);
      wk <- (BArray640.get128 k g);
      wk <- (VADD_2u64 wk (BArray128.get128 m j));
      wk <- (VEXT wk wk (W8.of_int 8));
      x <-
      (VEXT (BArray80.get128 s i2) (BArray80.get128 s i3) (W8.of_int 8));
      y <-
      (VEXT (BArray80.get128 s i1) (BArray80.get128 s i2) (W8.of_int 8));
      s <- (BArray80.set128 s i3 (VADD_2u64 (BArray80.get128 s i3) wk));
      z <-
      (VEXT (BArray128.get128 m ((j + 4) %% 8))
      (BArray128.get128 m ((j + 5) %% 8)) (W8.of_int 8));
      m <-
      (BArray128.set128 m j
      (SHA512SU0 (BArray128.get128 m j) (BArray128.get128 m ((j + 1) %% 8))));
      m <-
      (BArray128.set128 m j
      (SHA512SU1 (BArray128.get128 m j) (BArray128.get128 m ((j + 7) %% 8)) 
      z));
      s <- (BArray80.set128 s i3 (SHA512H (BArray80.get128 s i3) x y));
      s <-
      (BArray80.set128 s i4
      (VADD_2u64 (BArray80.get128 s i1) (BArray80.get128 s i3)));
      s <-
      (BArray80.set128 s i3
      (SHA512H2 (BArray80.get128 s i3) (BArray80.get128 s i1)
      (BArray80.get128 s i0)));
      t <- i0;
      i0 <- i3;
      i3 <- i2;
      i2 <- i4;
      i4 <- i1;
      i1 <- t;
      g <- (g + 1);
    }
    g <- 32;
    while ((g < 40)) {
      j <- (g %% 8);
      wk <- (BArray640.get128 k g);
      wk <- (VADD_2u64 wk (BArray128.get128 m j));
      wk <- (VEXT wk wk (W8.of_int 8));
      x <-
      (VEXT (BArray80.get128 s i2) (BArray80.get128 s i3) (W8.of_int 8));
      y <-
      (VEXT (BArray80.get128 s i1) (BArray80.get128 s i2) (W8.of_int 8));
      s <- (BArray80.set128 s i3 (VADD_2u64 (BArray80.get128 s i3) wk));
      s <- (BArray80.set128 s i3 (SHA512H (BArray80.get128 s i3) x y));
      s <-
      (BArray80.set128 s i4
      (VADD_2u64 (BArray80.get128 s i1) (BArray80.get128 s i3)));
      s <-
      (BArray80.set128 s i3
      (SHA512H2 (BArray80.get128 s i3) (BArray80.get128 s i1)
      (BArray80.get128 s i0)));
      t <- i0;
      i0 <- i3;
      i3 <- i2;
      i2 <- i4;
      i4 <- i1;
      i1 <- t;
      g <- (g + 1);
    }
    j <- 0;
    while ((j < 4)) {
      s <-
      (BArray80.set128 s j
      (VADD_2u64 (BArray80.get128 s j) (BArray64.get128 s0 j)));
      j <- (j + 1);
    }
    return (s, m);
  }
  proc _sha512_compress (h:BArray64.t, block:BArray128.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var j:int;
    var s:BArray80.t;
    var m:BArray128.t;
    var k:BArray640.t;
    k <- witness;
    m <- witness;
    s <- witness;
    j <- 0;
    while ((j < 4)) {
      s <- (BArray80.set128 s j (BArray64.get128 h j));
      j <- (j + 1);
    }
    j <- 0;
    while ((j < 8)) {
      m <- (BArray128.set128 m j (BArray128.get128 block j));
      m <- (BArray128.set128 m j (VREV64_16u8 (BArray128.get128 m j)));
      j <- (j + 1);
    }
    k <- sHA512_K;
    (s, m) <@ __sha512_block_a64 (s, m, k);
    j <- 0;
    while ((j < 4)) {
      h <- (BArray64.set128 h j (BArray80.get128 s j));
      j <- (j + 1);
    }
    return (h, ms);
  }
  proc _sha512_compress_blocks (h:BArray64.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var j:int;
    var s:BArray80.t;
    var k:BArray640.t;
    var more:bool;
    var m:BArray128.t;
    k <- witness;
    m <- witness;
    s <- witness;
    j <- 0;
    while ((j < 4)) {
      s <- (BArray80.set128 s j (BArray64.get128 h j));
      j <- (j + 1);
    }
    k <- sHA512_K;
    more <- (n <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      j <- 0;
      while ((j < 8)) {
        m <-
        (BArray128.set128 m j
        (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
        m <- (BArray128.set128 m j (VREV64_16u8 (BArray128.get128 m j)));
        j <- (j + 1);
      }
      (s, m) <@ __sha512_block_a64 (s, m, k);
      p <- (p + (W64.of_int 128));
      n <- (n - (W64.of_int 1));
      more <- (n <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    j <- 0;
    while ((j < 4)) {
      h <- (BArray64.set128 h j (BArray80.get128 s j));
      j <- (j + 1);
    }
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
  proc _hmac_sha256_keyblock_mem (k0:BArray64.t, key:W64.t, keylen:W64.t,
                                  ms:W64.t) : BArray64.t * W64.t = {
    var long:bool;
    var i:W64.t;
    var digest:BArray32.t;
    var j:int;
    var t:W64.t;
    var hi:W64.t;
    digest <- witness;
    long <- ((W64.of_int 64) \ult keylen);
    if (long) {
      ms <- (update_msf long ms);
      (* Erased call to spill *)
      (digest, ms) <@ _sha256_mem (digest, key, keylen, ms);
      (* Erased call to unspill *)
      k0 <- (protect_ptr k0 ms);
      j <- 0;
      while ((j < 4)) {
        t <- (BArray32.get64 digest j);
        k0 <- (BArray64.set64 k0 j t);
        j <- (j + 1);
      }
      i <- (W64.of_int 32);
    } else {
      ms <- (update_msf (! long) ms);
      i <- (W64.of_int 0);
      (k0, ms) <@ __fill64_mem (k0, i, key, keylen, ms);
      i <- keylen;
    }
    hi <- (W64.of_int 64);
    (k0, ms) <@ __zero64 (k0, i, hi, ms);
    return (k0, ms);
  }
  proc _hmac_sha512_keyblock_mem (k0:BArray128.t, key:W64.t, keylen:W64.t,
                                  ms:W64.t) : BArray128.t * W64.t = {
    var long:bool;
    var i:W64.t;
    var digest:BArray64.t;
    var j:int;
    var t:W64.t;
    var hi:W64.t;
    digest <- witness;
    long <- ((W64.of_int 128) \ult keylen);
    if (long) {
      ms <- (update_msf long ms);
      (* Erased call to spill *)
      (digest, ms) <@ _sha512_mem (digest, key, keylen, ms);
      (* Erased call to unspill *)
      k0 <- (protect_ptr k0 ms);
      j <- 0;
      while ((j < 8)) {
        t <- (BArray64.get64 digest j);
        k0 <- (BArray128.set64 k0 j t);
        j <- (j + 1);
      }
      i <- (W64.of_int 64);
    } else {
      ms <- (update_msf (! long) ms);
      i <- (W64.of_int 0);
      (k0, ms) <@ __fill128_mem (k0, i, key, keylen, ms);
      i <- keylen;
    }
    hi <- (W64.of_int 128);
    (k0, ms) <@ __zero128 (k0, i, hi, ms);
    return (k0, ms);
  }
  proc __hmac_sha256_init (inner:BArray32.t, outer:BArray32.t, k0:BArray64.t,
                           ms:W64.t) : BArray32.t * BArray32.t * W64.t = {
    var mi:W64.t;
    var mo:W64.t;
    var i:int;
    var t:W64.t;
    var u:W64.t;
    var ipad:BArray64.t;
    var opad:BArray64.t;
    ipad <- witness;
    opad <- witness;
    mi <- (W64.of_int 3906369333256140342);
    mo <- (W64.of_int 6655295901103053916);
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 k0 i);
      u <- t;
      t <- (t `^` mi);
      u <- (u `^` mo);
      ipad <- (BArray64.set64 ipad i t);
      opad <- (BArray64.set64 opad i u);
      i <- (i + 1);
    }
    inner <@ __sha256_init (inner);
    (inner, ms) <@ _sha256_compress (inner, ipad, ms);
    outer <@ __sha256_init (outer);
    (outer, ms) <@ _sha256_compress (outer, opad, ms);
    return (inner, outer, ms);
  }
  proc __hmac_sha512_init (inner:BArray64.t, outer:BArray64.t,
                           k0:BArray128.t, ms:W64.t) : BArray64.t *
                                                       BArray64.t * W64.t = {
    var mi:W64.t;
    var mo:W64.t;
    var i:int;
    var t:W64.t;
    var u:W64.t;
    var ipad:BArray128.t;
    var opad:BArray128.t;
    ipad <- witness;
    opad <- witness;
    mi <- (W64.of_int 3906369333256140342);
    mo <- (W64.of_int 6655295901103053916);
    i <- 0;
    while ((i < 16)) {
      t <- (BArray128.get64 k0 i);
      u <- t;
      t <- (t `^` mi);
      u <- (u `^` mo);
      ipad <- (BArray128.set64 ipad i t);
      opad <- (BArray128.set64 opad i u);
      i <- (i + 1);
    }
    inner <@ __sha512_init (inner);
    (inner, ms) <@ _sha512_compress (inner, ipad, ms);
    outer <@ __sha512_init (outer);
    (outer, ms) <@ _sha512_compress (outer, opad, ms);
    return (inner, outer, ms);
  }
  proc __hmac_sha256_outer (inner:BArray32.t, buf:BArray64.t, total:W64.t,
                            outer:BArray32.t, ms:W64.t) : BArray32.t *
                                                          BArray64.t *
                                                          W64.t * W64.t = {
    var digest:BArray32.t;
    var i:int;
    var x:W32.t;
    var t:W64.t;
    digest <- witness;
    (digest, inner, buf, ms) <@ _sha256___sha256_finalize (digest, inner,
    buf, total, ms);
    i <- 0;
    while ((i < 8)) {
      x <- (BArray32.get32 outer i);
      inner <- (BArray32.set32 inner i x);
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 4)) {
      t <- (BArray32.get64 digest i);
      buf <- (BArray64.set64 buf i t);
      i <- (i + 1);
    }
    total <- (W64.of_int (64 + 32));
    return (inner, buf, total, ms);
  }
  proc __hmac_sha256_finalize (out:BArray32.t, inner:BArray32.t,
                               buf:BArray64.t, total:W64.t, outer:BArray32.t,
                               ms:W64.t) : BArray32.t * BArray32.t *
                                           BArray64.t * W64.t = {
    
    (inner, buf, total, ms) <@ __hmac_sha256_outer (inner, buf, total, 
    outer, ms);
    (out, inner, buf, ms) <@ _sha256___sha256_finalize (out, inner, buf,
    total, ms);
    return (out, inner, buf, ms);
  }
  proc __hmac_sha512_outer (inner:BArray64.t, buf:BArray128.t, total:W64.t,
                            outer:BArray64.t, ms:W64.t) : BArray64.t *
                                                          BArray128.t *
                                                          W64.t * W64.t = {
    var digest:BArray64.t;
    var i:int;
    var t:W64.t;
    digest <- witness;
    (digest, inner, buf, ms) <@ _sha512___sha512_finalize (digest, inner,
    buf, total, ms);
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 outer i);
      inner <- (BArray64.set64 inner i t);
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 digest i);
      buf <- (BArray128.set64 buf i t);
      i <- (i + 1);
    }
    total <- (W64.of_int (128 + 64));
    return (inner, buf, total, ms);
  }
  proc __hmac_sha512_finalize (out:BArray64.t, inner:BArray64.t,
                               buf:BArray128.t, total:W64.t,
                               outer:BArray64.t, ms:W64.t) : BArray64.t *
                                                             BArray64.t *
                                                             BArray128.t *
                                                             W64.t = {
    
    (inner, buf, total, ms) <@ __hmac_sha512_outer (inner, buf, total, 
    outer, ms);
    (out, inner, buf, ms) <@ _sha512___sha512_finalize (out, inner, buf,
    total, ms);
    return (out, inner, buf, ms);
  }
  proc __sha2_tag (f:int) : W64.t = {
    var tag:W64.t;
    tag <- (W64.of_int (1100357333870 + (f `<<` 32)));
    return tag;
  }
  proc __sha2_ctx_open (head:BArray16.t, ms:W64.t) : W64.t * W64.t = {
    var tag:W64.t;
    var total:W64.t;
    tag <- (BArray16.get64d head 0);
    total <- (BArray16.get64d head 8);
    (* Erased call to declassify *)
    (* Erased call to declassify *)
    tag <- (protect_64 tag ms);
    total <- (protect_64 total ms);
    return (tag, total);
  }
  proc __sha2_room (total:W64.t) : W64.t = {
    var room:W64.t;
    var limit:W64.t;
    var zero:W64.t;
    limit <- (W64.of_int 2305843009213693952);
    zero <- (W64.of_int 0);
    room <- limit;
    room <- (room - total);
    room <- ((total \ult limit) ? room : zero);
    return room;
  }
  proc __sha256_ctx_load (h:BArray32.t, buf:BArray64.t, ctx:BArray112.t) : 
  BArray32.t * BArray64.t = {
    var i:int;
    var x:W32.t;
    var t:W64.t;
    i <- 0;
    while ((i < 8)) {
      x <- (BArray112.get32d ctx (16 + (4 * i)));
      h <- (BArray32.set32 h i x);
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 8)) {
      t <- (BArray112.get64d ctx (48 + (8 * i)));
      buf <- (BArray64.set64d buf (8 * i) t);
      i <- (i + 1);
    }
    return (h, buf);
  }
  proc __sha512_ctx_load (h:BArray64.t, buf:BArray128.t, ctx:BArray208.t) : 
  BArray64.t * BArray128.t = {
    var i:int;
    var t:W64.t;
    i <- 0;
    while ((i < 8)) {
      t <- (BArray208.get64d ctx (16 + (8 * i)));
      h <- (BArray64.set64 h i t);
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 16)) {
      t <- (BArray208.get64d ctx (80 + (8 * i)));
      buf <- (BArray128.set64d buf (8 * i) t);
      i <- (i + 1);
    }
    return (h, buf);
  }
  proc __sha256_ctx_init (ctx:BArray112.t, h:BArray32.t, tag:W64.t,
                          total:W64.t) : BArray112.t = {
    var i:int;
    var x:W32.t;
    var z:W64.t;
    ctx <- (BArray112.set64d ctx 0 tag);
    ctx <- (BArray112.set64d ctx 8 total);
    i <- 0;
    while ((i < 8)) {
      x <- (BArray32.get32 h i);
      ctx <- (BArray112.set32d ctx (16 + (4 * i)) x);
      i <- (i + 1);
    }
    z <- (W64.of_int 0);
    i <- 0;
    while ((i < 8)) {
      ctx <- (BArray112.set64d ctx (48 + (8 * i)) z);
      i <- (i + 1);
    }
    return ctx;
  }
  proc __sha512_ctx_init (ctx:BArray208.t, h:BArray64.t, tag:W64.t,
                          total:W64.t) : BArray208.t = {
    var i:int;
    var t:W64.t;
    var z:W64.t;
    ctx <- (BArray208.set64d ctx 0 tag);
    ctx <- (BArray208.set64d ctx 8 total);
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 h i);
      ctx <- (BArray208.set64d ctx (16 + (8 * i)) t);
      i <- (i + 1);
    }
    z <- (W64.of_int 0);
    i <- 0;
    while ((i < 16)) {
      ctx <- (BArray208.set64d ctx (80 + (8 * i)) z);
      i <- (i + 1);
    }
    return ctx;
  }
  proc _sha256_ctx_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t,
                           expect_0:W64.t, ms:W64.t) : BArray112.t * W64.t *
                                                       W64.t = {
    var aux:BArray32.t;
    var aux_0:BArray64.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var room:W64.t;
    (tag, total) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      room <@ __sha2_room (total);
      status <- (W64.of_int 2);
      ok <- (inlen \ult room);
      if (ok) {
        ms <- (update_msf ok ms);
        (aux, aux_0, aux_1, aux_2) <@ _sha256_absorb_mem ((
                                                          SBArray112_32.get_sub32
                                                          ctx 4),
        (SBArray112_64.get_sub8 ctx 48), total, in_0, inlen, ms);
        ctx <- (SBArray112_32.set_sub32 ctx 4 aux);
        ctx <- (SBArray112_64.set_sub8 ctx 48 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx <- (BArray112.set64d ctx 8 total);
        status <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! ok) ms);
      }
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha512_ctx_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                           expect_0:W64.t, ms:W64.t) : BArray208.t * W64.t *
                                                       W64.t = {
    var aux_0:BArray128.t;
    var aux:BArray64.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var room:W64.t;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      room <@ __sha2_room (total);
      status <- (W64.of_int 2);
      ok <- (inlen \ult room);
      if (ok) {
        ms <- (update_msf ok ms);
        (aux, aux_0, aux_1, aux_2) <@ _sha512_absorb_mem ((
                                                          SBArray208_64.get_sub64
                                                          ctx 2),
        (SBArray208_128.get_sub8 ctx 80), total, in_0, inlen, ms);
        ctx <- (SBArray208_64.set_sub64 ctx 2 aux);
        ctx <- (SBArray208_128.set_sub8 ctx 80 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx <- (BArray208.set64d ctx 8 total);
        status <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! ok) ms);
      }
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha224_ctx____ctx_finalize (ctx:BArray112.t, digest:BArray28.t,
                                    total:W64.t, ms:W64.t) : BArray112.t *
                                                             BArray28.t *
                                                             W64.t = {
    var aux:BArray28.t;
    var aux_0:BArray32.t;
    var aux_1:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha224___sha256_finalize (digest,
    (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray112_32.set_sub32 ctx 4 aux_0);
    ctx <- (SBArray112_64.set_sub8 ctx 48 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha224_ctx___sha2_ctx_final (ctx:BArray112.t, digest:BArray28.t,
                                     expect_0:W64.t, ms:W64.t) : BArray112.t *
                                                                 BArray28.t *
                                                                 W64.t *
                                                                 W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha224_ctx____ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (112 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray112.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc _sha256_ctx____ctx_finalize (ctx:BArray112.t, digest:BArray32.t,
                                    total:W64.t, ms:W64.t) : BArray112.t *
                                                             BArray32.t *
                                                             W64.t = {
    var aux:BArray32.t;
    var aux_0:BArray32.t;
    var aux_1:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha256___sha256_finalize (digest,
    (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray112_32.set_sub32 ctx 4 aux_0);
    ctx <- (SBArray112_64.set_sub8 ctx 48 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha256_ctx___sha2_ctx_final (ctx:BArray112.t, digest:BArray32.t,
                                     expect_0:W64.t, ms:W64.t) : BArray112.t *
                                                                 BArray32.t *
                                                                 W64.t *
                                                                 W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha256_ctx____ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (112 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray112.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc _sha384_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray48.t,
                                    total:W64.t, ms:W64.t) : BArray208.t *
                                                             BArray48.t *
                                                             W64.t = {
    var aux_1:BArray128.t;
    var aux:BArray48.t;
    var aux_0:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha384___sha512_finalize (digest,
    (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha384_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray48.t,
                                     expect_0:W64.t, ms:W64.t) : BArray208.t *
                                                                 BArray48.t *
                                                                 W64.t *
                                                                 W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha384_ctx____ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray208.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc _sha512_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray64.t,
                                    total:W64.t, ms:W64.t) : BArray208.t *
                                                             BArray64.t *
                                                             W64.t = {
    var aux_1:BArray128.t;
    var aux:BArray64.t;
    var aux_0:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha512___sha512_finalize (digest,
    (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha512_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray64.t,
                                     expect_0:W64.t, ms:W64.t) : BArray208.t *
                                                                 BArray64.t *
                                                                 W64.t *
                                                                 W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha512_ctx____ctx_finalize (ctx, digest, 
      total, ms);
      z <- (W64.of_int 0);
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray208.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc _sha512_224_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray28.t,
                                        total:W64.t, ms:W64.t) : BArray208.t *
                                                                 BArray28.t *
                                                                 W64.t = {
    var aux_1:BArray128.t;
    var aux:BArray28.t;
    var aux_0:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha512_224___sha512_finalize (digest,
    (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha512_224_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray28.t,
                                         expect_0:W64.t, ms:W64.t) : 
  BArray208.t * BArray28.t * W64.t * W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha512_224_ctx____ctx_finalize (ctx, digest,
      total, ms);
      z <- (W64.of_int 0);
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray208.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc _sha512_256_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray32.t,
                                        total:W64.t, ms:W64.t) : BArray208.t *
                                                                 BArray32.t *
                                                                 W64.t = {
    var aux_1:BArray128.t;
    var aux:BArray32.t;
    var aux_0:BArray64.t;
    var aux_2:W64.t;
    (aux, aux_0, aux_1, aux_2) <@ _sha512_256___sha512_finalize (digest,
    (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80), 
    total, ms);
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    return (ctx, digest, ms);
  }
  proc _sha512_256_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray32.t,
                                         expect_0:W64.t, ms:W64.t) : 
  BArray208.t * BArray32.t * W64.t * W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 ctx 0), ms);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (ctx, digest, ms) <@ _sha512_256_ctx____ctx_finalize (ctx, digest,
      total, ms);
      z <- (W64.of_int 0);
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray208.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, digest, status, ms);
  }
  proc __hmac_sha256_ctx_init (ctx:BArray144.t, key:W64.t, keylen:W64.t,
                               ms:W64.t) : BArray144.t * W64.t = {
    var aux:BArray112.t;
    var k0:BArray64.t;
    var inner:BArray32.t;
    var outer:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    var i:int;
    var x:W32.t;
    inner <- witness;
    k0 <- witness;
    outer <- witness;
    (* Erased call to spill *)
    (k0, ms) <@ _hmac_sha256_keyblock_mem (k0, key, keylen, ms);
    (inner, outer, ms) <@ __hmac_sha256_init (inner, outer, k0, ms);
    (* Erased call to unspill *)
    ctx <- (protect_ptr ctx ms);
    tag <@ __sha2_tag (7);
    total <- (W64.of_int 64);
    aux <@ __sha256_ctx_init ((SBArray144_112.get_sub8 ctx 0), inner, 
    tag, total);
    ctx <- (SBArray144_112.set_sub8 ctx 0 aux);
    i <- 0;
    while ((i < 8)) {
      x <- (BArray32.get32 outer i);
      ctx <- (BArray144.set32d ctx (112 + (4 * i)) x);
      i <- (i + 1);
    }
    return (ctx, ms);
  }
  proc __hmac_sha512_ctx_init (ctx:BArray272.t, key:W64.t, keylen:W64.t,
                               ms:W64.t) : BArray272.t * W64.t = {
    var aux:BArray208.t;
    var k0:BArray128.t;
    var inner:BArray64.t;
    var outer:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var i:int;
    var t:W64.t;
    inner <- witness;
    k0 <- witness;
    outer <- witness;
    (* Erased call to spill *)
    (k0, ms) <@ _hmac_sha512_keyblock_mem (k0, key, keylen, ms);
    (inner, outer, ms) <@ __hmac_sha512_init (inner, outer, k0, ms);
    (* Erased call to unspill *)
    ctx <- (protect_ptr ctx ms);
    tag <@ __sha2_tag (8);
    total <- (W64.of_int 128);
    aux <@ __sha512_ctx_init ((SBArray272_208.get_sub8 ctx 0), inner, 
    tag, total);
    ctx <- (SBArray272_208.set_sub8 ctx 0 aux);
    i <- 0;
    while ((i < 8)) {
      t <- (BArray64.get64 outer i);
      ctx <- (BArray272.set64d ctx (208 + (8 * i)) t);
      i <- (i + 1);
    }
    return (ctx, ms);
  }
  proc __hmac_sha256_ctx_final (ctx:BArray144.t, out:BArray32.t, ms:W64.t) : 
  BArray144.t * BArray32.t * W64.t * W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var inner:BArray32.t;
    var buf:BArray64.t;
    var i:int;
    var x:W32.t;
    var outer:BArray32.t;
    var mac:BArray32.t;
    var t:W64.t;
    var z:W64.t;
    buf <- witness;
    inner <- witness;
    mac <- witness;
    outer <- witness;
    (tag, total) <@ __sha2_ctx_open ((SBArray144_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (7);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (inner, buf) <@ __sha256_ctx_load (inner, buf,
      (SBArray144_112.get_sub8 ctx 0));
      i <- 0;
      while ((i < 8)) {
        x <- (BArray144.get32d ctx (112 + (4 * i)));
        outer <- (BArray32.set32 outer i x);
        i <- (i + 1);
      }
      (* Erased call to spill *)
      (mac, inner, buf, ms) <@ __hmac_sha256_finalize (mac, inner, buf,
      total, outer, ms);
      (* Erased call to unspill *)
      ctx <- (protect_ptr ctx ms);
      out <- (protect_ptr out ms);
      i <- 0;
      while ((i < 4)) {
        t <- (BArray32.get64 mac i);
        out <- (BArray32.set64 out i t);
        i <- (i + 1);
      }
      z <- (W64.of_int 0);
      inc <- (144 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray144.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, out, status, ms);
  }
  proc __hmac_sha512_ctx_final (ctx:BArray272.t, out:BArray64.t, ms:W64.t) : 
  BArray272.t * BArray64.t * W64.t * W64.t = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var inner:BArray64.t;
    var buf:BArray128.t;
    var i:int;
    var t:W64.t;
    var outer:BArray64.t;
    var mac:BArray64.t;
    var z:W64.t;
    buf <- witness;
    inner <- witness;
    mac <- witness;
    outer <- witness;
    (tag, total) <@ __sha2_ctx_open ((SBArray272_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (8);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (inner, buf) <@ __sha512_ctx_load (inner, buf,
      (SBArray272_208.get_sub8 ctx 0));
      i <- 0;
      while ((i < 8)) {
        t <- (BArray272.get64d ctx (208 + (8 * i)));
        outer <- (BArray64.set64 outer i t);
        i <- (i + 1);
      }
      (* Erased call to spill *)
      (mac, inner, buf, ms) <@ __hmac_sha512_finalize (mac, inner, buf,
      total, outer, ms);
      (* Erased call to unspill *)
      ctx <- (protect_ptr ctx ms);
      out <- (protect_ptr out ms);
      i <- 0;
      while ((i < 8)) {
        t <- (BArray64.get64 mac i);
        out <- (BArray64.set64 out i t);
        i <- (i + 1);
      }
      z <- (W64.of_int 0);
      inc <- (272 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray272.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, out, status, ms);
  }
  proc _hmac_sha256_mem (out:BArray32.t, key:W64.t, keylen:W64.t, msg:W64.t,
                         msglen:W64.t, ms:W64.t) : BArray32.t * W64.t = {
    var k0:BArray64.t;
    var inner:BArray32.t;
    var outer:BArray32.t;
    var total:W64.t;
    var buf:BArray64.t;
    buf <- witness;
    inner <- witness;
    k0 <- witness;
    outer <- witness;
    (* Erased call to spill *)
    (k0, ms) <@ _hmac_sha256_keyblock_mem (k0, key, keylen, ms);
    (inner, outer, ms) <@ __hmac_sha256_init (inner, outer, k0, ms);
    (* Erased call to unspill *)
    msg <- (protect_64 msg ms);
    msglen <- (protect_64 msglen ms);
    total <- (W64.of_int 64);
    (inner, buf, total, ms) <@ _sha256_absorb_mem (inner, buf, total, 
    msg, msglen, ms);
    (inner, buf, total, ms) <@ __hmac_sha256_outer (inner, buf, total, 
    outer, ms);
    (* Erased call to unspill *)
    (out, inner, buf, ms) <@ _sha256___sha256_finalize (out, inner, buf,
    total, ms);
    return (out, ms);
  }
  proc _hmac_sha512_mem (out:BArray64.t, key:W64.t, keylen:W64.t, msg:W64.t,
                         msglen:W64.t, ms:W64.t) : BArray64.t * W64.t = {
    var k0:BArray128.t;
    var inner:BArray64.t;
    var outer:BArray64.t;
    var total:W64.t;
    var buf:BArray128.t;
    buf <- witness;
    inner <- witness;
    k0 <- witness;
    outer <- witness;
    (* Erased call to spill *)
    (k0, ms) <@ _hmac_sha512_keyblock_mem (k0, key, keylen, ms);
    (inner, outer, ms) <@ __hmac_sha512_init (inner, outer, k0, ms);
    (* Erased call to unspill *)
    msg <- (protect_64 msg ms);
    msglen <- (protect_64 msglen ms);
    total <- (W64.of_int 128);
    (inner, buf, total, ms) <@ _sha512_absorb_mem (inner, buf, total, 
    msg, msglen, ms);
    (inner, buf, total, ms) <@ __hmac_sha512_outer (inner, buf, total, 
    outer, ms);
    (* Erased call to unspill *)
    (out, inner, buf, ms) <@ _sha512___sha512_finalize (out, inner, buf,
    total, ms);
    return (out, ms);
  }
  proc __sha256_x8_tr4 (a:W128.t, b:W128.t, c:W128.t, d:W128.t) : W128.t *
                                                                  W128.t *
                                                                  W128.t *
                                                                  W128.t = {
    var t0:W128.t;
    var t1:W128.t;
    var t2:W128.t;
    var t3:W128.t;
    t0 <- (VTRN1_4u32 a b);
    t1 <- (VTRN2_4u32 a b);
    t2 <- (VTRN1_4u32 c d);
    t3 <- (VTRN2_4u32 c d);
    a <- (VTRN1_2u64 t0 t2);
    b <- (VTRN1_2u64 t1 t3);
    c <- (VTRN2_2u64 t0 t2);
    d <- (VTRN2_2u64 t1 t3);
    return (a, b, c, d);
  }
  proc __sha256_x8_load_half (h8:BArray256.t, f:int) : BArray128.t = {
    var st:BArray128.t;
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var c:W128.t;
    var d:W128.t;
    st <- witness;
    q <- 0;
    while ((q < 2)) {
      a <- (BArray256.get128 h8 ((2 * (4 * q)) + f));
      b <- (BArray256.get128 h8 ((2 * ((4 * q) + 1)) + f));
      c <- (BArray256.get128 h8 ((2 * ((4 * q) + 2)) + f));
      d <- (BArray256.get128 h8 ((2 * ((4 * q) + 3)) + f));
      (a, b, c, d) <@ __sha256_x8_tr4 (a, b, c, d);
      st <- (BArray128.set128 st q a);
      st <- (BArray128.set128 st (2 + q) b);
      st <- (BArray128.set128 st (4 + q) c);
      st <- (BArray128.set128 st (6 + q) d);
      q <- (q + 1);
    }
    return st;
  }
  proc __sha256_x8_store_half (h8:BArray256.t, st:BArray128.t, f:int) : 
  BArray256.t = {
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var c:W128.t;
    var d:W128.t;
    q <- 0;
    while ((q < 2)) {
      (a, b, c, d) <@ __sha256_x8_tr4 ((BArray128.get128 st q),
      (BArray128.get128 st (2 + q)), (BArray128.get128 st (4 + q)),
      (BArray128.get128 st (6 + q)));
      h8 <- (BArray256.set128 h8 ((2 * (4 * q)) + f) a);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 1)) + f) b);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 2)) + f) c);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 3)) + f) d);
      q <- (q + 1);
    }
    return h8;
  }
  proc __sha256_x8_block2 (st:BArray128.t, r:int, m:BArray128.t,
                           k:BArray256.t) : BArray128.t * BArray128.t = {
    var j:int;
    var s0:BArray64.t;
    var g:int;
    var kv:W128.t;
    var l:int;
    var wk:BArray32.t;
    var prev:BArray32.t;
    prev <- witness;
    s0 <- witness;
    wk <- witness;
    j <- 0;
    while ((j < 4)) {
      s0 <- (BArray64.set128 s0 j (BArray128.get128 st ((4 * r) + j)));
      j <- (j + 1);
    }
    g <- 0;
    while ((g < 16)) {
      kv <- (BArray256.get128 k g);
      l <- 0;
      while ((l < 2)) {
        wk <-
        (BArray32.set128 wk l
        (VADD_4u32 kv (BArray128.get128 m ((4 * l) + (g %% 4)))));
        if ((g < 12)) {
          m <-
          (BArray128.set128 m ((4 * l) + (g %% 4))
          (SHA256SU0 (BArray128.get128 m ((4 * l) + (g %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 1) %% 4)))));
          m <-
          (BArray128.set128 m ((4 * l) + (g %% 4))
          (SHA256SU1 (BArray128.get128 m ((4 * l) + (g %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 2) %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 3) %% 4)))));
        } else {
          
        }
        prev <-
        (BArray32.set128 prev l (BArray128.get128 st ((4 * r) + (2 * l))));
        st <-
        (BArray128.set128 st ((4 * r) + (2 * l))
        (SHA256H (BArray128.get128 st ((4 * r) + (2 * l)))
        (BArray128.get128 st (((4 * r) + (2 * l)) + 1))
        (BArray32.get128 wk l)));
        st <-
        (BArray128.set128 st (((4 * r) + (2 * l)) + 1)
        (SHA256H2 (BArray128.get128 st (((4 * r) + (2 * l)) + 1))
        (BArray32.get128 prev l) (BArray32.get128 wk l)));
        l <- (l + 1);
      }
      g <- (g + 1);
    }
    j <- 0;
    while ((j < 4)) {
      st <-
      (BArray128.set128 st ((4 * r) + j)
      (VADD_4u32 (BArray128.get128 st ((4 * r) + j)) (BArray64.get128 s0 j)));
      j <- (j + 1);
    }
    return (st, m);
  }
  proc _sha256_x8_compress (h8:BArray256.t, blocks:BArray512.t, ms:W64.t) : 
  BArray256.t * W64.t = {
    var k:BArray256.t;
    var f:int;
    var st:BArray128.t;
    var i:int;
    var r:int;
    var m:BArray128.t;
    k <- witness;
    m <- witness;
    st <- witness;
    k <- sHA256_K;
    f <- 0;
    while ((f < 2)) {
      st <@ __sha256_x8_load_half (h8, f);
      r <- 0;
      while ((r < 2)) {
        i <- 0;
        while ((i < 4)) {
          m <-
          (BArray128.set128 m i
          (BArray512.get128 blocks ((4 * ((4 * f) + (2 * r))) + i)));
          m <- (BArray128.set128 m i (VREV32_16u8 (BArray128.get128 m i)));
          m <-
          (BArray128.set128 m (4 + i)
          (BArray512.get128 blocks ((4 * (((4 * f) + (2 * r)) + 1)) + i)));
          m <-
          (BArray128.set128 m (4 + i)
          (VREV32_16u8 (BArray128.get128 m (4 + i))));
          i <- (i + 1);
        }
        (st, m) <@ __sha256_x8_block2 (st, r, m, k);
        r <- (r + 1);
      }
      h8 <@ __sha256_x8_store_half (h8, st, f);
      f <- (f + 1);
    }
    return (h8, ms);
  }
  proc _sha256_x8_compress_lanes (h8:BArray256.t, in_0:BArray64.t, off:W64.t,
                                  n:W64.t, ms:W64.t) : BArray256.t * W64.t = {
    var k:BArray256.t;
    var f:int;
    var st:BArray128.t;
    var r:int;
    var p:W64.t;
    var q:W64.t;
    var c:W64.t;
    var more:bool;
    var i:int;
    var m:BArray128.t;
    k <- witness;
    m <- witness;
    st <- witness;
    k <- sHA256_K;
    f <- 0;
    while ((f < 2)) {
      st <@ __sha256_x8_load_half (h8, f);
      r <- 0;
      while ((r < 2)) {
        p <- (BArray64.get64 in_0 ((4 * f) + (2 * r)));
        p <- (protect_64 p ms);
        p <- (p + off);
        q <- (BArray64.get64 in_0 (((4 * f) + (2 * r)) + 1));
        q <- (protect_64 q ms);
        q <- (q + off);
        c <- n;
        more <- (c <> (W64.of_int 0));
        while (more) {
          ms <- (update_msf more ms);
          i <- 0;
          while ((i < 4)) {
            m <-
            (BArray128.set128 m i
            (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i))))));
            m <- (BArray128.set128 m i (VREV32_16u8 (BArray128.get128 m i)));
            m <-
            (BArray128.set128 m (4 + i)
            (loadW128 Glob.mem (W64.to_uint (q + (W64.of_int (16 * i))))));
            m <-
            (BArray128.set128 m (4 + i)
            (VREV32_16u8 (BArray128.get128 m (4 + i))));
            i <- (i + 1);
          }
          (st, m) <@ __sha256_x8_block2 (st, r, m, k);
          p <- (p + (W64.of_int 64));
          q <- (q + (W64.of_int 64));
          c <- (c - (W64.of_int 1));
          more <- (c <> (W64.of_int 0));
        }
        ms <- (update_msf (! more) ms);
        r <- (r + 1);
      }
      h8 <@ __sha256_x8_store_half (h8, st, f);
      f <- (f + 1);
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
  proc __sha512_x4_load_pair (h4:BArray256.t, i:int) : BArray160.t = {
    var s:BArray160.t;
    var q:int;
    var a:W128.t;
    var b:W128.t;
    s <- witness;
    q <- 0;
    while ((q < 4)) {
      a <- (BArray256.get128 h4 ((2 * (2 * q)) + i));
      b <- (BArray256.get128 h4 ((2 * ((2 * q) + 1)) + i));
      s <- (BArray160.set128 s q (VTRN1_2u64 a b));
      s <- (BArray160.set128 s (5 + q) (VTRN2_2u64 a b));
      q <- (q + 1);
    }
    return s;
  }
  proc __sha512_x4_store_pair (h4:BArray256.t, s:BArray160.t, i:int) : 
  BArray256.t = {
    var q:int;
    var a:W128.t;
    var b:W128.t;
    q <- 0;
    while ((q < 4)) {
      a <- (VTRN1_2u64 (BArray160.get128 s q) (BArray160.get128 s (5 + q)));
      b <- (VTRN2_2u64 (BArray160.get128 s q) (BArray160.get128 s (5 + q)));
      h4 <- (BArray256.set128 h4 ((2 * (2 * q)) + i) a);
      h4 <- (BArray256.set128 h4 ((2 * ((2 * q) + 1)) + i) b);
      q <- (q + 1);
    }
    return h4;
  }
  proc __sha512_x4_block2 (s:BArray160.t, m:BArray256.t, k:BArray640.t) : 
  BArray160.t * BArray256.t = {
    var j:int;
    var l:int;
    var save:BArray128.t;
    var i0:int;
    var i1:int;
    var i2:int;
    var i3:int;
    var i4:int;
    var g:int;
    var kv:W128.t;
    var wk:W128.t;
    var x:W128.t;
    var y:W128.t;
    var z:W128.t;
    var t:int;
    save <- witness;
    l <- 0;
    while ((l < 2)) {
      j <- 0;
      while ((j < 4)) {
        save <-
        (BArray128.set128 save ((4 * l) + j)
        (BArray160.get128 s ((5 * l) + j)));
        j <- (j + 1);
      }
      l <- (l + 1);
    }
    i0 <- 0;
    i1 <- 1;
    i2 <- 2;
    i3 <- 3;
    i4 <- 4;
    g <- 0;
    while ((g < 40)) {
      j <- (g %% 8);
      kv <- (BArray640.get128 k g);
      l <- 0;
      while ((l < 2)) {
        wk <- (VADD_2u64 kv (BArray256.get128 m ((8 * l) + j)));
        wk <- (VEXT wk wk (W8.of_int 8));
        x <-
        (VEXT (BArray160.get128 s ((5 * l) + i2))
        (BArray160.get128 s ((5 * l) + i3)) (W8.of_int 8));
        y <-
        (VEXT (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i2)) (W8.of_int 8));
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + i3)) wk));
        if ((g < 32)) {
          z <-
          (VEXT (BArray256.get128 m ((8 * l) + ((j + 4) %% 8)))
          (BArray256.get128 m ((8 * l) + ((j + 5) %% 8))) (W8.of_int 8));
          m <-
          (BArray256.set128 m ((8 * l) + j)
          (SHA512SU0 (BArray256.get128 m ((8 * l) + j))
          (BArray256.get128 m ((8 * l) + ((j + 1) %% 8)))));
          m <-
          (BArray256.set128 m ((8 * l) + j)
          (SHA512SU1 (BArray256.get128 m ((8 * l) + j))
          (BArray256.get128 m ((8 * l) + ((j + 7) %% 8))) z));
        } else {
          
        }
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (SHA512H (BArray160.get128 s ((5 * l) + i3)) x y));
        s <-
        (BArray160.set128 s ((5 * l) + i4)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i3))));
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (SHA512H2 (BArray160.get128 s ((5 * l) + i3))
        (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i0))));
        l <- (l + 1);
      }
      t <- i0;
      i0 <- i3;
      i3 <- i2;
      i2 <- i4;
      i4 <- i1;
      i1 <- t;
      g <- (g + 1);
    }
    l <- 0;
    while ((l < 2)) {
      j <- 0;
      while ((j < 4)) {
        x <- (BArray128.get128 save ((4 * l) + j));
        s <-
        (BArray160.set128 s ((5 * l) + j)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + j)) x));
        j <- (j + 1);
      }
      l <- (l + 1);
    }
    return (s, m);
  }
  proc _sha512_x4_compress (h4:BArray256.t, blocks:BArray512.t, ms:W64.t) : 
  BArray256.t * W64.t = {
    var k:BArray640.t;
    var i:int;
    var s:BArray160.t;
    var j:int;
    var m:BArray256.t;
    k <- witness;
    m <- witness;
    s <- witness;
    k <- sHA512_K;
    i <- 0;
    while ((i < 2)) {
      s <@ __sha512_x4_load_pair (h4, i);
      j <- 0;
      while ((j < 8)) {
        m <-
        (BArray256.set128 m j (BArray512.get128 blocks ((8 * (2 * i)) + j)));
        m <- (BArray256.set128 m j (VREV64_16u8 (BArray256.get128 m j)));
        m <-
        (BArray256.set128 m (8 + j)
        (BArray512.get128 blocks ((8 * ((2 * i) + 1)) + j)));
        m <-
        (BArray256.set128 m (8 + j)
        (VREV64_16u8 (BArray256.get128 m (8 + j))));
        j <- (j + 1);
      }
      (s, m) <@ __sha512_x4_block2 (s, m, k);
      h4 <@ __sha512_x4_store_pair (h4, s, i);
      i <- (i + 1);
    }
    return (h4, ms);
  }
  proc _sha512_x4_compress_lanes (h4:BArray256.t, in_0:BArray32.t, off:W64.t,
                                  n:W64.t, ms:W64.t) : BArray256.t * W64.t = {
    var k:BArray640.t;
    var i:int;
    var s:BArray160.t;
    var p:W64.t;
    var q:W64.t;
    var c:W64.t;
    var more:bool;
    var j:int;
    var m:BArray256.t;
    k <- witness;
    m <- witness;
    s <- witness;
    k <- sHA512_K;
    i <- 0;
    while ((i < 2)) {
      s <@ __sha512_x4_load_pair (h4, i);
      p <- (BArray32.get64 in_0 (2 * i));
      p <- (protect_64 p ms);
      p <- (p + off);
      q <- (BArray32.get64 in_0 ((2 * i) + 1));
      q <- (protect_64 q ms);
      q <- (q + off);
      c <- n;
      more <- (c <> (W64.of_int 0));
      while (more) {
        ms <- (update_msf more ms);
        j <- 0;
        while ((j < 8)) {
          m <-
          (BArray256.set128 m j
          (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
          m <- (BArray256.set128 m j (VREV64_16u8 (BArray256.get128 m j)));
          m <-
          (BArray256.set128 m (8 + j)
          (loadW128 Glob.mem (W64.to_uint (q + (W64.of_int (16 * j))))));
          m <-
          (BArray256.set128 m (8 + j)
          (VREV64_16u8 (BArray256.get128 m (8 + j))));
          j <- (j + 1);
        }
        (s, m) <@ __sha512_x4_block2 (s, m, k);
        p <- (p + (W64.of_int 128));
        q <- (q + (W64.of_int 128));
        c <- (c - (W64.of_int 1));
        more <- (c <> (W64.of_int 0));
      }
      ms <- (update_msf (! more) ms);
      h4 <@ __sha512_x4_store_pair (h4, s, i);
      i <- (i + 1);
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
  proc __sha256_x8_ctx_init (ctx:BArray784.t) : BArray784.t = {
    var aux:BArray256.t;
    var tag:W64.t;
    var z:W64.t;
    var i:int;
    tag <@ __sha2_tag (9);
    ctx <- (BArray784.set64d ctx 0 tag);
    z <- (W64.of_int 0);
    ctx <- (BArray784.set64d ctx 8 z);
    aux <@ __sha256_x8_init ((SBArray784_256.get_sub32 ctx 4));
    ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
    i <- 0;
    while ((i < 64)) {
      ctx <- (BArray784.set64d ctx (272 + (8 * i)) z);
      i <- (i + 1);
    }
    return ctx;
  }
  proc _sha256_x8_ctx_from (ctx:BArray784.t, src:BArray112.t, ms:W64.t) : 
  BArray784.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray512.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    (tag, total) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 src 0), ms);
    expect_0 <@ __sha2_tag (2);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      tag <@ __sha2_tag (9);
      ctx <- (BArray784.set64d ctx 0 tag);
      ctx <- (BArray784.set64d ctx 8 total);
      (aux, aux_0) <@ __sha256_x8_from ((SBArray784_256.get_sub32 ctx 4),
      (SBArray784_512.get_sub8 ctx 272), (SBArray112_32.get_sub32 src 4),
      (SBArray112_64.get_sub8 src 48));
      ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha256_x8_ctx_update (ctx:BArray784.t, in_0:BArray64.t, inlen:W64.t,
                              ms:W64.t) : BArray784.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray512.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var room:W64.t;
    (tag, total) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (9);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      room <@ __sha2_room (total);
      status <- (W64.of_int 2);
      ok <- (inlen \ult room);
      if (ok) {
        ms <- (update_msf ok ms);
        (aux, aux_0, aux_1, aux_2) <@ _sha256_x8_absorb_lanes ((
                                                               SBArray784_256.get_sub32
                                                               ctx 4),
        (SBArray784_512.get_sub8 ctx 272), total, in_0, inlen, ms);
        ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
        ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx <- (BArray784.set64d ctx 8 total);
        status <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! ok) ms);
      }
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha256_x8_ctx_final (ctx:BArray784.t, out:BArray256.t, ms:W64.t) : 
  BArray784.t * BArray256.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var aux_1:BArray512.t;
    var aux_2:W64.t;
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (9);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (aux, aux_0, aux_1, aux_2) <@ _sha256_x8_finalize (out,
      (SBArray784_256.get_sub32 ctx 4), (SBArray784_512.get_sub8 ctx 272),
      total, ms);
      out <- aux;
      ctx <- (SBArray784_256.set_sub32 ctx 4 aux_0);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_1);
      ms <- aux_2;
      z <- (W64.of_int 0);
      inc <- (784 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray784.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, out, status, ms);
  }
  proc __sha512_x4_ctx_init (ctx:BArray784.t) : BArray784.t = {
    var aux:BArray256.t;
    var tag:W64.t;
    var z:W64.t;
    var i:int;
    tag <@ __sha2_tag (10);
    ctx <- (BArray784.set64d ctx 0 tag);
    z <- (W64.of_int 0);
    ctx <- (BArray784.set64d ctx 8 z);
    aux <@ __sha512_x4_init ((SBArray784_256.get_sub64 ctx 2));
    ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
    i <- 0;
    while ((i < 64)) {
      ctx <- (BArray784.set64d ctx (272 + (8 * i)) z);
      i <- (i + 1);
    }
    return ctx;
  }
  proc _sha512_x4_ctx_from (ctx:BArray784.t, src:BArray208.t, ms:W64.t) : 
  BArray784.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray512.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    (tag, total) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 src 0), ms);
    expect_0 <@ __sha2_tag (4);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      tag <@ __sha2_tag (10);
      ctx <- (BArray784.set64d ctx 0 tag);
      ctx <- (BArray784.set64d ctx 8 total);
      (aux, aux_0) <@ __sha512_x4_from ((SBArray784_256.get_sub64 ctx 2),
      (SBArray784_512.get_sub8 ctx 272), (SBArray208_64.get_sub64 src 2),
      (SBArray208_128.get_sub8 src 80));
      ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha512_x4_ctx_update (ctx:BArray784.t, in_0:BArray32.t, inlen:W64.t,
                              ms:W64.t) : BArray784.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray512.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var room:W64.t;
    (tag, total) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (10);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      room <@ __sha2_room (total);
      status <- (W64.of_int 2);
      ok <- (inlen \ult room);
      if (ok) {
        ms <- (update_msf ok ms);
        (aux, aux_0, aux_1, aux_2) <@ _sha512_x4_absorb_lanes ((
                                                               SBArray784_256.get_sub64
                                                               ctx 2),
        (SBArray784_512.get_sub8 ctx 272), total, in_0, inlen, ms);
        ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
        ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx <- (BArray784.set64d ctx 8 total);
        status <- (W64.of_int 0);
      } else {
        ms <- (update_msf (! ok) ms);
      }
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, status, ms);
  }
  proc _sha512_x4_ctx_final (ctx:BArray784.t, out:BArray256.t, ms:W64.t) : 
  BArray784.t * BArray256.t * W64.t * W64.t = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var aux_1:BArray512.t;
    var aux_2:W64.t;
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    (tag, total) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 ctx 0), ms);
    expect_0 <@ __sha2_tag (10);
    status <- (W64.of_int 1);
    ok <- (tag = expect_0);
    if (ok) {
      ms <- (update_msf ok ms);
      (aux, aux_0, aux_1, aux_2) <@ _sha512_x4_finalize (out,
      (SBArray784_256.get_sub64 ctx 2), (SBArray784_512.get_sub8 ctx 272),
      total, ms);
      out <- aux;
      ctx <- (SBArray784_256.set_sub64 ctx 2 aux_0);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_1);
      ms <- aux_2;
      z <- (W64.of_int 0);
      inc <- (784 %/ 8);
      i <- 0;
      while ((i < inc)) {
        ctx <- (BArray784.set64d ctx (8 * i) z);
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
    } else {
      ms <- (update_msf (! ok) ms);
    }
    return (ctx, out, status, ms);
  }
  proc sha224 (out:BArray28.t, in_0:W64.t, inlen:W64.t) : BArray28.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha224_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha256 (out:BArray32.t, in_0:W64.t, inlen:W64.t) : BArray32.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha256_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha384 (out:BArray48.t, in_0:W64.t, inlen:W64.t) : BArray48.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha384_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha512 (out:BArray64.t, in_0:W64.t, inlen:W64.t) : BArray64.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha512_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha512_224 (out:BArray28.t, in_0:W64.t, inlen:W64.t) : BArray28.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha512_224_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha512_256 (out:BArray32.t, in_0:W64.t, inlen:W64.t) : BArray32.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha512_256_mem (out, in_0, inlen, ms);
    return out;
  }
  proc sha224_init (ctx:BArray112.t) : BArray112.t = {
    var ms:W64.t;
    var h:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha224_init (h);
    tag <@ __sha2_tag (1);
    total <- (W64.of_int 0);
    ctx <@ __sha256_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha224_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t) : BArray112.t *
                                                                  W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (1);
    (ctx, status, ms) <@ _sha256_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha224_final (ctx:BArray112.t, out:BArray28.t) : BArray112.t *
                                                        BArray28.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (1);
    (ctx, out, status, ms) <@ _sha224_ctx___sha2_ctx_final (ctx, out,
    expect_0, ms);
    return (ctx, out, status);
  }
  proc sha256_init (ctx:BArray112.t) : BArray112.t = {
    var ms:W64.t;
    var h:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha256_init (h);
    tag <@ __sha2_tag (2);
    total <- (W64.of_int 0);
    ctx <@ __sha256_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha256_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t) : BArray112.t *
                                                                  W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (2);
    (ctx, status, ms) <@ _sha256_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha256_final (ctx:BArray112.t, out:BArray32.t) : BArray112.t *
                                                        BArray32.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (2);
    (ctx, out, status, ms) <@ _sha256_ctx___sha2_ctx_final (ctx, out,
    expect_0, ms);
    return (ctx, out, status);
  }
  proc sha384_init (ctx:BArray208.t) : BArray208.t = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha384_init (h);
    tag <@ __sha2_tag (3);
    total <- (W64.of_int 0);
    ctx <@ __sha512_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha384_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t) : BArray208.t *
                                                                  W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (3);
    (ctx, status, ms) <@ _sha512_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha384_final (ctx:BArray208.t, out:BArray48.t) : BArray208.t *
                                                        BArray48.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (3);
    (ctx, out, status, ms) <@ _sha384_ctx___sha2_ctx_final (ctx, out,
    expect_0, ms);
    return (ctx, out, status);
  }
  proc sha512_init (ctx:BArray208.t) : BArray208.t = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha512_init (h);
    tag <@ __sha2_tag (4);
    total <- (W64.of_int 0);
    ctx <@ __sha512_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha512_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t) : BArray208.t *
                                                                  W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (4);
    (ctx, status, ms) <@ _sha512_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha512_final (ctx:BArray208.t, out:BArray64.t) : BArray208.t *
                                                        BArray64.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (4);
    (ctx, out, status, ms) <@ _sha512_ctx___sha2_ctx_final (ctx, out,
    expect_0, ms);
    return (ctx, out, status);
  }
  proc sha512_224_init (ctx:BArray208.t) : BArray208.t = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha512_224_init (h);
    tag <@ __sha2_tag (5);
    total <- (W64.of_int 0);
    ctx <@ __sha512_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha512_224_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t) : 
  BArray208.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (5);
    (ctx, status, ms) <@ _sha512_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha512_224_final (ctx:BArray208.t, out:BArray28.t) : BArray208.t *
                                                            BArray28.t *
                                                            W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (5);
    (ctx, out, status, ms) <@ _sha512_224_ctx___sha2_ctx_final (ctx, 
    out, expect_0, ms);
    return (ctx, out, status);
  }
  proc sha512_256_init (ctx:BArray208.t) : BArray208.t = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    h <- witness;
    ms <- (init_msf);
    h <@ __sha512_256_init (h);
    tag <@ __sha2_tag (6);
    total <- (W64.of_int 0);
    ctx <@ __sha512_ctx_init (ctx, h, tag, total);
    return ctx;
  }
  proc sha512_256_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t) : 
  BArray208.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (6);
    (ctx, status, ms) <@ _sha512_ctx_update (ctx, in_0, inlen, expect_0, ms);
    return (ctx, status);
  }
  proc sha512_256_final (ctx:BArray208.t, out:BArray32.t) : BArray208.t *
                                                            BArray32.t *
                                                            W64.t = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (6);
    (ctx, out, status, ms) <@ _sha512_256_ctx___sha2_ctx_final (ctx, 
    out, expect_0, ms);
    return (ctx, out, status);
  }
  proc hmac_sha256 (out:BArray32.t, key:W64.t, keylen:W64.t, msg:W64.t,
                    msglen:W64.t) : BArray32.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _hmac_sha256_mem (out, key, keylen, msg, msglen, ms);
    return out;
  }
  proc hmac_sha512 (out:BArray64.t, key:W64.t, keylen:W64.t, msg:W64.t,
                    msglen:W64.t) : BArray64.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _hmac_sha512_mem (out, key, keylen, msg, msglen, ms);
    return out;
  }
  proc hmac_sha256_init (ctx:BArray144.t, key:W64.t, keylen:W64.t) : 
  BArray144.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, ms) <@ __hmac_sha256_ctx_init (ctx, key, keylen, ms);
    return ctx;
  }
  proc hmac_sha256_update (ctx:BArray144.t, in_0:W64.t, inlen:W64.t) : 
  BArray144.t * W64.t = {
    var aux:BArray112.t;
    var aux_0:W64.t;
    var aux_1:W64.t;
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (7);
    (aux, aux_0, aux_1) <@ _sha256_ctx_update ((SBArray144_112.get_sub8 
                                               ctx 0),
    in_0, inlen, expect_0, ms);
    ctx <- (SBArray144_112.set_sub8 ctx 0 aux);
    status <- aux_0;
    ms <- aux_1;
    return (ctx, status);
  }
  proc hmac_sha256_final (ctx:BArray144.t, out:BArray32.t) : BArray144.t *
                                                             BArray32.t *
                                                             W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, out, status, ms) <@ __hmac_sha256_ctx_final (ctx, out, ms);
    return (ctx, out, status);
  }
  proc hmac_sha512_init (ctx:BArray272.t, key:W64.t, keylen:W64.t) : 
  BArray272.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, ms) <@ __hmac_sha512_ctx_init (ctx, key, keylen, ms);
    return ctx;
  }
  proc hmac_sha512_update (ctx:BArray272.t, in_0:W64.t, inlen:W64.t) : 
  BArray272.t * W64.t = {
    var aux:BArray208.t;
    var aux_0:W64.t;
    var aux_1:W64.t;
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    ms <- (init_msf);
    expect_0 <@ __sha2_tag (8);
    (aux, aux_0, aux_1) <@ _sha512_ctx_update ((SBArray272_208.get_sub8 
                                               ctx 0),
    in_0, inlen, expect_0, ms);
    ctx <- (SBArray272_208.set_sub8 ctx 0 aux);
    status <- aux_0;
    ms <- aux_1;
    return (ctx, status);
  }
  proc hmac_sha512_final (ctx:BArray272.t, out:BArray64.t) : BArray272.t *
                                                             BArray64.t *
                                                             W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, out, status, ms) <@ __hmac_sha512_ctx_final (ctx, out, ms);
    return (ctx, out, status);
  }
  proc sha256_x8 (out:BArray256.t, in_0:BArray64.t, len:W64.t) : BArray256.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha256_x8_lanes (out, in_0, len, ms);
    return out;
  }
  proc sha256_x8_init (ctx:BArray784.t) : BArray784.t = {
    var ms:W64.t;
    ms <- (init_msf);
    ctx <@ __sha256_x8_ctx_init (ctx);
    return ctx;
  }
  proc sha256_x8_init_from (ctx:BArray784.t, src:BArray112.t) : BArray784.t *
                                                                W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, status, ms) <@ _sha256_x8_ctx_from (ctx, src, ms);
    return (ctx, status);
  }
  proc sha256_x8_update (ctx:BArray784.t, in_0:BArray64.t, inlen:W64.t) : 
  BArray784.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, status, ms) <@ _sha256_x8_ctx_update (ctx, in_0, inlen, ms);
    return (ctx, status);
  }
  proc sha256_x8_final (ctx:BArray784.t, out:BArray256.t) : BArray784.t *
                                                            BArray256.t *
                                                            W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, out, status, ms) <@ _sha256_x8_ctx_final (ctx, out, ms);
    return (ctx, out, status);
  }
  proc sha512_x4 (out:BArray256.t, in_0:BArray32.t, len:W64.t) : BArray256.t = {
    var ms:W64.t;
    ms <- (init_msf);
    (out, ms) <@ _sha512_x4_lanes (out, in_0, len, ms);
    return out;
  }
  proc sha512_x4_init (ctx:BArray784.t) : BArray784.t = {
    var ms:W64.t;
    ms <- (init_msf);
    ctx <@ __sha512_x4_ctx_init (ctx);
    return ctx;
  }
  proc sha512_x4_init_from (ctx:BArray784.t, src:BArray208.t) : BArray784.t *
                                                                W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, status, ms) <@ _sha512_x4_ctx_from (ctx, src, ms);
    return (ctx, status);
  }
  proc sha512_x4_update (ctx:BArray784.t, in_0:BArray32.t, inlen:W64.t) : 
  BArray784.t * W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, status, ms) <@ _sha512_x4_ctx_update (ctx, in_0, inlen, ms);
    return (ctx, status);
  }
  proc sha512_x4_final (ctx:BArray784.t, out:BArray256.t) : BArray784.t *
                                                            BArray256.t *
                                                            W64.t = {
    var status:W64.t;
    var ms:W64.t;
    ms <- (init_msf);
    (ctx, out, status, ms) <@ _sha512_x4_ctx_final (ctx, out, ms);
    return (ctx, out, status);
  }
}.
