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

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo whoami 2>>judgeerrlog | tee -a judgelog)" != "root" ]
then
    shellreturn 1
fi

shellreturn 0

#set +e

