#!/bin/bash

LOG='/home/ec2-user/test.log'

function start(){
    echo 'start' >> $LOG
}

function stop(){
    echo 'stop' >> $LOG
    for x in {1..30}; do
        echo $x >> $LOG
        sleep 1
    done
}

function main(){
    if [[ $1 == 'start' ]]; then
        start
    elif [[ $1 == 'stop' ]]; then
        stop
    else
        exit 1
    fi
}

main $1
