#!/bin/bash

# Change variables below if you need
##############################
NAME='389ds'
DATA=${PWD}'/data'
CONFIG=${PWD}'/config'
LOGS=${PWD}'/logs'
CERTS=${PWD}'/certs'
HOST_NAME='ldap.tuimac.com'
##############################

function runContainer(){
    podman run -itd --name ${NAME} \
                -p 389:3389 \
                -p 636:3636 \
                ${NAME}
}

function cleanup(){
    podman image prune -f
    podman container prune -f
}

function createContainer(){
    podman build -t ${NAME} .
    runContainer
}

function deleteAll(){
    podman stop ${NAME}
    podman rm ${NAME}
    podman rmi ${NAME}
    cleanup
}

function commitImage(){
    podman stop ${NAME}
    podman commit ${NAME} $1
    podman start ${NAME}
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete | commit | register-secret]"
    echo -e "
optional arguments:
create              Create image and container after that run the container.
rerun               Delete only container and rerun container with new settings.
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
