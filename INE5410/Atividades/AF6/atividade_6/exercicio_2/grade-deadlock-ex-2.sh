#!/bin/bash
# Usage: grade dir_or_archive [output]

# Ensure realpath 
realpath . &>/dev/null
HAD_REALPATH=$(test "$?" -eq 127 && echo no || echo yes)
if [ "$HAD_REALPATH" = "no" ]; then
  cat > /tmp/realpath-grade.c <<EOF
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
  char* path = argv[1];
  char result[8192];
  memset(result, 0, 8192);

  if (argc == 1) {
      printf("Usage: %s path\n", argv[0]);
      return 2;
  }
  
  if (realpath(path, result)) {
    printf("%s\n", result);
    return 0;
  } else {
    printf("%s\n", argv[1]);
    return 1;
  }
}
EOF
  cc -o /tmp/realpath-grade /tmp/realpath-grade.c
  function realpath () {
    /tmp/realpath-grade $@
  }
fi

INFILE=$1
if [ -z "$INFILE" ]; then
  CWD_KBS=$(du -d 0 . | cut -f 1)
  if [ -n "$CWD_KBS" -a "$CWD_KBS" -gt 20000 ]; then
    echo "Chamado sem argumentos."\
         "Supus que \".\" deve ser avaliado, mas esse diretório é muito grande!"\
         "Se realmente deseja avaliar \".\", execute $0 ."
    exit 1
  fi
fi
test -z "$INFILE" && INFILE="."
INFILE=$(realpath "$INFILE")
# grades.csv is optional
OUTPUT=""
test -z "$2" || OUTPUT=$(realpath "$2")
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Absolute path to this script
THEPACK="${DIR}/$(basename "${BASH_SOURCE[0]}")"
STARTDIR=$(pwd)

# Split basename and extension
BASE=$(basename "$INFILE")
EXT=""
if [ ! -d "$INFILE" ]; then
  BASE=$(echo $(basename "$INFILE") | sed -E 's/^(.*)(\.(c|zip|(tar\.)?(gz|bz2|xz)))$/\1/g')
  EXT=$(echo  $(basename "$INFILE") | sed -E 's/^(.*)(\.(c|zip|(tar\.)?(gz|bz2|xz)))$/\2/g')
fi

# Setup working dir
rm -fr "/tmp/$BASE-test" || true
mkdir "/tmp/$BASE-test" || ( echo "Could not mkdir /tmp/$BASE-test"; exit 1 )
UNPACK_ROOT="/tmp/$BASE-test"
cd "$UNPACK_ROOT"

function cleanup () {
  test -n "$1" && echo "$1"
  cd "$STARTDIR"
  rm -fr "/tmp/$BASE-test"
  test "$HAD_REALPATH" = "yes" || rm /tmp/realpath-grade* &>/dev/null
  return 1 # helps with precedence
}

# Avoid messing up with the running user's home directory
# Not entirely safe, running as another user is recommended
export HOME=.

# Check if file is a tar archive
ISTAR=no
if [ ! -d "$INFILE" ]; then
  ISTAR=$( (tar tf "$INFILE" &> /dev/null && echo yes) || echo no )
fi

# Unpack the submission (or copy the dir)
if [ -d "$INFILE" ]; then
  cp -r "$INFILE" . || cleanup || exit 1 
elif [ "$EXT" = ".c" ]; then
  echo "Corrigindo um único arquivo .c. O recomendado é corrigir uma pasta ou  arquivo .tar.{gz,bz2,xz}, zip, como enviado ao moodle"
  mkdir c-files || cleanup || exit 1
  cp "$INFILE" c-files/ ||  cleanup || exit 1
elif [ "$EXT" = ".zip" ]; then
  unzip "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".tar.gz" ]; then
  tar zxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".tar.bz2" ]; then
  tar jxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".tar.xz" ]; then
  tar Jxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".gz" -a "$ISTAR" = "yes" ]; then
  tar zxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".gz" -a "$ISTAR" = "no" ]; then
  gzip -cdk "$INFILE" > "$BASE" || cleanup || exit 1
elif [ "$EXT" = ".bz2" -a "$ISTAR" = "yes"  ]; then
  tar jxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".bz2" -a "$ISTAR" = "no" ]; then
  bzip2 -cdk "$INFILE" > "$BASE" || cleanup || exit 1
elif [ "$EXT" = ".xz" -a "$ISTAR" = "yes"  ]; then
  tar Jxf "$INFILE" || cleanup || exit 1
