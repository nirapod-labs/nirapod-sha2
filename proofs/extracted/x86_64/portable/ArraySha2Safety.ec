require import AllCore IntDiv CoreMap List Distr.

from Jasmin require import JModel_x86.

import SLH64.

from Jasmin require import Jcheck JSafety.

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
  var tmp__trace : trace
  proc __bswap32 (x:W32.t) : W32.t * trace = {
    var x_init:bool;
    var trace___bswap32:trace;
    trace___bswap32 <- [];
    x_init <- true;
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, true)]);
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, true)]);
    trace___bswap32 <- (trace___bswap32 ++ [(Assert, x_init)]);
    x <- (BSWAP_32 x);
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
    x <- (BSWAP_64 x);
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
  proc __Sigma0_256 (x:W32.t) : W32.t * trace = {
    var r:W32.t;
    var t:W32.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___Sigma0_256:trace;
    trace___Sigma0_256 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 2));
    r_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 13));
    t_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, r_init)]);
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 22));
    t_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, r_init)]);
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma0_256 <- (trace___Sigma0_256 ++ [(Assert, r_init)]);
    return (r, trace___Sigma0_256);
  }
  proc __Sigma1_256 (x:W32.t) : W32.t * trace = {
    var r:W32.t;
    var t:W32.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___Sigma1_256:trace;
    trace___Sigma1_256 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 6));
    r_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 11));
    t_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, r_init)]);
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 25));
    t_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, r_init)]);
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma1_256 <- (trace___Sigma1_256 ++ [(Assert, r_init)]);
    return (r, trace___Sigma1_256);
  }
  proc __sigma0_256 (x:W32.t) : W32.t * trace = {
    var r:W32.t;
    var t:W32.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___sigma0_256:trace;
    trace___sigma0_256 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 7));
    r_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 18));
    t_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, r_init)]);
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 3));
    t_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, r_init)]);
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma0_256 <- (trace___sigma0_256 ++ [(Assert, r_init)]);
    return (r, trace___sigma0_256);
  }
  proc __sigma1_256 (x:W32.t) : W32.t * trace = {
    var r:W32.t;
    var t:W32.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___sigma1_256:trace;
    trace___sigma1_256 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 17));
    r_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 19));
    t_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, r_init)]);
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 10));
    t_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, r_init)]);
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma1_256 <- (trace___sigma1_256 ++ [(Assert, r_init)]);
    return (r, trace___sigma1_256);
  }
  proc __sha256_rounds (h:BArray32.t, w:BArray64.t, h_init:BArray32.t,
                        w_init:BArray64.t) : BArray32.t * BArray32.t * trace = {
    var i:int;
    var v:BArray32.t;
    var t:int;
    var t1:W32.t;
    var x:W32.t;
    var k:BArray256.t;
    var y:W32.t;
    var i_init:bool;
    var v_init:BArray32.t;
    var t_init:bool;
    var t1_init:bool;
    var x_init:bool;
    var k_init:BArray256.t;
    var y_init:bool;
    var trace___sha256_rounds:trace;
    k <- witness;
    k_init <- witness;
    v <- witness;
    v_init <- witness;
    trace___sha256_rounds <- [];
    i_init <- false;
    v_init <- (BArray32.init_arr (W8.of_int 0));
    t_init <- false;
    t1_init <- false;
    x_init <- false;
    k_init <- (BArray256.init_arr (W8.of_int 0));
    y_init <- false;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, i_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, i_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init h_init (i * 4) 4))]);
      v <- (BArray32.set32 v i (BArray32.get32 h i));
      v_init <- (BArray32.set32 v_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    t_init <- true;
    t <- 0;
    while ((t < 64)) {
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      if ((16 <= t)) {
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert,
         ((0 <= (((t - 2) %% 16) * 4)) /\
         (((((t - 2) %% 16) * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, (BArray64.is_init w_init (((t - 2) %% 16) * 4) 4))]);
        x <- (BArray64.get32 w ((t - 2) %% 16));
        x_init <- true;
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, x_init)]);
        (t1, tmp__trace) <@ __sigma1_256 (x);
        trace___sha256_rounds <- (trace___sha256_rounds ++ tmp__trace);
        t1_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert,
         ((0 <= (((t - 15) %% 16) * 4)) /\
         (((((t - 15) %% 16) * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, (BArray64.is_init w_init (((t - 15) %% 16) * 4) 4))]);
        x <- (BArray64.get32 w ((t - 15) %% 16));
        x_init <- true;
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, x_init)]);
        (x, tmp__trace) <@ __sigma0_256 (x);
        trace___sha256_rounds <- (trace___sha256_rounds ++ tmp__trace);
        x_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t1_init)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert,
         ((0 <= (((t - 7) %% 16) * 4)) /\
         (((((t - 7) %% 16) * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, (BArray64.is_init w_init (((t - 7) %% 16) * 4) 4))]);
        x <- (BArray64.get32 w ((t - 7) %% 16));
        x_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t1_init)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, ((0 <= ((t %% 16) * 4)) /\ ((((t %% 16) * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, (BArray64.is_init w_init ((t %% 16) * 4) 4))]);
        x <- (BArray64.get32 w (t %% 16));
        x_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t1_init)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, ((0 <= ((t %% 16) * 4)) /\ ((((t %% 16) * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t1_init)]);
        w <- (BArray64.set32 w (t %% 16) t1);
        w_init <- (BArray64.set32 w_init (t %% 16) (W32.of_int 4294967295));
      } else {
        trace___sha256_rounds <-
        (trace___sha256_rounds ++ [(Assert, t_init)]);
        trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, ((0 <= (t * 4)) /\ (((t * 4) + 4) <= 64)))]);
        trace___sha256_rounds <-
        (trace___sha256_rounds ++
        [(Assert, (BArray64.is_init w_init (t * 4) 4))]);
        t1 <- (BArray64.get32 w t);
        t1_init <- true;
      }
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((7 + 64) - t) %% 8) * 4)) /\
       ((((((7 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((7 + 64) - t) %% 8) * 4) 4))]);
      t1 <- (t1 + (BArray32.get32 v (((7 + 64) - t) %% 8)));
      t1_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((4 + 64) - t) %% 8) * 4)) /\
       ((((((4 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((4 + 64) - t) %% 8) * 4) 4))]);
      (x, tmp__trace) <@ __Sigma1_256 ((BArray32.get32 v
                                       (((4 + 64) - t) %% 8)));
      trace___sha256_rounds <- (trace___sha256_rounds ++ tmp__trace);
      x_init <- true;
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((5 + 64) - t) %% 8) * 4)) /\
       ((((((5 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((5 + 64) - t) %% 8) * 4) 4))]);
      x <- (BArray32.get32 v (((5 + 64) - t) %% 8));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((6 + 64) - t) %% 8) * 4)) /\
       ((((((6 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((6 + 64) - t) %% 8) * 4) 4))]);
      x <- (x `^` (BArray32.get32 v (((6 + 64) - t) %% 8)));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((4 + 64) - t) %% 8) * 4)) /\
       ((((((4 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((4 + 64) - t) %% 8) * 4) 4))]);
      x <- (x `&` (BArray32.get32 v (((4 + 64) - t) %% 8)));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((6 + 64) - t) %% 8) * 4)) /\
       ((((((6 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((6 + 64) - t) %% 8) * 4) 4))]);
      x <- (x `^` (BArray32.get32 v (((6 + 64) - t) %% 8)));
      x_init <- true;
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      k <- sHA256_K;
      k_init <- (BArray256.init_arr (W8.of_int 255));
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (t * 4)) /\ (((t * 4) + 4) <= 256)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray256.is_init k_init (t * 4) 4))]);
      x <- (BArray256.get32 k t);
      x_init <- true;
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((3 + 64) - t) %% 8) * 4)) /\
       ((((((3 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((3 + 64) - t) %% 8) * 4)) /\
       ((((((3 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((3 + 64) - t) %% 8) * 4) 4))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      v <-
      (BArray32.set32 v (((3 + 64) - t) %% 8)
      ((BArray32.get32 v (((3 + 64) - t) %% 8)) + t1));
      v_init <-
      (BArray32.set32 v_init (((3 + 64) - t) %% 8) (W32.of_int 4294967295));
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((0 + 64) - t) %% 8) * 4)) /\
       ((((((0 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((0 + 64) - t) %% 8) * 4) 4))]);
      (x, tmp__trace) <@ __Sigma0_256 ((BArray32.get32 v
                                       (((0 + 64) - t) %% 8)));
      trace___sha256_rounds <- (trace___sha256_rounds ++ tmp__trace);
      x_init <- true;
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((0 + 64) - t) %% 8) * 4)) /\
       ((((((0 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((0 + 64) - t) %% 8) * 4) 4))]);
      x <- (BArray32.get32 v (((0 + 64) - t) %% 8));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((1 + 64) - t) %% 8) * 4)) /\
       ((((((1 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((1 + 64) - t) %% 8) * 4) 4))]);
      x <- (x `^` (BArray32.get32 v (((1 + 64) - t) %% 8)));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((2 + 64) - t) %% 8) * 4)) /\
       ((((((2 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((2 + 64) - t) %% 8) * 4) 4))]);
      x <- (x `&` (BArray32.get32 v (((2 + 64) - t) %% 8)));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((0 + 64) - t) %% 8) * 4)) /\
       ((((((0 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((0 + 64) - t) %% 8) * 4) 4))]);
      y <- (BArray32.get32 v (((0 + 64) - t) %% 8));
      y_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, y_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((1 + 64) - t) %% 8) * 4)) /\
       ((((((1 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init ((((1 + 64) - t) %% 8) * 4) 4))]);
      y <- (y `&` (BArray32.get32 v (((1 + 64) - t) %% 8)));
      y_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, y_init)]);
      x <- (x `^` y);
      x_init <- true;
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, t_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert,
       ((0 <= ((((7 + 64) - t) %% 8) * 4)) /\
       ((((((7 + 64) - t) %% 8) * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++ [(Assert, t1_init)]);
      v <- (BArray32.set32 v (((7 + 64) - t) %% 8) t1);
      v_init <-
      (BArray32.set32 v_init (((7 + 64) - t) %% 8) (W32.of_int 4294967295));
      t <- (t + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, i_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init h_init (i * 4) 4))]);
      x <- (BArray32.get32 h i);
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, i_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, (BArray32.is_init v_init (i * 4) 4))]);
      x <- (x + (BArray32.get32 v i));
      x_init <- true;
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, i_init)]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, true)]);
      trace___sha256_rounds <-
      (trace___sha256_rounds ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 32)))]);
      trace___sha256_rounds <- (trace___sha256_rounds ++ [(Assert, x_init)]);
      h <- (BArray32.set32 h i x);
      h_init <- (BArray32.set32 h_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    return (h, h_init, trace___sha256_rounds);
  }
  proc _sha256_compress (h:BArray32.t, block:BArray64.t, ms:W64.t,
                         h_init:BArray32.t, block_init:BArray64.t) : 
  BArray32.t * W64.t * BArray32.t * trace = {
    var i:int;
    var x:W32.t;
    var w:BArray64.t;
    var i_init:bool;
    var x_init:bool;
    var w_init:BArray64.t;
    var ms_init:bool;
    var trace__sha256_compress:trace;
    w <- witness;
    w_init <- witness;
    trace__sha256_compress <- [];
    ms_init <- true;
    i_init <- false;
    x_init <- false;
    w_init <- (BArray64.init_arr (W8.of_int 0));
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, i_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, (BArray64.is_init block_init (i * 4) 4))]);
      x <- (BArray64.get32 block i);
      x_init <- true;
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap32 (x);
      trace__sha256_compress <- (trace__sha256_compress ++ tmp__trace);
      x_init <- true;
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, i_init)]);
      trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
      trace__sha256_compress <-
      (trace__sha256_compress ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 64)))]);
      trace__sha256_compress <-
      (trace__sha256_compress ++ [(Assert, x_init)]);
      w <- (BArray64.set32 w i x);
      w_init <- (BArray64.set32 w_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha256_compress <- (trace__sha256_compress ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_rounds (h, w, h_init, w_init);
    trace__sha256_compress <- (trace__sha256_compress ++ tmp__trace);
    trace__sha256_compress <-
    (trace__sha256_compress ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha256_compress);
  }
  proc _sha256_compress_one (h:BArray32.t, p:W64.t, ms:W64.t,
                             h_init:BArray32.t) : BArray32.t * W64.t *
                                                  BArray32.t * trace = {
    var i:int;
    var x:W32.t;
    var w:BArray64.t;
    var p_init:bool;
    var i_init:bool;
    var x_init:bool;
    var w_init:BArray64.t;
    var ms_init:bool;
    var trace__sha256_compress_one:trace;
    w <- witness;
    w_init <- witness;
    trace__sha256_compress_one <- [];
    p_init <- true;
    ms_init <- true;
    i_init <- false;
    x_init <- false;
    w_init <- (BArray64.init_arr (W8.of_int 0));
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, p_init)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, i_init)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, true)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++
      [(Assert,
       (is_valid ptr_modulus Glob.mem_v
       (W64.to_uint (p + (W64.of_int (4 * i)))) 4))]);
      x <- (loadW32 Glob.mem (W64.to_uint (p + (W64.of_int (4 * i)))));
      x_init <- true;
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, true)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap32 (x);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ tmp__trace);
      x_init <- true;
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, i_init)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, true)]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++
      [(Assert, ((0 <= (i * 4)) /\ (((i * 4) + 4) <= 64)))]);
      trace__sha256_compress_one <-
      (trace__sha256_compress_one ++ [(Assert, x_init)]);
      w <- (BArray64.set32 w i x);
      w_init <- (BArray64.set32 w_init i (W32.of_int 4294967295));
      i <- (i + 1);
    }
    trace__sha256_compress_one <-
    (trace__sha256_compress_one ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_rounds (h, w, h_init, w_init);
    trace__sha256_compress_one <- (trace__sha256_compress_one ++ tmp__trace);
    trace__sha256_compress_one <-
    (trace__sha256_compress_one ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha256_compress_one);
  }
  proc _sha256_compress_blocks (h:BArray32.t, p:W64.t, n:W64.t, ms:W64.t,
                                h_init:BArray32.t) : BArray32.t * W64.t *
                                                     BArray32.t * trace = {
    var more:bool;
    var more_init:bool;
    var ms_init:bool;
    var p_init:bool;
    var n_init:bool;
    var trace__sha256_compress_blocks:trace;
    trace__sha256_compress_blocks <- [];
    p_init <- true;
    n_init <- true;
    ms_init <- true;
    more_init <- false;
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
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
      (* Erased call to spill *)
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress_one (h, p, ms, h_init);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ tmp__trace);
      ms_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
      (* Erased call to unspill *)
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, p_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, true)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, n_init)]);
      trace__sha256_compress_blocks <-
      (trace__sha256_compress_blocks ++ [(Assert, ms_init)]);
      n <- (protect_64 n ms);
      n_init <- true;
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
  proc __Sigma0_512 (x:W64.t) : W64.t * trace = {
    var r:W64.t;
    var t:W64.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___Sigma0_512:trace;
    trace___Sigma0_512 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 28));
    r_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 34));
    t_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, r_init)]);
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 39));
    t_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, r_init)]);
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma0_512 <- (trace___Sigma0_512 ++ [(Assert, r_init)]);
    return (r, trace___Sigma0_512);
  }
  proc __Sigma1_512 (x:W64.t) : W64.t * trace = {
    var r:W64.t;
    var t:W64.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___Sigma1_512:trace;
    trace___Sigma1_512 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 14));
    r_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 18));
    t_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, r_init)]);
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 41));
    t_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, r_init)]);
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___Sigma1_512 <- (trace___Sigma1_512 ++ [(Assert, r_init)]);
    return (r, trace___Sigma1_512);
  }
  proc __sigma0_512 (x:W64.t) : W64.t * trace = {
    var r:W64.t;
    var t:W64.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___sigma0_512:trace;
    trace___sigma0_512 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 1));
    r_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 8));
    t_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, r_init)]);
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 7));
    t_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, r_init)]);
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma0_512 <- (trace___sigma0_512 ++ [(Assert, r_init)]);
    return (r, trace___sigma0_512);
  }
  proc __sigma1_512 (x:W64.t) : W64.t * trace = {
    var r:W64.t;
    var t:W64.t;
    var x_init:bool;
    var r_init:bool;
    var t_init:bool;
    var trace___sigma1_512:trace;
    trace___sigma1_512 <- [];
    x_init <- true;
    r_init <- false;
    t_init <- false;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, x_init)]);
    r <- x;
    r_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, r_init)]);
    r <- (r `|>>|` (W8.of_int 19));
    r_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, t_init)]);
    t <- (t `|>>|` (W8.of_int 61));
    t_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, r_init)]);
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, x_init)]);
    t <- x;
    t_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, t_init)]);
    t <- (t `>>` (W8.of_int 6));
    t_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, r_init)]);
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, t_init)]);
    r <- (r `^` t);
    r_init <- true;
    trace___sigma1_512 <- (trace___sigma1_512 ++ [(Assert, r_init)]);
    return (r, trace___sigma1_512);
  }
  proc __sha512_rounds (h:BArray64.t, w:BArray128.t, h_init:BArray64.t,
                        w_init:BArray128.t) : BArray64.t * BArray64.t * trace = {
    var i:int;
    var v:BArray64.t;
    var t:int;
    var t1:W64.t;
    var x:W64.t;
    var k:BArray640.t;
    var y:W64.t;
    var i_init:bool;
    var v_init:BArray64.t;
    var t_init:bool;
    var t1_init:bool;
    var x_init:bool;
    var k_init:BArray640.t;
    var y_init:bool;
    var trace___sha512_rounds:trace;
    k <- witness;
    k_init <- witness;
    v <- witness;
    v_init <- witness;
    trace___sha512_rounds <- [];
    i_init <- false;
    v_init <- (BArray64.init_arr (W8.of_int 0));
    t_init <- false;
    t1_init <- false;
    x_init <- false;
    k_init <- (BArray640.init_arr (W8.of_int 0));
    y_init <- false;
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, i_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, i_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      v <- (BArray64.set64 v i (BArray64.get64 h i));
      v_init <- (BArray64.set64 v_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    t_init <- true;
    t <- 0;
    while ((t < 80)) {
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      if ((16 <= t)) {
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert,
         ((0 <= (((t - 2) %% 16) * 8)) /\
         (((((t - 2) %% 16) * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, (BArray128.is_init w_init (((t - 2) %% 16) * 8) 8))]);
        x <- (BArray128.get64 w ((t - 2) %% 16));
        x_init <- true;
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, x_init)]);
        (t1, tmp__trace) <@ __sigma1_512 (x);
        trace___sha512_rounds <- (trace___sha512_rounds ++ tmp__trace);
        t1_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert,
         ((0 <= (((t - 15) %% 16) * 8)) /\
         (((((t - 15) %% 16) * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, (BArray128.is_init w_init (((t - 15) %% 16) * 8) 8))]);
        x <- (BArray128.get64 w ((t - 15) %% 16));
        x_init <- true;
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, x_init)]);
        (x, tmp__trace) <@ __sigma0_512 (x);
        trace___sha512_rounds <- (trace___sha512_rounds ++ tmp__trace);
        x_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t1_init)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert,
         ((0 <= (((t - 7) %% 16) * 8)) /\
         (((((t - 7) %% 16) * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, (BArray128.is_init w_init (((t - 7) %% 16) * 8) 8))]);
        x <- (BArray128.get64 w ((t - 7) %% 16));
        x_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t1_init)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, ((0 <= ((t %% 16) * 8)) /\ ((((t %% 16) * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, (BArray128.is_init w_init ((t %% 16) * 8) 8))]);
        x <- (BArray128.get64 w (t %% 16));
        x_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t1_init)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, x_init)]);
        t1 <- (t1 + x);
        t1_init <- true;
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, ((0 <= ((t %% 16) * 8)) /\ ((((t %% 16) * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t1_init)]);
        w <- (BArray128.set64 w (t %% 16) t1);
        w_init <-
        (BArray128.set64 w_init (t %% 16) (W64.of_int 18446744073709551615));
      } else {
        trace___sha512_rounds <-
        (trace___sha512_rounds ++ [(Assert, t_init)]);
        trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, ((0 <= (t * 8)) /\ (((t * 8) + 8) <= 128)))]);
        trace___sha512_rounds <-
        (trace___sha512_rounds ++
        [(Assert, (BArray128.is_init w_init (t * 8) 8))]);
        t1 <- (BArray128.get64 w t);
        t1_init <- true;
      }
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((7 + 80) - t) %% 8) * 8)) /\
       ((((((7 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((7 + 80) - t) %% 8) * 8) 8))]);
      t1 <- (t1 + (BArray64.get64 v (((7 + 80) - t) %% 8)));
      t1_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((4 + 80) - t) %% 8) * 8)) /\
       ((((((4 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((4 + 80) - t) %% 8) * 8) 8))]);
      (x, tmp__trace) <@ __Sigma1_512 ((BArray64.get64 v
                                       (((4 + 80) - t) %% 8)));
      trace___sha512_rounds <- (trace___sha512_rounds ++ tmp__trace);
      x_init <- true;
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((5 + 80) - t) %% 8) * 8)) /\
       ((((((5 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((5 + 80) - t) %% 8) * 8) 8))]);
      x <- (BArray64.get64 v (((5 + 80) - t) %% 8));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((6 + 80) - t) %% 8) * 8)) /\
       ((((((6 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((6 + 80) - t) %% 8) * 8) 8))]);
      x <- (x `^` (BArray64.get64 v (((6 + 80) - t) %% 8)));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((4 + 80) - t) %% 8) * 8)) /\
       ((((((4 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((4 + 80) - t) %% 8) * 8) 8))]);
      x <- (x `&` (BArray64.get64 v (((4 + 80) - t) %% 8)));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((6 + 80) - t) %% 8) * 8)) /\
       ((((((6 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((6 + 80) - t) %% 8) * 8) 8))]);
      x <- (x `^` (BArray64.get64 v (((6 + 80) - t) %% 8)));
      x_init <- true;
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      k <- sHA512_K;
      k_init <- (BArray640.init_arr (W8.of_int 255));
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (t * 8)) /\ (((t * 8) + 8) <= 640)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray640.is_init k_init (t * 8) 8))]);
      x <- (BArray640.get64 k t);
      x_init <- true;
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((3 + 80) - t) %% 8) * 8)) /\
       ((((((3 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((3 + 80) - t) %% 8) * 8)) /\
       ((((((3 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((3 + 80) - t) %% 8) * 8) 8))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      v <-
      (BArray64.set64 v (((3 + 80) - t) %% 8)
      ((BArray64.get64 v (((3 + 80) - t) %% 8)) + t1));
      v_init <-
      (BArray64.set64 v_init (((3 + 80) - t) %% 8)
      (W64.of_int 18446744073709551615));
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((0 + 80) - t) %% 8) * 8)) /\
       ((((((0 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((0 + 80) - t) %% 8) * 8) 8))]);
      (x, tmp__trace) <@ __Sigma0_512 ((BArray64.get64 v
                                       (((0 + 80) - t) %% 8)));
      trace___sha512_rounds <- (trace___sha512_rounds ++ tmp__trace);
      x_init <- true;
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((0 + 80) - t) %% 8) * 8)) /\
       ((((((0 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((0 + 80) - t) %% 8) * 8) 8))]);
      x <- (BArray64.get64 v (((0 + 80) - t) %% 8));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((1 + 80) - t) %% 8) * 8)) /\
       ((((((1 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((1 + 80) - t) %% 8) * 8) 8))]);
      x <- (x `^` (BArray64.get64 v (((1 + 80) - t) %% 8)));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((2 + 80) - t) %% 8) * 8)) /\
       ((((((2 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((2 + 80) - t) %% 8) * 8) 8))]);
      x <- (x `&` (BArray64.get64 v (((2 + 80) - t) %% 8)));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((0 + 80) - t) %% 8) * 8)) /\
       ((((((0 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((0 + 80) - t) %% 8) * 8) 8))]);
      y <- (BArray64.get64 v (((0 + 80) - t) %% 8));
      y_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, y_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((1 + 80) - t) %% 8) * 8)) /\
       ((((((1 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init ((((1 + 80) - t) %% 8) * 8) 8))]);
      y <- (y `&` (BArray64.get64 v (((1 + 80) - t) %% 8)));
      y_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, y_init)]);
      x <- (x `^` y);
      x_init <- true;
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      t1 <- (t1 + x);
      t1_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, t_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert,
       ((0 <= ((((7 + 80) - t) %% 8) * 8)) /\
       ((((((7 + 80) - t) %% 8) * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++ [(Assert, t1_init)]);
      v <- (BArray64.set64 v (((7 + 80) - t) %% 8) t1);
      v_init <-
      (BArray64.set64 v_init (((7 + 80) - t) %% 8)
      (W64.of_int 18446744073709551615));
      t <- (t + 1);
    }
    i_init <- true;
    i <- 0;
    while ((i < 8)) {
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, i_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init h_init (i * 8) 8))]);
      x <- (BArray64.get64 h i);
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, i_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, (BArray64.is_init v_init (i * 8) 8))]);
      x <- (x + (BArray64.get64 v i));
      x_init <- true;
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, i_init)]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, true)]);
      trace___sha512_rounds <-
      (trace___sha512_rounds ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 64)))]);
      trace___sha512_rounds <- (trace___sha512_rounds ++ [(Assert, x_init)]);
      h <- (BArray64.set64 h i x);
      h_init <- (BArray64.set64 h_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    return (h, h_init, trace___sha512_rounds);
  }
  proc _sha512_compress (h:BArray64.t, block:BArray128.t, ms:W64.t,
                         h_init:BArray64.t, block_init:BArray128.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var i:int;
    var x:W64.t;
    var w:BArray128.t;
    var i_init:bool;
    var x_init:bool;
    var w_init:BArray128.t;
    var ms_init:bool;
    var trace__sha512_compress:trace;
    w <- witness;
    w_init <- witness;
    trace__sha512_compress <- [];
    ms_init <- true;
    i_init <- false;
    x_init <- false;
    w_init <- (BArray128.init_arr (W8.of_int 0));
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, i_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, (BArray128.is_init block_init (i * 8) 8))]);
      x <- (BArray128.get64 block i);
      x_init <- true;
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha512_compress <- (trace__sha512_compress ++ tmp__trace);
      x_init <- true;
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, i_init)]);
      trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
      trace__sha512_compress <-
      (trace__sha512_compress ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace__sha512_compress <-
      (trace__sha512_compress ++ [(Assert, x_init)]);
      w <- (BArray128.set64 w i x);
      w_init <- (BArray128.set64 w_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    trace__sha512_compress <- (trace__sha512_compress ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_rounds (h, w, h_init, w_init);
    trace__sha512_compress <- (trace__sha512_compress ++ tmp__trace);
    trace__sha512_compress <-
    (trace__sha512_compress ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha512_compress);
  }
  proc _sha512_compress_one (h:BArray64.t, p:W64.t, ms:W64.t,
                             h_init:BArray64.t) : BArray64.t * W64.t *
                                                  BArray64.t * trace = {
    var i:int;
    var x:W64.t;
    var w:BArray128.t;
    var p_init:bool;
    var i_init:bool;
    var x_init:bool;
    var w_init:BArray128.t;
    var ms_init:bool;
    var trace__sha512_compress_one:trace;
    w <- witness;
    w_init <- witness;
    trace__sha512_compress_one <- [];
    p_init <- true;
    ms_init <- true;
    i_init <- false;
    x_init <- false;
    w_init <- (BArray128.init_arr (W8.of_int 0));
    i_init <- true;
    i <- 0;
    while ((i < 16)) {
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, p_init)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, i_init)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, true)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++
      [(Assert,
       (is_valid ptr_modulus Glob.mem_v
       (W64.to_uint (p + (W64.of_int (8 * i)))) 8))]);
      x <- (loadW64 Glob.mem (W64.to_uint (p + (W64.of_int (8 * i)))));
      x_init <- true;
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, true)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, x_init)]);
      (x, tmp__trace) <@ __bswap64 (x);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ tmp__trace);
      x_init <- true;
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, i_init)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, true)]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++
      [(Assert, ((0 <= (i * 8)) /\ (((i * 8) + 8) <= 128)))]);
      trace__sha512_compress_one <-
      (trace__sha512_compress_one ++ [(Assert, x_init)]);
      w <- (BArray128.set64 w i x);
      w_init <- (BArray128.set64 w_init i (W64.of_int 18446744073709551615));
      i <- (i + 1);
    }
    trace__sha512_compress_one <-
    (trace__sha512_compress_one ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_rounds (h, w, h_init, w_init);
    trace__sha512_compress_one <- (trace__sha512_compress_one ++ tmp__trace);
    trace__sha512_compress_one <-
    (trace__sha512_compress_one ++ [(Assert, ms_init)]);
    return (h, ms, h_init, trace__sha512_compress_one);
  }
  proc _sha512_compress_blocks (h:BArray64.t, p:W64.t, n:W64.t, ms:W64.t,
                                h_init:BArray64.t) : BArray64.t * W64.t *
                                                     BArray64.t * trace = {
    var more:bool;
    var more_init:bool;
    var ms_init:bool;
    var p_init:bool;
    var n_init:bool;
    var trace__sha512_compress_blocks:trace;
    trace__sha512_compress_blocks <- [];
    p_init <- true;
    n_init <- true;
    ms_init <- true;
    more_init <- false;
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
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
      (* Erased call to spill *)
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress_one (h, p, ms, h_init);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ tmp__trace);
      ms_init <- true;
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
      (* Erased call to unspill *)
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, p_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
      p <- (protect_64 p ms);
      p_init <- true;
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, true)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, n_init)]);
      trace__sha512_compress_blocks <-
      (trace__sha512_compress_blocks ++ [(Assert, ms_init)]);
      n <- (protect_64 n ms);
      n_init <- true;
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
  proc _sha256_x8_compress (h8:BArray256.t, blocks:BArray512.t, ms:W64.t,
                            h8_init:BArray256.t, blocks_init:BArray512.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var k:int;
    var j:int;
    var x:W32.t;
    var h:BArray32.t;
    var j_init:bool;
    var k_init:bool;
    var x_init:bool;
    var h_init:BArray32.t;
    var ms_init:bool;
    var trace__sha256_x8_compress:trace;
    h <- witness;
    h_init <- witness;
    trace__sha256_x8_compress <- [];
    ms_init <- true;
    k_init <- false;
    j_init <- false;
    x_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, j_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, k_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, true)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert, (BArray256.is_init h8_init (((8 * j) + k) * 4) 4))]);
        x <- (BArray256.get32 h8 ((8 * j) + k));
        x_init <- true;
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, j_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, true)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, x_init)]);
        h <- (BArray32.set32 h j x);
        h_init <- (BArray32.set32 h_init j (W32.of_int 4294967295));
        j <- (j + 1);
      }
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, k_init)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++
      [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress (h,
      (SBArray512_64.get_sub8 blocks (64 * k)), ms, h_init,
      (SBArray512_64.get_sub blocks_init (1 * (64 * k))));
      trace__sha256_x8_compress <- (trace__sha256_x8_compress ++ tmp__trace);
      ms_init <- true;
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, ms_init)]);
      h8 <- (protect_ptr h8 ms);
      h8_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, true)]);
      trace__sha256_x8_compress <-
      (trace__sha256_x8_compress ++ [(Assert, ms_init)]);
      blocks <- (protect_ptr blocks ms);
      blocks_init <- (BArray512.init_arr (W8.of_int 255));
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, j_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, true)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert, (BArray32.is_init h_init (j * 4) 4))]);
        x <- (BArray32.get32 h j);
        x_init <- true;
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, j_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, k_init)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, true)]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace__sha256_x8_compress <-
        (trace__sha256_x8_compress ++ [(Assert, x_init)]);
        h8 <- (BArray256.set32 h8 ((8 * j) + k) x);
        h8_init <-
        (BArray256.set32 h8_init ((8 * j) + k) (W32.of_int 4294967295));
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    trace__sha256_x8_compress <-
    (trace__sha256_x8_compress ++ [(Assert, ms_init)]);
    return (h8, ms, h8_init, trace__sha256_x8_compress);
  }
  proc _sha256_x8_compress_lanes (h8:BArray256.t, in_0:BArray64.t, off:W64.t,
                                  n:W64.t, ms:W64.t, h8_init:BArray256.t,
                                  in_init:BArray64.t) : BArray256.t * W64.t *
                                                        BArray256.t * trace = {
    var k:int;
    var j:int;
    var x:W32.t;
    var h:BArray32.t;
    var p:W64.t;
    var j_init:bool;
    var k_init:bool;
    var x_init:bool;
    var h_init:BArray32.t;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var n_init:bool;
    var trace__sha256_x8_compress_lanes:trace;
    h <- witness;
    h_init <- witness;
    trace__sha256_x8_compress_lanes <- [];
    off_init <- true;
    n_init <- true;
    ms_init <- true;
    k_init <- false;
    j_init <- false;
    x_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    p_init <- false;
    k_init <- true;
    k <- 0;
    while ((k < 8)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, j_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, k_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert, (BArray256.is_init h8_init (((8 * j) + k) * 4) 4))]);
        x <- (BArray256.get32 h8 ((8 * j) + k));
        x_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, j_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, x_init)]);
        h <- (BArray32.set32 h j x);
        h_init <- (BArray32.set32 h_init j (W32.of_int 4294967295));
        j <- (j + 1);
      }
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, k_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 64)))]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++
      [(Assert, (BArray64.is_init in_init (k * 8) 8))]);
      p <- (BArray64.get64 in_0 k);
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
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, n_init)]);
      (* Erased call to spill *)
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, p_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha256_compress_blocks (h, p, n, 
      ms, h_init);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, n_init)]);
      (* Erased call to unspill *)
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
      h8 <- (protect_ptr h8 ms);
      h8_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray64.init_arr (W8.of_int 255));
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, off_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, n_init)]);
      trace__sha256_x8_compress_lanes <-
      (trace__sha256_x8_compress_lanes ++ [(Assert, ms_init)]);
      n <- (protect_64 n ms);
      n_init <- true;
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, j_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert, ((0 <= (j * 4)) /\ (((j * 4) + 4) <= 32)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert, (BArray32.is_init h_init (j * 4) 4))]);
        x <- (BArray32.get32 h j);
        x_init <- true;
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, j_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, k_init)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, true)]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++
        [(Assert,
         ((0 <= (((8 * j) + k) * 4)) /\ (((((8 * j) + k) * 4) + 4) <= 256)))]);
        trace__sha256_x8_compress_lanes <-
        (trace__sha256_x8_compress_lanes ++ [(Assert, x_init)]);
        h8 <- (BArray256.set32 h8 ((8 * j) + k) x);
        h8_init <-
        (BArray256.set32 h8_init ((8 * j) + k) (W32.of_int 4294967295));
        j <- (j + 1);
      }
      k <- (k + 1);
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
  proc _sha512_x4_compress (h4:BArray256.t, blocks:BArray512.t, ms:W64.t,
                            h4_init:BArray256.t, blocks_init:BArray512.t) : 
  BArray256.t * W64.t * BArray256.t * trace = {
    var k:int;
    var j:int;
    var x:W64.t;
    var h:BArray64.t;
    var j_init:bool;
    var k_init:bool;
    var x_init:bool;
    var h_init:BArray64.t;
    var ms_init:bool;
    var trace__sha512_x4_compress:trace;
    h <- witness;
    h_init <- witness;
    trace__sha512_x4_compress <- [];
    ms_init <- true;
    k_init <- false;
    j_init <- false;
    x_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, k_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, (BArray256.is_init h4_init (((4 * j) + k) * 8) 8))]);
        x <- (BArray256.get64 h4 ((4 * j) + k));
        x_init <- true;
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, x_init)]);
        h <- (BArray64.set64 h j x);
        h_init <-
        (BArray64.set64 h_init j (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      (* Erased call to spill *)
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, k_init)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++
      [(Assert, ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress (h,
      (SBArray512_128.get_sub8 blocks (128 * k)), ms, h_init,
      (SBArray512_128.get_sub blocks_init (1 * (128 * k))));
      trace__sha512_x4_compress <- (trace__sha512_x4_compress ++ tmp__trace);
      ms_init <- true;
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      (* Erased call to unspill *)
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, ms_init)]);
      h4 <- (protect_ptr h4 ms);
      h4_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, true)]);
      trace__sha512_x4_compress <-
      (trace__sha512_x4_compress ++ [(Assert, ms_init)]);
      blocks <- (protect_ptr blocks ms);
      blocks_init <- (BArray512.init_arr (W8.of_int 255));
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert, (BArray64.is_init h_init (j * 8) 8))]);
        x <- (BArray64.get64 h j);
        x_init <- true;
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, j_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, k_init)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, true)]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace__sha512_x4_compress <-
        (trace__sha512_x4_compress ++ [(Assert, x_init)]);
        h4 <- (BArray256.set64 h4 ((4 * j) + k) x);
        h4_init <-
        (BArray256.set64 h4_init ((4 * j) + k)
        (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      k <- (k + 1);
    }
    trace__sha512_x4_compress <-
    (trace__sha512_x4_compress ++ [(Assert, ms_init)]);
    return (h4, ms, h4_init, trace__sha512_x4_compress);
  }
  proc _sha512_x4_compress_lanes (h4:BArray256.t, in_0:BArray32.t, off:W64.t,
                                  n:W64.t, ms:W64.t, h4_init:BArray256.t,
                                  in_init:BArray32.t) : BArray256.t * W64.t *
                                                        BArray256.t * trace = {
    var k:int;
    var j:int;
    var x:W64.t;
    var h:BArray64.t;
    var p:W64.t;
    var j_init:bool;
    var k_init:bool;
    var x_init:bool;
    var h_init:BArray64.t;
    var p_init:bool;
    var ms_init:bool;
    var off_init:bool;
    var n_init:bool;
    var trace__sha512_x4_compress_lanes:trace;
    h <- witness;
    h_init <- witness;
    trace__sha512_x4_compress_lanes <- [];
    off_init <- true;
    n_init <- true;
    ms_init <- true;
    k_init <- false;
    j_init <- false;
    x_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    p_init <- false;
    k_init <- true;
    k <- 0;
    while ((k < 4)) {
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, k_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert, (BArray256.is_init h4_init (((4 * j) + k) * 8) 8))]);
        x <- (BArray256.get64 h4 ((4 * j) + k));
        x_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, x_init)]);
        h <- (BArray64.set64 h j x);
        h_init <-
        (BArray64.set64 h_init j (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, k_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert, ((0 <= (k * 8)) /\ (((k * 8) + 8) <= 32)))]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++
      [(Assert, (BArray32.is_init in_init (k * 8) 8))]);
      p <- (BArray32.get64 in_0 k);
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
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, n_init)]);
      (* Erased call to spill *)
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, p_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      (h, ms, h_init, tmp__trace) <@ _sha512_compress_blocks (h, p, n, 
      ms, h_init);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ tmp__trace);
      ms_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, n_init)]);
      (* Erased call to unspill *)
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      h4 <- (protect_ptr h4 ms);
      h4_init <- (BArray256.init_arr (W8.of_int 255));
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      in_0 <- (protect_ptr in_0 ms);
      in_init <- (BArray32.init_arr (W8.of_int 255));
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, off_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      off <- (protect_64 off ms);
      off_init <- true;
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, n_init)]);
      trace__sha512_x4_compress_lanes <-
      (trace__sha512_x4_compress_lanes ++ [(Assert, ms_init)]);
      n <- (protect_64 n ms);
      n_init <- true;
      j_init <- true;
      j <- 0;
      while ((j < 8)) {
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert, ((0 <= (j * 8)) /\ (((j * 8) + 8) <= 64)))]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert, (BArray64.is_init h_init (j * 8) 8))]);
        x <- (BArray64.get64 h j);
        x_init <- true;
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, j_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, k_init)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, true)]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++
        [(Assert,
         ((0 <= (((4 * j) + k) * 8)) /\ (((((4 * j) + k) * 8) + 8) <= 256)))]);
        trace__sha512_x4_compress_lanes <-
        (trace__sha512_x4_compress_lanes ++ [(Assert, x_init)]);
        h4 <- (BArray256.set64 h4 ((4 * j) + k) x);
        h4_init <-
        (BArray256.set64 h4_init ((4 * j) + k)
        (W64.of_int 18446744073709551615));
        j <- (j + 1);
      }
      k <- (k + 1);
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
  proc a1____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray1.t,
                           off_:W64.t, n_:W64.t, ms:W64.t,
                           buf_init:BArray64.t, a_init:BArray1.t) : BArray64.t *
                                                                    W64.t *
                                                                    BArray64.t *
                                                                    trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a1____fill64_array:trace;
    trace_a1____fill64_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, end_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 1)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 1)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray1.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 64)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, end_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, dst_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 1)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, true)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, dst_init)]);
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a1____fill64_array <-
      (trace_a1____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, true)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, more_init)]);
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill64_array <-
    (trace_a1____fill64_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a1____fill64_array);
  }
  proc a1____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray1.t,
                            off_:W64.t, n_:W64.t, ms:W64.t,
                            buf_init:BArray128.t, a_init:BArray1.t) : 
  BArray128.t * W64.t * BArray128.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a1____fill128_array:trace;
    trace_a1____fill128_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, end_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 1)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 1)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray1.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 128)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, end_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, dst_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 1)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert, (BArray1.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray1.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, true)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, dst_init)]);
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a1____fill128_array <-
      (trace_a1____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, true)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, more_init)]);
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1____fill128_array <-
    (trace_a1____fill128_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a1____fill128_array);
  }
  proc a1___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                 a:BArray1.t, off:W64.t, len:W64.t, ms:W64.t,
                                 h_init:BArray32.t, buf_init:BArray64.t,
                                 a_init:BArray1.t) : BArray32.t *
                                                     BArray64.t * W64.t *
                                                     W64.t * BArray32.t *
                                                     BArray64.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a1___sha256_absorb_array:trace;
    trace_a1___sha256_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, more_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a1____fill64_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray1.init_arr (W8.of_int 255));
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray64.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha256_absorb_array <-
        (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a1___sha256_absorb_array <-
      (trace_a1___sha256_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, more_init)]);
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha256_absorb_array <-
    (trace_a1___sha256_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a1___sha256_absorb_array);
  }
  proc a1___sha512_absorb_array (h:BArray64.t, buf:BArray128.t, total:W64.t,
                                 a:BArray1.t, off:W64.t, len:W64.t, ms:W64.t,
                                 h_init:BArray64.t, buf_init:BArray128.t,
                                 a_init:BArray1.t) : BArray64.t *
                                                     BArray128.t * W64.t *
                                                     W64.t * BArray64.t *
                                                     BArray128.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a1___sha512_absorb_array:trace;
    trace_a1___sha512_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, more_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a1____fill128_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray1.init_arr (W8.of_int 255));
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray128.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha512_absorb_array <-
        (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a1___sha512_absorb_array <-
      (trace_a1___sha512_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, more_init)]);
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha512_absorb_array <-
    (trace_a1___sha512_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a1___sha512_absorb_array);
  }
  proc a1___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                    total:W64.t, a:BArray1.t, off:W64.t,
                                    stride:W64.t, len:W64.t, ms:W64.t,
                                    h_init:BArray256.t, buf_init:BArray512.t,
                                    a_init:BArray1.t) : BArray256.t *
                                                        BArray512.t * W64.t *
                                                        W64.t * BArray256.t *
                                                        BArray512.t * trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a1___sha256_x8_absorb_array:trace;
    trace_a1___sha256_x8_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, more_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a1____fill64_array ((
                                                               SBArray512_64.get_sub8
                                                               buf (64 * k)),
        fill, a, src, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))),
        a_init);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms,
        h_init, buf_init);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray1.init_arr (W8.of_int 255));
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha256_x8_absorb_array <-
        (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a1___sha256_x8_absorb_array <-
      (trace_a1___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha256_x8_absorb_array <-
    (trace_a1___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a1___sha256_x8_absorb_array);
  }
  proc a1___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                    total:W64.t, a:BArray1.t, off:W64.t,
                                    stride:W64.t, len:W64.t, ms:W64.t,
                                    h_init:BArray256.t, buf_init:BArray512.t,
                                    a_init:BArray1.t) : BArray256.t *
                                                        BArray512.t * W64.t *
                                                        W64.t * BArray256.t *
                                                        BArray512.t * trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a1___sha512_x4_absorb_array:trace;
    trace_a1___sha512_x4_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, more_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a1____fill128_array ((
                                                                SBArray512_128.get_sub8
                                                                buf (128 * k)
                                                                ),
        fill, a, src, n, ms,
        (SBArray512_128.get_sub buf_init (1 * (128 * k))), a_init);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms,
        h_init, buf_init);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray1.init_arr (W8.of_int 255));
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a1___sha512_x4_absorb_array <-
        (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a1___sha512_x4_absorb_array <-
      (trace_a1___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a1___sha512_x4_absorb_array <-
    (trace_a1___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a1___sha512_x4_absorb_array);
  }
  proc a1__sha256 (out:BArray32.t, a:BArray1.t, off:W64.t, len:W64.t,
                   out_init:BArray32.t, a_init:BArray1.t) : BArray32.t *
                                                            BArray32.t *
                                                            trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray32.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var trace_a1__sha256:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a1__sha256 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray1.init_arr (W8.of_int 255));
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, off_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, len_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace_a1__sha256 <- (trace_a1__sha256 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, total_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, off_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, len_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a1___sha256_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a1__sha256 <- (trace_a1__sha256 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, true)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, total_init)]);
    trace_a1__sha256 <- (trace_a1__sha256 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a1__sha256 <- (trace_a1__sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a1__sha256);
  }
  proc a1__sha512 (out:BArray64.t, a:BArray1.t, off:W64.t, len:W64.t,
                   out_init:BArray64.t, a_init:BArray1.t) : BArray64.t *
                                                            BArray64.t *
                                                            trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var trace_a1__sha512:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a1__sha512 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray1.init_arr (W8.of_int 255));
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, off_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, len_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace_a1__sha512 <- (trace_a1__sha512 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, total_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, off_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, len_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a1___sha512_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a1__sha512 <- (trace_a1__sha512 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, true)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, total_init)]);
    trace_a1__sha512 <- (trace_a1__sha512 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a1__sha512 <- (trace_a1__sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a1__sha512);
  }
  proc a1__sha256_x8 (out:BArray256.t, a:BArray1.t, off:W64.t, stride:W64.t,
                      len:W64.t, out_init:BArray256.t, a_init:BArray1.t) : 
  BArray256.t * BArray256.t * trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a1__sha256_x8:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a1__sha256_x8 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray1.init_arr (W8.of_int 255));
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, off_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, len_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_x8_init (h, h_init);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, total_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, off_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, len_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a1___sha256_x8_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, true)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, total_init)]);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256_x8_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a1__sha256_x8 <- (trace_a1__sha256_x8 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a1__sha256_x8);
  }
  proc a1__sha512_x4 (out:BArray256.t, a:BArray1.t, off:W64.t, stride:W64.t,
                      len:W64.t, out_init:BArray256.t, a_init:BArray1.t) : 
  BArray256.t * BArray256.t * trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a1__sha512_x4:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a1__sha512_x4 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray1.init_arr (W8.of_int 255));
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, off_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, len_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_x4_init (h, h_init);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, total_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, off_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, len_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a1___sha512_x4_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, true)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, total_init)]);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_x4_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a1__sha512_x4 <- (trace_a1__sha512_x4 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a1__sha512_x4);
  }
  proc a64____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray64.t,
                            off_:W64.t, n_:W64.t, ms:W64.t,
                            buf_init:BArray64.t, a_init:BArray64.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a64____fill64_array:trace;
    trace_a64____fill64_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, end_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray64.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, end_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, dst_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, true)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, dst_init)]);
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a64____fill64_array <-
      (trace_a64____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, true)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, more_init)]);
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill64_array <-
    (trace_a64____fill64_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a64____fill64_array);
  }
  proc a64____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray64.t,
                             off_:W64.t, n_:W64.t, ms:W64.t,
                             buf_init:BArray128.t, a_init:BArray64.t) : 
  BArray128.t * W64.t * BArray128.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a64____fill128_array:trace;
    trace_a64____fill128_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, end_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 64)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 64)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray64.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 128)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, end_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, dst_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 64)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert, (BArray64.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray64.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, true)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, dst_init)]);
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a64____fill128_array <-
      (trace_a64____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, true)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, more_init)]);
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64____fill128_array <-
    (trace_a64____fill128_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a64____fill128_array);
  }
  proc a64___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                  a:BArray64.t, off:W64.t, len:W64.t,
                                  ms:W64.t, h_init:BArray32.t,
                                  buf_init:BArray64.t, a_init:BArray64.t) : 
  BArray32.t * BArray64.t * W64.t * W64.t * BArray32.t * BArray64.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a64___sha256_absorb_array:trace;
    trace_a64___sha256_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, more_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a64____fill64_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray64.init_arr (W8.of_int 255));
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray64.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha256_absorb_array <-
        (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a64___sha256_absorb_array <-
      (trace_a64___sha256_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, more_init)]);
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha256_absorb_array <-
    (trace_a64___sha256_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a64___sha256_absorb_array);
  }
  proc a64___sha512_absorb_array (h:BArray64.t, buf:BArray128.t, total:W64.t,
                                  a:BArray64.t, off:W64.t, len:W64.t,
                                  ms:W64.t, h_init:BArray64.t,
                                  buf_init:BArray128.t, a_init:BArray64.t) : 
  BArray64.t * BArray128.t * W64.t * W64.t * BArray64.t * BArray128.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a64___sha512_absorb_array:trace;
    trace_a64___sha512_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, more_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a64____fill128_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray64.init_arr (W8.of_int 255));
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray128.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha512_absorb_array <-
        (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a64___sha512_absorb_array <-
      (trace_a64___sha512_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, more_init)]);
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha512_absorb_array <-
    (trace_a64___sha512_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a64___sha512_absorb_array);
  }
  proc a64___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                     total:W64.t, a:BArray64.t, off:W64.t,
                                     stride:W64.t, len:W64.t, ms:W64.t,
                                     h_init:BArray256.t,
                                     buf_init:BArray512.t, a_init:BArray64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t * BArray256.t * BArray512.t *
  trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a64___sha256_x8_absorb_array:trace;
    trace_a64___sha256_x8_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, more_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a64____fill64_array ((
                                                                SBArray512_64.get_sub8
                                                                buf (64 * k)),
        fill, a, src, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))),
        a_init);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms,
        h_init, buf_init);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray64.init_arr (W8.of_int 255));
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha256_x8_absorb_array <-
        (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a64___sha256_x8_absorb_array <-
      (trace_a64___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha256_x8_absorb_array <-
    (trace_a64___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a64___sha256_x8_absorb_array);
  }
  proc a64___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                     total:W64.t, a:BArray64.t, off:W64.t,
                                     stride:W64.t, len:W64.t, ms:W64.t,
                                     h_init:BArray256.t,
                                     buf_init:BArray512.t, a_init:BArray64.t) : 
  BArray256.t * BArray512.t * W64.t * W64.t * BArray256.t * BArray512.t *
  trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a64___sha512_x4_absorb_array:trace;
    trace_a64___sha512_x4_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, more_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a64____fill128_array ((
                                                                 SBArray512_128.get_sub8
                                                                 buf
                                                                 (128 * k)),
        fill, a, src, n, ms,
        (SBArray512_128.get_sub buf_init (1 * (128 * k))), a_init);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms,
        h_init, buf_init);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray64.init_arr (W8.of_int 255));
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a64___sha512_x4_absorb_array <-
        (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a64___sha512_x4_absorb_array <-
      (trace_a64___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a64___sha512_x4_absorb_array <-
    (trace_a64___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a64___sha512_x4_absorb_array);
  }
  proc a64__sha256 (out:BArray32.t, a:BArray64.t, off:W64.t, len:W64.t,
                    out_init:BArray32.t, a_init:BArray64.t) : BArray32.t *
                                                              BArray32.t *
                                                              trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray32.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var trace_a64__sha256:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a64__sha256 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, off_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, len_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace_a64__sha256 <- (trace_a64__sha256 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, total_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, off_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, len_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a64___sha256_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a64__sha256 <- (trace_a64__sha256 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, true)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, total_init)]);
    trace_a64__sha256 <- (trace_a64__sha256 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a64__sha256 <- (trace_a64__sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a64__sha256);
  }
  proc a64__sha512 (out:BArray64.t, a:BArray64.t, off:W64.t, len:W64.t,
                    out_init:BArray64.t, a_init:BArray64.t) : BArray64.t *
                                                              BArray64.t *
                                                              trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var trace_a64__sha512:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a64__sha512 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, off_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, len_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace_a64__sha512 <- (trace_a64__sha512 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, total_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, off_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, len_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a64___sha512_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a64__sha512 <- (trace_a64__sha512 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, true)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, total_init)]);
    trace_a64__sha512 <- (trace_a64__sha512 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a64__sha512 <- (trace_a64__sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a64__sha512);
  }
  proc a64__sha256_x8 (out:BArray256.t, a:BArray64.t, off:W64.t,
                       stride:W64.t, len:W64.t, out_init:BArray256.t,
                       a_init:BArray64.t) : BArray256.t * BArray256.t * trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a64__sha256_x8:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a64__sha256_x8 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, off_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <-
    (trace_a64__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, len_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_x8_init (h, h_init);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, total_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, off_init)]);
    trace_a64__sha256_x8 <-
    (trace_a64__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, len_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a64___sha256_x8_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, true)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, total_init)]);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256_x8_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a64__sha256_x8 <- (trace_a64__sha256_x8 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a64__sha256_x8);
  }
  proc a64__sha512_x4 (out:BArray256.t, a:BArray64.t, off:W64.t,
                       stride:W64.t, len:W64.t, out_init:BArray256.t,
                       a_init:BArray64.t) : BArray256.t * BArray256.t * trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a64__sha512_x4:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a64__sha512_x4 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, off_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <-
    (trace_a64__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, len_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_x4_init (h, h_init);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, total_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, off_init)]);
    trace_a64__sha512_x4 <-
    (trace_a64__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, len_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a64___sha512_x4_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, true)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, total_init)]);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_x4_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a64__sha512_x4 <- (trace_a64__sha512_x4 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a64__sha512_x4);
  }
  proc a128____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray128.t,
                             off_:W64.t, n_:W64.t, ms:W64.t,
                             buf_init:BArray64.t, a_init:BArray128.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a128____fill64_array:trace;
    trace_a128____fill64_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, end_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 128)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 128)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray128.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 64)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, end_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, dst_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 128)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, true)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, dst_init)]);
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a128____fill64_array <-
      (trace_a128____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, true)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, more_init)]);
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill64_array <-
    (trace_a128____fill64_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a128____fill64_array);
  }
  proc a128____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray128.t,
                              off_:W64.t, n_:W64.t, ms:W64.t,
                              buf_init:BArray128.t, a_init:BArray128.t) : 
  BArray128.t * W64.t * BArray128.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a128____fill128_array:trace;
    trace_a128____fill128_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, end_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray128.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, end_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, dst_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert, (BArray128.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray128.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, true)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, dst_init)]);
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a128____fill128_array <-
      (trace_a128____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, true)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, more_init)]);
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128____fill128_array <-
    (trace_a128____fill128_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a128____fill128_array);
  }
  proc a128___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                   a:BArray128.t, off:W64.t, len:W64.t,
                                   ms:W64.t, h_init:BArray32.t,
                                   buf_init:BArray64.t, a_init:BArray128.t) : 
  BArray32.t * BArray64.t * W64.t * W64.t * BArray32.t * BArray64.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a128___sha256_absorb_array:trace;
    trace_a128___sha256_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, more_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a128____fill64_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray128.init_arr (W8.of_int 255));
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray64.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha256_absorb_array <-
        (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a128___sha256_absorb_array <-
      (trace_a128___sha256_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, more_init)]);
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha256_absorb_array <-
    (trace_a128___sha256_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a128___sha256_absorb_array);
  }
  proc a128___sha512_absorb_array (h:BArray64.t, buf:BArray128.t,
                                   total:W64.t, a:BArray128.t, off:W64.t,
                                   len:W64.t, ms:W64.t, h_init:BArray64.t,
                                   buf_init:BArray128.t, a_init:BArray128.t) : 
  BArray64.t * BArray128.t * W64.t * W64.t * BArray64.t * BArray128.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a128___sha512_absorb_array:trace;
    trace_a128___sha512_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, more_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a128____fill128_array (buf, 
      fill, a, off, n, ms, buf_init, a_init);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray128.init_arr (W8.of_int 255));
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray128.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha512_absorb_array <-
        (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a128___sha512_absorb_array <-
      (trace_a128___sha512_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, more_init)]);
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha512_absorb_array <-
    (trace_a128___sha512_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a128___sha512_absorb_array);
  }
  proc a128___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray128.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t,
                                      h_init:BArray256.t,
                                      buf_init:BArray512.t,
                                      a_init:BArray128.t) : BArray256.t *
                                                            BArray512.t *
                                                            W64.t * W64.t *
                                                            BArray256.t *
                                                            BArray512.t *
                                                            trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a128___sha256_x8_absorb_array:trace;
    trace_a128___sha256_x8_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, more_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a128____fill64_array ((
                                                                 SBArray512_64.get_sub8
                                                                 buf 
                                                                 (64 * k)),
        fill, a, src, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))),
        a_init);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms,
        h_init, buf_init);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray128.init_arr (W8.of_int 255));
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha256_x8_absorb_array <-
        (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a128___sha256_x8_absorb_array <-
      (trace_a128___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha256_x8_absorb_array <-
    (trace_a128___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a128___sha256_x8_absorb_array);
  }
  proc a128___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray128.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t,
                                      h_init:BArray256.t,
                                      buf_init:BArray512.t,
                                      a_init:BArray128.t) : BArray256.t *
                                                            BArray512.t *
                                                            W64.t * W64.t *
                                                            BArray256.t *
                                                            BArray512.t *
                                                            trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a128___sha512_x4_absorb_array:trace;
    trace_a128___sha512_x4_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, more_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a128____fill128_array ((
                                                                  SBArray512_128.get_sub8
                                                                  buf
                                                                  (128 * k)),
        fill, a, src, n, ms,
        (SBArray512_128.get_sub buf_init (1 * (128 * k))), a_init);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms,
        h_init, buf_init);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray128.init_arr (W8.of_int 255));
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a128___sha512_x4_absorb_array <-
        (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a128___sha512_x4_absorb_array <-
      (trace_a128___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a128___sha512_x4_absorb_array <-
    (trace_a128___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a128___sha512_x4_absorb_array);
  }
  proc a128__sha256 (out:BArray32.t, a:BArray128.t, off:W64.t, len:W64.t,
                     out_init:BArray32.t, a_init:BArray128.t) : BArray32.t *
                                                                BArray32.t *
                                                                trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray32.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var trace_a128__sha256:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a128__sha256 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray128.init_arr (W8.of_int 255));
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, off_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, len_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace_a128__sha256 <- (trace_a128__sha256 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, total_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, off_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, len_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a128___sha256_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a128__sha256 <- (trace_a128__sha256 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, true)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, total_init)]);
    trace_a128__sha256 <- (trace_a128__sha256 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a128__sha256 <- (trace_a128__sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a128__sha256);
  }
  proc a128__sha512 (out:BArray64.t, a:BArray128.t, off:W64.t, len:W64.t,
                     out_init:BArray64.t, a_init:BArray128.t) : BArray64.t *
                                                                BArray64.t *
                                                                trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var trace_a128__sha512:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a128__sha512 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray128.init_arr (W8.of_int 255));
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, off_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, len_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace_a128__sha512 <- (trace_a128__sha512 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, total_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, off_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, len_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a128___sha512_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a128__sha512 <- (trace_a128__sha512 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, true)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, total_init)]);
    trace_a128__sha512 <- (trace_a128__sha512 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a128__sha512 <- (trace_a128__sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a128__sha512);
  }
  proc a128__sha256_x8 (out:BArray256.t, a:BArray128.t, off:W64.t,
                        stride:W64.t, len:W64.t, out_init:BArray256.t,
                        a_init:BArray128.t) : BArray256.t * BArray256.t *
                                              trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a128__sha256_x8:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a128__sha256_x8 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray128.init_arr (W8.of_int 255));
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, off_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <-
    (trace_a128__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, len_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_x8_init (h, h_init);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <-
    (trace_a128__sha256_x8 ++ [(Assert, total_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, off_init)]);
    trace_a128__sha256_x8 <-
    (trace_a128__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, len_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a128___sha256_x8_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, true)]);
    trace_a128__sha256_x8 <-
    (trace_a128__sha256_x8 ++ [(Assert, total_init)]);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256_x8_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a128__sha256_x8 <- (trace_a128__sha256_x8 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a128__sha256_x8);
  }
  proc a128__sha512_x4 (out:BArray256.t, a:BArray128.t, off:W64.t,
                        stride:W64.t, len:W64.t, out_init:BArray256.t,
                        a_init:BArray128.t) : BArray256.t * BArray256.t *
                                              trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a128__sha512_x4:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a128__sha512_x4 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray128.init_arr (W8.of_int 255));
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, off_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <-
    (trace_a128__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, len_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_x4_init (h, h_init);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <-
    (trace_a128__sha512_x4 ++ [(Assert, total_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, off_init)]);
    trace_a128__sha512_x4 <-
    (trace_a128__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, len_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a128___sha512_x4_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, true)]);
    trace_a128__sha512_x4 <-
    (trace_a128__sha512_x4 ++ [(Assert, total_init)]);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_x4_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a128__sha512_x4 <- (trace_a128__sha512_x4 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a128__sha512_x4);
  }
  proc a333____fill64_array (buf:BArray64.t, dst_:W64.t, a:BArray333.t,
                             off_:W64.t, n_:W64.t, ms:W64.t,
                             buf_init:BArray64.t, a_init:BArray333.t) : 
  BArray64.t * W64.t * BArray64.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a333____fill64_array:trace;
    trace_a333____fill64_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, end_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 333)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 333)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray333.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 64)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray64.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, end_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, dst_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 333)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, true)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 64)))]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, t_init)]);
      buf <- (BArray64.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <- (BArray64.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, dst_init)]);
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a333____fill64_array <-
      (trace_a333____fill64_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, true)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, more_init)]);
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill64_array <-
    (trace_a333____fill64_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a333____fill64_array);
  }
  proc a333____fill128_array (buf:BArray128.t, dst_:W64.t, a:BArray333.t,
                              off_:W64.t, n_:W64.t, ms:W64.t,
                              buf_init:BArray128.t, a_init:BArray333.t) : 
  BArray128.t * W64.t * BArray128.t * trace = {
    var dst:W64.t;
    var off:W64.t;
    var n:W64.t;
    var head:W64.t;
    var end_0:W64.t;
    var more:bool;
    var t:W64.t;
    var dst__init:bool;
    var dst_init:bool;
    var off__init:bool;
    var off_init:bool;
    var n__init:bool;
    var n_init:bool;
    var head_init:bool;
    var end_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var t_init:bool;
    var trace_a333____fill128_array:trace;
    trace_a333____fill128_array <- [];
    dst__init <- true;
    off__init <- true;
    n__init <- true;
    ms_init <- true;
    dst_init <- false;
    off_init <- false;
    n_init <- false;
    head_init <- false;
    end_init <- false;
    more_init <- false;
    t_init <- false;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst__init)]);
    dst <- dst_;
    dst_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, off__init)]);
    off <- off_;
    off_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n__init)]);
    n <- n_;
    n_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst_init)]);
    head <- dst;
    head_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    head <- (- head);
    head_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    head <- (head `&` (W64.of_int 7));
    head_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    head <- ((n \ult head) ? n : head);
    head_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    n <- (n - head);
    n_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, end_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, head_init)]);
    end_0 <- (end_0 + head);
    end_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 333)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n_init)]);
    more <- ((W64.of_int 8) \ule n);
    more_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 8) <= 333)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 8))]);
      t <- (BArray333.get64d a (W64.to_uint off));
      t_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 8) <= 128)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set64d buf (W64.to_uint dst) t);
      buf_init <-
      (BArray128.set64d buf_init (W64.to_uint dst)
      (W64.of_int 18446744073709551615));
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 8));
      dst_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 8));
      off_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, n_init)]);
      n <- (n - (W64.of_int 8));
      n_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, n_init)]);
      more <- ((W64.of_int 8) \ule n);
      more_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst_init)]);
    end_0 <- dst;
    end_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, end_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, n_init)]);
    end_0 <- (end_0 + n);
    end_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, dst_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, end_init)]);
    more <- (dst \ult end_0);
    more_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint off) * 1)) /\
       ((((W64.to_uint off) * 1) + 1) <= 333)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert, (BArray333.is_init a_init ((W64.to_uint off) * 1) 1))]);
      t <- (zeroextu64 (BArray333.get8 a (W64.to_uint off)));
      t_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, true)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++
      [(Assert,
       ((0 <= ((W64.to_uint dst) * 1)) /\
       ((((W64.to_uint dst) * 1) + 1) <= 128)))]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, t_init)]);
      buf <- (BArray128.set8 buf (W64.to_uint dst) (truncateu8 t));
      buf_init <-
      (BArray128.set8 buf_init (W64.to_uint dst) (W8.of_int 255));
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      dst <- (dst + (W64.of_int 1));
      dst_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, off_init)]);
      off <- (off + (W64.of_int 1));
      off_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, dst_init)]);
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, end_init)]);
      more <- (dst \ult end_0);
      more_init <- true;
      trace_a333____fill128_array <-
      (trace_a333____fill128_array ++ [(Assert, more_init)]);
    }
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, true)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, more_init)]);
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333____fill128_array <-
    (trace_a333____fill128_array ++ [(Assert, ms_init)]);
    return (buf, ms, buf_init, trace_a333____fill128_array);
  }
  proc a333___sha256_absorb_array (h:BArray32.t, buf:BArray64.t, total:W64.t,
                                   a:BArray333.t, off:W64.t, len:W64.t,
                                   ms:W64.t, h_init:BArray32.t,
                                   buf_init:BArray64.t, a_init:BArray333.t) : 
  BArray32.t * BArray64.t * W64.t * W64.t * BArray32.t * BArray64.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a333___sha256_absorb_array:trace;
    trace_a333___sha256_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, more_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a333____fill64_array (buf, fill, 
      a, off, n, ms, buf_init, a_init);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray333.init_arr (W8.of_int 255));
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray64.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha256_absorb_array <-
        (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a333___sha256_absorb_array <-
      (trace_a333___sha256_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, more_init)]);
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha256_absorb_array <-
    (trace_a333___sha256_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a333___sha256_absorb_array);
  }
  proc a333___sha512_absorb_array (h:BArray64.t, buf:BArray128.t,
                                   total:W64.t, a:BArray333.t, off:W64.t,
                                   len:W64.t, ms:W64.t, h_init:BArray64.t,
                                   buf_init:BArray128.t, a_init:BArray333.t) : 
  BArray64.t * BArray128.t * W64.t * W64.t * BArray64.t * BArray128.t * trace = {
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var full_init:bool;
    var trace_a333___sha512_absorb_array:trace;
    trace_a333___sha512_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    full_init <- false;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, more_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
      (buf, ms, buf_init, tmp__trace) <@ a333____fill128_array (buf, 
      fill, a, off, n, ms, buf_init, a_init);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ tmp__trace);
      ms_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_compress (h, buf, ms, 
        h_init, buf_init);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        total <- (protect_64 total ms);
        total_init <- true;
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray333.init_arr (W8.of_int 255));
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray128.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha512_absorb_array <-
        (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a333___sha512_absorb_array <-
      (trace_a333___sha512_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, more_init)]);
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha512_absorb_array <-
    (trace_a333___sha512_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a333___sha512_absorb_array);
  }
  proc a333___sha256_x8_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray333.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t,
                                      h_init:BArray256.t,
                                      buf_init:BArray512.t,
                                      a_init:BArray333.t) : BArray256.t *
                                                            BArray512.t *
                                                            W64.t * W64.t *
                                                            BArray256.t *
                                                            BArray512.t *
                                                            trace = {
    var aux:BArray64.t;
    var aux_1:BArray64.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a333___sha256_x8_absorb_array:trace;
    trace_a333___sha256_x8_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 63));
    fill_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, more_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 64);
      n_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 8)) {
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, k_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++
        [(Assert, ((0 <= ((64 * k) * 1)) /\ ((((64 * k) * 1) + 64) <= 512)))]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a333____fill64_array ((
                                                                 SBArray512_64.get_sub8
                                                                 buf 
                                                                 (64 * k)),
        fill, a, src, n, ms, (SBArray512_64.get_sub buf_init (1 * (64 * k))),
        a_init);
        buf <- (SBArray512_64.set_sub8 buf (64 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_64.set_sub buf_init (1 * (64 * k)) aux_1);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, src_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 64));
      full_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha256_x8_compress (h, buf, ms,
        h_init, buf_init);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray333.init_arr (W8.of_int 255));
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha256_x8_absorb_array <-
        (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a333___sha256_x8_absorb_array <-
      (trace_a333___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, more_init)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, true)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha256_x8_absorb_array <-
    (trace_a333___sha256_x8_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a333___sha256_x8_absorb_array);
  }
  proc a333___sha512_x4_absorb_array (h:BArray256.t, buf:BArray512.t,
                                      total:W64.t, a:BArray333.t, off:W64.t,
                                      stride:W64.t, len:W64.t, ms:W64.t,
                                      h_init:BArray256.t,
                                      buf_init:BArray512.t,
                                      a_init:BArray333.t) : BArray256.t *
                                                            BArray512.t *
                                                            W64.t * W64.t *
                                                            BArray256.t *
                                                            BArray512.t *
                                                            trace = {
    var aux:BArray128.t;
    var aux_1:BArray128.t;
    var aux_0:W64.t;
    var fill:W64.t;
    var more:bool;
    var n:W64.t;
    var src:W64.t;
    var k:int;
    var full:bool;
    var total_init:bool;
    var fill_init:bool;
    var len_init:bool;
    var more_init:bool;
    var ms_init:bool;
    var n_init:bool;
    var off_init:bool;
    var src_init:bool;
    var k_init:bool;
    var stride_init:bool;
    var full_init:bool;
    var trace_a333___sha512_x4_absorb_array:trace;
    trace_a333___sha512_x4_absorb_array <- [];
    total_init <- true;
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- true;
    fill_init <- false;
    more_init <- false;
    n_init <- false;
    src_init <- false;
    k_init <- false;
    full_init <- false;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    fill <- total;
    fill_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
    fill <- (fill `&` (W64.of_int 127));
    fill_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    total <- (total + len);
    total_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to spill *)
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
    more <- (len <> (W64.of_int 0));
    more_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    while (more) {
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, more_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
      ms <- (update_msf more ms);
      ms_init <- true;
      n <- (W64.of_int 128);
      n_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      n <- (n - fill);
      n_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      n <- ((len \ult n) ? len : n);
      n_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      src <- off;
      src_init <- true;
      k_init <- true;
      k <- 0;
      while ((k < 4)) {
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, k_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++
        [(Assert,
         ((0 <= ((128 * k) * 1)) /\ ((((128 * k) * 1) + 128) <= 512)))]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (aux, aux_0, aux_1, tmp__trace) <@ a333____fill128_array ((
                                                                  SBArray512_128.get_sub8
                                                                  buf
                                                                  (128 * k)),
        fill, a, src, n, ms,
        (SBArray512_128.get_sub buf_init (1 * (128 * k))), a_init);
        buf <- (SBArray512_128.set_sub8 buf (128 * k) aux);
        ms <- aux_0;
        buf_init <- (SBArray512_128.set_sub buf_init (1 * (128 * k)) aux_1);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, src_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        src <- (src + stride);
        src_init <- true;
        k <- (k + 1);
      }
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      fill <- (fill + n);
      fill_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, off_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      off <- (off + n);
      off_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, n_init)]);
      len <- (len - n);
      len_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, fill_init)]);
      full <- (fill = (W64.of_int 128));
      full_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, full_init)]);
      if (full) {
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf full ms);
        ms_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to unspill *)
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        h <- (protect_ptr h ms);
        h_init <- (BArray256.init_arr (W8.of_int 255));
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to spill *)
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        (h, ms, h_init, tmp__trace) <@ _sha512_x4_compress (h, buf, ms,
        h_init, buf_init);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ tmp__trace);
        ms_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        (* Erased call to unspill *)
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        (* Erased call to spill *)
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        a <- (protect_ptr a ms);
        a_init <- (BArray333.init_arr (W8.of_int 255));
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, off_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        off <- (protect_64 off ms);
        off_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, stride_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        stride <- (protect_64 stride ms);
        stride_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        len <- (protect_64 len ms);
        len_init <- true;
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        buf <- (protect_ptr buf ms);
        buf_init <- (BArray512.init_arr (W8.of_int 255));
        fill <- (W64.of_int 0);
        fill_init <- true;
      } else {
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, full_init)]);
        trace_a333___sha512_x4_absorb_array <-
        (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
        ms <- (update_msf (! full) ms);
        ms_init <- true;
      }
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, len_init)]);
      more <- (len <> (W64.of_int 0));
      more_init <- true;
      trace_a333___sha512_x4_absorb_array <-
      (trace_a333___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    }
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, more_init)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    ms <- (update_msf (! more) ms);
    ms_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    (* Erased call to unspill *)
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    h <- (protect_ptr h ms);
    h_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, true)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    total <- (protect_64 total ms);
    total_init <- true;
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, total_init)]);
    trace_a333___sha512_x4_absorb_array <-
    (trace_a333___sha512_x4_absorb_array ++ [(Assert, ms_init)]);
    return (h, buf, total, ms, h_init, buf_init,
           trace_a333___sha512_x4_absorb_array);
  }
  proc a333__sha256 (out:BArray32.t, a:BArray333.t, off:W64.t, len:W64.t,
                     out_init:BArray32.t, a_init:BArray333.t) : BArray32.t *
                                                                BArray32.t *
                                                                trace = {
    var ms:W64.t;
    var h:BArray32.t;
    var buf_s:BArray64.t;
    var buf:BArray64.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray32.t;
    var buf_s_init:BArray64.t;
    var buf_init:BArray64.t;
    var total_init:bool;
    var trace_a333__sha256:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a333__sha256 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray32.init_arr (W8.of_int 0));
    buf_s_init <- (BArray64.init_arr (W8.of_int 0));
    buf_init <- (BArray64.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray333.init_arr (W8.of_int 255));
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, off_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, len_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_init (h, h_init);
    trace_a333__sha256 <- (trace_a333__sha256 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, total_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, off_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, len_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a333___sha256_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a333__sha256 <- (trace_a333__sha256 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray32.init_arr (W8.of_int 255));
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, true)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, total_init)]);
    trace_a333__sha256 <- (trace_a333__sha256 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256___sha256_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a333__sha256 <- (trace_a333__sha256 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a333__sha256);
  }
  proc a333__sha512 (out:BArray64.t, a:BArray333.t, off:W64.t, len:W64.t,
                     out_init:BArray64.t, a_init:BArray333.t) : BArray64.t *
                                                                BArray64.t *
                                                                trace = {
    var ms:W64.t;
    var h:BArray64.t;
    var buf_s:BArray128.t;
    var buf:BArray128.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var len_init:bool;
    var h_init:BArray64.t;
    var buf_s_init:BArray128.t;
    var buf_init:BArray128.t;
    var total_init:bool;
    var trace_a333__sha512:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a333__sha512 <- [];
    off_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray64.init_arr (W8.of_int 0));
    buf_s_init <- (BArray128.init_arr (W8.of_int 0));
    buf_init <- (BArray128.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray333.init_arr (W8.of_int 255));
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, off_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, len_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_init (h, h_init);
    trace_a333__sha512 <- (trace_a333__sha512 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, total_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, off_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, len_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a333___sha512_absorb_array (
    h, buf, total, a, off, len, ms, h_init, buf_init, a_init);
    trace_a333__sha512 <- (trace_a333__sha512 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray64.init_arr (W8.of_int 255));
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, true)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, total_init)]);
    trace_a333__sha512 <- (trace_a333__sha512 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512___sha512_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a333__sha512 <- (trace_a333__sha512 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a333__sha512);
  }
  proc a333__sha256_x8 (out:BArray256.t, a:BArray333.t, off:W64.t,
                        stride:W64.t, len:W64.t, out_init:BArray256.t,
                        a_init:BArray333.t) : BArray256.t * BArray256.t *
                                              trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a333__sha256_x8:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a333__sha256_x8 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray333.init_arr (W8.of_int 255));
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, off_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <-
    (trace_a333__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, len_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha256_x8_init (h, h_init);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <-
    (trace_a333__sha256_x8 ++ [(Assert, total_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, off_init)]);
    trace_a333__sha256_x8 <-
    (trace_a333__sha256_x8 ++ [(Assert, stride_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, len_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a333___sha256_x8_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, true)]);
    trace_a333__sha256_x8 <-
    (trace_a333__sha256_x8 ++ [(Assert, total_init)]);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha256_x8_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a333__sha256_x8 <- (trace_a333__sha256_x8 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a333__sha256_x8);
  }
  proc a333__sha512_x4 (out:BArray256.t, a:BArray333.t, off:W64.t,
                        stride:W64.t, len:W64.t, out_init:BArray256.t,
                        a_init:BArray333.t) : BArray256.t * BArray256.t *
                                              trace = {
    var ms:W64.t;
    var h:BArray256.t;
    var buf_s:BArray512.t;
    var buf:BArray512.t;
    var total:W64.t;
    var ms_init:bool;
    var off_init:bool;
    var stride_init:bool;
    var len_init:bool;
    var h_init:BArray256.t;
    var buf_s_init:BArray512.t;
    var buf_init:BArray512.t;
    var total_init:bool;
    var trace_a333__sha512_x4:trace;
    buf <- witness;
    buf_init <- witness;
    buf_s <- witness;
    buf_s_init <- witness;
    h <- witness;
    h_init <- witness;
    trace_a333__sha512_x4 <- [];
    off_init <- true;
    stride_init <- true;
    len_init <- true;
    ms_init <- false;
    h_init <- (BArray256.init_arr (W8.of_int 0));
    buf_s_init <- (BArray512.init_arr (W8.of_int 0));
    buf_init <- (BArray512.init_arr (W8.of_int 0));
    total_init <- false;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    ms <- (init_msf);
    ms_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    a <- (protect_ptr a ms);
    a_init <- (BArray333.init_arr (W8.of_int 255));
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, off_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    off <- (protect_64 off ms);
    off_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <-
    (trace_a333__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    stride <- (protect_64 stride ms);
    stride_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, len_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    len <- (protect_64 len ms);
    len_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    (h, h_init, tmp__trace) <@ __sha512_x4_init (h, h_init);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ tmp__trace);
    buf <- buf_s;
    buf_init <- buf_s_init;
    total <- (W64.of_int 0);
    total_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to spill *)
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <-
    (trace_a333__sha512_x4 ++ [(Assert, total_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, off_init)]);
    trace_a333__sha512_x4 <-
    (trace_a333__sha512_x4 ++ [(Assert, stride_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, len_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    (h, buf, total, ms, h_init, buf_init, tmp__trace) <@ a333___sha512_x4_absorb_array (
    h, buf, total, a, off, stride, len, ms, h_init, buf_init, a_init);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ tmp__trace);
    total_init <- true;
    ms_init <- true;
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    (* Erased call to unspill *)
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    out <- (protect_ptr out ms);
    out_init <- (BArray256.init_arr (W8.of_int 255));
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, true)]);
    trace_a333__sha512_x4 <-
    (trace_a333__sha512_x4 ++ [(Assert, total_init)]);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ [(Assert, ms_init)]);
    (out, h, buf, ms, out_init, h_init, buf_init, tmp__trace) <@ _sha512_x4_finalize (
    out, h, buf, total, ms, out_init, h_init, buf_init);
    trace_a333__sha512_x4 <- (trace_a333__sha512_x4 ++ tmp__trace);
    ms_init <- true;
    return (out, out_init, trace_a333__sha512_x4);
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

