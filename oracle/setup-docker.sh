#!/bin/bash

# First things first, you need to download the zip file to create docker image from the module you download from Oracle Account

git clone https://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase/SingleInstance/dockerfiles

mv ~/Downloads/LINUX.X64_193000_db_home.zip ./19.3.0/

./buildContainerImage.sh -v 19.3.0 -e

docker ps -a

