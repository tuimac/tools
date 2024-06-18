#!/bin/bash

STACK_NAME='dev-server'
REGION='ap-northeast-3'
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
MYIP=$(curl inet-ip.info)

echo $MYIP

aws cloudformation create-stack --stack-name ${STACK_NAME} --region ${REGION} --capabilities CAPABILITY_NAMED_IAM --template-body file://${SCRIPT_DIR}/template.yml --disable-rollback --parameters ParameterKey=MyIP,ParameterValue=${MYIP}