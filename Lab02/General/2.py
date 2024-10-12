import subprocess
import os
import sys
import json
import random
import hashlib

hashfuncs = [["md5", hashlib.md5()], ["sha256", hashlib.sha256()]]

hashfunc = random.choice(hashfuncs)

filecount = random.randint(1,5)
hashcount = random.randint(1,5)
while hashcount == filecount:
    hashcount = random.randint(1,5)

files = []

for a in range(filecount):
    filename = f'/tmp/{random.randbytes(4).hex()}'
    with open(filename, 'w') as f:
        f.write('{}')
    files.append(filename)

hashfunc[1].update(b"{}")
hashdata = hashfunc[1].hexdigest()

parts = [f"--{hashfunc[0]} {(hashdata + ' ')*hashcount}" if hashcount > 0 else "", f"-i {' '.join(files)} " if filecount > 0 else ""]

checkout = ""
checkerr = "Error: Invalid values."

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
