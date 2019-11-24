#This script back up kvm image and take snapshot.
#You can back up automatically if you execute this script by crond.
#Caution:
#If you take daily back up by this script, you have to consider capacity of volume because KVM images are so large.
#Only take daily snapshot, then you can comment out following function :backup_image()

#!/bin/bash

#Initial variables
BASEDIR="/var/lib/libvirt"
BKUPDIR="${BASEDIR}/img_bk"
SNAPSHOTDIR="${BASEDIR}/qemu/snapshot"
DATE=`date "+%Y%m%d_%H%M%S"`
BKGENE=4

#If get error, exit from this script.
function error(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is failed!!"
        exit 1
    fi
}

#Check execution authorization.
function check_auth(){
    if [ $USER != "root" ]; then
        echo "Must be root!!"
        exit 1
    fi
}

#Remove backup image
function bkimage_lotate(){
    COUNT=0
    ls -lt ${BKUPDIR}/${1} | while read NAME; do
        if [ $COUNT -ge $BKGENE ]; then
            NAME=`echo $NAME | awk '{print $9}'`
            rm -f ${BKUPDIR}/${1}/${NAME}
        fi
        COUNT=$(($COUNT+1))
    done
}

#Remove snapshot
function snapshot_lotate(){
    COUNT=0
    ls -lt ${SNAPSHOTDIR}/${1} | while read NAME; do
        if [ $COUNT -ge $BKGENE ]; then
            NAME=`echo $NAME | awk '{print $9}'`
            rm -f ${SNAPSHOTDIR}/${1}/$NAME
        fi
        COUNT=$(($COUNT+1))
    done    
}

#Whether status of target instance is "shut off" or not.
function check_status(){
    STATUS=`virsh domstate $1`
    error $? "check_status for $1"
    if [[ $STATUS =~ 'running' ]]; then
        echo "$1 must be shutdown!!" 2>&1
        return 0
    fi
    return 1
}

#Make sure there are backup directory or not.
function is_backupdir(){
    [ ! -d "$BKUPDIR" ] && mkdir $BKUPDIR
    DOMBKDIR="$BKUPDIR/$1"
    [ ! -d "$DOMBKDIR" ] && mkdir $DOMBKDIR
    echo $DOMBKDIR
}

#Copy instance image to backup directory.
function backup_image(){
    ls | while read FILES; do
        [[ -z $FILES ]] && exit 0
        if [[ $FILES =~ $1 && $FILES =~ ".img" ]]; then
            cp -vu $FILES ${2}/${DATE}_${1}.img
            error $? "Backup $FILES is failed!!"
        fi
    done
}

#Create XML snapshot which the name is "date_domainname.xml".
function create_snapshot(){
    NAME="${DATE}_${1}"
    virsh snapshot-create-as $1 $NAME
    #error $? $1
}

#Main function to call other function.
function main(){
    check_auth
    virsh list --name --all | while read DOM_NAME; do
        [[ -z $DOM_NAME ]] && exit 0
        bkimage_lotate $DOM_NAME
        snapshot_lotate $DOM_NAME
        cd ${BASEDIR}/images
        RESULT=$(check_status $DOM_NAME)
        if [ -z $RESULT ]; then
            DOMBKDIR=`is_backupdir $DOM_NAME`
            backup_image $DOM_NAME $DOMBKDIR
            create_snapshot $DOM_NAME
        fi
    done
    systemctl restart libvirtd
}

#Call main function.
main
