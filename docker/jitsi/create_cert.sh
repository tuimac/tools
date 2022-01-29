#!/bin/bash

DOMAIN='jitsi.tuimac.me'

mkdir letsencrypt
cd letsencrypt
sudo apt install -y certbot
sudo certbot certonly --standalone -d ${DOMAIN}
sudo cp /etc/letsencrypt/archive/jitsi.tuimac.me/cert1.pem cert.pem
sudo cp /etc/letsencrypt/archive/jitsi.tuimac.me/chain1.pem chain.pem
sudo cp /etc/letsencrypt/archive/jitsi.tuimac.me/fullchain1.pem fullchain.pem
sudo cp /etc/letsencrypt/archive/jitsi.tuimac.me/privkey1.pem privkey.pem
sudo chown -R ${USER}:${USER} .
