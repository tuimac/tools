#!/usr/bin/env python

import boto3
import json
import sys
import os
from datetime import date, datetime
import re
import shutil
import subprocess
import traceback

def check_auth():
    if os.geteuid() != 0:
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

def find_value(json_data, key):
    if type(json_data) is dict:
        for k, v in json_data.items():
            if k == key: return v
            result = find_value(v, key)
            if result is not None: return result
    elif type(json_data) is list:
        for item in json_data:
            result = find_value(item, key)
            if result is not None: return result

def roll_back(new, old):
    os.rename(old, new)
    return

def create_record_data(ec2info):
    records_new = dict()
    for instance in ec2info["Reservations"]:
        status = instance["Instances"][0]["State"]["Name"]
        for tag in find_value(instance, "Tags"):
            if not (status == "running" or status == "stopped"): continue
            if tag["Key"] == "Name":
                try:
                    for eni in instance["Instances"][0]["NetworkInterfaces"]:
                        deviceIndex = eni["Attachment"]["DeviceIndex"]
                        if deviceIndex > 0:
                            records_new.setdefault(eni["PrivateIpAddress"], tag["Value"] + str(deviceIndex))
                        else:
                            records_new.setdefault(eni["PrivateIpAddress"], tag["Value"])
                        try:
                            records_new.setdefault(eni["Association"]["PublicIp"], tag["Value"] + "-public")
                        except KeyError:
                            pass
                except:
                    pass
                    #traceback.print_exc()
    return records_new

def read_record(path):
    records_old = dict()
    dumped_dnsconf = list()
    index = 0

    with open(path, 'r') as file:
        dumped_dnsconf = file.readlines()
    for i in range(len(dumped_dnsconf)):
        if re.match("^;", dumped_dnsconf[i]) is not None:
            index = i + 1
    if (index + 1) == len(dumped_dnsconf): return
    for i in range(index, len(dumped_dnsconf)):
        element_of_record = dumped_dnsconf[i].split()
        if len(element_of_record) == 0: break
        records_old.setdefault(element_of_record[3], element_of_record[0])
    with open(path, 'w') as file:
        for i in range(index):
            file.write(dumped_dnsconf[i])
    return records_old

def compare_records(new, old):
    if old is None: return new
    else:
        records_new = old
        for ip, name in old.items():
            if ip not in new: records_new.pop(ip)
        for ip, name in new.items():
            records_new.setdefault(ip, name)
        return records_new

def renew_bind_records(path, records_new):
    for ip, name in records_new.items():
        record = name + " IN " + "A " + ip + "\n"
        with open(path, 'a') as file:
            file.write(record)
    with open(path, 'a') as file:
        file.write("\n")
    return

if __name__ == '__main__':
    check_auth()
    os.environ['AWS_DEFAULT_REGION'] = "ap-northeast-1"
    NAMEDCONF = "/etc/named/tuimac.private"
    TMPFILE = NAMEDCONF + "_old"
    shutil.copyfile(NAMEDCONF, TMPFILE)

    try:
        ec2 = boto3.client('ec2')
        ec2info = ec2.describe_instances()
        records_new = create_record_data(ec2info)
        records_old = read_record(NAMEDCONF)
        records_new = compare_records(records_new, records_old)
        renew_bind_records(NAMEDCONF, records_new)
        os.remove(TMPFILE)
        restart_named = "systemctl restart named"
        subprocess.call(restart_named.split())
    except IndexError:
        roll_back(NAMEDCONF, TMPFILE)
