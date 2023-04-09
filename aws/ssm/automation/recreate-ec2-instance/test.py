#!/usr/bin/env python3

import boto3
import json

if __name__ == '__main__':
    image_id = 'ami-007c31053547c7ee5'
    instance_id = 'i-0333ac8c7e4b9e1e9'
    name_tag = 'recreate'
    tag_info = {}

    ec2 = boto3.client('ec2')
    # Get Information
    instance_data = ec2.get_launch_template_data(InstanceId = instance_id)['LaunchTemplateData']
    template_info = ec2.describe_launch_templates(
        Filters = [
            { 'Name': 'launch-template-name', 'Values': [name_tag] }
        ]
    )['LaunchTemplates']
    
    # Update template information
    instance_data['ImageId'] = image_id
    devices = ec2.describe_images(ImageIds=[image_id])['Images'][0]['BlockDeviceMappings']
    instance_data['BlockDeviceMappings'] = []
    for device in devices:
        if 'Ebs' in device:
            instance_data['BlockDeviceMappings'].append(device)
    
    # Get the tag information
    instance_detail = ec2.describe_instances(InstanceIds = [instance_id])['Reservations'][0]['Instances'][0]
    ## EBS Tag
    volume_id_list = [volume['Ebs']['VolumeId'] for volume in instance_detail['BlockDeviceMappings']]
    volume_details = ec2.describe_volumes(VolumeIds = volume_id_list)
    tag_info['volume'] = []
    for detail in volume_details['Volumes']:
        try:
            tag_info['volume'].append({ detail['Attachments'][0]['Device']: detail['Tags'] })
        except:
            pass

    ## Network Interfaces Tag
    nic_id_list = [nic['NetworkInterfaceId'] for nic in instance_detail['NetworkInterfaces']]
    nic_details = ec2.describe_network_interfaces(NetworkInterfaceIds = nic_id_list)
    tag_info['nic'] = []
    for detail in nic_details['NetworkInterfaces']:
        try:
            tag_info['nic'].append({ detail['Attachment']['DeviceIndex']: detail['TagSet'] })
        except:
            pass

    if len(template_info) == 0:
        ec2.create_launch_template(
            LaunchTemplateName = name_tag,
            VersionDescription = json.dumps(tag_info),
            LaunchTemplateData = instance_data
        )
    else:
        version = ec2.create_launch_template_version(
            LaunchTemplateName = name_tag,
            VersionDescription = json.dumps(tag_info),
            LaunchTemplateData = instance_data
        )['LaunchTemplateVersion']['VersionNumber']
        ec2.modify_launch_template(
            LaunchTemplateName = name_tag,
            DefaultVersion = str(version)
        )
