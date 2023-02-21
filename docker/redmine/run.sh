#!/bin/bash

function runContainer(){
    mkdir -p redmine/{files,logs,plugins,config}
    sudo chown 999:999 -R redmine/
    docker-compose up -d
    docker ps -a
}

function cleanup(){
    docker image prune -f
    docker container prune -f
}

function createContainer(){
    runContainer
    cleanup
}

function deleteAll(){
    docker-compose down
    sudo rm -rf mysql/
    sudo rm -rf redmine/
    cleanup
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
        createContainer
    elif [ $1 == "delete" ]; then
        deleteAll
    elif [ $1 == "help" ]; then
        userguide
    else
        { userguide; exit 1; }
    fi
}

main $1
