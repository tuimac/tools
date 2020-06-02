#This script is supported to run on Python 2.7 environment.

import json
import boto3
import sys
import os
import time
import subprocess
from datetime import date, datetime

VPCID = "vpc-xxxxxxxxxxxxxxx"
SUBNETIDS = [
    "subnet-xxxxxxxxxxxx",
]
SECURITYGPIDS = [
    "sg-xxxxxxxxxxxxxx",
]

def json_datetime(obj):
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError("Datetime don't fit the format!!")

def json_dump(json_data):
    result = json.dumps(json_data,
    	default=json_datetime,
        ensure_ascii=False,
        indent=4,
        separators=(',',': ')
    )
    print result	

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


def create_endpoint(ec2, service_name):
    service_name = "com.amazonaws.ap-northeast-1." + service_name
    for endpoint_name in [find_value(name, "ServiceName") for name in ec2.describe_vpc_endpoints()["VpcEndpoints"]]:
        if endpoint_name == service_name:
            print "Already have " + service_name
            return
    response = ec2.create_vpc_endpoint(
        DryRun = False,
        VpcEndpointType = 'Interface',
        VpcId = VPCID,
        ServiceName = service_name,
        SubnetIds = SUBNETIDS,
        SecurityGroupIds = SECURITYGPIDS,
        PrivateDnsEnabled = True
    )
    return

def start_ec2(instanceId, ec2):
    ec2.start_instances(
        InstanceIds = [instanceId],
        DryRun = False
    )
    return

def status_check(instanceId, ec2):
    response = ec2.describe_instance_status(
        InstanceIds = [instanceId],
        DryRun = False,
        IncludeAllInstances = True
    )
    status = find_value(find_value(response, "InstanceState"), "Name")
    return status

def getNameTag(reservation):
    tags = find_value(reservation, "Tags")
    for tag in tags:
        if find_value(tag, "Key") == "Name": return find_value(tag, "Value")

def start_ec2(ec2, targetname):
    ec2info = ec2.describe_instances()
    for reservation in ec2info['Reservations']:
        instanceId = find_value(reservation, "InstanceId")
        if targetname == getNameTag(reservation):
            if status_check(instanceId, ec2) == 'stopped':
                ec2.start_instances(
                    InstanceIds = [instanceId],
                    DryRun = False
                )

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    create_endpoint(ec2, "ec2")
    create_endpoint(ec2, "ssm")
    create_endpoint(ec2, "ssmmessages")
    create_endpoint(ec2, "ec2messages")
    start_ec2(ec2, "session-manager")
    start_ec2(ec2, "vpn")
