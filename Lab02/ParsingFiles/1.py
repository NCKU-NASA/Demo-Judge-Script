import subprocess
import os
import sys
import json
import random
import hashlib
from genuserfile import genfile

hashfuncs = ["md5", "sha256"]

for hashfunc in hashfuncs:
    alldata = genfile(hashfunc)
    
    parts = [alldata["hashpart"], alldata["filepart"]]

    #checkout = f"This script will create the following user(s): {' '.join(alldata['users'])} Do you want to continue? [y/n]:"
    #checkerr = ""

    try:
        for a in range(len(parts)):
            try:
                command = f"bash sahw2.sh {parts[0]}{parts[1]}".strip()

                run = subprocess.run(command.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=b'n')
                
                idtest = subprocess.run(f"for a in {' '.join(list(filter(('root').__ne__, alldata['users'])))}; do id $a; done", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

                resultout = run.stdout.decode()
                resulterr = run.stderr.decode()

                print("command: " + json.dumps(command))
                print("id: ")
                print(idtest.stdout.decode())
                print("ansid: ")
                print()
                print("returncode: " + str(run.returncode))
                print()

                if idtest.stdout.decode().strip() != "" or run.returncode != 0:
                    sys.exit(1)

                parts.append(parts.pop(0))
            finally:
                run = subprocess.run(f"bash ../removeuser.sh {alldata['filepart']}".split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    finally:
        for a in alldata['files']:
            os.remove(a)

exit(0)
