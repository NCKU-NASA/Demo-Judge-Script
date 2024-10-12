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

if [ "$(ssh $username@$1 ssh $username@$3 dig www.google.nasa +time=1 +tries=1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "www\.google\.nasa\..*IN.*A\s*10\.31\.31\.80")" == "" ]
then
    failed
fi

if [ "$(ssh $username@$1 ssh $username@$3 curl --connect-timeout 1 -s -w "%{http_code}" -o /dev/null www.google.nasa 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog)" != "200" ]
then
    failed
fi

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e
