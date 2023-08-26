import json
import boto3
import traceback

def start_container(instance_ids):
    command = 'su ec2-user "podman start test"'
    ssm = boto3.client('ssm')
    ssm.sendcommand(
        InstanceIds = instance_ids,
        DocumentName = 'AWS-RunShellScript',
        Parameters = {'commands': [command]}
    )
    
    
def lambda_handler(event, context):
    try:
        tg_arn = 'arn:aws:elasticloadbalancing:ap-northeast-3:409826931222:targetgroup/test/efaed04e3f1458fd'
        recovery_targets = []
        
        ec2 = boto3.client('ec2')
        elbv2 = boto3.client('elbv2')
        
        
        targets = elbv2.describe_target_health(TargetGroupArn=tg_arn)['TargetHealthDescriptions']
        for target in targets:
            if target['TargetHealth']['State'] == 'unhealthy':
                recovery_targets.append(target['Target']['Id'])
                
        reservations = ec2.describe_instances(
            InstanceIds = recovery_targets
        )['Reservations']
        print(recovery_targets)
        ec2.stop_instances(
            InstanceIds = recovery_targets
        )
        
        waiter = ec2.get_waiter('instance_stopped')
        waiter.wait(InstanceIds=targets)

        ec2.start_instances(
            InstanceIds = recovery_targets
        )
        
        waiter = ec2.get_waiter('instance_status_ok')
        waiter.wait(InstanceIds=targets)    
        
        start_container(recovery_targets)
        
    except:
        traceback.print_exc()
