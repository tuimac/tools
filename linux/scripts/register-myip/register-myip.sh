#!/bin/bash

INTERVAL=10
SECURITY_GROUP_NAME="Public"
REGION=$(aws configure get region)

function entry_ingress_rule() {
    local sg_id=$(aws ec2 describe-security-groups \
      --region "$REGION" \
      --filters Name=group-name,Values="$SECURITY_GROUP_NAME" \
      --query 'SecurityGroups[0].GroupId' \
      --output text)

    if [[ -z "$sg_id" || "$sg_id" == "None" ]]; then
      echo "Security group not found: $SECURITY_GROUP_NAME" >&2
      return 1
    fi
    local current_permission=$(aws ec2 describe-security-groups \
      --region "$REGION" \
      --group-ids "$sg_id" \
      --query 'SecurityGroups[0].IpPermissions' \
      --output json)

    if [[ "$current_permission" != "[]" ]]; then
      aws ec2 revoke-security-group-ingress \
        --region "$REGION" \
        --group-id "$sg_id" \
        --ip-permissions "$current_permission"

      echo "Deleted all current ingress rules."
    else
      echo "No ingress rules to delete."
    fi
    echo "My IP is ${MYIP}"
    aws ec2 authorize-security-group-ingress \
      --region "$REGION" \
      --group-id "$sg_id" \
      --ip-permissions "[{\"IpProtocol\":\"-1\",\"IpRanges\":[{\"CidrIp\":\"$MYIP/32\"}]}]"
    local result=$?
    if [ $result -ne 0 ]; then
        return $result
    fi
    echo "Added new ingress rule."
}

function register_myip_to_aws() {
    MYIP=$(curl http://checkip.amazonaws.com/)
    local result=$?
    if [ $result -ne 0 ]; then
        return $result
    fi
    aws ssm put-parameter \
        --name "/tuimac/network/laptop/myip" \
        --value ${MYIP} \
        --type "String" \
        --overwrite
    local result=$?
    if [ $result -ne 0 ]; then
        return $result
    fi
}

function main() {
    aws --version
    if [ $? -ne 0 ]; then
        echo "There is no AWS CLI in this machine."
        exit 1
    fi
    while true; do
        register_myip_to_aws
        if [ $? -ne 0 ]; then
            echo "Fail to register myip to AWS"
        fi
        entry_ingress_rule
        if [ $? -ne 0 ]; then
            echo "Fail to entry myip to AWS Security Group ingress rule"
        else
            break
        fi
        sleep $INTERVAL
    done
}

main
