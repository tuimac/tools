#!/bin/bash

# Initial variables
BUCKET_NAME='tuimac-registry'
FIXED_PATH='docker/registry/v2/repositories'
PRIVATE_URL='registry.tuimac.com'
IMAGE_LIST=(
    'tuimac/dev/nginx'
    'tuimac/test/tomcat'
)
ECR_URL='xxxxxxxxxx.dkr.ecr.ap-northeast-3.amazonaws.com'

# Main processes

function get_tags(){
    for path in $(aws s3api list-objects-v2 --bucket $BUCKET_NAME --delimiter '/' --prefix $FIXED_PATH/$1/_manifests/tags/ | jq -r '.CommonPrefixes[].Prefix'); do
        IMAGE_TAGS+=($(echo $path | awk -F "/" '{ print $(NF -1) }'))
    done
}

function create_ecr(){
    aws ecr create-repository \
        --repository-name $1 \
        --image-scanning-configuration 'scanOnPush=true' \
        --encryption-configuration 'encryptionType=AES256' \
        --image-tag-mutability IMMUTABLE \
        --tags 'Key=Name,Value='$1
}

function move_image_to_ecr(){
    for image in ${IMAGE_LIST[@]}; do
        IMAGE_TAGS=()
        get_tags $image
        create_ecr $image
        for tag in ${IMAGE_TAGS[@]}; do
            podman pull $PRIVATE_URL/$image:$tag
            aws ecr get-login-password | podman login --username AWS --password-stdin $ECR_URL
            podman tag $PRIVATE_URL/$image:$tag $ECR_URL/$image:$tag
            podman push $ECR_URL/$image:$tag 
        done
    done
}

function main(){
    move_image_to_ecr
}

main
