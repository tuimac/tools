#!/bin/bash

# This script automate to create Kubernetes Dashboard environment without token authentication.
# That's why the environment is created by this script is dangerous because
# anyone can access to the dashboard.
# But someone feel uncomfortable to Kubernetes Dashboard's authentication.
# So this script is for the person like that.
#
# Run this script on Apr/25/2020.
#
# Below commands refer from https://kubernetes.io basically.
# Hardware requirements is below:
# CPU : 2core
# Memory : 2GB
# Hypervisor : KVM
#
# OS requirements is below:
# OS : CentOS7.6

# The premise is run this script by except root user.
[[ $USER == "root" ]] && { echo "Don't run this script by root user."; exit 1; }

# Initialized variables.
ipaddress=`hostname -i`
masterNodeName=`hostname -s`

# Disable swap.
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install docker and some other stuff
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 docker git

# To set up docker
sudo usermod -aG docker $(id -g)
sudo systemctl enable docker
sudo systemctl start docker

# To bridge traffic, define below configuration.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
sudo sh -c "cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
sudo sysctl --system

# To install kube* tools, define kubernetes's repository.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
sudo sh -c "cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF"

# Set SELinux in permissive mode (effectively disabling it)
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Kubernetes's tools.
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
sudo systemctl start kubelet

# Open node's port for Kubernetes.
## This section for Kubernetes.
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp

## This section for Kubernetes Dashboard you can change if you want.(Default range is 30000 - 32767.)
sudo firewall-cmd --permanent --add-port=30000/tcp

## Set above modifications to firewalld.
sudo firewall-cmd --reload

# Initiallize control-plane.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# You can change "pod-network-cidr" and "service-cidr" if you want.
sudo kubeadm init \
    --apiserver-advertise-address $ipaddress \
    --pod-network-cidr 10.240.0.0/24 \
    --service-cidr 10.241.0.0/24 \
    --node-name ${masterNodeName}

# To make kubectl work for your non-root user.
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Tell root where admin.conf is.
sudo sh -c "export KUBECONFIG=/etc/kubernetes/admin.conf"

# Deploy Clico is one of the Pod network add-ons.
curl -O https://docs.projectcalico.org/v3.11/manifests/calico.yaml
kubectl create -f calico.yaml

# To deploy Metrics Server on master node, allow Kubernetes Scheduler to deploy Pod on master node.
kubectl taint nodes ${masterNodeName} node-role.kubernetes.io/master:NoSchedule-

# Now I don't know how to deploy Metrics Server master branch version so
# I choose older one.
## Define file path to edit.
MANIFEST=$HOME/metrics-server/deploy/1.8+/metrics-server-deployment.yaml

## Edit metrics-server deployment manifest to run metrics server pod properly.
## https://github.com/kubernetes-sigs/metrics-server/issues/131
git clone -b release-0.3 https://github.com/kubernetes-sigs/metrics-server.git
sed -i 32d $MANIFEST
sed -i 32i'\        image: k8s.gcr.io/metrics-server:v0.3.6' $MANIFEST
sed -i 33i'\        command:' $MANIFEST
sed -i 34i'\          - /metrics-server' $MANIFEST
sed -i 35i'\          - --kubelet-insecure-tls' $MANIFEST
sed -i 36i'\          - --kubelet-preferred-address-types=InternalDNS,InternalIP,ExternalDNS,ExternalIP,Hostname' $MANIFEST
kubectl create -f metrics-server/deploy/1.8+/

# Create self-signed certification for Kubernetes Dashboard through TLS communication.
mkdir certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt

# Deploy Kubernetes Dashboard.
# If you want to change Kubernetes Dashboard's port, you can change port below "nodePort:" value.
# https://devblogs.microsoft.com/premier-developer/bypassing-authentication-for-the-local-kubernetes-cluster-dashboard/
curl -O https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
sed -i 40i'\  type: NodePort' recommended.yaml
sed -i 44i'\      nodePort: 30000' recommended.yaml
sed -i 203i'\            - --enable-skip-login' recommended.yaml
kubectl create -f recommended.yaml

# Switch default Kubernetes Dashboard's certification to self-signed certification.
# Then dump new Kubernetes Dashboard's certification formatted in YAML.
# Extract "data"'s values from new certification, then that values insert into Kubernetes Dashboard's
# manifest file.
## Define dump file name.
DUMPFILE="secret.yaml"

## If you access to Kubernetes Dashboard through modern browser like Chrome,
## you can't reach to dashboard because of expiration of default certification generated by
## Kubernetes Dashboard. So delete secret and recreate secret correspond to self-signed certification,
## then generate keys and certification infomation from that secret.
## Finally that information insert into Kubernetes Dashboard's manifest then reflect to environment.
## https://github.com/kubernetes/dashboard/issues/3804
kubectl -n kubernetes-dashboard delete secret kubernetes-dashboard-certs
kubectl -n kubernetes-dashboard create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs
kubectl -n kubernetes-dashboard get secret kubernetes-dashboard-certs -oyaml > $DUMPFILE
sleep 1
sed -n '2,5p' $DUMPFILE << 'EOS' | sed -i '50r /dev/stdin' recommended.yaml
EOS
sleep 1
kubectl apply -f recommended.yaml

# Change Kubernets Dashboard's default service account role.
## Define manifest file name.
ROLEFILE="kubernetes-dashboard-role.yaml"

## Create manifest to attach "cluster-admin" authorization to default service account
## on Kubernetes Dashboard.
sh -c "cat <<EOF > $HOME/$ROLEFILE
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
EOF"

# Delete default ClusterRoleBindings for Kubernetes Dashboard, then recreate ClusterRoleBindings
# with "cluster-admin" which is almost same as root.
# If so, you can see all resources on the dashboard.
kubectl delete -f $ROLEFILE
kubectl apply -f $ROLEFILE

# Starting Kubernetes Dashboard take some time so sleep 10 seconds.
sleep 10
