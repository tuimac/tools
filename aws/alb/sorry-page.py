#!/usr/bin/env python3

import boto3

def lambda_handler(event, context):
    elbv2 = boto3.client('elbv2')
    elbv2.create_rule(
            ListenerArn = '',
        Conditions = [
            {
                'Field': 'path-pattern',
                'Values': ['*']
            }
        ],
        Priority = 1,
        Actions = [
            {
                'Type': 'fixed-response',
                'Order': 1,
                'FixedResponseConfig': {
                    'MessageBody': '<h1>Sorry!</h1>',
                    'StatusCode': '503',
                    'ContentType': 'text/html'
                }
            }
        ]
    )

lambda_handler('test', 'test')
