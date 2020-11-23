#!/bin/bash

GITREPOURL='https://github.com/tuimac/pictionary_v2.1.git'
GITREPONAME='pictionary_v2.1'
SCRIPTDIR=$(cd $(dirname "${BASH_SOURCE[0]}") > /dev/null 2>&1 && pwd)
PJTDIR=${SCRIPTDIR}/${GITREPONAME}
LOG=${SCRIPTDIR}/deploy.log
APPURL='http://test.com'
SNSTOPIC='test'
export AWS_DEFAULT_REGION='ap-northeast-1'

function usage(){
    echo -e 'usage: ./deploy.sh <Dockerhub user name> <AWS SNS ARN>' | tee -a $LOG
}

function cleanupProject(){
    [[ -e $PJTDIR ]] && { cd $PJTDIR; docker-compose down; cd $SCRIPTDIR; }
    docker rmi $(docker images -aq)
    sudo rm -rf ${PJTDIR}
}

function getProject(){
    cd ${SCRIPTDIR}
    git clone ${GITREPOURL}
}

function pullImages(){
    docker pull ${DOCKER_USER}/mysql
    docker pull ${DOCKER_USER}/springboot
    docker pull ${DOCKER_USER}/react
    docker pull ${DOCKER_USER}/nginx
}

function startContainers(){
    cd ${PJTDIR}
    docker-compose up -d
}

function checkEnvironment(){
    local subject=''
    if [ ! -z $(docker ps -a | grep Exited) ]; then
        aws sns publish \
            --topic-arn $SNS_ARN \
            --subject 'Pictionarizer deployment notification' \
            --message 'Deployment failed...'
    else
        aws sns publish \
            --topic-arn $SNS_ARN \
            --subject 'Pictionarizer deployment notification' \
            --message 'Deployment successed!! Access: '${APPURL}
    fi
}

function main(){
    [[ ! -f $LOG ]] && { touch $LOG; }
    date > $LOG
    if [ -z $1 ] || [ -z $2 ]; then
        usage
        exit 1
    fi
    export DOCKER_USER=$1
    SNS_ARN=$2

    cleanupProject | tee -a $LOG 2>&1
    getProject | tee -a $LOG 2>&1
    pullImages | tee -a $LOG 2>&1
    startContainers | tee -a $LOG 2>&1
    checkEnvironment | tee -a $LOG 2>&1
}

main $1 $2
