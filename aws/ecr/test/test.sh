#!/bin/bash

NAME='tuimac/dev/nginx'

aws ecr create-repository \
    --repository-name $NAME \
    --image-scanning-configuration 'scanOnPush=true' \
    --encryption-configuration 'encryptionType=AES256' \
    --image-tag-mutability IMMUTABLE \
    --tags 'Key=Name,Value='$NAME
