#!/bin/bash
LOG=/var/log/user-data.log
HOSTNAME=kubernetes
DOMAIN=tuimac.private
touch $LOG
exec >> $LOG 2>&1
    cd /home/ubuntu
    echo ${HOSTNAME}.${DOMAIN} > /etc/hostname
    IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    cat <<EOF >> /etc/hosts
$IP $HOSTNAME ${HOSTNAME}.${DOMAIN}
EOF
    apt update
    apt upgrade -y
    swapoff -a
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt install docker-ce docker-ce-cli containerd.io git curl -y

    for i in {0..10};do
      curl https://github.com > /dev/null
      [[ $? -eq 0 ]] && { break; }
      sleep 6
    done
    usermod -aG docker ec2-user
    systemctl start docker

    cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
    sysctl -p
    apt-get update && apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    cat <<EOF > /etc/docker/daemon.json
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "100m"
      },
      "storage-driver": "overlay2"
    }
EOF
    usermod -aG docker ubuntu
    systemctl enable docker
    systemctl daemon-reload
    systemctl restart docker
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    systemctl daemon-reload
    systemctl enable --now kubelet
    systemctl start kubelet
    sleep 10
    systemctl restart kubelet
    sleep 10
	cat <<EOF > init-config.yml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  name: kubernetes
localAPIEndpoint:
  bindPort: 6443

---

apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: kubernetes
controlPlaneEndpoint: kubernetes.tuimac.private:6443
apiServer:
  extraArgs:
    enable-admission-plugins: DefaultTolerationSeconds
    default-not-ready-toleration-seconds: "10"
    default-unreachable-toleration-seconds: "10"
networking:
  podSubnet: 10.230.0.0/16
  serviceSubnet: 10.231.0.0/16
  dnsDomain: kubernetes.local
certificatesDir: /etc/kubernetes/pki
EOF
    kubeadm init \
            --config=init-config.yml \
            --upload-certs \
            --ignore-preflight-errors all

    mkdir -p /home/ubuntu/.kube
    cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
    chown ubuntu:ubuntu /home/ubuntu/.kube/config
    sh -c "export KUBECONFIG=/etc/kubernetes/admin.conf"
    
    cat <<EOF > /root/iptables.sh
#!/bin/bash
sudo iptables -t nat -A POSTROUTING -s 10.230.0.0/16 -o ens5 -j MASQUERADE
sudo iptables -P FORWARD ACCEPT
EOF
    cat <<EOF > /usr/lib/systemd/system/addroute.service
[Unit]
Description=Add iptables route
After=network.target

[Service]
Type=simple
TimeoutSec=120
ExecStart=/root/iptables.sh
KillMode=none
SendSIGKILL=no
RemainAfterExit=true
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    chmod +x /root/iptables.sh
    systemctl daemon-reload
    systemctl enable addroute
    systemctl start addroute
    sleep 1
    curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -o kube-flannel.yml
    sed -i '/"Network": "10.244.0.0\/16",/a \      "ipMasq": false,' kube-flannel.yml
    kubectl apply -f kube-flannel.yml
    kubectl taint nodes kubernetes node-role.kubernetes.io/master:NoSchedule-

    mkdir -p /etc/vim/undo
    mkdir -p /etc/vim/backup
    chmod -R 777 /etc/vim
    curl https://raw.githubusercontent.com/tuimac/tools/master/vim/installer/ubuntu.sh | sudo bash
    su ubuntu -c 'git clone https://github.com/tuimac/tools.git'
    reboot
