import subprocess
import sys
import json
import random

flags = ""
for a in range(random.randint(1,5)):
    flags += f" --{random.randbytes(2).hex()}"

command = f"bash sahw2.sh{flags}".strip()
checkout = """
Usage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...} -i files ...

--sha256: SHA256 hashes to validate input files.
--md5: MD5 hashes to validate input files.
-i: Input files.
"""
checkerr = "Error: Invalid arguments."

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

exit(0)
