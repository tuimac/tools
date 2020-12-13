#!/bin/bash

IP=`hostname -i`

/usr/sbin/named -c /etc/bind/named.conf -g -u root
