require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_x86.

import SLH64.

require import
BArray16 BArray28 BArray32 BArray48 BArray64 BArray112 BArray128 BArray144
BArray208 BArray256 BArray272 BArray512 BArray640 BArray784 BArray1280
SBArray112_16 SBArray144_16 SBArray208_16 SBArray272_16 SBArray784_16
SBArray112_32 SBArray112_64 SBArray208_64 SBArray512_64 SBArray144_112
SBArray208_128 SBArray512_128 SBArray272_208 SBArray784_256 SBArray784_512.

abbrev sHA256_X8_SHANI_BSWAP =
(BArray16.of_list32
[(W32.of_int 66051); (W32.of_int 67438087); (W32.of_int 134810123);
(W32.of_int 202182159)]).

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

abbrev sHA512_AVX2_BSWAP =
(BArray32.of_list64
[(W64.of_int 283686952306183); (W64.of_int 579005069656919567);
(W64.of_int 283686952306183); (W64.of_int 579005069656919567)]).

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

abbrev sHA256_SHANI_BSWAP =
(BArray16.of_list32
[(W32.of_int 66051); (W32.of_int 67438087); (W32.of_int 134810123);
(W32.of_int 202182159)]).

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
    
    x <- (BSWAP_32 x);
    return x;
  }
  proc __bswap64 (x:W64.t) : W64.t = {
    
    x <- (BSWAP_64 x);
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
  proc __shani_load_state (h:BArray32.t) : W128.t * W128.t = {
    var abef:W128.t;
    var cdgh:W128.t;
    var lo:W128.t;
    var hi:W128.t;
    var t:W128.t;
    lo <- (BArray32.get128 h 0);
    hi <- (BArray32.get128 h 1);
    t <- (VPSHUFD_128 lo (W8.of_int 177));
    cdgh <- (VPSHUFD_128 hi (W8.of_int 27));
    abef <- (VPALIGNR_128 t cdgh (W8.of_int 8));
    cdgh <- (VPBLEND_8u16 cdgh t (W8.of_int 240));
    return (abef, cdgh);
  }
  proc __shani_store_state (h:BArray32.t, abef:W128.t, cdgh:W128.t) : 
  BArray32.t = {
    var t:W128.t;
    var lo:W128.t;
    var hi:W128.t;
    t <- (VPSHUFD_128 abef (W8.of_int 27));
    cdgh <- (VPSHUFD_128 cdgh (W8.of_int 177));
    lo <- (VPBLEND_8u16 t cdgh (W8.of_int 240));
    hi <- (VPALIGNR_128 cdgh t (W8.of_int 8));
    h <- (BArray32.set128 h 0 lo);
    h <- (BArray32.set128 h 1 hi);
    return h;
  }
  proc __shani_block (abef:W128.t, cdgh:W128.t, w:BArray64.t, k:BArray256.t) : 
  W128.t * W128.t * BArray64.t = {
    var abef0:W128.t;
    var cdgh0:W128.t;
    var g:int;
    var t:W128.t;
    var wk:W128.t;
    abef0 <- abef;
    cdgh0 <- cdgh;
    g <- 0;
    while ((g < 16)) {
      if ((4 <= g)) {
        w <-
        (BArray64.set128 w (g %% 4)
        (SHA256MSG1 (BArray64.get128 w (g %% 4))
        (BArray64.get128 w ((g + 1) %% 4))));
        t <-
        (VPALIGNR_128 (BArray64.get128 w ((g + 3) %% 4))
        (BArray64.get128 w ((g + 2) %% 4)) (W8.of_int 4));
        w <-
        (BArray64.set128 w (g %% 4)
        (VPADD_4u32 (BArray64.get128 w (g %% 4)) t));
        w <-
        (BArray64.set128 w (g %% 4)
        (SHA256MSG2 (BArray64.get128 w (g %% 4))
        (BArray64.get128 w ((g + 3) %% 4))));
      } else {
        
      }
      wk <- (VPADD_4u32 (BArray64.get128 w (g %% 4)) (BArray256.get128 k g));
      cdgh <- (SHA256RNDS2 cdgh abef wk);
      wk <- (VPSHUFD_128 wk (W8.of_int 14));
      abef <- (SHA256RNDS2 abef cdgh wk);
      g <- (g + 1);
    }
    abef <- (VPADD_4u32 abef abef0);
    cdgh <- (VPADD_4u32 cdgh cdgh0);
    return (abef, cdgh, w);
  }
  proc __shani_rounds (h:BArray32.t, w:BArray64.t) : BArray32.t = {
    var abef:W128.t;
    var cdgh:W128.t;
    var k:BArray256.t;
    k <- witness;
    (abef, cdgh) <@ __shani_load_state (h);
    k <- sHA256_K;
    (abef, cdgh, w) <@ __shani_block (abef, cdgh, w, k);
    h <@ __shani_store_state (h, abef, cdgh);
    return h;
  }
  proc _sha256_compress (h:BArray32.t, block:BArray64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var mask_p:BArray16.t;
    var mask:W128.t;
    var i:int;
    var w:BArray64.t;
    var hi:W128.t;
    mask_p <- witness;
    w <- witness;
    mask_p <- sHA256_SHANI_BSWAP;
    mask <- (BArray16.get128 mask_p 0);
    i <- 0;
    while ((i < 4)) {
      w <- (BArray64.set128 w i (VMOV_64 (BArray64.get64 block (2 * i))));
      hi <- (VMOV_64 (BArray64.get64 block ((2 * i) + 1)));
      w <- (BArray64.set128 w i (VPUNPCKL_2u64 (BArray64.get128 w i) hi));
      w <- (BArray64.set128 w i (VPSHUFB_128 (BArray64.get128 w i) mask));
      i <- (i + 1);
    }
    h <@ __shani_rounds (h, w);
    return (h, ms);
  }
  proc _sha256_compress_one (h:BArray32.t, p:W64.t, ms:W64.t) : BArray32.t *
                                                                W64.t = {
    var mask_p:BArray16.t;
    var mask:W128.t;
    var i:int;
    var w:BArray64.t;
    mask_p <- witness;
    w <- witness;
    mask_p <- sHA256_SHANI_BSWAP;
    mask <- (BArray16.get128 mask_p 0);
    i <- 0;
    while ((i < 4)) {
      w <-
      (BArray64.set128 w i
      (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i))))));
      w <- (BArray64.set128 w i (VPSHUFB_128 (BArray64.get128 w i) mask));
      i <- (i + 1);
    }
    h <@ __shani_rounds (h, w);
    return (h, ms);
  }
  proc _sha256_compress_blocks (h:BArray32.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray32.t * W64.t = {
    var abef:W128.t;
    var cdgh:W128.t;
    var k:BArray256.t;
    var mask_p:BArray16.t;
    var mask:W128.t;
    var more:bool;
    var i:int;
    var w:BArray64.t;
    k <- witness;
    mask_p <- witness;
    w <- witness;
    (abef, cdgh) <@ __shani_load_state (h);
    k <- sHA256_K;
    mask_p <- sHA256_SHANI_BSWAP;
    mask <- (BArray16.get128 mask_p 0);
    more <- (n <> (W64.of_int 0));
    while (more) {
      ms <- (update_msf more ms);
      i <- 0;
      while ((i < 4)) {
        w <-
        (BArray64.set128 w i
        (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i))))));
        w <- (BArray64.set128 w i (VPSHUFB_128 (BArray64.get128 w i) mask));
        i <- (i + 1);
      }
      (abef, cdgh, w) <@ __shani_block (abef, cdgh, w, k);
      p <- (p + (W64.of_int 64));
      n <- (n - (W64.of_int 1));
      more <- (n <> (W64.of_int 0));
    }
    ms <- (update_msf (! more) ms);
    h <@ __shani_store_state (h, abef, cdgh);
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
  proc __sha512_avx2_round (v:BArray64.t, m:BArray16.t, s:W64.t, t:int,
                            x:BArray256.t, j:int, ph:int) : BArray64.t *
                                                            BArray16.t *
                                                            W64.t *
                                                            BArray256.t = {
    var oF:bool;
    var sF:bool;
    var zF:bool;
    var pF:bool;
    var cF:bool;
    var vs:W256.t;
    var vw:W256.t;
    var vu:W256.t;
    var y:W64.t;
    var vt:W256.t;
    var z:W64.t;
    var w:W64.t;
    if ((ph = 0)) {
      vs <-
      (VPALIGNR_256 (BArray256.get256 x ((j + 1) %% 8))
      (BArray256.get256 x (j %% 8)) (W8.of_int 8));
      vw <-
      (VPALIGNR_256 (BArray256.get256 x ((j + 5) %% 8))
      (BArray256.get256 x ((j + 4) %% 8)) (W8.of_int 8));
    } else {
      
    }
    if ((ph = 1)) {
      vu <-
      ((BArray256.get256 x ((j + 7) %% 8)) \vshr64u256 (W128.of_int 6));
      vw <-
      ((BArray256.get256 x ((j + 7) %% 8)) \vshl64u256 (W128.of_int 3));
    } else {
      
    }
    v <-
    (BArray64.set64 v (((0 + 80) - t) %% 8)
    ((BArray64.get64 v (((0 + 80) - t) %% 8)) + s));
    y <- (BArray64.get64 v (((5 + 80) - t) %% 8));
    y <- (y `&` (BArray64.get64 v (((4 + 80) - t) %% 8)));
    if ((ph = 0)) {
      x <-
      (BArray256.set256 x (j %% 8)
      ((BArray256.get256 x (j %% 8)) \vadd64u256 vw));
      vt <- (vs \vshr64u256 (W128.of_int 1));
    } else {
      
    }
    if ((ph = 1)) {
      vt <-
      ((BArray256.get256 x ((j + 7) %% 8)) \vshr64u256 (W128.of_int 19));
      vu <- (vu `^` vw);
    } else {
      
    }
    z <- (RORX_64 (BArray64.get64 v (((4 + 80) - t) %% 8)) (W8.of_int 41));
    w <- (RORX_64 (BArray64.get64 v (((4 + 80) - t) %% 8)) (W8.of_int 18));
    v <-
    (BArray64.set64 v (((7 + 80) - t) %% 8)
    ((BArray64.get64 v (((7 + 80) - t) %% 8)) + y));
    if ((ph = 0)) {
      vu <- (vs \vshr64u256 (W128.of_int 7));
      vw <- (vs \vshl64u256 (W128.of_int 56));
    } else {
      
    }
    if ((ph = 1)) {
      vw <- (vw \vshl64u256 (W128.of_int 42));
      vu <- (vu `^` vt);
    } else {
      
    }
    (oF, cF, sF, pF, zF, y) <-
    (ANDN_64 (BArray64.get64 v (((4 + 80) - t) %% 8))
    (BArray64.get64 v (((6 + 80) - t) %% 8)));
    z <- (z `^` w);
    w <- (RORX_64 (BArray64.get64 v (((4 + 80) - t) %% 8)) (W8.of_int 14));
    if ((ph = 0)) {
      vu <- (vu `^` vt);
      vt <- (vt \vshr64u256 (W128.of_int 7));
    } else {
      
    }
    if ((ph = 1)) {
      vt <- (vt \vshr64u256 (W128.of_int 42));
      vu <- (vu `^` vw);
    } else {
      
    }
    v <-
    (BArray64.set64 v (((7 + 80) - t) %% 8)
    ((BArray64.get64 v (((7 + 80) - t) %% 8)) + y));
    z <- (z `^` w);
    m <-
    (BArray16.set64 m ((t + 1) %% 2) (BArray64.get64 v (((0 + 80) - t) %% 8))
    );
    y <- (RORX_64 (BArray64.get64 v (((0 + 80) - t) %% 8)) (W8.of_int 39));
    if ((ph = 0)) {
      vu <- (vu `^` vw);
      vw <- (vw \vshl64u256 (W128.of_int 7));
    } else {
      
    }
    if ((ph = 1)) {
      vu <- (vu `^` vt);
    } else {
      
    }
    v <-
    (BArray64.set64 v (((7 + 80) - t) %% 8)
    ((BArray64.get64 v (((7 + 80) - t) %% 8)) + z));
    m <-
    (BArray16.set64 m ((t + 1) %% 2)
    ((BArray16.get64 m ((t + 1) %% 2)) `^`
    (BArray64.get64 v (((1 + 80) - t) %% 8))));
    s <- (RORX_64 (BArray64.get64 v (((0 + 80) - t) %% 8)) (W8.of_int 34));
    if ((ph = 0)) {
      vu <- (vu `^` vt);
      vu <- (vu `^` vw);
    } else {
      
    }
    if ((ph = 1)) {
      x <-
      (BArray256.set256 x (j %% 8)
      ((BArray256.get256 x (j %% 8)) \vadd64u256 vu));
    } else {
      
    }
    z <- (RORX_64 (BArray64.get64 v (((0 + 80) - t) %% 8)) (W8.of_int 28));
    v <-
    (BArray64.set64 v (((3 + 80) - t) %% 8)
    ((BArray64.get64 v (((3 + 80) - t) %% 8)) +
    (BArray64.get64 v (((7 + 80) - t) %% 8))));
    m <-
    (BArray16.set64 m (t %% 2)
    ((BArray16.get64 m (t %% 2)) `&` (BArray16.get64 m ((t + 1) %% 2))));
    s <- (s `^` y);
    if ((ph = 0)) {
      x <-
      (BArray256.set256 x (j %% 8)
      ((BArray256.get256 x (j %% 8)) \vadd64u256 vu));
    } else {
      
    }
    m <-
    (BArray16.set64 m (t %% 2)
    ((BArray16.get64 m (t %% 2)) `^`
    (BArray64.get64 v (((1 + 80) - t) %% 8))));
    s <- (s `^` z);
    v <-
    (BArray64.set64 v (((7 + 80) - t) %% 8)
    ((BArray64.get64 v (((7 + 80) - t) %% 8)) + (BArray16.get64 m (t %% 2))));
    return (v, m, s, x);
  }
  proc __sha512_avx2 (h:BArray64.t, x:BArray256.t, nb:int, ms:W64.t) : 
  BArray64.t * W64.t = {
    var inc:int;
    var i:int;
    var k:W256.t;
    var wk:BArray1280.t;
    var v:BArray64.t;
    var m:BArray16.t;
    var s:W64.t;
    var t:int;
    var l:int;
    m <- witness;
    v <- witness;
    wk <- witness;
    i <- 0;
    while ((i < 8)) {
      k <- (VPBROADCAST_2u128 (BArray640.get128 sHA512_K i));
      k <- (k \vadd64u256 (BArray256.get256 x i));
      wk <- (BArray1280.set256 wk i k);
      i <- (i + 1);
    }
    i <- 0;
    while ((i < 8)) {
      v <- (BArray64.set64 v i (BArray64.get64 h i));
      i <- (i + 1);
    }
    inc <- nb;
    l <- 0;
    while ((l < inc)) {
      (* Erased call to spill *)
      m <- (BArray16.set64 m 0 (BArray64.get64 v 1));
      m <-
      (BArray16.set64 m 0 ((BArray16.get64 m 0) `^` (BArray64.get64 v 2)));
      s <- (W64.of_int 0);
      t <- 0;
      while ((t < 80)) {
        v <-
        (BArray64.set64 v (((7 + 80) - t) %% 8)
        ((BArray64.get64 v (((7 + 80) - t) %% 8)) +
        (BArray1280.get64 wk (((4 * (t %/ 2)) + (2 * l)) + (t %% 2)))));
        if (((l = 0) /\ (t < 64))) {
          (v, m, s, x) <@ __sha512_avx2_round (v, m, s, t, x, (t %/ 2),
          (t %% 2));
        } else {
          (v, m, s, x) <@ __sha512_avx2_round (v, m, s, t, x, 0, 2);
        }
        if ((((l = 0) /\ (t < 64)) /\ ((t %% 2) = 1))) {
          k <-
          (VPBROADCAST_2u128 (BArray640.get128 sHA512_K (8 + (t %/ 2))));
          k <- (k \vadd64u256 (BArray256.get256 x ((t %/ 2) %% 8)));
          wk <- (BArray1280.set256 wk (8 + (t %/ 2)) k);
        } else {
          
        }
        t <- (t + 1);
      }
      v <- (BArray64.set64 v 0 ((BArray64.get64 v 0) + s));
      (* Erased call to unspill *)
      h <- (protect_ptr h ms);
      i <- 0;
      while ((i < 8)) {
        v <-
        (BArray64.set64 v i ((BArray64.get64 v i) + (BArray64.get64 h i)));
        h <- (BArray64.set64 h i (BArray64.get64 v i));
        i <- (i + 1);
      }
      l <- (l + 1);
    }
    return (h, ms);
  }
  proc _sha512_compress (h:BArray64.t, block:BArray128.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var mask_p:BArray32.t;
    var mask:W256.t;
    var i:int;
    var x:BArray256.t;
    mask_p <- witness;
    x <- witness;
    mask_p <- sHA512_AVX2_BSWAP;
    mask <- (BArray32.get256 mask_p 0);
    i <- 0;
    while ((i < 8)) {
      x <-
      (BArray256.set256 x i (VPBROADCAST_2u128 (BArray128.get128 block i)));
      x <- (BArray256.set256 x i (VPSHUFB_256 (BArray256.get256 x i) mask));
      i <- (i + 1);
    }
    (h, ms) <@ __sha512_avx2 (h, x, 1, ms);
    return (h, ms);
  }
  proc _sha512_compress_one (h:BArray64.t, p:W64.t, ms:W64.t) : BArray64.t *
                                                                W64.t = {
    var mask_p:BArray32.t;
    var mask:W256.t;
    var i:int;
    var x:BArray256.t;
    mask_p <- witness;
    x <- witness;
    mask_p <- sHA512_AVX2_BSWAP;
    mask <- (BArray32.get256 mask_p 0);
    i <- 0;
    while ((i < 8)) {
      x <-
      (BArray256.set256 x i
      (VPBROADCAST_2u128
      (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i)))))));
      x <- (BArray256.set256 x i (VPSHUFB_256 (BArray256.get256 x i) mask));
      i <- (i + 1);
    }
    (h, ms) <@ __sha512_avx2 (h, x, 1, ms);
    return (h, ms);
  }
  proc _sha512_compress_two (h:BArray64.t, p:W64.t, ms:W64.t) : BArray64.t *
                                                                W64.t = {
    var mask_p:BArray32.t;
    var mask:W256.t;
    var i:int;
    var x:BArray256.t;
    mask_p <- witness;
    x <- witness;
    mask_p <- sHA512_AVX2_BSWAP;
    mask <- (BArray32.get256 mask_p 0);
    i <- 0;
    while ((i < 8)) {
      x <-
      (BArray256.set256 x i
      (VPBROADCAST_2u128
      (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i)))))));
      x <-
      (BArray256.set256 x i
      (VINSERTI128 (BArray256.get256 x i)
      (loadW128 Glob.mem
      (W64.to_uint ((p + (W64.of_int 128)) + (W64.of_int (16 * i)))))
      (W8.of_int 1)));
      x <- (BArray256.set256 x i (VPSHUFB_256 (BArray256.get256 x i) mask));
      i <- (i + 1);
    }
    (h, ms) <@ __sha512_avx2 (h, x, 2, ms);
    return (h, ms);
  }
  proc _sha512_compress_blocks (h:BArray64.t, p:W64.t, n:W64.t, ms:W64.t) : 
  BArray64.t * W64.t = {
    var more:bool;
    more <- ((W64.of_int 2) \ule n);
    while (more) {
      ms <- (update_msf more ms);
      (* Erased call to spill *)
      (h, ms) <@ _sha512_compress_two (h, p, ms);
      (* Erased call to unspill *)
      p <- (protect_64 p ms);
      n <- (protect_64 n ms);
      p <- (p + (W64.of_int 256));
      n <- (n - (W64.of_int 2));
      more <- ((W64.of_int 2) \ule n);
    }
    ms <- (update_msf (! more) ms);
    more <- (n <> (W64.of_int 0));
    if (more) {
      ms <- (update_msf more ms);
      (h, ms) <@ _sha512_compress_one (h, p, ms);
    } else {
      ms <- (update_msf (! more) ms);
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
  proc __shani_x8_load_pair (h8:BArray256.t, f:int, r:int) : BArray64.t = {
    var st:BArray64.t;
    var q:int;
    var x:W128.t;
    var y:W128.t;
    var u:W128.t;
    var v:W128.t;
    var t:W128.t;
    var s:W128.t;
    st <- witness;
    q <- 0;
    while ((q < 2)) {
      x <- (BArray256.get128 h8 ((2 * (2 * q)) + f));
      y <- (BArray256.get128 h8 ((2 * ((2 * q) + 1)) + f));
      u <- (BArray256.get128 h8 ((2 * ((2 * q) + 4)) + f));
      v <- (BArray256.get128 h8 ((2 * ((2 * q) + 5)) + f));
      if ((r = 0)) {
        t <- (VPUNPCKL_4u32 y x);
        s <- (VPUNPCKL_4u32 v u);
      } else {
        t <- (VPUNPCKH_4u32 y x);
        s <- (VPUNPCKH_4u32 v u);
      }
      st <- (BArray64.set128 st q (VPUNPCKL_2u64 s t));
      st <- (BArray64.set128 st (2 + q) (VPUNPCKH_2u64 s t));
      q <- (q + 1);
    }
    return st;
  }
  proc __shani_x8_store_pair (h8:BArray256.t, st:BArray64.t, f:int, r:int) : 
  BArray256.t = {
    var m:int;
    var q:int;
    var t:W128.t;
    var s:W128.t;
    var x:W128.t;
    var y:W128.t;
    m <- ((r = 0) ? 15 : 240);
    q <- 0;
    while ((q < 2)) {
      t <-
      (VPUNPCKH_2u64 (BArray64.get128 st q) (BArray64.get128 st (2 + q)));
      s <-
      (VPUNPCKL_2u64 (BArray64.get128 st q) (BArray64.get128 st (2 + q)));
      x <- (VPSHUFD_128 t (W8.of_int 221));
      y <- (BArray256.get128 h8 ((2 * (2 * q)) + f));
      y <- (VPBLEND_8u16 y x (W8.of_int m));
      h8 <- (BArray256.set128 h8 ((2 * (2 * q)) + f) y);
      x <- (VPSHUFD_128 t (W8.of_int 136));
      y <- (BArray256.get128 h8 ((2 * ((2 * q) + 1)) + f));
      y <- (VPBLEND_8u16 y x (W8.of_int m));
      h8 <- (BArray256.set128 h8 ((2 * ((2 * q) + 1)) + f) y);
      x <- (VPSHUFD_128 s (W8.of_int 221));
      y <- (BArray256.get128 h8 ((2 * ((2 * q) + 4)) + f));
      y <- (VPBLEND_8u16 y x (W8.of_int m));
      h8 <- (BArray256.set128 h8 ((2 * ((2 * q) + 4)) + f) y);
      x <- (VPSHUFD_128 s (W8.of_int 136));
      y <- (BArray256.get128 h8 ((2 * ((2 * q) + 5)) + f));
      y <- (VPBLEND_8u16 y x (W8.of_int m));
      h8 <- (BArray256.set128 h8 ((2 * ((2 * q) + 5)) + f) y);
      q <- (q + 1);
    }
    return h8;
  }
  proc __shani_x8_block2 (st:BArray64.t, w:BArray128.t, k:BArray256.t) : 
  BArray64.t * BArray128.t = {
    var j:int;
    var s0:BArray64.t;
    var g:int;
    var l:int;
    var t:W128.t;
    var wk:BArray32.t;
    var x0:W128.t;
    s0 <- witness;
    wk <- witness;
    j <- 0;
    while ((j < 4)) {
      s0 <- (BArray64.set128 s0 j (BArray64.get128 st j));
      j <- (j + 1);
    }
    g <- 0;
    while ((g < 16)) {
      l <- 0;
      while ((l < 2)) {
        if ((4 <= g)) {
          w <-
          (BArray128.set128 w ((4 * l) + (g %% 4))
          (SHA256MSG1 (BArray128.get128 w ((4 * l) + (g %% 4)))
          (BArray128.get128 w ((4 * l) + ((g + 1) %% 4)))));
          t <-
          (VPALIGNR_128 (BArray128.get128 w ((4 * l) + ((g + 3) %% 4)))
          (BArray128.get128 w ((4 * l) + ((g + 2) %% 4))) (W8.of_int 4));
          w <-
          (BArray128.set128 w ((4 * l) + (g %% 4))
          (VPADD_4u32 (BArray128.get128 w ((4 * l) + (g %% 4))) t));
          w <-
          (BArray128.set128 w ((4 * l) + (g %% 4))
          (SHA256MSG2 (BArray128.get128 w ((4 * l) + (g %% 4)))
          (BArray128.get128 w ((4 * l) + ((g + 3) %% 4)))));
        } else {
          
        }
        wk <-
        (BArray32.set128 wk l
        (VPADD_4u32 (BArray128.get128 w ((4 * l) + (g %% 4)))
        (BArray256.get128 k g)));
        x0 <- (BArray32.get128 wk l);
        st <-
        (BArray64.set128 st ((2 * l) + 1)
        (SHA256RNDS2 (BArray64.get128 st ((2 * l) + 1))
        (BArray64.get128 st (2 * l)) x0));
        l <- (l + 1);
      }
      l <- 0;
      while ((l < 2)) {
        x0 <- (VPSHUFD_128 (BArray32.get128 wk l) (W8.of_int 14));
        st <-
        (BArray64.set128 st (2 * l)
        (SHA256RNDS2 (BArray64.get128 st (2 * l))
        (BArray64.get128 st ((2 * l) + 1)) x0));
        l <- (l + 1);
      }
      g <- (g + 1);
    }
    j <- 0;
    while ((j < 4)) {
      st <-
      (BArray64.set128 st j
      (VPADD_4u32 (BArray64.get128 st j) (BArray64.get128 s0 j)));
      j <- (j + 1);
    }
    return (st, w);
  }
  proc _sha256_x8_compress (h8:BArray256.t, blocks:BArray512.t, ms:W64.t) : 
  BArray256.t * W64.t = {
    var k:BArray256.t;
    var mask_p:BArray16.t;
    var f:int;
    var r:int;
    var st:BArray64.t;
    var mask:W128.t;
    var i:int;
    var w:BArray128.t;
    k <- witness;
    mask_p <- witness;
    st <- witness;
    w <- witness;
    k <- sHA256_K;
    mask_p <- sHA256_X8_SHANI_BSWAP;
    f <- 0;
    while ((f < 2)) {
      r <- 0;
      while ((r < 2)) {
        st <@ __shani_x8_load_pair (h8, f, r);
        mask <- (BArray16.get128 mask_p 0);
        i <- 0;
        while ((i < 4)) {
          w <-
          (BArray128.set128 w i
          (BArray512.get128 blocks ((4 * ((4 * f) + (2 * r))) + i)));
          w <-
          (BArray128.set128 w i (VPSHUFB_128 (BArray128.get128 w i) mask));
          w <-
          (BArray128.set128 w (4 + i)
          (BArray512.get128 blocks ((4 * (((4 * f) + (2 * r)) + 1)) + i)));
          w <-
          (BArray128.set128 w (4 + i)
          (VPSHUFB_128 (BArray128.get128 w (4 + i)) mask));
          i <- (i + 1);
        }
        (st, w) <@ __shani_x8_block2 (st, w, k);
        h8 <@ __shani_x8_store_pair (h8, st, f, r);
        r <- (r + 1);
      }
      f <- (f + 1);
    }
    return (h8, ms);
  }
  proc _sha256_x8_compress_lanes (h8:BArray256.t, in_0:BArray64.t, off:W64.t,
                                  n:W64.t, ms:W64.t) : BArray256.t * W64.t = {
    var k:BArray256.t;
    var mask_p:BArray16.t;
    var f:int;
    var r:int;
    var st:BArray64.t;
    var p:W64.t;
    var q:W64.t;
    var c:W64.t;
    var more:bool;
    var mask:W128.t;
    var i:int;
    var w:BArray128.t;
    k <- witness;
    mask_p <- witness;
    st <- witness;
    w <- witness;
    k <- sHA256_K;
    mask_p <- sHA256_X8_SHANI_BSWAP;
    f <- 0;
    while ((f < 2)) {
      r <- 0;
      while ((r < 2)) {
        st <@ __shani_x8_load_pair (h8, f, r);
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
          mask <- (BArray16.get128 mask_p 0);
          i <- 0;
          while ((i < 4)) {
            w <-
            (BArray128.set128 w i
            (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i))))));
            w <-
            (BArray128.set128 w i (VPSHUFB_128 (BArray128.get128 w i) mask));
            w <-
            (BArray128.set128 w (4 + i)
            (loadW128 Glob.mem (W64.to_uint (q + (W64.of_int (16 * i))))));
            w <-
            (BArray128.set128 w (4 + i)
            (VPSHUFB_128 (BArray128.get128 w (4 + i)) mask));
            i <- (i + 1);
          }
          (st, w) <@ __shani_x8_block2 (st, w, k);
          p <- (p + (W64.of_int 64));
          q <- (q + (W64.of_int 64));
          c <- (c - (W64.of_int 1));
          more <- (c <> (W64.of_int 0));
        }
        ms <- (update_msf (! more) ms);
        h8 <@ __shani_x8_store_pair (h8, st, f, r);
        r <- (r + 1);
      }
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
