#!/bin/bash

git clone https://github.com/jitsi/docker-jitsi-meet
cd docker-jitsi-meet
cp ../env .env
sudo rm -rf ~/.jitsi-meet-cfg
mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody,jicofo,jvb}
./gen-passwords.sh
docker volume rm $(docker volume ls -aq)
docker-compose up -d
