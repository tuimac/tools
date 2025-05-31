#!/bin/bash

function create(){
    docker-compose build --no-cache
    docker-compose up -d
}

function delete(){
    docker-compose down
}

function deleteall(){
    docker-compose down --rmi all --volumes --remove-orphans
}

function recreate() {
    delete
    create
}

function recreateall() {
    deleteall
    create
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
    elif [ $1 == "deleteall" ]; then
        deleteall
    elif [ $1 == "recreate" ]; then
        recreate
    elif [ $1 == "recreateall" ]; then
        recreateall
    elif [ $1 == "help" ]; then
        userguide
    else
        { userguide; exit 1; }
    fi
}

main $1
