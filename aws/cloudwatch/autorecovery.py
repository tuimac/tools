#!/usr/bin/env python3

import boto3
import traceback

def autorecovery(instanceId):
    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_alarm(
        AlarmName = 'AutoRecovery_SystemStatusCheck_' + instanceId,
        AlarmActions = ['arn:aws:automate:ap-northeast-1:ec2:recover'],
        MetricName = 'StatusCheckFailed_System',
        Namespace = 'AWS/EC2',
        Statistic = 'Average',
        Dimensions = [{'Name': 'InstanceId', 'Value': instanceId}],
        Period = 120,
        EvaluationPeriods = 2,
        Threshold = 1,
        ComparisonOperator = 'GreaterThanOrEqualToThreshold'
    )
    cloudwatch.put_metric_alarm(
        AlarmName = 'AutoRecovery_InstanceStatusCheck_' + instanceId,
        AlarmActions = ['arn:aws:automate:ap-northeast-1:ec2:reboot'],
        MetricName = 'StatusCheckFailed_Instance',
        Namespace = 'AWS/EC2',
        Statistic = 'Average',
        Dimensions = [{'Name': 'InstanceId', 'Value': instanceId}],
        Period = 120,
        EvaluationPeriods = 2,
        Threshold = 1,
        ComparisonOperator = 'GreaterThanOrEqualToThreshold'
    )

def lambda_handler(event, context):
    try:
        ec2 = boto3.client('ec2')
        if len(event['targets']) == 0:
            ec2List = ec2.describe_instances()['Reservations'][0]['Instances']
            for instance in ec2List:
                autorecovery(instance['InstanceId'])
        else:
            for instanceId in event['targets']:
                ec2.describe_instances(InstanceIds=[instanceId])
                autorecovery(instanceId)
    except:
        traceback.print_exc()

if __name__ == '__main__':
    event = {
        'targets': []
    }
    context = ''

    lambda_handler(event, context)
