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
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=['subnet-xxxxxxxx'],securityGroups=['sg-xxxxxx'],assignPublicIp='ENABLED'}" \
        --task-definition httptracker:2
}

function main(){
    register
    #runTask
}

main
