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

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 hostname 2>>judgeerrlog | tee -a judgelog)" != "gw" ]
then
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ping gw -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from gw (.*): icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ip a show lan 2>>judgeerrlog | tee -a judgelog | grep "inet " | wc -l)" != "1" ]
then
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ip a show lan | grep "inet 192\.168\.3\.254/24")" == "" ]
then
    shellreturn 1
fi

if [ "$(ping $1 -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from $1: icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

shellreturn 0

#set +e
