#!/bin/bash

ARN=''

aws elbv2 modify-listener --listener-arn ${ARN} \
    --default-action '[
        {
            "Type": "forward",
            "ForwardConfig": {
                "TargetGroups": [
                    {
                        "TargetGroupArn": "",
                        "Weight": 0
                    },{
                        "TargetGroupArn": "",
                        "Weight": 1
                    }
                ],
                "TargetGroupStickinessConfig": {
                    "Enabled": false
                }
            }
        }
    ]'
