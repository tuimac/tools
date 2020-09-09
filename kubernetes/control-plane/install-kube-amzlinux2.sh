#!/bin/bash

sudo yum update -y
sudo swapoff -a
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 docker git

sudo usermod -aG docker ec2-user
sudo systemctl enable docker
sudo systemctl start docker

sudo sh -c "cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
sudo sysctl --system

sudo sh -c "cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF"

sudo setenforce 0
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
sudo systemctl start kubelet
sleep 10
sudo systemctl restart kubelet
sleep 10

sudo kubeadm init \
        --config=init-config.yaml \
        --upload-certs \
        --ignore-preflight-errors all

sudo mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
sudo sh -c "export KUBECONFIG=/etc/kubernetes/admin.conf"

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl label node data-plane1 node-role.kubernetes.io/worker=worker
