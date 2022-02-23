#!/bin/bash

# Change variables below if you need
##############################
NAME="postgresql"
VOLUME="${PWD}/volume"
DATA='/var/lib/pgsql/data/userdata'
##############################

function runContainer(){
    podman run -itd --name ${NAME} \
                -v ${VOLUME}:${DATA}:Z \
                -v $(pwd)/etc:/etc/postgresql:Z \
                -v ${BACKUP}:/var/lib/pgsql/backup:Z \
                -e POSTGRESQL_USER=test \
                -e POSTGRESQL_PASSWORD=password \
                -e POSTGRESQL_DATABASE=test \
                -h ${NAME} \
                -p 5432:5432 \
                ${NAME}
}

function cleanup(){
    podman image prune -f
    podman container prune -f
}

function createContainer(){
    mkdir ${VOLUME}
    podman unshare chown 26:26 ${VOLUME}
    podman unshare chown 26:26 etc/
    podman login registry.redhat.io
    podman build -t ${NAME} .
    runContainer
}

function rerunContainer(){
    echo -en "Do you want to commit image? [y(default)/n]: "
    read answer
    if [ "$answer" != "n" ]; then
        commitImage ${NAME}
    fi
    podman stop ${NAME}
    podman rm ${NAME}
    runContainer
    cleanup
}

function deleteAll(){
    podman stop ${NAME}
    podman rm ${NAME}
    podman rmi ${NAME}
    cleanup
    sudo rm -rf ${VOLUME}
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
    elif [ $1 == "rerun" ]; then
        rerunContainer
    elif [ $1 == "delete" ]; then
        deleteAll
    elif [ $1 == "commit" ]; then
        commitImage ${NAME}
    elif [ $1 == "push" ]; then
        pushImage
    elif [ $1 == "help" ]; then
        userguide
    elif [ $1 == "register-secret" ]; then
        registerSecret
    else
        { userguide; exit 1; }
    fi
}

main $1
