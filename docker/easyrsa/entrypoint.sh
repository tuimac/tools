#!/bin/bash

BASEDIR='/root/certs'

function generateCert(){
    mkdir -p $BASEDIR
    cd $BASEDIR
    ./easyrsa init-pki
    if [ ! -z $CLIENTPASS ]
    ./easyrsa --batch build-ca nopass
    ./easyrsa gen-dh
    openvpn --genkey --secret ${EASYRSA}/pki/ta.key
    ./easyrsa build-server-full ${SERVERCERTNAME} nopass
    ./easyrsa build-client-full ${CLIENTCERTNAME} nopass
    mv ${EASYRSA}/pki/ca.crt ${SERVERDIR}
    mv ${EASYRSA}/pki/issued/${SERVERCERTNAME}.crt ${SERVERDIR}
    mv ${EASYRSA}/pki/private/${SERVERCERTNAME}.key ${SERVERDIR}
    mv ${EASYRSA}/pki/ta.key ${SERVERDIR}
    mv ${EASYRSA}/pki/dh.pem ${SERVERDIR}
    mv ${EASYRSA}/pki/issued/${CLIENTCERTNAME}.crt ${CLIENTDIR}
    mv ${EASYRSA}/pki/private/${CLIENTCERTNAME}.key ${CLIENTDIR}
    echo '#######################################################'
    echo '#  Finish to generate certification. please download. #'
    echo '#######################################################'
}

function main(){

}

main
