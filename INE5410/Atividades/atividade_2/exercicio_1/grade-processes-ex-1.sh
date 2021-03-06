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
?      ??r?F?????? ER<$k-???v\Qd?-oR+*,?(? ???cf?)_???9??vd'??y0?AO?????$?d?3ܺ??F????6ww??w???v???m?k?i4[?????r,?c??vp?ص?,?[???t????(
?/??nzX??k?i?_????MB'?????]f?m?y??????w?q;?o???__ۺ?íK;?=?<=~q?????)5??O??8?4/???~????F???9?8?دЀ?}H?,?w???<(?X0 ?F`>&?E?0J??&??f*?k??&?|?C\????Hpf9v
f?Y???(?6???f????(d?Ɵ?
??_????q???;?B??8????٢?>??wwV??k?u?t?????$u??><0????sn?_?b6`?4e?a
?u߉Fc?S?O+?&i?()8C;? Pyߐ2????t????#d??v4l1?
?
?p?S??*?S6?Fqiʮi_4??Т??x?d??uު(g?KX?@[M?#S?g?/{??????CL?B???7.??Z?t??3?A`qh?y?*I4??9yy|\?
????}mnB??I}='E)p??X?q???????#6JXjmd??Q???"O?\????A9??d?	?6??&j?D?j??k??????\??z?}?1/ mKPxk*?%???pe??ȱ?Ur???g????۵yQ?̺`l?ZA?4˹?їGcda??oV&I??bea>H7Enf?[?bZ?|????i?s??=??d3?)?wXr"_???cйZ͉|-S䪑q9QZS????^
?ܮ?9???Q?߯\T?伹^?"??,Ϩ?׳?y{Q)?z?nҢ?'(x??X?`???S1?՘,??$??Gό?r9???(??	?N???ŝf?Z?_a??Ō??}?\?y2??????U?/N???꧲$??a?݉ȶ??#x~?#?s?~???.4?P(??%?ഹ???y???p???>/#,?n???3J?HʽmC??Y??Bc??S??????H?f????1??5?T"#W?V?I}V??y ?X?D3V??R?j^???"Ӈ6????>??R??i?FG??I3??t$?h?Uq???NVŦ(g???ŗ??Ux?}???|?=9??????O?OO?????:??Dń?*XEaC+N;ѿ?x?h$B??l??dr???4PU%w	^?;,?E?IU3???겾'r?rm.?#??t$P????y<???MeĄ?W?7????n??>jQ?#??ư4H??!eA ?p???Y? C)<ϋ?i?G???? ϲ]?\?????)?4t?r7???3?yi/?9A??\?X?y꧵OK?}ejR?????I??^?{??(?.?"L?3d??{^?}?6M?=?5?d??'??=Wk?
a???I2?L>?=B?ʋ9???S???k5Ei04?
4????b?6?hz?7aG?q?CB? f?0?\faod?ΐ?fP?6??9???ԨB?98??Y?b?3?"A*J??*)Q ⎾??:???lmant!????N???p?[?),???Q??J]e???u?;H?x??{g???1?W??>6?c??X?O?G%?.?׻;?Z?a??׈?B(?ww?g?2v7;RK??????,?UӓITD??r???T,pO-0f??,>?#?%???i?ѝ?ř|C??	E+Ph?"?lH?XSS?k??Ŧ?X???f?L??R?ko?C??ϴ6??.?)Sc?4?3?O?Y?	7?mHN??{?6?9?V?*|W>f^?Ŕ???բ??n!??"A?q??B???>???c???.?]?~z{4????Z3??;ۻ?????1???ӧGt?w?=>;??Zƣg/O?:???????I??m<?v??;|?C??c??@-??fMx?2?-???
'A`???}?%]7Wk??`?H?y?0*????S????E0???jc?EM?*+???LW~jAv?7MW!,??ɛ=???Wk9??&2?Í??J?:W?n???ɠ|? ???D??	?Jܘ?^4	C???[|DG???t??{?W??2??rv?+?y%ɇ?_? R?xj`ɘ?v?Ft???d?h?D?zݔz???;^~?;??R?3?}???3???M???vQ?j???ڊ?????=d~?wCY@???`??B?"???uI?G?H{	?\??YR?????r??\$???\,??(1gp???????E????{??? ?h???׿??????k#X|4?????t??w??????=?O?u??^???d??-??????????=2$?IBU7?#j9??u??k?q?k8t???x??????&L7?>???/5?}j???8@H&A????G1?s????o.0}??w???#?????]gJ???!??>yz????`??ԺC?y?Ç???K?=EhQ?q???M??{?8d?K?V?? TzIl<??C0??q???Y?,??,??Y?ٻ??-c@X??????]ˈ*L??/?)(~??}?u#-??"?`????)0~???>e??|????k"???,|?Fpt?W?/nq?
P?Y???|?=??gu???(?'hn"v?Y?Ͳ? N??
? 88??+F?Q?U\$z`?!w??ˍ!?6?S&???M??*?
?s??[q?	=??z???U???c??5`???Y?Aa6?⡉?KǠt0I"?z&??%-?[?a?f??/ ?JY?w??^?????-?pPƪ??#?????w??Փ?-?X????5?????im????z?w\?׵?E???J]rמK_??0??0o?rwR???}?эj#???_?O???\?1oD? ??h??????o???aq$v~!sr<b??-?0bEy?C???/??Ŏ??Q???)?.&????Rb??i?Wb?aᩐֆ[8y?M?\?	?Y??d{??\kVX???JR?lX?)??;???8}??ߏ?K???F?A40??	6?o??aC??Ii!?#?a?ނVvv?h]?(?Ԟ+R?F??`?`/???6j$??ތ?:?0?$?(??z3. -??L?<??????F^?D??2?}?׉?h???????ͻ?~4.L??A;{????R??]Il?&??X4?k???\?K???????F??S??b???!.?-?H?j?`??9???{?|/E׋?+!k??	?u?Yr??+j??L?,I*?*Q?G.*??T?????'g?팫* ?XR?8곁?osw??А??A??b,0J,?????:]T???-!w?^??5????(@?^t=;9?-Ī=hf??|??\I????t?bs?È%??\F??
ÌV???j???ȁ??r??'?H?(?jm?'9???,S?-?֔{|x?K#?M\??*?Y????!?7X???9?X?<vf?K3???R?q{??JsN?????hՈ??j??j??j??j??j??j??j??j??j???RX? P  