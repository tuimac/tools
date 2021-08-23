#!/bin/bash

aws iam list-policies | jq -r '.Policies[].Arn' | while read line; do
    if [[ $line =~ 'start-pipeline' ]]; then
        echo 'Delete '${line}
        aws iam delete-policy --policy-arn $line
    fi
done
