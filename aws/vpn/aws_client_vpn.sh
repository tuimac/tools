#!/bin/bash

BASEDIR='/home/ubuntu/test'
VPNVPCID=''
VPNSECURITYGROUPID=''
CLIENTCIDR=''
CERTDIR=${BASEDIR}/ca/certs
VPNREGION=''

function installTools(){
    sudo apt install -y easy-rsa openvpn
    jq -h
    [[ $? -ne 0 ]] && { sudo apt install -y jq;  }
    aws --version
    [[ $? -ne 0 ]] && { sudo apt install -y awscli; }
    aws configure list | grep region | grep None
    if [ $? -ne 1 ]; then
        mkdir ~/.aws
        echo -en '[default]\nregion = '${VPNREGION} > ~/.aws/config
    fi
}

function generateCerts(){
    [[ ! -e $BASEDIR ]] && { mkdir $BASEDIR; }
    cd $BASEDIR
    make-cadir ca
    cd ca
    ./easyrsa init-pki
    ./easyrsa --batch build-ca nopass
    ./easyrsa build-server-full server nopass
    ./easyrsa build-client-full client nopass
    cd ..
    mkdir $CERTDIR
    cp ca/pki/ca.crt $CERTDIR
    cp ca/pki/issued/server.crt $CERTDIR
    cp ca/pki/private/server.key $CERTDIR
    cp ca/pki/issued/client.crt $CERTDIR
    cp ca/pki/private/client.key $CERTDIR
}

function importServerCerts(){
    cd $CERTDIR
    SERVER_ACM_ARN=$(aws acm import-certificate \
        --certificate file://server.crt \
        --private-key file://server.key \
        --certificate-chain file://ca.crt \
        --region $VPNREGION \
        --tag Key=Name,Value='AWS_Client_VPN_Server_Cert' \
        | jq -r .CertificateArn)
    CLIENT_ACM_ARN=$(aws acm import-certificate \
        --certificate file://client.crt \
        --private-key file://client.key \
        --certificate-chain file://ca.crt \
        --region $VPNREGION \
        --tag Key=Name,Value='AWS_Client_VPN_Client_Cert' \
        | jq -r .CertificateArn)
    echo $ACM_ARN
}

function createVPNEndpoint(){
    aws ec2 create-client-vpn-endpoint \
        --client-cidr-block ${CLIENTCIDR} \
        --server-certificate-arn ${SERVER_ACM_ARN} \
        --authentication-options Type=certificate-authentication,MutualAuthentication={ClientRootCertificateChainArn=${CLIENT_ACM_ARN}} \
        --connection-log-options Enabled=false \
        --dns-servers "10.3.0.2" \
        --vpn-port 443 \
        --transport-protocol udp \
        --security-group-ids ${VPNSECURITYGROUPID} \
        --vpc-id ${VPNVPCID}
}

function main(){
    installTools
    generateCerts
    importServerCerts
    createVPNEndpoint
}

main
