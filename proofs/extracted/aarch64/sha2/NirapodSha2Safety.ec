require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_armv8a.

import SLH64.

from Jasmin require import Jcheck JSafety.

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
  var tmp__trace : trace
  proc __bswap32 (x:W32.t) : W32.t * trace = {
    var x_init:bool;
    var trace___bswap32:trace;
    trace___bswap32 <- [];
    x_init <- true;
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, true)]);
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, true)]);
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, x_init)]);
    x <- (REV_32 x);
    x_init <- true;
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, x_init)]);
    return (x, trace___bswap32);
  }
  proc __bswap64 (x:W64.t) : W64.t * trace = {
    var x_init:bool;
    var trace___bswap64:trace;
    trace___bswap64 <- [];
    x_init <- true;
    trace___bswap64 <- (trace___bswap64 ++ [(Assert, true)]);
    trace___bswap64 <- (trace___bswap64 ++ [(Assert, true)]);
    trace___bswap64 <- (trace___bswap64 ++ [(Assert, x_init)]);
    x <- (REV_64 x);
    x_init <- true;
    trace___bswap64 <- (trace___bswap64 ++ [(Assert, x_init)]);
    return (x, trace___bswap64);
  }
  proc __fill64_mem (buf:BArray64.t, dst_:W64.t, p_:W64.t, n_:W64.t,
                     ms:W64.t, buf_init:BArray64.t) : BArray64.t * W64.t *
                                                      BArray64.t * trace = {
    var dst:W64.t;
    var p:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var p__init:bool;
    var p_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace___fill64_mem:trace;
    trace___fill64_mem <- [];
    dst__init <- true;
    p__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    p_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p__init)]);
    p <- p_;
    p_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 1))]);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      t_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 1));
      p_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    }
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 8))]);
      t <- (loadW64 Glob.mem (W64.to_uint p));
      t_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 64)))]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 8));
      p_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    }
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 1))]);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      t_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
      trace___fill64_mem <-
      (trace___fill64_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 1));
      p_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, dst_init)]);
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    }
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, true)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, more_init)]);
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill64_mem <- (trace___fill64_mem ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace___fill64_mem);
  }
  proc __fill128_mem (buf:BArray128.t, dst_:W64.t, p_:W64.t, n_:W64.t,
                      ms:W64.t, buf_init:BArray128.t) : BArray128.t * W64.t *
                                                        BArray128.t * trace = {
    var dst:W64.t;
    var p:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var p__init:bool;
    var p_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace___fill128_mem:trace;
    trace___fill128_mem <- [];
    dst__init <- true;
    p__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    p_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p__init)]);
    p <- p_;
    p_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 1))]);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      t_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 1));
      p_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    }
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 8))]);
      t <- (loadW64 Glob.mem (W64.to_uint p));
      t_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 128)))]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 8));
      p_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    }
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    while (more) {
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert, (is_valid ptr_modulus Glob.mem_v (W64.to_uint p) 1))]);
      t <- (zeroextu64 (loadW8 Glob.mem (W64.to_uint p)));
      t_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
      trace___fill128_mem <-
      (trace___fill128_mem ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 1));
      p_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, dst_init)]);
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    }
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, true)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, more_init)]);
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___fill128_mem <- (trace___fill128_mem ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace___fill128_mem);
  }
  proc __zero64 (buf:BArray64.t, lo_:W64.t, hi:W64.t, ms:W64.t,
                 buf_init:BArray64.t) : BArray64.t * W64.t * BArray64.t *
                                        trace = {
    var lo:W64.t;
    var z:W64.t;
    var end_0:W64.t;
    var more:bool;
    var lo__init:bool;
    var lo_init:bool;
    var z_init:bool;
    var end_init:bool;
    var hi_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var trace___zero64:trace;
    trace___zero64 <- [];
    lo__init <- true;
    hi_init <- true;
    ms_init <- true;
    lo_init <- false;
    z_init <- false;
    end_init <- false;
    more_init <- false;
    trace___zero64 <- (trace___zero64 ++ [(Assert, lo__init)]);
    lo <- lo_;
    lo_init <- true;
    z <- (W64.of_int 0);
    z_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
    end_0 <- lo;
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    end_0 <- (end_0 + (W64.of_int 7));
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    end_0 <- (end_0 `&` (W64.of_int (- 8)));
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    end_0 <- ((hi \ult end_0) ? hi : end_0);
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    more <- (lo \ult end_0);
    more_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <-
      (trace___zero64 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 1) <= 64)))]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, z_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint lo) (truncateu8 z));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint lo) (W8.of_int 255));
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 1));
      lo_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
      more <- (lo \ult end_0);
      more_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    }
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
    end_0 <- lo;
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    end_0 <- (end_0 + (W64.of_int 8));
    end_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
    more <- (end_0 \ule hi);
    more_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <-
      (trace___zero64 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 8) <= 64)))]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, z_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint lo) z);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint lo)
      (W64.of_int 18446744073709551615));
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 8));
      lo_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      end_0 <- lo;
      end_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
      end_0 <- (end_0 + (W64.of_int 8));
      end_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, end_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
      more <- (end_0 \ule hi);
      more_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    }
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
    more <- (lo \ult hi);
    more_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
      trace___zero64 <-
      (trace___zero64 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 1) <= 64)))]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, z_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint lo) (truncateu8 z));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint lo) (W8.of_int 255));
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 1));
      lo_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, lo_init)]);
      trace___zero64 <- (trace___zero64 ++ [(Assert, hi_init)]);
      more <- (lo \ult hi);
      more_init <- true;
      trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    }
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, true)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, more_init)]);
    trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero64 <- (trace___zero64 ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace___zero64);
  }
  proc __zero128 (buf:BArray128.t, lo_:W64.t, hi:W64.t, ms:W64.t,
                  buf_init:BArray128.t) : BArray128.t * W64.t * BArray128.t *
                                          trace = {
    var lo:W64.t;
    var z:W64.t;
    var end_0:W64.t;
    var more:bool;
    var lo__init:bool;
    var lo_init:bool;
    var z_init:bool;
    var end_init:bool;
    var hi_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var trace___zero128:trace;
    trace___zero128 <- [];
    lo__init <- true;
    hi_init <- true;
    ms_init <- true;
    lo_init <- false;
    z_init <- false;
    end_init <- false;
    more_init <- false;
    trace___zero128 <- (trace___zero128 ++ [(Assert, lo__init)]);
    lo <- lo_;
    lo_init <- true;
    z <- (W64.of_int 0);
    z_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
    end_0 <- lo;
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    end_0 <- (end_0 + (W64.of_int 7));
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    end_0 <- (end_0 `&` (W64.of_int (- 8)));
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    end_0 <- ((hi \ult end_0) ? hi : end_0);
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    more <- (lo \ult end_0);
    more_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <-
      (trace___zero128 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 1) <= 128)))]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, z_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint lo) (truncateu8 z));
      buf_init <- (BArray128.set8 buf_init (W64.to_uint lo) (W8.of_int 255));
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 1));
      lo_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
      more <- (lo \ult end_0);
      more_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    }
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
    end_0 <- lo;
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    end_0 <- (end_0 + (W64.of_int 8));
    end_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
    more <- (end_0 \ule hi);
    more_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <-
      (trace___zero128 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 8) <= 128)))]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, z_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint lo) z);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint lo)
      (W64.of_int 18446744073709551615));
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 8));
      lo_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      end_0 <- lo;
      end_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
      end_0 <- (end_0 + (W64.of_int 8));
      end_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, end_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
      more <- (end_0 \ule hi);
      more_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    }
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
    more <- (lo \ult hi);
    more_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    while (more) {
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
      trace___zero128 <-
      (trace___zero128 ++
      [(Assert,
       ((0 <= ((W64.to_uint lo) * 1)) /\
       ((((W64.to_uint lo) * 1) + 1) <= 128)))]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, z_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint lo) (truncateu8 z));
      buf_init <- (BArray128.set8 buf_init (W64.to_uint lo) (W8.of_int 255));
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      lo <- (lo + (W64.of_int 1));
      lo_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, lo_init)]);
      trace___zero128 <- (trace___zero128 ++ [(Assert, hi_init)]);
      more <- (lo \ult hi);
      more_init <- true;
      trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    }
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, true)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, more_init)]);
    trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace___zero128 <- (trace___zero128 ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace___zero128);
  }
  proc __sha256_block_a64 (abcd:W128.t, efgh:W128.t, m:BArray64.t,
                           k:BArray256.t, m_init:BArray64.t,
                           k_init:BArray256.t) : W128.t * W128.t *
                                                 BArray64.t * BArray64.t *
                                                 trace = {
    var abcd0:W128.t;
    var efgh0:W128.t;
    var g:int;
    var wk:W128.t;
    var prev:W128.t;
    var abcd_init:bool;
    var abcd0_init:bool;
    var efgh_init:bool;
    var efgh0_init:bool;
    var g_init:bool;
    var wk_init:bool;
    var prev_init:bool;
    var trace___sha256_block_a64:trace;
    trace___sha256_block_a64 <- [];
    abcd_init <- true;
    efgh_init <- true;
    abcd0_init <- false;
    efgh0_init <- false;
    g_init <- false;
    wk_init <- false;
    prev_init <- false;
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
    abcd0 <- abcd;
    abcd0_init <- true;
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
    efgh0 <- efgh;
    efgh0_init <- true;
    g_init <- true;
    g <- 0;
    while ((g < 12)) {
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 256)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray256.is_init k_init (g * 16) 16))]);
      wk <- (BArray256.get128 k g);
      wk_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init ((g %% 4) * 16) 16))]);
      wk <- (VADD_4u32 wk (BArray64.get128 m (g %% 4)));
      wk_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init ((g %% 4) * 16) 16))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert,
       ((0 <= (((g + 1) %% 4) * 16)) /\ (((((g + 1) %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init (((g + 1) %% 4) * 16) 16))]);
      m <-
      (BArray64.set128 m (g %% 4)
      (SHA256SU0 (BArray64.get128 m (g %% 4))
      (BArray64.get128 m ((g + 1) %% 4))));
      m_init <-
      (BArray64.set128 m_init (g %% 4)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init ((g %% 4) * 16) 16))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert,
       ((0 <= (((g + 2) %% 4) * 16)) /\ (((((g + 2) %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init (((g + 2) %% 4) * 16) 16))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert,
       ((0 <= (((g + 3) %% 4) * 16)) /\ (((((g + 3) %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init (((g + 3) %% 4) * 16) 16))]);
      m <-
      (BArray64.set128 m (g %% 4)
      (SHA256SU1 (BArray64.get128 m (g %% 4))
      (BArray64.get128 m ((g + 2) %% 4)) (BArray64.get128 m ((g + 3) %% 4))));
      m_init <-
      (BArray64.set128 m_init (g %% 4)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
      prev <- abcd;
      prev_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      abcd <- (SHA256H abcd efgh wk);
      abcd_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, prev_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      efgh <- (SHA256H2 efgh prev wk);
      efgh_init <- true;
      g <- (g + 1);
    }
    g_init <- true;
    g <- 12;
    while ((g < 16)) {
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 256)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray256.is_init k_init (g * 16) 16))]);
      wk <- (BArray256.get128 k g);
      wk_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, g_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, ((0 <= ((g %% 4) * 16)) /\ ((((g %% 4) * 16) + 16) <= 64)))]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++
      [(Assert, (BArray64.is_init m_init ((g %% 4) * 16) 16))]);
      wk <- (VADD_4u32 wk (BArray64.get128 m (g %% 4)));
      wk_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
      prev <- abcd;
      prev_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      abcd <- (SHA256H abcd efgh wk);
      abcd_init <- true;
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, true)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, prev_init)]);
      trace___sha256_block_a64 <-
      (trace___sha256_block_a64 ++ [(Assert, wk_init)]);
      efgh <- (SHA256H2 efgh prev wk);
      efgh_init <- true;
      g <- (g + 1);
    }
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, true)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, true)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, abcd0_init)]);
    abcd <- (VADD_4u32 abcd abcd0);
    abcd_init <- true;
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, true)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, true)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, efgh0_init)]);
    efgh <- (VADD_4u32 efgh efgh0);
    efgh_init <- true;
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, abcd_init)]);
    trace___sha256_block_a64 <-
    (trace___sha256_block_a64 ++ [(Assert, efgh_init)]);
    return (abcd, efgh, m, m_init, trace___sha256_block_a64);
  }
  proc _sha256_compress (h:BArray32.t, block:BArray64.t, ms:W64.t,
                         h_init:BArray32.t, block_init:BArray64.t) : 
  BArray32.t * W64.t * BArray32.t * trace = {
    var abcd:W128.t;
    var efgh:W128.t;
    var j:int;
    var m:BArray64.t;
    var k:BArray256.t;
    var abcd_init:bool;
    var efgh_init:bool;
    var j_init:bool;
    var m_init:BArray64.t;
    var k_init:BArray256.t;
    var ms_init:bool;
    var trace__sha256_compress:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    trace__sha256_compress <- [];
    ms_init <- true;
    abcd_init <- false;
    efgh_init <- false;
    j_init <- false;
    m_init <- (BArray64.init_arr (W8.of_int 0));
    k_init <- (BArray256.init_arr (W8.of_int 0));
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, ((0 <= (0 * 16)) /\ (((0 * 16) + 16) <= 32)))]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, (BArray32.is_init h_init (0 * 16) 16))]);
    abcd <- (BArray32.get128 h 0);
    abcd_init <- true;
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, ((0 <= (1 * 16)) /\ (((1 * 16) + 16) <= 32)))]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, (BArray32.is_init h_init (1 * 16) 16))]);
    efgh <- (BArray32.get128 h 1);
    efgh_init <- true;
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, j_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, j_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, (BArray64.is_init block_init (j * 16) 16))]);
      m <- (BArray64.set128 m j (BArray64.get128 block j));
      m_init <-
      (BArray64.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, j_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, j_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, (BArray64.is_init m_init (j * 16) 16))]);
      m <- (BArray64.set128 m j (VREV32_16u8 (BArray64.get128 m j)));
      m_init <-
      (BArray64.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    k <- sHA256_K;
    k_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, abcd_init)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, efgh_init)]);
    (abcd, efgh, m, m_init, tmp__trace) <@ __sha256_block_a64 (abcd, 
    efgh, m, k, m_init, k_init);
    trace__sha256_compress <- (trace__sha256_compress ++ tmp__trace);
    abcd_init <- true;
    efgh_init <- true;
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, ((0 <= (0 * 16)) /\ (((0 * 16) + 16) <= 32)))]);
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, abcd_init)]);
    h <- (BArray32.set128 h 0 abcd);
    h_init <-
    (BArray32.set128 h_init 0
    (W128.of_int 340282366920938463463374607431768211455));
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    trace__sha256_compress <-
    (trace__sha256_compress ++
    [(Assert, ((0 <= (1 * 16)) /\ (((1 * 16) + 16) <= 32)))]);
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, efgh_init)]);
    h <- (BArray32.set128 h 1 efgh);
    h_init <-
    (BArray32.set128 h_init 1
    (W128.of_int 340282366920938463463374607431768211455));
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha256_compress);
  }
  proc _sha256_compress_blocks (h:BArray32.t, p:W64.t, n:W64.t, ms:W64.t,
                                h_init:BArray32.t) : BArray32.t * W64.t *
                                                     BArray32.t * trace = {
    var abcd:W128.t;
    var efgh:W128.t;
    var k:BArray256.t;
    var more:bool;
    var j:int;
    var m:BArray64.t;
    var abcd_init:bool;
    var efgh_init:bool;
    var k_init:BArray256.t;
    var more_init:bool;
    var ms_init:bool;
    var j_init:bool;
    var p_init:bool;
    var m_init:BArray64.t;
    var n_init:bool;
    var trace__sha256_compress_blocks:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    trace__sha256_compress_blocks <- [];
    p_init <- true;
    n_init <- true;
    ms_init <- true;
    abcd_init <- false;
    efgh_init <- false;
    k_init <- (BArray256.init_arr (W8.of_int 0));
    more_init <- false;
    j_init <- false;
    m_init <- (BArray64.init_arr (W8.of_int 0));
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, ((0 <= (0 * 16)) /\ (((0 * 16) + 16) <= 32)))]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, (BArray32.is_init h_init (0 * 16) 16))]);
    abcd <- (BArray32.get128 h 0);
    abcd_init <- true;
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, ((0 <= (1 * 16)) /\ (((1 * 16) + 16) <= 32)))]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, (BArray32.is_init h_init (1 * 16) 16))]);
    efgh <- (BArray32.get128 h 1);
    efgh_init <- true;
    k <- sHA256_K;
    k_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, more_init)]);
    while (more) {
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, more_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      j_init <- true;
      j <- 0;
      while ((j < 4)) {
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, j_init)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, j_init)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++
        [(Assert,
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (p + (W64.of_int (16 * j)))) 16))]);
        m <-
        (BArray64.set128 m j
        (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
        m_init <-
        (BArray64.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, j_init)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, j_init)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++ [(Assert, true)]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
        trace__sha256_compress_blocks <-
        (trace__sha256_compress_blocks ++
        [(Assert, (BArray64.is_init m_init (j * 16) 16))]);
        m <- (BArray64.set128 m j (VREV32_16u8 (BArray64.get128 m j)));
        m_init <-
        (BArray64.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        j <- (j + 1);
      }
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, abcd_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, efgh_init)]);
      (abcd, efgh, m, m_init, tmp__trace) <@ __sha256_block_a64 (abcd, 
      efgh, m, k, m_init, k_init);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ tmp__trace);
      abcd_init <- true;
      efgh_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 64));
      p_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 1));
      n_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
      more <- (n <> (W64.of_int 0));
      more_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, more_init)]);
    }
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, more_init)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, ((0 <= (0 * 16)) /\ (((0 * 16) + 16) <= 32)))]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, abcd_init)]);
    h <- (BArray32.set128 h 0 abcd);
    h_init <-
    (BArray32.set128 h_init 0
    (W128.of_int 340282366920938463463374607431768211455));
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, true)]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++
    [(Assert, ((0 <= (1 * 16)) /\ (((1 * 16) + 16) <= 32)))]);
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, efgh_init)]);
    h <- (BArray32.set128 h 1 efgh);
    h_init <-
    (BArray32.set128 h_init 1
    (W128.of_int 340282366920938463463374607431768211455));
    trace__sha256_compress_blocks <-
    (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha256_compress_blocks);
  }
  proc __sha256_init (h:BArray32.t, h_init:BArray32.t) : BArray32.t *
                                                         BArray32.t * trace = {
    var iv:BArray32.t;
    var i:int;
    var t:W32.t;
    var iv_init:BArray32.t;
    var i_init:bool;
    var t_init:bool;
    var trace___sha256_init:trace;
    iv <- witness;
    iv_init <- witness;
    trace___sha256_init <- [];
    iv_init <- (BArray32.init_arr (W8.of_int 0));
    i_init <- false;
    t_init <- false;
    iv <- sHA256_IV;
    iv_init <- (BArray32.init_arr (W8.of_int 255));
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_init <- (trace___sha256_init ++ [(Assert, i_init)]);
      trace___sha256_init <- (trace___sha256_init ++ [(Assert, true)]);
      trace___sha256_init <-
      (trace___sha256_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_init <-
      (trace___sha256_init ++
      [(Assert, (BArray32.is_init iv_init (i * 4) 4))]);
      t <- (BArray32.get32 iv i);
      t_init <- true;
      trace___sha256_init <- (trace___sha256_init ++ [(Assert, i_init)]);
      trace___sha256_init <- (trace___sha256_init ++ [(Assert, true)]);
      trace___sha256_init <-
      (trace___sha256_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_init <- (trace___sha256_init ++ [(Assert, t_init)]);
      h <- (BArray32.set32 h i t);
      h_init <- (BArray32.set32 h_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    return (h, h_init, trace___sha256_init);
  }
  proc __sha224_init (h:BArray32.t, h_init:BArray32.t) : BArray32.t *
                                                         BArray32.t * trace = {
    var iv:BArray32.t;
    var i:int;
    var t:W32.t;
    var iv_init:BArray32.t;
    var i_init:bool;
    var t_init:bool;
    var trace___sha224_init:trace;
    iv <- witness;
    iv_init <- witness;
    trace___sha224_init <- [];
    iv_init <- (BArray32.init_arr (W8.of_int 0));
    i_init <- false;
    t_init <- false;
    iv <- sHA224_IV;
    iv_init <- (BArray32.init_arr (W8.of_int 255));
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha224_init <- (trace___sha224_init ++ [(Assert, i_init)]);
      trace___sha224_init <- (trace___sha224_init ++ [(Assert, true)]);
      trace___sha224_init <-
      (trace___sha224_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha224_init <-
      (trace___sha224_init ++
      [(Assert, (BArray32.is_init iv_init (i * 4) 4))]);
      t <- (BArray32.get32 iv i);
      t_init <- true;
      trace___sha224_init <- (trace___sha224_init ++ [(Assert, i_init)]);
      trace___sha224_init <- (trace___sha224_init ++ [(Assert, true)]);
      trace___sha224_init <-
      (trace___sha224_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha224_init <- (trace___sha224_init ++ [(Assert, t_init)]);
      h <- (BArray32.set32 h i t);
      h_init <- (BArray32.set32 h_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    return (h, h_init, trace___sha224_init);
  }
  proc _sha256_absorb_mem (h:BArray32.t, buf:BArray64.t, total:W64.t,
                           in_0:W64.t, inlen:W64.t, ms:W64.t,
                           h_init:BArray32.t, buf_init:BArray64.t) : 
  BArray32.t * BArray64.t * W64.t * W64.t * BArray32.t * BArray64.t * trace = {
    var fill:W64.t;
    var n:W64.t;
    var full:bool;
    var off:W64.t;
    var more:bool;
    var total_init:bool;
    var fill_init:bool;
    var inlen_init:bool;
    var n_init:bool;
    var in_init:bool;
    var ms_init:bool;
    var full_init:bool;
    var off_init:bool;
    var more_init:bool;
    var trace__sha256_absorb_mem:trace;
    trace__sha256_absorb_mem <- [];
    total_init <- true;
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    fill_init <- false;
    n_init <- false;
    full_init <- false;
    off_init <- false;
    more_init <- false;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    total <- (total + inlen);
    total_init <- true;
    n <- (W64.of_int 64);
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    n <- (n - fill);
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    n <- ((inlen \ult n) ? inlen : n);
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    inlen <- (inlen - n);
    inlen_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, true)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __fill64_mem (buf, fill, in_0, 
    n, ms, buf_init);
    trace__sha256_absorb_mem <- (trace__sha256_absorb_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    fill <- (fill + n);
    fill_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    in_0 <- (in_0 + n);
    in_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    full <- (fill = (W64.of_int 64));
    full_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, full_init)]);
    if (full) {
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, full_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf full ms);
      ms_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to spill *)
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha256_absorb_mem <- (trace__sha256_absorb_mem ++ tmp__trace);
      ms_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to unspill *)
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      in_0 <- (protect_64 in_0 ms);
      in_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray64.init_arr (W8.of_int 255));
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, full_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! full) ms);
      ms_init <- true;
    }
    off <- (W64.of_int 0);
    off_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    n <- (n `>>` (W8.of_int 6));
    n_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, more_init)]);
    if (more) {
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, more_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to spill *)
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, n_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress_blocks (h, in_0, 
      n, ms, h_init);
      trace__sha256_absorb_mem <- (trace__sha256_absorb_mem ++ tmp__trace);
      ms_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to unspill *)
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      in_0 <- (protect_64 in_0 ms);
      in_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
      off <- inlen;
      off_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, off_init)]);
      off <- (off `>>` (W8.of_int 6));
      off_init <- true;
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, off_init)]);
      off <- (off `<<` (W8.of_int 6));
      off_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, true)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, more_init)]);
      trace__sha256_absorb_mem <-
      (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! more) ms);
      ms_init <- true;
    }
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, off_init)]);
    inlen <- (inlen - off);
    inlen_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, off_init)]);
    in_0 <- (in_0 + off);
    in_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, true)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, in_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __fill64_mem (buf, fill, in_0, 
    inlen, ms, buf_init);
    trace__sha256_absorb_mem <- (trace__sha256_absorb_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, total_init)]);
    trace__sha256_absorb_mem <-
    (trace__sha256_absorb_mem ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init, trace__sha256_absorb_mem);
  }
  proc _sha256___sha256_finalize (out:BArray32.t, h:BArray32.t,
                                  buf:BArray64.t, total:W64.t, ms:W64.t,
                                  out_init:BArray32.t, h_init:BArray32.t,
                                  buf_init:BArray64.t) : BArray32.t *
                                                         BArray32.t *
                                                         BArray64.t * W64.t *
                                                         BArray32.t *
                                                         BArray32.t *
                                                         BArray64.t * trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var trace__sha256___sha256_finalize:trace;
    trace__sha256___sha256_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 64)))]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, t_init)]);
    buf <- (BArray64.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray64.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 56) \ult fill);
    two_blocks_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 64);
      hi_init <- true;
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, hi_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero64 (buf, fill, hi, ms,
      buf_init);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray32.init_arr (W8.of_int 255));
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, total_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 56);
    hi_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, fill_init)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, hi_init)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero64 (buf, fill, hi, ms,
    buf_init);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++
    [(Assert, ((0 <= (56 * 1)) /\ (((56 * 1) + 8) <= 64)))]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, t_init)]);
    buf <- (BArray64.set64d buf 56 t);
    buf_init <-
    (BArray64.set64d buf_init 56 (W64.of_int 18446744073709551615));
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, true)]);
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray64.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (32 %/ 4);
    i <- 0;
    while ((i < inc)) {
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, i_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++
      [(Assert, (BArray32.is_init h_init (i * 4) 4))]);
      x <- (BArray32.get32 h i);
      x_init <- true;
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap32 (x);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, i_init)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, true)]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace__sha256___sha256_finalize <-
      (trace__sha256___sha256_finalize ++ [(Assert, x_init)]);
      out <- (BArray32.set32 out i x);
      out_init <- (BArray32.set32 out_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha256___sha256_finalize <-
    (trace__sha256___sha256_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha256___sha256_finalize);
  }
  proc _sha256____sha256_mem_from (out:BArray32.t, h:BArray32.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t,
                                   out_init:BArray32.t, h_init:BArray32.t) : 
  BArray32.t * W64.t * BArray32.t * trace = {
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha256____sha256_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha256____sha256_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, total_init)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, in_init)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, inlen_init)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha256_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, true)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, total_init)]);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha256____sha256_mem_from <-
    (trace__sha256____sha256_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha256____sha256_mem_from);
  }
  proc _sha224___sha256_finalize (out:BArray28.t, h:BArray32.t,
                                  buf:BArray64.t, total:W64.t, ms:W64.t,
                                  out_init:BArray28.t, h_init:BArray32.t,
                                  buf_init:BArray64.t) : BArray28.t *
                                                         BArray32.t *
                                                         BArray64.t * W64.t *
                                                         BArray28.t *
                                                         BArray32.t *
                                                         BArray64.t * trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var trace__sha224___sha256_finalize:trace;
    trace__sha224___sha256_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 64)))]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, t_init)]);
    buf <- (BArray64.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray64.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 56) \ult fill);
    two_blocks_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 64);
      hi_init <- true;
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, hi_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero64 (buf, fill, hi, ms,
      buf_init);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray28.init_arr (W8.of_int 255));
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, total_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 56);
    hi_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, fill_init)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, hi_init)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero64 (buf, fill, hi, ms,
    buf_init);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++
    [(Assert, ((0 <= (56 * 1)) /\ (((56 * 1) + 8) <= 64)))]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, t_init)]);
    buf <- (BArray64.set64d buf 56 t);
    buf_init <-
    (BArray64.set64d buf_init 56 (W64.of_int 18446744073709551615));
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray28.init_arr (W8.of_int 255));
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, true)]);
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray64.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (28 %/ 4);
    i <- 0;
    while ((i < inc)) {
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, i_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++
      [(Assert, (BArray32.is_init h_init (i * 4) 4))]);
      x <- (BArray32.get32 h i);
      x_init <- true;
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap32 (x);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, i_init)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, true)]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 28)))]);
      trace__sha224___sha256_finalize <-
      (trace__sha224___sha256_finalize ++ [(Assert, x_init)]);
      out <- (BArray28.set32 out i x);
      out_init <- (BArray28.set32 out_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha224___sha256_finalize <-
    (trace__sha224___sha256_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha224___sha256_finalize);
  }
  proc _sha224____sha256_mem_from (out:BArray28.t, h:BArray32.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t,
                                   out_init:BArray28.t, h_init:BArray32.t) : 
  BArray28.t * W64.t * BArray28.t * trace = {
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha224____sha256_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha224____sha256_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, total_init)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, in_init)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, inlen_init)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha256_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, true)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, total_init)]);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha224___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha224____sha256_mem_from <-
    (trace__sha224____sha256_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha224____sha256_mem_from);
  }
  proc _sha256_mem (out:BArray32.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                    out_init:BArray32.t) : BArray32.t * W64.t * BArray32.t *
                                           trace = {
    var h:BArray32.t;
    var h_init:BArray32.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha256_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha256_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace__sha256_mem <- (trace__sha256_mem ++ tmp__trace);
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, true)]);
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, in_init)]);
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, inlen_init)]);
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha256____sha256_mem_from (out, 
    h, in_0, inlen, ms, out_init, h_init);
    trace__sha256_mem <- (trace__sha256_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha256_mem <- (trace__sha256_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha256_mem);
  }
  proc _sha224_mem (out:BArray28.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                    out_init:BArray28.t) : BArray28.t * W64.t * BArray28.t *
                                           trace = {
    var h:BArray32.t;
    var h_init:BArray32.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha224_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha224_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha224_init (h, h_init);
    trace__sha224_mem <- (trace__sha224_mem ++ tmp__trace);
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, true)]);
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, in_init)]);
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, inlen_init)]);
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha224____sha256_mem_from (out, 
    h, in_0, inlen, ms, out_init, h_init);
    trace__sha224_mem <- (trace__sha224_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha224_mem <- (trace__sha224_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha224_mem);
  }
  proc __sha512_block_a64 (s:BArray80.t, m:BArray128.t, k:BArray640.t,
                           s_init:BArray80.t, m_init:BArray128.t,
                           k_init:BArray640.t) : BArray80.t * BArray128.t *
                                                 BArray80.t * BArray128.t *
                                                 trace = {
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
    var j_init:bool;
    var s0_init:BArray64.t;
    var i0_init:bool;
    var i1_init:bool;
    var i2_init:bool;
    var i3_init:bool;
    var i4_init:bool;
    var g_init:bool;
    var wk_init:bool;
    var x_init:bool;
    var y_init:bool;
    var z_init:bool;
    var t_init:bool;
    var trace___sha512_block_a64:trace;
    s0 <- witness;
    s0_init <- witness;
    trace___sha512_block_a64 <- [];
    j_init <- false;
    s0_init <- (BArray64.init_arr (W8.of_int 0));
    i0_init <- false;
    i1_init <- false;
    i2_init <- false;
    i3_init <- false;
    i4_init <- false;
    g_init <- false;
    wk_init <- false;
    x_init <- false;
    y_init <- false;
    z_init <- false;
    t_init <- false;
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (j * 16) 16))]);
      s0 <- (BArray64.set128 s0 j (BArray80.get128 s j));
      s0_init <-
      (BArray64.set128 s0_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    i0 <- 0;
    i0_init <- true;
    i1 <- 1;
    i1_init <- true;
    i2 <- 2;
    i2_init <- true;
    i3 <- 3;
    i3_init <- true;
    i4 <- 4;
    i4_init <- true;
    g_init <- true;
    g <- 0;
    while ((g < 32)) {
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, g_init)]);
      j <- (g %% 8);
      j_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, g_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 640)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray640.is_init k_init (g * 16) 16))]);
      wk <- (BArray640.get128 k g);
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
      wk <- (VADD_2u64 wk (BArray128.get128 m j));
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      wk <- (VEXT wk wk (W8.of_int 8));
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i2 * 16)) /\ (((i2 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i2 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      x <-
      (VEXT (BArray80.get128 s i2) (BArray80.get128 s i3) (W8.of_int 8));
      x_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i2 * 16)) /\ (((i2 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i2 * 16) 16))]);
      y <-
      (VEXT (BArray80.get128 s i1) (BArray80.get128 s i2) (W8.of_int 8));
      y_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      s <- (BArray80.set128 s i3 (VADD_2u64 (BArray80.get128 s i3) wk));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert,
       ((0 <= (((j + 4) %% 8) * 16)) /\
       (((((j + 4) %% 8) * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (((j + 4) %% 8) * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert,
       ((0 <= (((j + 5) %% 8) * 16)) /\
       (((((j + 5) %% 8) * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (((j + 5) %% 8) * 16) 16))]);
      z <-
      (VEXT (BArray128.get128 m ((j + 4) %% 8))
      (BArray128.get128 m ((j + 5) %% 8)) (W8.of_int 8));
      z_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert,
       ((0 <= (((j + 1) %% 8) * 16)) /\
       (((((j + 1) %% 8) * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (((j + 1) %% 8) * 16) 16))]);
      m <-
      (BArray128.set128 m j
      (SHA512SU0 (BArray128.get128 m j) (BArray128.get128 m ((j + 1) %% 8))));
      m_init <-
      (BArray128.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert,
       ((0 <= (((j + 7) %% 8) * 16)) /\
       (((((j + 7) %% 8) * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (((j + 7) %% 8) * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, z_init)]);
      m <-
      (BArray128.set128 m j
      (SHA512SU1 (BArray128.get128 m j) (BArray128.get128 m ((j + 7) %% 8)) 
      z));
      m_init <-
      (BArray128.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, x_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, y_init)]);
      s <- (BArray80.set128 s i3 (SHA512H (BArray80.get128 s i3) x y));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i4_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i4 * 16)) /\ (((i4 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      s <-
      (BArray80.set128 s i4
      (VADD_2u64 (BArray80.get128 s i1) (BArray80.get128 s i3)));
      s_init <-
      (BArray80.set128 s_init i4
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i0_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i0 * 16)) /\ (((i0 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i0 * 16) 16))]);
      s <-
      (BArray80.set128 s i3
      (SHA512H2 (BArray80.get128 s i3) (BArray80.get128 s i1)
      (BArray80.get128 s i0)));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i0_init)]);
      t <- i0;
      t_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      i0 <- i3;
      i0_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      i3 <- i2;
      i3_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i4_init)]);
      i2 <- i4;
      i2_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      i4 <- i1;
      i4_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, t_init)]);
      i1 <- t;
      i1_init <- true;
      g <- (g + 1);
    }
    g_init <- true;
    g <- 32;
    while ((g < 40)) {
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, g_init)]);
      j <- (g %% 8);
      j_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, g_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 640)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray640.is_init k_init (g * 16) 16))]);
      wk <- (BArray640.get128 k g);
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
      wk <- (VADD_2u64 wk (BArray128.get128 m j));
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      wk <- (VEXT wk wk (W8.of_int 8));
      wk_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i2 * 16)) /\ (((i2 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i2 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      x <-
      (VEXT (BArray80.get128 s i2) (BArray80.get128 s i3) (W8.of_int 8));
      x_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i2 * 16)) /\ (((i2 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i2 * 16) 16))]);
      y <-
      (VEXT (BArray80.get128 s i1) (BArray80.get128 s i2) (W8.of_int 8));
      y_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, wk_init)]);
      s <- (BArray80.set128 s i3 (VADD_2u64 (BArray80.get128 s i3) wk));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, x_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, y_init)]);
      s <- (BArray80.set128 s i3 (SHA512H (BArray80.get128 s i3) x y));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i4_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i4 * 16)) /\ (((i4 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      s <-
      (BArray80.set128 s i4
      (VADD_2u64 (BArray80.get128 s i1) (BArray80.get128 s i3)));
      s_init <-
      (BArray80.set128 s_init i4
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i3 * 16)) /\ (((i3 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i3 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i1 * 16)) /\ (((i1 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i1 * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i0_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (i0 * 16)) /\ (((i0 * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (i0 * 16) 16))]);
      s <-
      (BArray80.set128 s i3
      (SHA512H2 (BArray80.get128 s i3) (BArray80.get128 s i1)
      (BArray80.get128 s i0)));
      s_init <-
      (BArray80.set128 s_init i3
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i0_init)]);
      t <- i0;
      t_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i3_init)]);
      i0 <- i3;
      i0_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i2_init)]);
      i3 <- i2;
      i3_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i4_init)]);
      i2 <- i4;
      i2_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, i1_init)]);
      i4 <- i1;
      i4_init <- true;
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, t_init)]);
      i1 <- t;
      i1_init <- true;
      g <- (g + 1);
    }
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray80.is_init s_init (j * 16) 16))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, j_init)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++ [(Assert, true)]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace___sha512_block_a64 <-
      (trace___sha512_block_a64 ++
      [(Assert, (BArray64.is_init s0_init (j * 16) 16))]);
      s <-
      (BArray80.set128 s j
      (VADD_2u64 (BArray80.get128 s j) (BArray64.get128 s0 j)));
      s_init <-
      (BArray80.set128 s_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    return (s, m, s_init, m_init, trace___sha512_block_a64);
  }
  proc _sha512_compress (h:BArray64.t, block:BArray128.t, ms:W64.t,
                         h_init:BArray64.t, block_init:BArray128.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var j:int;
    var s:BArray80.t;
    var m:BArray128.t;
    var k:BArray640.t;
    var j_init:bool;
    var s_init:BArray80.t;
    var m_init:BArray128.t;
    var k_init:BArray640.t;
    var ms_init:bool;
    var trace__sha512_compress:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    s <- witness;
    s_init <- witness;
    trace__sha512_compress <- [];
    ms_init <- true;
    j_init <- false;
    s_init <- (BArray80.init_arr (W8.of_int 0));
    m_init <- (BArray128.init_arr (W8.of_int 0));
    k_init <- (BArray640.init_arr (W8.of_int 0));
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, (BArray64.is_init h_init (j * 16) 16))]);
      s <- (BArray80.set128 s j (BArray64.get128 h j));
      s_init <-
      (BArray80.set128 s_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    j_init <- true;
    j <- 0;
    while ((j < 8)) {
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, (BArray128.is_init block_init (j * 16) 16))]);
      m <- (BArray128.set128 m j (BArray128.get128 block j));
      m_init <-
      (BArray128.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
      m <- (BArray128.set128 m j (VREV64_16u8 (BArray128.get128 m j)));
      m_init <-
      (BArray128.set128 m_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    k <- sHA512_K;
    k_init <- (BArray640.init_arr (W8.of_int 255));
    trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
    (s, m, s_init, m_init, tmp__trace) <@ __sha512_block_a64 (s, m, k,
    s_init, m_init, k_init);
    trace__sha512_compress <- (trace__sha512_compress ++ tmp__trace);
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, j_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, (BArray80.is_init s_init (j * 16) 16))]);
      h <- (BArray64.set128 h j (BArray80.get128 s j));
      h_init <-
      (BArray64.set128 h_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    trace__sha512_compress <-
    (trace__sha512_compress ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha512_compress);
  }
  proc _sha512_compress_blocks (h:BArray64.t, p:W64.t, n:W64.t, ms:W64.t,
                                h_init:BArray64.t) : BArray64.t * W64.t *
                                                     BArray64.t * trace = {
    var j:int;
    var s:BArray80.t;
    var k:BArray640.t;
    var more:bool;
    var m:BArray128.t;
    var j_init:bool;
    var s_init:BArray80.t;
    var k_init:BArray640.t;
    var more_init:bool;
    var ms_init:bool;
    var p_init:bool;
    var m_init:BArray128.t;
    var n_init:bool;
    var trace__sha512_compress_blocks:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    s <- witness;
    s_init <- witness;
    trace__sha512_compress_blocks <- [];
    p_init <- true;
    n_init <- true;
    ms_init <- true;
    j_init <- false;
    s_init <- (BArray80.init_arr (W8.of_int 0));
    k_init <- (BArray640.init_arr (W8.of_int 0));
    more_init <- false;
    m_init <- (BArray128.init_arr (W8.of_int 0));
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, (BArray64.is_init h_init (j * 16) 16))]);
      s <- (BArray80.set128 s j (BArray64.get128 h j));
      s_init <-
      (BArray80.set128 s_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    k <- sHA512_K;
    k_init <- (BArray640.init_arr (W8.of_int 255));
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, more_init)]);
    while (more) {
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, more_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++
        [(Assert,
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (p + (W64.of_int (16 * j)))) 16))]);
        m <-
        (BArray128.set128 m j
        (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
        m_init <-
        (BArray128.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++ [(Assert, true)]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 128)))]);
        trace__sha512_compress_blocks <-
        (trace__sha512_compress_blocks ++
        [(Assert, (BArray128.is_init m_init (j * 16) 16))]);
        m <- (BArray128.set128 m j (VREV64_16u8 (BArray128.get128 m j)));
        m_init <-
        (BArray128.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        j <- (j + 1);
      }
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      (s, m, s_init, m_init, tmp__trace) <@ __sha512_block_a64 (s, m, 
      k, s_init, m_init, k_init);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ tmp__trace);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
      p <- (p + (W64.of_int 128));
      p_init <- true;
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 1));
      n_init <- true;
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
      more <- (n <> (W64.of_int 0));
      more_init <- true;
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, more_init)]);
    }
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, true)]);
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, true)]);
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, more_init)]);
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, j_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 80)))]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++
      [(Assert, (BArray80.is_init s_init (j * 16) 16))]);
      h <- (BArray64.set128 h j (BArray80.get128 s j));
      h_init <-
      (BArray64.set128 h_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    trace__sha512_compress_blocks <-
    (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha512_compress_blocks);
  }
  proc __sha512_load_iv (h:BArray64.t, iv:BArray64.t, h_init:BArray64.t,
                         iv_init:BArray64.t) : BArray64.t * BArray64.t *
                                               trace = {
    var i:int;
    var t:W64.t;
    var i_init:bool;
    var t_init:bool;
    var trace___sha512_load_iv:trace;
    trace___sha512_load_iv <- [];
    i_init <- false;
    t_init <- false;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++ [(Assert, i_init)]);
      trace___sha512_load_iv <- (trace___sha512_load_iv ++ [(Assert, true)]);
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++
      [(Assert, (BArray64.is_init iv_init (i * 8) 8))]);
      t <- (BArray64.get64 iv i);
      t_init <- true;
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++ [(Assert, i_init)]);
      trace___sha512_load_iv <- (trace___sha512_load_iv ++ [(Assert, true)]);
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_load_iv <-
      (trace___sha512_load_iv ++ [(Assert, t_init)]);
      h <- (BArray64.set64 h i t);
      h_init <- (BArray64.set64 h_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (h, h_init, trace___sha512_load_iv);
  }
  proc __sha512_init (h:BArray64.t, h_init:BArray64.t) : BArray64.t *
                                                         BArray64.t * trace = {
    var trace___sha512_init:trace;
    trace___sha512_init <- [];
    trace___sha512_init <- (trace___sha512_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_load_iv (h, sHA512_IV, h_init,
    (BArray64.init_arr (W8.of_int 255)));
    trace___sha512_init <- (trace___sha512_init ++ tmp__trace);
    return (h, h_init, trace___sha512_init);
  }
  proc __sha384_init (h:BArray64.t, h_init:BArray64.t) : BArray64.t *
                                                         BArray64.t * trace = {
    var trace___sha384_init:trace;
    trace___sha384_init <- [];
    trace___sha384_init <- (trace___sha384_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_load_iv (h, sHA384_IV, h_init,
    (BArray64.init_arr (W8.of_int 255)));
    trace___sha384_init <- (trace___sha384_init ++ tmp__trace);
    return (h, h_init, trace___sha384_init);
  }
  proc __sha512_224_init (h:BArray64.t, h_init:BArray64.t) : BArray64.t *
                                                             BArray64.t *
                                                             trace = {
    var trace___sha512_224_init:trace;
    trace___sha512_224_init <- [];
    trace___sha512_224_init <- (trace___sha512_224_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_load_iv (h, sHA512_224_IV, h_init,
    (BArray64.init_arr (W8.of_int 255)));
    trace___sha512_224_init <- (trace___sha512_224_init ++ tmp__trace);
    return (h, h_init, trace___sha512_224_init);
  }
  proc __sha512_256_init (h:BArray64.t, h_init:BArray64.t) : BArray64.t *
                                                             BArray64.t *
                                                             trace = {
    var trace___sha512_256_init:trace;
    trace___sha512_256_init <- [];
    trace___sha512_256_init <- (trace___sha512_256_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_load_iv (h, sHA512_256_IV, h_init,
    (BArray64.init_arr (W8.of_int 255)));
    trace___sha512_256_init <- (trace___sha512_256_init ++ tmp__trace);
    return (h, h_init, trace___sha512_256_init);
  }
  proc _sha512_absorb_mem (h:BArray64.t, buf:BArray128.t, total:W64.t,
                           in_0:W64.t, inlen:W64.t, ms:W64.t,
                           h_init:BArray64.t, buf_init:BArray128.t) : 
  BArray64.t * BArray128.t * W64.t * W64.t * BArray64.t * BArray128.t * trace = {
    var fill:W64.t;
    var n:W64.t;
    var full:bool;
    var off:W64.t;
    var more:bool;
    var total_init:bool;
    var fill_init:bool;
    var inlen_init:bool;
    var n_init:bool;
    var in_init:bool;
    var ms_init:bool;
    var full_init:bool;
    var off_init:bool;
    var more_init:bool;
    var trace__sha512_absorb_mem:trace;
    trace__sha512_absorb_mem <- [];
    total_init <- true;
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    fill_init <- false;
    n_init <- false;
    full_init <- false;
    off_init <- false;
    more_init <- false;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    total <- (total + inlen);
    total_init <- true;
    n <- (W64.of_int 128);
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    n <- (n - fill);
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    n <- ((inlen \ult n) ? inlen : n);
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    inlen <- (inlen - n);
    inlen_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, true)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __fill128_mem (buf, fill, in_0, 
    n, ms, buf_init);
    trace__sha512_absorb_mem <- (trace__sha512_absorb_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    fill <- (fill + n);
    fill_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    in_0 <- (in_0 + n);
    in_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    full <- (fill = (W64.of_int 128));
    full_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, full_init)]);
    if (full) {
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, full_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf full ms);
      ms_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to spill *)
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha512_absorb_mem <- (trace__sha512_absorb_mem ++ tmp__trace);
      ms_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to unspill *)
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      in_0 <- (protect_64 in_0 ms);
      in_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, full_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! full) ms);
      ms_init <- true;
    }
    off <- (W64.of_int 0);
    off_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    n <- (n `>>` (W8.of_int 7));
    n_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, more_init)]);
    if (more) {
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, more_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to spill *)
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, n_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress_blocks (h, in_0, 
      n, ms, h_init);
      trace__sha512_absorb_mem <- (trace__sha512_absorb_mem ++ tmp__trace);
      ms_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      (* Erased call to unspill *)
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      in_0 <- (protect_64 in_0 ms);
      in_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
      off <- inlen;
      off_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, off_init)]);
      off <- (off `>>` (W8.of_int 7));
      off_init <- true;
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, off_init)]);
      off <- (off `<<` (W8.of_int 7));
      off_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, true)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, more_init)]);
      trace__sha512_absorb_mem <-
      (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! more) ms);
      ms_init <- true;
    }
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, off_init)]);
    inlen <- (inlen - off);
    inlen_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, off_init)]);
    in_0 <- (in_0 + off);
    in_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, true)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, fill_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, in_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, inlen_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __fill128_mem (buf, fill, in_0, 
    inlen, ms, buf_init);
    trace__sha512_absorb_mem <- (trace__sha512_absorb_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, total_init)]);
    trace__sha512_absorb_mem <-
    (trace__sha512_absorb_mem ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init, trace__sha512_absorb_mem);
  }
  proc _sha512___sha512_finalize (out:BArray64.t, h:BArray64.t,
                                  buf:BArray128.t, total:W64.t, ms:W64.t,
                                  out_init:BArray64.t, h_init:BArray64.t,
                                  buf_init:BArray128.t) : BArray64.t *
                                                          BArray64.t *
                                                          BArray128.t *
                                                          W64.t *
                                                          BArray64.t *
                                                          BArray64.t *
                                                          BArray128.t * trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var y_init:bool;
    var trace__sha512___sha512_finalize:trace;
    trace__sha512___sha512_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    y_init <- false;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 128)))]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray128.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 112) \ult fill);
    two_blocks_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 128);
      hi_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, hi_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
      buf_init);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 112);
    hi_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, hi_init)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
    buf_init);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 61));
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++
    [(Assert, ((0 <= (112 * 1)) /\ (((112 * 1) + 8) <= 128)))]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 112 t);
    buf_init <-
    (BArray128.set64d buf_init 112 (W64.of_int 18446744073709551615));
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++
    [(Assert, ((0 <= (120 * 1)) /\ (((120 * 1) + 8) <= 128)))]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 120 t);
    buf_init <-
    (BArray128.set64d buf_init 120 (W64.of_int 18446744073709551615));
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, true)]);
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray128.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (64 %/ 8);
    i <- 0;
    while ((i < inc)) {
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, x_init)]);
      out <- (BArray64.set64 out i x);
      out_init <-
      (BArray64.set64 out_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    inc <- ((64 + 7) %/ 8);
    i <- (64 %/ 8);
    while ((i < inc)) {
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, x_init)]);
      x <- (x `>>` (W8.of_int 32));
      x_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, x_init)]);
      y <- (truncateu32 x);
      y_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, y_init)]);
      (y, tmp__trace) <@ __bswap32 (y);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ tmp__trace);
      y_init <- true;
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, true)]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++
      [(Assert, ((0 <= ((2 * i) * 4)) /\ ((((2 * i) * 4) + 4) <= 64)))]);
      trace__sha512___sha512_finalize <-
      (trace__sha512___sha512_finalize ++ [(Assert, y_init)]);
      out <- (BArray64.set32 out (2 * i) y);
      out_init <- (BArray64.set32 out_init (2 * i) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha512___sha512_finalize <-
    (trace__sha512___sha512_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha512___sha512_finalize);
  }
  proc _sha512____sha512_mem_from (out:BArray64.t, h:BArray64.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t,
                                   out_init:BArray64.t, h_init:BArray64.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512____sha512_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha512____sha512_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, in_init)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, inlen_init)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha512_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha512____sha512_mem_from <-
    (trace__sha512____sha512_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512____sha512_mem_from);
  }
  proc _sha384___sha512_finalize (out:BArray48.t, h:BArray64.t,
                                  buf:BArray128.t, total:W64.t, ms:W64.t,
                                  out_init:BArray48.t, h_init:BArray64.t,
                                  buf_init:BArray128.t) : BArray48.t *
                                                          BArray64.t *
                                                          BArray128.t *
                                                          W64.t *
                                                          BArray48.t *
                                                          BArray64.t *
                                                          BArray128.t * trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var y_init:bool;
    var trace__sha384___sha512_finalize:trace;
    trace__sha384___sha512_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    y_init <- false;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 128)))]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray128.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 112) \ult fill);
    two_blocks_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 128);
      hi_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, hi_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
      buf_init);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray48.init_arr (W8.of_int 255));
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 112);
    hi_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, hi_init)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
    buf_init);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 61));
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++
    [(Assert, ((0 <= (112 * 1)) /\ (((112 * 1) + 8) <= 128)))]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 112 t);
    buf_init <-
    (BArray128.set64d buf_init 112 (W64.of_int 18446744073709551615));
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++
    [(Assert, ((0 <= (120 * 1)) /\ (((120 * 1) + 8) <= 128)))]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 120 t);
    buf_init <-
    (BArray128.set64d buf_init 120 (W64.of_int 18446744073709551615));
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray48.init_arr (W8.of_int 255));
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, true)]);
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray128.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (48 %/ 8);
    i <- 0;
    while ((i < inc)) {
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 48)))]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, x_init)]);
      out <- (BArray48.set64 out i x);
      out_init <-
      (BArray48.set64 out_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    inc <- ((48 + 7) %/ 8);
    i <- (48 %/ 8);
    while ((i < inc)) {
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, x_init)]);
      x <- (x `>>` (W8.of_int 32));
      x_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, x_init)]);
      y <- (truncateu32 x);
      y_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, y_init)]);
      (y, tmp__trace) <@ __bswap32 (y);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ tmp__trace);
      y_init <- true;
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, true)]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++
      [(Assert, ((0 <= ((2 * i) * 4)) /\ ((((2 * i) * 4) + 4) <= 48)))]);
      trace__sha384___sha512_finalize <-
      (trace__sha384___sha512_finalize ++ [(Assert, y_init)]);
      out <- (BArray48.set32 out (2 * i) y);
      out_init <- (BArray48.set32 out_init (2 * i) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha384___sha512_finalize <-
    (trace__sha384___sha512_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha384___sha512_finalize);
  }
  proc _sha384____sha512_mem_from (out:BArray48.t, h:BArray64.t, in_0:W64.t,
                                   inlen:W64.t, ms:W64.t,
                                   out_init:BArray48.t, h_init:BArray64.t) : 
  BArray48.t * W64.t * BArray48.t * trace = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha384____sha512_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha384____sha512_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, in_init)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, inlen_init)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha512_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, true)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha384___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha384____sha512_mem_from <-
    (trace__sha384____sha512_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha384____sha512_mem_from);
  }
  proc _sha512_224___sha512_finalize (out:BArray28.t, h:BArray64.t,
                                      buf:BArray128.t, total:W64.t, ms:W64.t,
                                      out_init:BArray28.t, h_init:BArray64.t,
                                      buf_init:BArray128.t) : BArray28.t *
                                                              BArray64.t *
                                                              BArray128.t *
                                                              W64.t *
                                                              BArray28.t *
                                                              BArray64.t *
                                                              BArray128.t *
                                                              trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var y_init:bool;
    var trace__sha512_224___sha512_finalize:trace;
    trace__sha512_224___sha512_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    y_init <- false;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 128)))]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray128.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 112) \ult fill);
    two_blocks_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 128);
      hi_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, hi_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
      buf_init);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray28.init_arr (W8.of_int 255));
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 112);
    hi_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, hi_init)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
    buf_init);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 61));
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++
    [(Assert, ((0 <= (112 * 1)) /\ (((112 * 1) + 8) <= 128)))]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 112 t);
    buf_init <-
    (BArray128.set64d buf_init 112 (W64.of_int 18446744073709551615));
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++
    [(Assert, ((0 <= (120 * 1)) /\ (((120 * 1) + 8) <= 128)))]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 120 t);
    buf_init <-
    (BArray128.set64d buf_init 120 (W64.of_int 18446744073709551615));
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray28.init_arr (W8.of_int 255));
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray128.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (28 %/ 8);
    i <- 0;
    while ((i < inc)) {
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 28)))]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, x_init)]);
      out <- (BArray28.set64 out i x);
      out_init <-
      (BArray28.set64 out_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    inc <- ((28 + 7) %/ 8);
    i <- (28 %/ 8);
    while ((i < inc)) {
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, x_init)]);
      x <- (x `>>` (W8.of_int 32));
      x_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, x_init)]);
      y <- (truncateu32 x);
      y_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, y_init)]);
      (y, tmp__trace) <@ __bswap32 (y);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ tmp__trace);
      y_init <- true;
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++
      [(Assert, ((0 <= ((2 * i) * 4)) /\ ((((2 * i) * 4) + 4) <= 28)))]);
      trace__sha512_224___sha512_finalize <-
      (trace__sha512_224___sha512_finalize ++ [(Assert, y_init)]);
      out <- (BArray28.set32 out (2 * i) y);
      out_init <- (BArray28.set32 out_init (2 * i) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha512_224___sha512_finalize <-
    (trace__sha512_224___sha512_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha512_224___sha512_finalize);
  }
  proc _sha512_224____sha512_mem_from (out:BArray28.t, h:BArray64.t,
                                       in_0:W64.t, inlen:W64.t, ms:W64.t,
                                       out_init:BArray28.t, h_init:BArray64.t) : 
  BArray28.t * W64.t * BArray28.t * trace = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512_224____sha512_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha512_224____sha512_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, in_init)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, inlen_init)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha512_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_224___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha512_224____sha512_mem_from <-
    (trace__sha512_224____sha512_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_224____sha512_mem_from);
  }
  proc _sha512_256___sha512_finalize (out:BArray32.t, h:BArray64.t,
                                      buf:BArray128.t, total:W64.t, ms:W64.t,
                                      out_init:BArray32.t, h_init:BArray64.t,
                                      buf_init:BArray128.t) : BArray32.t *
                                                              BArray64.t *
                                                              BArray128.t *
                                                              W64.t *
                                                              BArray32.t *
                                                              BArray64.t *
                                                              BArray128.t *
                                                              trace = {
    var inc:int;
    var fill:W64.t;
    var t:W64.t;
    var two_blocks:bool;
    var hi:W64.t;
    var i:int;
    var x:W64.t;
    var y:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var t_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var i_init:bool;
    var x_init:bool;
    var y_init:bool;
    var trace__sha512_256___sha512_finalize:trace;
    trace__sha512_256___sha512_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    t_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    i_init <- false;
    x_init <- false;
    y_init <- false;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++
    [(Assert,
     ((0 <= ((W64.to_uint fill) * 1)) /\
     ((((W64.to_uint fill) * 1) + 1) <= 128)))]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set8 buf (W64.to_uint fill) (truncateu8 t));
    buf_init <- (BArray128.set8 buf_init (W64.to_uint fill) (W8.of_int 255));
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 112) \ult fill);
    two_blocks_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 128);
      hi_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, hi_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
      buf_init);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
      buf_init);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray32.init_arr (W8.of_int 255));
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray128.init_arr (W8.of_int 255));
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 112);
    hi_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, fill_init)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, hi_init)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
    (buf, ms, buf_init, tmp__trace) <@ __zero128 (buf, fill, hi, ms,
    buf_init);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 61));
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++
    [(Assert, ((0 <= (112 * 1)) /\ (((112 * 1) + 8) <= 128)))]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 112 t);
    buf_init <-
    (BArray128.set64d buf_init 112 (W64.of_int 18446744073709551615));
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++
    [(Assert, ((0 <= (120 * 1)) /\ (((120 * 1) + 8) <= 128)))]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, t_init)]);
    buf <- (BArray128.set64d buf 120 t);
    buf_init <-
    (BArray128.set64d buf_init 120 (W64.of_int 18446744073709551615));
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray128.init_arr (W8.of_int 255));
    i_init <- true;
    inc <- (32 %/ 8);
    i <- 0;
    while ((i < inc)) {
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ tmp__trace);
      x_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 32)))]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, x_init)]);
      out <- (BArray32.set64 out i x);
      out_init <-
      (BArray32.set64 out_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    inc <- ((32 + 7) %/ 8);
    i <- (32 %/ 8);
    while ((i < inc)) {
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, x_init)]);
      x <- (x `>>` (W8.of_int 32));
      x_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, x_init)]);
      y <- (truncateu32 x);
      y_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, y_init)]);
      (y, tmp__trace) <@ __bswap32 (y);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ tmp__trace);
      y_init <- true;
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, i_init)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, true)]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++
      [(Assert, ((0 <= ((2 * i) * 4)) /\ ((((2 * i) * 4) + 4) <= 32)))]);
      trace__sha512_256___sha512_finalize <-
      (trace__sha512_256___sha512_finalize ++ [(Assert, y_init)]);
      out <- (BArray32.set32 out (2 * i) y);
      out_init <- (BArray32.set32 out_init (2 * i) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha512_256___sha512_finalize <-
    (trace__sha512_256___sha512_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha512_256___sha512_finalize);
  }
  proc _sha512_256____sha512_mem_from (out:BArray32.t, h:BArray64.t,
                                       in_0:W64.t, inlen:W64.t, ms:W64.t,
                                       out_init:BArray32.t, h_init:BArray64.t) : 
  BArray32.t * W64.t * BArray32.t * trace = {
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512_256____sha512_mem_from:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    trace__sha512_256____sha512_mem_from <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, in_init)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, inlen_init)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha512_absorb_mem (
    h, buf, total, in_0, inlen, ms, h_init, buf_init);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, true)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, total_init)]);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_256___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ tmp__trace);
    ms_init <- true;
    trace__sha512_256____sha512_mem_from <-
    (trace__sha512_256____sha512_mem_from ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_256____sha512_mem_from);
  }
  proc _sha512_mem (out:BArray64.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                    out_init:BArray64.t) : BArray64.t * W64.t * BArray64.t *
                                           trace = {
    var h:BArray64.t;
    var h_init:BArray64.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha512_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace__sha512_mem <- (trace__sha512_mem ++ tmp__trace);
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, true)]);
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, in_init)]);
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, inlen_init)]);
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512____sha512_mem_from (out, 
    h, in_0, inlen, ms, out_init, h_init);
    trace__sha512_mem <- (trace__sha512_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha512_mem <- (trace__sha512_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_mem);
  }
  proc _sha384_mem (out:BArray48.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                    out_init:BArray48.t) : BArray48.t * W64.t * BArray48.t *
                                           trace = {
    var h:BArray64.t;
    var h_init:BArray64.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha384_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha384_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha384_init (h, h_init);
    trace__sha384_mem <- (trace__sha384_mem ++ tmp__trace);
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, true)]);
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, in_init)]);
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, inlen_init)]);
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha384____sha512_mem_from (out, 
    h, in_0, inlen, ms, out_init, h_init);
    trace__sha384_mem <- (trace__sha384_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha384_mem <- (trace__sha384_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha384_mem);
  }
  proc _sha512_224_mem (out:BArray28.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                        out_init:BArray28.t) : BArray28.t * W64.t *
                                               BArray28.t * trace = {
    var h:BArray64.t;
    var h_init:BArray64.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512_224_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha512_224_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_224_init (h, h_init);
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ tmp__trace);
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ [(Assert, true)]);
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ [(Assert, in_init)]);
    trace__sha512_224_mem <-
    (trace__sha512_224_mem ++ [(Assert, inlen_init)]);
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_224____sha512_mem_from (
    out, h, in_0, inlen, ms, out_init, h_init);
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha512_224_mem <- (trace__sha512_224_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_224_mem);
  }
  proc _sha512_256_mem (out:BArray32.t, in_0:W64.t, inlen:W64.t, ms:W64.t,
                        out_init:BArray32.t) : BArray32.t * W64.t *
                                               BArray32.t * trace = {
    var h:BArray64.t;
    var h_init:BArray64.t;
    var in_init:bool;
    var inlen_init:bool;
    var ms_init:bool;
    var trace__sha512_256_mem:trace;
    h <- witness;
    h_init <- witness;
    trace__sha512_256_mem <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- true;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_256_init (h, h_init);
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ tmp__trace);
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ [(Assert, true)]);
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ [(Assert, in_init)]);
    trace__sha512_256_mem <-
    (trace__sha512_256_mem ++ [(Assert, inlen_init)]);
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_256____sha512_mem_from (
    out, h, in_0, inlen, ms, out_init, h_init);
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ tmp__trace);
    ms_init <- true;
    trace__sha512_256_mem <- (trace__sha512_256_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_256_mem);
  }
  proc _hmac_sha256_keyblock_mem (k0:BArray64.t, key:W64.t, keylen:W64.t,
                                  ms:W64.t, k0_init:BArray64.t) : BArray64.t *
                                                                  W64.t *
                                                                  BArray64.t *
                                                                  trace = {
    var long:bool;
    var i:W64.t;
    var digest:BArray32.t;
    var j:int;
    var t:W64.t;
    var hi:W64.t;
    var keylen_init:bool;
    var long_init:bool;
    var ms_init:bool;
    var i_init:bool;
    var key_init:bool;
    var digest_init:BArray32.t;
    var j_init:bool;
    var t_init:bool;
    var hi_init:bool;
    var trace__hmac_sha256_keyblock_mem:trace;
    digest <- witness;
    digest_init <- witness;
    trace__hmac_sha256_keyblock_mem <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- true;
    long_init <- false;
    i_init <- false;
    digest_init <- (BArray32.init_arr (W8.of_int 0));
    j_init <- false;
    t_init <- false;
    hi_init <- false;
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, keylen_init)]);
    long <- ((W64.of_int 64) \ult keylen);
    long_init <- true;
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, long_init)]);
    if (long) {
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, long_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf long ms);
      ms_init <- true;
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, key_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, keylen_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
      (digest, ms, digest_init, tmp__trace) <@ _sha256_mem (digest, key,
      keylen, ms, digest_init);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ tmp__trace);
      ms_init <- true;
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
      k0 <- (protect_ptr k0 ms);
      k0_init <- (BArray64.init_arr (W8.of_int 255));
      j_init <- true;
      j <- 0;
      while ((j < 4)) {
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++ [(Assert, j_init)]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 32)))]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++
        [(Assert, (BArray32.is_init digest_init (j * 8) 8))]);
        t <- (BArray32.get64 digest j);
        t_init <- true;
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++ [(Assert, j_init)]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__hmac_sha256_keyblock_mem <-
        (trace__hmac_sha256_keyblock_mem ++ [(Assert, t_init)]);
        k0 <- (BArray64.set64 k0 j t);
        k0_init <-
        (BArray64.set64 k0_init j (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      i <- (W64.of_int 32);
      i_init <- true;
    } else {
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, long_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! long) ms);
      ms_init <- true;
      i <- (W64.of_int 0);
      i_init <- true;
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, i_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, key_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, keylen_init)]);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
      (k0, ms, k0_init, tmp__trace) <@ __fill64_mem (k0, i, key, keylen, 
      ms, k0_init);
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ tmp__trace);
      ms_init <- true;
      trace__hmac_sha256_keyblock_mem <-
      (trace__hmac_sha256_keyblock_mem ++ [(Assert, keylen_init)]);
      i <- keylen;
      i_init <- true;
    }
    hi <- (W64.of_int 64);
    hi_init <- true;
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, true)]);
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, i_init)]);
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, hi_init)]);
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ __zero64 (k0, i, hi, ms, k0_init);
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha256_keyblock_mem <-
    (trace__hmac_sha256_keyblock_mem ++ [(Assert, ms_init)]);
    return (k0, ms, k0_init, trace__hmac_sha256_keyblock_mem);
  }
  proc _hmac_sha512_keyblock_mem (k0:BArray128.t, key:W64.t, keylen:W64.t,
                                  ms:W64.t, k0_init:BArray128.t) : BArray128.t *
                                                                   W64.t *
                                                                   BArray128.t *
                                                                   trace = {
    var long:bool;
    var i:W64.t;
    var digest:BArray64.t;
    var j:int;
    var t:W64.t;
    var hi:W64.t;
    var keylen_init:bool;
    var long_init:bool;
    var ms_init:bool;
    var i_init:bool;
    var key_init:bool;
    var digest_init:BArray64.t;
    var j_init:bool;
    var t_init:bool;
    var hi_init:bool;
    var trace__hmac_sha512_keyblock_mem:trace;
    digest <- witness;
    digest_init <- witness;
    trace__hmac_sha512_keyblock_mem <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- true;
    long_init <- false;
    i_init <- false;
    digest_init <- (BArray64.init_arr (W8.of_int 0));
    j_init <- false;
    t_init <- false;
    hi_init <- false;
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, keylen_init)]);
    long <- ((W64.of_int 128) \ult keylen);
    long_init <- true;
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, long_init)]);
    if (long) {
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, long_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf long ms);
      ms_init <- true;
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, key_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, keylen_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
      (digest, ms, digest_init, tmp__trace) <@ _sha512_mem (digest, key,
      keylen, ms, digest_init);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ tmp__trace);
      ms_init <- true;
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
      k0 <- (protect_ptr k0 ms);
      k0_init <- (BArray128.init_arr (W8.of_int 255));
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++ [(Assert, j_init)]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++
        [(Assert, (BArray64.is_init digest_init (j * 8) 8))]);
        t <- (BArray64.get64 digest j);
        t_init <- true;
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++ [(Assert, j_init)]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 128)))]);
        trace__hmac_sha512_keyblock_mem <-
        (trace__hmac_sha512_keyblock_mem ++ [(Assert, t_init)]);
        k0 <- (BArray128.set64 k0 j t);
        k0_init <-
        (BArray128.set64 k0_init j (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      i <- (W64.of_int 64);
      i_init <- true;
    } else {
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, long_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
      ms <- (update_msf (! long) ms);
      ms_init <- true;
      i <- (W64.of_int 0);
      i_init <- true;
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, i_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, key_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, keylen_init)]);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
      (k0, ms, k0_init, tmp__trace) <@ __fill128_mem (k0, i, key, keylen, 
      ms, k0_init);
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ tmp__trace);
      ms_init <- true;
      trace__hmac_sha512_keyblock_mem <-
      (trace__hmac_sha512_keyblock_mem ++ [(Assert, keylen_init)]);
      i <- keylen;
      i_init <- true;
    }
    hi <- (W64.of_int 128);
    hi_init <- true;
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, true)]);
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, i_init)]);
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, hi_init)]);
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ __zero128 (k0, i, hi, ms, k0_init);
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha512_keyblock_mem <-
    (trace__hmac_sha512_keyblock_mem ++ [(Assert, ms_init)]);
    return (k0, ms, k0_init, trace__hmac_sha512_keyblock_mem);
  }
  proc __hmac_sha256_init (inner:BArray32.t, outer:BArray32.t, k0:BArray64.t,
                           ms:W64.t, inner_init:BArray32.t,
                           outer_init:BArray32.t, k0_init:BArray64.t) : 
  BArray32.t * BArray32.t * W64.t * BArray32.t * BArray32.t * trace = {
    var mi:W64.t;
    var mo:W64.t;
    var i:int;
    var t:W64.t;
    var u:W64.t;
    var ipad:BArray64.t;
    var opad:BArray64.t;
    var mi_init:bool;
    var mo_init:bool;
    var i_init:bool;
    var t_init:bool;
    var u_init:bool;
    var ipad_init:BArray64.t;
    var opad_init:BArray64.t;
    var ms_init:bool;
    var trace___hmac_sha256_init:trace;
    ipad <- witness;
    ipad_init <- witness;
    opad <- witness;
    opad_init <- witness;
    trace___hmac_sha256_init <- [];
    ms_init <- true;
    mi_init <- false;
    mo_init <- false;
    i_init <- false;
    t_init <- false;
    u_init <- false;
    ipad_init <- (BArray64.init_arr (W8.of_int 0));
    opad_init <- (BArray64.init_arr (W8.of_int 0));
    mi <- (W64.of_int 3906369333256140342);
    mi_init <- true;
    mo <- (W64.of_int 6655295901103053916);
    mo_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, i_init)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, true)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++
      [(Assert, (BArray64.is_init k0_init (i * 8) 8))]);
      t <- (BArray64.get64 k0 i);
      t_init <- true;
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, t_init)]);
      u <- t;
      u_init <- true;
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, t_init)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, mi_init)]);
      t <- (t `^` mi);
      t_init <- true;
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, u_init)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, mo_init)]);
      u <- (u `^` mo);
      u_init <- true;
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, i_init)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, true)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, t_init)]);
      ipad <- (BArray64.set64 ipad i t);
      ipad_init <-
      (BArray64.set64 ipad_init i (W64.of_int 18446744073709551615));
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, i_init)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, true)]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha256_init <-
      (trace___hmac_sha256_init ++ [(Assert, u_init)]);
      opad <- (BArray64.set64 opad i u);
      opad_init <-
      (BArray64.set64 opad_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, true)]);
    (inner, inner_init, tmp__trace) <@ __sha256_init (inner, inner_init);
    trace___hmac_sha256_init <- (trace___hmac_sha256_init ++ tmp__trace);
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, true)]);
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, ms_init)]);
    (inner, ms, inner_init, tmp__trace) <@ _sha256_compress (inner, ipad, 
    ms, inner_init, ipad_init);
    trace___hmac_sha256_init <- (trace___hmac_sha256_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, true)]);
    (outer, outer_init, tmp__trace) <@ __sha256_init (outer, outer_init);
    trace___hmac_sha256_init <- (trace___hmac_sha256_init ++ tmp__trace);
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, true)]);
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, ms_init)]);
    (outer, ms, outer_init, tmp__trace) <@ _sha256_compress (outer, opad, 
    ms, outer_init, opad_init);
    trace___hmac_sha256_init <- (trace___hmac_sha256_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha256_init <-
    (trace___hmac_sha256_init ++ [(Assert, ms_init)]);
    return (inner, outer, ms, inner_init, outer_init,
           trace___hmac_sha256_init);
  }
  proc __hmac_sha512_init (inner:BArray64.t, outer:BArray64.t,
                           k0:BArray128.t, ms:W64.t, inner_init:BArray64.t,
                           outer_init:BArray64.t, k0_init:BArray128.t) : 
  BArray64.t * BArray64.t * W64.t * BArray64.t * BArray64.t * trace = {
    var mi:W64.t;
    var mo:W64.t;
    var i:int;
    var t:W64.t;
    var u:W64.t;
    var ipad:BArray128.t;
    var opad:BArray128.t;
    var mi_init:bool;
    var mo_init:bool;
    var i_init:bool;
    var t_init:bool;
    var u_init:bool;
    var ipad_init:BArray128.t;
    var opad_init:BArray128.t;
    var ms_init:bool;
    var trace___hmac_sha512_init:trace;
    ipad <- witness;
    ipad_init <- witness;
    opad <- witness;
    opad_init <- witness;
    trace___hmac_sha512_init <- [];
    ms_init <- true;
    mi_init <- false;
    mo_init <- false;
    i_init <- false;
    t_init <- false;
    u_init <- false;
    ipad_init <- (BArray128.init_arr (W8.of_int 0));
    opad_init <- (BArray128.init_arr (W8.of_int 0));
    mi <- (W64.of_int 3906369333256140342);
    mi_init <- true;
    mo <- (W64.of_int 6655295901103053916);
    mo_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, i_init)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, true)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++
      [(Assert, (BArray128.is_init k0_init (i * 8) 8))]);
      t <- (BArray128.get64 k0 i);
      t_init <- true;
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, t_init)]);
      u <- t;
      u_init <- true;
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, t_init)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, mi_init)]);
      t <- (t `^` mi);
      t_init <- true;
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, u_init)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, mo_init)]);
      u <- (u `^` mo);
      u_init <- true;
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, i_init)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, true)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, t_init)]);
      ipad <- (BArray128.set64 ipad i t);
      ipad_init <-
      (BArray128.set64 ipad_init i (W64.of_int 18446744073709551615));
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, i_init)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, true)]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace___hmac_sha512_init <-
      (trace___hmac_sha512_init ++ [(Assert, u_init)]);
      opad <- (BArray128.set64 opad i u);
      opad_init <-
      (BArray128.set64 opad_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, true)]);
    (inner, inner_init, tmp__trace) <@ __sha512_init (inner, inner_init);
    trace___hmac_sha512_init <- (trace___hmac_sha512_init ++ tmp__trace);
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, true)]);
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, ms_init)]);
    (inner, ms, inner_init, tmp__trace) <@ _sha512_compress (inner, ipad, 
    ms, inner_init, ipad_init);
    trace___hmac_sha512_init <- (trace___hmac_sha512_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, true)]);
    (outer, outer_init, tmp__trace) <@ __sha512_init (outer, outer_init);
    trace___hmac_sha512_init <- (trace___hmac_sha512_init ++ tmp__trace);
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, true)]);
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, ms_init)]);
    (outer, ms, outer_init, tmp__trace) <@ _sha512_compress (outer, opad, 
    ms, outer_init, opad_init);
    trace___hmac_sha512_init <- (trace___hmac_sha512_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha512_init <-
    (trace___hmac_sha512_init ++ [(Assert, ms_init)]);
    return (inner, outer, ms, inner_init, outer_init,
           trace___hmac_sha512_init);
  }
  proc __hmac_sha256_outer (inner:BArray32.t, buf:BArray64.t, total:W64.t,
                            outer:BArray32.t, ms:W64.t,
                            inner_init:BArray32.t, buf_init:BArray64.t,
                            outer_init:BArray32.t) : BArray32.t *
                                                     BArray64.t * W64.t *
                                                     W64.t * BArray32.t *
                                                     BArray64.t * trace = {
    var digest:BArray32.t;
    var i:int;
    var x:W32.t;
    var t:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var digest_init:BArray32.t;
    var i_init:bool;
    var x_init:bool;
    var t_init:bool;
    var trace___hmac_sha256_outer:trace;
    digest <- witness;
    digest_init <- witness;
    trace___hmac_sha256_outer <- [];
    total_init <- true;
    ms_init <- true;
    digest_init <- (BArray32.init_arr (W8.of_int 0));
    i_init <- false;
    x_init <- false;
    t_init <- false;
    trace___hmac_sha256_outer <-
    (trace___hmac_sha256_outer ++ [(Assert, true)]);
    trace___hmac_sha256_outer <-
    (trace___hmac_sha256_outer ++ [(Assert, total_init)]);
    trace___hmac_sha256_outer <-
    (trace___hmac_sha256_outer ++ [(Assert, ms_init)]);
    (digest, inner, buf, ms, digest_init, inner_init, buf_init, tmp__trace) <@ 
    _sha256___sha256_finalize (digest, inner, buf, total, ms, digest_init,
    inner_init, buf_init);
    trace___hmac_sha256_outer <- (trace___hmac_sha256_outer ++ tmp__trace);
    ms_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, i_init)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, true)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, (BArray32.is_init outer_init (i * 4) 4))]);
      x <- (BArray32.get32 outer i);
      x_init <- true;
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, i_init)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, true)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, x_init)]);
      inner <- (BArray32.set32 inner i x);
      inner_init <- (BArray32.set32 inner_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 4)) {
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, i_init)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, true)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 32)))]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, (BArray32.is_init digest_init (i * 8) 8))]);
      t <- (BArray32.get64 digest i);
      t_init <- true;
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, i_init)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, true)]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha256_outer <-
      (trace___hmac_sha256_outer ++ [(Assert, t_init)]);
      buf <- (BArray64.set64 buf i t);
      buf_init <-
      (BArray64.set64 buf_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    total <- (W64.of_int (64 + 32));
    total_init <- true;
    trace___hmac_sha256_outer <-
    (trace___hmac_sha256_outer ++ [(Assert, total_init)]);
    trace___hmac_sha256_outer <-
    (trace___hmac_sha256_outer ++ [(Assert, ms_init)]);
    return (inner, buf, total, ms, inner_init, buf_init,
           trace___hmac_sha256_outer);
  }
  proc __hmac_sha256_finalize (out:BArray32.t, inner:BArray32.t,
                               buf:BArray64.t, total:W64.t, outer:BArray32.t,
                               ms:W64.t, out_init:BArray32.t,
                               inner_init:BArray32.t, buf_init:BArray64.t,
                               outer_init:BArray32.t) : BArray32.t *
                                                        BArray32.t *
                                                        BArray64.t * W64.t *
                                                        BArray32.t *
                                                        BArray32.t *
                                                        BArray64.t * trace = {
    var total_init:bool;
    var ms_init:bool;
    var trace___hmac_sha256_finalize:trace;
    trace___hmac_sha256_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, true)]);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, total_init)]);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ __hmac_sha256_outer (
    inner, buf, total, outer, ms, inner_init, buf_init, outer_init);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, true)]);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, total_init)]);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, ms_init)]);
    (out, inner, buf, ms, out_init, inner_init, buf_init, tmp__trace) <@ 
    _sha256___sha256_finalize (out, inner, buf, total, ms, out_init,
    inner_init, buf_init);
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha256_finalize <-
    (trace___hmac_sha256_finalize ++ [(Assert, ms_init)]);
    return (out, inner, buf, ms, out_init, inner_init, buf_init,
           trace___hmac_sha256_finalize);
  }
  proc __hmac_sha512_outer (inner:BArray64.t, buf:BArray128.t, total:W64.t,
                            outer:BArray64.t, ms:W64.t,
                            inner_init:BArray64.t, buf_init:BArray128.t,
                            outer_init:BArray64.t) : BArray64.t *
                                                     BArray128.t * W64.t *
                                                     W64.t * BArray64.t *
                                                     BArray128.t * trace = {
    var digest:BArray64.t;
    var i:int;
    var t:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var digest_init:BArray64.t;
    var i_init:bool;
    var t_init:bool;
    var trace___hmac_sha512_outer:trace;
    digest <- witness;
    digest_init <- witness;
    trace___hmac_sha512_outer <- [];
    total_init <- true;
    ms_init <- true;
    digest_init <- (BArray64.init_arr (W8.of_int 0));
    i_init <- false;
    t_init <- false;
    trace___hmac_sha512_outer <-
    (trace___hmac_sha512_outer ++ [(Assert, true)]);
    trace___hmac_sha512_outer <-
    (trace___hmac_sha512_outer ++ [(Assert, total_init)]);
    trace___hmac_sha512_outer <-
    (trace___hmac_sha512_outer ++ [(Assert, ms_init)]);
    (digest, inner, buf, ms, digest_init, inner_init, buf_init, tmp__trace) <@ 
    _sha512___sha512_finalize (digest, inner, buf, total, ms, digest_init,
    inner_init, buf_init);
    trace___hmac_sha512_outer <- (trace___hmac_sha512_outer ++ tmp__trace);
    ms_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, i_init)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, true)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, (BArray64.is_init outer_init (i * 8) 8))]);
      t <- (BArray64.get64 outer i);
      t_init <- true;
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, i_init)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, true)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, t_init)]);
      inner <- (BArray64.set64 inner i t);
      inner_init <-
      (BArray64.set64 inner_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, i_init)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, true)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, (BArray64.is_init digest_init (i * 8) 8))]);
      t <- (BArray64.get64 digest i);
      t_init <- true;
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, i_init)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, true)]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace___hmac_sha512_outer <-
      (trace___hmac_sha512_outer ++ [(Assert, t_init)]);
      buf <- (BArray128.set64 buf i t);
      buf_init <-
      (BArray128.set64 buf_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    total <- (W64.of_int (128 + 64));
    total_init <- true;
    trace___hmac_sha512_outer <-
    (trace___hmac_sha512_outer ++ [(Assert, total_init)]);
    trace___hmac_sha512_outer <-
    (trace___hmac_sha512_outer ++ [(Assert, ms_init)]);
    return (inner, buf, total, ms, inner_init, buf_init,
           trace___hmac_sha512_outer);
  }
  proc __hmac_sha512_finalize (out:BArray64.t, inner:BArray64.t,
                               buf:BArray128.t, total:W64.t,
                               outer:BArray64.t, ms:W64.t,
                               out_init:BArray64.t, inner_init:BArray64.t,
                               buf_init:BArray128.t, outer_init:BArray64.t) : 
  BArray64.t * BArray64.t * BArray128.t * W64.t * BArray64.t * BArray64.t *
  BArray128.t * trace = {
    var total_init:bool;
    var ms_init:bool;
    var trace___hmac_sha512_finalize:trace;
    trace___hmac_sha512_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, true)]);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, total_init)]);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ __hmac_sha512_outer (
    inner, buf, total, outer, ms, inner_init, buf_init, outer_init);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, true)]);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, total_init)]);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, ms_init)]);
    (out, inner, buf, ms, out_init, inner_init, buf_init, tmp__trace) <@ 
    _sha512___sha512_finalize (out, inner, buf, total, ms, out_init,
    inner_init, buf_init);
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha512_finalize <-
    (trace___hmac_sha512_finalize ++ [(Assert, ms_init)]);
    return (out, inner, buf, ms, out_init, inner_init, buf_init,
           trace___hmac_sha512_finalize);
  }
  proc __sha2_tag (f:int) : W64.t * trace = {
    var tag:W64.t;
    var f_init:bool;
    var tag_init:bool;
    var trace___sha2_tag:trace;
    trace___sha2_tag <- [];
    f_init <- true;
    tag_init <- false;
    trace___sha2_tag <- (trace___sha2_tag ++ [(Assert, f_init)]);
    tag <- (W64.of_int (1100357333870 + (f `<<` 32)));
    tag_init <- true;
    trace___sha2_tag <- (trace___sha2_tag ++ [(Assert, tag_init)]);
    return (tag, trace___sha2_tag);
  }
  proc __sha2_ctx_open (head:BArray16.t, ms:W64.t, head_init:BArray16.t) : 
  W64.t * W64.t * trace = {
    var tag:W64.t;
    var total:W64.t;
    var tag_init:bool;
    var total_init:bool;
    var ms_init:bool;
    var trace___sha2_ctx_open:trace;
    trace___sha2_ctx_open <- [];
    ms_init <- true;
    tag_init <- false;
    total_init <- false;
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 16)))]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++
    [(Assert, (BArray16.is_init head_init (0 * 1) 8))]);
    tag <- (BArray16.get64d head 0);
    tag_init <- true;
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++
    [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 16)))]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++
    [(Assert, (BArray16.is_init head_init (8 * 1) 8))]);
    total <- (BArray16.get64d head 8);
    total_init <- true;
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, tag_init)]);
    (* Erased call to declassify *)
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++ [(Assert, total_init)]);
    (* Erased call to declassify *)
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, tag_init)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, ms_init)]);
    tag <- (protect_64 tag ms);
    tag_init <- true;
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, true)]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++ [(Assert, total_init)]);
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace___sha2_ctx_open <- (trace___sha2_ctx_open ++ [(Assert, tag_init)]);
    trace___sha2_ctx_open <-
    (trace___sha2_ctx_open ++ [(Assert, total_init)]);
    return (tag, total, trace___sha2_ctx_open);
  }
  proc __sha2_room (total:W64.t) : W64.t * trace = {
    var room:W64.t;
    var limit:W64.t;
    var zero:W64.t;
    var limit_init:bool;
    var zero_init:bool;
    var room_init:bool;
    var total_init:bool;
    var trace___sha2_room:trace;
    trace___sha2_room <- [];
    total_init <- true;
    room_init <- false;
    limit_init <- false;
    zero_init <- false;
    limit <- (W64.of_int 2305843009213693952);
    limit_init <- true;
    zero <- (W64.of_int 0);
    zero_init <- true;
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, limit_init)]);
    room <- limit;
    room_init <- true;
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, room_init)]);
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, total_init)]);
    room <- (room - total);
    room_init <- true;
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, total_init)]);
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, limit_init)]);
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, room_init)]);
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, zero_init)]);
    room <- ((total \ult limit) ? room : zero);
    room_init <- true;
    trace___sha2_room <- (trace___sha2_room ++ [(Assert, room_init)]);
    return (room, trace___sha2_room);
  }
  proc __sha256_ctx_load (h:BArray32.t, buf:BArray64.t, ctx:BArray112.t,
                          h_init:BArray32.t, buf_init:BArray64.t,
                          ctx_init:BArray112.t) : BArray32.t * BArray64.t *
                                                  BArray32.t * BArray64.t *
                                                  trace = {
    var i:int;
    var x:W32.t;
    var t:W64.t;
    var i_init:bool;
    var x_init:bool;
    var t_init:bool;
    var trace___sha256_ctx_load:trace;
    trace___sha256_ctx_load <- [];
    i_init <- false;
    x_init <- false;
    t_init <- false;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, i_init)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, true)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert,
       ((0 <= ((16 + (4 * i)) * 1)) /\ ((((16 + (4 * i)) * 1) + 4) <= 112)))]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert, (BArray112.is_init ctx_init ((16 + (4 * i)) * 1) 4))]);
      x <- (BArray112.get32d ctx (16 + (4 * i)));
      x_init <- true;
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, i_init)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, true)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, x_init)]);
      h <- (BArray32.set32 h i x);
      h_init <- (BArray32.set32 h_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, i_init)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, true)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert,
       ((0 <= ((48 + (8 * i)) * 1)) /\ ((((48 + (8 * i)) * 1) + 8) <= 112)))]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert, (BArray112.is_init ctx_init ((48 + (8 * i)) * 1) 8))]);
      t <- (BArray112.get64d ctx (48 + (8 * i)));
      t_init <- true;
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, i_init)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, true)]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++
      [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 64)))]);
      trace___sha256_ctx_load <-
      (trace___sha256_ctx_load ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (8 * i) t);
      buf_init <-
      (BArray64.set64d buf_init (8 * i) (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (h, buf, h_init, buf_init, trace___sha256_ctx_load);
  }
  proc __sha512_ctx_load (h:BArray64.t, buf:BArray128.t, ctx:BArray208.t,
                          h_init:BArray64.t, buf_init:BArray128.t,
                          ctx_init:BArray208.t) : BArray64.t * BArray128.t *
                                                  BArray64.t * BArray128.t *
                                                  trace = {
    var i:int;
    var t:W64.t;
    var i_init:bool;
    var t_init:bool;
    var trace___sha512_ctx_load:trace;
    trace___sha512_ctx_load <- [];
    i_init <- false;
    t_init <- false;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, i_init)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, true)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert,
       ((0 <= ((16 + (8 * i)) * 1)) /\ ((((16 + (8 * i)) * 1) + 8) <= 208)))]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert, (BArray208.is_init ctx_init ((16 + (8 * i)) * 1) 8))]);
      t <- (BArray208.get64d ctx (16 + (8 * i)));
      t_init <- true;
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, i_init)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, true)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, t_init)]);
      h <- (BArray64.set64 h i t);
      h_init <- (BArray64.set64 h_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, i_init)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, true)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert,
       ((0 <= ((80 + (8 * i)) * 1)) /\ ((((80 + (8 * i)) * 1) + 8) <= 208)))]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert, (BArray208.is_init ctx_init ((80 + (8 * i)) * 1) 8))]);
      t <- (BArray208.get64d ctx (80 + (8 * i)));
      t_init <- true;
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, i_init)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, true)]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++
      [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 128)))]);
      trace___sha512_ctx_load <-
      (trace___sha512_ctx_load ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (8 * i) t);
      buf_init <-
      (BArray128.set64d buf_init (8 * i) (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (h, buf, h_init, buf_init, trace___sha512_ctx_load);
  }
  proc __sha256_ctx_init (ctx:BArray112.t, h:BArray32.t, tag:W64.t,
                          total:W64.t, ctx_init:BArray112.t,
                          h_init:BArray32.t) : BArray112.t * BArray112.t *
                                               trace = {
    var i:int;
    var x:W32.t;
    var z:W64.t;
    var tag_init:bool;
    var total_init:bool;
    var i_init:bool;
    var x_init:bool;
    var z_init:bool;
    var trace___sha256_ctx_init:trace;
    trace___sha256_ctx_init <- [];
    tag_init <- true;
    total_init <- true;
    i_init <- false;
    x_init <- false;
    z_init <- false;
    trace___sha256_ctx_init <- (trace___sha256_ctx_init ++ [(Assert, true)]);
    trace___sha256_ctx_init <-
    (trace___sha256_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 112)))]);
    trace___sha256_ctx_init <-
    (trace___sha256_ctx_init ++ [(Assert, tag_init)]);
    ctx <- (BArray112.set64d ctx 0 tag);
    ctx_init <-
    (BArray112.set64d ctx_init 0 (W64.of_int 18446744073709551615));
    trace___sha256_ctx_init <- (trace___sha256_ctx_init ++ [(Assert, true)]);
    trace___sha256_ctx_init <-
    (trace___sha256_ctx_init ++
    [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 112)))]);
    trace___sha256_ctx_init <-
    (trace___sha256_ctx_init ++ [(Assert, total_init)]);
    ctx <- (BArray112.set64d ctx 8 total);
    ctx_init <-
    (BArray112.set64d ctx_init 8 (W64.of_int 18446744073709551615));
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, i_init)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, true)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++
      [(Assert, (BArray32.is_init h_init (i * 4) 4))]);
      x <- (BArray32.get32 h i);
      x_init <- true;
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, i_init)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, true)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++
      [(Assert,
       ((0 <= ((16 + (4 * i)) * 1)) /\ ((((16 + (4 * i)) * 1) + 4) <= 112)))]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, x_init)]);
      ctx <- (BArray112.set32d ctx (16 + (4 * i)) x);
      ctx_init <-
      (BArray112.set32d ctx_init (16 + (4 * i)) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    z <- (W64.of_int 0);
    z_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, i_init)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, true)]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++
      [(Assert,
       ((0 <= ((48 + (8 * i)) * 1)) /\ ((((48 + (8 * i)) * 1) + 8) <= 112)))]);
      trace___sha256_ctx_init <-
      (trace___sha256_ctx_init ++ [(Assert, z_init)]);
      ctx <- (BArray112.set64d ctx (48 + (8 * i)) z);
      ctx_init <-
      (BArray112.set64d ctx_init (48 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (ctx, ctx_init, trace___sha256_ctx_init);
  }
  proc __sha512_ctx_init (ctx:BArray208.t, h:BArray64.t, tag:W64.t,
                          total:W64.t, ctx_init:BArray208.t,
                          h_init:BArray64.t) : BArray208.t * BArray208.t *
                                               trace = {
    var i:int;
    var t:W64.t;
    var z:W64.t;
    var tag_init:bool;
    var total_init:bool;
    var i_init:bool;
    var t_init:bool;
    var z_init:bool;
    var trace___sha512_ctx_init:trace;
    trace___sha512_ctx_init <- [];
    tag_init <- true;
    total_init <- true;
    i_init <- false;
    t_init <- false;
    z_init <- false;
    trace___sha512_ctx_init <- (trace___sha512_ctx_init ++ [(Assert, true)]);
    trace___sha512_ctx_init <-
    (trace___sha512_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 208)))]);
    trace___sha512_ctx_init <-
    (trace___sha512_ctx_init ++ [(Assert, tag_init)]);
    ctx <- (BArray208.set64d ctx 0 tag);
    ctx_init <-
    (BArray208.set64d ctx_init 0 (W64.of_int 18446744073709551615));
    trace___sha512_ctx_init <- (trace___sha512_ctx_init ++ [(Assert, true)]);
    trace___sha512_ctx_init <-
    (trace___sha512_ctx_init ++
    [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 208)))]);
    trace___sha512_ctx_init <-
    (trace___sha512_ctx_init ++ [(Assert, total_init)]);
    ctx <- (BArray208.set64d ctx 8 total);
    ctx_init <-
    (BArray208.set64d ctx_init 8 (W64.of_int 18446744073709551615));
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, i_init)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, true)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      t <- (BArray64.get64 h i);
      t_init <- true;
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, i_init)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, true)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++
      [(Assert,
       ((0 <= ((16 + (8 * i)) * 1)) /\ ((((16 + (8 * i)) * 1) + 8) <= 208)))]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, t_init)]);
      ctx <- (BArray208.set64d ctx (16 + (8 * i)) t);
      ctx_init <-
      (BArray208.set64d ctx_init (16 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    z <- (W64.of_int 0);
    z_init <- true;
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, i_init)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, true)]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++
      [(Assert,
       ((0 <= ((80 + (8 * i)) * 1)) /\ ((((80 + (8 * i)) * 1) + 8) <= 208)))]);
      trace___sha512_ctx_init <-
      (trace___sha512_ctx_init ++ [(Assert, z_init)]);
      ctx <- (BArray208.set64d ctx (80 + (8 * i)) z);
      ctx_init <-
      (BArray208.set64d ctx_init (80 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (ctx, ctx_init, trace___sha512_ctx_init);
  }
  proc _sha256_ctx_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t,
                           expect_0:W64.t, ms:W64.t, ctx_init:BArray112.t) : 
  BArray112.t * W64.t * W64.t * BArray112.t * trace = {
    var aux:BArray32.t;
    var aux_3:BArray32.t;
    var aux_0:BArray64.t;
    var aux_4:BArray64.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var room:W64.t;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var room_init:bool;
    var inlen_init:bool;
    var in_init:bool;
    var trace__sha256_ctx_update:trace;
    trace__sha256_ctx_update <- [];
    in_init <- true;
    inlen_init <- true;
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    room_init <- false;
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, true)]);
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 112)))]);
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray112_16.get_sub ctx_init (1 * 0)));
    trace__sha256_ctx_update <- (trace__sha256_ctx_update ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, tag_init)]);
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, true)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, true)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, true)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, total_init)]);
      (room, tmp__trace) <@ __sha2_room (total);
      trace__sha256_ctx_update <- (trace__sha256_ctx_update ++ tmp__trace);
      room_init <- true;
      status <- (W64.of_int 2);
      status_init <- true;
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, inlen_init)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, room_init)]);
      ok <- (inlen \ult room);
      ok_init <- true;
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
      if (ok) {
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf ok ms);
        ms_init <- true;
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++
        [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++
        [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++
        [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++
        [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, total_init)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, in_init)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, inlen_init)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, aux_2, aux_3, aux_4, tmp__trace) <@ _sha256_absorb_mem (
        (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48),
        total, in_0, inlen, ms, (SBArray112_32.get_sub ctx_init (4 * 4)),
        (SBArray112_64.get_sub ctx_init (1 * 48)));
        ctx <- (SBArray112_32.set_sub32 ctx 4 aux);
        ctx <- (SBArray112_64.set_sub8 ctx 48 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx_init <- (SBArray112_32.set_sub ctx_init (4 * 4) aux_3);
        ctx_init <- (SBArray112_64.set_sub ctx_init (1 * 48) aux_4);
        trace__sha256_ctx_update <- (trace__sha256_ctx_update ++ tmp__trace);
        total_init <- true;
        ms_init <- true;
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++
        [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 112)))]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, total_init)]);
        ctx <- (BArray112.set64d ctx 8 total);
        ctx_init <-
        (BArray112.set64d ctx_init 8 (W64.of_int 18446744073709551615));
        status <- (W64.of_int 0);
        status_init <- true;
      } else {
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, true)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
        trace__sha256_ctx_update <-
        (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf (! ok) ms);
        ms_init <- true;
      }
    } else {
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, true)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, true)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, ok_init)]);
      trace__sha256_ctx_update <-
      (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, status_init)]);
    trace__sha256_ctx_update <-
    (trace__sha256_ctx_update ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha256_ctx_update);
  }
  proc _sha512_ctx_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                           expect_0:W64.t, ms:W64.t, ctx_init:BArray208.t) : 
  BArray208.t * W64.t * W64.t * BArray208.t * trace = {
    var aux_0:BArray128.t;
    var aux_4:BArray128.t;
    var aux:BArray64.t;
    var aux_3:BArray64.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var room:W64.t;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var room_init:bool;
    var inlen_init:bool;
    var in_init:bool;
    var trace__sha512_ctx_update:trace;
    trace__sha512_ctx_update <- [];
    in_init <- true;
    inlen_init <- true;
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    room_init <- false;
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, true)]);
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray208_16.get_sub ctx_init (1 * 0)));
    trace__sha512_ctx_update <- (trace__sha512_ctx_update ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, tag_init)]);
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, true)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, true)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, true)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, total_init)]);
      (room, tmp__trace) <@ __sha2_room (total);
      trace__sha512_ctx_update <- (trace__sha512_ctx_update ++ tmp__trace);
      room_init <- true;
      status <- (W64.of_int 2);
      status_init <- true;
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, inlen_init)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, room_init)]);
      ok <- (inlen \ult room);
      ok_init <- true;
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
      if (ok) {
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf ok ms);
        ms_init <- true;
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++
        [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++
        [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++
        [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++
        [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, total_init)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, in_init)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, inlen_init)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, aux_2, aux_3, aux_4, tmp__trace) <@ _sha512_absorb_mem (
        (SBArray208_64.get_sub64 ctx 2), (SBArray208_128.get_sub8 ctx 80),
        total, in_0, inlen, ms, (SBArray208_64.get_sub ctx_init (8 * 2)),
        (SBArray208_128.get_sub ctx_init (1 * 80)));
        ctx <- (SBArray208_64.set_sub64 ctx 2 aux);
        ctx <- (SBArray208_128.set_sub8 ctx 80 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx_init <- (SBArray208_64.set_sub ctx_init (8 * 2) aux_3);
        ctx_init <- (SBArray208_128.set_sub ctx_init (1 * 80) aux_4);
        trace__sha512_ctx_update <- (trace__sha512_ctx_update ++ tmp__trace);
        total_init <- true;
        ms_init <- true;
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++
        [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 208)))]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, total_init)]);
        ctx <- (BArray208.set64d ctx 8 total);
        ctx_init <-
        (BArray208.set64d ctx_init 8 (W64.of_int 18446744073709551615));
        status <- (W64.of_int 0);
        status_init <- true;
      } else {
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, true)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
        trace__sha512_ctx_update <-
        (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf (! ok) ms);
        ms_init <- true;
      }
    } else {
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, true)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, true)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, ok_init)]);
      trace__sha512_ctx_update <-
      (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, status_init)]);
    trace__sha512_ctx_update <-
    (trace__sha512_ctx_update ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha512_ctx_update);
  }
  proc _sha224_ctx____ctx_finalize (ctx:BArray112.t, digest:BArray28.t,
                                    total:W64.t, ms:W64.t,
                                    ctx_init:BArray112.t,
                                    digest_init:BArray28.t) : BArray112.t *
                                                              BArray28.t *
                                                              W64.t *
                                                              BArray112.t *
                                                              BArray28.t *
                                                              trace = {
    var aux:BArray28.t;
    var aux_3:BArray28.t;
    var aux_0:BArray32.t;
    var aux_4:BArray32.t;
    var aux_1:BArray64.t;
    var aux_5:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha224_ctx____ctx_finalize:trace;
    trace__sha224_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha224___sha256_finalize (
    digest, (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48),
    total, ms, digest_init, (SBArray112_32.get_sub ctx_init (4 * 4)),
    (SBArray112_64.get_sub ctx_init (1 * 48)));
    digest <- aux;
    ctx <- (SBArray112_32.set_sub32 ctx 4 aux_0);
    ctx <- (SBArray112_64.set_sub8 ctx 48 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray112_32.set_sub ctx_init (4 * 4) aux_4);
    ctx_init <- (SBArray112_64.set_sub ctx_init (1 * 48) aux_5);
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha224_ctx____ctx_finalize <-
    (trace__sha224_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha224_ctx____ctx_finalize);
  }
  proc _sha224_ctx___sha2_ctx_final (ctx:BArray112.t, digest:BArray28.t,
                                     expect_0:W64.t, ms:W64.t,
                                     ctx_init:BArray112.t,
                                     digest_init:BArray28.t) : BArray112.t *
                                                               BArray28.t *
                                                               W64.t *
                                                               W64.t *
                                                               BArray112.t *
                                                               BArray28.t *
                                                               trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha224_ctx___sha2_ctx_final:trace;
    trace__sha224_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 112)))]);
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray112_16.get_sub ctx_init (1 * 0)));
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha224_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (112 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha224_ctx___sha2_ctx_final <-
        (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha224_ctx___sha2_ctx_final <-
        (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha224_ctx___sha2_ctx_final <-
        (trace__sha224_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 112)))]);
        trace__sha224_ctx___sha2_ctx_final <-
        (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray112.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray112.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha224_ctx___sha2_ctx_final <-
      (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha224_ctx___sha2_ctx_final <-
    (trace__sha224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha224_ctx___sha2_ctx_final);
  }
  proc _sha256_ctx____ctx_finalize (ctx:BArray112.t, digest:BArray32.t,
                                    total:W64.t, ms:W64.t,
                                    ctx_init:BArray112.t,
                                    digest_init:BArray32.t) : BArray112.t *
                                                              BArray32.t *
                                                              W64.t *
                                                              BArray112.t *
                                                              BArray32.t *
                                                              trace = {
    var aux:BArray32.t;
    var aux_0:BArray32.t;
    var aux_3:BArray32.t;
    var aux_4:BArray32.t;
    var aux_1:BArray64.t;
    var aux_5:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha256_ctx____ctx_finalize:trace;
    trace__sha256_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha256___sha256_finalize (
    digest, (SBArray112_32.get_sub32 ctx 4), (SBArray112_64.get_sub8 ctx 48),
    total, ms, digest_init, (SBArray112_32.get_sub ctx_init (4 * 4)),
    (SBArray112_64.get_sub ctx_init (1 * 48)));
    digest <- aux;
    ctx <- (SBArray112_32.set_sub32 ctx 4 aux_0);
    ctx <- (SBArray112_64.set_sub8 ctx 48 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray112_32.set_sub ctx_init (4 * 4) aux_4);
    ctx_init <- (SBArray112_64.set_sub ctx_init (1 * 48) aux_5);
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha256_ctx____ctx_finalize <-
    (trace__sha256_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha256_ctx____ctx_finalize);
  }
  proc _sha256_ctx___sha2_ctx_final (ctx:BArray112.t, digest:BArray32.t,
                                     expect_0:W64.t, ms:W64.t,
                                     ctx_init:BArray112.t,
                                     digest_init:BArray32.t) : BArray112.t *
                                                               BArray32.t *
                                                               W64.t *
                                                               W64.t *
                                                               BArray112.t *
                                                               BArray32.t *
                                                               trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha256_ctx___sha2_ctx_final:trace;
    trace__sha256_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 112)))]);
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray112_16.get_sub ctx_init (1 * 0)));
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha256_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (112 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha256_ctx___sha2_ctx_final <-
        (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha256_ctx___sha2_ctx_final <-
        (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha256_ctx___sha2_ctx_final <-
        (trace__sha256_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 112)))]);
        trace__sha256_ctx___sha2_ctx_final <-
        (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray112.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray112.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha256_ctx___sha2_ctx_final <-
      (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha256_ctx___sha2_ctx_final <-
    (trace__sha256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha256_ctx___sha2_ctx_final);
  }
  proc _sha384_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray48.t,
                                    total:W64.t, ms:W64.t,
                                    ctx_init:BArray208.t,
                                    digest_init:BArray48.t) : BArray208.t *
                                                              BArray48.t *
                                                              W64.t *
                                                              BArray208.t *
                                                              BArray48.t *
                                                              trace = {
    var aux_1:BArray128.t;
    var aux_5:BArray128.t;
    var aux:BArray48.t;
    var aux_3:BArray48.t;
    var aux_0:BArray64.t;
    var aux_4:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha384_ctx____ctx_finalize:trace;
    trace__sha384_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha384___sha512_finalize (
    digest, (SBArray208_64.get_sub64 ctx 2),
    (SBArray208_128.get_sub8 ctx 80), total, ms, digest_init,
    (SBArray208_64.get_sub ctx_init (8 * 2)),
    (SBArray208_128.get_sub ctx_init (1 * 80)));
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray208_64.set_sub ctx_init (8 * 2) aux_4);
    ctx_init <- (SBArray208_128.set_sub ctx_init (1 * 80) aux_5);
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha384_ctx____ctx_finalize <-
    (trace__sha384_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha384_ctx____ctx_finalize);
  }
  proc _sha384_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray48.t,
                                     expect_0:W64.t, ms:W64.t,
                                     ctx_init:BArray208.t,
                                     digest_init:BArray48.t) : BArray208.t *
                                                               BArray48.t *
                                                               W64.t *
                                                               W64.t *
                                                               BArray208.t *
                                                               BArray48.t *
                                                               trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha384_ctx___sha2_ctx_final:trace;
    trace__sha384_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray208_16.get_sub ctx_init (1 * 0)));
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha384_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha384_ctx___sha2_ctx_final <-
        (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha384_ctx___sha2_ctx_final <-
        (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha384_ctx___sha2_ctx_final <-
        (trace__sha384_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 208)))]);
        trace__sha384_ctx___sha2_ctx_final <-
        (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray208.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray208.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha384_ctx___sha2_ctx_final <-
      (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha384_ctx___sha2_ctx_final <-
    (trace__sha384_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha384_ctx___sha2_ctx_final);
  }
  proc _sha512_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray64.t,
                                    total:W64.t, ms:W64.t,
                                    ctx_init:BArray208.t,
                                    digest_init:BArray64.t) : BArray208.t *
                                                              BArray64.t *
                                                              W64.t *
                                                              BArray208.t *
                                                              BArray64.t *
                                                              trace = {
    var aux_1:BArray128.t;
    var aux_5:BArray128.t;
    var aux:BArray64.t;
    var aux_0:BArray64.t;
    var aux_3:BArray64.t;
    var aux_4:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha512_ctx____ctx_finalize:trace;
    trace__sha512_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha512___sha512_finalize (
    digest, (SBArray208_64.get_sub64 ctx 2),
    (SBArray208_128.get_sub8 ctx 80), total, ms, digest_init,
    (SBArray208_64.get_sub ctx_init (8 * 2)),
    (SBArray208_128.get_sub ctx_init (1 * 80)));
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray208_64.set_sub ctx_init (8 * 2) aux_4);
    ctx_init <- (SBArray208_128.set_sub ctx_init (1 * 80) aux_5);
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_ctx____ctx_finalize <-
    (trace__sha512_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha512_ctx____ctx_finalize);
  }
  proc _sha512_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray64.t,
                                     expect_0:W64.t, ms:W64.t,
                                     ctx_init:BArray208.t,
                                     digest_init:BArray64.t) : BArray208.t *
                                                               BArray64.t *
                                                               W64.t *
                                                               W64.t *
                                                               BArray208.t *
                                                               BArray64.t *
                                                               trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha512_ctx___sha2_ctx_final:trace;
    trace__sha512_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray208_16.get_sub ctx_init (1 * 0)));
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha512_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha512_ctx___sha2_ctx_final <-
        (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha512_ctx___sha2_ctx_final <-
        (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha512_ctx___sha2_ctx_final <-
        (trace__sha512_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 208)))]);
        trace__sha512_ctx___sha2_ctx_final <-
        (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray208.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray208.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_ctx___sha2_ctx_final <-
      (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha512_ctx___sha2_ctx_final <-
    (trace__sha512_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha512_ctx___sha2_ctx_final);
  }
  proc _sha512_224_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray28.t,
                                        total:W64.t, ms:W64.t,
                                        ctx_init:BArray208.t,
                                        digest_init:BArray28.t) : BArray208.t *
                                                                  BArray28.t *
                                                                  W64.t *
                                                                  BArray208.t *
                                                                  BArray28.t *
                                                                  trace = {
    var aux_1:BArray128.t;
    var aux_5:BArray128.t;
    var aux:BArray28.t;
    var aux_3:BArray28.t;
    var aux_0:BArray64.t;
    var aux_4:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha512_224_ctx____ctx_finalize:trace;
    trace__sha512_224_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha512_224___sha512_finalize (
    digest, (SBArray208_64.get_sub64 ctx 2),
    (SBArray208_128.get_sub8 ctx 80), total, ms, digest_init,
    (SBArray208_64.get_sub ctx_init (8 * 2)),
    (SBArray208_128.get_sub ctx_init (1 * 80)));
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray208_64.set_sub ctx_init (8 * 2) aux_4);
    ctx_init <- (SBArray208_128.set_sub ctx_init (1 * 80) aux_5);
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_224_ctx____ctx_finalize <-
    (trace__sha512_224_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha512_224_ctx____ctx_finalize);
  }
  proc _sha512_224_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray28.t,
                                         expect_0:W64.t, ms:W64.t,
                                         ctx_init:BArray208.t,
                                         digest_init:BArray28.t) : BArray208.t *
                                                                   BArray28.t *
                                                                   W64.t *
                                                                   W64.t *
                                                                   BArray208.t *
                                                                   BArray28.t *
                                                                   trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha512_224_ctx___sha2_ctx_final:trace;
    trace__sha512_224_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray208_16.get_sub ctx_init (1 * 0)));
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha512_224_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha512_224_ctx___sha2_ctx_final <-
        (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha512_224_ctx___sha2_ctx_final <-
        (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha512_224_ctx___sha2_ctx_final <-
        (trace__sha512_224_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 208)))]);
        trace__sha512_224_ctx___sha2_ctx_final <-
        (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray208.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray208.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_224_ctx___sha2_ctx_final <-
      (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha512_224_ctx___sha2_ctx_final <-
    (trace__sha512_224_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha512_224_ctx___sha2_ctx_final);
  }
  proc _sha512_256_ctx____ctx_finalize (ctx:BArray208.t, digest:BArray32.t,
                                        total:W64.t, ms:W64.t,
                                        ctx_init:BArray208.t,
                                        digest_init:BArray32.t) : BArray208.t *
                                                                  BArray32.t *
                                                                  W64.t *
                                                                  BArray208.t *
                                                                  BArray32.t *
                                                                  trace = {
    var aux_1:BArray128.t;
    var aux_5:BArray128.t;
    var aux:BArray32.t;
    var aux_3:BArray32.t;
    var aux_0:BArray64.t;
    var aux_4:BArray64.t;
    var aux_2:W64.t;
    var total_init:bool;
    var ms_init:bool;
    var trace__sha512_256_ctx____ctx_finalize:trace;
    trace__sha512_256_ctx____ctx_finalize <- [];
    total_init <- true;
    ms_init <- true;
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++ [(Assert, true)]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++
    [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++ [(Assert, total_init)]);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ _sha512_256___sha512_finalize (
    digest, (SBArray208_64.get_sub64 ctx 2),
    (SBArray208_128.get_sub8 ctx 80), total, ms, digest_init,
    (SBArray208_64.get_sub ctx_init (8 * 2)),
    (SBArray208_128.get_sub ctx_init (1 * 80)));
    digest <- aux;
    ctx <- (SBArray208_64.set_sub64 ctx 2 aux_0);
    ctx <- (SBArray208_128.set_sub8 ctx 80 aux_1);
    ms <- aux_2;
    digest_init <- aux_3;
    ctx_init <- (SBArray208_64.set_sub ctx_init (8 * 2) aux_4);
    ctx_init <- (SBArray208_128.set_sub ctx_init (1 * 80) aux_5);
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_256_ctx____ctx_finalize <-
    (trace__sha512_256_ctx____ctx_finalize ++ [(Assert, ms_init)]);
    return (ctx, digest, ms, ctx_init, digest_init,
           trace__sha512_256_ctx____ctx_finalize);
  }
  proc _sha512_256_ctx___sha2_ctx_final (ctx:BArray208.t, digest:BArray32.t,
                                         expect_0:W64.t, ms:W64.t,
                                         ctx_init:BArray208.t,
                                         digest_init:BArray32.t) : BArray208.t *
                                                                   BArray32.t *
                                                                   W64.t *
                                                                   W64.t *
                                                                   BArray208.t *
                                                                   BArray32.t *
                                                                   trace = {
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var status_init:bool;
    var expect_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha512_256_ctx___sha2_ctx_final:trace;
    trace__sha512_256_ctx___sha2_ctx_final <- [];
    expect_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray208_16.get_sub ctx_init (1 * 0)));
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, tag_init)]);
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, total_init)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      (ctx, digest, ms, ctx_init, digest_init, tmp__trace) <@ _sha512_256_ctx____ctx_finalize (
      ctx, digest, total, ms, ctx_init, digest_init);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (208 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha512_256_ctx___sha2_ctx_final <-
        (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, i_init)]);
        trace__sha512_256_ctx___sha2_ctx_final <-
        (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
        trace__sha512_256_ctx___sha2_ctx_final <-
        (trace__sha512_256_ctx___sha2_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 208)))]);
        trace__sha512_256_ctx___sha2_ctx_final <-
        (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray208.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray208.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, true)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_256_ctx___sha2_ctx_final <-
      (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, status_init)]);
    trace__sha512_256_ctx___sha2_ctx_final <-
    (trace__sha512_256_ctx___sha2_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, digest, status, ms, ctx_init, digest_init,
           trace__sha512_256_ctx___sha2_ctx_final);
  }
  proc __hmac_sha256_ctx_init (ctx:BArray144.t, key:W64.t, keylen:W64.t,
                               ms:W64.t, ctx_init:BArray144.t) : BArray144.t *
                                                                 W64.t *
                                                                 BArray144.t *
                                                                 trace = {
    var aux:BArray112.t;
    var aux_0:BArray112.t;
    var k0:BArray64.t;
    var inner:BArray32.t;
    var outer:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    var i:int;
    var x:W32.t;
    var key_init:bool;
    var keylen_init:bool;
    var ms_init:bool;
    var k0_init:BArray64.t;
    var inner_init:BArray32.t;
    var outer_init:BArray32.t;
    var tag_init:bool;
    var total_init:bool;
    var i_init:bool;
    var x_init:bool;
    var trace___hmac_sha256_ctx_init:trace;
    inner <- witness;
    inner_init <- witness;
    k0 <- witness;
    k0_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace___hmac_sha256_ctx_init <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- true;
    k0_init <- (BArray64.init_arr (W8.of_int 0));
    inner_init <- (BArray32.init_arr (W8.of_int 0));
    outer_init <- (BArray32.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    i_init <- false;
    x_init <- false;
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, key_init)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, keylen_init)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ _hmac_sha256_keyblock_mem (k0, key,
    keylen, ms, k0_init);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, ms_init)]);
    (inner, outer, ms, inner_init, outer_init, tmp__trace) <@ __hmac_sha256_init (
    inner, outer, k0, ms, inner_init, outer_init, k0_init);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, ms_init)]);
    ctx <- (protect_ptr ctx ms);
    ctx_init <- (BArray144.init_arr (W8.of_int 255));
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (7);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 64);
    total_init <- true;
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 112) <= 144)))]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 112) <= 144)))]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, tag_init)]);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, total_init)]);
    (aux, aux_0, tmp__trace) <@ __sha256_ctx_init ((SBArray144_112.get_sub8
                                                   ctx 0),
    inner, tag, total, (SBArray144_112.get_sub ctx_init (1 * 0)),
    inner_init);
    ctx <- (SBArray144_112.set_sub8 ctx 0 aux);
    ctx_init <- (SBArray144_112.set_sub ctx_init (1 * 0) aux_0);
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ tmp__trace);
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++ [(Assert, i_init)]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++
      [(Assert, (BArray32.is_init outer_init (i * 4) 4))]);
      x <- (BArray32.get32 outer i);
      x_init <- true;
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++ [(Assert, i_init)]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++
      [(Assert,
       ((0 <= ((112 + (4 * i)) * 1)) /\ ((((112 + (4 * i)) * 1) + 4) <= 144)))]);
      trace___hmac_sha256_ctx_init <-
      (trace___hmac_sha256_ctx_init ++ [(Assert, x_init)]);
      ctx <- (BArray144.set32d ctx (112 + (4 * i)) x);
      ctx_init <-
      (BArray144.set32d ctx_init (112 + (4 * i)) (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace___hmac_sha256_ctx_init <-
    (trace___hmac_sha256_ctx_init ++ [(Assert, ms_init)]);
    return (ctx, ms, ctx_init, trace___hmac_sha256_ctx_init);
  }
  proc __hmac_sha512_ctx_init (ctx:BArray272.t, key:W64.t, keylen:W64.t,
                               ms:W64.t, ctx_init:BArray272.t) : BArray272.t *
                                                                 W64.t *
                                                                 BArray272.t *
                                                                 trace = {
    var aux:BArray208.t;
    var aux_0:BArray208.t;
    var k0:BArray128.t;
    var inner:BArray64.t;
    var outer:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var i:int;
    var t:W64.t;
    var key_init:bool;
    var keylen_init:bool;
    var ms_init:bool;
    var k0_init:BArray128.t;
    var inner_init:BArray64.t;
    var outer_init:BArray64.t;
    var tag_init:bool;
    var total_init:bool;
    var i_init:bool;
    var t_init:bool;
    var trace___hmac_sha512_ctx_init:trace;
    inner <- witness;
    inner_init <- witness;
    k0 <- witness;
    k0_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace___hmac_sha512_ctx_init <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- true;
    k0_init <- (BArray128.init_arr (W8.of_int 0));
    inner_init <- (BArray64.init_arr (W8.of_int 0));
    outer_init <- (BArray64.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    i_init <- false;
    t_init <- false;
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, key_init)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, keylen_init)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ _hmac_sha512_keyblock_mem (k0, key,
    keylen, ms, k0_init);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, ms_init)]);
    (inner, outer, ms, inner_init, outer_init, tmp__trace) <@ __hmac_sha512_init (
    inner, outer, k0, ms, inner_init, outer_init, k0_init);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ tmp__trace);
    ms_init <- true;
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, ms_init)]);
    ctx <- (protect_ptr ctx ms);
    ctx_init <- (BArray272.init_arr (W8.of_int 255));
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (8);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 128);
    total_init <- true;
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 208) <= 272)))]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 208) <= 272)))]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, tag_init)]);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, total_init)]);
    (aux, aux_0, tmp__trace) <@ __sha512_ctx_init ((SBArray272_208.get_sub8
                                                   ctx 0),
    inner, tag, total, (SBArray272_208.get_sub ctx_init (1 * 0)),
    inner_init);
    ctx <- (SBArray272_208.set_sub8 ctx 0 aux);
    ctx_init <- (SBArray272_208.set_sub ctx_init (1 * 0) aux_0);
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ tmp__trace);
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++ [(Assert, i_init)]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++
      [(Assert, (BArray64.is_init outer_init (i * 8) 8))]);
      t <- (BArray64.get64 outer i);
      t_init <- true;
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++ [(Assert, i_init)]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++
      [(Assert,
       ((0 <= ((208 + (8 * i)) * 1)) /\ ((((208 + (8 * i)) * 1) + 8) <= 272)))]);
      trace___hmac_sha512_ctx_init <-
      (trace___hmac_sha512_ctx_init ++ [(Assert, t_init)]);
      ctx <- (BArray272.set64d ctx (208 + (8 * i)) t);
      ctx_init <-
      (BArray272.set64d ctx_init (208 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    trace___hmac_sha512_ctx_init <-
    (trace___hmac_sha512_ctx_init ++ [(Assert, ms_init)]);
    return (ctx, ms, ctx_init, trace___hmac_sha512_ctx_init);
  }
  proc __hmac_sha256_ctx_final (ctx:BArray144.t, out:BArray32.t, ms:W64.t,
                                ctx_init:BArray144.t, out_init:BArray32.t) : 
  BArray144.t * BArray32.t * W64.t * W64.t * BArray144.t * BArray32.t * trace = {
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
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var inner_init:BArray32.t;
    var buf_init:BArray64.t;
    var i_init:bool;
    var x_init:bool;
    var outer_init:BArray32.t;
    var mac_init:BArray32.t;
    var t_init:bool;
    var z_init:bool;
    var trace___hmac_sha256_ctx_final:trace;
    buf <- witness;
    buf_init <- witness;
    inner <- witness;
    inner_init <- witness;
    mac <- witness;
    mac_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace___hmac_sha256_ctx_final <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    inner_init <- (BArray32.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    i_init <- false;
    x_init <- false;
    outer_init <- (BArray32.init_arr (W8.of_int 0));
    mac_init <- (BArray32.init_arr (W8.of_int 0));
    t_init <- false;
    z_init <- false;
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 144)))]);
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray144_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray144_16.get_sub ctx_init (1 * 0)));
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (7);
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, tag_init)]);
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ok_init)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++
      [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 112) <= 144)))]);
      (inner, buf, inner_init, buf_init, tmp__trace) <@ __sha256_ctx_load (
      inner, buf, (SBArray144_112.get_sub8 ctx 0), inner_init, buf_init,
      (SBArray144_112.get_sub ctx_init (1 * 0)));
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ tmp__trace);
      i_init <- true;
      i <- 0;
      while ((i < 8)) {
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert,
         ((0 <= ((112 + (4 * i)) * 1)) /\
         ((((112 + (4 * i)) * 1) + 4) <= 144)))]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, (BArray144.is_init ctx_init ((112 + (4 * i)) * 1) 4))]);
        x <- (BArray144.get32d ctx (112 + (4 * i)));
        x_init <- true;
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, x_init)]);
        outer <- (BArray32.set32 outer i x);
        outer_init <- (BArray32.set32 outer_init i (W32.of_int 4294967295));
        i <- (i + 1);
      }
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, total_init)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
      (mac, inner, buf, ms, mac_init, inner_init, buf_init, tmp__trace) <@ 
      __hmac_sha256_finalize (mac, inner, buf, total, outer, ms, mac_init,
      inner_init, buf_init, outer_init);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ tmp__trace);
      ms_init <- true;
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
      ctx <- (protect_ptr ctx ms);
      ctx_init <- (BArray144.init_arr (W8.of_int 255));
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray32.init_arr (W8.of_int 255));
      i_init <- true;
      i <- 0;
      while ((i < 4)) {
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 32)))]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, (BArray32.is_init mac_init (i * 8) 8))]);
        t <- (BArray32.get64 mac i);
        t_init <- true;
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 32)))]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, t_init)]);
        out <- (BArray32.set64 out i t);
        out_init <-
        (BArray32.set64 out_init i (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (144 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 144)))]);
        trace___hmac_sha256_ctx_final <-
        (trace___hmac_sha256_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray144.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray144.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ok_init)]);
      trace___hmac_sha256_ctx_final <-
      (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, status_init)]);
    trace___hmac_sha256_ctx_final <-
    (trace___hmac_sha256_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, out, status, ms, ctx_init, out_init,
           trace___hmac_sha256_ctx_final);
  }
  proc __hmac_sha512_ctx_final (ctx:BArray272.t, out:BArray64.t, ms:W64.t,
                                ctx_init:BArray272.t, out_init:BArray64.t) : 
  BArray272.t * BArray64.t * W64.t * W64.t * BArray272.t * BArray64.t * trace = {
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
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var inner_init:BArray64.t;
    var buf_init:BArray128.t;
    var i_init:bool;
    var t_init:bool;
    var outer_init:BArray64.t;
    var mac_init:BArray64.t;
    var z_init:bool;
    var trace___hmac_sha512_ctx_final:trace;
    buf <- witness;
    buf_init <- witness;
    inner <- witness;
    inner_init <- witness;
    mac <- witness;
    mac_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace___hmac_sha512_ctx_final <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    inner_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    i_init <- false;
    t_init <- false;
    outer_init <- (BArray64.init_arr (W8.of_int 0));
    mac_init <- (BArray64.init_arr (W8.of_int 0));
    z_init <- false;
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 272)))]);
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray272_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray272_16.get_sub ctx_init (1 * 0)));
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (8);
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, tag_init)]);
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ok_init)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++
      [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 208) <= 272)))]);
      (inner, buf, inner_init, buf_init, tmp__trace) <@ __sha512_ctx_load (
      inner, buf, (SBArray272_208.get_sub8 ctx 0), inner_init, buf_init,
      (SBArray272_208.get_sub ctx_init (1 * 0)));
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ tmp__trace);
      i_init <- true;
      i <- 0;
      while ((i < 8)) {
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert,
         ((0 <= ((208 + (8 * i)) * 1)) /\
         ((((208 + (8 * i)) * 1) + 8) <= 272)))]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, (BArray272.is_init ctx_init ((208 + (8 * i)) * 1) 8))]);
        t <- (BArray272.get64d ctx (208 + (8 * i)));
        t_init <- true;
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, t_init)]);
        outer <- (BArray64.set64 outer i t);
        outer_init <-
        (BArray64.set64 outer_init i (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, total_init)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
      (mac, inner, buf, ms, mac_init, inner_init, buf_init, tmp__trace) <@ 
      __hmac_sha512_finalize (mac, inner, buf, total, outer, ms, mac_init,
      inner_init, buf_init, outer_init);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ tmp__trace);
      ms_init <- true;
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
      ctx <- (protect_ptr ctx ms);
      ctx_init <- (BArray272.init_arr (W8.of_int 255));
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray64.init_arr (W8.of_int 255));
      i_init <- true;
      i <- 0;
      while ((i < 8)) {
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, (BArray64.is_init mac_init (i * 8) 8))]);
        t <- (BArray64.get64 mac i);
        t_init <- true;
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, t_init)]);
        out <- (BArray64.set64 out i t);
        out_init <-
        (BArray64.set64 out_init i (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (272 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, i_init)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 272)))]);
        trace___hmac_sha512_ctx_final <-
        (trace___hmac_sha512_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray272.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray272.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, true)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ok_init)]);
      trace___hmac_sha512_ctx_final <-
      (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, status_init)]);
    trace___hmac_sha512_ctx_final <-
    (trace___hmac_sha512_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, out, status, ms, ctx_init, out_init,
           trace___hmac_sha512_ctx_final);
  }
  proc _hmac_sha256_mem (out:BArray32.t, key:W64.t, keylen:W64.t, msg:W64.t,
                         msglen:W64.t, ms:W64.t, out_init:BArray32.t) : 
  BArray32.t * W64.t * BArray32.t * trace = {
    var k0:BArray64.t;
    var inner:BArray32.t;
    var outer:BArray32.t;
    var total:W64.t;
    var buf:BArray64.t;
    var msg_init:bool;
    var msglen_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var ms_init:bool;
    var k0_init:BArray64.t;
    var inner_init:BArray32.t;
    var outer_init:BArray32.t;
    var total_init:bool;
    var buf_init:BArray64.t;
    var trace__hmac_sha256_mem:trace;
    buf <- witness;
    buf_init <- witness;
    inner <- witness;
    inner_init <- witness;
    k0 <- witness;
    k0_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace__hmac_sha256_mem <- [];
    key_init <- true;
    keylen_init <- true;
    msg_init <- true;
    msglen_init <- true;
    ms_init <- true;
    k0_init <- (BArray64.init_arr (W8.of_int 0));
    inner_init <- (BArray32.init_arr (W8.of_int 0));
    outer_init <- (BArray32.init_arr (W8.of_int 0));
    total_init <- false;
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msglen_init)]);
    (* Erased call to spill *)
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, key_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, keylen_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ _hmac_sha256_keyblock_mem (k0, key,
    keylen, ms, k0_init);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    (inner, outer, ms, inner_init, outer_init, tmp__trace) <@ __hmac_sha256_init (
    inner, outer, k0, ms, inner_init, outer_init, k0_init);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msglen_init)]);
    (* Erased call to unspill *)
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    msg <- (protect_64 msg ms);
    msg_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msglen_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    msglen <- (protect_64 msglen ms);
    msglen_init <- true;
    total <- (W64.of_int 64);
    total_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, total_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, msglen_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ _sha256_absorb_mem (
    inner, buf, total, msg, msglen, ms, inner_init, buf_init);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, total_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ __hmac_sha256_outer (
    inner, buf, total, outer, ms, inner_init, buf_init, outer_init);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ [(Assert, true)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, total_init)]);
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    (out, inner, buf, ms, out_init, inner_init, buf_init, tmp__trace) <@ 
    _sha256___sha256_finalize (out, inner, buf, total, ms, out_init,
    inner_init, buf_init);
    trace__hmac_sha256_mem <- (trace__hmac_sha256_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha256_mem <-
    (trace__hmac_sha256_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__hmac_sha256_mem);
  }
  proc _hmac_sha512_mem (out:BArray64.t, key:W64.t, keylen:W64.t, msg:W64.t,
                         msglen:W64.t, ms:W64.t, out_init:BArray64.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var k0:BArray128.t;
    var inner:BArray64.t;
    var outer:BArray64.t;
    var total:W64.t;
    var buf:BArray128.t;
    var msg_init:bool;
    var msglen_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var ms_init:bool;
    var k0_init:BArray128.t;
    var inner_init:BArray64.t;
    var outer_init:BArray64.t;
    var total_init:bool;
    var buf_init:BArray128.t;
    var trace__hmac_sha512_mem:trace;
    buf <- witness;
    buf_init <- witness;
    inner <- witness;
    inner_init <- witness;
    k0 <- witness;
    k0_init <- witness;
    outer <- witness;
    outer_init <- witness;
    trace__hmac_sha512_mem <- [];
    key_init <- true;
    keylen_init <- true;
    msg_init <- true;
    msglen_init <- true;
    ms_init <- true;
    k0_init <- (BArray128.init_arr (W8.of_int 0));
    inner_init <- (BArray64.init_arr (W8.of_int 0));
    outer_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msglen_init)]);
    (* Erased call to spill *)
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, key_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, keylen_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    (k0, ms, k0_init, tmp__trace) <@ _hmac_sha512_keyblock_mem (k0, key,
    keylen, ms, k0_init);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    (inner, outer, ms, inner_init, outer_init, tmp__trace) <@ __hmac_sha512_init (
    inner, outer, k0, ms, inner_init, outer_init, k0_init);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msglen_init)]);
    (* Erased call to unspill *)
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    msg <- (protect_64 msg ms);
    msg_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msglen_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    msglen <- (protect_64 msglen ms);
    msglen_init <- true;
    total <- (W64.of_int 128);
    total_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, total_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msg_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, msglen_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ _sha512_absorb_mem (
    inner, buf, total, msg, msglen, ms, inner_init, buf_init);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, total_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    (inner, buf, total, ms, inner_init, buf_init, tmp__trace) <@ __hmac_sha512_outer (
    inner, buf, total, outer, ms, inner_init, buf_init, outer_init);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ [(Assert, true)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, total_init)]);
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    (out, inner, buf, ms, out_init, inner_init, buf_init, tmp__trace) <@ 
    _sha512___sha512_finalize (out, inner, buf, total, ms, out_init,
    inner_init, buf_init);
    trace__hmac_sha512_mem <- (trace__hmac_sha512_mem ++ tmp__trace);
    ms_init <- true;
    trace__hmac_sha512_mem <-
    (trace__hmac_sha512_mem ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__hmac_sha512_mem);
  }
  proc __sha256_x8_tr4 (a:W128.t, b:W128.t, c:W128.t, d:W128.t) : W128.t *
                                                                  W128.t *
                                                                  W128.t *
                                                                  W128.t *
                                                                  trace = {
    var t0:W128.t;
    var t1:W128.t;
    var t2:W128.t;
    var t3:W128.t;
    var a_init:bool;
    var b_init:bool;
    var t0_init:bool;
    var t1_init:bool;
    var c_init:bool;
    var d_init:bool;
    var t2_init:bool;
    var t3_init:bool;
    var trace___sha256_x8_tr4:trace;
    trace___sha256_x8_tr4 <- [];
    a_init <- true;
    b_init <- true;
    c_init <- true;
    d_init <- true;
    t0_init <- false;
    t1_init <- false;
    t2_init <- false;
    t3_init <- false;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, a_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, b_init)]);
    t0 <- (VTRN1_4u32 a b);
    t0_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, a_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, b_init)]);
    t1 <- (VTRN2_4u32 a b);
    t1_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, c_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, d_init)]);
    t2 <- (VTRN1_4u32 c d);
    t2_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, c_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, d_init)]);
    t3 <- (VTRN2_4u32 c d);
    t3_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t0_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t2_init)]);
    a <- (VTRN1_2u64 t0 t2);
    a_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t1_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t3_init)]);
    b <- (VTRN1_2u64 t1 t3);
    b_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t0_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t2_init)]);
    c <- (VTRN2_2u64 t0 t2);
    c_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, true)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t1_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, t3_init)]);
    d <- (VTRN2_2u64 t1 t3);
    d_init <- true;
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, a_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, b_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, c_init)]);
    trace___sha256_x8_tr4 <- (trace___sha256_x8_tr4 ++ [(Assert, d_init)]);
    return (a, b, c, d, trace___sha256_x8_tr4);
  }
  proc __sha256_x8_load_half (h8:BArray256.t, f:int, h8_init:BArray256.t) : 
  BArray128.t * BArray128.t * trace = {
    var st:BArray128.t;
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var c:W128.t;
    var d:W128.t;
    var q_init:bool;
    var f_init:bool;
    var a_init:bool;
    var b_init:bool;
    var c_init:bool;
    var d_init:bool;
    var st_init:BArray128.t;
    var trace___sha256_x8_load_half:trace;
    st <- witness;
    st_init <- witness;
    trace___sha256_x8_load_half <- [];
    f_init <- true;
    st_init <- (BArray128.init_arr (W8.of_int 0));
    q_init <- false;
    a_init <- false;
    b_init <- false;
    c_init <- false;
    d_init <- false;
    q_init <- true;
    q <- 0;
    while ((q < 2)) {
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, f_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       ((0 <= (((2 * (4 * q)) + f) * 16)) /\
       (((((2 * (4 * q)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert, (BArray256.is_init h8_init (((2 * (4 * q)) + f) * 16) 16))]);
      a <- (BArray256.get128 h8 ((2 * (4 * q)) + f));
      a_init <- true;
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, f_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 1)) + f) * 16)) /\
       (((((2 * ((4 * q) + 1)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       (BArray256.is_init h8_init (((2 * ((4 * q) + 1)) + f) * 16) 16))]);
      b <- (BArray256.get128 h8 ((2 * ((4 * q) + 1)) + f));
      b_init <- true;
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, f_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 2)) + f) * 16)) /\
       (((((2 * ((4 * q) + 2)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       (BArray256.is_init h8_init (((2 * ((4 * q) + 2)) + f) * 16) 16))]);
      c <- (BArray256.get128 h8 ((2 * ((4 * q) + 2)) + f));
      c_init <- true;
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, f_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 3)) + f) * 16)) /\
       (((((2 * ((4 * q) + 3)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert,
       (BArray256.is_init h8_init (((2 * ((4 * q) + 3)) + f) * 16) 16))]);
      d <- (BArray256.get128 h8 ((2 * ((4 * q) + 3)) + f));
      d_init <- true;
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, a_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, b_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, c_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, d_init)]);
      (a, b, c, d, tmp__trace) <@ __sha256_x8_tr4 (a, b, c, d);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ tmp__trace);
      a_init <- true;
      b_init <- true;
      c_init <- true;
      d_init <- true;
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert, ((0 <= (q * 16)) /\ (((q * 16) + 16) <= 128)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, a_init)]);
      st <- (BArray128.set128 st q a);
      st_init <-
      (BArray128.set128 st_init q
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert, ((0 <= ((2 + q) * 16)) /\ ((((2 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, b_init)]);
      st <- (BArray128.set128 st (2 + q) b);
      st_init <-
      (BArray128.set128 st_init (2 + q)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert, ((0 <= ((4 + q) * 16)) /\ ((((4 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, c_init)]);
      st <- (BArray128.set128 st (4 + q) c);
      st_init <-
      (BArray128.set128 st_init (4 + q)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, q_init)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, true)]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++
      [(Assert, ((0 <= ((6 + q) * 16)) /\ ((((6 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_load_half <-
      (trace___sha256_x8_load_half ++ [(Assert, d_init)]);
      st <- (BArray128.set128 st (6 + q) d);
      st_init <-
      (BArray128.set128 st_init (6 + q)
      (W128.of_int 340282366920938463463374607431768211455));
      q <- (q + 1);
    }
    return (st, st_init, trace___sha256_x8_load_half);
  }
  proc __sha256_x8_store_half (h8:BArray256.t, st:BArray128.t, f:int,
                               h8_init:BArray256.t, st_init:BArray128.t) : 
  BArray256.t * BArray256.t * trace = {
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var c:W128.t;
    var d:W128.t;
    var q_init:bool;
    var a_init:bool;
    var b_init:bool;
    var c_init:bool;
    var d_init:bool;
    var f_init:bool;
    var trace___sha256_x8_store_half:trace;
    trace___sha256_x8_store_half <- [];
    f_init <- true;
    q_init <- false;
    a_init <- false;
    b_init <- false;
    c_init <- false;
    d_init <- false;
    q_init <- true;
    q <- 0;
    while ((q < 2)) {
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, ((0 <= (q * 16)) /\ (((q * 16) + 16) <= 128)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, (BArray128.is_init st_init (q * 16) 16))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, ((0 <= ((2 + q) * 16)) /\ ((((2 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, (BArray128.is_init st_init ((2 + q) * 16) 16))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, ((0 <= ((4 + q) * 16)) /\ ((((4 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, (BArray128.is_init st_init ((4 + q) * 16) 16))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, ((0 <= ((6 + q) * 16)) /\ ((((6 + q) * 16) + 16) <= 128)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert, (BArray128.is_init st_init ((6 + q) * 16) 16))]);
      (a, b, c, d, tmp__trace) <@ __sha256_x8_tr4 ((BArray128.get128 st q),
      (BArray128.get128 st (2 + q)), (BArray128.get128 st (4 + q)),
      (BArray128.get128 st (6 + q)));
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ tmp__trace);
      a_init <- true;
      b_init <- true;
      c_init <- true;
      d_init <- true;
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, f_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert,
       ((0 <= (((2 * (4 * q)) + f) * 16)) /\
       (((((2 * (4 * q)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, a_init)]);
      h8 <- (BArray256.set128 h8 ((2 * (4 * q)) + f) a);
      h8_init <-
      (BArray256.set128 h8_init ((2 * (4 * q)) + f)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, f_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 1)) + f) * 16)) /\
       (((((2 * ((4 * q) + 1)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, b_init)]);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 1)) + f) b);
      h8_init <-
      (BArray256.set128 h8_init ((2 * ((4 * q) + 1)) + f)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, f_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 2)) + f) * 16)) /\
       (((((2 * ((4 * q) + 2)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, c_init)]);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 2)) + f) c);
      h8_init <-
      (BArray256.set128 h8_init ((2 * ((4 * q) + 2)) + f)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, q_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, f_init)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, true)]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++
      [(Assert,
       ((0 <= (((2 * ((4 * q) + 3)) + f) * 16)) /\
       (((((2 * ((4 * q) + 3)) + f) * 16) + 16) <= 256)))]);
      trace___sha256_x8_store_half <-
      (trace___sha256_x8_store_half ++ [(Assert, d_init)]);
      h8 <- (BArray256.set128 h8 ((2 * ((4 * q) + 3)) + f) d);
      h8_init <-
      (BArray256.set128 h8_init ((2 * ((4 * q) + 3)) + f)
      (W128.of_int 340282366920938463463374607431768211455));
      q <- (q + 1);
    }
    return (h8, h8_init, trace___sha256_x8_store_half);
  }
  proc __sha256_x8_block2 (st:BArray128.t, r:int, m:BArray128.t,
                           k:BArray256.t, st_init:BArray128.t,
                           m_init:BArray128.t, k_init:BArray256.t) : 
  BArray128.t * BArray128.t * BArray128.t * BArray128.t * trace = {
    var j:int;
    var s0:BArray64.t;
    var g:int;
    var kv:W128.t;
    var l:int;
    var wk:BArray32.t;
    var prev:BArray32.t;
    var j_init:bool;
    var r_init:bool;
    var s0_init:BArray64.t;
    var g_init:bool;
    var kv_init:bool;
    var l_init:bool;
    var wk_init:BArray32.t;
    var prev_init:BArray32.t;
    var trace___sha256_x8_block2:trace;
    prev <- witness;
    prev_init <- witness;
    s0 <- witness;
    s0_init <- witness;
    wk <- witness;
    wk_init <- witness;
    trace___sha256_x8_block2 <- [];
    r_init <- true;
    j_init <- false;
    s0_init <- (BArray64.init_arr (W8.of_int 0));
    g_init <- false;
    kv_init <- false;
    l_init <- false;
    wk_init <- (BArray32.init_arr (W8.of_int 0));
    prev_init <- (BArray32.init_arr (W8.of_int 0));
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, j_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, j_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert,
       ((0 <= (((4 * r) + j) * 16)) /\ (((((4 * r) + j) * 16) + 16) <= 128)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, (BArray128.is_init st_init (((4 * r) + j) * 16) 16))]);
      s0 <- (BArray64.set128 s0 j (BArray128.get128 st ((4 * r) + j)));
      s0_init <-
      (BArray64.set128 s0_init j
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    g_init <- true;
    g <- 0;
    while ((g < 16)) {
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 256)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, (BArray256.is_init k_init (g * 16) 16))]);
      kv <- (BArray256.get128 k g);
      kv_init <- true;
      l_init <- true;
      l <- 0;
      while ((l < 2)) {
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, ((0 <= (l * 16)) /\ (((l * 16) + 16) <= 32)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, kv_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= (((4 * l) + (g %% 4)) * 16)) /\
         (((((4 * l) + (g %% 4)) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray128.is_init m_init (((4 * l) + (g %% 4)) * 16) 16))]);
        wk <-
        (BArray32.set128 wk l
        (VADD_4u32 kv (BArray128.get128 m ((4 * l) + (g %% 4)))));
        wk_init <-
        (BArray32.set128 wk_init l
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
        if ((g < 12)) {
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + (g %% 4)) * 16)) /\
           (((((4 * l) + (g %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + (g %% 4)) * 16)) /\
           (((((4 * l) + (g %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           (BArray128.is_init m_init (((4 * l) + (g %% 4)) * 16) 16))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + ((g + 1) %% 4)) * 16)) /\
           (((((4 * l) + ((g + 1) %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           (BArray128.is_init m_init (((4 * l) + ((g + 1) %% 4)) * 16) 16))]);
          m <-
          (BArray128.set128 m ((4 * l) + (g %% 4))
          (SHA256SU0 (BArray128.get128 m ((4 * l) + (g %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 1) %% 4)))));
          m_init <-
          (BArray128.set128 m_init ((4 * l) + (g %% 4))
          (W128.of_int 340282366920938463463374607431768211455));
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + (g %% 4)) * 16)) /\
           (((((4 * l) + (g %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + (g %% 4)) * 16)) /\
           (((((4 * l) + (g %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           (BArray128.is_init m_init (((4 * l) + (g %% 4)) * 16) 16))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + ((g + 2) %% 4)) * 16)) /\
           (((((4 * l) + ((g + 2) %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           (BArray128.is_init m_init (((4 * l) + ((g + 2) %% 4)) * 16) 16))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, g_init)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++ [(Assert, true)]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           ((0 <= (((4 * l) + ((g + 3) %% 4)) * 16)) /\
           (((((4 * l) + ((g + 3) %% 4)) * 16) + 16) <= 128)))]);
          trace___sha256_x8_block2 <-
          (trace___sha256_x8_block2 ++
          [(Assert,
           (BArray128.is_init m_init (((4 * l) + ((g + 3) %% 4)) * 16) 16))]);
          m <-
          (BArray128.set128 m ((4 * l) + (g %% 4))
          (SHA256SU1 (BArray128.get128 m ((4 * l) + (g %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 2) %% 4)))
          (BArray128.get128 m ((4 * l) + ((g + 3) %% 4)))));
          m_init <-
          (BArray128.set128 m_init ((4 * l) + (g %% 4))
          (W128.of_int 340282366920938463463374607431768211455));
        } else {
          
        }
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, ((0 <= (l * 16)) /\ (((l * 16) + 16) <= 32)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= (((4 * r) + (2 * l)) * 16)) /\
         (((((4 * r) + (2 * l)) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray128.is_init st_init (((4 * r) + (2 * l)) * 16) 16))]);
        prev <-
        (BArray32.set128 prev l (BArray128.get128 st ((4 * r) + (2 * l))));
        prev_init <-
        (BArray32.set128 prev_init l
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= (((4 * r) + (2 * l)) * 16)) /\
         (((((4 * r) + (2 * l)) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= (((4 * r) + (2 * l)) * 16)) /\
         (((((4 * r) + (2 * l)) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray128.is_init st_init (((4 * r) + (2 * l)) * 16) 16))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= ((((4 * r) + (2 * l)) + 1) * 16)) /\
         ((((((4 * r) + (2 * l)) + 1) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         (BArray128.is_init st_init ((((4 * r) + (2 * l)) + 1) * 16) 16))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, ((0 <= (l * 16)) /\ (((l * 16) + 16) <= 32)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray32.is_init wk_init (l * 16) 16))]);
        st <-
        (BArray128.set128 st ((4 * r) + (2 * l))
        (SHA256H (BArray128.get128 st ((4 * r) + (2 * l)))
        (BArray128.get128 st (((4 * r) + (2 * l)) + 1))
        (BArray32.get128 wk l)));
        st_init <-
        (BArray128.set128 st_init ((4 * r) + (2 * l))
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= ((((4 * r) + (2 * l)) + 1) * 16)) /\
         ((((((4 * r) + (2 * l)) + 1) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         ((0 <= ((((4 * r) + (2 * l)) + 1) * 16)) /\
         ((((((4 * r) + (2 * l)) + 1) * 16) + 16) <= 128)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert,
         (BArray128.is_init st_init ((((4 * r) + (2 * l)) + 1) * 16) 16))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, ((0 <= (l * 16)) /\ (((l * 16) + 16) <= 32)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray32.is_init prev_init (l * 16) 16))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, l_init)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++ [(Assert, true)]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, ((0 <= (l * 16)) /\ (((l * 16) + 16) <= 32)))]);
        trace___sha256_x8_block2 <-
        (trace___sha256_x8_block2 ++
        [(Assert, (BArray32.is_init wk_init (l * 16) 16))]);
        st <-
        (BArray128.set128 st (((4 * r) + (2 * l)) + 1)
        (SHA256H2 (BArray128.get128 st (((4 * r) + (2 * l)) + 1))
        (BArray32.get128 prev l) (BArray32.get128 wk l)));
        st_init <-
        (BArray128.set128 st_init (((4 * r) + (2 * l)) + 1)
        (W128.of_int 340282366920938463463374607431768211455));
        l <- (l + 1);
      }
      g <- (g + 1);
    }
    j_init <- true;
    j <- 0;
    while ((j < 4)) {
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, j_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert,
       ((0 <= (((4 * r) + j) * 16)) /\ (((((4 * r) + j) * 16) + 16) <= 128)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, r_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, j_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert,
       ((0 <= (((4 * r) + j) * 16)) /\ (((((4 * r) + j) * 16) + 16) <= 128)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, (BArray128.is_init st_init (((4 * r) + j) * 16) 16))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, j_init)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++ [(Assert, true)]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 64)))]);
      trace___sha256_x8_block2 <-
      (trace___sha256_x8_block2 ++
      [(Assert, (BArray64.is_init s0_init (j * 16) 16))]);
      st <-
      (BArray128.set128 st ((4 * r) + j)
      (VADD_4u32 (BArray128.get128 st ((4 * r) + j)) (BArray64.get128 s0 j)));
      st_init <-
      (BArray128.set128 st_init ((4 * r) + j)
      (W128.of_int 340282366920938463463374607431768211455));
      j <- (j + 1);
    }
    return (st, m, st_init, m_init, trace___sha256_x8_block2);
  }
  proc _sha256_x8_compress (h8:BArray256.t, blocks:BArray512.t, ms:W64.t,
                            h8_init:BArray256.t, blocks_init:BArray512.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var k:BArray256.t;
    var f:int;
    var st:BArray128.t;
    var i:int;
    var r:int;
    var m:BArray128.t;
    var k_init:BArray256.t;
    var f_init:bool;
    var st_init:BArray128.t;
    var i_init:bool;
    var r_init:bool;
    var m_init:BArray128.t;
    var ms_init:bool;
    var trace__sha256_x8_compress:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    st <- witness;
    st_init <- witness;
    trace__sha256_x8_compress <- [];
    ms_init <- true;
    k_init <- (BArray256.init_arr (W8.of_int 0));
    f_init <- false;
    st_init <- (BArray128.init_arr (W8.of_int 0));
    i_init <- false;
    r_init <- false;
    m_init <- (BArray128.init_arr (W8.of_int 0));
    k <- sHA256_K;
    k_init <- (BArray256.init_arr (W8.of_int 255));
    f_init <- true;
    f <- 0;
    while ((f < 2)) {
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, f_init)]);
      (st, st_init, tmp__trace) <@ __sha256_x8_load_half (h8, f, h8_init);
      trace__sha256_x8_compress <- (trace__sha256_x8_compress ++ tmp__trace);
      r_init <- true;
      r <- 0;
      while ((r < 2)) {
        i_init <- true;
        i <- 0;
        while ((i < 4)) {
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, f_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, r_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           ((0 <= (((4 * ((4 * f) + (2 * r))) + i) * 16)) /\
           (((((4 * ((4 * f) + (2 * r))) + i) * 16) + 16) <= 512)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           (BArray512.is_init blocks_init
           (((4 * ((4 * f) + (2 * r))) + i) * 16) 16))]);
          m <-
          (BArray128.set128 m i
          (BArray512.get128 blocks ((4 * ((4 * f) + (2 * r))) + i)));
          m_init <-
          (BArray128.set128 m_init i
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert, (BArray128.is_init m_init (i * 16) 16))]);
          m <- (BArray128.set128 m i (VREV32_16u8 (BArray128.get128 m i)));
          m_init <-
          (BArray128.set128 m_init i
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, f_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, r_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           ((0 <= (((4 * (((4 * f) + (2 * r)) + 1)) + i) * 16)) /\
           (((((4 * (((4 * f) + (2 * r)) + 1)) + i) * 16) + 16) <= 512)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           (BArray512.is_init blocks_init
           (((4 * (((4 * f) + (2 * r)) + 1)) + i) * 16) 16))]);
          m <-
          (BArray128.set128 m (4 + i)
          (BArray512.get128 blocks ((4 * (((4 * f) + (2 * r)) + 1)) + i)));
          m_init <-
          (BArray128.set128 m_init (4 + i)
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, i_init)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++ [(Assert, true)]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert,
           ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
          trace__sha256_x8_compress <-
          (trace__sha256_x8_compress ++
          [(Assert, (BArray128.is_init m_init ((4 + i) * 16) 16))]);
          m <-
          (BArray128.set128 m (4 + i)
          (VREV32_16u8 (BArray128.get128 m (4 + i))));
          m_init <-
          (BArray128.set128 m_init (4 + i)
          (W128.of_int 340282366920938463463374607431768211455));
          i <- (i + 1);
        }
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, true)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, r_init)]);
        (st, m, st_init, m_init, tmp__trace) <@ __sha256_x8_block2 (st, 
        r, m, k, st_init, m_init, k_init);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ tmp__trace);
        r <- (r + 1);
      }
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, f_init)]);
      (h8, h8_init, tmp__trace) <@ __sha256_x8_store_half (h8, st, f,
      h8_init, st_init);
      trace__sha256_x8_compress <- (trace__sha256_x8_compress ++ tmp__trace);
      f <- (f + 1);
    }
    trace__sha256_x8_compress <-
    (trace__sha256_x8_compress ++ [(Assert, ms_init)]);
    return (h8, ms, h8_init, trace__sha256_x8_compress);
  }
  proc _sha256_x8_compress_lanes (h8:BArray256.t, in_0:BArray64.t, off:W64.t,
                                  n:W64.t, ms:W64.t, h8_init:BArray256.t,
                                  in_init:BArray64.t) : BArray256.t * W64.t *
                                                        BArray256.t * trace = {
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
    var k_init:BArray256.t;
    var f_init:bool;
    var st_init:BArray128.t;
    var r_init:bool;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var q_init:bool;
    var n_init:bool;
    var c_init:bool;
    var more_init:bool;
    var i_init:bool;
    var m_init:BArray128.t;
    var trace__sha256_x8_compress_lanes:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    st <- witness;
    st_init <- witness;
    trace__sha256_x8_compress_lanes <- [];
    off_init <- true;
    n_init <- true;
    ms_init <- true;
    k_init <- (BArray256.init_arr (W8.of_int 0));
    f_init <- false;
    st_init <- (BArray128.init_arr (W8.of_int 0));
    r_init <- false;
    p_init <- false;
    q_init <- false;
    c_init <- false;
    more_init <- false;
    i_init <- false;
    m_init <- (BArray128.init_arr (W8.of_int 0));
    k <- sHA256_K;
    k_init <- (BArray256.init_arr (W8.of_int 255));
    f_init <- true;
    f <- 0;
    while ((f < 2)) {
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, f_init)]);
      (st, st_init, tmp__trace) <@ __sha256_x8_load_half (h8, f, h8_init);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ tmp__trace);
      r_init <- true;
      r <- 0;
      while ((r < 2)) {
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, f_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, r_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert,
         ((0 <= (((4 * f) + (2 * r)) * 8)) /\
         (((((4 * f) + (2 * r)) * 8) + 8) <= 64)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert, (BArray64.is_init in_init (((4 * f) + (2 * r)) * 8) 8))]);
        p <- (BArray64.get64 in_0 ((4 * f) + (2 * r)));
        p_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, p_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
        p <- (protect_64 p ms);
        p_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, p_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, off_init)]);
        p <- (p + off);
        p_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, f_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, r_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert,
         ((0 <= ((((4 * f) + (2 * r)) + 1) * 8)) /\
         ((((((4 * f) + (2 * r)) + 1) * 8) + 8) <= 64)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert,
         (BArray64.is_init in_init ((((4 * f) + (2 * r)) + 1) * 8) 8))]);
        q <- (BArray64.get64 in_0 (((4 * f) + (2 * r)) + 1));
        q_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, q_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
        q <- (protect_64 q ms);
        q_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, q_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, off_init)]);
        q <- (q + off);
        q_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, n_init)]);
        c <- n;
        c_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, c_init)]);
        more <- (c <> (W64.of_int 0));
        more_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, more_init)]);
        while (more) {
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, more_init)]);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
          ms <- (update_msf more ms);
          ms_init <- true;
          i_init <- true;
          i <- 0;
          while ((i < 4)) {
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, p_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert,
             (is_valid ptr_modulus Glob.mem_v
             (W64.to_uint (p + (W64.of_int (16 * i)))) 16))]);
            m <-
            (BArray128.set128 m i
            (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * i))))));
            m_init <-
            (BArray128.set128 m_init i
            (W128.of_int 340282366920938463463374607431768211455));
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert, ((0 <= (i * 16)) /\ (((i * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert, (BArray128.is_init m_init (i * 16) 16))]);
            m <- (BArray128.set128 m i (VREV32_16u8 (BArray128.get128 m i)));
            m_init <-
            (BArray128.set128 m_init i
            (W128.of_int 340282366920938463463374607431768211455));
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert,
             ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, q_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert,
             (is_valid ptr_modulus Glob.mem_v
             (W64.to_uint (q + (W64.of_int (16 * i)))) 16))]);
            m <-
            (BArray128.set128 m (4 + i)
            (loadW128 Glob.mem (W64.to_uint (q + (W64.of_int (16 * i))))));
            m_init <-
            (BArray128.set128 m_init (4 + i)
            (W128.of_int 340282366920938463463374607431768211455));
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert,
             ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, i_init)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert,
             ((0 <= ((4 + i) * 16)) /\ ((((4 + i) * 16) + 16) <= 128)))]);
            trace__sha256_x8_compress_lanes <-
            (trace__sha256_x8_compress_lanes ++
            [(Assert, (BArray128.is_init m_init ((4 + i) * 16) 16))]);
            m <-
            (BArray128.set128 m (4 + i)
            (VREV32_16u8 (BArray128.get128 m (4 + i))));
            m_init <-
            (BArray128.set128 m_init (4 + i)
            (W128.of_int 340282366920938463463374607431768211455));
            i <- (i + 1);
          }
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, r_init)]);
          (st, m, st_init, m_init, tmp__trace) <@ __sha256_x8_block2 (
          st, r, m, k, st_init, m_init, k_init);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ tmp__trace);
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, p_init)]);
          p <- (p + (W64.of_int 64));
          p_init <- true;
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, q_init)]);
          q <- (q + (W64.of_int 64));
          q_init <- true;
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, c_init)]);
          c <- (c - (W64.of_int 1));
          c_init <- true;
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, c_init)]);
          more <- (c <> (W64.of_int 0));
          more_init <- true;
          trace__sha256_x8_compress_lanes <-
          (trace__sha256_x8_compress_lanes ++ [(Assert, more_init)]);
        }
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, more_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
        ms <- (update_msf (! more) ms);
        ms_init <- true;
        r <- (r + 1);
      }
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, f_init)]);
      (h8, h8_init, tmp__trace) <@ __sha256_x8_store_half (h8, st, f,
      h8_init, st_init);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ tmp__trace);
      f <- (f + 1);
    }
    trace__sha256_x8_compress_lanes <-
    (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
    return (h8, ms, h8_init, trace__sha256_x8_compress_lanes);
  }
  proc __sha256_x8_init (h:BArray256.t, h_init:BArray256.t) : BArray256.t *
                                                              BArray256.t *
                                                              trace = {
    var iv:BArray32.t;
    var j:int;
    var t:W32.t;
    var k:int;
    var iv_init:BArray32.t;
    var j_init:bool;
    var t_init:bool;
    var k_init:bool;
    var trace___sha256_x8_init:trace;
    iv <- witness;
    iv_init <- witness;
    trace___sha256_x8_init <- [];
    iv_init <- (BArray32.init_arr (W8.of_int 0));
    j_init <- false;
    t_init <- false;
    k_init <- false;
    iv <- sHA256_IV;
    iv_init <- (BArray32.init_arr (W8.of_int 255));
    j_init <- true;
    j <- 0;
    while ((j < 8)) {
      trace___sha256_x8_init <-
      (trace___sha256_x8_init ++ [(Assert, j_init)]);
      trace___sha256_x8_init <- (trace___sha256_x8_init ++ [(Assert, true)]);
      trace___sha256_x8_init <-
      (trace___sha256_x8_init ++
      [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
      trace___sha256_x8_init <-
      (trace___sha256_x8_init ++
      [(Assert, (BArray32.is_init iv_init (j * 4) 4))]);
      t <- (BArray32.get32 iv j);
      t_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace___sha256_x8_init <-
        (trace___sha256_x8_init ++ [(Assert, j_init)]);
        trace___sha256_x8_init <-
        (trace___sha256_x8_init ++ [(Assert, k_init)]);
        trace___sha256_x8_init <-
        (trace___sha256_x8_init ++ [(Assert, true)]);
        trace___sha256_x8_init <-
        (trace___sha256_x8_init ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace___sha256_x8_init <-
        (trace___sha256_x8_init ++ [(Assert, t_init)]);
        h <- (BArray256.set32 h ((8 * j) + k) t);
        h_init <-
        (BArray256.set32 h_init ((8 * j) + k) (W32.of_int 4294967295));
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    return (h, h_init, trace___sha256_x8_init);
  }
  proc __sha256_x8_from (h:BArray256.t, buf:BArray512.t, hs:BArray32.t,
                         bs:BArray64.t, h_init:BArray256.t,
                         buf_init:BArray512.t, hs_init:BArray32.t,
                         bs_init:BArray64.t) : BArray256.t * BArray512.t *
                                               BArray256.t * BArray512.t *
                                               trace = {
    var j:int;
    var x:W32.t;
    var k:int;
    var i:int;
    var t:W64.t;
    var j_init:bool;
    var x_init:bool;
    var k_init:bool;
    var i_init:bool;
    var t_init:bool;
    var trace___sha256_x8_from:trace;
    trace___sha256_x8_from <- [];
    j_init <- false;
    x_init <- false;
    k_init <- false;
    i_init <- false;
    t_init <- false;
    j_init <- true;
    j <- 0;
    while ((j < 8)) {
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++ [(Assert, j_init)]);
      trace___sha256_x8_from <- (trace___sha256_x8_from ++ [(Assert, true)]);
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++
      [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++
      [(Assert, (BArray32.is_init hs_init (j * 4) 4))]);
      x <- (BArray32.get32 hs j);
      x_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, j_init)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, k_init)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, true)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, x_init)]);
        h <- (BArray256.set32 h ((8 * j) + k) x);
        h_init <-
        (BArray256.set32 h_init ((8 * j) + k) (W32.of_int 4294967295));
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++ [(Assert, i_init)]);
      trace___sha256_x8_from <- (trace___sha256_x8_from ++ [(Assert, true)]);
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha256_x8_from <-
      (trace___sha256_x8_from ++
      [(Assert, (BArray64.is_init bs_init (i * 8) 8))]);
      t <- (BArray64.get64 bs i);
      t_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, k_init)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, i_init)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, true)]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++
        [(Assert,
         ((0 <= (((64 * k) + (8 * i)) * 1)) /\
         (((((64 * k) + (8 * i)) * 1) + 8) <= 512)))]);
        trace___sha256_x8_from <-
        (trace___sha256_x8_from ++ [(Assert, t_init)]);
        buf <- (BArray512.set64d buf ((64 * k) + (8 * i)) t);
        buf_init <-
        (BArray512.set64d buf_init ((64 * k) + (8 * i))
        (W64.of_int 18446744073709551615));
        k <- (k + 1);
      }
      i <- (i + 1);
    }
    return (h, buf, h_init, buf_init, trace___sha256_x8_from);
  }
  proc _sha256_x8_absorb_lanes (h:BArray256.t, buf:BArray512.t, total:W64.t,
                                in_0:BArray64.t, inlen:W64.t, ms:W64.t,
                                h_init:BArray256.t, buf_init:BArray512.t,
                                in_init:BArray64.t) : BArray256.t *
                                                      BArray512.t * W64.t *
                                                      W64.t * BArray256.t *
                                                      BArray512.t * trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var n:W64.t;
    var k:int;
    var p:W64.t;
    var off:W64.t;
    var full:bool;
    var more:bool;
    var total_init:bool;
    var fill_init:bool;
    var inlen_init:bool;
    var n_init:bool;
    var k_init:bool;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var full_init:bool;
    var more_init:bool;
    var trace__sha256_x8_absorb_lanes:trace;
    trace__sha256_x8_absorb_lanes <- [];
    total_init <- true;
    inlen_init <- true;
    ms_init <- true;
    fill_init <- false;
    n_init <- false;
    k_init <- false;
    p_init <- false;
    off_init <- false;
    full_init <- false;
    more_init <- false;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
    total <- (total + inlen);
    total_init <- true;
    n <- (W64.of_int 64);
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    n <- (n - fill);
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    n <- ((inlen \ult n) ? inlen : n);
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    n_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 64)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, (BArray64.is_init in_init (k * 8) 8))]);
      p <- (BArray64.get64 in_0 k);
      p_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __fill64_mem ((
                                                       SBArray512_64.get_sub8
                                                       buf (64 * k)),
      fill, p, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))));
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    fill <- (fill + n);
    fill_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    off <- n;
    off_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
    full <- (fill = (W64.of_int 64));
    full_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, full_init)]);
    if (full) {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, full_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf full ms);
      ms_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to spill *)
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms, 
      h_init, buf_init);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to unspill *)
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, full_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf (! full) ms);
      ms_init <- true;
    }
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
    n <- (n - off);
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    n <- (n `>>` (W8.of_int 6));
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, more_init)]);
    if (more) {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, more_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to spill *)
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress_lanes (h, in_0, 
      off, n, ms, h_init, in_init);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to unspill *)
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
      n <- inlen;
      n_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      n <- (n - off);
      n_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      n <- (n `>>` (W8.of_int 6));
      n_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      n <- (n `<<` (W8.of_int 6));
      n_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, more_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf (! more) ms);
      ms_init <- true;
    }
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
    n <- (n - off);
    n_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 64)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, (BArray64.is_init in_init (k * 8) 8))]);
      p <- (BArray64.get64 in_0 k);
      p_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, off_init)]);
      p <- (p + off);
      p_init <- true;
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, true)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, fill_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __fill64_mem ((
                                                       SBArray512_64.get_sub8
                                                       buf (64 * k)),
      fill, p, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))));
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
      trace__sha256_x8_absorb_lanes <-
      (trace__sha256_x8_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, total_init)]);
    trace__sha256_x8_absorb_lanes <-
    (trace__sha256_x8_absorb_lanes ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace__sha256_x8_absorb_lanes);
  }
  proc _sha256_x8_finalize (out:BArray256.t, h:BArray256.t, buf:BArray512.t,
                            total:W64.t, ms:W64.t, out_init:BArray256.t,
                            h_init:BArray256.t, buf_init:BArray512.t) : 
  BArray256.t * BArray256.t * BArray512.t * W64.t * BArray256.t *
  BArray256.t * BArray512.t * trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var at:W64.t;
    var t:W64.t;
    var k:int;
    var two_blocks:bool;
    var hi:W64.t;
    var j:int;
    var x:W32.t;
    var total_init:bool;
    var fill_init:bool;
    var at_init:bool;
    var t_init:bool;
    var k_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var j_init:bool;
    var x_init:bool;
    var trace__sha256_x8_finalize:trace;
    trace__sha256_x8_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    at_init <- false;
    t_init <- false;
    k_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    j_init <- false;
    x_init <- false;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
    at <- fill;
    at_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, at_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++
      [(Assert,
       ((0 <= ((W64.to_uint at) * 1)) /\
       ((((W64.to_uint at) * 1) + 1) <= 512)))]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, t_init)]);
      buf <- (BArray512.set8 buf (W64.to_uint at) (truncateu8 t));
      buf_init <- (BArray512.set8 buf_init (W64.to_uint at) (W8.of_int 255));
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, at_init)]);
      at <- (at + (W64.of_int 64));
      at_init <- true;
      k <- (k + 1);
    }
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 56) \ult fill);
    two_blocks_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 64);
      hi_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, true)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, hi_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ __zero64 ((SBArray512_64.get_sub8
                                                     buf (64 * k)),
        fill, hi, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))));
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ tmp__trace);
        ms_init <- true;
        k <- (k + 1);
      }
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms, 
      h_init, buf_init);
      trace__sha256_x8_finalize <- (trace__sha256_x8_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, total_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 56);
    hi_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, fill_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, hi_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __zero64 ((SBArray512_64.get_sub8
                                                   buf (64 * k)),
      fill, hi, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))));
      buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
      trace__sha256_x8_finalize <- (trace__sha256_x8_finalize ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, t_init)]);
    t <- (t `<<` (W8.of_int 3));
    t_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha256_x8_finalize <- (trace__sha256_x8_finalize ++ tmp__trace);
    t_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, true)]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++
      [(Assert,
       ((0 <= (((64 * k) + 56) * 1)) /\ (((((64 * k) + 56) * 1) + 8) <= 512)))]);
      trace__sha256_x8_finalize <-
      (trace__sha256_x8_finalize ++ [(Assert, t_init)]);
      buf <- (BArray512.set64d buf ((64 * k) + 56) t);
      buf_init <-
      (BArray512.set64d buf_init ((64 * k) + 56)
      (W64.of_int 18446744073709551615));
      k <- (k + 1);
    }
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha256_x8_finalize <- (trace__sha256_x8_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, true)]);
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray512.init_arr (W8.of_int 255));
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, j_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, true)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++
        [(Assert, (BArray256.is_init h_init (((8 * j) + k) * 4) 4))]);
        x <- (BArray256.get32 h ((8 * j) + k));
        x_init <- true;
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, true)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, x_init)]);
        (x, tmp__trace) <@ __bswap32 (x);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ tmp__trace);
        x_init <- true;
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, k_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, j_init)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, true)]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++
        [(Assert,
         ((0 <= (((8 * k) + j) * 4)) /\ (((((8 * k) + j) * 4) + 4) <= 256)))]);
        trace__sha256_x8_finalize <-
        (trace__sha256_x8_finalize ++ [(Assert, x_init)]);
        out <- (BArray256.set32 out ((8 * k) + j) x);
        out_init <-
        (BArray256.set32 out_init ((8 * k) + j) (W32.of_int 4294967295));
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    trace__sha256_x8_finalize <-
    (trace__sha256_x8_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha256_x8_finalize);
  }
  proc _sha256_x8_lanes (out:BArray256.t, in_0:BArray64.t, len:W64.t,
                         ms:W64.t, out_init:BArray256.t, in_init:BArray64.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var len_init:bool;
    var ms_init:bool;
    var trace__sha256_x8_lanes:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace__sha256_x8_lanes <- [];
    len_init <- true;
    ms_init <- true;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_x8_init (h, h_init);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, total_init)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, len_init)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha256_x8_absorb_lanes (
    h, buf, total, in_0, len, ms, h_init, buf_init, in_init);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ [(Assert, true)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, total_init)]);
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256_x8_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha256_x8_lanes <- (trace__sha256_x8_lanes ++ tmp__trace);
    ms_init <- true;
    trace__sha256_x8_lanes <-
    (trace__sha256_x8_lanes ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha256_x8_lanes);
  }
  proc __sha512_x4_load_pair (h4:BArray256.t, i:int, h4_init:BArray256.t) : 
  BArray160.t * BArray160.t * trace = {
    var s:BArray160.t;
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var q_init:bool;
    var i_init:bool;
    var a_init:bool;
    var b_init:bool;
    var s_init:BArray160.t;
    var trace___sha512_x4_load_pair:trace;
    s <- witness;
    s_init <- witness;
    trace___sha512_x4_load_pair <- [];
    i_init <- true;
    s_init <- (BArray160.init_arr (W8.of_int 0));
    q_init <- false;
    a_init <- false;
    b_init <- false;
    q_init <- true;
    q <- 0;
    while ((q < 4)) {
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, i_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert,
       ((0 <= (((2 * (2 * q)) + i) * 16)) /\
       (((((2 * (2 * q)) + i) * 16) + 16) <= 256)))]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert, (BArray256.is_init h4_init (((2 * (2 * q)) + i) * 16) 16))]);
      a <- (BArray256.get128 h4 ((2 * (2 * q)) + i));
      a_init <- true;
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, i_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert,
       ((0 <= (((2 * ((2 * q) + 1)) + i) * 16)) /\
       (((((2 * ((2 * q) + 1)) + i) * 16) + 16) <= 256)))]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert,
       (BArray256.is_init h4_init (((2 * ((2 * q) + 1)) + i) * 16) 16))]);
      b <- (BArray256.get128 h4 ((2 * ((2 * q) + 1)) + i));
      b_init <- true;
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert, ((0 <= (q * 16)) /\ (((q * 16) + 16) <= 160)))]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, a_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, b_init)]);
      s <- (BArray160.set128 s q (VTRN1_2u64 a b));
      s_init <-
      (BArray160.set128 s_init q
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, true)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++
      [(Assert, ((0 <= ((5 + q) * 16)) /\ ((((5 + q) * 16) + 16) <= 160)))]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, a_init)]);
      trace___sha512_x4_load_pair <-
      (trace___sha512_x4_load_pair ++ [(Assert, b_init)]);
      s <- (BArray160.set128 s (5 + q) (VTRN2_2u64 a b));
      s_init <-
      (BArray160.set128 s_init (5 + q)
      (W128.of_int 340282366920938463463374607431768211455));
      q <- (q + 1);
    }
    return (s, s_init, trace___sha512_x4_load_pair);
  }
  proc __sha512_x4_store_pair (h4:BArray256.t, s:BArray160.t, i:int,
                               h4_init:BArray256.t, s_init:BArray160.t) : 
  BArray256.t * BArray256.t * trace = {
    var q:int;
    var a:W128.t;
    var b:W128.t;
    var q_init:bool;
    var a_init:bool;
    var b_init:bool;
    var i_init:bool;
    var trace___sha512_x4_store_pair:trace;
    trace___sha512_x4_store_pair <- [];
    i_init <- true;
    q_init <- false;
    a_init <- false;
    b_init <- false;
    q_init <- true;
    q <- 0;
    while ((q < 4)) {
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, ((0 <= (q * 16)) /\ (((q * 16) + 16) <= 160)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, (BArray160.is_init s_init (q * 16) 16))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, ((0 <= ((5 + q) * 16)) /\ ((((5 + q) * 16) + 16) <= 160)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, (BArray160.is_init s_init ((5 + q) * 16) 16))]);
      a <- (VTRN1_2u64 (BArray160.get128 s q) (BArray160.get128 s (5 + q)));
      a_init <- true;
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, ((0 <= (q * 16)) /\ (((q * 16) + 16) <= 160)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, (BArray160.is_init s_init (q * 16) 16))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, ((0 <= ((5 + q) * 16)) /\ ((((5 + q) * 16) + 16) <= 160)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert, (BArray160.is_init s_init ((5 + q) * 16) 16))]);
      b <- (VTRN2_2u64 (BArray160.get128 s q) (BArray160.get128 s (5 + q)));
      b_init <- true;
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, i_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert,
       ((0 <= (((2 * (2 * q)) + i) * 16)) /\
       (((((2 * (2 * q)) + i) * 16) + 16) <= 256)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, a_init)]);
      h4 <- (BArray256.set128 h4 ((2 * (2 * q)) + i) a);
      h4_init <-
      (BArray256.set128 h4_init ((2 * (2 * q)) + i)
      (W128.of_int 340282366920938463463374607431768211455));
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, q_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, i_init)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, true)]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++
      [(Assert,
       ((0 <= (((2 * ((2 * q) + 1)) + i) * 16)) /\
       (((((2 * ((2 * q) + 1)) + i) * 16) + 16) <= 256)))]);
      trace___sha512_x4_store_pair <-
      (trace___sha512_x4_store_pair ++ [(Assert, b_init)]);
      h4 <- (BArray256.set128 h4 ((2 * ((2 * q) + 1)) + i) b);
      h4_init <-
      (BArray256.set128 h4_init ((2 * ((2 * q) + 1)) + i)
      (W128.of_int 340282366920938463463374607431768211455));
      q <- (q + 1);
    }
    return (h4, h4_init, trace___sha512_x4_store_pair);
  }
  proc __sha512_x4_block2 (s:BArray160.t, m:BArray256.t, k:BArray640.t,
                           s_init:BArray160.t, m_init:BArray256.t,
                           k_init:BArray640.t) : BArray160.t * BArray256.t *
                                                 BArray160.t * BArray256.t *
                                                 trace = {
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
    var l_init:bool;
    var j_init:bool;
    var save_init:BArray128.t;
    var i0_init:bool;
    var i1_init:bool;
    var i2_init:bool;
    var i3_init:bool;
    var i4_init:bool;
    var g_init:bool;
    var kv_init:bool;
    var wk_init:bool;
    var x_init:bool;
    var y_init:bool;
    var z_init:bool;
    var t_init:bool;
    var trace___sha512_x4_block2:trace;
    save <- witness;
    save_init <- witness;
    trace___sha512_x4_block2 <- [];
    j_init <- false;
    l_init <- false;
    save_init <- (BArray128.init_arr (W8.of_int 0));
    i0_init <- false;
    i1_init <- false;
    i2_init <- false;
    i3_init <- false;
    i4_init <- false;
    g_init <- false;
    kv_init <- false;
    wk_init <- false;
    x_init <- false;
    y_init <- false;
    z_init <- false;
    t_init <- false;
    l_init <- true;
    l <- 0;
    while ((l < 2)) {
      j_init <- true;
      j <- 0;
      while ((j < 4)) {
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((4 * l) + j) * 16)) /\
         (((((4 * l) + j) * 16) + 16) <= 128)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + j) * 16)) /\
         (((((5 * l) + j) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + j) * 16) 16))]);
        save <-
        (BArray128.set128 save ((4 * l) + j)
        (BArray160.get128 s ((5 * l) + j)));
        save_init <-
        (BArray128.set128 save_init ((4 * l) + j)
        (W128.of_int 340282366920938463463374607431768211455));
        j <- (j + 1);
      }
      l <- (l + 1);
    }
    i0 <- 0;
    i0_init <- true;
    i1 <- 1;
    i1_init <- true;
    i2 <- 2;
    i2_init <- true;
    i3 <- 3;
    i3_init <- true;
    i4 <- 4;
    i4_init <- true;
    g_init <- true;
    g <- 0;
    while ((g < 40)) {
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, g_init)]);
      j <- (g %% 8);
      j_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, g_init)]);
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, true)]);
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++
      [(Assert, ((0 <= (g * 16)) /\ (((g * 16) + 16) <= 640)))]);
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++
      [(Assert, (BArray640.is_init k_init (g * 16) 16))]);
      kv <- (BArray640.get128 k g);
      kv_init <- true;
      l_init <- true;
      l <- 0;
      while ((l < 2)) {
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, kv_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((8 * l) + j) * 16)) /\
         (((((8 * l) + j) * 16) + 16) <= 256)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray256.is_init m_init (((8 * l) + j) * 16) 16))]);
        wk <- (VADD_2u64 kv (BArray256.get128 m ((8 * l) + j)));
        wk_init <- true;
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, wk_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, wk_init)]);
        wk <- (VEXT wk wk (W8.of_int 8));
        wk_init <- true;
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i2_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i2) * 16)) /\
         (((((5 * l) + i2) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i2) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i3) * 16) 16))]);
        x <-
        (VEXT (BArray160.get128 s ((5 * l) + i2))
        (BArray160.get128 s ((5 * l) + i3)) (W8.of_int 8));
        x_init <- true;
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i1_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i1) * 16)) /\
         (((((5 * l) + i1) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i1) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i2_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i2) * 16)) /\
         (((((5 * l) + i2) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i2) * 16) 16))]);
        y <-
        (VEXT (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i2)) (W8.of_int 8));
        y_init <- true;
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i3) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, wk_init)]);
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + i3)) wk));
        s_init <-
        (BArray160.set128 s_init ((5 * l) + i3)
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, g_init)]);
        if ((g < 32)) {
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + ((j + 4) %% 8)) * 16)) /\
           (((((8 * l) + ((j + 4) %% 8)) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           (BArray256.is_init m_init (((8 * l) + ((j + 4) %% 8)) * 16) 16))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + ((j + 5) %% 8)) * 16)) /\
           (((((8 * l) + ((j + 5) %% 8)) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           (BArray256.is_init m_init (((8 * l) + ((j + 5) %% 8)) * 16) 16))]);
          z <-
          (VEXT (BArray256.get128 m ((8 * l) + ((j + 4) %% 8)))
          (BArray256.get128 m ((8 * l) + ((j + 5) %% 8))) (W8.of_int 8));
          z_init <- true;
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + j) * 16)) /\
           (((((8 * l) + j) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + j) * 16)) /\
           (((((8 * l) + j) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert, (BArray256.is_init m_init (((8 * l) + j) * 16) 16))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + ((j + 1) %% 8)) * 16)) /\
           (((((8 * l) + ((j + 1) %% 8)) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           (BArray256.is_init m_init (((8 * l) + ((j + 1) %% 8)) * 16) 16))]);
          m <-
          (BArray256.set128 m ((8 * l) + j)
          (SHA512SU0 (BArray256.get128 m ((8 * l) + j))
          (BArray256.get128 m ((8 * l) + ((j + 1) %% 8)))));
          m_init <-
          (BArray256.set128 m_init ((8 * l) + j)
          (W128.of_int 340282366920938463463374607431768211455));
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + j) * 16)) /\
           (((((8 * l) + j) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + j) * 16)) /\
           (((((8 * l) + j) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert, (BArray256.is_init m_init (((8 * l) + j) * 16) 16))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, true)]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           ((0 <= (((8 * l) + ((j + 7) %% 8)) * 16)) /\
           (((((8 * l) + ((j + 7) %% 8)) * 16) + 16) <= 256)))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++
          [(Assert,
           (BArray256.is_init m_init (((8 * l) + ((j + 7) %% 8)) * 16) 16))]);
          trace___sha512_x4_block2 <-
          (trace___sha512_x4_block2 ++ [(Assert, z_init)]);
          m <-
          (BArray256.set128 m ((8 * l) + j)
          (SHA512SU1 (BArray256.get128 m ((8 * l) + j))
          (BArray256.get128 m ((8 * l) + ((j + 7) %% 8))) z));
          m_init <-
          (BArray256.set128 m_init ((8 * l) + j)
          (W128.of_int 340282366920938463463374607431768211455));
        } else {
          
        }
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i3) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, x_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, y_init)]);
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (SHA512H (BArray160.get128 s ((5 * l) + i3)) x y));
        s_init <-
        (BArray160.set128 s_init ((5 * l) + i3)
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i4_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i4) * 16)) /\
         (((((5 * l) + i4) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i1_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i1) * 16)) /\
         (((((5 * l) + i1) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i1) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i3) * 16) 16))]);
        s <-
        (BArray160.set128 s ((5 * l) + i4)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i3))));
        s_init <-
        (BArray160.set128 s_init ((5 * l) + i4)
        (W128.of_int 340282366920938463463374607431768211455));
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i3) * 16)) /\
         (((((5 * l) + i3) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i3) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i1_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i1) * 16)) /\
         (((((5 * l) + i1) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i1) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, i0_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + i0) * 16)) /\
         (((((5 * l) + i0) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + i0) * 16) 16))]);
        s <-
        (BArray160.set128 s ((5 * l) + i3)
        (SHA512H2 (BArray160.get128 s ((5 * l) + i3))
        (BArray160.get128 s ((5 * l) + i1))
        (BArray160.get128 s ((5 * l) + i0))));
        s_init <-
        (BArray160.set128 s_init ((5 * l) + i3)
        (W128.of_int 340282366920938463463374607431768211455));
        l <- (l + 1);
      }
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, i0_init)]);
      t <- i0;
      t_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, i3_init)]);
      i0 <- i3;
      i0_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, i2_init)]);
      i3 <- i2;
      i3_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, i4_init)]);
      i2 <- i4;
      i2_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, i1_init)]);
      i4 <- i1;
      i4_init <- true;
      trace___sha512_x4_block2 <-
      (trace___sha512_x4_block2 ++ [(Assert, t_init)]);
      i1 <- t;
      i1_init <- true;
      g <- (g + 1);
    }
    l_init <- true;
    l <- 0;
    while ((l < 2)) {
      j_init <- true;
      j <- 0;
      while ((j < 4)) {
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((4 * l) + j) * 16)) /\
         (((((4 * l) + j) * 16) + 16) <= 128)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray128.is_init save_init (((4 * l) + j) * 16) 16))]);
        x <- (BArray128.get128 save ((4 * l) + j));
        x_init <- true;
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + j) * 16)) /\
         (((((5 * l) + j) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, l_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, j_init)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, true)]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert,
         ((0 <= (((5 * l) + j) * 16)) /\
         (((((5 * l) + j) * 16) + 16) <= 160)))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++
        [(Assert, (BArray160.is_init s_init (((5 * l) + j) * 16) 16))]);
        trace___sha512_x4_block2 <-
        (trace___sha512_x4_block2 ++ [(Assert, x_init)]);
        s <-
        (BArray160.set128 s ((5 * l) + j)
        (VADD_2u64 (BArray160.get128 s ((5 * l) + j)) x));
        s_init <-
        (BArray160.set128 s_init ((5 * l) + j)
        (W128.of_int 340282366920938463463374607431768211455));
        j <- (j + 1);
      }
      l <- (l + 1);
    }
    return (s, m, s_init, m_init, trace___sha512_x4_block2);
  }
  proc _sha512_x4_compress (h4:BArray256.t, blocks:BArray512.t, ms:W64.t,
                            h4_init:BArray256.t, blocks_init:BArray512.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var k:BArray640.t;
    var i:int;
    var s:BArray160.t;
    var j:int;
    var m:BArray256.t;
    var k_init:BArray640.t;
    var i_init:bool;
    var s_init:BArray160.t;
    var j_init:bool;
    var m_init:BArray256.t;
    var ms_init:bool;
    var trace__sha512_x4_compress:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    s <- witness;
    s_init <- witness;
    trace__sha512_x4_compress <- [];
    ms_init <- true;
    k_init <- (BArray640.init_arr (W8.of_int 0));
    i_init <- false;
    s_init <- (BArray160.init_arr (W8.of_int 0));
    j_init <- false;
    m_init <- (BArray256.init_arr (W8.of_int 0));
    k <- sHA512_K;
    k_init <- (BArray640.init_arr (W8.of_int 255));
    i_init <- true;
    i <- 0;
    while ((i < 2)) {
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, i_init)]);
      (s, s_init, tmp__trace) <@ __sha512_x4_load_pair (h4, i, h4_init);
      trace__sha512_x4_compress <- (trace__sha512_x4_compress ++ tmp__trace);
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, i_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         ((0 <= (((8 * (2 * i)) + j) * 16)) /\
         (((((8 * (2 * i)) + j) * 16) + 16) <= 512)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         (BArray512.is_init blocks_init (((8 * (2 * i)) + j) * 16) 16))]);
        m <-
        (BArray256.set128 m j (BArray512.get128 blocks ((8 * (2 * i)) + j)));
        m_init <-
        (BArray256.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, (BArray256.is_init m_init (j * 16) 16))]);
        m <- (BArray256.set128 m j (VREV64_16u8 (BArray256.get128 m j)));
        m_init <-
        (BArray256.set128 m_init j
        (W128.of_int 340282366920938463463374607431768211455));
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, i_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         ((0 <= (((8 * ((2 * i) + 1)) + j) * 16)) /\
         (((((8 * ((2 * i) + 1)) + j) * 16) + 16) <= 512)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         (BArray512.is_init blocks_init (((8 * ((2 * i) + 1)) + j) * 16) 16))]);
        m <-
        (BArray256.set128 m (8 + j)
        (BArray512.get128 blocks ((8 * ((2 * i) + 1)) + j)));
        m_init <-
        (BArray256.set128 m_init (8 + j)
        (W128.of_int 340282366920938463463374607431768211455));
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, (BArray256.is_init m_init ((8 + j) * 16) 16))]);
        m <-
        (BArray256.set128 m (8 + j)
        (VREV64_16u8 (BArray256.get128 m (8 + j))));
        m_init <-
        (BArray256.set128 m_init (8 + j)
        (W128.of_int 340282366920938463463374607431768211455));
        j <- (j + 1);
      }
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      (s, m, s_init, m_init, tmp__trace) <@ __sha512_x4_block2 (s, m, 
      k, s_init, m_init, k_init);
      trace__sha512_x4_compress <- (trace__sha512_x4_compress ++ tmp__trace);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, i_init)]);
      (h4, h4_init, tmp__trace) <@ __sha512_x4_store_pair (h4, s, i, 
      h4_init, s_init);
      trace__sha512_x4_compress <- (trace__sha512_x4_compress ++ tmp__trace);
      i <- (i + 1);
    }
    trace__sha512_x4_compress <-
    (trace__sha512_x4_compress ++ [(Assert, ms_init)]);
    return (h4, ms, h4_init, trace__sha512_x4_compress);
  }
  proc _sha512_x4_compress_lanes (h4:BArray256.t, in_0:BArray32.t, off:W64.t,
                                  n:W64.t, ms:W64.t, h4_init:BArray256.t,
                                  in_init:BArray32.t) : BArray256.t * W64.t *
                                                        BArray256.t * trace = {
    var k:BArray640.t;
    var i:int;
    var s:BArray160.t;
    var p:W64.t;
    var q:W64.t;
    var c:W64.t;
    var more:bool;
    var j:int;
    var m:BArray256.t;
    var k_init:BArray640.t;
    var i_init:bool;
    var s_init:BArray160.t;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var q_init:bool;
    var n_init:bool;
    var c_init:bool;
    var more_init:bool;
    var j_init:bool;
    var m_init:BArray256.t;
    var trace__sha512_x4_compress_lanes:trace;
    k <- witness;
    k_init <- witness;
    m <- witness;
    m_init <- witness;
    s <- witness;
    s_init <- witness;
    trace__sha512_x4_compress_lanes <- [];
    off_init <- true;
    n_init <- true;
    ms_init <- true;
    k_init <- (BArray640.init_arr (W8.of_int 0));
    i_init <- false;
    s_init <- (BArray160.init_arr (W8.of_int 0));
    p_init <- false;
    q_init <- false;
    c_init <- false;
    more_init <- false;
    j_init <- false;
    m_init <- (BArray256.init_arr (W8.of_int 0));
    k <- sHA512_K;
    k_init <- (BArray640.init_arr (W8.of_int 255));
    i_init <- true;
    i <- 0;
    while ((i < 2)) {
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, i_init)]);
      (s, s_init, tmp__trace) <@ __sha512_x4_load_pair (h4, i, h4_init);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ tmp__trace);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, i_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert, ((0 <= ((2 * i) * 8)) /\ ((((2 * i) * 8) + 8) <= 32)))]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert, (BArray32.is_init in_init ((2 * i) * 8) 8))]);
      p <- (BArray32.get64 in_0 (2 * i));
      p_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, off_init)]);
      p <- (p + off);
      p_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, i_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert,
       ((0 <= (((2 * i) + 1) * 8)) /\ (((((2 * i) + 1) * 8) + 8) <= 32)))]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert, (BArray32.is_init in_init (((2 * i) + 1) * 8) 8))]);
      q <- (BArray32.get64 in_0 ((2 * i) + 1));
      q_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, q_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      q <- (protect_64 q ms);
      q_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, q_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, off_init)]);
      q <- (q + off);
      q_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, n_init)]);
      c <- n;
      c_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, c_init)]);
      more <- (c <> (W64.of_int 0));
      more_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, more_init)]);
      while (more) {
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, more_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
        ms <- (update_msf more ms);
        ms_init <- true;
        j_init <- true;
        j <- 0;
        while ((j < 8)) {
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, p_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert,
           (is_valid ptr_modulus Glob.mem_v
           (W64.to_uint (p + (W64.of_int (16 * j)))) 16))]);
          m <-
          (BArray256.set128 m j
          (loadW128 Glob.mem (W64.to_uint (p + (W64.of_int (16 * j))))));
          m_init <-
          (BArray256.set128 m_init j
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert, ((0 <= (j * 16)) /\ (((j * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert, (BArray256.is_init m_init (j * 16) 16))]);
          m <- (BArray256.set128 m j (VREV64_16u8 (BArray256.get128 m j)));
          m_init <-
          (BArray256.set128 m_init j
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert,
           ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, q_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert,
           (is_valid ptr_modulus Glob.mem_v
           (W64.to_uint (q + (W64.of_int (16 * j)))) 16))]);
          m <-
          (BArray256.set128 m (8 + j)
          (loadW128 Glob.mem (W64.to_uint (q + (W64.of_int (16 * j))))));
          m_init <-
          (BArray256.set128 m_init (8 + j)
          (W128.of_int 340282366920938463463374607431768211455));
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert,
           ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert,
           ((0 <= ((8 + j) * 16)) /\ ((((8 + j) * 16) + 16) <= 256)))]);
          trace__sha512_x4_compress_lanes <-
          (trace__sha512_x4_compress_lanes ++
          [(Assert, (BArray256.is_init m_init ((8 + j) * 16) 16))]);
          m <-
          (BArray256.set128 m (8 + j)
          (VREV64_16u8 (BArray256.get128 m (8 + j))));
          m_init <-
          (BArray256.set128 m_init (8 + j)
          (W128.of_int 340282366920938463463374607431768211455));
          j <- (j + 1);
        }
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        (s, m, s_init, m_init, tmp__trace) <@ __sha512_x4_block2 (s, 
        m, k, s_init, m_init, k_init);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ tmp__trace);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, p_init)]);
        p <- (p + (W64.of_int 128));
        p_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, q_init)]);
        q <- (q + (W64.of_int 128));
        q_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, c_init)]);
        c <- (c - (W64.of_int 1));
        c_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, c_init)]);
        more <- (c <> (W64.of_int 0));
        more_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, more_init)]);
      }
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, more_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf (! more) ms);
      ms_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, i_init)]);
      (h4, h4_init, tmp__trace) <@ __sha512_x4_store_pair (h4, s, i, 
      h4_init, s_init);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ tmp__trace);
      i <- (i + 1);
    }
    trace__sha512_x4_compress_lanes <-
    (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
    return (h4, ms, h4_init, trace__sha512_x4_compress_lanes);
  }
  proc __sha512_x4_init (h:BArray256.t, h_init:BArray256.t) : BArray256.t *
                                                              BArray256.t *
                                                              trace = {
    var iv:BArray64.t;
    var j:int;
    var t:W64.t;
    var k:int;
    var iv_init:BArray64.t;
    var j_init:bool;
    var t_init:bool;
    var k_init:bool;
    var trace___sha512_x4_init:trace;
    iv <- witness;
    iv_init <- witness;
    trace___sha512_x4_init <- [];
    iv_init <- (BArray64.init_arr (W8.of_int 0));
    j_init <- false;
    t_init <- false;
    k_init <- false;
    iv <- sHA512_IV;
    iv_init <- (BArray64.init_arr (W8.of_int 255));
    j_init <- true;
    j <- 0;
    while ((j < 8)) {
      trace___sha512_x4_init <-
      (trace___sha512_x4_init ++ [(Assert, j_init)]);
      trace___sha512_x4_init <- (trace___sha512_x4_init ++ [(Assert, true)]);
      trace___sha512_x4_init <-
      (trace___sha512_x4_init ++
      [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
      trace___sha512_x4_init <-
      (trace___sha512_x4_init ++
      [(Assert, (BArray64.is_init iv_init (j * 8) 8))]);
      t <- (BArray64.get64 iv j);
      t_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace___sha512_x4_init <-
        (trace___sha512_x4_init ++ [(Assert, j_init)]);
        trace___sha512_x4_init <-
        (trace___sha512_x4_init ++ [(Assert, k_init)]);
        trace___sha512_x4_init <-
        (trace___sha512_x4_init ++ [(Assert, true)]);
        trace___sha512_x4_init <-
        (trace___sha512_x4_init ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace___sha512_x4_init <-
        (trace___sha512_x4_init ++ [(Assert, t_init)]);
        h <- (BArray256.set64 h ((4 * j) + k) t);
        h_init <-
        (BArray256.set64 h_init ((4 * j) + k)
        (W64.of_int 18446744073709551615));
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    return (h, h_init, trace___sha512_x4_init);
  }
  proc __sha512_x4_from (h:BArray256.t, buf:BArray512.t, hs:BArray64.t,
                         bs:BArray128.t, h_init:BArray256.t,
                         buf_init:BArray512.t, hs_init:BArray64.t,
                         bs_init:BArray128.t) : BArray256.t * BArray512.t *
                                                BArray256.t * BArray512.t *
                                                trace = {
    var j:int;
    var x:W64.t;
    var k:int;
    var i:int;
    var t:W64.t;
    var j_init:bool;
    var x_init:bool;
    var k_init:bool;
    var i_init:bool;
    var t_init:bool;
    var trace___sha512_x4_from:trace;
    trace___sha512_x4_from <- [];
    j_init <- false;
    x_init <- false;
    k_init <- false;
    i_init <- false;
    t_init <- false;
    j_init <- true;
    j <- 0;
    while ((j < 8)) {
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++ [(Assert, j_init)]);
      trace___sha512_x4_from <- (trace___sha512_x4_from ++ [(Assert, true)]);
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++
      [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++
      [(Assert, (BArray64.is_init hs_init (j * 8) 8))]);
      x <- (BArray64.get64 hs j);
      x_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, j_init)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, k_init)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, true)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, x_init)]);
        h <- (BArray256.set64 h ((4 * j) + k) x);
        h_init <-
        (BArray256.set64 h_init ((4 * j) + k)
        (W64.of_int 18446744073709551615));
        k <- (k + 1);
      }
      j <- (j + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++ [(Assert, i_init)]);
      trace___sha512_x4_from <- (trace___sha512_x4_from ++ [(Assert, true)]);
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace___sha512_x4_from <-
      (trace___sha512_x4_from ++
      [(Assert, (BArray128.is_init bs_init (i * 8) 8))]);
      t <- (BArray128.get64 bs i);
      t_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, k_init)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, i_init)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, true)]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++
        [(Assert,
         ((0 <= (((128 * k) + (8 * i)) * 1)) /\
         (((((128 * k) + (8 * i)) * 1) + 8) <= 512)))]);
        trace___sha512_x4_from <-
        (trace___sha512_x4_from ++ [(Assert, t_init)]);
        buf <- (BArray512.set64d buf ((128 * k) + (8 * i)) t);
        buf_init <-
        (BArray512.set64d buf_init ((128 * k) + (8 * i))
        (W64.of_int 18446744073709551615));
        k <- (k + 1);
      }
      i <- (i + 1);
    }
    return (h, buf, h_init, buf_init, trace___sha512_x4_from);
  }
  proc _sha512_x4_absorb_lanes (h:BArray256.t, buf:BArray512.t, total:W64.t,
                                in_0:BArray32.t, inlen:W64.t, ms:W64.t,
                                h_init:BArray256.t, buf_init:BArray512.t,
                                in_init:BArray32.t) : BArray256.t *
                                                      BArray512.t * W64.t *
                                                      W64.t * BArray256.t *
                                                      BArray512.t * trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var n:W64.t;
    var k:int;
    var p:W64.t;
    var off:W64.t;
    var full:bool;
    var more:bool;
    var total_init:bool;
    var fill_init:bool;
    var inlen_init:bool;
    var n_init:bool;
    var k_init:bool;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var full_init:bool;
    var more_init:bool;
    var trace__sha512_x4_absorb_lanes:trace;
    trace__sha512_x4_absorb_lanes <- [];
    total_init <- true;
    inlen_init <- true;
    ms_init <- true;
    fill_init <- false;
    n_init <- false;
    k_init <- false;
    p_init <- false;
    off_init <- false;
    full_init <- false;
    more_init <- false;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
    total <- (total + inlen);
    total_init <- true;
    n <- (W64.of_int 128);
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    n <- (n - fill);
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    n <- ((inlen \ult n) ? inlen : n);
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    n <- ((fill = (W64.of_int 0)) ? fill : n);
    n_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 32)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, (BArray32.is_init in_init (k * 8) 8))]);
      p <- (BArray32.get64 in_0 k);
      p_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __fill128_mem ((
                                                        SBArray512_128.get_sub8
                                                        buf (128 * k)),
      fill, p, n, ms, (SBArray512_128.get_sub buf_init (1 * (128 * k))));
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    fill <- (fill + n);
    fill_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    off <- n;
    off_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
    full <- (fill = (W64.of_int 128));
    full_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, full_init)]);
    if (full) {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, full_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf full ms);
      ms_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to spill *)
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms, 
      h_init, buf_init);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to unspill *)
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray32.init_arr (W8.of_int 255));
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, full_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf (! full) ms);
      ms_init <- true;
    }
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
    n <- (n - off);
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    n <- (n `>>` (W8.of_int 7));
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    more <- (n <> (W64.of_int 0));
    more_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, more_init)]);
    if (more) {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, more_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to spill *)
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress_lanes (h, in_0, 
      off, n, ms, h_init, in_init);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      (* Erased call to unspill *)
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray32.init_arr (W8.of_int 255));
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      inlen <- (protect_64 inlen ms);
      inlen_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
      n <- inlen;
      n_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      n <- (n - off);
      n_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      n <- (n `>>` (W8.of_int 7));
      n_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      n <- (n `<<` (W8.of_int 7));
      n_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, more_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      ms <- (update_msf (! more) ms);
      ms_init <- true;
    }
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, inlen_init)]);
    n <- inlen;
    n_init <- true;
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
    n <- (n - off);
    n_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 32)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, (BArray32.is_init in_init (k * 8) 8))]);
      p <- (BArray32.get64 in_0 k);
      p_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, off_init)]);
      p <- (p + off);
      p_init <- true;
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, true)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, fill_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __fill128_mem ((
                                                        SBArray512_128.get_sub8
                                                        buf (128 * k)),
      fill, p, n, ms, (SBArray512_128.get_sub buf_init (1 * (128 * k))));
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
      trace__sha512_x4_absorb_lanes <-
      (trace__sha512_x4_absorb_lanes ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, total_init)]);
    trace__sha512_x4_absorb_lanes <-
    (trace__sha512_x4_absorb_lanes ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace__sha512_x4_absorb_lanes);
  }
  proc _sha512_x4_finalize (out:BArray256.t, h:BArray256.t, buf:BArray512.t,
                            total:W64.t, ms:W64.t, out_init:BArray256.t,
                            h_init:BArray256.t, buf_init:BArray512.t) : 
  BArray256.t * BArray256.t * BArray512.t * W64.t * BArray256.t *
  BArray256.t * BArray512.t * trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
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
    var total_init:bool;
    var fill_init:bool;
    var at_init:bool;
    var t_init:bool;
    var k_init:bool;
    var two_blocks_init:bool;
    var ms_init:bool;
    var hi_init:bool;
    var u_init:bool;
    var j_init:bool;
    var x_init:bool;
    var trace__sha512_x4_finalize:trace;
    trace__sha512_x4_finalize <- [];
    total_init <- true;
    ms_init <- true;
    fill_init <- false;
    at_init <- false;
    t_init <- false;
    k_init <- false;
    two_blocks_init <- false;
    hi_init <- false;
    u_init <- false;
    j_init <- false;
    x_init <- false;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
    at <- fill;
    at_init <- true;
    t <- (W64.of_int 128);
    t_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, at_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++
      [(Assert,
       ((0 <= ((W64.to_uint at) * 1)) /\
       ((((W64.to_uint at) * 1) + 1) <= 512)))]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, t_init)]);
      buf <- (BArray512.set8 buf (W64.to_uint at) (truncateu8 t));
      buf_init <- (BArray512.set8 buf_init (W64.to_uint at) (W8.of_int 255));
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, at_init)]);
      at <- (at + (W64.of_int 128));
      at_init <- true;
      k <- (k + 1);
    }
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
    fill <- (fill + (W64.of_int 1));
    fill_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
    two_blocks <- ((W64.of_int 112) \ult fill);
    two_blocks_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, two_blocks_init)]);
    if (two_blocks) {
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf two_blocks ms);
      ms_init <- true;
      hi <- (W64.of_int 128);
      hi_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, true)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, hi_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ __zero128 ((
                                                      SBArray512_128.get_sub8
                                                      buf (128 * k)),
        fill, hi, ms, (SBArray512_128.get_sub buf_init (1 * (128 * k))));
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ tmp__trace);
        ms_init <- true;
        k <- (k + 1);
      }
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
      (* Erased call to spill *)
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms, 
      h_init, buf_init);
      trace__sha512_x4_finalize <- (trace__sha512_x4_finalize ++ tmp__trace);
      ms_init <- true;
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
      (* Erased call to unspill *)
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      out <- (protect_ptr out ms);
      out_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      buf <- (protect_ptr buf ms);
      buf_init <- (BArray512.init_arr (W8.of_int 255));
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      total <- (protect_64 total ms);
      total_init <- true;
      fill <- (W64.of_int 0);
      fill_init <- true;
    } else {
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, two_blocks_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      ms <- (update_msf (! two_blocks) ms);
      ms_init <- true;
    }
    hi <- (W64.of_int 112);
    hi_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, fill_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, hi_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, tmp__trace) <@ __zero128 ((SBArray512_128.get_sub8
                                                    buf (128 * k)),
      fill, hi, ms, (SBArray512_128.get_sub buf_init (1 * (128 * k))));
      buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
      ms <- aux_0;
      buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
      trace__sha512_x4_finalize <- (trace__sha512_x4_finalize ++ tmp__trace);
      ms_init <- true;
      k <- (k + 1);
    }
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
    t <- total;
    t_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 61));
    t_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, t_init)]);
    (t, tmp__trace) <@ __bswap64 (t);
    trace__sha512_x4_finalize <- (trace__sha512_x4_finalize ++ tmp__trace);
    t_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, total_init)]);
    u <- total;
    u_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, u_init)]);
    u <- (u `<<` (W8.of_int 3));
    u_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, u_init)]);
    (u, tmp__trace) <@ __bswap64 (u);
    trace__sha512_x4_finalize <- (trace__sha512_x4_finalize ++ tmp__trace);
    u_init <- true;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++
      [(Assert,
       ((0 <= (((128 * k) + 112) * 1)) /\
       (((((128 * k) + 112) * 1) + 8) <= 512)))]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, t_init)]);
      buf <- (BArray512.set64d buf ((128 * k) + 112) t);
      buf_init <-
      (BArray512.set64d buf_init ((128 * k) + 112)
      (W64.of_int 18446744073709551615));
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, true)]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++
      [(Assert,
       ((0 <= (((128 * k) + 120) * 1)) /\
       (((((128 * k) + 120) * 1) + 8) <= 512)))]);
      trace__sha512_x4_finalize <-
      (trace__sha512_x4_finalize ++ [(Assert, u_init)]);
      buf <- (BArray512.set64d buf ((128 * k) + 120) u);
      buf_init <-
      (BArray512.set64d buf_init ((128 * k) + 120)
      (W64.of_int 18446744073709551615));
      k <- (k + 1);
    }
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
    (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms, h_init,
    buf_init);
    trace__sha512_x4_finalize <- (trace__sha512_x4_finalize ++ tmp__trace);
    ms_init <- true;
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, true)]);
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
    buf <- (protect_ptr buf ms);
    buf_init <- (BArray512.init_arr (W8.of_int 255));
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, j_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, true)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++
        [(Assert, (BArray256.is_init h_init (((4 * j) + k) * 8) 8))]);
        x <- (BArray256.get64 h ((4 * j) + k));
        x_init <- true;
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, true)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, x_init)]);
        (x, tmp__trace) <@ __bswap64 (x);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ tmp__trace);
        x_init <- true;
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, k_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, j_init)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, true)]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++
        [(Assert,
         ((0 <= (((8 * k) + j) * 8)) /\ (((((8 * k) + j) * 8) + 8) <= 256)))]);
        trace__sha512_x4_finalize <-
        (trace__sha512_x4_finalize ++ [(Assert, x_init)]);
        out <- (BArray256.set64 out ((8 * k) + j) x);
        out_init <-
        (BArray256.set64 out_init ((8 * k) + j)
        (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    trace__sha512_x4_finalize <-
    (trace__sha512_x4_finalize ++ [(Assert, ms_init)]);
    return (out, h, buf, ms, out_init, h_init, buf_init,
           trace__sha512_x4_finalize);
  }
  proc _sha512_x4_lanes (out:BArray256.t, in_0:BArray32.t, len:W64.t,
                         ms:W64.t, out_init:BArray256.t, in_init:BArray32.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var len_init:bool;
    var ms_init:bool;
    var trace__sha512_x4_lanes:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace__sha512_x4_lanes <- [];
    len_init <- true;
    ms_init <- true;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_x4_init (h, h_init);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, total_init)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, len_init)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ _sha512_x4_absorb_lanes (
    h, buf, total, in_0, len, ms, h_init, buf_init, in_init);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ [(Assert, true)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, total_init)]);
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_x4_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace__sha512_x4_lanes <- (trace__sha512_x4_lanes ++ tmp__trace);
    ms_init <- true;
    trace__sha512_x4_lanes <-
    (trace__sha512_x4_lanes ++ [(Assert, ms_init)]);
    return (out, ms, out_init, trace__sha512_x4_lanes);
  }
  proc __sha256_x8_ctx_init (ctx:BArray784.t, ctx_init:BArray784.t) : 
  BArray784.t * BArray784.t * trace = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var tag:W64.t;
    var z:W64.t;
    var i:int;
    var tag_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace___sha256_x8_ctx_init:trace;
    trace___sha256_x8_ctx_init <- [];
    tag_init <- false;
    z_init <- false;
    i_init <- false;
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (9);
    trace___sha256_x8_ctx_init <- (trace___sha256_x8_ctx_init ++ tmp__trace);
    tag_init <- true;
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, true)]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 784)))]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, tag_init)]);
    ctx <- (BArray784.set64d ctx 0 tag);
    ctx_init <-
    (BArray784.set64d ctx_init 0 (W64.of_int 18446744073709551615));
    z <- (W64.of_int 0);
    z_init <- true;
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, true)]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++
    [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, z_init)]);
    ctx <- (BArray784.set64d ctx 8 z);
    ctx_init <-
    (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++ [(Assert, true)]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
    trace___sha256_x8_ctx_init <-
    (trace___sha256_x8_ctx_init ++
    [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
    (aux, aux_0, tmp__trace) <@ __sha256_x8_init ((SBArray784_256.get_sub32
                                                  ctx 4),
    (SBArray784_256.get_sub ctx_init (4 * 4)));
    ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
    ctx_init <- (SBArray784_256.set_sub ctx_init (4 * 4) aux_0);
    trace___sha256_x8_ctx_init <- (trace___sha256_x8_ctx_init ++ tmp__trace);
    i_init <- true;
    i <- 0;
    while ((i < 64)) {
      trace___sha256_x8_ctx_init <-
      (trace___sha256_x8_ctx_init ++ [(Assert, i_init)]);
      trace___sha256_x8_ctx_init <-
      (trace___sha256_x8_ctx_init ++ [(Assert, true)]);
      trace___sha256_x8_ctx_init <-
      (trace___sha256_x8_ctx_init ++
      [(Assert,
       ((0 <= ((272 + (8 * i)) * 1)) /\ ((((272 + (8 * i)) * 1) + 8) <= 784)))]);
      trace___sha256_x8_ctx_init <-
      (trace___sha256_x8_ctx_init ++ [(Assert, z_init)]);
      ctx <- (BArray784.set64d ctx (272 + (8 * i)) z);
      ctx_init <-
      (BArray784.set64d ctx_init (272 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (ctx, ctx_init, trace___sha256_x8_ctx_init);
  }
  proc _sha256_x8_ctx_from (ctx:BArray784.t, src:BArray112.t, ms:W64.t,
                            ctx_init:BArray784.t, src_init:BArray112.t) : 
  BArray784.t * W64.t * W64.t * BArray784.t * trace = {
    var aux:BArray256.t;
    var aux_1:BArray256.t;
    var aux_0:BArray512.t;
    var aux_2:BArray512.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var trace__sha256_x8_ctx_from:trace;
    trace__sha256_x8_ctx_from <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 112)))]);
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray112_16.get_sub8 
                                                 src 0),
    ms, (SBArray112_16.get_sub src_init (1 * 0)));
    trace__sha256_x8_ctx_from <- (trace__sha256_x8_ctx_from ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (2);
    trace__sha256_x8_ctx_from <- (trace__sha256_x8_ctx_from ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, tag_init)]);
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      (tag, tmp__trace) <@ __sha2_tag (9);
      trace__sha256_x8_ctx_from <- (trace__sha256_x8_ctx_from ++ tmp__trace);
      tag_init <- true;
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, tag_init)]);
      ctx <- (BArray784.set64d ctx 0 tag);
      ctx_init <-
      (BArray784.set64d ctx_init 0 (W64.of_int 18446744073709551615));
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, total_init)]);
      ctx <- (BArray784.set64d ctx 8 total);
      ctx_init <-
      (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 32) <= 112)))]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++
      [(Assert, ((0 <= (48 * 1)) /\ (((48 * 1) + 64) <= 112)))]);
      (aux, aux_0, aux_1, aux_2, tmp__trace) <@ __sha256_x8_from ((
                                                                  SBArray784_256.get_sub32
                                                                  ctx 4),
      (SBArray784_512.get_sub8 ctx 272), (SBArray112_32.get_sub32 src 4),
      (SBArray112_64.get_sub8 src 48),
      (SBArray784_256.get_sub ctx_init (4 * 4)),
      (SBArray784_512.get_sub ctx_init (1 * 272)),
      (SBArray112_32.get_sub src_init (4 * 4)),
      (SBArray112_64.get_sub src_init (1 * 48)));
      ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
      ctx_init <- (SBArray784_256.set_sub ctx_init (4 * 4) aux_1);
      ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_2);
      trace__sha256_x8_ctx_from <- (trace__sha256_x8_ctx_from ++ tmp__trace);
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, true)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_from <-
      (trace__sha256_x8_ctx_from ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, status_init)]);
    trace__sha256_x8_ctx_from <-
    (trace__sha256_x8_ctx_from ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha256_x8_ctx_from);
  }
  proc _sha256_x8_ctx_update (ctx:BArray784.t, in_0:BArray64.t, inlen:W64.t,
                              ms:W64.t, ctx_init:BArray784.t,
                              in_init:BArray64.t) : BArray784.t * W64.t *
                                                    W64.t * BArray784.t *
                                                    trace = {
    var aux:BArray256.t;
    var aux_3:BArray256.t;
    var aux_0:BArray512.t;
    var aux_4:BArray512.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var room:W64.t;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var room_init:bool;
    var inlen_init:bool;
    var trace__sha256_x8_ctx_update:trace;
    trace__sha256_x8_ctx_update <- [];
    inlen_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    room_init <- false;
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 784)))]);
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray784_16.get_sub ctx_init (1 * 0)));
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (9);
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, tag_init)]);
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, total_init)]);
      (room, tmp__trace) <@ __sha2_room (total);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ tmp__trace);
      room_init <- true;
      status <- (W64.of_int 2);
      status_init <- true;
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, inlen_init)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, room_init)]);
      ok <- (inlen \ult room);
      ok_init <- true;
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
      if (ok) {
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf ok ms);
        ms_init <- true;
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++
        [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++
        [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++
        [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++
        [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, total_init)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, inlen_init)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, aux_2, aux_3, aux_4, tmp__trace) <@ _sha256_x8_absorb_lanes (
        (SBArray784_256.get_sub32 ctx 4), (SBArray784_512.get_sub8 ctx 272),
        total, in_0, inlen, ms, (SBArray784_256.get_sub ctx_init (4 * 4)),
        (SBArray784_512.get_sub ctx_init (1 * 272)), in_init);
        ctx <- (SBArray784_256.set_sub32 ctx 4 aux);
        ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx_init <- (SBArray784_256.set_sub ctx_init (4 * 4) aux_3);
        ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_4);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ tmp__trace);
        total_init <- true;
        ms_init <- true;
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++
        [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, total_init)]);
        ctx <- (BArray784.set64d ctx 8 total);
        ctx_init <-
        (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
        status <- (W64.of_int 0);
        status_init <- true;
      } else {
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
        trace__sha256_x8_ctx_update <-
        (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf (! ok) ms);
        ms_init <- true;
      }
    } else {
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, true)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_update <-
      (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, status_init)]);
    trace__sha256_x8_ctx_update <-
    (trace__sha256_x8_ctx_update ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha256_x8_ctx_update);
  }
  proc _sha256_x8_ctx_final (ctx:BArray784.t, out:BArray256.t, ms:W64.t,
                             ctx_init:BArray784.t, out_init:BArray256.t) : 
  BArray784.t * BArray256.t * W64.t * W64.t * BArray784.t * BArray256.t *
  trace = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var aux_3:BArray256.t;
    var aux_4:BArray256.t;
    var aux_1:BArray512.t;
    var aux_5:BArray512.t;
    var aux_2:W64.t;
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha256_x8_ctx_final:trace;
    trace__sha256_x8_ctx_final <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 784)))]);
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray784_16.get_sub ctx_init (1 * 0)));
    trace__sha256_x8_ctx_final <- (trace__sha256_x8_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (9);
    trace__sha256_x8_ctx_final <- (trace__sha256_x8_ctx_final ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, tag_init)]);
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++
      [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++
      [(Assert, ((0 <= (4 * 4)) /\ (((4 * 4) + 256) <= 784)))]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, total_init)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ 
      _sha256_x8_finalize (out, (SBArray784_256.get_sub32 ctx 4),
      (SBArray784_512.get_sub8 ctx 272), total, ms, out_init,
      (SBArray784_256.get_sub ctx_init (4 * 4)),
      (SBArray784_512.get_sub ctx_init (1 * 272)));
      out <- aux;
      ctx <- (SBArray784_256.set_sub32 ctx 4 aux_0);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_1);
      ms <- aux_2;
      out_init <- aux_3;
      ctx_init <- (SBArray784_256.set_sub ctx_init (4 * 4) aux_4);
      ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_5);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (784 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha256_x8_ctx_final <-
        (trace__sha256_x8_ctx_final ++ [(Assert, i_init)]);
        trace__sha256_x8_ctx_final <-
        (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
        trace__sha256_x8_ctx_final <-
        (trace__sha256_x8_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 784)))]);
        trace__sha256_x8_ctx_final <-
        (trace__sha256_x8_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray784.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray784.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, true)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, ok_init)]);
      trace__sha256_x8_ctx_final <-
      (trace__sha256_x8_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, status_init)]);
    trace__sha256_x8_ctx_final <-
    (trace__sha256_x8_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, out, status, ms, ctx_init, out_init,
           trace__sha256_x8_ctx_final);
  }
  proc __sha512_x4_ctx_init (ctx:BArray784.t, ctx_init:BArray784.t) : 
  BArray784.t * BArray784.t * trace = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var tag:W64.t;
    var z:W64.t;
    var i:int;
    var tag_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace___sha512_x4_ctx_init:trace;
    trace___sha512_x4_ctx_init <- [];
    tag_init <- false;
    z_init <- false;
    i_init <- false;
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (10);
    trace___sha512_x4_ctx_init <- (trace___sha512_x4_ctx_init ++ tmp__trace);
    tag_init <- true;
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, true)]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 784)))]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, tag_init)]);
    ctx <- (BArray784.set64d ctx 0 tag);
    ctx_init <-
    (BArray784.set64d ctx_init 0 (W64.of_int 18446744073709551615));
    z <- (W64.of_int 0);
    z_init <- true;
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, true)]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++
    [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, z_init)]);
    ctx <- (BArray784.set64d ctx 8 z);
    ctx_init <-
    (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++ [(Assert, true)]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
    trace___sha512_x4_ctx_init <-
    (trace___sha512_x4_ctx_init ++
    [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
    (aux, aux_0, tmp__trace) <@ __sha512_x4_init ((SBArray784_256.get_sub64
                                                  ctx 2),
    (SBArray784_256.get_sub ctx_init (8 * 2)));
    ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
    ctx_init <- (SBArray784_256.set_sub ctx_init (8 * 2) aux_0);
    trace___sha512_x4_ctx_init <- (trace___sha512_x4_ctx_init ++ tmp__trace);
    i_init <- true;
    i <- 0;
    while ((i < 64)) {
      trace___sha512_x4_ctx_init <-
      (trace___sha512_x4_ctx_init ++ [(Assert, i_init)]);
      trace___sha512_x4_ctx_init <-
      (trace___sha512_x4_ctx_init ++ [(Assert, true)]);
      trace___sha512_x4_ctx_init <-
      (trace___sha512_x4_ctx_init ++
      [(Assert,
       ((0 <= ((272 + (8 * i)) * 1)) /\ ((((272 + (8 * i)) * 1) + 8) <= 784)))]);
      trace___sha512_x4_ctx_init <-
      (trace___sha512_x4_ctx_init ++ [(Assert, z_init)]);
      ctx <- (BArray784.set64d ctx (272 + (8 * i)) z);
      ctx_init <-
      (BArray784.set64d ctx_init (272 + (8 * i))
      (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (ctx, ctx_init, trace___sha512_x4_ctx_init);
  }
  proc _sha512_x4_ctx_from (ctx:BArray784.t, src:BArray208.t, ms:W64.t,
                            ctx_init:BArray784.t, src_init:BArray208.t) : 
  BArray784.t * W64.t * W64.t * BArray784.t * trace = {
    var aux:BArray256.t;
    var aux_1:BArray256.t;
    var aux_0:BArray512.t;
    var aux_2:BArray512.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var trace__sha512_x4_ctx_from:trace;
    trace__sha512_x4_ctx_from <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 208)))]);
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray208_16.get_sub8 
                                                 src 0),
    ms, (SBArray208_16.get_sub src_init (1 * 0)));
    trace__sha512_x4_ctx_from <- (trace__sha512_x4_ctx_from ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (4);
    trace__sha512_x4_ctx_from <- (trace__sha512_x4_ctx_from ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, tag_init)]);
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      (tag, tmp__trace) <@ __sha2_tag (10);
      trace__sha512_x4_ctx_from <- (trace__sha512_x4_ctx_from ++ tmp__trace);
      tag_init <- true;
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 8) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, tag_init)]);
      ctx <- (BArray784.set64d ctx 0 tag);
      ctx_init <-
      (BArray784.set64d ctx_init 0 (W64.of_int 18446744073709551615));
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, total_init)]);
      ctx <- (BArray784.set64d ctx 8 total);
      ctx_init <-
      (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 64) <= 208)))]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++
      [(Assert, ((0 <= (80 * 1)) /\ (((80 * 1) + 128) <= 208)))]);
      (aux, aux_0, aux_1, aux_2, tmp__trace) <@ __sha512_x4_from ((
                                                                  SBArray784_256.get_sub64
                                                                  ctx 2),
      (SBArray784_512.get_sub8 ctx 272), (SBArray208_64.get_sub64 src 2),
      (SBArray208_128.get_sub8 src 80),
      (SBArray784_256.get_sub ctx_init (8 * 2)),
      (SBArray784_512.get_sub ctx_init (1 * 272)),
      (SBArray208_64.get_sub src_init (8 * 2)),
      (SBArray208_128.get_sub src_init (1 * 80)));
      ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
      ctx_init <- (SBArray784_256.set_sub ctx_init (8 * 2) aux_1);
      ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_2);
      trace__sha512_x4_ctx_from <- (trace__sha512_x4_ctx_from ++ tmp__trace);
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, true)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_from <-
      (trace__sha512_x4_ctx_from ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, status_init)]);
    trace__sha512_x4_ctx_from <-
    (trace__sha512_x4_ctx_from ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha512_x4_ctx_from);
  }
  proc _sha512_x4_ctx_update (ctx:BArray784.t, in_0:BArray32.t, inlen:W64.t,
                              ms:W64.t, ctx_init:BArray784.t,
                              in_init:BArray32.t) : BArray784.t * W64.t *
                                                    W64.t * BArray784.t *
                                                    trace = {
    var aux:BArray256.t;
    var aux_3:BArray256.t;
    var aux_0:BArray512.t;
    var aux_4:BArray512.t;
    var aux_1:W64.t;
    var aux_2:W64.t;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var room:W64.t;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var room_init:bool;
    var inlen_init:bool;
    var trace__sha512_x4_ctx_update:trace;
    trace__sha512_x4_ctx_update <- [];
    inlen_init <- true;
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    room_init <- false;
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 784)))]);
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray784_16.get_sub ctx_init (1 * 0)));
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (10);
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, tag_init)]);
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, total_init)]);
      (room, tmp__trace) <@ __sha2_room (total);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ tmp__trace);
      room_init <- true;
      status <- (W64.of_int 2);
      status_init <- true;
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, inlen_init)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, room_init)]);
      ok <- (inlen \ult room);
      ok_init <- true;
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
      if (ok) {
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf ok ms);
        ms_init <- true;
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++
        [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++
        [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++
        [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++
        [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, total_init)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, inlen_init)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, aux_2, aux_3, aux_4, tmp__trace) <@ _sha512_x4_absorb_lanes (
        (SBArray784_256.get_sub64 ctx 2), (SBArray784_512.get_sub8 ctx 272),
        total, in_0, inlen, ms, (SBArray784_256.get_sub ctx_init (8 * 2)),
        (SBArray784_512.get_sub ctx_init (1 * 272)), in_init);
        ctx <- (SBArray784_256.set_sub64 ctx 2 aux);
        ctx <- (SBArray784_512.set_sub8 ctx 272 aux_0);
        total <- aux_1;
        ms <- aux_2;
        ctx_init <- (SBArray784_256.set_sub ctx_init (8 * 2) aux_3);
        ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_4);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ tmp__trace);
        total_init <- true;
        ms_init <- true;
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++
        [(Assert, ((0 <= (8 * 1)) /\ (((8 * 1) + 8) <= 784)))]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, total_init)]);
        ctx <- (BArray784.set64d ctx 8 total);
        ctx_init <-
        (BArray784.set64d ctx_init 8 (W64.of_int 18446744073709551615));
        status <- (W64.of_int 0);
        status_init <- true;
      } else {
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
        trace__sha512_x4_ctx_update <-
        (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
        ms <- (update_msf (! ok) ms);
        ms_init <- true;
      }
    } else {
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, true)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_update <-
      (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, status_init)]);
    trace__sha512_x4_ctx_update <-
    (trace__sha512_x4_ctx_update ++ [(Assert, ms_init)]);
    return (ctx, status, ms, ctx_init, trace__sha512_x4_ctx_update);
  }
  proc _sha512_x4_ctx_final (ctx:BArray784.t, out:BArray256.t, ms:W64.t,
                             ctx_init:BArray784.t, out_init:BArray256.t) : 
  BArray784.t * BArray256.t * W64.t * W64.t * BArray784.t * BArray256.t *
  trace = {
    var aux:BArray256.t;
    var aux_0:BArray256.t;
    var aux_3:BArray256.t;
    var aux_4:BArray256.t;
    var aux_1:BArray512.t;
    var aux_5:BArray512.t;
    var aux_2:W64.t;
    var inc:int;
    var status:W64.t;
    var tag:W64.t;
    var total:W64.t;
    var expect_0:W64.t;
    var ok:bool;
    var z:W64.t;
    var i:int;
    var ms_init:bool;
    var tag_init:bool;
    var total_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var ok_init:bool;
    var z_init:bool;
    var i_init:bool;
    var trace__sha512_x4_ctx_final:trace;
    trace__sha512_x4_ctx_final <- [];
    ms_init <- true;
    status_init <- false;
    tag_init <- false;
    total_init <- false;
    expect_init <- false;
    ok_init <- false;
    z_init <- false;
    i_init <- false;
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 16) <= 784)))]);
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, ms_init)]);
    (tag, total, tmp__trace) <@ __sha2_ctx_open ((SBArray784_16.get_sub8 
                                                 ctx 0),
    ms, (SBArray784_16.get_sub ctx_init (1 * 0)));
    trace__sha512_x4_ctx_final <- (trace__sha512_x4_ctx_final ++ tmp__trace);
    tag_init <- true;
    total_init <- true;
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (10);
    trace__sha512_x4_ctx_final <- (trace__sha512_x4_ctx_final ++ tmp__trace);
    expect_init <- true;
    status <- (W64.of_int 1);
    status_init <- true;
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, tag_init)]);
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, expect_init)]);
    ok <- (tag = expect_0);
    ok_init <- true;
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, ok_init)]);
    if (ok) {
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf ok ms);
      ms_init <- true;
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++
      [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++
      [(Assert, ((0 <= (2 * 8)) /\ (((2 * 8) + 256) <= 784)))]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++
      [(Assert, ((0 <= (272 * 1)) /\ (((272 * 1) + 512) <= 784)))]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, total_init)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, ms_init)]);
      (aux, aux_0, aux_1, aux_2, aux_3, aux_4, aux_5, tmp__trace) <@ 
      _sha512_x4_finalize (out, (SBArray784_256.get_sub64 ctx 2),
      (SBArray784_512.get_sub8 ctx 272), total, ms, out_init,
      (SBArray784_256.get_sub ctx_init (8 * 2)),
      (SBArray784_512.get_sub ctx_init (1 * 272)));
      out <- aux;
      ctx <- (SBArray784_256.set_sub64 ctx 2 aux_0);
      ctx <- (SBArray784_512.set_sub8 ctx 272 aux_1);
      ms <- aux_2;
      out_init <- aux_3;
      ctx_init <- (SBArray784_256.set_sub ctx_init (8 * 2) aux_4);
      ctx_init <- (SBArray784_512.set_sub ctx_init (1 * 272) aux_5);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ tmp__trace);
      ms_init <- true;
      z <- (W64.of_int 0);
      z_init <- true;
      i_init <- true;
      inc <- (784 %/ 8);
      i <- 0;
      while ((i < inc)) {
        trace__sha512_x4_ctx_final <-
        (trace__sha512_x4_ctx_final ++ [(Assert, i_init)]);
        trace__sha512_x4_ctx_final <-
        (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
        trace__sha512_x4_ctx_final <-
        (trace__sha512_x4_ctx_final ++
        [(Assert, ((0 <= ((8 * i) * 1)) /\ ((((8 * i) * 1) + 8) <= 784)))]);
        trace__sha512_x4_ctx_final <-
        (trace__sha512_x4_ctx_final ++ [(Assert, z_init)]);
        ctx <- (BArray784.set64d ctx (8 * i) z);
        ctx_init <-
        (BArray784.set64d ctx_init (8 * i) (W64.of_int 18446744073709551615));
        i <- (i + 1);
      }
      status <- (W64.of_int 0);
      status_init <- true;
    } else {
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, true)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, ok_init)]);
      trace__sha512_x4_ctx_final <-
      (trace__sha512_x4_ctx_final ++ [(Assert, ms_init)]);
      ms <- (update_msf (! ok) ms);
      ms_init <- true;
    }
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, status_init)]);
    trace__sha512_x4_ctx_final <-
    (trace__sha512_x4_ctx_final ++ [(Assert, ms_init)]);
    return (ctx, out, status, ms, ctx_init, out_init,
           trace__sha512_x4_ctx_final);
  }
  proc sha224 (out:BArray28.t, in_0:W64.t, inlen:W64.t, out_init:BArray28.t) : 
  BArray28.t * BArray28.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha224:trace;
    trace_sha224 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha224 <- (trace_sha224 ++ [(Assert, true)]);
    trace_sha224 <- (trace_sha224 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha224 <- (trace_sha224 ++ [(Assert, true)]);
    trace_sha224 <- (trace_sha224 ++ [(Assert, in_init)]);
    trace_sha224 <- (trace_sha224 ++ [(Assert, inlen_init)]);
    trace_sha224 <- (trace_sha224 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha224_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha224 <- (trace_sha224 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha224);
  }
  proc sha256 (out:BArray32.t, in_0:W64.t, inlen:W64.t, out_init:BArray32.t) : 
  BArray32.t * BArray32.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha256:trace;
    trace_sha256 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha256 <- (trace_sha256 ++ [(Assert, true)]);
    trace_sha256 <- (trace_sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256 <- (trace_sha256 ++ [(Assert, true)]);
    trace_sha256 <- (trace_sha256 ++ [(Assert, in_init)]);
    trace_sha256 <- (trace_sha256 ++ [(Assert, inlen_init)]);
    trace_sha256 <- (trace_sha256 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha256_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha256 <- (trace_sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha256);
  }
  proc sha384 (out:BArray48.t, in_0:W64.t, inlen:W64.t, out_init:BArray48.t) : 
  BArray48.t * BArray48.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha384:trace;
    trace_sha384 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha384 <- (trace_sha384 ++ [(Assert, true)]);
    trace_sha384 <- (trace_sha384 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha384 <- (trace_sha384 ++ [(Assert, true)]);
    trace_sha384 <- (trace_sha384 ++ [(Assert, in_init)]);
    trace_sha384 <- (trace_sha384 ++ [(Assert, inlen_init)]);
    trace_sha384 <- (trace_sha384 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha384_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha384 <- (trace_sha384 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha384);
  }
  proc sha512 (out:BArray64.t, in_0:W64.t, inlen:W64.t, out_init:BArray64.t) : 
  BArray64.t * BArray64.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha512:trace;
    trace_sha512 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha512 <- (trace_sha512 ++ [(Assert, true)]);
    trace_sha512 <- (trace_sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512 <- (trace_sha512 ++ [(Assert, true)]);
    trace_sha512 <- (trace_sha512 ++ [(Assert, in_init)]);
    trace_sha512 <- (trace_sha512 ++ [(Assert, inlen_init)]);
    trace_sha512 <- (trace_sha512 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha512 <- (trace_sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha512);
  }
  proc sha512_224 (out:BArray28.t, in_0:W64.t, inlen:W64.t,
                   out_init:BArray28.t) : BArray28.t * BArray28.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha512_224:trace;
    trace_sha512_224 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, true)]);
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, true)]);
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, in_init)]);
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, inlen_init)]);
    trace_sha512_224 <- (trace_sha512_224 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_224_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha512_224 <- (trace_sha512_224 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha512_224);
  }
  proc sha512_256 (out:BArray32.t, in_0:W64.t, inlen:W64.t,
                   out_init:BArray32.t) : BArray32.t * BArray32.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var trace_sha512_256:trace;
    trace_sha512_256 <- [];
    in_init <- true;
    inlen_init <- true;
    ms_init <- false;
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, true)]);
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, true)]);
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, in_init)]);
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, inlen_init)]);
    trace_sha512_256 <- (trace_sha512_256 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_256_mem (out, in_0, inlen, 
    ms, out_init);
    trace_sha512_256 <- (trace_sha512_256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha512_256);
  }
  proc sha224_init (ctx:BArray112.t, ctx_init:BArray112.t) : BArray112.t *
                                                             BArray112.t *
                                                             trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray32.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha224_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha224_init <- [];
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, true)]);
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha224_init (h, h_init);
    trace_sha224_init <- (trace_sha224_init ++ tmp__trace);
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (1);
    trace_sha224_init <- (trace_sha224_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, true)]);
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, tag_init)]);
    trace_sha224_init <- (trace_sha224_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha256_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha224_init <- (trace_sha224_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha224_init);
  }
  proc sha224_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t,
                      ctx_init:BArray112.t) : BArray112.t * W64.t *
                                              BArray112.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha224_update:trace;
    trace_sha224_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, true)]);
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (1);
    trace_sha224_update <- (trace_sha224_update ++ tmp__trace);
    expect_init <- true;
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, true)]);
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, in_init)]);
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, inlen_init)]);
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, expect_init)]);
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha256_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha224_update <- (trace_sha224_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha224_update <- (trace_sha224_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha224_update);
  }
  proc sha224_final (ctx:BArray112.t, out:BArray28.t, ctx_init:BArray112.t,
                     out_init:BArray28.t) : BArray112.t * BArray28.t *
                                            W64.t * BArray112.t *
                                            BArray28.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha224_final:trace;
    trace_sha224_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, true)]);
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (1);
    trace_sha224_final <- (trace_sha224_final ++ tmp__trace);
    expect_init <- true;
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, true)]);
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, expect_init)]);
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha224_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha224_final <- (trace_sha224_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha224_final <- (trace_sha224_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha224_final);
  }
  proc sha256_init (ctx:BArray112.t, ctx_init:BArray112.t) : BArray112.t *
                                                             BArray112.t *
                                                             trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray32.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha256_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha256_init <- [];
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, true)]);
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace_sha256_init <- (trace_sha256_init ++ tmp__trace);
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (2);
    trace_sha256_init <- (trace_sha256_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, true)]);
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, tag_init)]);
    trace_sha256_init <- (trace_sha256_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha256_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha256_init <- (trace_sha256_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha256_init);
  }
  proc sha256_update (ctx:BArray112.t, in_0:W64.t, inlen:W64.t,
                      ctx_init:BArray112.t) : BArray112.t * W64.t *
                                              BArray112.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha256_update:trace;
    trace_sha256_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, true)]);
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (2);
    trace_sha256_update <- (trace_sha256_update ++ tmp__trace);
    expect_init <- true;
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, true)]);
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, in_init)]);
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, inlen_init)]);
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, expect_init)]);
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha256_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha256_update <- (trace_sha256_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha256_update <- (trace_sha256_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha256_update);
  }
  proc sha256_final (ctx:BArray112.t, out:BArray32.t, ctx_init:BArray112.t,
                     out_init:BArray32.t) : BArray112.t * BArray32.t *
                                            W64.t * BArray112.t *
                                            BArray32.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha256_final:trace;
    trace_sha256_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, true)]);
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (2);
    trace_sha256_final <- (trace_sha256_final ++ tmp__trace);
    expect_init <- true;
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, true)]);
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, expect_init)]);
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha256_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha256_final <- (trace_sha256_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha256_final <- (trace_sha256_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha256_final);
  }
  proc sha384_init (ctx:BArray208.t, ctx_init:BArray208.t) : BArray208.t *
                                                             BArray208.t *
                                                             trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray64.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha384_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha384_init <- [];
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, true)]);
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha384_init (h, h_init);
    trace_sha384_init <- (trace_sha384_init ++ tmp__trace);
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (3);
    trace_sha384_init <- (trace_sha384_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, true)]);
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, tag_init)]);
    trace_sha384_init <- (trace_sha384_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha512_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha384_init <- (trace_sha384_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha384_init);
  }
  proc sha384_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                      ctx_init:BArray208.t) : BArray208.t * W64.t *
                                              BArray208.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha384_update:trace;
    trace_sha384_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, true)]);
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (3);
    trace_sha384_update <- (trace_sha384_update ++ tmp__trace);
    expect_init <- true;
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, true)]);
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, in_init)]);
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, inlen_init)]);
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, expect_init)]);
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha384_update <- (trace_sha384_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha384_update <- (trace_sha384_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha384_update);
  }
  proc sha384_final (ctx:BArray208.t, out:BArray48.t, ctx_init:BArray208.t,
                     out_init:BArray48.t) : BArray208.t * BArray48.t *
                                            W64.t * BArray208.t *
                                            BArray48.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha384_final:trace;
    trace_sha384_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, true)]);
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (3);
    trace_sha384_final <- (trace_sha384_final ++ tmp__trace);
    expect_init <- true;
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, true)]);
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, expect_init)]);
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha384_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha384_final <- (trace_sha384_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha384_final <- (trace_sha384_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha384_final);
  }
  proc sha512_init (ctx:BArray208.t, ctx_init:BArray208.t) : BArray208.t *
                                                             BArray208.t *
                                                             trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray64.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha512_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha512_init <- [];
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, true)]);
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace_sha512_init <- (trace_sha512_init ++ tmp__trace);
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (4);
    trace_sha512_init <- (trace_sha512_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, true)]);
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, tag_init)]);
    trace_sha512_init <- (trace_sha512_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha512_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha512_init <- (trace_sha512_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha512_init);
  }
  proc sha512_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                      ctx_init:BArray208.t) : BArray208.t * W64.t *
                                              BArray208.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha512_update:trace;
    trace_sha512_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, true)]);
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (4);
    trace_sha512_update <- (trace_sha512_update ++ tmp__trace);
    expect_init <- true;
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, true)]);
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, in_init)]);
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, inlen_init)]);
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, expect_init)]);
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha512_update <- (trace_sha512_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_update <- (trace_sha512_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha512_update);
  }
  proc sha512_final (ctx:BArray208.t, out:BArray64.t, ctx_init:BArray208.t,
                     out_init:BArray64.t) : BArray208.t * BArray64.t *
                                            W64.t * BArray208.t *
                                            BArray64.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha512_final:trace;
    trace_sha512_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, true)]);
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (4);
    trace_sha512_final <- (trace_sha512_final ++ tmp__trace);
    expect_init <- true;
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, true)]);
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, expect_init)]);
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha512_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha512_final <- (trace_sha512_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_final <- (trace_sha512_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha512_final);
  }
  proc sha512_224_init (ctx:BArray208.t, ctx_init:BArray208.t) : BArray208.t *
                                                                 BArray208.t *
                                                                 trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray64.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha512_224_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha512_224_init <- [];
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, true)]);
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_224_init (h, h_init);
    trace_sha512_224_init <- (trace_sha512_224_init ++ tmp__trace);
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (5);
    trace_sha512_224_init <- (trace_sha512_224_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, true)]);
    trace_sha512_224_init <- (trace_sha512_224_init ++ [(Assert, tag_init)]);
    trace_sha512_224_init <-
    (trace_sha512_224_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha512_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha512_224_init <- (trace_sha512_224_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha512_224_init);
  }
  proc sha512_224_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                          ctx_init:BArray208.t) : BArray208.t * W64.t *
                                                  BArray208.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha512_224_update:trace;
    trace_sha512_224_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_224_update <- (trace_sha512_224_update ++ [(Assert, true)]);
    trace_sha512_224_update <- (trace_sha512_224_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_224_update <- (trace_sha512_224_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (5);
    trace_sha512_224_update <- (trace_sha512_224_update ++ tmp__trace);
    expect_init <- true;
    trace_sha512_224_update <- (trace_sha512_224_update ++ [(Assert, true)]);
    trace_sha512_224_update <-
    (trace_sha512_224_update ++ [(Assert, in_init)]);
    trace_sha512_224_update <-
    (trace_sha512_224_update ++ [(Assert, inlen_init)]);
    trace_sha512_224_update <-
    (trace_sha512_224_update ++ [(Assert, expect_init)]);
    trace_sha512_224_update <-
    (trace_sha512_224_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha512_224_update <- (trace_sha512_224_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_224_update <-
    (trace_sha512_224_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha512_224_update);
  }
  proc sha512_224_final (ctx:BArray208.t, out:BArray28.t,
                         ctx_init:BArray208.t, out_init:BArray28.t) : 
  BArray208.t * BArray28.t * W64.t * BArray208.t * BArray28.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha512_224_final:trace;
    trace_sha512_224_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_224_final <- (trace_sha512_224_final ++ [(Assert, true)]);
    trace_sha512_224_final <- (trace_sha512_224_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_224_final <- (trace_sha512_224_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (5);
    trace_sha512_224_final <- (trace_sha512_224_final ++ tmp__trace);
    expect_init <- true;
    trace_sha512_224_final <- (trace_sha512_224_final ++ [(Assert, true)]);
    trace_sha512_224_final <-
    (trace_sha512_224_final ++ [(Assert, expect_init)]);
    trace_sha512_224_final <-
    (trace_sha512_224_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha512_224_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha512_224_final <- (trace_sha512_224_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_224_final <-
    (trace_sha512_224_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha512_224_final);
  }
  proc sha512_256_init (ctx:BArray208.t, ctx_init:BArray208.t) : BArray208.t *
                                                                 BArray208.t *
                                                                 trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var tag:W64.t;
    var total:W64.t;
    var ms_init:bool;
    var h_init:BArray64.t;
    var tag_init:bool;
    var total_init:bool;
    var trace_sha512_256_init:trace;
    h <- witness;
    h_init <- witness;
    trace_sha512_256_init <- [];
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    tag_init <- false;
    total_init <- false;
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, true)]);
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_256_init (h, h_init);
    trace_sha512_256_init <- (trace_sha512_256_init ++ tmp__trace);
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, true)]);
    (tag, tmp__trace) <@ __sha2_tag (6);
    trace_sha512_256_init <- (trace_sha512_256_init ++ tmp__trace);
    tag_init <- true;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, true)]);
    trace_sha512_256_init <- (trace_sha512_256_init ++ [(Assert, tag_init)]);
    trace_sha512_256_init <-
    (trace_sha512_256_init ++ [(Assert, total_init)]);
    (ctx, ctx_init, tmp__trace) <@ __sha512_ctx_init (ctx, h, tag, total,
    ctx_init, h_init);
    trace_sha512_256_init <- (trace_sha512_256_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha512_256_init);
  }
  proc sha512_256_update (ctx:BArray208.t, in_0:W64.t, inlen:W64.t,
                          ctx_init:BArray208.t) : BArray208.t * W64.t *
                                                  BArray208.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha512_256_update:trace;
    trace_sha512_256_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_256_update <- (trace_sha512_256_update ++ [(Assert, true)]);
    trace_sha512_256_update <- (trace_sha512_256_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_256_update <- (trace_sha512_256_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (6);
    trace_sha512_256_update <- (trace_sha512_256_update ++ tmp__trace);
    expect_init <- true;
    trace_sha512_256_update <- (trace_sha512_256_update ++ [(Assert, true)]);
    trace_sha512_256_update <-
    (trace_sha512_256_update ++ [(Assert, in_init)]);
    trace_sha512_256_update <-
    (trace_sha512_256_update ++ [(Assert, inlen_init)]);
    trace_sha512_256_update <-
    (trace_sha512_256_update ++ [(Assert, expect_init)]);
    trace_sha512_256_update <-
    (trace_sha512_256_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_ctx_update (ctx, 
    in_0, inlen, expect_0, ms, ctx_init);
    trace_sha512_256_update <- (trace_sha512_256_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_256_update <-
    (trace_sha512_256_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha512_256_update);
  }
  proc sha512_256_final (ctx:BArray208.t, out:BArray32.t,
                         ctx_init:BArray208.t, out_init:BArray32.t) : 
  BArray208.t * BArray32.t * W64.t * BArray208.t * BArray32.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var status_init:bool;
    var trace_sha512_256_final:trace;
    trace_sha512_256_final <- [];
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_sha512_256_final <- (trace_sha512_256_final ++ [(Assert, true)]);
    trace_sha512_256_final <- (trace_sha512_256_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_256_final <- (trace_sha512_256_final ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (6);
    trace_sha512_256_final <- (trace_sha512_256_final ++ tmp__trace);
    expect_init <- true;
    trace_sha512_256_final <- (trace_sha512_256_final ++ [(Assert, true)]);
    trace_sha512_256_final <-
    (trace_sha512_256_final ++ [(Assert, expect_init)]);
    trace_sha512_256_final <-
    (trace_sha512_256_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha512_256_ctx___sha2_ctx_final (
    ctx, out, expect_0, ms, ctx_init, out_init);
    trace_sha512_256_final <- (trace_sha512_256_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_256_final <-
    (trace_sha512_256_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha512_256_final);
  }
  proc hmac_sha256 (out:BArray32.t, key:W64.t, keylen:W64.t, msg:W64.t,
                    msglen:W64.t, out_init:BArray32.t) : BArray32.t *
                                                         BArray32.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var msg_init:bool;
    var msglen_init:bool;
    var trace_hmac_sha256:trace;
    trace_hmac_sha256 <- [];
    key_init <- true;
    keylen_init <- true;
    msg_init <- true;
    msglen_init <- true;
    ms_init <- false;
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, true)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, true)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, key_init)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, keylen_init)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, msg_init)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, msglen_init)]);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _hmac_sha256_mem (out, key, keylen,
    msg, msglen, ms, out_init);
    trace_hmac_sha256 <- (trace_hmac_sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_hmac_sha256);
  }
  proc hmac_sha512 (out:BArray64.t, key:W64.t, keylen:W64.t, msg:W64.t,
                    msglen:W64.t, out_init:BArray64.t) : BArray64.t *
                                                         BArray64.t * trace = {
    var ms:W64.t;
    var ms_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var msg_init:bool;
    var msglen_init:bool;
    var trace_hmac_sha512:trace;
    trace_hmac_sha512 <- [];
    key_init <- true;
    keylen_init <- true;
    msg_init <- true;
    msglen_init <- true;
    ms_init <- false;
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, true)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, true)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, key_init)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, keylen_init)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, msg_init)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, msglen_init)]);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _hmac_sha512_mem (out, key, keylen,
    msg, msglen, ms, out_init);
    trace_hmac_sha512 <- (trace_hmac_sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_hmac_sha512);
  }
  proc hmac_sha256_init (ctx:BArray144.t, key:W64.t, keylen:W64.t,
                         ctx_init:BArray144.t) : BArray144.t * BArray144.t *
                                                 trace = {
    var ms:W64.t;
    var ms_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var trace_hmac_sha256_init:trace;
    trace_hmac_sha256_init <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- false;
    trace_hmac_sha256_init <- (trace_hmac_sha256_init ++ [(Assert, true)]);
    trace_hmac_sha256_init <- (trace_hmac_sha256_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha256_init <- (trace_hmac_sha256_init ++ [(Assert, true)]);
    trace_hmac_sha256_init <-
    (trace_hmac_sha256_init ++ [(Assert, key_init)]);
    trace_hmac_sha256_init <-
    (trace_hmac_sha256_init ++ [(Assert, keylen_init)]);
    trace_hmac_sha256_init <-
    (trace_hmac_sha256_init ++ [(Assert, ms_init)]);
    (ctx, ms, ctx_init, tmp__trace) <@ __hmac_sha256_ctx_init (ctx, key,
    keylen, ms, ctx_init);
    trace_hmac_sha256_init <- (trace_hmac_sha256_init ++ tmp__trace);
    ms_init <- true;
    return (ctx, ctx_init, trace_hmac_sha256_init);
  }
  proc hmac_sha256_update (ctx:BArray144.t, in_0:W64.t, inlen:W64.t,
                           ctx_init:BArray144.t) : BArray144.t * W64.t *
                                                   BArray144.t * trace = {
    var aux:BArray112.t;
    var aux_2:BArray112.t;
    var aux_0:W64.t;
    var aux_1:W64.t;
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_hmac_sha256_update:trace;
    trace_hmac_sha256_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, true)]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (7);
    trace_hmac_sha256_update <- (trace_hmac_sha256_update ++ tmp__trace);
    expect_init <- true;
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, true)]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 112) <= 144)))]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 112) <= 144)))]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, in_init)]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, inlen_init)]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, expect_init)]);
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, tmp__trace) <@ _sha256_ctx_update ((
                                                                  SBArray144_112.get_sub8
                                                                  ctx 0),
    in_0, inlen, expect_0, ms, (SBArray144_112.get_sub ctx_init (1 * 0)));
    ctx <- (SBArray144_112.set_sub8 ctx 0 aux);
    status <- aux_0;
    ms <- aux_1;
    ctx_init <- (SBArray144_112.set_sub ctx_init (1 * 0) aux_2);
    trace_hmac_sha256_update <- (trace_hmac_sha256_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_hmac_sha256_update <-
    (trace_hmac_sha256_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_hmac_sha256_update);
  }
  proc hmac_sha256_final (ctx:BArray144.t, out:BArray32.t,
                          ctx_init:BArray144.t, out_init:BArray32.t) : 
  BArray144.t * BArray32.t * W64.t * BArray144.t * BArray32.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_hmac_sha256_final:trace;
    trace_hmac_sha256_final <- [];
    status_init <- false;
    ms_init <- false;
    trace_hmac_sha256_final <- (trace_hmac_sha256_final ++ [(Assert, true)]);
    trace_hmac_sha256_final <- (trace_hmac_sha256_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha256_final <- (trace_hmac_sha256_final ++ [(Assert, true)]);
    trace_hmac_sha256_final <-
    (trace_hmac_sha256_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ __hmac_sha256_ctx_final (
    ctx, out, ms, ctx_init, out_init);
    trace_hmac_sha256_final <- (trace_hmac_sha256_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_hmac_sha256_final <-
    (trace_hmac_sha256_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_hmac_sha256_final);
  }
  proc hmac_sha512_init (ctx:BArray272.t, key:W64.t, keylen:W64.t,
                         ctx_init:BArray272.t) : BArray272.t * BArray272.t *
                                                 trace = {
    var ms:W64.t;
    var ms_init:bool;
    var key_init:bool;
    var keylen_init:bool;
    var trace_hmac_sha512_init:trace;
    trace_hmac_sha512_init <- [];
    key_init <- true;
    keylen_init <- true;
    ms_init <- false;
    trace_hmac_sha512_init <- (trace_hmac_sha512_init ++ [(Assert, true)]);
    trace_hmac_sha512_init <- (trace_hmac_sha512_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha512_init <- (trace_hmac_sha512_init ++ [(Assert, true)]);
    trace_hmac_sha512_init <-
    (trace_hmac_sha512_init ++ [(Assert, key_init)]);
    trace_hmac_sha512_init <-
    (trace_hmac_sha512_init ++ [(Assert, keylen_init)]);
    trace_hmac_sha512_init <-
    (trace_hmac_sha512_init ++ [(Assert, ms_init)]);
    (ctx, ms, ctx_init, tmp__trace) <@ __hmac_sha512_ctx_init (ctx, key,
    keylen, ms, ctx_init);
    trace_hmac_sha512_init <- (trace_hmac_sha512_init ++ tmp__trace);
    ms_init <- true;
    return (ctx, ctx_init, trace_hmac_sha512_init);
  }
  proc hmac_sha512_update (ctx:BArray272.t, in_0:W64.t, inlen:W64.t,
                           ctx_init:BArray272.t) : BArray272.t * W64.t *
                                                   BArray272.t * trace = {
    var aux:BArray208.t;
    var aux_2:BArray208.t;
    var aux_0:W64.t;
    var aux_1:W64.t;
    var status:W64.t;
    var ms:W64.t;
    var expect_0:W64.t;
    var ms_init:bool;
    var expect_init:bool;
    var in_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_hmac_sha512_update:trace;
    trace_hmac_sha512_update <- [];
    in_init <- true;
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    expect_init <- false;
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, true)]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, true)]);
    (expect_0, tmp__trace) <@ __sha2_tag (8);
    trace_hmac_sha512_update <- (trace_hmac_sha512_update ++ tmp__trace);
    expect_init <- true;
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, true)]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 208) <= 272)))]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++
    [(Assert, ((0 <= (0 * 1)) /\ (((0 * 1) + 208) <= 272)))]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, in_init)]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, inlen_init)]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, expect_init)]);
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, ms_init)]);
    (aux, aux_0, aux_1, aux_2, tmp__trace) <@ _sha512_ctx_update ((
                                                                  SBArray272_208.get_sub8
                                                                  ctx 0),
    in_0, inlen, expect_0, ms, (SBArray272_208.get_sub ctx_init (1 * 0)));
    ctx <- (SBArray272_208.set_sub8 ctx 0 aux);
    status <- aux_0;
    ms <- aux_1;
    ctx_init <- (SBArray272_208.set_sub ctx_init (1 * 0) aux_2);
    trace_hmac_sha512_update <- (trace_hmac_sha512_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_hmac_sha512_update <-
    (trace_hmac_sha512_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_hmac_sha512_update);
  }
  proc hmac_sha512_final (ctx:BArray272.t, out:BArray64.t,
                          ctx_init:BArray272.t, out_init:BArray64.t) : 
  BArray272.t * BArray64.t * W64.t * BArray272.t * BArray64.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_hmac_sha512_final:trace;
    trace_hmac_sha512_final <- [];
    status_init <- false;
    ms_init <- false;
    trace_hmac_sha512_final <- (trace_hmac_sha512_final ++ [(Assert, true)]);
    trace_hmac_sha512_final <- (trace_hmac_sha512_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_hmac_sha512_final <- (trace_hmac_sha512_final ++ [(Assert, true)]);
    trace_hmac_sha512_final <-
    (trace_hmac_sha512_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ __hmac_sha512_ctx_final (
    ctx, out, ms, ctx_init, out_init);
    trace_hmac_sha512_final <- (trace_hmac_sha512_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_hmac_sha512_final <-
    (trace_hmac_sha512_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_hmac_sha512_final);
  }
  proc sha256_x8 (out:BArray256.t, in_0:BArray64.t, len:W64.t,
                  out_init:BArray256.t, in_init:BArray64.t) : BArray256.t *
                                                              BArray256.t *
                                                              trace = {
    var ms:W64.t;
    var ms_init:bool;
    var len_init:bool;
    var trace_sha256_x8:trace;
    trace_sha256_x8 <- [];
    len_init <- true;
    ms_init <- false;
    trace_sha256_x8 <- (trace_sha256_x8 ++ [(Assert, true)]);
    trace_sha256_x8 <- (trace_sha256_x8 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_x8 <- (trace_sha256_x8 ++ [(Assert, true)]);
    trace_sha256_x8 <- (trace_sha256_x8 ++ [(Assert, len_init)]);
    trace_sha256_x8 <- (trace_sha256_x8 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha256_x8_lanes (out, in_0, len, 
    ms, out_init, in_init);
    trace_sha256_x8 <- (trace_sha256_x8 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha256_x8);
  }
  proc sha256_x8_init (ctx:BArray784.t, ctx_init:BArray784.t) : BArray784.t *
                                                                BArray784.t *
                                                                trace = {
    var ms:W64.t;
    var ms_init:bool;
    var trace_sha256_x8_init:trace;
    trace_sha256_x8_init <- [];
    ms_init <- false;
    trace_sha256_x8_init <- (trace_sha256_x8_init ++ [(Assert, true)]);
    trace_sha256_x8_init <- (trace_sha256_x8_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_x8_init <- (trace_sha256_x8_init ++ [(Assert, true)]);
    (ctx, ctx_init, tmp__trace) <@ __sha256_x8_ctx_init (ctx, ctx_init);
    trace_sha256_x8_init <- (trace_sha256_x8_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha256_x8_init);
  }
  proc sha256_x8_init_from (ctx:BArray784.t, src:BArray112.t,
                            ctx_init:BArray784.t, src_init:BArray112.t) : 
  BArray784.t * W64.t * BArray784.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_sha256_x8_init_from:trace;
    trace_sha256_x8_init_from <- [];
    status_init <- false;
    ms_init <- false;
    trace_sha256_x8_init_from <-
    (trace_sha256_x8_init_from ++ [(Assert, true)]);
    trace_sha256_x8_init_from <-
    (trace_sha256_x8_init_from ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_x8_init_from <-
    (trace_sha256_x8_init_from ++ [(Assert, true)]);
    trace_sha256_x8_init_from <-
    (trace_sha256_x8_init_from ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha256_x8_ctx_from (ctx, 
    src, ms, ctx_init, src_init);
    trace_sha256_x8_init_from <- (trace_sha256_x8_init_from ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha256_x8_init_from <-
    (trace_sha256_x8_init_from ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha256_x8_init_from);
  }
  proc sha256_x8_update (ctx:BArray784.t, in_0:BArray64.t, inlen:W64.t,
                         ctx_init:BArray784.t, in_init:BArray64.t) : 
  BArray784.t * W64.t * BArray784.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha256_x8_update:trace;
    trace_sha256_x8_update <- [];
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    trace_sha256_x8_update <- (trace_sha256_x8_update ++ [(Assert, true)]);
    trace_sha256_x8_update <- (trace_sha256_x8_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_x8_update <- (trace_sha256_x8_update ++ [(Assert, true)]);
    trace_sha256_x8_update <-
    (trace_sha256_x8_update ++ [(Assert, inlen_init)]);
    trace_sha256_x8_update <-
    (trace_sha256_x8_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha256_x8_ctx_update (
    ctx, in_0, inlen, ms, ctx_init, in_init);
    trace_sha256_x8_update <- (trace_sha256_x8_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha256_x8_update <-
    (trace_sha256_x8_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha256_x8_update);
  }
  proc sha256_x8_final (ctx:BArray784.t, out:BArray256.t,
                        ctx_init:BArray784.t, out_init:BArray256.t) : 
  BArray784.t * BArray256.t * W64.t * BArray784.t * BArray256.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_sha256_x8_final:trace;
    trace_sha256_x8_final <- [];
    status_init <- false;
    ms_init <- false;
    trace_sha256_x8_final <- (trace_sha256_x8_final ++ [(Assert, true)]);
    trace_sha256_x8_final <- (trace_sha256_x8_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha256_x8_final <- (trace_sha256_x8_final ++ [(Assert, true)]);
    trace_sha256_x8_final <- (trace_sha256_x8_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha256_x8_ctx_final (
    ctx, out, ms, ctx_init, out_init);
    trace_sha256_x8_final <- (trace_sha256_x8_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha256_x8_final <-
    (trace_sha256_x8_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha256_x8_final);
  }
  proc sha512_x4 (out:BArray256.t, in_0:BArray32.t, len:W64.t,
                  out_init:BArray256.t, in_init:BArray32.t) : BArray256.t *
                                                              BArray256.t *
                                                              trace = {
    var ms:W64.t;
    var ms_init:bool;
    var len_init:bool;
    var trace_sha512_x4:trace;
    trace_sha512_x4 <- [];
    len_init <- true;
    ms_init <- false;
    trace_sha512_x4 <- (trace_sha512_x4 ++ [(Assert, true)]);
    trace_sha512_x4 <- (trace_sha512_x4 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_x4 <- (trace_sha512_x4 ++ [(Assert, true)]);
    trace_sha512_x4 <- (trace_sha512_x4 ++ [(Assert, len_init)]);
    trace_sha512_x4 <- (trace_sha512_x4 ++ [(Assert, ms_init)]);
    (out, ms, out_init, tmp__trace) <@ _sha512_x4_lanes (out, in_0, len, 
    ms, out_init, in_init);
    trace_sha512_x4 <- (trace_sha512_x4 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_sha512_x4);
  }
  proc sha512_x4_init (ctx:BArray784.t, ctx_init:BArray784.t) : BArray784.t *
                                                                BArray784.t *
                                                                trace = {
    var ms:W64.t;
    var ms_init:bool;
    var trace_sha512_x4_init:trace;
    trace_sha512_x4_init <- [];
    ms_init <- false;
    trace_sha512_x4_init <- (trace_sha512_x4_init ++ [(Assert, true)]);
    trace_sha512_x4_init <- (trace_sha512_x4_init ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_x4_init <- (trace_sha512_x4_init ++ [(Assert, true)]);
    (ctx, ctx_init, tmp__trace) <@ __sha512_x4_ctx_init (ctx, ctx_init);
    trace_sha512_x4_init <- (trace_sha512_x4_init ++ tmp__trace);
    return (ctx, ctx_init, trace_sha512_x4_init);
  }
  proc sha512_x4_init_from (ctx:BArray784.t, src:BArray208.t,
                            ctx_init:BArray784.t, src_init:BArray208.t) : 
  BArray784.t * W64.t * BArray784.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_sha512_x4_init_from:trace;
    trace_sha512_x4_init_from <- [];
    status_init <- false;
    ms_init <- false;
    trace_sha512_x4_init_from <-
    (trace_sha512_x4_init_from ++ [(Assert, true)]);
    trace_sha512_x4_init_from <-
    (trace_sha512_x4_init_from ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_x4_init_from <-
    (trace_sha512_x4_init_from ++ [(Assert, true)]);
    trace_sha512_x4_init_from <-
    (trace_sha512_x4_init_from ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_x4_ctx_from (ctx, 
    src, ms, ctx_init, src_init);
    trace_sha512_x4_init_from <- (trace_sha512_x4_init_from ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_x4_init_from <-
    (trace_sha512_x4_init_from ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha512_x4_init_from);
  }
  proc sha512_x4_update (ctx:BArray784.t, in_0:BArray32.t, inlen:W64.t,
                         ctx_init:BArray784.t, in_init:BArray32.t) : 
  BArray784.t * W64.t * BArray784.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var inlen_init:bool;
    var status_init:bool;
    var trace_sha512_x4_update:trace;
    trace_sha512_x4_update <- [];
    inlen_init <- true;
    status_init <- false;
    ms_init <- false;
    trace_sha512_x4_update <- (trace_sha512_x4_update ++ [(Assert, true)]);
    trace_sha512_x4_update <- (trace_sha512_x4_update ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_x4_update <- (trace_sha512_x4_update ++ [(Assert, true)]);
    trace_sha512_x4_update <-
    (trace_sha512_x4_update ++ [(Assert, inlen_init)]);
    trace_sha512_x4_update <-
    (trace_sha512_x4_update ++ [(Assert, ms_init)]);
    (ctx, status, ms, ctx_init, tmp__trace) <@ _sha512_x4_ctx_update (
    ctx, in_0, inlen, ms, ctx_init, in_init);
    trace_sha512_x4_update <- (trace_sha512_x4_update ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_x4_update <-
    (trace_sha512_x4_update ++ [(Assert, status_init)]);
    return (ctx, status, ctx_init, trace_sha512_x4_update);
  }
  proc sha512_x4_final (ctx:BArray784.t, out:BArray256.t,
                        ctx_init:BArray784.t, out_init:BArray256.t) : 
  BArray784.t * BArray256.t * W64.t * BArray784.t * BArray256.t * trace = {
    var status:W64.t;
    var ms:W64.t;
    var ms_init:bool;
    var status_init:bool;
    var trace_sha512_x4_final:trace;
    trace_sha512_x4_final <- [];
    status_init <- false;
    ms_init <- false;
    trace_sha512_x4_final <- (trace_sha512_x4_final ++ [(Assert, true)]);
    trace_sha512_x4_final <- (trace_sha512_x4_final ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_sha512_x4_final <- (trace_sha512_x4_final ++ [(Assert, true)]);
    trace_sha512_x4_final <- (trace_sha512_x4_final ++ [(Assert, ms_init)]);
    (ctx, out, status, ms, ctx_init, out_init, tmp__trace) <@ _sha512_x4_ctx_final (
    ctx, out, ms, ctx_init, out_init);
    trace_sha512_x4_final <- (trace_sha512_x4_final ++ tmp__trace);
    status_init <- true;
    ms_init <- true;
    trace_sha512_x4_final <-
    (trace_sha512_x4_final ++ [(Assert, status_init)]);
    return (ctx, out, status, ctx_init, out_init, trace_sha512_x4_final);
  }
}.

(* The post and trace are valid. *)

op __bswap32_spec _x =
   hoare [M.__bswap32 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __bswap64_spec _x =
   hoare [M.__bswap64 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __fill64_mem_spec _buf _dst_ _p_ _n_ _ms _buf_init =
   hoare [M.__fill64_mem :
   (((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\ ((_p_ = p_) /\ ((_dst_ = dst_) /\ (_buf = buf)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((_dst_ \ule (W64.of_int 64)) /\ (_n_ \ule (W64.of_int 64))) /\
     ((_dst_ + _n_) \ule (W64.of_int 64))) /\
    (BArray64.is_init _buf_init 0 (W64.to_uint _dst_))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p_) (W64.to_uint _n_))))))))))) ==>
   ((true /\
    (true /\ (BArray64.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op __fill128_mem_spec _buf _dst_ _p_ _n_ _ms _buf_init =
   hoare [M.__fill128_mem :
   (((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\ ((_p_ = p_) /\ ((_dst_ = dst_) /\ (_buf = buf)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((_dst_ \ule (W64.of_int 128)) /\ (_n_ \ule (W64.of_int 128))) /\
     ((_dst_ + _n_) \ule (W64.of_int 128))) /\
    (BArray128.is_init _buf_init 0 (W64.to_uint _dst_))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p_) (W64.to_uint _n_))))))))))) ==>
   ((true /\
    (true /\ (BArray128.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op __zero64_spec _buf _lo_ _hi _ms _buf_init =
   hoare [M.__zero64 :
   (((_buf_init = buf_init) /\
    ((_ms = ms) /\ ((_hi = hi) /\ ((_lo_ = lo_) /\ (_buf = buf))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((_lo_ \ule _hi) /\ (_hi \ule (W64.of_int 64))) /\
   (BArray64.is_init _buf_init 0 (W64.to_uint _lo_)))))))) ==>
   ((true /\ (BArray64.is_init res.`3 0 (W64.to_uint _hi))) /\
   (valid res.`4))].

op __zero128_spec _buf _lo_ _hi _ms _buf_init =
   hoare [M.__zero128 :
   (((_buf_init = buf_init) /\
    ((_ms = ms) /\ ((_hi = hi) /\ ((_lo_ = lo_) /\ (_buf = buf))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((_lo_ \ule _hi) /\ (_hi \ule (W64.of_int 128))) /\
   (BArray128.is_init _buf_init 0 (W64.to_uint _lo_)))))))) ==>
   ((true /\ (BArray128.is_init res.`3 0 (W64.to_uint _hi))) /\
   (valid res.`4))].

op __sha256_block_a64_spec _abcd _efgh _m _k _m_init _k_init =
   hoare [M.__sha256_block_a64 :
   (((_k_init = k_init) /\
    ((_m_init = m_init) /\
    ((_k = k) /\ ((_m = m) /\ ((_efgh = efgh) /\ (_abcd = abcd)))))) /\
   ((BArray64.is_init _m_init 0 64) /\ (BArray256.is_init _k_init 0 256))) ==>
   ((BArray64.is_init res.`4 0 64) /\ (valid res.`5))].

op _sha256_compress_spec _h _block _ms _h_init _block_init =
   hoare [M._sha256_compress :
   (((_block_init = block_init) /\
    ((_h_init = h_init) /\ ((_ms = ms) /\ ((_block = block) /\ (_h = h))))) /\
   ((BArray32.is_init _h_init 0 32) /\ (BArray64.is_init _block_init 0 64))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _sha256_compress_blocks_spec _h _p _n _ms _h_init =
   hoare [M._sha256_compress_blocks :
   (((_h_init = h_init) /\
    ((_ms = ms) /\ ((_n = n) /\ ((_p = p) /\ (_h = h))))) /\
   (true /\
   (true /\
   (true /\
   (((BArray32.is_init _h_init 0 32) /\
    (_n \ult (W64.of_int 288230376151711744))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p)
   (W64.to_uint ((W64.of_int 64) * _n)))))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op __sha256_init_spec _h _h_init =
   hoare [M.__sha256_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op __sha224_init_spec _h _h_init =
   hoare [M.__sha224_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op _sha256_absorb_mem_spec _h _buf _total _in _inlen _ms _h_init _buf_init =
   hoare [M._sha256_absorb_mem :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\
    ((_in = in_0) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (((BArray32.is_init _h_init 0 32) /\
    (BArray64.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 64))))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray32.is_init res.`5 0 32) /\
     (BArray64.is_init res.`6 0 (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _inlen)))))))) /\
   (valid res.`7))].

op _sha256___sha256_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha256___sha256_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   ((BArray32.is_init _h_init 0 32) /\
   (BArray64.is_init _buf_init 0 (W64.to_uint (_total \umod (W64.of_int 64)))
   ))))) ==>
   ((((BArray32.is_init res.`5 0 32) /\ (BArray32.is_init res.`6 0 32)) /\
    (BArray64.is_init res.`7 0 64)) /\
   (valid res.`8))].

op _sha256____sha256_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha256____sha256_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray32.is_init _h_init 0 32) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _sha224___sha256_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha224___sha256_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   ((BArray32.is_init _h_init 0 32) /\
   (BArray64.is_init _buf_init 0 (W64.to_uint (_total \umod (W64.of_int 64)))
   ))))) ==>
   ((((BArray28.is_init res.`5 0 28) /\ (BArray32.is_init res.`6 0 32)) /\
    (BArray64.is_init res.`7 0 64)) /\
   (valid res.`8))].

op _sha224____sha256_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha224____sha256_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray32.is_init _h_init 0 32) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray28.is_init res.`3 0 28) /\ (valid res.`4))].

op _sha256_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha256_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _sha224_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha224_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray28.is_init res.`3 0 28) /\ (valid res.`4))].

op __sha512_block_a64_spec _s _m _k _s_init _m_init _k_init =
   hoare [M.__sha512_block_a64 :
   (((_k_init = k_init) /\
    ((_m_init = m_init) /\
    ((_s_init = s_init) /\ ((_k = k) /\ ((_m = m) /\ (_s = s)))))) /\
   (((BArray80.is_init _s_init 0 64) /\ (BArray128.is_init _m_init 0 128)) /\
   (BArray640.is_init _k_init 0 640))) ==>
   (((BArray80.is_init res.`3 0 80) /\ (BArray128.is_init res.`4 0 128)) /\
   (valid res.`5))].

op _sha512_compress_spec _h _block _ms _h_init _block_init =
   hoare [M._sha512_compress :
   (((_block_init = block_init) /\
    ((_h_init = h_init) /\ ((_ms = ms) /\ ((_block = block) /\ (_h = h))))) /\
   ((BArray64.is_init _h_init 0 64) /\ (BArray128.is_init _block_init 0 128))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op _sha512_compress_blocks_spec _h _p _n _ms _h_init =
   hoare [M._sha512_compress_blocks :
   (((_h_init = h_init) /\
    ((_ms = ms) /\ ((_n = n) /\ ((_p = p) /\ (_h = h))))) /\
   (true /\
   (true /\
   (true /\
   (((BArray64.is_init _h_init 0 64) /\
    (_n \ult (W64.of_int 144115188075855872))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p)
   (W64.to_uint ((W64.of_int 128) * _n)))))))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op __sha512_load_iv_spec _h _iv _h_init _iv_init =
   hoare [M.__sha512_load_iv :
   (((_iv_init = iv_init) /\
    ((_h_init = h_init) /\ ((_iv = iv) /\ (_h = h)))) /\
   (BArray64.is_init _iv_init 0 64)) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op __sha512_init_spec _h _h_init =
   hoare [M.__sha512_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op __sha384_init_spec _h _h_init =
   hoare [M.__sha384_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op __sha512_224_init_spec _h _h_init =
   hoare [M.__sha512_224_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op __sha512_256_init_spec _h _h_init =
   hoare [M.__sha512_256_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op _sha512_absorb_mem_spec _h _buf _total _in _inlen _ms _h_init _buf_init =
   hoare [M._sha512_absorb_mem :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\
    ((_in = in_0) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (((BArray64.is_init _h_init 0 64) /\
    (BArray128.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 128))))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray64.is_init res.`5 0 64) /\
     (BArray128.is_init res.`6 0
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _inlen)))))))) /\
   (valid res.`7))].

op _sha512___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha512___sha512_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   ((BArray64.is_init _h_init 0 64) /\
   (BArray128.is_init _buf_init 0
   (W64.to_uint (_total \umod (W64.of_int 128)))))))) ==>
   ((((BArray64.is_init res.`5 0 64) /\ (BArray64.is_init res.`6 0 64)) /\
    (BArray128.is_init res.`7 0 128)) /\
   (valid res.`8))].

op _sha512____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha512____sha512_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray64.is_init _h_init 0 64) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op _sha384___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha384___sha512_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   ((BArray64.is_init _h_init 0 64) /\
   (BArray128.is_init _buf_init 0
   (W64.to_uint (_total \umod (W64.of_int 128)))))))) ==>
   ((((BArray48.is_init res.`5 0 48) /\ (BArray64.is_init res.`6 0 64)) /\
    (BArray128.is_init res.`7 0 128)) /\
   (valid res.`8))].

op _sha384____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha384____sha512_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray64.is_init _h_init 0 64) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray48.is_init res.`3 0 48) /\ (valid res.`4))].

op _sha512_224___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha512_224___sha512_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   ((BArray64.is_init _h_init 0 64) /\
   (BArray128.is_init _buf_init 0
   (W64.to_uint (_total \umod (W64.of_int 128)))))))) ==>
   ((((BArray28.is_init res.`5 0 28) /\ (BArray64.is_init res.`6 0 64)) /\
    (BArray128.is_init res.`7 0 128)) /\
   (valid res.`8))].

op _sha512_224____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha512_224____sha512_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray64.is_init _h_init 0 64) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray28.is_init res.`3 0 28) /\ (valid res.`4))].

op _sha512_256___sha512_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha512_256___sha512_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   ((BArray64.is_init _h_init 0 64) /\
   (BArray128.is_init _buf_init 0
   (W64.to_uint (_total \umod (W64.of_int 128)))))))) ==>
   ((((BArray32.is_init res.`5 0 32) /\ (BArray64.is_init res.`6 0 64)) /\
    (BArray128.is_init res.`7 0 128)) /\
   (valid res.`8))].

op _sha512_256____sha512_mem_from_spec _out _h _in _inlen _ms _out_init _h_init =
   hoare [M._sha512_256____sha512_mem_from :
   (((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ ((_h = h) /\ (_out = out))))))) /\
   (true /\
   (true /\
   ((BArray64.is_init _h_init 0 64) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _sha512_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha512_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op _sha384_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha384_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray48.is_init res.`3 0 48) /\ (valid res.`4))].

op _sha512_224_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha512_224_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray28.is_init res.`3 0 28) /\ (valid res.`4))].

op _sha512_256_mem_spec _out _in _inlen _ms _out_init =
   hoare [M._sha512_256_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _hmac_sha256_keyblock_mem_spec _k0 _key _keylen _ms _k0_init =
   hoare [M._hmac_sha256_keyblock_mem :
   (((_k0_init = k0_init) /\
    ((_ms = ms) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_k0 = k0))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op _hmac_sha512_keyblock_mem_spec _k0 _key _keylen _ms _k0_init =
   hoare [M._hmac_sha512_keyblock_mem :
   (((_k0_init = k0_init) /\
    ((_ms = ms) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_k0 = k0))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray128.is_init res.`3 0 128) /\ (valid res.`4))].

op __hmac_sha256_init_spec _inner _outer _k0 _ms _inner_init _outer_init _k0_init =
   hoare [M.__hmac_sha256_init :
   (((_k0_init = k0_init) /\
    ((_outer_init = outer_init) /\
    ((_inner_init = inner_init) /\
    ((_ms = ms) /\ ((_k0 = k0) /\ ((_outer = outer) /\ (_inner = inner))))))) /\
   (BArray64.is_init _k0_init 0 64)) ==>
   (((BArray32.is_init res.`4 0 32) /\ (BArray32.is_init res.`5 0 32)) /\
   (valid res.`6))].

op __hmac_sha512_init_spec _inner _outer _k0 _ms _inner_init _outer_init _k0_init =
   hoare [M.__hmac_sha512_init :
   (((_k0_init = k0_init) /\
    ((_outer_init = outer_init) /\
    ((_inner_init = inner_init) /\
    ((_ms = ms) /\ ((_k0 = k0) /\ ((_outer = outer) /\ (_inner = inner))))))) /\
   (BArray128.is_init _k0_init 0 128)) ==>
   (((BArray64.is_init res.`4 0 64) /\ (BArray64.is_init res.`5 0 64)) /\
   (valid res.`6))].

op __hmac_sha256_outer_spec _inner _buf _total _outer _ms _inner_init _buf_init _outer_init =
   hoare [M.__hmac_sha256_outer :
   (((_outer_init = outer_init) /\
    ((_buf_init = buf_init) /\
    ((_inner_init = inner_init) /\
    ((_ms = ms) /\
    ((_outer = outer) /\
    ((_total = total) /\ ((_buf = buf) /\ (_inner = inner)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (((BArray32.is_init _inner_init 0 32) /\
    (BArray64.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 64))))) /\
   (BArray32.is_init _outer_init 0 32))))) ==>
   ((true /\
    (((BArray32.is_init res.`5 0 32) /\ (BArray64.is_init res.`6 0 32)) /\
    (res.`3 = (W64.of_int 96)))) /\
   (valid res.`7))].

op __hmac_sha256_finalize_spec _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init =
   hoare [M.__hmac_sha256_finalize :
   (((_outer_init = outer_init) /\
    ((_buf_init = buf_init) /\
    ((_inner_init = inner_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_outer = outer) /\
    ((_total = total) /\
    ((_buf = buf) /\ ((_inner = inner) /\ (_out = out)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (((BArray32.is_init _inner_init 0 32) /\
    (BArray64.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 64))))) /\
   (BArray32.is_init _outer_init 0 32))))) ==>
   ((BArray32.is_init res.`5 0 32) /\ (valid res.`8))].

op __hmac_sha512_outer_spec _inner _buf _total _outer _ms _inner_init _buf_init _outer_init =
   hoare [M.__hmac_sha512_outer :
   (((_outer_init = outer_init) /\
    ((_buf_init = buf_init) /\
    ((_inner_init = inner_init) /\
    ((_ms = ms) /\
    ((_outer = outer) /\
    ((_total = total) /\ ((_buf = buf) /\ (_inner = inner)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (((BArray64.is_init _inner_init 0 64) /\
    (BArray128.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 128))))) /\
   (BArray64.is_init _outer_init 0 64))))) ==>
   ((true /\
    (((BArray64.is_init res.`5 0 64) /\ (BArray128.is_init res.`6 0 64)) /\
    (res.`3 = (W64.of_int 192)))) /\
   (valid res.`7))].

op __hmac_sha512_finalize_spec _out _inner _buf _total _outer _ms _out_init _inner_init _buf_init _outer_init =
   hoare [M.__hmac_sha512_finalize :
   (((_outer_init = outer_init) /\
    ((_buf_init = buf_init) /\
    ((_inner_init = inner_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_outer = outer) /\
    ((_total = total) /\
    ((_buf = buf) /\ ((_inner = inner) /\ (_out = out)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (((BArray64.is_init _inner_init 0 64) /\
    (BArray128.is_init _buf_init 0
    (W64.to_uint (_total \umod (W64.of_int 128))))) /\
   (BArray64.is_init _outer_init 0 64))))) ==>
   ((BArray64.is_init res.`5 0 64) /\ (valid res.`8))].

op __sha2_tag_spec _f =
   hoare [M.__sha2_tag : ((_f = f) /\ true) ==> (true /\ (valid res.`2))].

op __sha2_ctx_open_spec _head _ms _head_init =
   hoare [M.__sha2_ctx_open :
   (((_head_init = head_init) /\ ((_ms = ms) /\ (_head = head))) /\
   (BArray16.is_init _head_init 0 16)) ==> (true /\ (valid res.`3))].

op __sha2_room_spec _total =
   hoare [M.__sha2_room :
   ((_total = total) /\ true) ==> (true /\ (valid res.`2))].

op __sha256_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init =
   hoare [M.__sha256_ctx_load :
   (((_ctx_init = ctx_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\ ((_ctx = ctx) /\ ((_buf = buf) /\ (_h = h)))))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   (((BArray32.is_init res.`3 0 32) /\ (BArray64.is_init res.`4 0 64)) /\
   (valid res.`5))].

op __sha512_ctx_load_spec _h _buf _ctx _h_init _buf_init _ctx_init =
   hoare [M.__sha512_ctx_load :
   (((_ctx_init = ctx_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\ ((_ctx = ctx) /\ ((_buf = buf) /\ (_h = h)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   (((BArray64.is_init res.`3 0 64) /\ (BArray128.is_init res.`4 0 128)) /\
   (valid res.`5))].

op __sha256_ctx_init_spec _ctx _h _tag _total _ctx_init _h_init =
   hoare [M.__sha256_ctx_init :
   (((_h_init = h_init) /\
    ((_ctx_init = ctx_init) /\
    ((_total = total) /\ ((_tag = tag) /\ ((_h = h) /\ (_ctx = ctx)))))) /\
   (BArray32.is_init _h_init 0 32)) ==>
   ((BArray112.is_init res.`2 0 112) /\ (valid res.`3))].

op __sha512_ctx_init_spec _ctx _h _tag _total _ctx_init _h_init =
   hoare [M.__sha512_ctx_init :
   (((_h_init = h_init) /\
    ((_ctx_init = ctx_init) /\
    ((_total = total) /\ ((_tag = tag) /\ ((_h = h) /\ (_ctx = ctx)))))) /\
   (BArray64.is_init _h_init 0 64)) ==>
   ((BArray208.is_init res.`2 0 208) /\ (valid res.`3))].

op _sha256_ctx_update_spec _ctx _in _inlen _expect _ms _ctx_init =
   hoare [M._sha256_ctx_update :
   (((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))))) /\
   (true /\
   (true /\
   ((BArray112.is_init _ctx_init 0 112) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray112.is_init res.`4 0 112) /\ (valid res.`5))].

op _sha512_ctx_update_spec _ctx _in _inlen _expect _ms _ctx_init =
   hoare [M._sha512_ctx_update :
   (((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))))) /\
   (true /\
   (true /\
   ((BArray208.is_init _ctx_init 0 208) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray208.is_init res.`4 0 208) /\ (valid res.`5))].

op _sha224_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha224_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   (((BArray112.is_init res.`4 0 112) /\ (BArray28.is_init res.`5 0 28)) /\
   (valid res.`6))].

op _sha224_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha224_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   ((true /\
    ((BArray112.is_init res.`5 0 112) /\
    (BArray28.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 28 : 0)))) /\
   (valid res.`7))].

op _sha256_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha256_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   (((BArray112.is_init res.`4 0 112) /\ (BArray32.is_init res.`5 0 32)) /\
   (valid res.`6))].

op _sha256_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha256_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   ((true /\
    ((BArray112.is_init res.`5 0 112) /\
    (BArray32.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`7))].

op _sha384_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha384_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   (((BArray208.is_init res.`4 0 208) /\ (BArray48.is_init res.`5 0 48)) /\
   (valid res.`6))].

op _sha384_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha384_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`5 0 208) /\
    (BArray48.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 48 : 0)))) /\
   (valid res.`7))].

op _sha512_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha512_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   (((BArray208.is_init res.`4 0 208) /\ (BArray64.is_init res.`5 0 64)) /\
   (valid res.`6))].

op _sha512_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha512_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`5 0 208) /\
    (BArray64.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 64 : 0)))) /\
   (valid res.`7))].

op _sha512_224_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha512_224_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   (((BArray208.is_init res.`4 0 208) /\ (BArray28.is_init res.`5 0 28)) /\
   (valid res.`6))].

op _sha512_224_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha512_224_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`5 0 208) /\
    (BArray28.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 28 : 0)))) /\
   (valid res.`7))].

op _sha512_256_ctx____ctx_finalize_spec _ctx _digest _total _ms _ctx_init _digest_init =
   hoare [M._sha512_256_ctx____ctx_finalize :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   (((BArray208.is_init res.`4 0 208) /\ (BArray32.is_init res.`5 0 32)) /\
   (valid res.`6))].

op _sha512_256_ctx___sha2_ctx_final_spec _ctx _digest _expect _ms _ctx_init _digest_init =
   hoare [M._sha512_256_ctx___sha2_ctx_final :
   (((_digest_init = digest_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\
    ((_expect = expect_0) /\ ((_digest = digest) /\ (_ctx = ctx)))))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`5 0 208) /\
    (BArray32.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`7))].

op __hmac_sha256_ctx_init_spec _ctx _key _keylen _ms _ctx_init =
   hoare [M.__hmac_sha256_ctx_init :
   (((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_ctx = ctx))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray144.is_init res.`3 0 144) /\ (valid res.`4))].

op __hmac_sha512_ctx_init_spec _ctx _key _keylen _ms _ctx_init =
   hoare [M.__hmac_sha512_ctx_init :
   (((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_ctx = ctx))))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray272.is_init res.`3 0 272) /\ (valid res.`4))].

op __hmac_sha256_ctx_final_spec _ctx _out _ms _ctx_init _out_init =
   hoare [M.__hmac_sha256_ctx_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_out = out) /\ (_ctx = ctx))))) /\
   (BArray144.is_init _ctx_init 0 144)) ==>
   ((true /\
    ((BArray144.is_init res.`5 0 144) /\
    (BArray32.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`7))].

op __hmac_sha512_ctx_final_spec _ctx _out _ms _ctx_init _out_init =
   hoare [M.__hmac_sha512_ctx_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_out = out) /\ (_ctx = ctx))))) /\
   (BArray272.is_init _ctx_init 0 272)) ==>
   ((true /\
    ((BArray272.is_init res.`5 0 272) /\
    (BArray64.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 64 : 0)))) /\
   (valid res.`7))].

op _hmac_sha256_mem_spec _out _key _keylen _msg _msglen _ms _out_init =
   hoare [M._hmac_sha256_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_msglen = msglen) /\
    ((_msg = msg) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen)
    ) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _msg) (W64.to_uint _msglen)))))))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _hmac_sha512_mem_spec _out _key _keylen _msg _msglen _ms _out_init =
   hoare [M._hmac_sha512_mem :
   (((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_msglen = msglen) /\
    ((_msg = msg) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen)
    ) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _msg) (W64.to_uint _msglen)))))))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op __sha256_x8_tr4_spec _a _b _c _d =
   hoare [M.__sha256_x8_tr4 :
   (((_d = d) /\ ((_c = c) /\ ((_b = b) /\ (_a = a)))) /\ true) ==>
   (true /\ (valid res.`5))].

op __sha256_x8_load_half_spec _h8 _f _h8_init =
   hoare [M.__sha256_x8_load_half :
   (((_h8_init = h8_init) /\ ((_f = f) /\ (_h8 = h8))) /\
   (true /\
   (true /\ (((0 <= _f) /\ (_f < 2)) /\ (BArray256.is_init _h8_init 0 256))))) ==>
   ((BArray128.is_init res.`2 0 128) /\ (valid res.`3))].

op __sha256_x8_store_half_spec _h8 _st _f _h8_init _st_init =
   hoare [M.__sha256_x8_store_half :
   (((_st_init = st_init) /\
    ((_h8_init = h8_init) /\ ((_f = f) /\ ((_st = st) /\ (_h8 = h8))))) /\
   (true /\
   (true /\
   ((((0 <= _f) /\ (_f < 2)) /\ (BArray256.is_init _h8_init 0 256)) /\
   (BArray128.is_init _st_init 0 128))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op __sha256_x8_block2_spec _st _r _m _k _st_init _m_init _k_init =
   hoare [M.__sha256_x8_block2 :
   (((_k_init = k_init) /\
    ((_m_init = m_init) /\
    ((_st_init = st_init) /\
    ((_k = k) /\ ((_m = m) /\ ((_r = r) /\ (_st = st))))))) /\
   (true /\
   (true /\
   (((((0 <= _r) /\ (_r < 2)) /\ (BArray128.is_init _st_init 0 128)) /\
    (BArray128.is_init _m_init 0 128)) /\
   (BArray256.is_init _k_init 0 256))))) ==>
   (((BArray128.is_init res.`3 0 128) /\ (BArray128.is_init res.`4 0 128)) /\
   (valid res.`5))].

op _sha256_x8_compress_spec _h8 _blocks _ms _h8_init _blocks_init =
   hoare [M._sha256_x8_compress :
   (((_blocks_init = blocks_init) /\
    ((_h8_init = h8_init) /\
    ((_ms = ms) /\ ((_blocks = blocks) /\ (_h8 = h8))))) /\
   ((BArray256.is_init _h8_init 0 256) /\
   (BArray512.is_init _blocks_init 0 512))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op _sha256_x8_compress_lanes_spec _h8 _in _off _n _ms _h8_init _in_init =
   hoare [M._sha256_x8_compress_lanes :
   (((_in_init = in_init) /\
    ((_h8_init = h8_init) /\
    ((_ms = ms) /\
    ((_n = n) /\ ((_off = off) /\ ((_in = in_0) /\ (_h8 = h8))))))) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   (true /\
   ((((((((((((BArray256.is_init _h8_init 0 256) /\
             (BArray64.is_init _in_init 0 64)) /\
            (_n \ult (W64.of_int 288230376151711744))) /\
           (_off \ult (W64.of_int 2305843009213693952))) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint ((BArray64.get64 _in 0) + _off))
          (W64.to_uint ((W64.of_int 64) * _n)))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint ((BArray64.get64 _in 1) + _off))
         (W64.to_uint ((W64.of_int 64) * _n)))) /\
        (is_valid ptr_modulus Glob.mem_v
        (W64.to_uint ((BArray64.get64 _in 2) + _off))
        (W64.to_uint ((W64.of_int 64) * _n)))) /\
       (is_valid ptr_modulus Glob.mem_v
       (W64.to_uint ((BArray64.get64 _in 3) + _off))
       (W64.to_uint ((W64.of_int 64) * _n)))) /\
      (is_valid ptr_modulus Glob.mem_v
      (W64.to_uint ((BArray64.get64 _in 4) + _off))
      (W64.to_uint ((W64.of_int 64) * _n)))) /\
     (is_valid ptr_modulus Glob.mem_v
     (W64.to_uint ((BArray64.get64 _in 5) + _off))
     (W64.to_uint ((W64.of_int 64) * _n)))) /\
    (is_valid ptr_modulus Glob.mem_v
    (W64.to_uint ((BArray64.get64 _in 6) + _off))
    (W64.to_uint ((W64.of_int 64) * _n)))) /\
   (is_valid ptr_modulus Glob.mem_v
   (W64.to_uint ((BArray64.get64 _in 7) + _off))
   (W64.to_uint ((W64.of_int 64) * _n))))))))))))))))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op __sha256_x8_init_spec _h _h_init =
   hoare [M.__sha256_x8_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op __sha256_x8_from_spec _h _buf _hs _bs _h_init _buf_init _hs_init _bs_init =
   hoare [M.__sha256_x8_from :
   (((_bs_init = bs_init) /\
    ((_hs_init = hs_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_bs = bs) /\ ((_hs = hs) /\ ((_buf = buf) /\ (_h = h)))))))) /\
   ((BArray32.is_init _hs_init 0 32) /\ (BArray64.is_init _bs_init 0 64))) ==>
   (((BArray256.is_init res.`3 0 256) /\ (BArray512.is_init res.`4 0 512)) /\
   (valid res.`5))].

op _sha256_x8_absorb_lanes_spec _h _buf _total _in _inlen _ms _h_init _buf_init _in_init =
   hoare [M._sha256_x8_absorb_lanes :
   (((_in_init = in_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\
    ((_in = in_0) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   (((((((((((((((((((BArray256.is_init _h_init 0 256) /\
                    (BArray512.is_init _buf_init 0
                    (W64.to_uint (_total \umod (W64.of_int 64))))) /\
                   (BArray512.is_init _buf_init 64
                   (W64.to_uint (_total \umod (W64.of_int 64))))) /\
                  (BArray512.is_init _buf_init 128
                  (W64.to_uint (_total \umod (W64.of_int 64))))) /\
                 (BArray512.is_init _buf_init 192
                 (W64.to_uint (_total \umod (W64.of_int 64))))) /\
                (BArray512.is_init _buf_init 256
                (W64.to_uint (_total \umod (W64.of_int 64))))) /\
               (BArray512.is_init _buf_init 320
               (W64.to_uint (_total \umod (W64.of_int 64))))) /\
              (BArray512.is_init _buf_init 384
              (W64.to_uint (_total \umod (W64.of_int 64))))) /\
             (BArray512.is_init _buf_init 448
             (W64.to_uint (_total \umod (W64.of_int 64))))) /\
            (_inlen \ult (W64.of_int 2305843009213693952))) /\
           (BArray64.is_init _in_init 0 64)) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint (BArray64.get64 _in 0)) (W64.to_uint _inlen))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (BArray64.get64 _in 1)) (W64.to_uint _inlen))) /\
        (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 2))
        (W64.to_uint _inlen))) /\
       (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 3))
       (W64.to_uint _inlen))) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 4))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 5))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 6))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 7))
   (W64.to_uint _inlen))))))))))))))))))))))))))))))))))))))))))))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    ((((((((((BArray256.is_init res.`5 0 256) /\
            (BArray512.is_init res.`6 0
            (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
           (BArray512.is_init res.`6 64
           (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
          (BArray512.is_init res.`6 128
          (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
         (BArray512.is_init res.`6 192
         (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
        (BArray512.is_init res.`6 256
        (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
       (BArray512.is_init res.`6 320
       (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
      (BArray512.is_init res.`6 384
      (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
     (BArray512.is_init res.`6 448
     (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _inlen)))))))))))))))))))))) /\
   (valid res.`7))].

op _sha256_x8_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha256_x8_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (((((((((BArray256.is_init _h_init 0 256) /\
          (BArray512.is_init _buf_init 0
          (W64.to_uint (_total \umod (W64.of_int 64))))) /\
         (BArray512.is_init _buf_init 64
         (W64.to_uint (_total \umod (W64.of_int 64))))) /\
        (BArray512.is_init _buf_init 128
        (W64.to_uint (_total \umod (W64.of_int 64))))) /\
       (BArray512.is_init _buf_init 192
       (W64.to_uint (_total \umod (W64.of_int 64))))) /\
      (BArray512.is_init _buf_init 256
      (W64.to_uint (_total \umod (W64.of_int 64))))) /\
     (BArray512.is_init _buf_init 320
     (W64.to_uint (_total \umod (W64.of_int 64))))) /\
    (BArray512.is_init _buf_init 384
    (W64.to_uint (_total \umod (W64.of_int 64))))) /\
   (BArray512.is_init _buf_init 448
   (W64.to_uint (_total \umod (W64.of_int 64)))))))))))))))))))))) ==>
   ((((BArray256.is_init res.`5 0 256) /\ (BArray256.is_init res.`6 0 256)) /\
    (BArray512.is_init res.`7 0 512)) /\
   (valid res.`8))].

op _sha256_x8_lanes_spec _out _in _len _ms _out_init _in_init =
   hoare [M._sha256_x8_lanes :
   (((_in_init = in_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\ ((_len = len) /\ ((_in = in_0) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   ((((((((((_len \ult (W64.of_int 2305843009213693952)) /\
           (BArray64.is_init _in_init 0 64)) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint (BArray64.get64 _in 0)) (W64.to_uint _len))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (BArray64.get64 _in 1)) (W64.to_uint _len))) /\
        (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 2))
        (W64.to_uint _len))) /\
       (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 3))
       (W64.to_uint _len))) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 4))
      (W64.to_uint _len))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 5))
     (W64.to_uint _len))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 6))
    (W64.to_uint _len))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 7))
   (W64.to_uint _len))))))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op __sha512_x4_load_pair_spec _h4 _i _h4_init =
   hoare [M.__sha512_x4_load_pair :
   (((_h4_init = h4_init) /\ ((_i = i) /\ (_h4 = h4))) /\
   (true /\
   (true /\ (((0 <= _i) /\ (_i < 2)) /\ (BArray256.is_init _h4_init 0 256))))) ==>
   (((BArray160.is_init res.`2 0 64) /\ (BArray160.is_init res.`2 80 64)) /\
   (valid res.`3))].

op __sha512_x4_store_pair_spec _h4 _s _i _h4_init _s_init =
   hoare [M.__sha512_x4_store_pair :
   (((_s_init = s_init) /\
    ((_h4_init = h4_init) /\ ((_i = i) /\ ((_s = s) /\ (_h4 = h4))))) /\
   (true /\
   (true /\
   (((((0 <= _i) /\ (_i < 2)) /\ (BArray256.is_init _h4_init 0 256)) /\
    (BArray160.is_init _s_init 0 64)) /\
   (BArray160.is_init _s_init 80 64))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op __sha512_x4_block2_spec _s _m _k _s_init _m_init _k_init =
   hoare [M.__sha512_x4_block2 :
   (((_k_init = k_init) /\
    ((_m_init = m_init) /\
    ((_s_init = s_init) /\ ((_k = k) /\ ((_m = m) /\ (_s = s)))))) /\
   ((((BArray160.is_init _s_init 0 64) /\ (BArray160.is_init _s_init 80 64)) /\
    (BArray256.is_init _m_init 0 256)) /\
   (BArray640.is_init _k_init 0 640))) ==>
   (((BArray160.is_init res.`3 0 160) /\ (BArray256.is_init res.`4 0 256)) /\
   (valid res.`5))].

op _sha512_x4_compress_spec _h4 _blocks _ms _h4_init _blocks_init =
   hoare [M._sha512_x4_compress :
   (((_blocks_init = blocks_init) /\
    ((_h4_init = h4_init) /\
    ((_ms = ms) /\ ((_blocks = blocks) /\ (_h4 = h4))))) /\
   ((BArray256.is_init _h4_init 0 256) /\
   (BArray512.is_init _blocks_init 0 512))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op _sha512_x4_compress_lanes_spec _h4 _in _off _n _ms _h4_init _in_init =
   hoare [M._sha512_x4_compress_lanes :
   (((_in_init = in_init) /\
    ((_h4_init = h4_init) /\
    ((_ms = ms) /\
    ((_n = n) /\ ((_off = off) /\ ((_in = in_0) /\ (_h4 = h4))))))) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   ((((((((BArray256.is_init _h4_init 0 256) /\
         (BArray32.is_init _in_init 0 32)) /\
        (_n \ult (W64.of_int 144115188075855872))) /\
       (_off \ult (W64.of_int 2305843009213693952))) /\
      (is_valid ptr_modulus Glob.mem_v
      (W64.to_uint ((BArray32.get64 _in 0) + _off))
      (W64.to_uint ((W64.of_int 128) * _n)))) /\
     (is_valid ptr_modulus Glob.mem_v
     (W64.to_uint ((BArray32.get64 _in 1) + _off))
     (W64.to_uint ((W64.of_int 128) * _n)))) /\
    (is_valid ptr_modulus Glob.mem_v
    (W64.to_uint ((BArray32.get64 _in 2) + _off))
    (W64.to_uint ((W64.of_int 128) * _n)))) /\
   (is_valid ptr_modulus Glob.mem_v
   (W64.to_uint ((BArray32.get64 _in 3) + _off))
   (W64.to_uint ((W64.of_int 128) * _n))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op __sha512_x4_init_spec _h _h_init =
   hoare [M.__sha512_x4_init :
   (((_h_init = h_init) /\ (_h = h)) /\ true) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op __sha512_x4_from_spec _h _buf _hs _bs _h_init _buf_init _hs_init _bs_init =
   hoare [M.__sha512_x4_from :
   (((_bs_init = bs_init) /\
    ((_hs_init = hs_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_bs = bs) /\ ((_hs = hs) /\ ((_buf = buf) /\ (_h = h)))))))) /\
   ((BArray64.is_init _hs_init 0 64) /\ (BArray128.is_init _bs_init 0 128))) ==>
   (((BArray256.is_init res.`3 0 256) /\ (BArray512.is_init res.`4 0 512)) /\
   (valid res.`5))].

op _sha512_x4_absorb_lanes_spec _h _buf _total _in _inlen _ms _h_init _buf_init _in_init =
   hoare [M._sha512_x4_absorb_lanes :
   (((_in_init = in_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_inlen = inlen) /\
    ((_in = in_0) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   (((((((((((BArray256.is_init _h_init 0 256) /\
            (BArray512.is_init _buf_init 0
            (W64.to_uint (_total \umod (W64.of_int 128))))) /\
           (BArray512.is_init _buf_init 128
           (W64.to_uint (_total \umod (W64.of_int 128))))) /\
          (BArray512.is_init _buf_init 256
          (W64.to_uint (_total \umod (W64.of_int 128))))) /\
         (BArray512.is_init _buf_init 384
         (W64.to_uint (_total \umod (W64.of_int 128))))) /\
        (_inlen \ult (W64.of_int 2305843009213693952))) /\
       (BArray32.is_init _in_init 0 32)) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 0))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 1))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 2))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 3))
   (W64.to_uint _inlen))))))))))))))))))))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    ((((((BArray256.is_init res.`5 0 256) /\
        (BArray512.is_init res.`6 0
        (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
       (BArray512.is_init res.`6 128
       (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
      (BArray512.is_init res.`6 256
      (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
     (BArray512.is_init res.`6 384
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _inlen)))))))))))))) /\
   (valid res.`7))].

op _sha512_x4_finalize_spec _out _h _buf _total _ms _out_init _h_init _buf_init =
   hoare [M._sha512_x4_finalize :
   (((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\
    ((_total = total) /\ ((_buf = buf) /\ ((_h = h) /\ (_out = out)))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (((((BArray256.is_init _h_init 0 256) /\
      (BArray512.is_init _buf_init 0
      (W64.to_uint (_total \umod (W64.of_int 128))))) /\
     (BArray512.is_init _buf_init 128
     (W64.to_uint (_total \umod (W64.of_int 128))))) /\
    (BArray512.is_init _buf_init 256
    (W64.to_uint (_total \umod (W64.of_int 128))))) /\
   (BArray512.is_init _buf_init 384
   (W64.to_uint (_total \umod (W64.of_int 128)))))))))))))) ==>
   ((((BArray256.is_init res.`5 0 256) /\ (BArray256.is_init res.`6 0 256)) /\
    (BArray512.is_init res.`7 0 512)) /\
   (valid res.`8))].

op _sha512_x4_lanes_spec _out _in _len _ms _out_init _in_init =
   hoare [M._sha512_x4_lanes :
   (((_in_init = in_init) /\
    ((_out_init = out_init) /\
    ((_ms = ms) /\ ((_len = len) /\ ((_in = in_0) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   ((((((_len \ult (W64.of_int 2305843009213693952)) /\
       (BArray32.is_init _in_init 0 32)) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 0))
      (W64.to_uint _len))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 1))
     (W64.to_uint _len))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 2))
    (W64.to_uint _len))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 3))
   (W64.to_uint _len))))))))))))))))))))) ==>
   ((BArray256.is_init res.`3 0 256) /\ (valid res.`4))].

op __sha256_x8_ctx_init_spec _ctx _ctx_init =
   hoare [M.__sha256_x8_ctx_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray784.is_init res.`2 0 784) /\ (valid res.`3))].

op _sha256_x8_ctx_from_spec _ctx _src _ms _ctx_init _src_init =
   hoare [M._sha256_x8_ctx_from :
   (((_src_init = src_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_src = src) /\ (_ctx = ctx))))) /\
   (BArray112.is_init _src_init 0 112)) ==>
   ((true /\
    (BArray784.is_init res.`4 0 ((res.`2 = (W64.of_int 0)) ? 784 : 0))) /\
   (valid res.`5))].

op _sha256_x8_ctx_update_spec _ctx _in _inlen _ms _ctx_init _in_init =
   hoare [M._sha256_x8_ctx_update :
   (((_in_init = in_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))))) /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   ((((((((((BArray784.is_init _ctx_init 0 784) /\
           (BArray64.is_init _in_init 0 64)) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint (BArray64.get64 _in 0)) (W64.to_uint _inlen))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (BArray64.get64 _in 1)) (W64.to_uint _inlen))) /\
        (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 2))
        (W64.to_uint _inlen))) /\
       (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 3))
       (W64.to_uint _inlen))) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 4))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 5))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 6))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 7))
   (W64.to_uint _inlen)))))))))))))))))))))))))))))))))))) ==>
   ((BArray784.is_init res.`4 0 784) /\ (valid res.`5))].

op _sha256_x8_ctx_final_spec _ctx _out _ms _ctx_init _out_init =
   hoare [M._sha256_x8_ctx_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_out = out) /\ (_ctx = ctx))))) /\
   (BArray784.is_init _ctx_init 0 784)) ==>
   ((true /\
    ((BArray784.is_init res.`5 0 784) /\
    (BArray256.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 256 : 0)))) /\
   (valid res.`7))].

op __sha512_x4_ctx_init_spec _ctx _ctx_init =
   hoare [M.__sha512_x4_ctx_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray784.is_init res.`2 0 784) /\ (valid res.`3))].

op _sha512_x4_ctx_from_spec _ctx _src _ms _ctx_init _src_init =
   hoare [M._sha512_x4_ctx_from :
   (((_src_init = src_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_src = src) /\ (_ctx = ctx))))) /\
   (BArray208.is_init _src_init 0 208)) ==>
   ((true /\
    (BArray784.is_init res.`4 0 ((res.`2 = (W64.of_int 0)) ? 784 : 0))) /\
   (valid res.`5))].

op _sha512_x4_ctx_update_spec _ctx _in _inlen _ms _ctx_init _in_init =
   hoare [M._sha512_x4_ctx_update :
   (((_in_init = in_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))))) /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   ((((((BArray784.is_init _ctx_init 0 784) /\
       (BArray32.is_init _in_init 0 32)) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 0))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 1))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 2))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 3))
   (W64.to_uint _inlen)))))))))))))))))))) ==>
   ((BArray784.is_init res.`4 0 784) /\ (valid res.`5))].

op _sha512_x4_ctx_final_spec _ctx _out _ms _ctx_init _out_init =
   hoare [M._sha512_x4_ctx_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\
    ((_ms = ms) /\ ((_out = out) /\ (_ctx = ctx))))) /\
   (BArray784.is_init _ctx_init 0 784)) ==>
   ((true /\
    ((BArray784.is_init res.`5 0 784) /\
    (BArray256.is_init res.`6 0 ((res.`3 = (W64.of_int 0)) ? 256 : 0)))) /\
   (valid res.`7))].

op sha224_spec _out _in _inlen _out_init =
   hoare [M.sha224 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray28.is_init res.`2 0 28) /\ (valid res.`3))].

op sha256_spec _out _in _inlen _out_init =
   hoare [M.sha256 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op sha384_spec _out _in _inlen _out_init =
   hoare [M.sha384 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray48.is_init res.`2 0 48) /\ (valid res.`3))].

op sha512_spec _out _in _inlen _out_init =
   hoare [M.sha512 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op sha512_224_spec _out _in _inlen _out_init =
   hoare [M.sha512_224 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray28.is_init res.`2 0 28) /\ (valid res.`3))].

op sha512_256_spec _out _in _inlen _out_init =
   hoare [M.sha512_256 :
   (((_out_init = out_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_out = out)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op sha224_init_spec _ctx _ctx_init =
   hoare [M.sha224_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray112.is_init res.`2 0 112) /\ (valid res.`3))].

op sha224_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha224_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray112.is_init _ctx_init 0 112) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray112.is_init res.`3 0 112) /\ (valid res.`4))].

op sha224_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha224_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   ((true /\
    ((BArray112.is_init res.`4 0 112) /\
    (BArray28.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 28 : 0)))) /\
   (valid res.`6))].

op sha256_init_spec _ctx _ctx_init =
   hoare [M.sha256_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray112.is_init res.`2 0 112) /\ (valid res.`3))].

op sha256_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha256_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray112.is_init _ctx_init 0 112) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray112.is_init res.`3 0 112) /\ (valid res.`4))].

op sha256_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha256_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray112.is_init _ctx_init 0 112)) ==>
   ((true /\
    ((BArray112.is_init res.`4 0 112) /\
    (BArray32.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`6))].

op sha384_init_spec _ctx _ctx_init =
   hoare [M.sha384_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray208.is_init res.`2 0 208) /\ (valid res.`3))].

op sha384_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha384_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray208.is_init _ctx_init 0 208) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray208.is_init res.`3 0 208) /\ (valid res.`4))].

op sha384_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha384_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`4 0 208) /\
    (BArray48.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 48 : 0)))) /\
   (valid res.`6))].

op sha512_init_spec _ctx _ctx_init =
   hoare [M.sha512_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray208.is_init res.`2 0 208) /\ (valid res.`3))].

op sha512_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha512_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray208.is_init _ctx_init 0 208) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray208.is_init res.`3 0 208) /\ (valid res.`4))].

op sha512_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha512_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`4 0 208) /\
    (BArray64.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 64 : 0)))) /\
   (valid res.`6))].

op sha512_224_init_spec _ctx _ctx_init =
   hoare [M.sha512_224_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray208.is_init res.`2 0 208) /\ (valid res.`3))].

op sha512_224_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha512_224_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray208.is_init _ctx_init 0 208) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray208.is_init res.`3 0 208) /\ (valid res.`4))].

op sha512_224_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha512_224_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`4 0 208) /\
    (BArray28.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 28 : 0)))) /\
   (valid res.`6))].

op sha512_256_init_spec _ctx _ctx_init =
   hoare [M.sha512_256_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray208.is_init res.`2 0 208) /\ (valid res.`3))].

op sha512_256_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.sha512_256_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray208.is_init _ctx_init 0 208) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray208.is_init res.`3 0 208) /\ (valid res.`4))].

op sha512_256_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha512_256_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray208.is_init _ctx_init 0 208)) ==>
   ((true /\
    ((BArray208.is_init res.`4 0 208) /\
    (BArray32.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`6))].

op hmac_sha256_spec _out _key _keylen _msg _msglen _out_init =
   hoare [M.hmac_sha256 :
   (((_out_init = out_init) /\
    ((_msglen = msglen) /\
    ((_msg = msg) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen)
    ) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _msg) (W64.to_uint _msglen)))))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op hmac_sha512_spec _out _key _keylen _msg _msglen _out_init =
   hoare [M.hmac_sha512 :
   (((_out_init = out_init) /\
    ((_msglen = msglen) /\
    ((_msg = msg) /\ ((_keylen = keylen) /\ ((_key = key) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen)
    ) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _msg) (W64.to_uint _msglen)))))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op hmac_sha256_init_spec _ctx _key _keylen _ctx_init =
   hoare [M.hmac_sha256_init :
   (((_ctx_init = ctx_init) /\
    ((_keylen = keylen) /\ ((_key = key) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray144.is_init res.`2 0 144) /\ (valid res.`3))].

op hmac_sha256_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.hmac_sha256_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray144.is_init _ctx_init 0 144) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray144.is_init res.`3 0 144) /\ (valid res.`4))].

op hmac_sha256_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.hmac_sha256_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray144.is_init _ctx_init 0 144)) ==>
   ((true /\
    ((BArray144.is_init res.`4 0 144) /\
    (BArray32.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 32 : 0)))) /\
   (valid res.`6))].

op hmac_sha512_init_spec _ctx _key _keylen _ctx_init =
   hoare [M.hmac_sha512_init :
   (((_ctx_init = ctx_init) /\
    ((_keylen = keylen) /\ ((_key = key) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _key) (W64.to_uint _keylen))))) ==>
   ((BArray272.is_init res.`2 0 272) /\ (valid res.`3))].

op hmac_sha512_update_spec _ctx _in _inlen _ctx_init =
   hoare [M.hmac_sha512_update :
   (((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx)))) /\
   (true /\
   (true /\
   ((BArray272.is_init _ctx_init 0 272) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _in) (W64.to_uint _inlen)))))) ==>
   ((BArray272.is_init res.`3 0 272) /\ (valid res.`4))].

op hmac_sha512_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.hmac_sha512_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray272.is_init _ctx_init 0 272)) ==>
   ((true /\
    ((BArray272.is_init res.`4 0 272) /\
    (BArray64.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 64 : 0)))) /\
   (valid res.`6))].

op sha256_x8_spec _out _in _len _out_init _in_init =
   hoare [M.sha256_x8 :
   (((_in_init = in_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   ((((((((((_len \ult (W64.of_int 2305843009213693952)) /\
           (BArray64.is_init _in_init 0 64)) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint (BArray64.get64 _in 0)) (W64.to_uint _len))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (BArray64.get64 _in 1)) (W64.to_uint _len))) /\
        (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 2))
        (W64.to_uint _len))) /\
       (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 3))
       (W64.to_uint _len))) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 4))
      (W64.to_uint _len))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 5))
     (W64.to_uint _len))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 6))
    (W64.to_uint _len))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 7))
   (W64.to_uint _len))))))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op sha256_x8_init_spec _ctx _ctx_init =
   hoare [M.sha256_x8_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray784.is_init res.`2 0 784) /\ (valid res.`3))].

op sha256_x8_init_from_spec _ctx _src _ctx_init _src_init =
   hoare [M.sha256_x8_init_from :
   (((_src_init = src_init) /\
    ((_ctx_init = ctx_init) /\ ((_src = src) /\ (_ctx = ctx)))) /\
   (BArray112.is_init _src_init 0 112)) ==>
   ((true /\
    (BArray784.is_init res.`3 0 ((res.`2 = (W64.of_int 0)) ? 784 : 0))) /\
   (valid res.`4))].

op sha256_x8_update_spec _ctx _in _inlen _ctx_init _in_init =
   hoare [M.sha256_x8_update :
   (((_in_init = in_init) /\
    ((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx))))) /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (3 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (4 * 8)) /\ (((4 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (4 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (5 * 8)) /\ (((5 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (5 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (6 * 8)) /\ (((6 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (6 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (7 * 8)) /\ (((7 * 8) + 8) <= 64)) /\
   ((BArray64.is_init _in_init (7 * 8) 8) /\
   (true /\
   ((((((((((BArray784.is_init _ctx_init 0 784) /\
           (BArray64.is_init _in_init 0 64)) /\
          (is_valid ptr_modulus Glob.mem_v
          (W64.to_uint (BArray64.get64 _in 0)) (W64.to_uint _inlen))) /\
         (is_valid ptr_modulus Glob.mem_v
         (W64.to_uint (BArray64.get64 _in 1)) (W64.to_uint _inlen))) /\
        (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 2))
        (W64.to_uint _inlen))) /\
       (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 3))
       (W64.to_uint _inlen))) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 4))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 5))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 6))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray64.get64 _in 7))
   (W64.to_uint _inlen)))))))))))))))))))))))))))))))))))) ==>
   ((BArray784.is_init res.`3 0 784) /\ (valid res.`4))].

op sha256_x8_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha256_x8_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray784.is_init _ctx_init 0 784)) ==>
   ((true /\
    ((BArray784.is_init res.`4 0 784) /\
    (BArray256.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 256 : 0)))) /\
   (valid res.`6))].

op sha512_x4_spec _out _in _len _out_init _in_init =
   hoare [M.sha512_x4 :
   (((_in_init = in_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_in = in_0) /\ (_out = out))))) /\
   (true /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   ((((((_len \ult (W64.of_int 2305843009213693952)) /\
       (BArray32.is_init _in_init 0 32)) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 0))
      (W64.to_uint _len))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 1))
     (W64.to_uint _len))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 2))
    (W64.to_uint _len))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 3))
   (W64.to_uint _len))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op sha512_x4_init_spec _ctx _ctx_init =
   hoare [M.sha512_x4_init :
   (((_ctx_init = ctx_init) /\ (_ctx = ctx)) /\ true) ==>
   ((BArray784.is_init res.`2 0 784) /\ (valid res.`3))].

op sha512_x4_init_from_spec _ctx _src _ctx_init _src_init =
   hoare [M.sha512_x4_init_from :
   (((_src_init = src_init) /\
    ((_ctx_init = ctx_init) /\ ((_src = src) /\ (_ctx = ctx)))) /\
   (BArray208.is_init _src_init 0 208)) ==>
   ((true /\
    (BArray784.is_init res.`3 0 ((res.`2 = (W64.of_int 0)) ? 784 : 0))) /\
   (valid res.`4))].

op sha512_x4_update_spec _ctx _in _inlen _ctx_init _in_init =
   hoare [M.sha512_x4_update :
   (((_in_init = in_init) /\
    ((_ctx_init = ctx_init) /\
    ((_inlen = inlen) /\ ((_in = in_0) /\ (_ctx = ctx))))) /\
   (true /\
   (((0 <= (0 * 8)) /\ (((0 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (0 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (1 * 8)) /\ (((1 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (1 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (2 * 8)) /\ (((2 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (2 * 8) 8) /\
   (true /\
   (true /\
   (((0 <= (3 * 8)) /\ (((3 * 8) + 8) <= 32)) /\
   ((BArray32.is_init _in_init (3 * 8) 8) /\
   (true /\
   ((((((BArray784.is_init _ctx_init 0 784) /\
       (BArray32.is_init _in_init 0 32)) /\
      (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 0))
      (W64.to_uint _inlen))) /\
     (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 1))
     (W64.to_uint _inlen))) /\
    (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 2))
    (W64.to_uint _inlen))) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint (BArray32.get64 _in 3))
   (W64.to_uint _inlen)))))))))))))))))))) ==>
   ((BArray784.is_init res.`3 0 784) /\ (valid res.`4))].

op sha512_x4_final_spec _ctx _out _ctx_init _out_init =
   hoare [M.sha512_x4_final :
   (((_out_init = out_init) /\
    ((_ctx_init = ctx_init) /\ ((_out = out) /\ (_ctx = ctx)))) /\
   (BArray784.is_init _ctx_init 0 784)) ==>
   ((true /\
    ((BArray784.is_init res.`4 0 784) /\
    (BArray256.is_init res.`5 0 ((res.`3 = (W64.of_int 0)) ? 256 : 0)))) /\
   (valid res.`6))].
