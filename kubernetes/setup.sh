#!/bin/bash

user="tuidev"
ipaddress=`hostname -i`
basedir="/home/"${user}"/management"

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 docker git
sudo usermod -aG docker $user
sudo systemctl enable docker
sudo systemctl start docker

sudo sh -c "cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
sudo sysctl --system

sudo sh -c "cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF"

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
sudo systemctl start kubelet

sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --permanent --add-port=30000/tcp
sudo firewall-cmd --reload

sudo kubeadm init \
    --apiserver-advertise-address $ipaddress \
    --pod-network-cidr 10.240.0.0/24 \
    --service-cidr 10.241.0.0/24

sudo mkdir -p /home/${user}/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/${user}/.kube/config
sudo chown ${user}:${user} /home/${user}/.kube/config

mkdir $basedir
cd $basedir

sudo export KUBECONFIG=/etc/kubernetes/admin.conf

curl -O https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

kubectl apply -f kube-flannel.yml

sudo sh -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/k8s.conf"
sudo sysctl --systemS

git clone -b release-0.3 https://github.com/kubernetes-sigs/metrics-server.git
kubectl apply -f metrics-server/deploy/1.8+/

mkdir certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
