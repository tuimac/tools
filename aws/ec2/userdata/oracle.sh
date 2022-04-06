#!/bin/bash
LOG=/var/log/user-data.log
DOCKER_COMPOSE_VERSION='1.29.2'
touch $LOG
exec >> $LOG 2>&1
    echo 7.9 > /etc/yum/vars/releasever
    yum update -y
    yum install -y git vim wget
    mkdir -p /etc/vim/undo
    mkdir -p /etc/vim/backup
    rm /etc/vimrc
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
    chmod -R 777 /etc/vim
    echo "alias vi='vim'" >> /etc/profile
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    wget https://yum.oracle.com/public-yum-ol7.repo
    mv public-yum-ol7.repo /etc/yum.repos.d/public-yum-ol7.repo
    yum-config-manager --enable ol7_UEKR4
    yum-config-manager --enable ol7_addons
    yum install -y docker-engine
    systemctl enable docker
    usermod -aG docker ec2-user
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    su - ec2-user
    cd /home/ec2-user
    git clone https://github.com/tuimac/tools.git; echo "cloned"
    chown -R ec2-user:ec2-user /home/ec2-user/tools
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=8000/tcp --permanent
    firewall-cmd --zone=public --add-port=8080/tcp --permanent
    firewall-cmd --reload
    reboot
