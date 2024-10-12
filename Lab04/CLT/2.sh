#!/bin/bash

if [ $# -lt 3 ]
then
    echo "usage: $0 <wanip> <studentId> <clt_ip>"
    exit 0
fi

failed(){
    cat judgelog
    cat judgeerrlog 1>&2
    exit 1
}

#set -e

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(ssh $username@$1 ssh $username@$3 sudo whoami 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "root" ]
then
    echo "passwd free sudo on clt?" >> judgelog
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 ping 8.8.8.8 -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from 8.8.8.8: icmp_seq=1")" == "" ]
then
    echo "ping dead?" >> judgelog
    failed
fi

traceroutedata="$(ssh $username@$1 ssh $username@$3 sudo traceroute -n -I 8.8.8.8 -w 0.1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)"

if [ "$(echo "$traceroutedata" | grep "1  192.168.3.254")" == "" ]
then
    failed
fi

if [ "$(echo "$traceroutedata" | grep "2  10.100.100.254")" == "" ]
then
    failed
fi

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e
