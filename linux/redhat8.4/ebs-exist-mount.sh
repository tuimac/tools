#!/bin/bash

DEVICE='/dev/nvme1n1'
MOUNT_POINT='/usr/bin'
TARGET_UUID='18ff16ce-a2c4-4339-be9f-778375d5378a'

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
mount $DEVICE /data
cp -r ${MOUNT_POINT}/* /data
umount /data
echo 'UUID='${TARGET_UUID}' '${MOUNT_POINT}'                xfs     defaults,nofail 0 0' >> /etc/fstab
