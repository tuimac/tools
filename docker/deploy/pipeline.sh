#!/bin/bash

set -e

# Variables
BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
BUILD_DIR=${BASE_DIR}/build
PJT_DIR=${BUILD_DIR}/test
REPO_URL='https://github.com/tuimac/test'
REPO_BRANCH='main'

# Pipeline
function deploy(){
    docker run -itd --name nginx \
        -p 80:80 \
        nginx
}

function build(){
    local image_name='node:latest'
    docker run --rm --name nodejs \
        -v ${PJT_DIR}:/build \
        $image_name \
        bash -c 'cd /build; npm install; npm run build'
    docker rmi $image_name
}

function check(){
    if [ ! -e $PJT_DIR ]; then
        [[ ! -e $BUILD_DIR ]] && { mkdir $BUILD_DIR; }
        cd $BUILD_DIR
        git clone -b $REPO_BRANCH $REPO_URL
    fi
    cd $PJT_DIR
    git checkout $REPO_BRANCH
    git fetch $REPO_URL
    local local=`git rev-parse HEAD`
    local remote=`git rev-parse ${REPO_BRANCH}@{upstream}`
    echo $local
    echo $remote
    if [ "$local" == "$remote" ]; then
        CHECK_FLAG=0
    else
        git merge
        CHECK_FLAG=1
    fi
}

function main(){
    CHECK_FLAG=0
    check
    if [[ $CHECK_FLAG == 0 ]]; then
        echo 'nothing'
        exit 0
    elif [[ $CHECK_FLAG == 1 ]]; then
        build
        deploy
    else
        echo 'Something wrong!!'
        exit 1
    fi
}

main
