#!/bin/bash

CLUSTER=test
NODEGROUP=test-a

function create(){
    aws eks create-cluster \
        --name ${CLUSTER} \
        --role-arn arn:aws:iam::000000000000:role/EKS-cluster-role \
        --resources-vpc-config \
            subnetIds=subnet-xxxxxxxxxxxxxxxxx,securityGroupIds=sg-xxxxxxxxxxxxxxxxxx,endpointPrivateAccess=true,endpointPublicAccess=false \
        --kubernetes-version 1.17
}

function nodegroup_eksctl(){
        eksctl create nodegroup \
          --cluster ${CLUSTER} \
          --region ap-northeast-1 \
          --name ${NODEGROUP} \
          --node-type t3.small \
          --nodes 2 \
          --nodes-min 2 \
          --nodes-max 2 \
          --ssh-access \
          --ssh-public-key test.pem \
          --managed
}

function nodegroup_awscli(){
    aws eks create-nodegroup \
        --cluster-name ${CLUSTER} \
        --nodegroup-name ${NODEGROUP} \
        --scaling-config minSize=2,maxSize=2,desiredSize=2 \
        --disk-size 20 \
        --subnet subnet-xxxxxxxxxxxxxxxxxx subnet-xxxxxxxxxxxxxxxxxx \
        --instance-type t3.small \
        --ami-type AL2_x86_64 \
        --remote-access ec2SshKey=test,sourceSecurityGroups=sg-xxxxxxxxxxxxxxxxxx \
        --node-role arn:aws:iam::000000000000:role/EC2-EKS-role \
        --labels Name=${NODEGROUP} \
        --tags Name=${NODEGROUP}
}

function update(){
    aws eks update-kubeconfig \
        --region ap-northeast-1 \
        --name ${CLUSTER}
        #--role-arn arn:aws:iam::000000000000:role/EC2-EKS-role
}

function main(){
    [[ -z $1 ]] && { echo 'Need argument.'; exit 1; }
    if [ $1 == 'create' ]; then
        create
    elif [ $1 == 'nodegroup' ]; then
        nodegroup_awscli
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
