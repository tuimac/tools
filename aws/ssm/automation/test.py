#!/usr/bin/env python3

import boto3

ssm = boto3.client('ssm')
result = ssm.describe_automation_executions(
    Filters = [
        {
            'Key': 'ExecutionId',
            'Values': ['1dfbd695-f79a-4e03-8f4b-04588b52e277']
        }
    ]
)

print(result)
