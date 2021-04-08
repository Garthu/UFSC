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
�      �<kw۶���_�0�Cʒ��+�+����>u�l������CK���dH�v�������������������u��5Nb���`0��1���ƍo��Ԅ�������FS}��Mkmcmsk}��j��!�l�y,�i�NH�7΄޸Q9ܢ��'���$�S����mc���$e��:t��h�b����}��������oH�~��������'��k\8Ѹ����ۣӞ����YjU^�;�uZ����;������;d�WqG�,1R��H���xL=(�OH}D�T�!t0���
I�`���?�O	z�Ƥ�^F. W���3圙'&�FȰ��4�&K	�����}��:�({�"hVX����{Ns����^��1#�d��d����͍�����&�!%�F���Wǻ5+t��l�p�^�y!��7�Uq���7���0�LV`�U2�������	� d�T�O�m��
8�@AL��B-�5U%��m?�^,(\�nL���Qcz�8i긞�?��r�T/W�UZ9ɓY���`*���ȹ���YD��L�=���5ϡ6��xz��sn+�`��!�&�G>H5�g�v���HDR��Ⱦ�7���L����$8�Mr8��8�kD��S:�hl.'ŤY#���G��,+�ԊAl�A�8�Z��q�a@�(H��o�6Z-��)n#p���᠌r	� %����(0�5p&`�j�zꙌ!���w֯�s+�֒��h�QkH�e�]�<�m��ͤ%5�e��sL^��7y��0�����K��6?՝T�YN�09MQ�Cd��_��]Z(״���T8�2GrH+"BI�����y��٫�g��Ү�WyfQ^�_�V��P�~�<����U��OƓb��@�e#�L�j5'bf�aF0��V��e�~&�YV:�/��'�	u�YP�YLi2���}b���/;z���[	�6-��}�����ԣ��A���؇u
�wqV�ɻ�7D�uO���>W�@�ӫ�,pN[;%\`�m�
smȐ�\�e�	�ﳕ�$ݥT�y�t>�ȷ�Y��L]LT��z�`��Rw��"���A=�T$��&�Y�fMP����Rm���|��ՂDJ��{��)Ђl��I��μ;l�w�E�џ��2�Y���%�+;�D2&Coj�]������=>���/��G��]PyE��zb���C$X�,p��������/f#@�rӁ$VZ�;�#&��秀J�����[��O����,�-uL�Re�\����́*���G�0BCvbD�Gs0?�����)�2d�b0K��)�t2! \�{��i��bD�"�ˉ&r����˨Y�P��H]��XhY�j�25䰊���S'�r4��M!��M����a_J+�8oGB3`�ɴ���g�!�BJR3�b1�<}!��t��>��|�J'?�=kj�43=Mf�X����8 X�9��Љr�DL�1�Lc�A��bņ(ّ"(���П3	�ݐ�^4�H��ԉc�7�2�\����N��D%�D�q����LlHU6!����1E�!++*���407�?�~��!���1La�we��BV	��	RG�����:��1�51L^	W;����ʟԏj�T�y��<[,���� �*� u��|'����R:C���pjS������e۝��9�B%�f� �4�T	d%������s�v'��/g9	E[D3����Y�����'�]W5�ە�.�(���7R���mL�,�-c*4� �gP��X�	��6���تg P|QI�څ�W*�>�I�)�DJzx�M|��+�-�j_����[�J���_�ΐ֯7��:���۹�ߍ������C$������t�z{��ve���q�����G'ǯ;K�W���{�?u�6*�>��cI���H�ҫ�7�L*�����F�R6xDW�����3[�N�!�:K&xu��C�� �PE�@
m7�㑟DHN��� ��ٞ8�����1�O"�<�9R���v w��}]dwoH��#���҈~"K�3�h4�4 K�����WP��t�����G~ ��_	����ry�����^�	��)e�:���㕈̦$�guu�r���/=�Ͱ���Dbwb\���?!lP��.Ȝ���*�����	�t�m`>�;H���]����J���T���(�<����7��xG!���Ԥ�Y�D`7�#2�+�##G���t�|H/����~�VF.!�����T��R���_����QǢ�m+;�on�=��<HR����w{]��}�E���ە
��a3Ng(=�$�Q��6�#\h��`�5;0�*�r2#J����<J
7`��@\��/59�6.�dE6�6�f��ms�6�C��~FΊK�a�"�hޅ��*ɉ�%��֌q=,|�����#�.a�A��1�y������ӥֶMh�3 f�#�"��6���3Do�e% �^����� t�X��Npe�4%�J˲d%y���}^�^� �d��dh�]�*������%�rK���Qf_�O-��S�8��?�a([���:��'2��7��6��m>�1���Ҡ�y�5�yx-��X���Ǡ	����c,��%���dT !����2�H6�����ʗ�1EJ�\^�-YGuJ�$�߸� �r��z�!�W��I�Ƴ���o���\]&c�;��by�!�t1��'n��b
�����,�K���F���M�d �Z�w���_m6���Av5CQy�;DJ��+g����I���^�����\��F�1��A�Sw��������z'��^���C�x�G�Gۮ<eg�t�����l`!.Y� ;�H4ώ/l<�6��$���N�ʇ��˧8�?����Nj�FSX�]���9�g0��<j��M�*Ԝ�ࣰ?ӈ�B�^����l��1,�:V��5;6A���}3/r/=0n)�R?03�A�Q��|hb	�D#@��v,*��2�ݟ{`�3�����I���q��,��5��-v��M�eo�-�$\�M68����6��9��ol��l���kj��B�ڑ3&T���B���4���j��؅W����<��ٰ��U��2��i��NU�y��f5p�_����Uk�`j��J6tة����Ι_�G�2��ȕ�p�Y�/��qhTKMN��8��O�?�?H����zn��������iډ`X�_w'�����N ՙ�y3�l=o����稁FF�5
=V��Ӥ���o�O������� a�H!�7��6�p@1���vt���l����Ǉ=X�0�bCj.������&�2$ ����1����%�9���9�~wtZ����Og�c�=�b*���������yb�A��W&T"��k�T,:��7�J:7(�J��s@Q���ď�5w�����N*:YÎ1%��p��_���3/ީ��~���Z1L����$��,�C���1>���R���S�kbmeq3i(�$�C�k2|X��-��@91�2F>3��J�Jb��Xq�N��1�4����D�'/a�b��|<��8+�;��b>7Ұ�\D�ݩl���2��:}�Y�[1RI6V���ZQ��HEƢ(X�R�z"I�+�&�2�~��Oȼ�+�'���Ci�`tߐ0 Ñ]�QI�\'�4-rdߑ&ٖju[��LV��͉��"˫(b?+�4�S1�%��_D'c�i&�G�~�rŬ"$����$k���gY,�_��$��5�E���<J���R:��H�u��<-`KQh"�Y����hfa�Cm��"+"��z��WZ�����=(�T��آ��2���J�AL��9y�g�0�l�Џ���NH]�t��\a����{��>�
�
V|2����!S%,��8������v��]	 ����q�p��-g�F�m��s���pY�y�4A�3a#}���30�X2&��gu ��Pd��,+}�ԘBt�6�`[L��.����E{g:YJ�K�.Y�܂K�D�uj�n�9.٠Uf��X���т�N	_�VM��_�[^��x>��G�=-�[���\.���j�Y����/�X�ˌ��l���}Ic�1��������wr|�_#��-/]��H;���t��'Ppy;�%���k1�,h 
��b؄���ʆ.!��yD�]�&�
X�p'x�!i�����p��Z[=_�ICJ:��Ψ�"cb��t�
\WaK_�
19��|]�]D.�ޯ؋x]Y� `9��}Ͽh��D=��5-8`��M�8�^��0֨e����ɏ{ǯ������p�{ ��H �:�T�/`�����z�O� l��V�|Y.�S��ߋ�E&W��gxn�v�YD��,j
_�dʳ��Z�w�������|�J=�ʟ(�^��@�/֯���c�~>��L�V~
�_!<��E���#t=FW�\`L��k����oŠf�Y"A ���3I\�N����6�߱X�\�9n0a %� ���/�D[�.�k�6�L�rb��`�ٗ����_0��z��V#����zF��V�l����mc��K�h7_����֋|l4[�h���Gk}]�Z_m�`m��Z/6���z��Hmu��&{��G�Anl�d���m�2mG��J��:˕ZQ������	�3tJX�0�]���V���ma����5ǹ�L7)�E'��ey���5 �6?�x�ə{.j����F=ޙxĮ�������:�۴��'l���YoI#����_�U1Ϋ��i��q0�n {ʞ�5׵�Ӣc���V 1j ��i��Ƕ�����n����ݎo��Ap�>O%�5����m�k���� t�(P0��2��(�|u�)��[��/Z=��m	����U��kOhVK�jSv'���q"jU�M�/�2��GB���6L��!�Q�5����a|��bW���v�(���,�^n�-�h��*�u�nH.�V<J`C	�Lu�`�(y耚�]4�5�m/��c*:�O<硫�k�����A����C����䘸,�O���+ك1eG�)���8%�vQa��tqX����-��
?Gǐa'�6��ߏ�������`T�~��?�~��v�y&7���"v�;���k�Ni��N�U4�]=�;�����v�ȃ��!a�$�Y�S�͢!�.db]av)Zk�k	�;������H���*�wG*#!;�� ���|�=R��˂t�$����� 2Q1-�(X�J���Vc9�6.X|If4�N��-�
�$��y����o��1=*2O�"	LBk&�3�(M�u�ɐ���\��pi�ތ.�'�] �#*N*\<6F���a���V� ����[4V�E��C/a)7��0,
}U����|-��d�����Ա��k��s����=@zJhL�C|�QL�~Y+t�����ԁ߳�q����s���+?��W�9�O�8�r��u�{���t��d����/�~"&{�}p����=�lw����6c��Ȫ�1P���m�Ư�wd�� ��4	����z��,WS2X�f�u��(?����i�r�G�G�� ����F�ɛ�1�t�� �
S0uc�֖��U���붝%�* �z�>LT*�>�֚}d_Κ��G�U=�!���ONN��y_+}k�������9:����E��}uڱ���]�瓷���O/������g{�>=y�n��i7�/�/��ڎ0��l�_=:ͳ����_x�o�������֣��T�����]w�t����h{�C�̘��q6<D1Tq��Y�:sמμ��Kҋ�9JC���J�09�jhT�z�⭩�^:�l��<�� �m4���j���6Ltx�>��c���퍪^Vr��Qō�������m�����V�Dr�a'Mz��N��N�{��k;���C�i��(���4I�0��g����s��/vg 	����is���X$8�3�`�ER$ŧ\r}h�3���˹I�5��oFa�9	�I
�q�:����W�4�b�I�X�ͅ�O'`E�
�S���Sm�sxx����o8���cz(j�B0�5�U��r�hڡ����Z�*�'��kHW�B�7b'[�^�Q�������ocEdX�O51����!�Q�tQa�����aXV+^�'�����9;�<�d���1V�kn���$�,��ٚ~T��'@E��ETT�lb��?��e���Ǐ2���=^����b;��Xue�r������ڎ��(�NȂSq:0�`rհ�?*h�!^l~����Ķ��D��Z�1�+P��V,TlE+�'�?ݦ��~��Q3y�'�H�ÇR��W=k���~&qn,*e�VjaER���4����4�ciV.*G&Q�zQ���� �w*���9,2��pˇ�SS�j��9'CO��UB�*U�&�*��:���Mg^�6��ǿ(0�H{�Xq�0Ab���O��.�B��{۟��DL0���/����"<r&'���w���Y�0���s�#OEk���)h��e�P;o$^{��B�6h�E�b���䰤���<8��J~"���-C�$~��q������;\n+��2���0�-�ۉ�&�n�ǔ.�/�0CJ�C��H��m��6���_�g{�_m�ኅ��`�	H�#Q�N��w9׺y���ejb	<>U�>V��MNyg`{܉)����^/��J��y$�-ܖ�q�xa��%�Qք]h�4��Q�U�[,=o�rj�L�ʐ��?�I8�8Zד��;0U'��y�gN9�2,��G��S�ه����e�č���K����d�[�W����܉��ߔ���o�L�*����@�XN+il5�
�R�9Hij��N��%�4�TNC���,�p2K�HXF8�Q��ק�j|�_�L�QF\�MUJ^�[kv�S�"�H�ZpfV���1�H�x��1Q��Z����F�1�g��#Q@WŮ?s�fJs E�m�j��eԄt]�%څB:�+r�#��|�R�~~<:UI�&��n��JOFY�����l�&qM�#6����͡$�LJF"W7�Ri'�d9~6�$w�Յɪ4�L 6TB@%�������y ���k�UI�HU>�YiMp,1x�<�F:J�5���*�&ж(�*h'��R�ǝ,+�z�o���N�Ņ:�z�<6��Dt\$�Z^�`ݕt_�X3i2A��t3�P��ݪ�D)�7�+6QdWQh�V�qm3�b�a�u��� ��񐋖mV.�l*��ʳ�F���Z���E�f9[Aq�ҍ�\%���s'�˙�Q�J��dzg�+���S�dw���7�/�+k4l�+M,�Q5�@��@J���j�z�2�h��[ō�[,������o��J�aF�|ГG�����-tX�����"�ݗ[��E�Zr���}��~"�x��;�@�L�l=������������w�(�.�0� ����HF	�x�F����F(`�X��t�}��կ|�iz�7�4Ez,}� F�ŵ��e������q�ٺa�LV3��� y�u�c�WG�_�툶��8�K��%�Ze���Y���@z	��9��uX݄d/��.�B���F䶸�� eJ�e.��@��q�$���$,�D�,({���M�'��LPs�y2lv��ۻ4`�ْ���]�1��w�P�z`&���s�8�g��Z瞎����u���M^K#�?�]i����ͱv��d֦Z/�	7�����Zm9\.�+���I�UK�r+���ه�Hz���?ق��0��&�J}̵O�7jx�l�pg������v������!<��d��ݡ?��,��tx2�'#��l��xs��Εb�p�:[Җ�y�'_J�Տ�5�N���)��v�C��c#�_X$c*�l5�E:7��cnp�#�*�d�C��M��B/(uz��]<mB�"!��zD]-
I/GN�,�dsZ5��Xѯ{�Y�"��eA0�p��qDX&�$�f��|��,:�:M�D�Z���B��r�Yp��\���Ȑ����KR�r�^�U�->�
�yG:̖������e^�����$�hkP��0��m*��h��_��� c�uS�VJ,f�NveQ+�k�*Q���z��&����v�l�D.&C�[�؄	��q��8q���y^��Ց]J���ͬ$��gel�8+mLB�FfCiU��`7�{��ΐ���6.�1d� oyĶ�3[\ٲ�9�I��/d���<]����fyx���:�`ʇ������R>��H��c�q�䣔eb���,PD�-����ƾ�h�9�2rz.���-�.ƕ�m�6SQ�d�l��>��F��F��)�>l�wZr�;�3���y�� �2:+�H,u�6D�_�[�$<mq�-�LT�c��x��e23'ǖ�CQ�٠{DJ@*�K�@�)�kk�x�5&�Z��ͬ �v���8Ӽ���U�y�K�U�.Yd�b'�c��Yş۱��*��-����
(�k�pp��|-p��d-3CL�ċ��E�{�BT,���7�'e��~� ��0=������x�;'hПh��]|H��N 7Z�����&BӖ^;���u���B�Kg��ftVI��z?��~�����U��A���VeYd�j��RlI̓��h�cr�U�f�܋�M�����P�,�w��dq-ȬWϓ�EZ�V{3E�K�� Y�N!�405�J������k��I&Ns\`/=m[�ܮ'yJo�.NX*�RH�r�X&`dqﯧBJ:<�6;q�B}��˹���Q��Xj�����Z��ie�0����{��t���{tg��4��::�<_�i�V%�ӎG_�u���ĺ�e�+;��e?������q�*¨�DH��5�4,_���Z���[L���$�
}E����e
U�}�O���v���ִ؊���y�r2�l� S����iPs�L���v�y�&5�.DFj2������6z��7�&^�q�Lr�����j�G|�j5���D�%{7��㩹�x��=�oW��fv�����%c[8wl��!|�&�,W����T�~c+5w7��=庖�M׼�V�����[(���Xs���<��3����u:� �J9�xj�"��rbdf�nQ�q��H�D�ՍX�klk艃*��Kf�7���w��[���ƞ�*���"a�������],�Y(�_���V)���[3�0A��X=a�F�Z��]�j�!��tqlxڨr��6(DLa���"ŀ������D&�81�ћx�I8�j��)�����p'G�(}��t9N���|�˥z����D����ߑQU�螌��\�dS�xq[��`��iZKn�d���/����U>�H��ƯD)e|Rt�Q�����������Q,�ħ"�)O��Y:T9�=��	���D`/�;+>�����UHg0��	�����	��������s�4�=m�ЬlQ.71�#@3�Um�V�Q������,�CF Xby�7��¿TdWe��r���H���y6��տ(^�<�����5UF�O�j�c�S�eA\�UB�X�&:K0����4%z23t�d����z�>��n�eÙ��=�N�A(*�����T�9ite%C@榬�=�be�4L�x����e���ֻ�$���+ǝ(lvN���[�v�� �w�����~�!?RS6~�#Pue���ʋo��3��u�*��al21d�p3PO�z	qK-�V�Ϩ�$'�F�A ���	}�fAѡ�����Jo(�"j`�.��LQ���ןN��3��k����Jai�pJ�T�?�`��Ii�\�o3I�5s�T�Lz�zƟRD3	j�%�U$,��s5��V�*N���s��bg{��q���O�u�tqΈ�,�(�)g��L>U�2�	ɣ�s�F�1�����g��/�!��o3�`~V��"� �tD��3���i~8���*	,(��,'�p�� yC�d!b̓hUǊ����e7�Ȃ]S��Y3<�DZm�Ϟ�Ku*��d8IJ-��x��p�U,Wz�H�[!6� ~�	��%��	~!�c���y_�Sh_$����u�}UU ![�IN\���h�k�%qĮ���7��qp*,Dţ��r>}�p4��u���'n�j���W�� ��Ĕi뽦vr��gG�|���E��tQx�[�B��è�A�Sg8�%|�9�;�����T�ޔ���,vU��Q��fړ�Uh���zN��W���Y(��Յ�K�!�3g��r����+D���2��Uꉦ�ї'���$�Z�U�-暝btB��+2�~gm�^�Ǯ�F�����"�����Y���9WԊ��om��nsQ�������(l�N`�⃨,#�J�a|=�,��C�F��KV�/��rV�����T���>���i*�_s+޶������`���
�|�1D�
M�b�j�'&{rC�e�i�?�}�����;���F���x�q��g�?_��w�z��X����7 k5�+���I�5~y���N�[�_����
��/(�Sn&��
�q�M����I�ʙ�/7d�
j�l���
7���Am |��W��٫� ��6�cw�{�`��� ��U,f2r��c�f{��ad���-���N,(3�HWpy4_F|O�����8>�Ҙ�rK*�T0Z���Z�ʙ%XT_ѫc�^�(�=.�S,��q6X�ޢ|	E�՚̻2Vó]�(�L)���sp��3���������)�W����]���x���Q+Ռ�x9c��Z�|���DW��v>1��ˇ�Κx%� \r4g�DY�Z�ՙ��ȓ������D�8���Յ�0��2IƤ�K�%oД0k��0{N�	X����mָo�m�b��&�O��CG�/��Os�Pa�����u���>�G�R����:�3��o��;�X�2���\�����`8L]%k4g�ný#���na(��i8��!�ԦNнV-q�x*�����/�t�B*�M=7�D����襡��b����α�s�!�+��⏕l��=E���2�O,�a�=�\횫�
�o	G�<�H�!K�G*�.�֝��*������'y/Xc?v�娇��Ya�$��+����IFBM1��[<�?��^���.�u��d�m��X������M���1�n�`�m���i�� �Y����?��Z�ߧ��Tc/�������k?3����/�������`k��ZH,�B�n�VS
}�n��at_�3��ϲ�ۓ�,�Ay���Z<�7�;\4{Z�KA�L��	_P�'�Ȟn�8Q����5A�`e>��y #�԰,�~�i,�(�����u�t�Ki��o�����jÓ�6�F"��G�.�}�4�����܄���sBi�m�e����Ӥ�f`M	/���Ț�ѧ[���FM��6>s0���ӌ0�7��=^�LWY�=Xid*�'�x���M�����$�h7����*9Rv$e ���V�(t�N�؉�%#��ح�hPd����J�X�.T�sO��Q-/�~MQ��Z��2�J�Mc�2��/����7�ev�_�ɁIK�	�f��p'EV�O�PhJ�/����"�	�<\�g��l��^�g��9��$���0����4�Sz�P_�#gk�9��8;���|�ƻ4����sۢ�����u��D}����=ʳ��Vg��G�ߍ��K��=q��m�y��-�\���-�~��	�!NRRpd�(�����?���_�:����	��Ew4���m���?���5�
5�tN?�#�-���>~��N�%��Nm0f/��Sf���
�t����P��*>Ű��6p�o{��/j�ߗXC0@��z��f/{C�IgRj�Qx����DHƔ�7�=�fl�v�s: )��r;�Q:�/�N��u��m�2�n�`w{cyI �����:�o�j�{�����ShH0�ք�Gy�xy�4�3�`�85*[hen%�so�?/�_-e��e���Å�#%u�1η��o�{n���P�y�`Ƿ�����N<�{�;f�(�pX#��F����n� }�wl�A�3M�ȥz�G�L�7��{Cװi�M�nw���J���{_�m㐅����l���_�GA+�Y"	l���ѵ���D�^W2GX�����m���S��7��#i8q1������7���x���:K�gX_�~|{�E`E�;�/s��l	������s\��[����eM�eMIFQf������`�`BF�Ee������7��x��쎛�t�W���=�>ľ��c23!�UX`�q����o��,��U/IKj/m��h��ӵ"Z.�Z	2
5��U��P^��Vv�Y:��O��.����/����Q<���~� �����b�����to��ц\�g�������7������í��7�k���X����WY{�N����5��G���x��M�yܬ���0�k��&�z�m8����ʣ�H\�X���ڞ�GM�k{�_��a�j�;Ow_�m�ǲ���N�?�������@�C��4u��9�OS���� t=�wj��@�
���'��-��Y�Y0u����
�!c�G `@�� �@��sɔ����z��S:����ƅ#��lk�PGظ�{��8��c��ߠ��<���1�Z��a6�4{��P�� ���ڣ�M�{>��׻]ħ3@;��& 茼Iw��`�q/���s�貶��h�}�@���߅.9�����������Sv2��nwy�s��.8#pF>�臫]3rX���_���{�K���r� 8����Y{����sh<?���R����A�Ӆ���2@"S�#g��ù�R��8�o('���v꼣�ޝ$.�+����q�vLi46��n����>P�]��YMց��3��'���yw:!�/h�qEaӐ�;F�U��-���ӫ_Q� ����4U[n���Y��b�1[n@_n�69%�I�@C-l��ڒ%F>O?�o���0	������sD��^nlm5Y{��q;�ގ�� ��;��1��YQ ݃�礍F`������w�����+�n�����Y�G̈́ z��_Jt;+_��.�����{*!@�ׇ����^n��<J�8&������F�va�$�B8���Ϩ���C�|<�%(�ya���Q2��`���=t��Qu�`S��;��:����+�L�J5֎ك'w�@x�J�N���ns�z����j[��l񚠻Μ��w�ȡmR�J�#�\({��m]���AXqF �柃X�RY���d ��B��srK���2j�=���6j���ڤ6�����n��Y�B�Xz���I��nl�k�S���ӣ>hw\�p�b@]��1-�GL`<�P�Sr�(7T��Ojeߡ�Sc���?�o1ԛ������_�f�VxF���C1DM���^�2�f�q�������E؈@�K���8<[����P4ry����9s�\y�S��Be<���uԂ��q"��/�$�й�ʕ��-M�|�O��p҆_r���<��3!�6��y t�/Z-�FY�@��!�1�hVH޺�l
:���8�p|����o��
�z������W�	�0N�p��ݦ���}(&�T���{*��1u\���ox=~�n,è{�6�uk�cuL]Z���_�nn�q�-a�f��ge�P�&�à�Ly�:���n�V�1o^�SP���E���*_�C��[ç�ڭ[Y��m5���҆�n���\W	h�H���=�)1����5mr��1q7kk,Q�� �iç�����nH�bۥS4�$���]����o�H��%s�8p�C�uT���귉?c��h c�$^{!H��������W��TF�S�+~j���TwM	:��C�$��U,eīݾE;�`F��C���^�&�l�	�[g�A��0cf#@8�-r֕2��I�f#�t�U����)#ߐ&ͯ�!1�4)�j�l�^��%i'�����H>�lm�{�y��0�������İn��"+���������:FP!�Nؘ�a��Z�u�4����|Z��pcW�$��:ot��u����`�D�a\�	h���H���p�Q�� u6VS �wKՉX	~^p�����4T3'\sƂ.�&����=�&��.|R����X�e3��:�Y�i�L��|L'�3�l�|��s}nww�v�_����U���b��s5on���`�x�V�����տ��)���VN�M��M���@bB*~�j�&/Z�'N���8��~���EY�EY�EY�EY�EY�EY�EY�EY�EY�EY�EY�EY�EY�E�x��� $W @ 