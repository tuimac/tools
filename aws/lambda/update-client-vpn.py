#!/usr/bin/env python3

import boto3
import datetime
import os

def create_client_vpn(ec2, today) -> dict:
    response = ec2.create_client_vpn_endpoint(
        ClientCidrBlock = os.environ['CIDR'],
        ServerCertificateArn = os.environ['SERVER_CERT_ARN'],
        AuthenticationOptions = [
            {
                'Type': 'certificate-authentication',
                'MutualAuthentication': {
                    'ClientRootCertificateChainArn': os.environ['CLIENT_CERT_ARN']
                }
            }
        ],
        ConnectionLogOptions = {
            'Enabled': True,
            'CloudwatchLogGroup': os.environ['LOGS_GROUP'],
            'CloudwatchLogStream': os.environ['LOGS_STREAM']
        },
        DnsServers 
    )

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    today = datetime.datetime.today().strftime('%Y%m%d')
    
    create_client_vpn(ec2, today)
