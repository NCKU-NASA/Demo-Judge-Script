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
        print("command: \"su <user> -c whoami\"")
        print("stdout: ")
        print(a['logintestout'])
        print('stderr: ')
        print(a['logintesterr'])
        print()

        if not a['loginteststate']:
            sys.exit(1)

exit(0)
