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
    echo "passwd free sudo?" >> judgelog
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 sudo apt list --installed ncat netcat* 2>>judgeerrlog | tee -a judgelog | grep installed)" == "" ]
then
    echo "Please install netcat." >> judgelog
    shellreturn 1
fi

if [ "$(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 type nc 2>>judgeerrlog | tee -a judgelog)" == "" ]
then
    shellreturn 1
fi



port=$(shuf -i 2000-40000 -n 1)

ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "echo \"if you see this message, your external/1 fail\" | sudo nc -l -p $port" 2>>judgeerrlog 1>>judgelog &

sleep 3

dead=false
if [ "$(echo 1 | nc $1 $port -q 1 -w 3 2>>judgeerrlog | tee -a judgelog)" != "" ]
then
    dead=true
fi

kill -9 $(ps aux | grep "nc -l -p" | awk '{print $2}' | head -n 1)

if ! $dead
then
    port=80

    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "echo \"why you need to open tcp 80 port?\" | sudo nc -l -p $port" 1>/dev/null &

    sleep 3

    if [ "$(echo 1 | nc $1 $port -q 1 -w 3 | tee -a judgelog)" != "" ]
    then
        dead=true
    fi
fi

kill -9 $(ps aux | grep "nc -l -p" | awk '{print $2}' | head -n 1)

for a in $(ssh $(echo "$2" | awk '{print tolower($0)}')@$1 ps aux | grep "nc -l -p" | awk '{print $2}')
do
    ssh $(echo "$2" | awk '{print tolower($0)}')@$1 "sudo kill -9 $a"
done

if $dead
then
    shellreturn 1
fi

shellreturn 0

#set +e
