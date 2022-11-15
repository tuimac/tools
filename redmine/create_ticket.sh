#!/bin/bash

# Fixed variable
API_KEY=''
INTERVAL=1
POLLING_TIME=60
PROJECT='test'
URL='http://localhost:8003'

function create_child_ticket(){
    local issue_id=$1
    local payload=$(echo {})
    
    payload=$(echo $payload | jq '.issue.project_id = 2')
    payload=$(echo $payload | jq '.issue.tracker_id = 6')
    payload=$(echo $payload | jq '.issue.priority_id = 1')
    payload=$(echo $payload | jq '.issue.subject = "testtest"')
    payload=$(echo $payload | jq --arg issue_id $issue_id '.issue.parent_id = $issue_id')
    payload=$(echo $payload | jq '.issue.custom_fields = []')
    payload=$(echo $payload | jq '.issue.custom_fields |= .+[{"id": 9, "value": 5}]')
    echo $payload | jq > sample.json
    echo $payload

    curl -X POST -d @sample.json -H 'Content-Type: application/json' -H 'X-Redmine-API-Key:'${API_KEY} ${URL}/issues.json

    rm sample.json
}

function monitor_tracker(){
    local issue_id_list=($(curl -X GET -H X-Redmine-API-Key:${API_KEY} ${URL}/projects/${PROJECT}/issues.json?limit=10 | \
        jq -sr '.[].issues[] | select(.tracker.name == "test") | .id'
    ))
    for issue_id in ${issue_id_list[@]}; do
        local result=$(curl -X GET -H X-Redmine-API-Key:${API_KEY} ${URL}/issues/${issue_id}.json?include=children | \
            jq -sr '.[].issue.children'
        )
        if [[ $result == 'null' ]]; then
            create_child_ticket $issue_id
        fi
    done
}


function main(){
    #monitor_tracker
    create_child_ticket 15
    #for((i=0; i < $POLLING_TIME; i+=$INTERVAL)); do
          
    #done
}

main

