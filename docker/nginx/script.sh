#!/bin/bash

ARN='arn:aws:elasticloadbalancing:ap-northeast-1:002310297599:listener/app/test/d2f28a34dd9895c8/6cd0662d72227bbd'

aws elbv2 modify-listener --listener-arn ${ARN} \
    --default-action '[
        {
            "Type": "forward",
            "ForwardConfig": {
                "TargetGroups": [
                    {
                        "TargetGroupArn": "arn:aws:elasticloadbalancing:ap-northeast-1:002310297599:targetgroup/test-a/36a7b15cc9a23cdb",
                        "Weight": 0
                    },{
                        "TargetGroupArn": "arn:aws:elasticloadbalancing:ap-northeast-1:002310297599:targetgroup/test-c/fb9d2ef9b81c9a7b",
                        "Weight": 1
                    }
                ],
                "TargetGroupStickinessConfig": {
                    "Enabled": false
                }
            }
        }
    ]'
