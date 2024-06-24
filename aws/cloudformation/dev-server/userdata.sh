#!/bin/bash

sudo su -
timedatectl set-timezone Asia/Tokyo
cat <<EOF >> /etc/profile
# Custom History
export HISTSIZE=1000000
export HISTTIMEFORMAT="[%Y/%m/%d %T] "
export HISTCONTROL=ignoreboth
EOF
hostnamectl set-hostname dev-server.tuimac.com
sed -i '12 a preserve_hostname: true' /etc/cloud/cloud.cfg
sed -i '13 a repo_upgrade: none' /etc/cloud/cloud.cfg

mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vim/vimrc
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc
chmod -R 777 /etc/vim

apt update && sudo apt upgrade -y
apt install -y ubuntu-desktop task-gnome-desktop xrdp docker.io
systemctl enable xrdp docker

adduser tuimac
usermod -aG docker tuimac
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
