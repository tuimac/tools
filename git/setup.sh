#!/bin/bash

GITUSERNAME='tuimac'
NETRC=~/.netrc

echo -en "GitHub Password: "
read -s PASSWORD
echo ''

git config --global user.email "tuimac.devadm01@gmail.com"
git config --global user.name "tuimac"

echo -en "machine github.com\nlogin ${GITUSERNAME}\npassword ${PASSWORD}\nprotocol https" > $NETRC
