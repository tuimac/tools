#!/bin/bash

NAME="awstest"
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
    docker build -t ${DOCKERHUBUSER}/${NAME} .
    docker run -itd --name ${NAME} \
                -v "/var/run/docker.sock:/var/run/docker.sock" \
                -v "/usr/bin/docker:/usr/bin/docker" \
                -v "${VOLUME}:/tmp" \
                ${NAME} /bin/bash
}

function commitImage(){
    docker stop ${NAME}
    docker commit ${NAME} ${DOCKERHUBUSER}/${NAME}
    cat password.txt | base64 -d | docker login --username ${DOCKERHUBUSER} --password-stdin
    if [ $? -ne 0 ]; then
        docker login --username ${DOCKERHUBUSER}
    fi
    docker push ${DOCKERHUBUSER}/${NAME}
    docker start ${NAME}
}

function registerSecret(){
        if [ -e password.txt ]; then
        echo -en "There is 'password.txt' file in your current directory."
        echo -en "Continue this? [y/n]: "
        read answer
        if [ $answer == "n" ]; then
            echo "Registering password is skipped."
            exit 0
        else
            echo "Only type in 'y' or 'n'."
            exit 1
        fi
        fi
        echo -en "Password: "
        read -s password
        echo
        echo $password | base64 > password.txt
        cat password.txt | base64 -d
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete | commit | register-secret]"
    echo -e "
        optional arguments:
        create              Create image and container after that run the container.
        delete              Delete image and container.
        commit              Create image from target container and push the image to remote repository.
        register-secret     Create password.txt for make it login process within 'commit' operation.
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    if [ $1 == "create" ]; then
        createContainer
    elif [ $1 == "delete" ]; then
        deleteAll
    elif [ $1 == "commit" ]; then
        commitImage
    elif [ $1 == "help" ]; then
        userguide
    else
        { userguide; exit 1; }
    fi
}

main $1
