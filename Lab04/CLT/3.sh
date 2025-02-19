#!/bin/bash

if [ $# -lt 2 ]
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

dead=false

if [ "$(ssh $username@$1 ssh $username@$3 curl --connect-timeout 1 -L -k ifconfig.nasa 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "$1" ]
then
    dead=true
fi


if $dead
then
    failed
fi

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e
