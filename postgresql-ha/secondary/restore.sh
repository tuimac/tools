#!/bin/bash

sudo rm -rf volume
aws s3 cp s3://tuimac000/backup.zip .
unzip backup.zip
mv backup/ volume/
rm -f backup.zip
