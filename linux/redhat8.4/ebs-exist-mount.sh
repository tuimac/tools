#!/bin/bash

DEVICE='/dev/nvme1n1'
MOUNT_POINT='/usr/sbin'
TARGET_UUID='8bf2a307-8044-4786-8c50-76b39bc5ccc3'

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
mkdir tmpdir
cp -r ${MOUNT_POINT}/* tmpdir/
mount $DEVICE $MOUNT_POINT
cp -r tmpdir/* ${MOUNT_POINT}/
echo 'UUID='${TARGET_UUID}' '${MOUNT_POINT}'                xfs     defaults,nofail 0 0' >> /etc/fstab
rm -rf tmpdir
