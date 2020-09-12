#!/bin/bash

function dev(){
    kubeadm init \
        --apiserver-advertise-address 10.3.0.233 \
        --apiserver-bind-port 6444 \
        --pod-network-cidr 10.250.0.0/16 \
        --service-cidr 10.251.0.0/16 \
        --service-dns-domain dev.local \
        --control-plane-endpoint dev \
        --ignore-preflight-errors all \
        --node-name dev
}

function prod(){
    kubeadm init \
        --apiserver-advertise-address 10.3.0.233 \
        --apiserver-bind-port 6443 \
        --pod-network-cidr 10.240.0.0/16 \
        --service-cidr 10.241.0.0/16 \
        --service-dns-domain prod.local \
        --control-plane-endpoint prod \
        --node-name prod
}

function main(){
    if [ $1 == 'prod' ]; then
        prod
    elif [ $1 == 'dev' ]; then
        prod
        dev
    else
        { echo 'wrong'; exit 1; }
    fi
}

main $1
