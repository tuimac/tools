#!/bin/bash

PODNETWORK='10.230.0.0/16'

sudo apt update
suod apt upgrade -y
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
sleep 10
sudo systemctl restart kubelet
sleep 10

sudo kubeadm init \
        --config=init-config.yaml \
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

#kubectl label node data-plane1 node-role.kubernetes.io/worker=worker
#kubectl taint nodes NODE_NAME node-role.kubernetes.io/master:NoSchedule-

DEVICE=`ls /sys/class/net`

for x in ${DEVICE// / }; do
    if [[ $x =~ 'ens' ]]; then
        DEVICE=`echo $x`
        break
    fi
done

sudo iptables -t nat -A POSTROUTING -s ${PODNETWORK} -o $DEVICE -j MASQUERADE

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
