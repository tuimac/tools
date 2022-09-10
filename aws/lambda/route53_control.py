#!/usr/bin/env python3

import boto3
import traceback
import re

HOSTED_ZONE = 'tuimac.com'

def validate_name_tag_value(name_tag_value) -> str:
    name_tag_value = name_tag_value.lower()
    fqdn_regex = '((?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9-])*(\.[a-zA-Z-]{2,63})*$))'

    if re.match(fqdn_regex, name_tag_value):
        return name_tag_value
    else:
        raise Exception('The format of Name Tag is wrong!!')

def get_ec2instance_info(instance_id, ec2) -> dict:
    result = dict()
    instance = ec2.describe_instances(
        InstanceIds = [instance_id]
    )['Reservations'][0]['Instances'][0]

    for tag in instance['Tags']:
        if tag['Key'] == 'Name':
            name_tag_value = tag['Value']
            break
    result['private_ip'] = instance['NetworkInterfaces'][0]['PrivateIpAddress']
    try:
        result['public_ip'] = instance['NetworkInterfaces'][0]['PrivateIpAddresses'][0]['Association']['PublicIp']
    except:
        traceback.print_exc()
        pass

    result['tag'] = name_tag_value

    return result

def validate_recordset(tag, hosted_zone_id, route53):
    target_fqdn = tag + '.' + HOSTED_ZONE + '.'

    records = route53.list_resource_record_sets(
        HostedZoneId = hosted_zone_id
    )['ResourceRecordSets']
    for record in records:
        if record['Name'] == target_fqdn and record['Type'] == 'A':
            raise Exception('There is same hostname!!')

def add_record(tag, hosted_zone_id, info, route53):
    route53.change_resource_record_sets(
        HostedZoneId = hosted_zone_id,
        ChangeBatch = {
            'Changes': [
                {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': tag + '.private.' + HOSTED_ZONE,
                        'Type': 'A',
                        'TTL': 30,
                        'ResourceRecords': [
                            {'Value': info['private_ip']}
                        ]
                    }
                }
            ]
        }
    )
    if 'public_ip' in info:
        route53.change_resource_record_sets(
            HostedZoneId = hosted_zone_id,
            ChangeBatch = {
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': tag + '.' + HOSTED_ZONE,
                            'Type': 'A',
                            'TTL': 30,
                            'ResourceRecords': [
                                {'Value': info['public_ip']}
                            ]
                        }
                    }
                ]
            }
        )

def delete_record(tag, hosted_zone_id, info, route53):
    route53.change_resource_record_sets(
        HostedZoneId = hosted_zone_id,
        ChangeBatch = {
            'Changes': [
                {
                    'Action': 'DELETE',
                    'ResourceRecordSet': {
                        'Name': tag + '.private.' + HOSTED_ZONE,
                        'Type': 'A',
                        'TTL': 30,
                        'ResourceRecords': [
                            {'Value': info['private_ip']}
                        ]
                    }
                }
            ]
        }
    )
    route53.change_resource_record_sets(
        HostedZoneId = hosted_zone_id,
        ChangeBatch = {
            'Changes': [
                {
                    'Action': 'DELETE',
                    'ResourceRecordSet': {
                        'Name': tag + '.' + HOSTED_ZONE,
                        'Type': 'A',
                        'TTL': 30,
                        'ResourceRecords': [
                            {'Value': info['public_ip']}
                        ]
                    }
                }
            ]
        }
    )

def lambda_handler(event, context)
    try:
        hosted_zone_id = ''
        ec2 = boto3.client('ec2')
        route53 = boto3.client('route53')
        state = event['detail']['state']
        instance_id = event['detail']['state']

        info = get_ec2instance_info(instance_id, ec2)
        tag = validate_name_tag_value(info['tag'])
        
        if state == 'running':
            validate_recordset(tag, hosted_zone_id, route53)
            add_record(tag, hosted_zone_id, info, route53)
        elif state == 'shutting-down':
            delete_record(tag, hosted_zone_id, info, route53)
        else:
            raise Exception('"' + state + '" is wrong!!')
    except:
        traceback.print_exc()
