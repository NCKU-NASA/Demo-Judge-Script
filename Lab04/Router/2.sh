#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>"
    exit 0
fi

failed(){
    cat judgelog
    cat judgeerrlog 1>&2
    exit 1
}

#set -e

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping 8.8.8.8 -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    failed
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 curl --connect-timeout 5 portquiz.net:$(shuf -i 10-40000 -n 1))" == "" ]
then
    echo "Connection test fail." 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog > /dev/null
    failed
fi

echo "Connection test success." 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog > /dev/null

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e

