#!/bin/bash

INSTANCE_ID=(
    'i-038aa52f36b1d916a'
    'i-06f1ecafe0859f9dc'
)

echo $(echo ${INSTANCE_ID[@]} | awk 'gsub(" ", ",")')
aws ec2 stop-instances --instance-ids $INSTANCE_ID
