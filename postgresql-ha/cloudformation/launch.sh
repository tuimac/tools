#!/bin/bash

aws cloudformation create-stack --stack-name rhel-ha-dr --region ap-northeast-1 --capabilities CAPABILITY_NAMED_IAM --template-body file://template.yml
