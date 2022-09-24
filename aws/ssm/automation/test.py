#!/usr/bin/env python3

import boto3
import datetime
import json

def stub(ec2):
    instance_ids = []
    reservations = ec2.describe_instances(
        Filters = [
            {
                'Name': 'tag:AutoBackup',
                'Values': ['yes']
            }
        ]
    )['Reservations']
    for reservation in reservations:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])
    return instance_ids

if __name__ == '__main__':
    # Initialization
    ec2 = boto3.client('ec2')
    instance_ids = stub(ec2)
    generations = 2
    now = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')

    for instance_id in instance_ids:
        # Get EC2 Instance Name tag value
        tags = ec2.describe_tags(
            Filters = [
                {'Name': 'resource-id', 'Values': [instance_id]}
            ]
        )['Tags']
        name_tag = [tag['Value'] for tag in tags if tag['Key'] == 'Name'][0]

        # Create Image
        image_name = name_tag + '-' + now
        ec2.create_image(
            InstanceId = instance_id,
            Name = image_name,
            NoReboot = True,
            TagSpecifications  =  [
                {
                    'ResourceType': 'image',
                    'Tags': [
                        {'Key': 'Name', 'Value': image_name},
                        {'Key': 'AutoBackup', 'Value': 'yes'},
                        {'Key': 'Name_Tag', 'Value': name_tag}
                    ]
                },
                {
                    'ResourceType': 'snapshot',
                    'Tags': [
                        {'Key': 'Name', 'Value': image_name},
                        {'Key': 'AutoBackup', 'Value': 'yes'},
                        {'Key': 'Name_Tag', 'Value': name_tag}
                    ]
                }
            ]
        )

        # Delete old images
        images = ec2.describe_images(
            Filters = [
                {'Name': 'tag:AutoBackup', 'Values': ['yes']},
                {'Name': 'tag:Name_Tag', 'Values': [name_tag]}
            ]
        )['Images']
        delete_images = sorted(
            images,
            key = lambda image: datetime.datetime.strptime(image['CreationDate'], '%Y-%m-%dT%H:%M:%S.%fZ'),
        )[0:-2]
        
        # Delete old snapshots
        for image in delete_images:
            snapshot_ids = [snapshots['Ebs']['SnapshotId'] for snapshots in image['BlockDeviceMappings']]
            ec2.deregister_image(ImageId=image['ImageId'])
            for snapshot_id in snapshot_ids:
                ec2.delete_snapshot(SnapshotId=snapshot_id)
