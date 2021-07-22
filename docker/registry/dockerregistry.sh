#!/bin/bash

BUCKET_NAME='docker-registry-00'
STORAGE_PATH='/'`hostname`

function create_registry(){

    docker run -itd \
        --name registry \
        --restart=always \
        -e SETTINGS_FLAVOR=s3 \
        -e AWS_BUCKET=${BUCKET_NAME} \
        -e STORAGE_PATH=${STORAGE_PATH} \
        -p 5000:5000 \
        registry
}

function delete_registry(){
    docker stop registry
    docker rm registry
}

function userguide(){
    echo -e "usage: ./registry [create | delete]"
    echo -e "
optional arguments:
create		Deploy registry container.
delete		Delete registry container.
    "    
}

function main(){
    if [ $1 == 'create' ]; then
        create_registry
    elif [ $1 == 'delete' ]; then
        delete_registry
    else
        userguide
    fi
}

main $1
