#!/bin/bash

REGION='ap-northeast-3'

function ubuntu-install(){
    wget https://s3.${REGION}.amazonaws.com/amazoncloudwatch-agent-${REGION}/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb
    dpkg -i -E ./amazon-cloudwatch-agent.deb
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m onPremise -s -c ssm:home
}

function main(){
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
    ubuntu-install
}

main
