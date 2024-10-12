import os
import sys
import json
import yaml
import random
import hashlib

shells = ["/bin/sh", "/bin/bash"]

def genfile(hashfunc, badformat=False, min=100, max=150):
    iduserregex = ""
    getentuserregex = ""
    userchecklist = []
    existstring = ""
    userdata = []
    groupbag = []
    users = []
    for a in range(random.randint(15,20)):
        groupbag.append(bytes([random.randint(b'a'[0],b'z'[0])]).decode() + random.randbytes(4).hex())
    for a in range(2):
        now = []
        length = random.randint(min, max)
        rootindex = random.randint(0, length - 1)
        for i in range(length):
            nowgroups = random.sample(groupbag, k=random.randint(0,5))
            nowshell = random.choice(shells)
            nowpassword = random.randbytes(random.randint(4, 8)).hex()
            if random.randint(0, 99) < 1 or i == rootindex:
                nowuser = "root"
                existstring += f"Warning: user {nowuser} already exists.\n"
            elif random.randint(0, 99) < 5 and i > 5:
                nowuser = random.choice(random.choice(userdata + [now]))["username"]
                existstring += f"Warning: user {nowuser} already exists.\n"
            else:
                nowuser = bytes([random.randint(b'a'[0],b'z'[0])]).decode() + random.randbytes(4).hex()
                nowgroupsreg = ','.join([f"\d+\(({'|'.join(nowgroups + [nowuser])})\)" for a in (nowgroups + [nowuser])])
                iduserregex += f"uid=\d+\({nowuser}\) gid=\d+\({nowuser}\) groups={nowgroupsreg}\n"
                getentuserregex += f"{nowuser}:.*:\d+:\d+:.*:.*:{nowshell}\n"
                userchecklist.append({"username": nowuser, "password": nowpassword})
            users.append(nowuser)
            now.append({"username":nowuser, "password": nowpassword, "shell": nowshell, "groups":nowgroups})

        userdata.append(now)

    if badformat:
        types = ["yaml", "csv"]
    else:
        types = ["json", "csv"]

    files = []
    hashdatas = []

    for a in userdata:
        nowtype = random.choice(types)
        types.remove(nowtype)
        filename = f'/tmp/{random.randbytes(4).hex()}'
        with open(filename, 'w') as f:
            if nowtype == "json":
                f.write(json.dumps(a))
            elif nowtype == "yaml":
                yaml.dump(a, f)
            elif nowtype == "csv":
                f.write("username,password,shell,groups\n")
                for data in a:
                    f.write(f"{data['username']},{data['password']},{data['shell']},{' '.join(data['groups'])}\n")
            elif nowtype == "html":
                f.write("<!DOCTYPE html><html><body><p>My First Heading</p></body></html>")
        nowhashobj = eval(f"hashlib.{hashfunc}()")
        with open(filename, 'rb') as f:
            nowhashobj.update(f.read())
        hashdatas.append(nowhashobj.hexdigest())
        files.append(filename)

    return {"hashpart":f"--{hashfunc} {' '.join(hashdatas)} " if len(hashdatas) > 0 else "", "filepart":f"-i {' '.join(files)} " if len(files) > 0 else "", "users": users, "iduserregex": iduserregex, "getentuserregex": getentuserregex, "userchecklist": userchecklist, "existstring": existstring, "files": files}
