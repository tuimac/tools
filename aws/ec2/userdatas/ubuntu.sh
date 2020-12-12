#!/bin/bash
LOG=/var/log/user-data.log
HOSTNAME=dns
DOMAIN=tuimac.private
touch $LOG
exec >> $LOG 2>&1
    apt update -y
    apt upgrade -y
    mkdir /etc/vim/undo
    mkdir /etc/vim/backup
    rm /etc/vim/vimrc
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc
    chmod -R 777 /etc/vim
    apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common git
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt install docker-ce docker-ce-cli containerd.io -y
    systemctl enable docker
    usermod -aG docker ubuntu
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    cat <<EOF >> /etc/hosts
$IP $HOSTNAME ${HOSTNAME}.${DOMAIN}
EOF
    echo ${HOSTNAME}.${DOMAIN} > /etc/hostname
    reboot
