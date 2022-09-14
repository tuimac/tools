#!/usr/bin/env python3

test = [2, 3, 5, 6]
print([i for i in test if i == 2])

    ec2 = boto3.client('ec2')
    tags = []

    reservations = ec2.describe_instances(
        Filters = [
            {
                'Name': 'tag:Test',
                'Values': ['yes']
            }
        ]
    )['Reservations']

    for reservation in reservations:
        for instance in reservation['Instances']:
            for tag in instance['Tags']:
                if tag['Key'] == 'Name':
                    tags.append(tag['Value'])
