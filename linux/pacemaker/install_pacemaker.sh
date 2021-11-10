#!/bin/bash

PRIMARY_IP=''
SECONDARY_IP=''

# Do these process on both servers until next comment anchor
sudo yum install -y pacemaker pcs

sudo cat <<EOF >> /etc/hosts
$PRIMARY_IP test-1
$SECONDARY_IP test-2
EOF

sudo systemctl start pcsd
sudo systemctl enable pcsd
sudo systemctl status pcsd

sudo passwd hacluster

# Until here

sudo pcs cluster auth test-1 test-2 -u hacluster
sudo pcs cluster setup --name mycluster test-1 test-2 --force
sudo pcs cluster start --all
sudo pcs cluster enable --all

sudo ip address add 192.168.0.100/32 dev eth0

sudo pcs resource create vip ocf:heartbeat:IPaddr2 ip=192.168.0.100 cidr_netmask=32 nic="eth0" op monitor interval=5s

# Disable STONITH
pcs property set stonith-enabled=false

# Ignore quorum
pcs property set no-quorum-policy=ignore

sudo mkdir /usr/lib/ocf/resource.d/test
sudo cp changeRoute /usr/lib/ocf/resource.d/test

sudo pcs resource create test ocf:test:changeRoute
