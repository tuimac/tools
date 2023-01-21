#!/bin/bash

VOLUME_NAME='test'
NAME='nginx'

function runContainer(){
    podman volume create $VOLUME_NAME
    podman run -itd --name $NAME \
                -v ${VOLUME_NAME}:/var/log/nginx:Z \
                -h $NAME \
                -p 8000:80 \
                docker.io/library/nginx:latest
}

function deleteAll(){
    podman stop $NAME
    podman rm $NAME
    podman volume rm $VOLUME_NAME
    podman image prune -f
    podman container prune -f
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
    case $1 in
        'create')
            runContainer;;
        'delete')
            deleteAll;;
        'help')
            userguide;;
        *)
            userguide
            exit 1;;
    esac
}

main $1
