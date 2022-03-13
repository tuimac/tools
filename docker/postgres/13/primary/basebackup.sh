#!/bin/bash

sudo rm -rf backup/*
COMMAND='pg_basebackup -R -D /var/lib/postgresql/backup -U test'
docker exec -it postgresql ${COMMAND}
sudo zip -r backup.zip backup/*
MD5=`openssl md5 -binary backup.zip | base64`
aws s3 cp backup.zip s3://tuimac000 --metadata 'md5="'${MD5}'"'
rm -f backup.zip
