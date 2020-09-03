#!/bin/bash

CLUSTER=ac-test
NODEGROUP=ac-test-a

function create(){
    aws eks create-cluster \
        --name $CLUSTER \
        --role-arn arn:aws:iam::500415866962:role/EKS-cluster \
        --resources-vpc-config \
            subnetIds=subnet-0fc7211f4023b71ff,subnet-0972f112479448909,securityGroupIds=sg-0810dfe81aefef4f2,endpointPrivateAccess=true,endpointPublicAccess=false \
        --kubernetes-version 1.17
}

function nodegroup(){
    aws eks create-nodegroup \
        --cluster-name $CLUSTER \
        --nodegroup-name $NODEGROUP \
        --scaling-config minSize=2,maxSize=2,desiredSize=2 \
        --disk-size 30 \
        --subnets subnet-0fc7211f4023b71ff subnet-0972f112479448909 \
        --instance-type t3.small \
        --ami-type AL2_x86_64 \
        --remote-access ec2SshKey=tuimac,sourceSecurityGroups=sg-0810dfe81aefef4f2 \
        --node-role arn:aws:iam::500415866962:role/EC2-Admin \
        --labels Name=${NODEGROUP} \
        --tags Name=${NODEGROUP}
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
