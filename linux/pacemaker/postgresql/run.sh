#!/bin/bash

function create(){
    sudo pcs resource create test ocf:heartbeat:test name=postgresql
    sudo pcs status
}

function delete(){
    sudo pcs resource delete test
    sudo pcs resource refresh test --node primary
    sudo pcs resource refresh test --node secondary
    sudo pcs status
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete]"
    echo -e "
optional arguments:
create              Create image and container after that run the container.
delete              Delete image and container.
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    if [ $1 == "create" ]; then
        create
    elif [ $1 == "delete" ]; then
        delete
    else
        { userguide; exit 1; }
    fi
}

main $1