op __Sigma0_256_spec _x =
   hoare [M.__Sigma0_256 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __Sigma1_256_spec _x =
   hoare [M.__Sigma1_256 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sigma0_256_spec _x =
   hoare [M.__sigma0_256 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sigma1_256_spec _x =
   hoare [M.__sigma1_256 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sha256_rounds_spec _h _w _h_init _w_init =
   hoare [M.__sha256_rounds :
   (((_w_init = w_init) /\ ((_h_init = h_init) /\ ((_w = w) /\ (_h = h)))) /\
   ((BArray32.is_init _h_init 0 32) /\ (BArray64.is_init _w_init 0 64))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op _sha256_compress_spec _h _block _ms _h_init _block_init =
   hoare [M._sha256_compress :
   (((_block_init = block_init) /\
    ((_h_init = h_init) /\ ((_ms = ms) /\ ((_block = block) /\ (_h = h))))) /\
   ((BArray32.is_init _h_init 0 32) /\ (BArray64.is_init _block_init 0 64))) ==>
   ((BArray32.is_init res.`3 0 32) /\ (valid res.`4))].

op _sha256_compress_one_spec _h _p _ms _h_init =
   hoare [M._sha256_compress_one :
   (((_h_init = h_init) /\ ((_ms = ms) /\ ((_p = p) /\ (_h = h)))) /\
   (true /\
   ((BArray32.is_init _h_init 0 32) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p) 64)))) ==>
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

op __Sigma0_512_spec _x =
   hoare [M.__Sigma0_512 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __Sigma1_512_spec _x =
   hoare [M.__Sigma1_512 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sigma0_512_spec _x =
   hoare [M.__sigma0_512 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sigma1_512_spec _x =
   hoare [M.__sigma1_512 : ((_x = x) /\ true) ==> (true /\ (valid res.`2))].

op __sha512_rounds_spec _h _w _h_init _w_init =
   hoare [M.__sha512_rounds :
   (((_w_init = w_init) /\ ((_h_init = h_init) /\ ((_w = w) /\ (_h = h)))) /\
   ((BArray64.is_init _h_init 0 64) /\ (BArray128.is_init _w_init 0 128))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op _sha512_compress_spec _h _block _ms _h_init _block_init =
   hoare [M._sha512_compress :
   (((_block_init = block_init) /\
    ((_h_init = h_init) /\ ((_ms = ms) /\ ((_block = block) /\ (_h = h))))) /\
   ((BArray64.is_init _h_init 0 64) /\ (BArray128.is_init _block_init 0 128))) ==>
   ((BArray64.is_init res.`3 0 64) /\ (valid res.`4))].

op _sha512_compress_one_spec _h _p _ms _h_init =
   hoare [M._sha512_compress_one :
   (((_h_init = h_init) /\ ((_ms = ms) /\ ((_p = p) /\ (_h = h)))) /\
   (true /\
   ((BArray64.is_init _h_init 0 64) /\
   (is_valid ptr_modulus Glob.mem_v (W64.to_uint _p) 128)))) ==>
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

op a1____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a1____fill64_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 64)) /\ (_n_ \ule (W64.of_int 64))) /\
       ((_dst_ + _n_) \ule (W64.of_int 64))) /\
      (BArray64.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 1))) /\
    ((_off_ + _n_) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray64.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a1____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a1____fill128_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 128)) /\ (_n_ \ule (W64.of_int 128))) /\
       ((_dst_ + _n_) \ule (W64.of_int 128))) /\
      (BArray128.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 1))) /\
    ((_off_ + _n_) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray128.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a1___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a1___sha256_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray32.is_init _h_init 0 32) /\
       (BArray64.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 64))))) /\
      (_off \ule (W64.of_int 1))) /\
     (_len \ule (W64.of_int 1))) /\
    ((_off + _len) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray32.is_init res.`5 0 32) /\
     (BArray64.is_init res.`6 0 (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a1___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a1___sha512_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray64.is_init _h_init 0 64) /\
       (BArray128.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 128))))) /\
      (_off \ule (W64.of_int 1))) /\
     (_len \ule (W64.of_int 1))) /\
    ((_off + _len) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray64.is_init res.`5 0 64) /\
     (BArray128.is_init res.`6 0
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a1___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a1___sha256_x8_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((((((((((BArray256.is_init _h_init 0 256) /\
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
              (_off \ule (W64.of_int 1))) /\
             (_stride \ule (W64.of_int 1))) /\
            (_len \ule (W64.of_int 1))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule (W64.of_int 1))) /\
          (BArray1.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray1.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray1.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray1.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray1.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray1.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray1.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray1.is_init _a_init (W64.to_uint (_off + ((W64.of_int 7) * _stride)))
   (W64.to_uint _len)))))))))))))))))))))))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))))))))))) /\
   (valid res.`7))].

op a1___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a1___sha512_x4_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((BArray256.is_init _h_init 0 256) /\
              (BArray512.is_init _buf_init 0
              (W64.to_uint (_total \umod (W64.of_int 128))))) /\
             (BArray512.is_init _buf_init 128
             (W64.to_uint (_total \umod (W64.of_int 128))))) /\
            (BArray512.is_init _buf_init 256
            (W64.to_uint (_total \umod (W64.of_int 128))))) /\
           (BArray512.is_init _buf_init 384
           (W64.to_uint (_total \umod (W64.of_int 128))))) /\
          (_off \ule (W64.of_int 1))) /\
         (_stride \ule (W64.of_int 1))) /\
        (_len \ule (W64.of_int 1))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 1))) /\
      (BArray1.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray1.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray1.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray1.is_init _a_init (W64.to_uint (_off + ((W64.of_int 3) * _stride)))
   (W64.to_uint _len)))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))) /\
   (valid res.`7))].

op a1__sha256_spec _out _a _off _len _out_init _a_init =
   hoare [M.a1__sha256 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 1)) /\ (_len \ule (W64.of_int 1))) /\
    ((_off + _len) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op a1__sha512_spec _out _a _off _len _out_init _a_init =
   hoare [M.a1__sha512 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 1)) /\ (_len \ule (W64.of_int 1))) /\
    ((_off + _len) \ule (W64.of_int 1))) /\
   (BArray1.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op a1__sha256_x8_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a1__sha256_x8 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((((((_off \ule (W64.of_int 1)) /\ (_stride \ule (W64.of_int 1))) /\
            (_len \ule (W64.of_int 1))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule (W64.of_int 1))) /\
          (BArray1.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray1.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray1.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray1.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray1.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray1.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray1.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray1.is_init _a_init (W64.to_uint (_off + ((W64.of_int 7) * _stride)))
   (W64.to_uint _len)))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a1__sha512_x4_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a1__sha512_x4 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((_off \ule (W64.of_int 1)) /\ (_stride \ule (W64.of_int 1))) /\
        (_len \ule (W64.of_int 1))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 1))) /\
      (BArray1.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray1.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray1.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray1.is_init _a_init (W64.to_uint (_off + ((W64.of_int 3) * _stride)))
   (W64.to_uint _len)))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a64____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a64____fill64_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 64)) /\ (_n_ \ule (W64.of_int 64))) /\
       ((_dst_ + _n_) \ule (W64.of_int 64))) /\
      (BArray64.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 64))) /\
    ((_off_ + _n_) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray64.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a64____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a64____fill128_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 128)) /\ (_n_ \ule (W64.of_int 128))) /\
       ((_dst_ + _n_) \ule (W64.of_int 128))) /\
      (BArray128.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 64))) /\
    ((_off_ + _n_) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray128.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a64___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a64___sha256_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray32.is_init _h_init 0 32) /\
       (BArray64.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 64))))) /\
      (_off \ule (W64.of_int 64))) /\
     (_len \ule (W64.of_int 64))) /\
    ((_off + _len) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray32.is_init res.`5 0 32) /\
     (BArray64.is_init res.`6 0 (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a64___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a64___sha512_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray64.is_init _h_init 0 64) /\
       (BArray128.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 128))))) /\
      (_off \ule (W64.of_int 64))) /\
     (_len \ule (W64.of_int 64))) /\
    ((_off + _len) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray64.is_init res.`5 0 64) /\
     (BArray128.is_init res.`6 0
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a64___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a64___sha256_x8_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((((((((((BArray256.is_init _h_init 0 256) /\
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
              (_off \ule (W64.of_int 64))) /\
             (_stride \ule (W64.of_int 64))) /\
            (_len \ule (W64.of_int 64))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 64))) /\
          (BArray64.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray64.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray64.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray64.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray64.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray64.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray64.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray64.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))))))))))) /\
   (valid res.`7))].

