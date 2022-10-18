#!/bin/bash

PREFIX_LIST_ID='pl-04d59afb8311fc1b7'
IP_LISTS=(
    'ubi_ip1'
    'ubi_ip2'
    'rhui'
)
DESCRIPTIONS=(
    'ubi-repository'
    'ubi-repository'
    'rhui'
)
VERSION=1

for list_file in ${IP_LISTS[@]}; do
    ENTRY=''
    while read line; do
        ENTRY=$ENTRY' Cidr='$line',Description='${DESCRIPTIONS[$VERSION]}
    done < $list_file
    aws ec2 modify-managed-prefix-list \
        --prefix-list-id $PREFIX_LIST_ID \
        --add-entries $ENTRY \
        --current-version $VERSION
    (( VERSION++ ))
done
