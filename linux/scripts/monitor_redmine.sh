#!/bin/bash

REDMINE_HOST='http://sample.com/'
REDMINE_API_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
TRACKER=''

function change_status(){
    local info=$(curl -H 'X-Redmine-API-Key:'$REDMINE_API_KEY $REDMINE_HOST/issues.json?issue_id=$1 | jq .)
    echo $info
    curl -v -X PUT -d '{"issue": {"status_id": "12"}}' -H 'Content-Type: application/json' -H 'X-Redmine-API-Key:'$REDMINE_API_KEY $REDMINE_HOST/issues/$1.json
}

function monitor(){
    while true; do
        local target=$(curl -H 'X-Redmine-API-Key:'$REDMINE_API_KEY $REDMINE_HOST/issues.json | jq -r '.issues[] | select(.status.name == "移送作業開始") | .id')
        for id in ${target// / }; do
            change_status $id
        done
        sleep 1
    done
}

function main(){
    monitor    
}

main
