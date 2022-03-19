#!/bin/bash

function create(){
    docker-compose up -d
    sudo chown 999:999 -R postgresql/logs
    sudo chown 101:101 -R nginx/logs
    sudo chown 101:101 -R nginx/webapps
}

function delete(){
    docker-compose down
    sudo chown $USER:$USER -R postgresql/logs
    sudo chown $USER:$USER -R nginx/logs
    sudo chown $USER:$USER -R nginx/webapps
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