op a64___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a64___sha512_x4_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((BArray256.is_init _h_init 0 256) /\
              (BArray512.is_init _buf_init 0
              (W64.to_uint (_total \umod (W64.of_int 128))))) /\
             (BArray512.is_init _buf_init 128
             (W64.to_uint (_total \umod (W64.of_int 128))))) /\
            (BArray512.is_init _buf_init 256
            (W64.to_uint (_total \umod (W64.of_int 128))))) /\
           (BArray512.is_init _buf_init 384
           (W64.to_uint (_total \umod (W64.of_int 128))))) /\
          (_off \ule (W64.of_int 64))) /\
         (_stride \ule (W64.of_int 64))) /\
        (_len \ule (W64.of_int 64))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 64))) /\
      (BArray64.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray64.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray64.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray64.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))) /\
   (valid res.`7))].

op a64__sha256_spec _out _a _off _len _out_init _a_init =
   hoare [M.a64__sha256 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 64)) /\ (_len \ule (W64.of_int 64))) /\
    ((_off + _len) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op a64__sha512_spec _out _a _off _len _out_init _a_init =
   hoare [M.a64__sha512 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 64)) /\ (_len \ule (W64.of_int 64))) /\
    ((_off + _len) \ule (W64.of_int 64))) /\
   (BArray64.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op a64__sha256_x8_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a64__sha256_x8 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((((((_off \ule (W64.of_int 64)) /\ (_stride \ule (W64.of_int 64))) /\
            (_len \ule (W64.of_int 64))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 64))) /\
          (BArray64.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray64.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray64.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray64.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray64.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray64.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray64.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray64.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a64__sha512_x4_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a64__sha512_x4 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((_off \ule (W64.of_int 64)) /\ (_stride \ule (W64.of_int 64))) /\
        (_len \ule (W64.of_int 64))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 64))) /\
      (BArray64.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray64.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray64.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray64.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a128____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a128____fill64_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 64)) /\ (_n_ \ule (W64.of_int 64))) /\
       ((_dst_ + _n_) \ule (W64.of_int 64))) /\
      (BArray64.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 128))) /\
    ((_off_ + _n_) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray64.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a128____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a128____fill128_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 128)) /\ (_n_ \ule (W64.of_int 128))) /\
       ((_dst_ + _n_) \ule (W64.of_int 128))) /\
      (BArray128.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 128))) /\
    ((_off_ + _n_) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray128.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a128___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a128___sha256_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray32.is_init _h_init 0 32) /\
       (BArray64.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 64))))) /\
      (_off \ule (W64.of_int 128))) /\
     (_len \ule (W64.of_int 128))) /\
    ((_off + _len) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray32.is_init res.`5 0 32) /\
     (BArray64.is_init res.`6 0 (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a128___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a128___sha512_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray64.is_init _h_init 0 64) /\
       (BArray128.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 128))))) /\
      (_off \ule (W64.of_int 128))) /\
     (_len \ule (W64.of_int 128))) /\
    ((_off + _len) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray64.is_init res.`5 0 64) /\
     (BArray128.is_init res.`6 0
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a128___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a128___sha256_x8_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((((((((((BArray256.is_init _h_init 0 256) /\
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
              (_off \ule (W64.of_int 128))) /\
             (_stride \ule (W64.of_int 128))) /\
            (_len \ule (W64.of_int 128))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 128))) /\
          (BArray128.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray128.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray128.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray128.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray128.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray128.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray128.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray128.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))))))))))) /\
   (valid res.`7))].

