#This script is supported to run on Python 2.7 environment.

import json
import boto3
import sys
import os
import time
import subprocess
from datetime import date, datetime

#This variable is that you don't want to delete.
EXCEP_ENDPOINTID = "vpce-xxxxxxxxxxxxxxxxxx"

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

def delete_endpoint(ec2):
    for endpoint_id in [find_value(name, "VpcEndpointId") for name in ec2.describe_vpc_endpoints()["VpcEndpoints"]]:
        #Skip delete S3 endpoint
        if endpoint_id == EXCEP_ENDPOINTID: continue
        response = ec2.delete_vpc_endpoints(
            DryRun = False,
            VpcEndpointIds = [
                endpoint_id,    
            ]
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

def stop_ec2(ec2):
    ec2info = ec2.describe_instances()
    for reservation in ec2info['Reservations']:
        instanceId = find_value(reservation, "InstanceId")
        if status_check(instanceId, ec2) == 'running':
                ec2.stop_instances(
                    InstanceIds=[
                        instanceId,
                    ]
                )
    return

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    delete_endpoint(ec2)
    stop_ec2(ec2)
