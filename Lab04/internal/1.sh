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

if [ "$(ipcalc $3 | grep Network | awk '{print $2}')" != "192.168.3.0/24" ]
then
    echo "invalid clt ip address" >> judgelog
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 hostname 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "clt" ]
then
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 ping clt -c 1 -W 1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "bytes from clt (.*): icmp_seq=1")" == "" ]
then
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 ip a show eth0 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "inet " | wc -l)" == "" ]
then
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 ip a show eth0 | grep "192\.168\.3\.255 scope global dynamic")" == "" ]
then
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 ss -ulnp | grep $3:53 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "" ]
then
    echo "udp 53 port??? I just said don't set up dns server on clt." >> judgelog
    failed
fi

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e
