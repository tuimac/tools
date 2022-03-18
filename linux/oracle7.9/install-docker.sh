#!/bin/bash

# If you set the empty value to each environment variable, install latest version
DOCKER_VERSION=''

# You need set the specific version.
# https://github.com/docker/compose/releases/
DOCKER_COMPOSE_VERSION='1.29.2'

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }

yum install -y wget
wget https://yum.oracle.com/public-yum-ol7.repo
mv public-yum-ol7.repo /etc/yum.repos.d/public-yum-ol7.repo
yum-config-manager --enable ol7_UEKR4
yum-config-manager --enable ol7_addons

# Command to find Docker Engine Version.
# yum list --showduplicates | grep docker

if [ -z $DOCKER_VERSION ]; then
    yum install -y docker-engine
else
    yum install -y docker-engine-${DOCKER_VERSION}
fi
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

reboot
