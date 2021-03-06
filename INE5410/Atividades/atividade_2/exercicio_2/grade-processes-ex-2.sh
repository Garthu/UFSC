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
?      ?;?r?H?>?+R0?)??C????m?M{???{{bE5?$B @??v??/s??C???W??f?(??????UD??????z(aqr?g????????M?mom??_?????n???~?~?jw?[????X??<N?????^?????K[???	C??&^ps??˽????ٳ?h8??$?U??@????xc?? Z?C??????W?O?`?Ď'?Oov?߾?????*m??ޛ??zmcF0?|^ ?g;???7?#?ph??Ђ?H&,?o??
4FPѱ?` ?3	?|I??`A??(?@?x	??????:j`Og?c'`??U?-??kC%kVH8A??̏*h?*???6?-?K?ӹ4?qF/???M????ڼ??w?z???]????'??y??????I?/bc???/H ?0t????????qR3J?ĎjT?1?#??!MAK???A8B6?mG??????`??[?OY?H瑗?r??	?@c????=???I	??Y~UQ΢??҃???6C???e??c??!?;?? 0??Q???QK?Q m???4?EЃ??'>????a?????PC???!???͉|֩????(.`?+5R?yʦ1K?G?gh?!?>?p??U?.?r?rP??){???͢???0Q*????!E???S
?!????#@9?%?]	
??J~?~?8\ձ}?t?v?\?g???z?vmWS?.ik:???"??v531??t?l#?3??J%?C?a?.F????tS?f??e#??????߭??|'?dޓ:̂???aɎl?ػĠ?Z͈ܕ)2?ȸ?	?)????? ???ud7>?6????~X;??β???&?֪*???=?U?t6iQ?
^6??)X'sw*????%?????3??Z?&?8LBp|f?Y???????6/?_???T?%?o?????E?2??x?Z?T??p>	qu"?-??????Ad_O?_8??c?!?J?z? 8m?,??z>g???\6???b??_?)%U$e??H?gY?
??2???????HŦ???vJ?}?(UH??T??jR?u?k?$?m????w?zկ?[???C??xOk?A)????ё?|R??5??ڰMU????ɪ??ࢳ?1?????C??_?}??x???^???????5?#tT	?*?a]? ?V?
vbx2ᠩ?b??+b??A???@U??'xU'UͼN?????ȴʵy?:B?M[5Q?3?h`F?2b?ة5????m???!jQ~#??ư4N&?!a??t????\A?R?XT}?T?d]	??y????:??u?J?????????4?R?J{?ȑ??1˄??????l?t???MMJ??G?3p?ɽ?|?}??
&?r??y^~??M?l?DDWF\ K??,?q??Z?ȕӣ???'???#?8??\??\;??܎?V?C??@??e?C??X?~	??(??bO"6??I??v?L?n
ei?ʛ?5???U?S??;kGLt?X$HM???%%
D??w`mMg_???u̍.?s???܋?'?$????9*?]??t???頞r??u2/????<??J??????s:??S?Q??˯????c???8k???Z?Y?K?]?I-Ѱ?f4?G;?0??3??,??T,p?O??gQ??8?5P?p?ݲ??(.?2'7H ???-R̖???U??]ӭ,7]?Bn?֪d?hvMm_???N	_hmjy]?[??Li?gH??s?'\??%9??V? ?9?V?*|?f^????f?ՠ??n.?? A<q??B??߽A??[q??.k??^r{4?8??t?77??????????{/???E??n??1?????]??????z??e???O???ҫl?>????^>}?d?eg???????d???a?k??bmt????l????z??F3??A?1?_$?6???(N?t????|E"8
a?lO??	??b??'?YN?T??R9???䈿LE????]T:-O???=T?1չh?36?
79????? OR??\???PʄK ??????a???1o?xj`??Ev??t??|
?p???fӔzY??;^v?[`?J?S?]?q??;??
?I?P??s[wvm?\??R??62??;??*?O=$??~)T{x?CI?\=??b??.??iR?????r?j)\?M?\,??06p??w5?(?E???ߏ<c????=???[y?G?oLY4f?mи*?w??????????;iz?7^??}??????#c?x????3N
gjzdH?☪n?G???᪃߯??y????/G3b?=????0i?`??ry*_i	.??0R??b!??	?????,?????9????e?C????̒?:Z??O?W{?}?ƸހF?9?|???Ç+?mE?P?q?????p??u?l???v5- ????x?W?`??x?I$???ZŲ?Z?ZUDY8?y???}?? ?d?.w]ETa??|xCA?ͷ?֥x??k?Ԃ?N4%?>`???]???????^+????33w???h?/'??l??:?P]??p?p??????\(?'hn"f?Y?̪? ?NgA <y? .W?b#O?8H???E:?H??	I6ȝR???7#Ы?s$???]N?hvF???g,u???S????f#,#41si?? ?	CD??䧗???ts3L????? ?Z1"k?a5^4[????jՄ'?@a???e????=?NX3??2??????-??????}???????ͦ??hf5?`C?KN?#?,at&T?ek?̟Ը??at???>e??x?&SzS??҅?5??p?.?iS|??,
??o!dF??L??œF#/??KR???"?s?p??+??ߖ4?E+`)???4?(1??aᡐֆ ?p??3?׹psض0'????s?Eaq?F?????)m???8?܌?7?1?????W??H??FS?!?????Њ?=B?6l5;?т?f???=??D?R?b6U??zk_??ڨ\????????4?Jx^?K<?r\@J>??.~?y?Ď?=Uىb???????6?#?o?<ŢE(V?Z?g*? ?Qju?????Q???qF^????v?Um????K?OЙdn&???!?Mq|??s??p?k_J5V??d ?H??/`x?9?6?????]&?????^b_??fR`??9s<ڧi[)?0i???Q?"|???????Zզ?ym??O??(??G,<N?}?? #N?|j<.?	?(P?????k??DS??W:?<HR?????;??e?D?S\??	?7?.?????(?!?*??v?*???绅g6?(??RL?#8z@@?1?O?[???2\??%lw??Sf?.gT?=2?~??~?3?V?\XX[??w??)??7ŷ)?c?3???u,p2?X??NH???~>??++c??<???Cx????Y?D(*??g??~????k$G????*L4??#??????|?ٙ`Nq?&?>?Yt??)h)?!H?_G\??yN/??xNX? 6?&??/Q?6?p?<?at?M;?X}?C\?!?m1?(T???{g??Y?r
6?8"~?X#eq֐???LzL?U??*???IK??S?5?yHQQ k?s/????3&????G?_	?\???0<p????%܍B???m?@7??b??d?W??ܝv?b?Ó??Lb???{j|?A>?? e?T^???Vl?qL?Qp?~??Ỳ?@?P?(?)?){.??d?m??????=:U?]L?z??$?["?WsB7k????ެ?:?????%????Z?le??5????=Q	'w??D?s??;y???????+?~m??????????%?n?|?k???j?w?F?7&?????(?????{????Z?nbN?K?~j`??%?~)??BA???>h?
е??t-?q)6(?,?q?*????xx??Fqv.???ź?9m?rD?w?X????I?????t???????5M??{??_?T??L????
2?r1D?lV$U????P?4T?n?dE?C%D?5??L>S??/???Av?k?|???1???5?L?;?.9/?)%???e?V?"?</媓wO????r?_1?nµT?????e?^2?#???H?A7?O*??[?]?????9?9N????}?o???ݷ???m?u8p P  