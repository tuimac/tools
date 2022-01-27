#!/bin/bash

function runContainer(){
    git clone https://github.com/jitsi/docker-jitsi-meet
    cd docker-jitsi-meet
    cp ../env .env
    mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody,jicofo,jvb}
    ./gen-passwords.sh
    docker-compose up -d
    cd ..
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
    cd docker-jitsi-meet
    docker-compose down
    docker rmi jitsi/jvb
    docker rmi jitsi/jicofo
    docker rmi jitsi/prosody
    docker rmi jitsi/web
    cleanup
    sudo rm -rf ~/.jitsi-meet-cfg
    cd ..
    sudo rm -rf docker-jitsi-meet/
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
    elif [ $1 == "register-secret" ]; then
        registerSecret
    else
        { userguide; exit 1; }
    fi
}

main $1
