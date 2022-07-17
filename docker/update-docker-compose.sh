#!/bin/bash

DOCKER_COMPOSE='/usr/local/bin/docker-compose'

which docker-compose >> /dev/null 2>&1
[[ $? -ne 1 ]] && { sudo rm $DOCKER_COMPOSE; }

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o $DOCKER_COMPOSE
sudo chmod +x $DOCKER_COMPOSE
docker-compose --version
