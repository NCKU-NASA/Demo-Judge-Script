import subprocess
import os
import sys
import json
import random
import hashlib

hashfuncs = ["md5", "sha256"]

for hashfunc in hashfuncs:
    filecount = random.randint(2,4)
    hashcount = filecount

    files = []

    testuser = bytes([random.randint(b'a'[0],b'z'[0])]).decode() + random.randbytes(4).hex()

    filedata = f'[{{"username":"root","password":"{random.randbytes(4).hex()}","shell":"/bin/sh","groups":[]}},{{"username":"{testuser}","password":"{random.randbytes(4).hex()}","shell":"/bin/sh","groups":[]}},{{"username":"{testuser}","password":"{random.randbytes(4).hex()}","shell":"/bin/sh","groups":[]}}]'
    for a in range(filecount):
        filename = f'/tmp/{random.randbytes(4).hex()}'
        with open(filename, 'w') as f:
            f.write(filedata)
        files.append(filename)

    print(files)
    exit(0)

    hashdatas = []
    nowhashobj = eval(f"hashlib.{hashfunc}()")
    nowhashobj.update(filedata.encode())
    hashdatas = [nowhashobj.hexdigest()]
    for a in range(1, hashcount):
        nowhashobj = eval(f"hashlib.{hashfunc}()")
        nowhashobj.update(random.randbytes(16))
        hashdatas.append(nowhashobj.hexdigest())

    filepart = f"-i {' '.join(files)} " if filecount > 0 else ""

    parts = [f"--{hashfunc} {' '.join(hashdatas)} " if hashcount > 0 else "", filepart]

    checkout = ""
    checkerr = "Error: Invalid checksum."

    try:
        for a in range(len(parts)):
            try:
                command = f"bash sahw2.sh {parts[0]}{parts[1]}".strip()

                run = subprocess.run(command.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=b'n')

                resultout = run.stdout.decode()
                resulterr = run.stderr.decode()

                print("command: " + json.dumps(command))
                print("stdout: " + json.dumps(resultout))
                print("ansout: " + json.dumps(checkout))
                print("stderr: " + json.dumps(resulterr))
                print("anserr: " + json.dumps(checkerr))
                print("returncode: " + str(run.returncode))
                print()

                if resultout.strip() != checkout.strip() or resulterr.strip() != checkerr.strip() or run.returncode == 0:
                    sys.exit(1)

                parts.append(parts.pop(0))
            finally:
                run = subprocess.run(f"bash ../removeuser.sh {filepart}".split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    finally:
        for a in files:
            os.remove(a)

exit(0)
