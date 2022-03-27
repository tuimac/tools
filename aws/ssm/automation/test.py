#!/usr/bin/env python3

import boto3

ssm = boto3.client('ssm')
ssm.start_automation_execution(
    DocumentName = 'AWS-DeleteImage',
    Parameters = {
        'ImageId': [
            'ami-0d82d5be06abc2cf8'
        ]
    }
)
