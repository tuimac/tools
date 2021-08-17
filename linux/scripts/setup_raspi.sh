#!/bin/bash

echo 'node3.tuimac.private' > /etc/hostname
echo 'interface eth0
static ip_address=10.0.222.3/24
static routers=10.0.222.1
static domain_name_servers=10.0.222.5 8.8.8.8
static domain_search=tuimac.private' >> /etc/dhcpcd.conf

echo ' cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' >> /boot/cmdline.txt

echo 'dtoverlay=pi3-disable-wifi
dtoverlay=pi3-disable-bt
gpu_mem=16' >> /boot/config.txt

adduser tuidev
vi /etc/sudoers
userdel pi
rm -rf /home/pi

apt-get --purge remove vim-common vim-tiny -y
apt-get install vim -y
mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vim/vimrc
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc
chmod -R 777 /etc/vim
