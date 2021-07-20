#!/bin/bash

BUCKET_NAME='docker-registry-00'
STORAGE_PATH='/'`hostname`

docker run \
         -e SETTINGS_FLAVOR=s3 \
         -e AWS_BUCKET=${BUCKET_NAME} \
         -e STORAGE_PATH=${STORAGE_PATH} \
         -p 5000:5000 \
         registry
