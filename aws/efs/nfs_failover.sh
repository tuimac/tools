#!/bin/bash

FQDN='efs.tuimac.me'
PRIMARY_EFS='fs-b551fd95'
SECONDARY_EFS='fs-8c74a8cc'

sudo yum -y install amazon-efs-utils
aws route53 change-resource-record-sets --hosted-zone-id Z0037849QLDLVW42TQK4 --change-batch file://primary.json
mkdir efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${FQDN}:/ efs
sudo chmod -R 777 efs
touch efs/test_primary
ls efs
aws route53 change-resource-record-sets --hosted-zone-id Z0037849QLDLVW42TQK4 --change-batch file://secondary.json
sudo systemd-resolve --flush-caches
nslookup ${FQDN}
aws efs delete-file-system --file-system-id ${PRIMARY_EFS} --region ap-southeast-1
sudo umount -f -l efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${FQDN}:/ efs
sudo chmod -R 777 efs
touch efs/test_secondary
ls efs
