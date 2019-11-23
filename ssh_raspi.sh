#!/bin/bash

IPv6=""
NIC=""

IPv6=`avahi-resolve-host-name raspberrypi.local | awk '{print $2}'` > /dev/null 2>&1
[[ -z $IPv6 ]] && { echo -e "Can't resolve raspberrypi.local..."; exit 1; }

for nic in `ls /sys/class/net`; do
    if [[ $nic =~ enp0s20f0u. ]]; then
        NIC=`echo $nic`
        break
    fi
done
[[ -z $NIC ]] && { echo -e "Can't detect usb device..."; exit 1; }

echo -ne "Login User: "
read USER_NAME

ssh -6 ${USER_NAME}@${IPv6}%${NIC}
