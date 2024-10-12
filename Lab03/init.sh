#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage: $0 <wanip> <studentId>" 1>&2
    exit 1
fi

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 '
if [ -f ~/.ssh/config ]
then
    cp ~/.ssh/config ~/.ssh/config.bak
fi

echo "StrictHostKeyChecking no" > ~/.ssh/config
echo "UserKnownHostsFile=/dev/null" >> ~/.ssh/config
echo "PasswordAuthentication=no" >> ~/.ssh/config
echo "ConnectTimeout=1" >> ~/.ssh/config
chmod 600 ~/.ssh/config'

exit 0
