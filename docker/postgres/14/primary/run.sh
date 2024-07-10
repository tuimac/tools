#!/bin/bash

# Change variables below if you need
##############################
NAME='postgresql'
DATA="${PWD}/data"
BACKUP="${PWD}/backup"
LOG="${PWD}/log"
##############################

function runContainer(){
    docker run -itd --name ${NAME} \
                -v ${DATA}:/var/lib/postgresql/data \
                -v ${BACKUP}:/var/lib/postgresql/backup \
                -v ${LOG}:/var/log/postgresql \
                -e POSTGRES_PASSWORD=password \
                -e POSTGRES_USER=test \
                -e POSTGRES_DB=test \
                -h ${NAME} \
                --network host \
                ${NAME}
    sleep 3
    sudo cp conf/postgresql.conf ${DATA}
    sudo cp conf/pg_hba.conf ${DATA}
    docker restart ${NAME}
}

function cleanup(){
    docker image prune -f
    docker container prune -f
}

function createContainer(){
    mkdir ${DATA}
    mkdir ${BACKUP}
    docker unshare chown 999:999 ${LOG}
    docker unshare chown 999:999 ${LOG}
    docker unshare chown 999:999 ${LOG}
    mkdir ${LOG}
    docker build -t ${NAME} .
    runContainer
}

function rerunContainer(){
    echo -en "Do you want to commit image? [y(default)/n]: "
    read answer
    if [ "$answer" != "n" ]; then
        commitImage ${NAME}
    fi
    docker stop ${NAME}
    docker rm ${NAME}
    runContainer
    cleanup
}

function deleteAll(){
    docker stop ${NAME}
    docker rm ${NAME}
    docker rmi ${NAME}
    cleanup
    sudo rm -rf ${DATA}
    sudo rm -rf ${BACKUP}
    sudo rm -rf ${LOG}
}

function commitImage(){
    docker stop ${NAME}
    docker commit ${NAME} $1
    docker start ${NAME}
}

function pushImage(){
    commitImage ${IMAGE}
    docker push ${IMAGE}
    if [ $? -ne 0 ]; then
        cat .password.txt | base64 -d | docker login --username ${dockerHUBUSER} --password-stdin
        if [ $? -ne 0 ]; then
            docker login --username ${dockerHUBUSER}
        fi
        docker push ${IMAGE}
    fi
    docker rmi ${IMAGE}
    cleanup
}

function registerSecret(){
    local secretFile=".password.txt"
    if [ -e $secretFile ]; then
        echo -en "There is '.password.txt' file in your current directory."
        echo -en "Continue this? [y/n]: "
        read answer
        if [ $answer == "n" ]; then
            echo "Registering password is skipped."
            exit 0
        elif [ $answer == "y" ]; then
            echo "" > /dev/null
        else
            echo "Only type in 'y' or 'n'."
            exit 1
        fi
    fi
    echo -en "Password: "
    read -s password
    echo
    chmod 600 ${secretFile}
    echo $password | base64 > ${secretFile}
    chmod 400 ${secretFile}
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete | commit | register-secret]"
    echo -e "
optional arguments:
create              Create image and container after that run the container.
rerun               Delete only container and rerun container with new settings.
delete              Delete image and container.
commit              Create image from target container and push the image to remote repository.
push                Push image you create to docker Hub.
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
