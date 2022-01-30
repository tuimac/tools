#!/bin/bash

RELEASE='stable-6826'

function runContainer(){
    curl -L https://github.com/jitsi/docker-jitsi-meet/archive/refs/tags/stable-6826.tar.gz -o ${RELEASE}.tar.gz
    tar xvzf ${RELEASE}.tar.gz
    cd docker-jitsi-meet-${RELEASE}
    cp ../env .env
    mkdir -p ~/.jitsi-meet-cfg/{web/crontabs,web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
    ./gen-passwords.sh
    docker-compose up -d
    cd ..
    docker build -t tuimac/jitsi-ssl .
    docker run -itd \
        -p 443:443 \
        --name jitsi-ssl \
        -v $(pwd)/letsencrypt:/etc/letsencrypt \
        tuimac/jitsi-ssl
}

function cleanup(){
    docker image prune -f
    docker container prune -f
}

function createContainer(){
    runContainer
    #cleanup
}

function deleteAll(){
    cd docker-jitsi-meet-${RELEASE}
    docker-compose down
    docker stop jitsi-ssl
    docker rm jitsi-ssl
    docker rmi tuimac/jitsi-ssl
    docker rmi jitsi/jvb:${RELEASE}
    docker rmi jitsi/jicofo:${RELEASE}
    docker rmi jitsi/prosody:${RELEASE}
    docker rmi jitsi/web:${RELEASE}
    docker rmi jitsi/jibri:${RELEASE}
    docker rmi jitsi/jigasi:${RELEASE}
    cleanup
    sudo rm -rf ~/.jitsi-meet-cfg
    cd ..
    sudo rm -rf docker-jitsi-meet-${RELEASE}/
    rm ${RELEASE}.tar.gz
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
