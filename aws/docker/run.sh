#!/bin/bash

NAME="aws-test"
VOLUME="${PWD}/volume"

function deleteAll(){
    docker stop ${NAME}
    docker rm ${NAME}
    docker rmi ${NAME}
    docker image prune -f
    rm -rf ${VOLUME}
}

function createContainer(){
    mkdir ${VOLUME}
    docker build -t ${NAME} .
    docker run -itd --name ${NAME} \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                -v "/usr/bin/docker:/usr/bin/docker" \
                -v "${VOLUME}:/tmp" \
                ${NAME} /bin/bash
}

function commitImage(){
    docker stop ${NAME}
    docker commit ${NAME} ${NAME}
    docker start ${NAME}
}

function main(){
    local message="Need argument which is 'create', 'commit' or 'delete'."
    [[ -z $1 ]] && { echo $message; exit 1; }
    if [ $1 == "create" ]; then
        createContainer
    elif [ $1 == "delete" ]; then
        deleteAll
    elif [ $1 == "commit" ]; then
        commitImage
    else
        { echo $message; exit 1; }
    fi
}

main $1
