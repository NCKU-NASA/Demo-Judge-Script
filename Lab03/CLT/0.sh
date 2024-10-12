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

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 hostname 2>>judgeerrlog | tee -a judgelog)" != "clt" ]
then
    shellreturn 1
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ping clt -c 1 -W 1 2>>judgeerrlog | tee -a judgelog | grep "bytes from clt (.*): icmp_seq=1")" == "" ]
then
    shellreturn 1
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ip a show eth0 2>>judgeerrlog | tee -a judgelog | grep "inet " | wc -l)" == "" ]
then
    shellreturn 1
fi

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 ip a show eth0 | grep "inet 192\.168\.3\.100/24")" == "" ]
then
    shellreturn 1
fi


shellreturn 0

#set +e
