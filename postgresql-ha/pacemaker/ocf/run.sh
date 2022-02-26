#!/bin/bash

PRIMARY_INS_ID='i-0acf98a9958c0e0fe'
CONTAINER='postgresql'
LOG='/var/log/pcs-podman.log'
RESOURCE_NAME='pg_podman'

function create(){
    sudo truncate -s0 $LOG
    sudo date >> $LOG
    podman inspect $CONTAINER
    [[ $? -ne 0 ]] && { echo 'There is no container name is '$CONTAINER; exit 1; }
    podman start $CONTAINER
    sudo pcs resource create ${RESOURCE_NAME} ocf:heartbeat:${RESOURCE_NAME} name=${CONTAINER} user=ec2-user instance_id=${PRIMARY_INS_ID} op monitor interval=5s timeout=5s
    sudo pcs status
}

function delete(){
    sudo pcs resource delete ${RESOURCE_NAME} --force
    sudo pcs resource refresh ${RESOURCE_NAME}
    sudo pcs status
}

function deploy(){
    sudo cp ${RESOURCE_NAME} /usr/lib/ocf/resource.d/heartbeat/${RESOURCE_NAME}
    sudo scp -i ~/tuimac.pem $RESOURCE_NAME ec2-user@secondary:/usr/lib/ocf/resource.d/heartbeat/$RESOURCE_NAME
    ls -l /usr/lib/ocf/resource.d/heartbeat/${RESOURCE_NAME}
}

function start(){
    podman stop $CONTAINER
    podman ps -a
    while true; do
        sudo pcs status
        sleep 3
    done
}

function log(){
    sudo cat $LOG
}

function userguide(){
    echo -e "usage: ./run.sh [help | create | delete]"
    echo -e "
optional arguments:
create              Create pcs resources.
delete              Delete pcs resources.
deploy              Copy ocf script to /usr/lib/ocf/resource.d/heartbeat
    "
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    if [ $1 == "create" ]; then
        create
    elif [ $1 == "delete" ]; then
        delete
    elif [ $1 == "deploy" ]; then
        deploy
    elif [ $1 == "start" ]; then
        start
    elif [ $1 == "log" ]; then
        log
    else
        { userguide; exit 1; }
    fi
}

main $1
