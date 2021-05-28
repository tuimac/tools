#!/bin/bash

aws cloudformation create-stack --stack-name lambdaFargate --region ap-northeast-1 --capabilities CAPABILITY_NAMED_IAM --template-body file://template.yml
