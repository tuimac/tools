#!/bin/bash

yum install -y vim
mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vimrc
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
chmod -R 777 /etc/vim

echo 'alias vi="vim"' >> /home/ec2-user/.bashrc
echo 'alias vi="vim"' >> /root/.bashrc
source /home/ec2-user/.bashrc
source /root/.bashrc
