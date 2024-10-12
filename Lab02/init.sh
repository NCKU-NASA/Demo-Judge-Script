#!/bin/bash

pythonname=$(xxd -l 8 -ps /dev/urandom)

mv /usr/bin/python3 /usr/bin/$(pythonname)

curl -X POST "$JUDGEURL/status/setenv" -H "Content-Type: application/json" -d "{\"id\": \"$judgeid\", \"envs\": [{\"pythonname\": \"$pythonname\"}]}"


sed -i '' 's/\.\.\///g;s/[[:space:]]+\.\.[[:space:]]+//g;s/[[:space:]]+\.\.$//g' sahw2.sh
for a in rm pwd readlink
do
    sed -i '' 's/[^0-9a-zA-Z]+'$a'[^0-9a-zA-Z]+//g;s/^'$a'[^0-9a-zA-Z]+//g' sahw2.sh
done
