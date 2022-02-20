#!/bin/bash

function create(){
    sudo pcs resource create test ocf:heartbeat:test name=postgresql user=ec2-user
    sudo pcs status
}

function delete(){
    sudo pcs resource delete test
    sudo pcs resource refresh test --node primary
    sudo pcs resource refresh test --node secondary
    sudo pcs status
}

function deploy(){
    sudo cp test /usr/lib/ocf/resource.d/heartbeat/test
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
    else
        { userguide; exit 1; }
    fi
}

main $1
