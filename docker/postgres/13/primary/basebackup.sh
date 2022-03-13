#!/bin/bash

sudo rm -rf backup/*
COMMAND='pg_basebackup -R -D /var/lib/postgresql/backup -U test'
podman exec -it -u postgres postgresql ${COMMAND}
sudo zip -r backup.zip backup/*
aws s3 cp backup.zip s3://tuimac000
rm -f backup.zip
