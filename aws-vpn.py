#This program execute on python2.7.15 x86
#Use this after 'aws configure'

#!/usr/bin/env python

import json
import boto3
import sys
import os
import time
import subprocess

#Search specific value of some json
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

#Check execution authority
def check_auth():
    if os.geteuid() != 0:
        args = ['sudo', sys.executable] + sys.argv + [os.environ]
        os.execlpe('sudo', *args)

#Get EC2's Name Tag.
def getNameTag(reservation):
    tags = find_value(reservation, "Tags")
    for tag in tags:
        if find_value(tag, "Key") == "Name": return find_value(tag, "Value")

#Get EC2's public IP address.
def getPublicIP(instanceId, ec2, index_of_instances, count=0):
    ec2info = ec2.describe_instances()
    publicip = find_value(ec2info['Reservations'][index_of_instances], "PublicIpAddress")

    if count >= 2:
        print "Get public IP is failed!!"
        exit(1)
    if publicip is None:
        count += 1
        getPublicIP(instanceId, ec2, index_of_instances, count)
    return publicip

#Get status informantion from Json file.
def status_check(instanceId, ec2):
    response = ec2.describe_instance_status(
        InstanceIds = [instanceId],
        DryRun = False,
        IncludeAllInstances = True
    )
    status = find_value(find_value(response, "InstanceState"), "Name")
    return status

#Start EC2
def start_ec2(instanceId, ec2):
    ec2.start_instances(
        InstanceIds = [instanceId],
        DryRun = False
    )

    #Checking status of instance which had started before
    for i in range(10):
        if status_check(instanceId, ec2) == "running": 
            print "Start instance is success..."
            return
        time.sleep(3)
    return

#Replace publicIP for VPN by nmcli
def replace_publicIP(ip, vpn_name, port="1194"):
    new_value = ip + ":" + port
    replaceip_command="nmcli connection modify " + vpn_name + " +vpn.data remote=" + new_value
    subprocess.call(replaceip_command.split())
    return

#Start target EC2 after replace public ip
def start_vpn(publicIP, vpn_name):
    replace_publicIP(publicIP, vpn_name)
    startvpn_command = 'nmcli connection up id ' + vpn_name
    subprocess.call(startvpn_command.split())
    return

#Create EC2 Endpoint
def create_endpoint(ec2, service_name):
    service_name = "com.amazonaws.ap-northeast-1." + service_name
    for endpoint_name in [find_value(name, "ServiceName") for name in ec2.describe_vpc_endpoints()["VpcEndpoints"]]:
        if endpoint_name == service_name:
            print "Already have " + service_name
            return
    response = ec2.create_vpc_endpoint(
        DryRun = False,
        VpcEndpointType = 'Interface',
        VpcId = 'vpc-xxxxxxxxxxxxx',
        ServiceName = service_name,
        SubnetIds = [
            'subnet-xxxxxxxxxxxxxxx',
        ],
        SecurityGroupIds = [
            'sg-xxxxxxxxxxxxxxxxxxx',
        ],
        PrivateDnsEnabled = True
    )
    return

#Main
if __name__ == '__main__':

    check_auth()

    #Target TAG_NAME for specific EC2 instance
    TAG_NAME = "vpn"
    publicIP = ""
    VPN_NAME="tuimac"

    #Create EC2 Client
    ec2 = boto3.client('ec2')
    ec2info = ec2.describe_instances()

    #which information of instances is in "ec2info"'s json data
    index_of_instances = 0

    #Start EC2 which have 'VPN' name tag
    for reservation in ec2info['Reservations']:
        
        instanceId = find_value(reservation, "InstanceId")

        #Start instance and Get Public IP address
        if TAG_NAME == getNameTag(reservation):
            if status_check(instanceId, ec2) == 'stopped':
                start_ec2(instanceId, ec2)
            publicIP = getPublicIP(instanceId, ec2, index_of_instances)

        index_of_instances += 1

    #Start VPN
    start_vpn(publicIP, VPN_NAME)

    #Create EC2 endpoint
    create_endpoint(ec2, "ec2")
    create_endpoint(ec2, "sqs")
