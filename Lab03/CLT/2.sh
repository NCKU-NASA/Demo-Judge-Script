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

dead=false

if [ "$(ssh $username@$1 ssh $username@192.168.3.100 curl --connect-timeout 1 -L -k 10.210.0.8 2>>judgeerrlog | tee -a judgelog)" != "$1" ]
then
    dead=true
fi


if $dead
then
    shellreturn 1
fi

shellreturn 0

#set +e
