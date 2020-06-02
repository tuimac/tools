#!/bin/bash

NETWORKADDR="192.168.0.0/24"
TARGETIP="192.168.1.45"
BITLENGTH=32
NETWORK_BIT=0
NETMASK_BIT=0
IPADDR_BIT=0

function print_list(){
    tmplist=($@)
    for((i=0; $i < ${#tmplist[@]}; i++)); do
        printf ${tmplist[i]}
    done
    echo ""
    return 0
}

function networkaddr_to_bin(){
    local INDEX=0
    local NETMASK=0
    local IPADDR

    for X in ${1//// }; do
        [[ $INDEX -eq 0 ]] && IPADDR=`echo $X`
        [[ $INDEX -eq 1 ]] && NETMASK=`echo $X`
        ((INDEX++))
    done
    NETMASK_BIT=$((((2 ** BITLENGTH) - (2 ** (BITLENGTH - NETMASK)))))
    for X in ${IPADDR//./ }; do
        NETWORK_BIT=$(((NETWORK_BIT << 8) | X))
    done
    return 0
}

function targetip_to_bin(){
    for X in ${1//./ }; do
        IPADDR_BIT=$(((IPADDR_BIT << 8) | X))
    done
    return 0
}

function filter_ip(){
    local TMP=$1
    echo $1
    echo $2
    echo $3
    TMP=$((TMP & $2))
    echo $TMP
    [[ ! $TMP -eq $3 ]] && { echo -e "This IP is outofrange"; exit 1; }
    echo -e "Valid"
    return 0
}

function main(){
    networkaddr_to_bin $NETWORKADDR
    targetip_to_bin $TARGETIP
    filter_ip $IPADDR_BIT $NETMASK_BIT $NETWORK_BIT
}

main
