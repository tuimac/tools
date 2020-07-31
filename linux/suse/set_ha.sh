#!/bin/bash

# Reference is below
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-pacemaker

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }

zypper in socat
echo 'DefaultTasksMax=4096' >> /etc/systemd/system.conf
systemctl daemon-reload
systemctl --no-pager show | grep DefaultTasksMax
[[ $? -ne 0 ]] && { echo 'Adding "DefaultTaskMax" was failed...'; exit 1; }

echo 'vm.dirty_bytes = 629145600' >> /etc/sysctl.conf
echo 'vm.dirty_background_bytes = 314572800' >> /etc/sysctl.conf

sed -i "s/CLOUD_NETCONFIG_MANAGE='yes'/CLOUD_NETCONFIG_MANAGE='no'/g" /etc/sysconfig/network/ifcfg-eth0

expect -c '
spawn ssh-keygen
expect -- "Enter file in which to save the key (/root/.ssh/id_rsa):"
send -- ¥r
expect -- "Enter passphrase (empty for no passphrase):"
send -- ¥r
expect -- "Enter same passphrase again:"
send -- ¥r
timeout set 60
'

