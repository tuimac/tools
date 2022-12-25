#!/bin/bash

API_KEY=''
INTERVAL=5
POLLING_TIME=60
TICKET_CREATION_INTERVAL=0.5
PROJECT='test'
URL='http://localhost:8003'
PARENT_TRACKER_IDS=(1)

function create

function monitor_ticket(){
    TICKET_INFO=$(curl -X GET -H X-Redmine-API-Key:${API_KEY} ${URL}/projects/${PROJECT}/issues.json?limit=100)
    PARENT_IDS=$(echo $TICKET_INFO | jq -sr '.[].issues[] | select(.parent.id != null) | .parent.id')
    for id in ${PARENT_TRACKER_IDS[@]}; do
        TARGET_IDS=$(echo $TICKET_INFO | jq -sr --argjson id "$id" '.[].issues[] | select(.tracker.id == $id) | .id')
        for target_id in ${TARGET_IDS[@]}; do
            if [[ $(printf '%s\n' "${PARENT_IDS[@]}" | grep -qx $target_id; echo -n $?) -ne 0 ]]; then
                echo $target_id
            fi
        done
    done
}

function start_monitor_ticket(){
    for((i=0; $i < $POLLING_TIME; i++)); do
        monitor_ticket
        sleep $INTERVAL
    done
}

function main(){
    start_monitor_ticket
}

main
