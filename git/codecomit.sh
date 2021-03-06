#!/bin/bash

NETRC=~/.netrc
EMAIL='tuimac.devadm01@gmail.com'

echo -en 'CodeCommit Username: '
read username
echo -en 'CodeCommit Password: '
read -s password
echo ''

touch $NETRC
echo -en "machine git-codecommit.ap-northeast-1.amazonaws.com\nlogin ${username}\npassword ${password}\nprotocol https" > $NETRC

#sudo apt install gnupg-agent pinentry-curses -y
#gpg -e -r ${EMAIL} ${NETRC}
#gpg --gen-key
#gpg -e -r ${EMAIL} ${NETRC}
#rm ${NETRC}
#
#target="/usr/share/doc/git/contrib/credential/netrc/git-credential-netrc"
#result=`ls -al ${target} 2> /dev/null | awk '{print $1}' 2> /dev/null`
#
#if [ -z $result ]; then
#    sudo ls / > /dev/null 2>&1
#    if [ $? -eq 0 ]; then
#        target=`sudo find /usr | grep git-credential-netrc`
#    else
#        target=`find /usr | grep git-credential-netrc`
#    fi
#    if [ -z $target ]; then
#        result=''
#    else
#        result=`ls -al ${target} | awk '{print $1}' 2> /dev/null`
#    fi
#fi
#if [ -z $result ]; then
#    git config --global credential.helper "netrc -d -v"
#else
#    if [ ! $result == "-rwxr-xr-x" ]; then
#        [[ ! $USER == "root" ]] && { echo -en "\nchmod need sudo privillege\n";}
#        sudo chmod +x ${target}
#    fi
#    git config --global credential.helper ${target}
#fi
#
#
#git config --global --get user.email ${EMAIL}
#git config --global --get user.name ${username}
