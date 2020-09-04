#!/bin/bash

CLUSTER=ac-test
NODEGROUP=ac-test-a

function create(){
    aws eks create-cluster \
        --name $CLUSTER \
        --role-arn arn:aws:iam::xxxxxxxxxxxx:role/EKS-cluster \
        --resources-vpc-config \
            subnetIds=subnet-xxxxxxxxxxxxx,securityGroupIds=sg-xxxxxxxxxxxxxxx,endpointPrivateAccess=true,endpointPublicAccess=false \
        --kubernetes-version 1.17
}

function nodegroup(){
        eksctl create nodegroup \
          --cluster ${CLUSTER} \
          --region ap-northeast-1 \
          --name ${NODEGROUP} \
          --node-type t3.small \
          --nodes 2 \
          --nodes-min 2 \
          --nodes-max 2 \
          --ssh-access \
          --ssh-public-key tuimac.pem \
          --managed
}

function update(){
    aws eks update-kubeconfig \
        --region ap-northeast-1 \
        --name $CLUSTER
}

function main(){
    if [ $1 == 'create' ]; then
        create
    elif [ $1 == 'nodegroup' ]; then
        nodegroup
    elif [ $1 == 'update' ]; then
        update
    else
        { echo 'wrong.'; exit 1; }
    fi
}

main $1

# memo
# Define map role
# https://dev.classmethod.jp/articles/eks-cluster-access-control/
