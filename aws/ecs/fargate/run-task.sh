#!/bin/bash

NAME='httptracker'

function register(){
    aws ecs register-task-definition \
        --cli-input-json file://httptracker-task.json
}

function runTask(){
    aws ecs run-task \
        --cluster 'test' \
        --count 1 \
        --launch-type EC2 \
        --network-configuration "awsvpcConfiguration={subnets=['subnet-xxxxxxxx'],securityGroups=['sg-xxxxxx'],assignPublicIp='ENABLED'}" \
        --task-definition test:6
}

function main(){
    register
    #runTask
}

main
