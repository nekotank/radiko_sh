#!/bin/sh

playerurl=http://radiko.jp/apps/js/playerCommon.js

curl --silent -L -O ${playerurl}
if [ $? -ne 0 ]; then
    echo "failed get player"
fi

## get keydata
playerargs=`sed -n 's/.*new RadikoJSPlayer(\(.*\)/\1/p' ./playerCommon.js | sed 's/, /\n/g'`
appid=`echo "$playerargs" | sed -n 2p | sed -e "s/^'//" -e "s/'$//"`
authkey=`echo "$playerargs" | sed -n 3p | sed -e "s/^'//" -e "s/'$//"`

# autorize key value
RADIKO_AUTHKEY_VALUE="bcd151073c03b352e1ef2fd66c32209da9ca0afa"

if [ $authkey != $RADIKO_AUTHKEY_VALUE ]; then
    RADIKO_AUTHKEY_VALUE=authkey
fi
#
# access auth1_res
#
auth1_res=$(/usr/bin/curl --silent \
     --header "X-Radiko-App: pc_html5" \
     --header "X-Radiko-App-Version: 0.0.1" \
     --header "X-Radiko-User: dummy_user" \
     --header "X-Radiko-Device: pc" \
     --dump-header - \
     --output /dev/null \
     "https://radiko.jp/v2/api/auth1")
if [ $? -ne 0 -o ! "${auth1_res}" ]; then
    echo "failed auth1 process" 1>&2
    exit 1
fi

#echo "${auth1_res}"
# get keydata
# get partial key
#
authtoken=$(echo "${auth1_res}" | awk 'tolower($0) ~/^x-radiko-authtoken: / {print substr($0,21,length($0)-21)}')
offset=$(echo "${auth1_res}" | awk 'tolower($0) ~/^x-radiko-keyoffset: / {print substr($0,21,length($0)-21)}')
length=$(echo "${auth1_res}" | awk 'tolower($0) ~/^x-radiko-keylength: / {print substr($0,21,length($0)-21)}')

if [ -z "${authtoken}" ] || [ -z "${offset}" ] || [ -z "${length}" ]; then
    echo "offset failed" 1>&2
fi
#echo "${offset}"
#echo "${length}"

partialkey=$(echo ${RADIKO_AUTHKEY_VALUE} | \
            dd bs=1 "skip=${offset}" "count=${length}" 2> /dev/null | \
            /usr/bin/base64)

if [ $? -ne 0 -o ! "${partialkey}" ]; then
    echo "failed auth1 process" 1>&2
    exit 1
fi

auth2_url_parm=""
if [ -n "${radiko_session}"]; then
  auth2_url_parm="?radiko_session=${radiko_session}"
fi

#
# access auth2_fms
#
#echo "${authtoken}"
#echo "${partialkey}"
auth2_fms=$(/usr/bin/curl  \
     --silent \
     --header "X-Radiko-User: dummy_user" \
     --header "X-Radiko-Device: pc" \
     --header "X-Radiko-AuthToken: ${authtoken}" \
     --header "X-Radiko-Partialkey: ${partialkey}" \
     --dump-header - \
     --output /dev/null \
     "https://radiko.jp/v2/api/auth2")

#echo "${auth2_fms}"

if [ $? -ne 0 -o ! "${auth2_fms}" ]; then
  echo "failed auth2 process" 1>&2
  exit 1
fi
echo "authentication success" 1>&2

#areaid=`echo ${auth2_fms} | perl -ne 'print $1 if(/^([^,]+),/i)'`
#echo "areaid: ${areaid}" 1>&2

echo "${playerurl}" "${authtoken}"
