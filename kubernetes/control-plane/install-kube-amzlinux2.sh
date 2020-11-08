#!/bin/bash

PODNETWORK='10.230.0.0/16'

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
        --pod-network-cidr=${PODNETWORK} \
        --config=init-config.yaml \
        --upload-certs \
        --ignore-preflight-errors all

sudo mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
sudo sh -c "export KUBECONFIG=/etc/kubernetes/admin.conf"

sleep 1

#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#kubectl label node data-plane1 node-role.kubernetes.io/worker=worker
#kubectl taint nodes NODE_NAME node-role.kubernetes.io/master:NoSchedule-

sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
sudo iptables -t nat -A POSTROUTING -s ${PODNETWORK} -o eth0 -j MASQUERADE
sudo service iptables save

# Installation of Kubernetes Dashboard without HTTPS certification!!

while true; do
    echo -en 'Do you want to install Kubernetes Dashboard??[y/n]: '
    read answer

    if [ $answer == 'y' ]; then
        break
    elif [ $answer == 'n' ]; then
        echo 'Abort to install Kubernets Dashboard.'
        exit 0
    else
        echo 'You should answer "y" or "n".'
    fi
done

curl -O https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml
sed -i 40i'\  type: NodePort' recommended.yaml
sed -i 44i'\      nodePort: 30000' recommended.yaml
sed -i 203i'\            - --enable-skip-login' recommended.yaml
kubectl create -f recommended.yaml

mkdir certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt

kubectl -n kubernetes-dashboard delete secret kubernetes-dashboard-certs
kubectl -n kubernetes-dashboard create secret generic kubernetes-dashboard-certs --from-file=certs
kubectl -n kubernetes-dashboard get secret kubernetes-dashboard-certs -oyaml > secret.yaml

sed -n '2,5p' secret.yaml << 'EOS' | sed -i '50r /dev/stdin' recommended.yaml
EOS
sleep 1
kubectl apply -f recommended.yaml

sh -c "cat <<EOF role.yaml
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

kubectl delete -f role.yaml
kubectl apply -f role.yaml
