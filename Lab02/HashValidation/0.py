import subprocess
import os
import sys
import json
import random
import hashlib

hashfuncs = ["md5", "sha256"]

for hashfunc in hashfuncs:
    filecount = 1
    hashcount = filecount

    files = []

    for a in range(filecount):
        filename = f'/tmp/{random.randbytes(4).hex()}'
        with open(filename, 'w') as f:
            f.write('{}')
        files.append(filename)

    hashdatas = []
    for a in range(hashcount):
        nowhashobj = eval(f"hashlib.{hashfunc}()")
        nowhashobj.update(random.randbytes(16))
        hashdatas.append(nowhashobj.hexdigest())

    parts = [f"--{hashfunc} {' '.join(hashdatas)} " if hashcount > 0 else "", f"-i {' '.join(files)} " if filecount > 0 else ""]

    checkout = ""
    checkerr = "Error: Invalid checksum."

    try:
        for a in range(len(parts)):
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
        for a in files:
            os.remove(a)

exit(0)
