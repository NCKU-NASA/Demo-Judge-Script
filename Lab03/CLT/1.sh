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

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 sudo whoami 2>>judgeerrlog | tee -a judgelog)" != "root" ]
then
    echo "passwd less sudo on clt?" >> judgelog
    shellreturn 1
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ping 8.8.8.8 -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

traceroutedata="$(ssh $username@$1 ssh $username@192.168.3.100 sudo traceroute -n -I 8.8.8.8 -w 1 2>>judgeerrlog | tee -a judgelog)"

if [ "$(echo "$traceroutedata" | grep "1  192.168.3.254")" == "" ]
then
    shellreturn 1
fi

if [ "$(echo "$traceroutedata" | grep "2  10.210.128.254")" == "" ]
then
    shellreturn 1
fi

shellreturn 0

#set +e
