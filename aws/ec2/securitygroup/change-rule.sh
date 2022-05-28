#!/bin/bash

SG_ID='sg-xxxxxxxxxxxxxxxxx'

aws ec2 revoke-security-group-ingress \
    --group-id ${SG_ID} \
    --protocol -1 \
    --port -1 \
    --cidr 58.13.158.154/32
