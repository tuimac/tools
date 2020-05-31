#!/bin/bash


NAME="test-aws"

function delete_docker(){
    docker stop ${NAME}
    docker rm ${NAME}
    docker rmi ${NAME}
}

function create_docker(){
    docker build -t ${NAME} .
    docker run -itd --name ${NAME} \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                -v "/usr/bin/docker:/usr/bin/docker" \
                -v "volume:/root" \
                ${NAME}
}

function main(){
    [[ -z $1 ]] && { echo "Need argument which is 'create' or 'delete'."; exit 1; }
    if [ $1 == "create" ]; then
        create_docker
    else
        delete_docker
    fi
}

main $1




















































