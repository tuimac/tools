#!/usr/bin/env python3

import boto3
import json

if __name__ == '__main__':
    instance_id = 'i-05227056247327811'
    tag_data = {"image": "ami-09dede1f111e1a7de", "volume": {"/dev/xvda": [{"Key": "Name", "Value": "test"}], "/dev/xvdb": [{"Key": "Name", "Value": "test"}]}, "nic": {"0": [{"Key": "Name", "Value": "test"}]}}
    ec2 = boto3.client('ec2')
    ec2_info = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]
    # AMI tag
    image_name = ec2.describe_images(ImageIds=[tag_data['image']])['Images'][0]['Name']
    ec2.create_tags(
        Resources = [tag_data['image']],
        Tags = [{ 'Key': 'Name', 'Value': image_name }]
    )

    # Volume tag
    for target in tag_data['volume']:
        for device_info in ec2_info['BlockDeviceMappings']:
            if target == device_info['DeviceName']:
                ec2.create_tags(
                    Resources = [device_info['Ebs']['VolumeId']],
                    Tags = tag_data['volume'][target]
                )

    # Network Interface tag
    for target in tag_data['nic']:
        for nic_info in ec2_info['NetworkInterfaces']:
            if target == str(nic_info['Attachment']['DeviceIndex']):
                ec2.create_tags(
                    Resources = [nic_info['NetworkInterfaceId']],
                    Tags = tag_data['nic'][target]
                )
