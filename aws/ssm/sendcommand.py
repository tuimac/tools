#!/usr/bin/env python3

import boto3
import time
import traceback
import os

if __name__ == '__main__':

    try:
        ec2 = boto3.client('ec2')
        ssm = boto3.client('ssm')
        instance_ids = []
        command = 'sleep 10; exit 1;'

        instances = ec2.describe_instances(
            Filters = [{'Name': 'tag:Name', 'Values': ['amzn2']}]
        )['Reservations'][0]['Instances']

        for instance in instances:
            instance_ids.append(instance['InstanceId'])

        command_id = ssm.send_command(
            Targets = [{'Key': 'InstanceIds', 'Values': instance_ids}],
            DocumentName = 'AWS-RunShellScript',
            Parameters = {'commands': [command]}
        )['Command']['CommandId']
        
        complete_commands = []
        while len(complete_commands) == 0:
            complete_commands = ssm.list_commands(
                CommandId = command_id,
                Filters = [{'key': 'ExecutionStage', 'value': 'Complete'}]
            )['Commands']
            time.sleep(5)
        
        if complete_commands[0]['Status'] == 'Success':
            os._exit(0)
        else:
            os._exit(1)
    except:
        traceback.print_exc()
        os._exit(1)
