#!/usr/bin/env python3

import boto3
import traceback

IPS=[
    '10.0.0.5',
    '10.0.0.6'
]
SUBNET=''
FLAG='delete'

def delete_interfaces(ec2):
    for ip in IPS:
        try:
            targets = ec2.describe_network_interfaces(
                Filters = [
                    { 'Name': 'subnet-id', 'Values': [SUBNET] },
                    { 'Name': 'addresses.private-ip-address', 'Values': IPS }
                ]
            )['NetworkInterfaces']
            for target in targets:
                ec2.delete_network_interface(
                    NetworkInterfaceId = target['NetworkInterfaceId']
                )
        except:
            traceback.print_exc()

def create_interfaces(ec2):
    for ip in IPS:
        try:
            ec2.create_network_interface(
                PrivateIpAddress = ip,
                SubnetId = SUBNET
            )
        except:
            traceback.print_exc()

if __name__ == '__main__':
    ec2 = boto3.client('ec2')

    if FLAG == 'create':
        create_insterfaces(ec2)
    elif FLAG == 'delete':
        delete_interfaces(ec2)
    else:
        pass
