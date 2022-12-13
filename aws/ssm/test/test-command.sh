#!/bin/bash

aws ssm send-command \
    --document-name AWS-RunShellScript \
    --target 'Key=tag:Target,Values=yes' \
    --parameters 'commands=["sed -i \"s/cache_credentials \= True/cache_credentials \= False/\" /etc/sssd/sssd.conf"]'
