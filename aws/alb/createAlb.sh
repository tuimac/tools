#!/bin/bash

ALBNAME=''
TGNAME=''
VPCID='vpc-xxxxxxxxxxxxxxxx'
SECURITYGROUPID='sg-xxxxxxxxxxxxxxx'
SUBNETSID='subnet-xxxxxxxxxxxxx subnet-xxxxxxxxxxxxxxx'
TARGETSEC2=(i-xxxxxxxxxxxxxxxx)
SERVERPORT=80
SERVERPROTO='HTTP'
ALBPORT=80
ALBPROTO='HTTP'

function checkEnv(){
    jq --version > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo 'There is no jq on this machine. Install jq like "yum install -y jq".'
        exit 1
    else
        echo 'Confirm jq on this machine.'
    fi
}

function createTargetGroup(){
    local result=`aws elbv2 create-target-group \
        --name $TGNAME \
        --protocol $SERVERPROTO \
        --port $SERVERPORT \
        --vpc-id $VPCID \
        --health-check-protocol $SERVERPROTO \
        --health-check-port $SERVERPORT \
        --health-check-enabled \
        --health-check-path / \
        --health-check-interval-seconds 30 \
        --health-check-timeout-seconds 5 \
        --healthy-threshold-count 5 \
        --unhealthy-threshold-count 2 \
        --matcher HttpCode=200 \
        --target-type instance`
    
    TGARN=`echo $result | jq -r '.TargetGroups[] | .TargetGroupArn'`

    if [ $? -ne 0 ]; then
        echo 'Create target group is failed.'
        exit 1
    else
        echo 'Create target group is successed!'
    fi
}

function createAlb(){
    local result=`aws elbv2 create-load-balancer \
        --name $ALBNAME \
        --subnets $SUBNETSID \
        --security-groups $SECURITYGROUPID \
        --scheme internal \
        --type application \
        --ip-address-type ipv4 \
        --tags Key=Name,Value=$ALBNAME`
    
    ALBARN=`echo $result | jq -r '.LoadBalancers[] | .LoadBalancerArn'`

    if [ $? -ne 0 ]; then
        echo 'Create ALB is failed.'
        exit 1
    else
        echo 'Create ALB is successed!'
    fi
}

function createListener(){
    local result=`aws elbv2 create-listener \
        --load-balancer-arn $ALBARN \
        --protocol $ALBPROTO \
        --port $ALBPORT \
        --default-actions Type=forward,TargetGroupArn=$TGARN`

    if [ $? -ne 0 ]; then
        echo 'Create Listener is failed.'
        exit 1
    else
        echo 'Create Listener is successed!'
    fi
}

function registerTarget(){
    local targets=`aws ec2 describe-instances --filter 'Name=tag:Environment,Values=prod' | \
                    jq -r '.Reservations[].Instances[].InstanceId'`

    for instanceid in ${targets[@]}; do
        local result=`aws elbv2 register-targets \
            --target-group-arn $TGARN \
            --targets Id=$instanceid`

        if [ $? -ne 0 ]; then
            echo 'Add instance to target group is failed.'
            exit 1
        else
            echo 'Add '${instanceid}' to target group is successed!'
        fi
    done
}

function main(){
    checkEnv
    createTargetGroup
    createAlb
    createListener
    registerTarget
}

main
