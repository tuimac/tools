#!/bin/bash

[[ -z $1 ]] && { echo "Need argument as a name."; exit 1; }

NAME=$1

docker build -t ${NAME} .
docker run -itd --name ${NAME} \
            -v "/var/run/docker.sock:/var/run/docker.sock" \
            -v "/usr/bin/docker:/usr/bin/docker" \
            ${NAME}






















































