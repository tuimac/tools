#!/bin/bash

[[ $USER -ne 'root' ]] && { echo 'Must be root'; exit 1; }

timedatectl set-timezone Asia/Tokyo

cat <EOF > /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl -p

apt-get -y install iptables arptables ebtables
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy

apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
apt-mark hold docker-ce docker-ce-cli containerd.io
usermod -aG docker tuidev

cat /proc/cgroups | grep memory
echo ' cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory' >> /boot/firmware/cmdline.txt
cat /boot/firmware/cmdline.txt
cat /proc/cgroups | grep memory

reboot

cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF
systemctl enable docker
systemctl daemon-reload
systemctl restart docker

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get -y install kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm init --config=init-config.yml --upload-certs --ignore-preflight-errors all
ufw allow to 0.0.0.0/0 port 22
ufw allow to 0.0.0.0/0 port 2379
ufw allow to 0.0.0.0/0 port 2380
ufw allow to 0.0.0.0/0 port 10250
ufw allow to 0.0.0.0/0 port 10251
ufw allow to 0.0.0.0/0 port 10252
ufw allow to 0.0.0.0/0 port 10248
ufw allow to 0.0.0.0/0 port 443
ufw allow to 0.0.0.0/0 port 8472
ufw enable

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#kubectl taint nodes NODE_NAME node-role.kubernetes.io/master:NoSchedule-
