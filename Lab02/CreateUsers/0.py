import subprocess
import os
import sys
import json
import random
import hashlib
import re
from genuserfile import genfile

def useradd(alldata, parts):
    try:
        command = f"bash sahw2.sh {parts[0]}{parts[1]}".strip()

        run = subprocess.run(command.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=b'y')
       
        users = [a['username'] for a in alldata['userchecklist']]
        idtest = subprocess.run(f"for a in {' '.join(list(filter(('root').__ne__, users)))}; do id $a; done", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        getenttest = subprocess.run(f"getent passwd {' '.join(list(filter(('root').__ne__, users)))}".split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        logintestusers = random.sample(alldata["userchecklist"], k=5)

        loginteststate = True
        logintestout = ""
        logintesterr = ""
        for nowloginuser in logintestusers:
            nowstate = False
            for a in range(5):
                nowlogintest = subprocess.run(["sudo", "-u", "nasa", "sshpass", "-p", nowloginuser['password'], "ssh", f"{nowloginuser['username']}@localhost", "whoami"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, input=nowloginuser['password'].encode())
                logintestout += nowlogintest.stdout.decode() + '\n'
                logintesterr += nowlogintest.stderr.decode() + '\n'
                if nowlogintest.stdout.decode().strip() == nowloginuser['username']:
                    nowstate = True
                    break
            if not nowstate:
                loginteststate = False
                break

        result = {"command":command, "returncode":run.returncode, "resultout": run.stdout.decode(), "resulterr": run.stderr.decode(), "id":idtest.stdout.decode(), "getent": getenttest.stdout.decode(), "loginteststate": loginteststate, "logintestout": logintestout, "logintesterr": logintesterr}


        print("command: " + json.dumps(result['command']))
        print("stdout: " + json.dumps(result['resultout']))
        print("ansoutregex: " + json.dumps('(.|\r|\n)*'+alldata['existstring'].strip()+'$'))
        print("stderr: " + json.dumps(result['resulterr']))
        print("anserr: " + json.dumps(""))
        print("returncode: " + str(result['returncode']))
        print()

        return result
    finally:
        run = subprocess.run(f"bash ../removeuser.sh {alldata['filepart']}".split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)



hashfuncs = ["md5", "sha256"]

resultdata = {"ans":[], "result":[]}

for hashfunc in hashfuncs:
    nowresult = []
    alldata = genfile(hashfunc, min=10, max=30)
    resultdata["ans"].append(alldata)
    parts = [alldata["hashpart"], alldata["filepart"]]

    try:
        for a in range(len(parts)):
            nowresult.append(useradd(alldata, parts))
            parts.append(parts.pop(0))
    finally:
        for a in alldata['files']:
            os.remove(a)

    resultdata["result"].append(nowresult)

alldata = genfile(random.choice(hashfuncs))
resultdata["ans"].append(alldata)
parts = [alldata["hashpart"], alldata["filepart"]]
random.shuffle(parts)
try:
    resultdata["result"].append([useradd(alldata, parts)])
finally: 
    for a in alldata['files']:
        os.remove(a)

with open('createuser.json', 'w') as f:
    f.write(json.dumps(resultdata))

for i in range(len(resultdata["result"])):
    for a in resultdata["result"][i]:
        if re.compile('(.|\r|\n)*'+resultdata["ans"][i]['existstring'].strip()+'$').match(a['resultout'].strip()) == None or a['resulterr'].strip() != "" or a['returncode'] != 0:
            sys.exit(1)

exit(0)
