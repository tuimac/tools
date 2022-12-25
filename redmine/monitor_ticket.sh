#!/bin/bash

API_KEY='aa708e193b32b1f6dd9c8595b94e2ec9555a4011'
INTERVAL=5
POLLING_TIME=60
PROJECT='test'
TARGET_TRACKER_ID=
URL='http://localhost:8003'


function monitor_ticket(){
    for(($i=0; i < $POLLING_TIME; i++)); do
        CHILDREN_TICKET_INFO=$(curl -X GET -H X-Redmine-API-Key:${API_KEY} ${URL}/projects/${PROJECT}/issues.json?limit=10&)
    done
}

fuction main(){
    monitor_ticket
}

main