op a128___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a128___sha512_x4_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((BArray256.is_init _h_init 0 256) /\
              (BArray512.is_init _buf_init 0
              (W64.to_uint (_total \umod (W64.of_int 128))))) /\
             (BArray512.is_init _buf_init 128
             (W64.to_uint (_total \umod (W64.of_int 128))))) /\
            (BArray512.is_init _buf_init 256
            (W64.to_uint (_total \umod (W64.of_int 128))))) /\
           (BArray512.is_init _buf_init 384
           (W64.to_uint (_total \umod (W64.of_int 128))))) /\
          (_off \ule (W64.of_int 128))) /\
         (_stride \ule (W64.of_int 128))) /\
        (_len \ule (W64.of_int 128))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 128))) /\
      (BArray128.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray128.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray128.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray128.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))) /\
   (valid res.`7))].

op a128__sha256_spec _out _a _off _len _out_init _a_init =
   hoare [M.a128__sha256 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 128)) /\ (_len \ule (W64.of_int 128))) /\
    ((_off + _len) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op a128__sha512_spec _out _a _off _len _out_init _a_init =
   hoare [M.a128__sha512 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 128)) /\ (_len \ule (W64.of_int 128))) /\
    ((_off + _len) \ule (W64.of_int 128))) /\
   (BArray128.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op a128__sha256_x8_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a128__sha256_x8 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((((((_off \ule (W64.of_int 128)) /\
             (_stride \ule (W64.of_int 128))) /\
            (_len \ule (W64.of_int 128))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 128))) /\
          (BArray128.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray128.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray128.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray128.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray128.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray128.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray128.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray128.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a128__sha512_x4_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a128__sha512_x4 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((_off \ule (W64.of_int 128)) /\ (_stride \ule (W64.of_int 128))) /\
        (_len \ule (W64.of_int 128))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 128))) /\
      (BArray128.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray128.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray128.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray128.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a333____fill64_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a333____fill64_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 64)) /\ (_n_ \ule (W64.of_int 64))) /\
       ((_dst_ + _n_) \ule (W64.of_int 64))) /\
      (BArray64.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 333))) /\
    ((_off_ + _n_) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray64.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a333____fill128_array_spec _buf _dst_ _a _off_ _n_ _ms _buf_init _a_init =
   hoare [M.a333____fill128_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_ms = ms) /\
    ((_n_ = n_) /\
    ((_off_ = off_) /\ ((_a = a) /\ ((_dst_ = dst_) /\ (_buf = buf)))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((_dst_ \ule (W64.of_int 128)) /\ (_n_ \ule (W64.of_int 128))) /\
       ((_dst_ + _n_) \ule (W64.of_int 128))) /\
      (BArray128.is_init _buf_init 0 (W64.to_uint _dst_))) /\
     (_off_ \ule (W64.of_int 333))) /\
    ((_off_ + _n_) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off_) (W64.to_uint _n_)))))))))))))) ==>
   ((true /\
    (true /\ (BArray128.is_init res.`3 0 (W64.to_uint (_dst_ + _n_))))) /\
   (valid res.`4))].

op a333___sha256_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a333___sha256_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 64)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray32.is_init _h_init 0 32) /\
       (BArray64.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 64))))) /\
      (_off \ule (W64.of_int 333))) /\
     (_len \ule (W64.of_int 333))) /\
    ((_off + _len) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 64)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray32.is_init res.`5 0 32) /\
     (BArray64.is_init res.`6 0 (W64.to_uint (res.`3 \umod (W64.of_int 64))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a333___sha512_absorb_array_spec _h _buf _total _a _off _len _ms _h_init _buf_init _a_init =
   hoare [M.a333___sha512_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h)))))))))) /\
   (true /\
   (((W64.to_uint (W64.of_int 128)) <> 0) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((BArray64.is_init _h_init 0 64) /\
       (BArray128.is_init _buf_init 0
       (W64.to_uint (_total \umod (W64.of_int 128))))) /\
      (_off \ule (W64.of_int 333))) /\
     (_len \ule (W64.of_int 333))) /\
    ((_off + _len) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))))) ==>
   ((true /\
    (((W64.to_uint (W64.of_int 128)) <> 0) /\
    (true /\
    (true /\
    (true /\
    (((BArray64.is_init res.`5 0 64) /\
     (BArray128.is_init res.`6 0
     (W64.to_uint (res.`3 \umod (W64.of_int 128))))) /\
    (res.`3 = (_total + _len)))))))) /\
   (valid res.`7))].

op a333___sha256_x8_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a333___sha256_x8_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((((((((((BArray256.is_init _h_init 0 256) /\
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
              (_off \ule (W64.of_int 333))) /\
             (_stride \ule (W64.of_int 333))) /\
            (_len \ule (W64.of_int 333))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 333))) /\
          (BArray333.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray333.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray333.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray333.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray333.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray333.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray333.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray333.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))))))))))) /\
   (valid res.`7))].

op a333___sha512_x4_absorb_array_spec _h _buf _total _a _off _stride _len _ms _h_init _buf_init _a_init =
   hoare [M.a333___sha512_x4_absorb_array :
   (((_a_init = a_init) /\
    ((_buf_init = buf_init) /\
    ((_h_init = h_init) /\
    ((_ms = ms) /\
    ((_len = len) /\
    ((_stride = stride) /\
    ((_off = off) /\
    ((_a = a) /\ ((_total = total) /\ ((_buf = buf) /\ (_h = h))))))))))) /\
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
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (((((((((((((BArray256.is_init _h_init 0 256) /\
              (BArray512.is_init _buf_init 0
              (W64.to_uint (_total \umod (W64.of_int 128))))) /\
             (BArray512.is_init _buf_init 128
             (W64.to_uint (_total \umod (W64.of_int 128))))) /\
            (BArray512.is_init _buf_init 256
            (W64.to_uint (_total \umod (W64.of_int 128))))) /\
           (BArray512.is_init _buf_init 384
           (W64.to_uint (_total \umod (W64.of_int 128))))) /\
          (_off \ule (W64.of_int 333))) /\
         (_stride \ule (W64.of_int 333))) /\
        (_len \ule (W64.of_int 333))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 333))) /\
      (BArray333.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray333.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray333.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray333.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))) ==>
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
    (res.`3 = (_total + _len)))))))))))))) /\
   (valid res.`7))].

op a333__sha256_spec _out _a _off _len _out_init _a_init =
   hoare [M.a333__sha256 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 333)) /\ (_len \ule (W64.of_int 333))) /\
    ((_off + _len) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray32.is_init res.`2 0 32) /\ (valid res.`3))].

