#!/bin/bash

INTERVAL='10'
SOURCE_ARN=''
DEST_ARN=''
LOGS_ARN=''

LOOP=$((60 / INTERVAL))

function create_task(){
    set -f
    local name='test-'${1}
    local schedule='ScheduleExpression="cron('${1}' * * * ? *)"'
    echo $schedule
    aws datasync create-task \
        --source-location-arn $SOURCE_ARN \
        --destination-location-arn $DEST_ARN \
        --cloud-watch-log-group-arn $LOGS_ARN \
        --name $name \
        --schedule "$schedule" \
        --options 'PreserveDeletedFiles=REMOVE,LogLevel=TRANSFER,VerifyMode=ONLY_FILES_TRANSFERRED,OverwriteMode=ALWAYS'
}

function main(){
    for (( i=0; i<$LOOP; i++ )); do
	local interval=$((i * INTERVAL))
        create_task $interval
    done
}
main
