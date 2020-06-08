#!/bin/bash

# Change variables below if you need
##############################
NAME="dockercontainername"
VOLUME="${PWD}/volume"
DOCKERHUBUSER="yourusernameofdockerhub"
IMAGE=${DOCKERHUBUSER}/${NAME}
##############################

function runContainer(){
    docker run -itd --name ${NAME} \
                -h ${NAME} \
                -v "${VOLUME}:/tmp" \
                -v "/etc/localtime:/etc/localtime:ro" \
                -p "8080:80" \
                -p "3000:3000" \
                -p "3001:3001" \
                --network="br0" \
                ${IMAGE} /bin/bash
}

function cleanup(){
    docker image prune -f
    docker container prune -f
}

function createContainer(){
    mkdir ${VOLUME}
    docker build -t ${IMAGE} .
    runContainer
    cleanup
}

function rerunContainer(){
    docker stop ${NAME}
    docker rm ${NAME}
    runContainer
    cleanup
}

function deleteAll(){
    docker stop ${NAME}
    docker rm ${NAME}
    docker rmi ${IMAGE}
    cleanup
    rm -rf ${VOLUME}
}

function commitImage(){
    docker stop ${NAME}
    docker commit ${NAME} ${IMAGE}
    docker start ${NAME}
}

function pushImage(){
    docker push ${NAME}
    if [ $? -ne 0 ]; then
        cat .password.txt | base64 -d | docker login --username ${DOCKERHUBUSER} --password-stdin
        if [ $? -ne 0 ]; then
            docker login --username ${DOCKERHUBUSER}
        fi
        docker push ${IMAGE}
    fi
}

function registerSecret(){
    if [ -e .password.txt ]; then
    echo -en "There is '.password.txt' file in your current directory."
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
    echo $password | base64 > .password.txt
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete | commit | register-secret]"
    echo -e "
optional arguments:
create              Create image and container after that run the container.
rerun               Delete only container and rerun container with new settings.
delete              Delete image and container.
commit              Create image from target container and push the image to remote repository.
push                Push image you create to Docker Hub.
register-secret     Create password.txt for make it login process within 'commit' operation.
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
        commitImage
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
