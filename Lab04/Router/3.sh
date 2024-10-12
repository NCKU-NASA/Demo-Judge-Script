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

username=$(echo "$2" | awk '{print tolower($0)}')

if [ "$(dig www.$username.nasa +time=1 +tries=1 2> >(tee -a judgeerrlog 1>&2) | tee -a judgelog | grep "^\S*$username\.nasa\..*IN.*A\s*$1")" == "" ]
then
    failed
fi

cat judgelog
cat judgeerrlog 1>&2
exit 0

#set +e

