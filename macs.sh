#!/bin/sh
# mac address の取得

IPADDR=$1
LOGINPW=$2
REDIS=$3
MACS=""

if [ "${IPADDR}" = "" -o "${LOGINPW}" = "" ];then
    printf "Err. No Parameter."
    exit 1
fi

expect -c"
spawn telnet ${IPADDR}
expect \"Password:\"
send \"${LOGINPW}\r\"
expect \">\"
send \"console character ascii\r\"
expect \">\"
send \"console lines infinity\r\"
expect \">\"
send \"show arp\r\"
expect \">\"
send \"exit\r\"
close
" | grep -E "^LAN[1-3]" | awk '{print $3}' > /tmp/.macs.txt
# " | grep "Client ID" | sed -e  "s/^.*: ([0-9]*) //g" | sed -e "s/ /:/g" > /tmp/.macs.txt

while read line
do
    TMP_LINE=`echo ${line} | sed -e "s//,/g"`
    MACS=${MACS}${TMP_LINE}
done < /tmp/.macs.txt
MACS=`echo ${MACS} | sed -e "s/,$//g"`

curl http://${REDIS}:8080/orca/${MACS}/ > /dev/null 2>&1
