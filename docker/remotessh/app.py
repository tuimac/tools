import paramiko
import time

def handler(event, context):
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

    client.close()
    return None
