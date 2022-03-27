#!/usr/bin/env python3

import boto3
'''
ec2 = boto3.client('ec2')
images = ec2.describe_images(
    Owners = [
        'self'
    ]
)['Images']
print(type(images))
images.sort(key=lambda sort_key: sort_key.get('CreationDate'), reverse=True)
print(images)
'''

retention = 3

nums = [1, 3, 5, 6, 8]
result = nums[retention:]
print(result)
