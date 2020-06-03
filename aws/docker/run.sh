#!/bin/bash

NAME="aws-test"
VOLUME="${PWD}/volume"
DOCKERHUBUSER="tuimac"

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
    cat password.txt | docker login --username ${DOCKERHUBUSER} --password-stdin
    if [ $? -ne 0 ]; then
        echo -ne "Password: "
        read -s password
        echo
        docker login --username ${DOCKERHUBUSER} --password $password
    fi
    docker push ${DOCKERHUBUSER}/${NAME}
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
