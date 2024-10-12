import subprocess
import os
import sys
import json
import random
import hashlib
import re
from genuserfile import genfile

with open('createuser.json', 'r') as f:
    resultdata = json.loads(f.read())

for i in range(len(resultdata['ans'])):
    for a in resultdata['result'][i]:
        print("command: \"id <user>\"")
        print("id: ")
        print(a['id'])
        print("ansidregex: ")
        print(resultdata['ans'][i]["iduserregex"].strip())
        print("command: \"getent passwd <user>\"")
        print('getent: ')
        print(a['getent'])
        print('ansgetentregex: ')
        print(resultdata['ans'][i]["getentuserregex"].strip())
        print()

        if re.compile(resultdata['ans'][i]["iduserregex"].strip()).match(a['id'].strip()) == None or re.compile(resultdata['ans'][i]["getentuserregex"].strip()).match(a['getent'].strip()) == None:
            sys.exit(1)

exit(0)
