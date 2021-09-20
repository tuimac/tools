#!/bin/bash

GITUSERNAME='tuimac'
PASSWORD=`curl http://node3/githubtoken`
NETRC='~/.netrc'

echo -en "machine github.com\nlogin ${GITUSERNAME}\npassword ${PASSWORD}\nprotocol https" > $NETRC
