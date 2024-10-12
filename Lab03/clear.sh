#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>" 1>&2
    exit 1
fi

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 '
if [ -f ~/.ssh/config.bak ]
then
    mv ~/.ssh/config.bak ~/.ssh/config
else
    rm ~/.ssh/config
fi
'

exit 0