op a333__sha512_spec _out _a _off _len _out_init _a_init =
   hoare [M.a333__sha512 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\ ((_off = off) /\ ((_a = a) /\ (_out = out)))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((_off \ule (W64.of_int 333)) /\ (_len \ule (W64.of_int 333))) /\
    ((_off + _len) \ule (W64.of_int 333))) /\
   (BArray333.is_init _a_init (W64.to_uint _off) (W64.to_uint _len)))))))))) ==>
   ((BArray64.is_init res.`2 0 64) /\ (valid res.`3))].

op a333__sha256_x8_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a333__sha256_x8 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((((((_off \ule (W64.of_int 333)) /\
             (_stride \ule (W64.of_int 333))) /\
            (_len \ule (W64.of_int 333))) /\
           (((_off + ((W64.of_int 7) * _stride)) + _len) \ule
           (W64.of_int 333))) /\
          (BArray333.is_init _a_init
          (W64.to_uint (_off + ((W64.of_int 0) * _stride)))
          (W64.to_uint _len))) /\
         (BArray333.is_init _a_init
         (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len)
         )) /\
        (BArray333.is_init _a_init
        (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
       (BArray333.is_init _a_init
       (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len))) /\
      (BArray333.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 4) * _stride))) (W64.to_uint _len))) /\
     (BArray333.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 5) * _stride))) (W64.to_uint _len))) /\
    (BArray333.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 6) * _stride))) (W64.to_uint _len))) /\
   (BArray333.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 7) * _stride))) (W64.to_uint _len)))))))))))))))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].

