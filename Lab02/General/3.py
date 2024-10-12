import subprocess
import os
import sys
import json
import random
import hashlib

hashfuncs = [["md5", hashlib.md5()], ["sha256", hashlib.sha256()]]

filecount = random.randint(1,2)*2
hashcount = filecount

files = []

for a in range(filecount):
    filename = f'/tmp/{random.randbytes(4).hex()}'
    with open(filename, 'w') as f:
        f.write('{}')
    files.append(filename)

hashdatas = []

for a in hashfuncs:
    a[1].update(b"{}")
    hashdatas.append(a[1].hexdigest())

parts = ["", f"-i {' '.join(files)} " if filecount > 0 else ""]
for a in range(len(hashfuncs)):
    parts[0] += f"--{hashfuncs[a][0]} {(hashdatas[a] + ' ')*int(hashcount / 2)}"

checkout = ""
checkerr = "Error: Only one type of hash function is allowed."

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

for a in files:
    os.remove(a)

exit(0)
