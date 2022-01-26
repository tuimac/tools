#!/usr/bin/env python3

import paramiko
import time

TARGET_SERVER = '10.3.1.50'
SSH_USER = 'ubuntu'
SSH_KEY = 'tuimac.pem'
COMMAND = 'cd /home/' + SSH_USER + '/tools/docker/nginx/; ./script.sh;'

client = paramiko.SSHClient()
rsa_key = paramiko.RSAKey.from_private_key_file(SSH_KEY)
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

client.connect(TARGET_SERVER, 22, SSH_USER, pkey=rsa_key)

stdin, stdout, stderr = client.exec_command(COMMAND)
time.sleep(5)

print(stdin)
print(stdout)
print(stderr)

client.close()
