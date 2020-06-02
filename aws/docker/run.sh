#!/bin/bash

NAME="test-aws"
VOLUME="${PWD}/volume"

function delete_docker(){
    docker stop ${NAME}
    docker rm ${NAME}
    docker rmi ${NAME}
    docker image prune -f
    rm -rf ${VOLUME}
}

function create_docker(){
    mkdir ${VOLUME}
    docker build -t ${NAME} .
    docker run -itd --name ${NAME} \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                -v "/usr/bin/docker:/usr/bin/docker" \
                -v "${VOLUME}:/tmp" \
                ${NAME} /bin/bash
}

function main(){
    [[ -z $1 ]] && { echo "Need argument which is 'create' or 'delete'."; exit 1; }
    if [ $1 == "create" ]; then
        create_docker
    elif [ $1 == "delete" ]; then
        delete_docker
    else
        { echo "Need argument which is 'create' or 'delete'."; exit 1; }
    fi
}

main $1




















































