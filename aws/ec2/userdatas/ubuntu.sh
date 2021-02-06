#!/bin/bash
LOG=/var/log/user-data.log
HOSTNAME=docker
DOMAIN=tuimac.private
touch $LOG
exec >> $LOG 2>&1
    apt update
    apt install -y docker.io git curl
    apt upgrade -y
    mkdir -p /etc/vim/undo
    mkdir -p /etc/vim/backup
    chmod -R 777 /etc/vim
    systemctl enable docker
    usermod -aG docker ubuntu
    for i in {0..10};do
      curl https://github.com
      [[ $? -eq 0 ]] && { break; }
      sleep 6
    done
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    cat <<EOF >> /etc/hosts
$IP $HOSTNAME ${HOSTNAME}.${DOMAIN}
EOF
    echo ${HOSTNAME}.${DOMAIN} > /etc/hostname
    cd /home/ubuntu
    su ubuntu -c 'git clone https://github.com/tuimac/tools.git'
    curl https://raw.githubusercontent.com/tuimac/tools/master/vim/installer/ubuntu.sh | sudo bash 
    reboot
