#!/bin/bash

#################### How to use this script ####################
# This script is used for taking snapshot by libvirtd
# after target VMs has been shutted down.
#
# You can modify variables below for control backup.
#
# SUFFIX 
# => This variable is used for creating snapshot names and
#    detect snapshots are created by this script.
# 
# DOMAINS
# => These variables are used for directing domains.
#    
# GENERATIONS
# => These variables are used for defining number of snapshot
#    you retain by every domains. If you target two domains of
#    domains, you have to set DOMAINS and GENERATIONS list
#    like below.
#
#    ex)
#       DOMAINS=("test1" "test2")
#       GENERATIONS=(10 20)
#
#################################################################

########### Variables ###########
SUFFIX="autosnapshot"
DOMAINS=("test1" "test2")
GENERATIONS=(5 10)
#################################

######################################
# Don't need to modify below scripts #
######################################

function snapshot(){
    local domain=$1
    local status=`virsh domstate $domain | tr -d '[:space:]'`
    local snapshotName=`date +%Y%m%d%H%M%S`-${domain}-${SUFFIX}

    if [[ $status == "running" ]]; then
        virsh shutdown $domain
    fi
    while [[ $status != "shutoff" ]]; do
        status=`virsh domstate $domain | tr -d '[:space:]'`
    done
    virsh snapshot-create-as $domain $snapshotName
}

function lotateSnapshots(){
    local domain=$1
    local gene=$2
    local index=0
    local deleteGene=0
    local currentGene=`virsh snapshot-list $domain --name | grep ${SUFFIX} | wc -l`
    
    if [[ $gene -lt $currentGene ]]; then
        deleteGene=$((currentGene - gene))
        virsh snapshot-list $domain --name | grep ${SUFFIX} | while read snapshotName; do
            ((index++))
            virsh snapshot-delete $domain $snapshotName
            [[ $index -ge $deleteGene ]] && { break; }
        done
    fi
}

function startInstance(){
    local domain=$1
    virsh start $domain
}

function main(){
	local domainLen=${#DOMAINS[@]}
	local generationLen=${#GENERATIONS[@]}

    [[ $domainLen -ne $generationLen ]] && { exit 1; }

    for((i=0; $i < $domainLen; i++)); do
        snapshot ${DOMAINS[$i]}
        lotateSnapshots ${DOMAINS[$i]} ${GENERATIONS[$i]}
        startInstance ${DOMAINS[$i]}
    done
}

main
