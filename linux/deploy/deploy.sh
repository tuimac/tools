#!/bin/bash

export DOCKER_USER='tuimac'

sudo rm -rf pictionary_v2.1
git clone https://github.com/tuimac/pictionary_v2.1.git
cd pictionary_v2.1
docker-compose down
docker rmi $(docker images -aq)
docker pull ${DOCKER_USER}/mysql
docker pull ${DOCKER_USER}/springboot
docker pull ${DOCKER_USER}/react
docker pull ${DOCKER_USER}/nginx
docker-compose up -d
