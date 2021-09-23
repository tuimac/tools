#!/bin/bash

GITUSERNAME='tuimac'
NETRC=~/.netrc

echo -en "GitHub Password: "
read -s PASSWORD

echo -en "machine github.com\nlogin ${GITUSERNAME}\npassword ${PASSWORD}\nprotocol https" > $NETRC
