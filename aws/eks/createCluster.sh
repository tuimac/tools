#!/bin/bash

aws eks create-cluster \
    --name ac-test \
    --role-arn arn:aws:iam::500415866962:role/EKS-cluster \
    --resources-vpc-config \
        subnetIds=subnet-xxxxxxxx,subnet-xxxxxxx,securityGroupIds=sg-xxxxx,endpointPrivateAccess=true,endpointPublicAccess=false \
    --kubernetes-version 1.17
