#!/bin/bash

# Change variables below if you need
##############################
NAME="primary"
VOLUME="${PWD}/volume"
podmanHUBUSER="tuimac"
IMAGE=${podmanHUBUSER}/${NAME}
##############################

function runContainer(){
    DATA='/var/lib/postgresql/data'
    podman run -itd --name ${NAME} \
                -v ${VOLUME}:${DATA} \
                -v $(pwd)/etc:/etc/postgresql \
                -e POSTGRESQL_USER=test \
                -e POSTGRESQL_PASSWORD=password \
                -e POSTGRESQL_DATABASE=test \
                -h ${NAME} \
                -p 5432:5432 \
                ${NAME} \
                postgres -c config_file=/etc/postgresql/postgresql.conf \
                -c hba_file=/etc/postgresql/pg_hba.conf
    #podman stop ${NAME}
    #podman start ${NAME}
}

function cleanup(){
    podman image prune -f
    podman container prune -f
}

function createContainer(){
    mkdir ${VOLUME}
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