elif [ "$EXT" = ".xz" -a "$ISTAR" = "no" ]; then
  xz -cdk "$INFILE" > "$BASE" || cleanup || exit 1
else
  echo "Unknown extension $EXT"; cleanup; exit 1
fi

# There must be exactly one top-level dir inside the submission
# As a fallback, if there is no directory, will work directly on 
# tmp/$BASE-test, but in this case there must be files! 
function get-legit-dirs  {
  find . -mindepth 1 -maxdepth 1 -type d | grep -vE '^\./__MACOS' | grep -vE '^\./\.'
}
NDIRS=$(get-legit-dirs | wc -l)
test "$NDIRS" -lt 2 || \
  cleanup "Malformed archive! Expected exactly one directory, found $NDIRS" || exit 1
test  "$NDIRS" -eq  1 -o  "$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)" -gt 0  || \
  cleanup "Empty archive!" || exit 1
if [ "$NDIRS" -eq 1 ]; then #only cd if there is a dir
  cd "$(get-legit-dirs)"
fi

# Unpack the testbench
tail -n +$(($(grep -ahn  '^__TESTBENCH_MARKER__' "$THEPACK" | cut -f1 -d:) +1)) "$THEPACK" | tar zx
cd testbench || cleanup || exit 1

# Deploy additional binaries so that validate.sh can use them
test "$HAD_REALPATH" = "yes" || cp /tmp/realpath-grade "tools/realpath"
cc -std=c11 tools/wrap-function.c -o tools/wrap-function \
  || echo "Compilation of wrap-function.c failed. If you are on a Mac, brace for impact"
export PATH="$PATH:$(realpath "tools")"

# Run validate
(./validate.sh 2>&1 | tee validate.log) || cleanup || exit 1

# Write output file
if [ -n "$OUTPUT" ]; then
  #write grade
  echo "@@@###grade:" > result
  cat grade >> result || cleanup || exit 1
  #write feedback, falling back to validate.log
  echo "@@@###feedback:" >> result
  (test -f feedback && cat feedback >> result) || \
    (test -f validate.log && cat validate.log >> result) || \
    cleanup "No feedback file!" || exit 1
  #Copy result to output
  test ! -d "$OUTPUT" || cleanup "$OUTPUT is a directory!" || exit 1
  rm -f "$OUTPUT"
  cp result "$OUTPUT"
fi

if ( ! grep -E -- '-[0-9]+' grade &> /dev/null ); then
   echo -e "Grade for $BASE$EXT: $(cat grade)"
fi

cleanup || true

exit 0

