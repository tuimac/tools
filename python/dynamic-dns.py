#!/usr/bin/env python3

import boto3
import json
import sys
import os
import shutil
import subprocess
import traceback
import hashlib
import re

CONF_PATH = 'tuimac.private'

def check_auth():
    if os.geteuid() != 0:
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

def roll_back(new, old):
    os.rename(old, new)
    return

# Make sure name tags follows the FQDN syntax
def validate_name_tag(name_tag):
    if re.match('^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$', name_tag) is None:
        raise TypeError
    else:
        return name_tag

def create_new_records(ec2):
    # List ec2 information only from only running instances
    record_list = []
    a_record_temp = ' IN A '

    ec2_list = ec2.describe_instances(
        Filters = [{
            'Name': 'instance-state-name',
            'Values': ['running']
        }]
    )

    # Add records to list
    for instance in ec2_list['Reservations']:
        try:
            name_tag = [tag['Value'] for tag in instance['Instances'][0]['Tags'] if tag['Key'] == 'Name'][0]

            # Validate name tag
            print(name_tag)
            name_tag =  validate_name_tag(name_tag)

            for eni in instance['Instances'][0]['NetworkInterfaces']:
                deviceIndex = eni['Attachment']['DeviceIndex']
                if deviceIndex > 0:
                    record_list.append(name_tag + a_record_temp + eni['PrivateIpAddress'] + str(deviceIndex))
                else:
                    record_list.append(name_tag + a_record_temp + eni['PrivateIpAddress'])
                try:
                    record_list.append(name_tag + '-p' + a_record_temp + eni['Association']['PublicIp'])
                except KeyError as e:
                    raise e
        except KeyError as e:
            raise e
        except TypeError as e:
            raise e

    return record_list
        
def rewrite_records(dns_records):
    new_conf_lines = []

    # Read the lines for record conf file until ';'
    with open(CONF_PATH, 'r') as file:
        file_lines = file.readlines()
        for file_line in file_lines:
            new_conf_lines.append(file_line)
            if re.match('^;', file_line) is not None:
                break

    # Add new DNS records
    for dns_record in dns_records:
        new_conf_lines.append(dns_record + '\n')

    # Overwrite the record conf file
    with open(CONF_PATH, 'w') as file:
        for new_conf_line in new_conf_lines:
            file.write(new_conf_line)


def is_same_file(new_file_path, old_file_path):
    # Calculate the hash for new file
    new_file = open(new_file_path, 'r')
    new_file_hash = hashlib.md5(new_file.read().encode()).hexdigest()

    # Calculate the hash for new file
    old_file = open(old_file_path, 'r')
    old_file_hash = hashlib.md5(old_file.read().encode()).hexdigest()

    new_file.close()
    old_file.close()
    print(new_file_hash)
    print(old_file_hash)
    # Compare each hashes
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
