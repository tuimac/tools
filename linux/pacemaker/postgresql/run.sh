#!/bin/bash

PRIMARY_INS_ID='i-01c7de2d1b2eb836d'
CONTAINER='postgresql'

function create(){
    docker inspect $CONTAINER
    [[ $? -ne 0 ]] && { echo 'There is no container name is '$CONTAINER; exit 1; }
    docker start $CONTAINER
    sudo pcs resource create test ocf:heartbeat:test name=${CONTAINER} user=ec2-user instance_id=${PRIMARY_INS_ID}
    sudo pcs status
}

function delete(){
    sudo pcs resource delete test --force
    sudo pcs resource refresh test --node primary
    sudo pcs resource refresh test --node secondary
    sudo pcs status
}

function deploy(){
    sudo cp test /usr/lib/ocf/resource.d/heartbeat/test
    ls -l /usr/lib/ocf/resource.d/heartbeat/test
}

function start(){
    docker stop $CONTAINER
    docker ps -a
    while true; do
        sudo pcs status
        sleep 3
    done
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete]"
    echo -e "
optional arguments:
create              Create pcs resources.
delete              Delete pcs resources.
deploy              Copy ocf script to /usr/lib/ocf/resource.d/heartbeat
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    if [ $1 == "create" ]; then
        create
    elif [ $1 == "delete" ]; then
        delete
    elif [ $1 == "deploy" ]; then
        deploy
    elif [ $1 == "start" ]; then
        start
    else
        { userguide; exit 1; }
    fi
}

main $1
