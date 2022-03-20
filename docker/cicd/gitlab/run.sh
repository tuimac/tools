#!/bin/bash

function create(){
    docker-compose up -d
}

function delete(){
    docker-compose down
}

function main(){
    [[ -z $1 ]] && { echo 'Error raised!!'; exit 1; }
    if [ $1 == "create" ]; then
        create
    elif [ $1 == "delete" ]; then
        delete
    fi
}

main $1
