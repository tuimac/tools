#!/bin/bash

rm /etc/SUSEConnect
rm -f /etc/zypp/{repos,services,credentials}.d/*
rm -f /usr/lib/zypp/plugins/services/*
sed -i '/^Added by SMT reg/,+1d' /etc/hosts
/usr/sbin/registercloudguest --force-new

zypper update -y
