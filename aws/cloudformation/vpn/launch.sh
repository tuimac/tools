#!/bin/bash

STACK_NAME='aws-client-vpn'
REGION='ap-northeast-3'

aws cloudformation create-stack --stack-name ${STACK_NAME} --region ${REGION} --capabilities CAPABILITY_NAMED_IAM --template-body file://template.yml
