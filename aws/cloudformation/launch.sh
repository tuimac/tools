#!/bin/bash

[[ -z $1 ]] && { echo 'Need template file name!!'; exit 1; }

aws cloudformation create-stack --stack-name tuimac-network --region ap-northeast-3 --capabilities CAPABILITY_NAMED_IAM --template-body file://$1
