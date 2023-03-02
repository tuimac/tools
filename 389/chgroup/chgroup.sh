#!/bin/bash

MGR_PW='P@ssw0rd'
BASE_DN='dc=tuimac,dc=com'
USER_OU='People'

function createLdif(){
    local tmpldif=$1
    local username=$2
    local gid=$3
    cat <<EOF >> $tmpldif
dn: cn=$username,ou=$USER_OU,$BASE_DN
changetype: modify
add: gidNumber
gidNumber: 1000
EOF
    echo -en '\n-\n' >> $TMP_LDIF
}

function main(){
    local userList=$1
    local tmpldif=${RANDOM}.ldif
    while read line; do
        local username=`echo $line | awk '{print $1}'`
        local gid=`echo $line | awk '{print $2}'`
        createLdif $tmpldif $username $gid
    done < $userList
    ldapadd -x -D "cn=Directory Manager" -w $MGR_PW -f $tmpldif
    if [ $? -ne 0 ]; then
        echo 'Add user was failed!'
        rm $TMP_LDIF
        exit 1
    else
        echo 'Add user was successed!'
        rm $TMP_LDIF
    fi
    rm $tmpldif
}

main $1
