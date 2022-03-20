#!/bin/bash

[[ $USER != 'root' ]] && { echo 'Must be root!!'; exit 1 }

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=8000/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=5432/tcp --permanent
firewall-cmd --reload

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
