#!/bin/sh
#-----------------------------------------------------------------
# $1:ID (必須)
#       TBS      TBSラジオ
#       QRR      文化放送
#       LFR      ニッポン放送
#       NSB      ラジオNIKKEI
#       INT      INTERFM
#       FMT      TOKYO FM
#       BAYFM78  BayFm
#       NACK5    NACK5
#       JORF     ラジオ日本
#       YFM      FM yokohama
#       ---------------------
#       ABC      ABCラジオ
#       MBS      MBSラジオ
#       OBC      ラジオ大阪
#       CCL      FM COCOLO
#       802      FM802
#       FMO      FM大阪
#
# $2:OFILE (必須)
#       任意のファイル名(UTF-8可)
# $3:TIME (必須)
#       録音時間(分)
#
# -t "VALUE" (省略可)
#       タイトル
# -a "VALUE" (省略可)
#       アーティスト
# -A "VALUE" (省略可)
#       アルバム
# -g "VALUE" (省略可)
#       ジャンル
#-----------------------------------------------------------------
export LANG="ja_JP.UTF-8" LC_ALL="ja_JP.UTF-8"

USAGE=\
"Usage:$0 ID OFILE TIME [-t \"TITLE\"] [-a \"ARTIST\"] [-A \"ALBUM\"] [-g \"GENRE\"]"

if [ $# -lt 3 ];then
    print "${USAGE}\n`head -n36 $0 | grep -v ksh | sed 's/^#//g' `" 1>&2
    exit 1
fi

USERNAME=$(whoami)
ID="$1"
OFILE="$2"
TIME=$3
USERHOME=/home/${USERNAME}
#------------------------------------------#
GetAuth_SRC="${USERHOME}/src/get_auth.sh"
#------------------------------------------#
TOUT=1800  # sec
DELAY=20   # sec
RDIR=/tmp
CODEC=""
#CODEC=libmp3lame
####CODEC=libfaac
TIME=$((TIME*60+DELAY))

DATE1=$(date +%Y-%m-%d_%H%M%S)
DATE2=$(echo ${DATE1} | cut -c1-10)
DATE3=$(date +%Y/%m/%d)
YEAR=$(echo ${DATE1} | cut -c1-4)

shift 3
while getopts a:g:t:A: opt
do
    case ${opt} in
        t) TITLE="${OPTARG} ${DATE2}";;
        a) AUTHOR="${OPTARG}";;
        g) GENRE="${OPTARG}";;
        A) ALBUM="${OPTARG}";;
        *) echo ${USAGE} 1>&2
           exit 1;;
    esac
done

if [ "${CODEC}" = "libmp3lame" ];then
    RFILE="${RDIR}/${ID}_${OFILE}_${DATE1}.mp3"
	ID3V="-id3v2_version 3"
else
    RFILE="${RDIR}/${ID}_${OFILE}_${DATE1}.m4a"
fi
echo "RFILE:${RFILE}"
### authentication
RAuth=`${GetAuth_SRC}`
set -- ${RAuth}

playerurl=$1
authtoken=$2
echo "playerurl:${playerurl}"
echo "authtoken:${authtoken}"

areafree=0
playlist_uri=$(curl --silent \
    "http://radiko.jp/v2/station/stream_smh_multi/${ID}.xml" | \
    xmllint  --xpath \
    "/urls/url[@areafree='${areafree}'][1]/playlist_create_url/text()" \
    - 2> /dev/null)

echo "playlist_uri:${playlist_uri}"

if [ -z "${playlist_uri}" ];then
    echo "Cannnot get playlist URI" >&2
fi

#/usr/bin/rtmpdump -B ${TIME} -m ${TOUT} -qvr \
#    rtmpe://f-radiko.smartstream.ne.jp/${ID}/_definst_/simul-stream.stream \
#    -W ${playerurl} -C S:"" -C S:"" -C S:"" -C S:${authtoken} \
#    -o - 2>/tmp/rtmpdump.log | \
/usr/bin/ffmpeg \
    -loglevel error \
    -fflags +discardcorrupt \
    -headers "X-Radiko-Authtoken: ${authtoken}" \
    -i ${playlist_uri} \
    -acodec copy \
    -vn \
    -bsf:a aac_adtstoasc \
    -y \
    -t ${TIME} \
    "${RFILE}" \
#    - ${ID3V} -vn -acodec ${CODEC} -ar 44100 -ab 98304 -ac 2\
#    -metadata author="${AUTHOR}" \
#    -metadata artist="${AUTHOR}" \
#    -metadata title="${TITLE}" \
#    -metadata album="${ALBUM}" \
#    -metadata genre="${GENRE}" \
#    -metadata year="${YEAR}" \
#    2>/tmp/ffmpeg.log
#    > /dev/null 

iTunes_DIR="${USERHOME}/radiko/${OFILE}/"
if [ ! -d ${iTunes_DIR} ]; then
    mkdir "${iTunes_DIR}"
    chown ${USERNAME}:${USERNAME} "${iTunes_DIR}"
fi

if [ "${iTunes_DIR}" ]; then
    chown nekotank:nekotank "${RFILE}"
    cp "${RFILE}" "${iTunes_DIR}"
    if [ "$?" = "0" ]; then
        rm -f "${RFILE}"
    fi
fi