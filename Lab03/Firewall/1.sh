#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>" 1>&2
    exit 1
fi

#set -e
> judgeerrlog
> judgelog

shellreturn()
{
    cat judgelog
    cat judgeerrlog 1>&2
    exit $1
}

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping 8.8.8.8 -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 curl --connect-timeout 5 portquiz.net:$(shuf -i 10-40000 -n 1))" == "" ]
then
    echo "Connection test fail." 2>>judgeerrlog 1>>judgelog
    shellreturn 1
fi

echo "Connection test success." 2>>judgeerrlog 1>>judgelog

shellreturn 0

#set +e

