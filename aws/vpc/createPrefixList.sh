#!/bin/bash

PREFIX_LIST_ID='pl-09ba5c726a98c0b0f'
IP_LIST='redhat_ip2.list'
DESCRIPTION='redhat-repository'
ENTRY=''

while read line; do
    ENTRY=$ENTRY' Cidr='$line',Description='$DESCRIPTION
done < $IP_LIST
aws ec2 modify-managed-prefix-list \
    --prefix-list-id $PREFIX_LIST_ID \
    --add-entries $ENTRY \
    --current-version 2