__TESTBENCH_MARKER__
?      ?<?v?8?y?W ?㐲d??Kb??????O;v6V&}????dq"?I?Nw?c???<?'??m.$??䤝?άq|L?*
?B(0?Q|A??x??WKH[?lnm4ԧL?????fs}??????l??6????R?fQ섄<r&?ƍ??????8????'?Wт????F????I???u????Į??Ss???z??7??????T??????'??.\o?ƕ?o????엇G??R?????i?Ӭ?????	%?G?~?!C?B?;"gd???:?H?|??c?A?(}L?#??R?`???O??HZ??????7|lH?7&M?2r??E??)??8114B?%?Ť?6YJp?%l?h?{~?ID?;A??je?u??s?;?W?R?q?%???Z?hg??F??0??Ez?z??lH?wQ<t???nE?
]?2?7??z^H/?fU\/&??=???)??q???F0??d0v?* Y;??:C???N<F?g?Pi?CU	g1C??O?
ס??:tԘ? C?:?g?'?$?˕E~?V??B??C?2S L?#?x9?t?<?Hbw???g????9?&?B?B?4y?m???0$?????F?,??񻣣???A??W?fX}???3p???I?'?~?H??xJ???夘4j$r??Hv?e?@?Z1(?][#	{?e??¸	?0?U???7m??m????o?pPF??-@?o?l?`
Lg??????ބz&c?"+???k??J??$??Z?@	4???A???0??????F??w?????PS?&?_F?=??~鷭l?S?I5??$
??U;DV??=^Х?rM+?V??
GX?HiED(????cr^5Ϝ??{??l?_???*?,?????׊?????g???j???xR??g?l??	X??ۉ?Yk?Ln??ipY??	g???K???`BowS?Lo?|y???9?ˎ?^???V?M_??z??t??z4?w:(???N??.??>y?????????0v[?
C?CpzU??is??̹MYa?ґ??̡0???}??????j?2????g??4?ڝ???*?_?lRQj??RS?\Q??<????D?ڄ<kB?̠	*?|5R??{!z????Z??C?TxO? V Z??pT"	??#??w?M??4?6?s???1K????ye??H?d??M??????????݃?????????*???CO?S R~?k??67????lHSn:??JSsgs???P?/w^?=p?????3??????T?L?W?ݸ9P%#?"#?`??Fh?N?(?`?槞v??? EQ?̃Sf?2#??N&?KqO?=?5?V?hXd}9?D?ػxy5???I?k?-KC?V??V?tRs??sA???i#?`9|?????Z ?kCi%?m?Hh?:???l2d?CHIj?X,???/??A??????#? ??Q??ǸgbM-?f?G??,+]????!?>:?C???I5?րi?7(??vA??%;R?%?}?? b&??Rۋf?ٛ:?`??&P??+?9]݉??$?(8???;|?Ӂ???&??5Q"??;deEe_ՙ?5??ğa??ܐ?ŧ?0?????C!?Q???#?Ap?|?T?뚘&???Xf??@?O?G5d*????-??p?o?fI?:y?x???K?]?)?!??j8??X???׉ܲ??PĜv????x?E????qXd?d?????u?Ǘ????-???F??L??v??򮫚??ʊ?]w??]??@)??6&]????1?B??3(Ox,ք?d??Zvl?3 ?(???w???+?@??$?_"%=<?&>D???W?/hz???گ??????3??kǍ﯎??V??wc??z???I=?{sx??~ݣ?^g?U??yw??,??????Ugi????=?qo????FՇ?=b,?\???;I@ֆ?j͛M&??čb{H???)<?+br?	?ߙ?-v'Ðz?%???Ow?!?z O??i???????O"$?|?J `?lO??q??|???'?i?)?ja;??E툾????7$?B??r?iD??%֙?\4?P?%??????+(?M??^???? ????JNw?<??Q???????	?Fo???JDfS??????j??xe???fX^?t"?;1.Y?q?6(?HdNI?Q?]?????V:?60???`q?.TXQ
?A?x"jyk?^?????T???FrjR??B"???????????b:\>???r~?r+#??
?h?{N??B?x?ͯOixI???c?????????????o????????A?>y?c??????V??bz،??J@?0	n?????5X|??{??J??̈???3?0???X?;??KΥ??!Y?ͷ??$f?\???????????s???9?wa怿Jr?I?:?5c\?????c???KXe?zws????<y?d??m@Z8?????4I}??c???jZ????????? ??VE??\Y2M	?Ҵ,YI????o?W?1?{ `5ZpעJ%%,f?u	Ŷܒ ??t????S?;?9??@??O{??????N#????-??p?OkCn1?4?V??2??3?o??<`y???	=ƒkX2 N-NFB???k.?dC??J ??|y S????eޒuT??M2????*??gB~?{??o<]m??F???n??e0?????Q-F?wRA?!n~???,?@???̒???^m?	??O???z?<?????????3? ????<?"????3q?N???$ou|/ȕ????V.?w????M?w?????????z'o?^???c?x?'?'ۮ<ag?t??????l`!.Y? ;?H4ώ/l<?6??$???N?ʇ??˧8??????Nj?FSX?]???9?g0??<j??M?*Ԝ?ࣰӈ?B?^????l??1,?:V??5;6A???}3/r/=0n)?R?03?A?Q??|hb	?D#@?ޏv,*??2??_{`?3?????I???q??,??5??-v??M?eo?-?$\?M68????6??9??ol??l???kj??B?ڑ3&T???J???4???j??؅W????<??ٰ??U??2??i??NU?y???f5p??????Uk?`j??J6tة????Ι_?G?2??ȕ?p?Y?/??qX???????~?i???M??a??[?o4???Hs?i'?aٝ ?^?:Tg???<?????3???542Z?Q????p?&5?'?x}?ʷ/5w%??? 	kE
?(p????????y洣Xu?'d?=,?8<>???_??RsY?VeE50?!اo?????(?Ρ?;?)?ۣ?R?'?|:#? c??S??=?E܍??ʜ?2a???y?d??];?b?i̼yTҹ?@?`V?ğ??'\'~̯??6?pvR??vԈ)?'??M?@??????y?N?V?# G׊aj??u'??di2Tǜ ????0o?z?@?n??8_?h+??ICy%y:\???j4o!?ʉ9??f?3ꬄY?$?I?7?d(?aMc8z}?N${?.?J?G????¹s;/?s#K?E?ݝ?61??,CH??7?F?#??d`cŋQ???@MьTd,??Q?,u?'?d?bk?+???-??̋??z??<?6? ?@?	?0?E?dȥqr?A?"G?0?=i?m?V?EK?dE+ڜ;-Ұ??"??BH??CX???Et?16?fb?~$?+W̪!B?X
?J?>?}?Ţ?e(NR[K?ZD?A??C??iIja!???L?ԛ?<`???a?&??JS?f?	1??H*?"B?	???|???z9?#??qIE?-ZY)??y?t??Ԭ???x??9?6P	??1y????L?ʍ?v>?ܾg?????`?`?'??y2U??n?????/h??ݕ `*??N?G?rj$!???<':y?	?U??[p0A?G>6҇??:??%cR??pVBK	EF[Ͳ??N?)DWh
?????r?ʠ?\?w???$??????A?-?N?Y?v??:Qev??????@֚06?)??Ӫ?2???u?k???ԗ?H??%r+???˅?p?S?#=Ms??y?s??ua????/i?0?>??^???N??k?P???k4?bg???n??.?cǳ?u?-&??@?_???_??%d<?????T????;$???R`X\???SUk??+c>)b?CI????RdL???Q??*l??+?[!&纞?K??????{т??+? ,?T???????gt?????#|????݋?!???<??>?i???U????%n?w@?9 	$Zg???̾G???^??)???"??
?/??E?`*vC?{1c?(???z?ύ??N<?????EMA⫙,Cy?os9B?????@!U<??;?/W?' X?%???}?????2??a???????ɗ?O?????Y|??h~?#2q???芘??rt??R???Ԭ4K$(D??ր&???	???F?;?1?&??c???!??e?h?6??u??F??UN??,>????s6???????i?V?m??V[??Zmn???????j<???խ???h4??z?????? ???h@{?E????-|l=?b??^?|?????d?[/?c?u[p??L?ѯ????r?֚(?m?KN??V?:%?{?.?nr?^??????\???\]????r??<x|??W????i<???=?B???F=ޙxĮ???????:?۴???Gl?p?5?ޔFD??߿̫*b?W??H/?`f? ??=j?kW?E?Tٓ?$ b?@^?????m????????ۻ?*?K???u?J:pj?uۊ?????A?:xQ"?`Rve,?Q???LSt??h?_?z.????-??r?מЬ??զ?N????DԪ??/?2??GB????6L???!?Q?5?????a|??bW???v?(???,?^n?-?h??*??y?nH.?V<J`C	?Lu?`?(y耚?]4?5?m/??c*:?O<硫???????ڛ???$??%??e?@??8]??);:N?%??)?h??
{?G??;??uv.h?>wP?9:?;!???~?}M????Ӡb??#t~???C???3`7?3?!?87th???)E?^3vJS_w???????)??i/??e??F|'	3? ??2??n!p!?
??K??Z;?X?H0??7l??G"????;R	?!?٠7w?C??U]?%??]??????iQ@?*T:ܕ??8??p?q??K2㠑?u?Dl)T@? a??)2C???E?????<???E$0	????0?4??q'CBv*r???¥I?z3?H,?9??vH??d8?p??Q?r?٦֛?$G?}o?X??????? fð(?U?n?;??????^??S??????????????OO??? v?O"7????/k????q?؜:?{;??qS~????
1???kg`U???~?{`??nw?̓S???я?d/???7??#??????^????f?t?Y6*?t ????U???????&?{??]? ?0?%?j
B# ?????凟?\v=-?S?????? ?p??H7y<??n?Xa
??`L?ڒ??j?:~ݶ??Z^??߁???J??g?Zs???Y??@C???0??????)t6?k?o?ځ^?^3G۝b!????/O;????k?r??{???9?ߜ??b?ۧ'???w;?F?y??QqQ??~?M?????N???=-????jmd?ss????T?????mw??t????h{??C?̘??q6<D1Tq??Y?:sמ̼???Kҋ?9JC???J?09?jhT?z?⭩?^:?l??<?? ?m4???j???6Ltx?>??c????kU'????o{߶?ƍ,?l~D_BҼ???l)r?H??stI?d??p?Ȗ?1???&eǱ?e?????^3k?Ӭ?r^?c?? th􅲢L??????B?P(TU???i?Fi??
?H?O???~gޅ;?k?\k?s????s?????u?i???]?w???)6<???????????9% T>L?}???H7?????p1ǴP?*??`?k???包"Q?C?/????,U"Wv'?!?\uKW?'???j????E??=?{+"?Rt??)?@?x?1#e?r???W??E5C?j0x???|????8H?,??N?@e???\`$?"G?5???5N??JU??????,ļ??f??????O??????e???[?[?bU?k4>????f?(<NH?Sq;0?`qհ???????_?oq,a??G?0'?sD??	[R?J???O???h??y?J?<Ņ(?a?P
R?j??c(??Y???J????[?D??????OK?RQ	?D?놑?U?? @?W?/I?A"???|8:??&m]?9???%?v?TEl2???k??HQ?d??5+?{??eO???X?'?	bMN'~R]?d?7?σYfM?];????b0?{7Đ3???:?G?Y?0????N??>????Q?>?6Fc-?H?vgq???I-˛?-??ÒϠwp??J~"???-c?$?w?d?????L??rWI???N~qm?0܍?4?v?,?d~E???RjPg4&??$$??xgk???Ͽ|????????+?v>??C??jg??|?S??E??X&*??S?S)Z?s???䄡{?????yW֪y?[	?Gc?	es??i\3^X=j????5f?4Y?????վ7Yo?Pj?D)K??ꟓ?`L~?#W?'+`?J?q1N?b2?Hd#??#??Lq/?W&n?ӷ?c3=??_??_?pf???_i?b?r'?&~]>C??Q?d?3x?;Ic?$?U?*???8HiJ???=?uKP??dWy??3=?yf٨??Yҍ?d?#?????????r??!E?K?)ꕒ??f֚?E?T??J?W??0)??B]?x??s??"????_???l^?W??~?Zq?sýY?'???<??e՜ ?yԄt??K?s?t????<?73?r???????lW?J???B??ҒQ????45MSa??SaQ?~shI??????U??Ծ?1???bvO?Սɲ}Z??PAJ!???? ????)??[??^We?X??1??,???4wC???m??XIwh[?Y?c?q%?⎷L9??He'??\?}=E?P?D???ﵼ)?:??\??3?3??,?v????v????>^?/?D?^\D?6ZƵ???|4??ڍ1ht-?!-۪?[????]?򁥥|n}?xMS???ZO*3?H??Ν?og?D?;??f?$??;q???{???????b_?\Y?f;?h?5? F?l??&S )???]j?F?2?h?$G????,?????1?????aE?|?.C???????-???B?O?ς???6???^5???Ç???\??0?w|?v??????[????????(???Ŕ??W?"9ő????<+?????.????d?c??կ??i~??Q?i?t_?tA?X?K)??=M
??c]s??g??M=?ʹ?.?u???^???鋶i?8??KB?NZ娮d,?	K?q ????9?jB?????ˀ??u??Qw?\?Y?29r?r#??@?v?H
?}Z\??N?j??T??&??>n&??y<m??[?4a?؊5^??֘8?͊/T??X?r?\<????+?֙ёr?뽎????????c???'t*MK?@?96?͙??B[O??o??e?V[N?[?
rY?x?bUӧ?
`??ΡA????]W??lA?v?js?L?>?Z?'Ɖ5?b?|??|ux??羞S????F6??lw???wb?????y4??nh?ɣ?????*?D?Pu?$-ճF-??????7????
??????
?[??.??H?T`l5?e?6??N?\?2?G?Uh?L5o??J?s?????t?1ڄ.E????Q?*?P?{9r*?	&?Ӫ???6?~ݻMI?/s?????#??R>$?7??d? ?f?A?X?A????'W?M?(Ou4?-??e?˥??шti??8?.G???????????eq$?l?X?1+??Zfy???P??T?	(m5J2???m?AeR?#?4?rR?????????J?%?l>?Ŏ?,jeE?Ƥ?~?^??	?	??.*??s6w?&þ7egc"\V2?????Ŷ̲?U???R?Uj?? ᄿ(a?DY?c2`T2?J?Ru??؋?`?ǔx?H?`??YPY??#?i?=?????BȦU?)L?=|#k?????Z??v2???B:???*?	???}?t??	?vGo?n?G	????U?@Qm??-7??E??ђ?1r??????͸???f
??L}??9????8?Ȓ=9Ç?A?Îp?8?`??????U???RmC??u?KL?&'A??bIye?1????[X*3s?d???*??"RRA_??u?^[??3?1??
Enf???͏$DL?K?z?U???w/?W?x?ъ?x??]?g?n?Ξ?$Ê??fP?2?4????iV????x?[??,1?σ??m?!
V?܂C߀??΃?x`????zL2l??zl?????B?=?v?!9??2?E<h?j?	??u[x-lQ?}??DC?Jg????+???w?-%?-de.{?G?E"?*,?TVMX]?#????6??=)??JS3?y??A?K[<??e?^U?,???j<?a\$?h?7U4??5??Vu?Q??T?:?{??}?W׏?L?np??0ڶx?]O???>t]?????????A>O????ߺ
)V?0~m????増398J??P??XJ?????JA䴲JWN???Qz???dxtc??4?E:?O?Y?i?V??£?O?X^?"]??E??c;5?r?'7\???p?2̨?u"$@??˗Џߔo-D??-?}???^???%"}My_(K????z.b۵&PZ?|+?Z?????Գ?_?cd??j.?,?I?u??l^|?qM|
?⚔?j?-&?q́???37S??ǹ??zu?!>????q"????܉E<zϞ??ەs????|??x?????[?i?@;`??-?n|?Ҡ*uU?7?R3OcaR?^?(׵d?f??r?%o???2`?S
??|??M]sdn6W) A??rz???y?[&bdaMQ??0g? ??*????8????u?ļ??3w"6?Y??g*w?G
?uuV?
[;???,P̿??i&???ƅ?[?0A??X?0S??T)??K1??E\?96>????c"??]Sx?|???S???pK"?????\̡?3?^????I?????B??	??/ z?Rm?6O?D?;2?2?
ݓ?????TJ^ܖ|)?j`?Ԓ>?,/?K?l&?*?l??L?W??Ͳ??]x&-?ќ???
_-`?<J|*<??$͘?K@?????O ??#p?????d8N???V"????&`~Jܦ'\???xS>
???ʂ???B??F-?\G??	??#UGn*պ??*(?????`?????2?J?^?c?ֺ?=??7????;?K;~Xhb?"??J?_??X?u[?@3?P0?~???Dl?2$M??LM]????%}??'??l??eiw&?G??c?#A??
??J???@V??Ƅ?vF?/?2?????6?ѿL$?????G????Dn?7?J???EdGk?>`|?L^?<???W?𐚢???@U???u,/Ko?Q>?d:???0N???Z?MG=??%?]l49Z?=?Β??%'???ߎ??????jޏ2?iP?x?????(#3E?!?_:C?f?p2?12]?K????)?R?a??(?ەLJ?ŜGt[?????$gj?3?3??,?JPsS|Z?ò?zc?&ܱQK??/??`?????????x???:?t????,.ɭ		c??L>e?2?	???s?V?1E?[???????M0???B,????$* >4?o#8-ǎ?????G??????.??K_?h?w?t?B?5?????g9?nr?????rY?fx???6?^?=?`ꄡ??p??Z???L??<+?X??????o|?;|???-??	~!?c????Xf?оI???? ???@B????8G8??hK?bWv{N??X?89????p9?>|??\/D??wW??ǰZCY'???k	d????l?????~쳣}~L̃;AM??G?(???b!ĦAX.????(A	?v?6ü%?;a*rwΦap??D?N\??qQ3???2}M??z?iȆW?yg???
?!?S?sډj?v?|?%'"A?aI????5??`?e1m.&1?V???????E*?o,MQ?????}??xc?v|?|??X?8??kE?̷6P??9??X????z[??oq'?b?Q?,?b??<???Y??ǜ????f_&?e?2??)۩??}?s??T>??6V?mgEm's??J3? ??c?n/????:?UяU????˼h???}?????;?n???????????}????6??????????????}c?$???{?x????j/_XR@Mo.(?Sf&?Z??8L?u5?JK??X?Lԗ?5[?5?A?J#??U&?a o???w??&??`???H???+(??{ ?)m???ܷ???u??02????-?b?'?C?K?<?-#?'r|???ϯ4??ܒ?B?*????p-P?ʒ,?7?꘳ׂC??????K?2 ??>Z?/!??Z?YWƪsx?Kc???)????? \?????'???????[)?W????]???h????Q*U??x9c??Z[|???L??wv>3??ۇ?Κx%{? \2$g?D??Z?ՙ???')?'_?'???ơ]??.??I??q2&?]Ҷ?W?U	?v??紞?F??Ϩ?f??V?M֭g9{?::???ПAo?OP??????u3?????#H)??]c?xu??5????mx?z??ouM.Eo???3???5??S7&??ΑIAڏ?0E?4??#%?ѩct?5@+0F??U?????p?1@M?E???&?(?c!?"??4?b\??a?<9??b?7?c%????G?[c?O???b?qc?O?'?ܰB??7D?殼?5?Ht???5d???H?u?3Ertg??
"???!I????8????????4??b`aEمL???$š&j?͟ӿ??^?$?_$sC?ЮOR
???g???????R??????l??a????;?f???wlv'[B??b=r??;	5??????5???7{?????s?
G1l?72Y{???U??ҵ???:?W?ZU??c??????n???zI??Y???1???=??????7?c??K??L?鰑?׹Ǧ???Xsǡ???_i?U??9?Ƶ
G?a_?F{W?}?_?kD???
?????(r"?T?8?_7j??4~F]i( F,r<???l?z?胉3??y???1w????3o?(?_?(#O?#*U?y?Y
N?_?????RծwcYL?]e?????R?@?&B??????Y?_???^==?:)X??f?ݪd??@?0?f?1?~?ኧ|???u?`İ??B??@?UЋ?N??x	?`>??"]?.]-?
?r??~??<??{?M?D??D????ܛ??`????٣???ߓg????me?O???fW?*?z??6 .?C/?i??E?C??????@??????a8??V%Ũ?[?B?
?w,???\???P??????>SO.??8??	US??]ҹ??Ȭz??s??n??9?`bH???П??Y)?????&vse?p??֪S?{_z+?????y:????????O??Q?]8?$O???q?U;?ǣ??i?)Mo??x??0?;Y?qx?z?ݤ?w???????a?w?d?gϞ???3?G	??&?|	L??r???M~???,??:ޑ??????k?v?!??????0`(??G??2????k?*u?vZ??/4b?_`????i#?J?????،i??[8IF??47I?#?P?:???˛/Ĉ??????)?K?.}??0?Tn?[??ԥ?.0??4js~????T??G_?0?߼??iRͲ?Yf*P~B?n?h?6IT?a2H?RW=?G^4???R??gA?P	?wqI??5?n????ag??f&?~??>?Кms+껀???%?a?EX??y??;NП7Z?
??ԏ??ŭ?'??*?X4?0?)?$?u2v볨?|vTv????.{h??49as?\?;???\?/?6<`5?j#È??ij?v???a???t????	3??g????|c??/????@??)??? ??IC1Xl;d-??ϠM?h03??E?%<?%y?s???|??@??R????M?!???ΐ?q4?y?@??b??v??.???(????md?o?x?M??ǏV????Rp??x??rS????B`??????={????????????l;?8}/b???s??s?ER?????|?U!FW}}??? U?w3?&?O>?yJǯ??#&?3g??_]??????C??;?ٰ?0??z??:?N6X??~? ????ZT#:??????-?????cZ?\m?+7d????]???q??s-d?:ğ?.????'???@~??Q???H?5͡T????	????,!?hnS??С??G?%????Qg?I}?z?Zm???`???]??q??????^??{?۽?z?I?+?[?<<??2?͑?
Y?O򠍝????ʧ??2??y|O??L]?hJ??]?ȋ*g?"k*?g?3????u?s?n:?7?M?????`>??@~???ܚń?
e???>̊n?k]BPu?@:?U<??l?豺?ə??z=??O ??ug???^??f̴?]\8?[?????)T?v???lB??/?*[?-??F??'Y-?[??j????-??????4?LtǵY	???????a??n]a?Ip?ȽpC?a3??aI??Zf?ܳ??
"An?c^????MW?&?9?L?ɵ??*L??M0?p)N?F????W?#?=j?=??k???G0?E.s???4?SzQS_?$??9v>M???vH㝶?[?ܧ?????_Ϟ<???V?O??_?/??[)wW:'??9q????m?????%Y??]??????}?	???s?8??:L??(hM?7.????????????9??????????e??Ľ???)?wàB?v?&?????o?(}4??????Л8????B??h?v???P?ώǦTA?L{U?#|?۞zc??
H?ܰ???d??C $g?.?:??R??ߐ????؍9[?U?F?n????x?H??e???KDI??/+??$ۃ????ƽ?%?K?\vްn?H?.{ҵ?S??q?v??Gd??wS?? /gN???ͮ?r?%a?sw<pS6?Z???V???????e?׭?\?kDX~|??/m?gX?ɭĻ?;;??{L??T*V???.??8s?nq??&?o??w?h????FNy(*}?S_?`????o?z???om???ӫ>??Y??O?????>@??Њ??Z[??#?7??<?/ ?NA?+D??? ????,??????d܀?x6f????9u%?3 ???qVv,b????G?x? ?@????#?????h???5e?#????O"g??68(?M A?????8}??6ӉQ?4S#?4?Wr"?Jȯ?\??U????p?????a??F 8to??K???%??<?p?,mJF??w;_??1I9?d???+???3@e?????dW?Ѿ?<7#m?8???C?0???0??l4%??6??+ѳ;b ݑN???h?[?@/???n??D?????z{?hMB?_?K~??Q.??gN<EABz?nBb??1b?5?????ܢl?@HN??mb?z?>?2?????_+??2ڤk?U(?ؓ?6?V?t??nW???"???)h?t4?W'iD?^?/z?????S?a?????H?XN?dum"????.??@???{k:?b+??/??ߠ??u???????????VJ?+΋??F?'?a?zT?M?V??!?d?Cے?V?	?7?|H??C??9<**W?_??gL?J???f??)>??H뗹R??yfD??#????-(ϙ?ʽ??????HyJ]?9)2m??@;g??????1??? b????s??/p?&???!??>F????a??ړ6;r'?@`?y???N\????>??H?NëM?o^?;K?????,II???-??6???j?٣??W??r??V?拝?ˣ?!?Z[??????????W??????W??vX댵???nk?]?E??+?ݫ?՛ߢa?6??+w8<4?Y?4r?F???h?!???9???UH?TvtD*?qAeg?kx9???V???^?h7???+l:?????? L@????u?x?v?rAꎠHd bV8o?wr?!p.I`??cX\FN?͂Q?P???q??4Dr?Al?;"19Y?mDץ?:??C?S0;?@u_nn?;???]??B?)=8q?دEt?:<?a?[J(b?Q+a??M?ȼ?:?=?ͦk??Ӟ8?V4? M ???Yg??X?]??????gAKP???:s}7t???Cr Fo?vZ??[????;?{?Q?^?}<?C6t|W?c?1??????{???O?,?p6<ڸW{??N8b???^??????ϡc??SX?Z?\I;?x?5?H?Y??%???\?????????;p???F&????????<???	???t?F???a??-8?dGő[?kM֠#Sg?O??X?6???_?P?,d?????M??;Q?Gs)x?t?G0??*?j?c6yx?֔ݫ?Xnm?yO?????Z????2	???ʰA??V?z?? ?????f????a?>??Н????g?????V????-?}u~|?c??F???L{\m7??l??y??W?v??D????֟????ﷇ????W{????{GI??ΌIo????쿶Q9#?&?&??A(?z???K????!?4p??_???pt???3???!k?Gc̹?Ĺ?,;?o???
.s?6b??=z?`z?U?r·?_??e???
???n?f??k??V:GӐϖ|%?#8]|??e??????XrU ???k?QI?M??x2??B"???qG??gb??G?N*?????"??qϫ?e?n???{(K/???Y郎ɛ??Խ????h ?&?37?n?E?ċ?g`L <]J1??F??;???'"Kfϡ???@?D??ෘ??J???????a3j+?c????"?4?&tI?3?Al??5h??A????????|#?rx??4f5!l?7	??s???.t?!??q?+ ??P????X2 ?g@???4??@?J??iNo???'r?h?p?/?t?q-?2??W?e=t??Z-FY? ?c?F???+C?v??? ?????	????0?F	H?@a?Ae???'ؐ@??=?]?1?_?o B?-'??g*??c??N????z?v?qf??Q?J?Qf??{VU?Tه?I??????v?????i?????AC1+?J??1|&?*wr`Ly?
?????%]X?XƗ???d?>e?W??IC?o?$?W6???l@]?:?w-??t?>Ӛ+??8)[ߒ",???pu???+??-??i???ʝ??X???SJ?Y0y{?+??GW?BA2??J?&8qc?Ck??L??տ0\3?a??k/D??}?!?? ?e??<??????ڇ8?4%?]??΁????;Idz?AK??U?ށ??^0???c???^?&Yl?1?;g?a1?0ce#@??Q_??+ylG?0MG???G?f4???K"F?!-??A"Zi:U??l?r?+?N???kC??]x,,<\xk?gxK???n?{?B?g!>???Ut?G$??6[E???&kC??_???eu?i?ۍ.??IH?;??D??v???a'?O?aT??N??B??k4??Gw]M?Pgs?`5??eN]x??`?M?~?yC޴X?*??k?X0????0(?g???j|3?g~?I??x֎??:?ŮXFIe ????tB??Ǜ?H??;??n???i????֒u?UJ?s?1Xߍ4?n???Fi?jh??x]?cb2?]??ю?i?
7u?RP??UH?6UU?X?E?ĉ\??CM??{SiY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eY?eYn???j h 