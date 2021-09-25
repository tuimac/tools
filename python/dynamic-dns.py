#!/usr/bin/env python3

import boto3
import json
import sys
import os
import shutil
import subprocess
import traceback
import hashlib

CONF_PATH = 'tuimac.private'

def check_auth():
    if os.geteuid() != 0:
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

def roll_back(new, old):
    os.rename(old, new)
    return

def create_new_records(ec2):
    # List ec2 information only from only running instances
    records_list = []

    ec2_list = ec2.describe_instances(
        Filters = [{
            'Name': 'instance-state-name',
            'Values': ['running']
        }]
    )
    for instance in ec2_list['Reservations']:
        try:
            name_tag = [tag['Value'] for tag in instance['Instances'][0]['Tags'] if tag['Key'] == 'Name'][0]
            records_list.append(name_tag)
        except KeyError:
            pass
        

def rewrite_records(dns_records):
    pass

def is_same_file(new_file_path, old_file_path):
    new_file = open(new_file_path, 'r')
    new_file_hash = hashlib.md5(new_file.read().encode()).hexdigest()
    old_file = open(old_file_path, 'r')
    old_file_hash = hashlib.md5(old_file.read().encode()).hexdigest()
    print(new_file_hash)
    print(old_file_hash)
    if new_file_hash == old_file_hash:
        return True
    else:
        return False


if __name__ == '__main__':
    try:
        # Check if this script was executed by root or sudo
        check_auth()

        # Set region for boto3
        os.environ['AWS_DEFAULT_REGION'] = 'ap-northeast-1'

        # Avoid old file to ~.old
        shutil.copyfile(CONF_PATH, CONF_PATH + '.old')

        # Initialize aws sdk
        ec2 = boto3.client('ec2')

        # Create new DNS record
        dns_records = create_new_records(ec2)

        # Rewrite record
        rewrite_records(dns_records)

        # If there is some renewable records, reload named
        if is_same_file(CONF_PATH, CONF_PATH + '.old') is True:
            print('True')
            #subprocess.call(['systemctl', 'restart', 'named'])

        # Delete old file
        os.remove(CONF_PATH + '.old')
    except:
        traceback.print_exc()
        roll_back(CONF_PATH, CONF_PATH + '.old')
