#!/bin/bash

aws cloudformation create-stack --stack-name pacemaker --region ap-northeast-3 --capabilities CAPABILITY_NAMED_IAM --template-body file://template.yml