op a333__sha512_x4_spec _out _a _off _stride _len _out_init _a_init =
   hoare [M.a333__sha512_x4 :
   (((_a_init = a_init) /\
    ((_out_init = out_init) /\
    ((_len = len) /\
    ((_stride = stride) /\ ((_off = off) /\ ((_a = a) /\ (_out = out))))))) /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   (true /\
   ((((((((_off \ule (W64.of_int 333)) /\ (_stride \ule (W64.of_int 333))) /\
        (_len \ule (W64.of_int 333))) /\
       (((_off + ((W64.of_int 3) * _stride)) + _len) \ule (W64.of_int 333))) /\
      (BArray333.is_init _a_init
      (W64.to_uint (_off + ((W64.of_int 0) * _stride))) (W64.to_uint _len))) /\
     (BArray333.is_init _a_init
     (W64.to_uint (_off + ((W64.of_int 1) * _stride))) (W64.to_uint _len))) /\
    (BArray333.is_init _a_init
    (W64.to_uint (_off + ((W64.of_int 2) * _stride))) (W64.to_uint _len))) /\
   (BArray333.is_init _a_init
   (W64.to_uint (_off + ((W64.of_int 3) * _stride))) (W64.to_uint _len)))))))))))))))))))))) ==>
   ((BArray256.is_init res.`2 0 256) /\ (valid res.`3))].
