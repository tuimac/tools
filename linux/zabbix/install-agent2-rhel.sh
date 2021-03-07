#!/bin/bash

sudo sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# Get url from https://repo.zabbix.com/zabbix
#sudo dnf install https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-agent2-5.0.8-1.el8.x86_64.rpm
sudo dnf install https://repo.zabbix.com/zabbix/4.4/rhel/8/x86_64/zabbix-agent2-4.4.0-1.el8.x86_64.rpm
sudo dnf install -y zabbix-agent2

CONF='/etc/zabbix/zabbix_agent2.conf'
sudo sed -i -e "s/Server=127.0.0.1/Server=10.3.0.230/g" ${CONF}
sudo sed -i -e "s/ServerActive=127.0.0.1/ServerActive=10.3.0.230/g" ${CONF}

sudo usermod -aG docker zabbix

sudo systemctl enable zabbix-agent2
sudo systemctl start zabbix-agent2
