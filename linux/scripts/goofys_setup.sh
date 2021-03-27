#!/bin/bash

BUCKET_NAME='000-transcriptor'
TARGET_DIR='goofys'

sudo apt install -y golang
wget https://github.com/kahing/goofys/releases/latest/download/goofys
chmod +x goofys
sudo mv goofys /usr/bin/goofys
goofys -v
[ $? -ne 0 ] && { echo Install goofys has been failed...; exit 1; }

aws s3 ls $BUCKET_NAME
[ $? -ne 0 ] && { echo Connection to S3 has been failed...; exit 1; }

[ ! -e ${TARGET_DIR} ] && mkdir ${TARGET_DIR}
goofys ${BUCKET_NAME} ${TARGET_DIR}

mv src/index.html ${TARGET_DIR}/index.html
