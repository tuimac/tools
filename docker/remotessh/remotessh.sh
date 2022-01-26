#!/bin/bash

TARGET_SERVER='10.3.1.50'
SSH_USER='ubuntu'
SSH_KEY='tuimac.pem'
COMMAND='cd /home/'${SSH_USER}'/tools/docker/nginx/; ./script.sh;'

ssh -i ${SSH_KEY} ${SSH_USER}@${TARGET_SERVER} -o "StrictHostKeyChecking=no" ${COMMAND}
