#!/bin/bash

sudo rm -rf backup/*
COMMAND='pg_basebackup -D /var/lib/postgresql/backup -Fp -Xs -P -R -U test'
podman exec -it -u postgres postgresql ${COMMAND}
sudo zip -r backup.zip backup/*
aws s3 cp backup.zip s3://tuimac000
rm -f backup.zip
