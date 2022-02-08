#!/bin/bash

INTERVAL='10'
SOURCE_ARN=''
DEST_ARN=''
LOGS_ARN=''

LOOP=$((60 / INTERVAL))

function create_task(){
    aws datasync create-task \
        --source-location-arn $SOURCE_ARN \
        --destination-location-arn $DEST_ARN \
        --cloud-watch-log-group-arn $LOGS_ARN \
        --name 'test-'${$1} \
        -schedule ${1}' * * * * *' \
        --options 'PreserveDeletedFiles=REMOVE,LogLevel=BASIC,TransferMode=ALL,OverwriteMode=ALWAYS'
}

function main(){
    for (( i=0; i<$LOOP; i++ )); do
        create_task $i
    done
}
#main
create_task
