#!/bin/bash

CONFIG='/etc/audit/auditd.conf'
NEW_DIR='/var/log/os/audit/'

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }

sed -i 's/log_file = \/var\/log\/audit\/audit.log/log_file = \/var\/log\/os\/audit\/audit.log/' $CONFIG
mkdir -p $NEW_DIR
touch ${NEW_DIR}/audit.log
chcon -t auditd_log_t $NEW_DIR
chcon -t auditd_log_t ${NEW_DIR}/audit.log

echo '-a exit,always -S execve' >> /etc/audit/audit.rules 
cat /etc/audit/audit.rules
