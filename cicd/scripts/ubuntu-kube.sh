#!/bin/bash

PODNETWORK='10.230.0.0/16'
CONFIG='init-config.yaml'

sh -c "cat <<EOF > ${CONFIG}
# https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  name: docker
localAPIEndpoint:
  bindPort: 6443

---

apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: production
controlPlaneEndpoint: docker.tuimac.private:6443
apiServer:
  extraArgs:
    enable-admission-plugins: DefaultTolerationSeconds
    default-not-ready-toleration-seconds: "10"
    default-unreachable-toleration-seconds: "10"
networking:
  podSubnet: ${PODNETWORK}
  serviceSubnet: 10.231.0.0/16
  dnsDomain: prod.local
certificatesDir: /etc/kubernetes/pki
EOF"


sudo apt update
sudo apt upgrade -y
sudo swapoff -a
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install docker-ce docker-ce-cli containerd.io -y

sudo usermod -aG docker ec2-user
sudo systemctl enable docker
sudo systemctl start docker

sudo sh -c "cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
sudo sysctl --system

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
sudo systemctl start kubelet
sleep 5
sudo systemctl restart kubelet
sleep 5

sudo kubeadm init \
        --config=${CONFIG} \
        --upload-certs \
        --ignore-preflight-errors all

[[ $? -ne 0 ]] && { echo -ne 'Initialization of kubernetes are failed!'; exit 1; }

sudo mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
sudo sh -c "export KUBECONFIG=/etc/kubernetes/admin.conf"

sleep 1

#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
