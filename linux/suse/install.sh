#!/bin/bash

INSTALL_PACKAGE='test.zip'
HOSTNAME='test'
FQDN=${HOSTNAME}'.local'
IPADDR='10.3.0.222'

function install_by_zypper(){
    echo '################## '${FUNCNAME[0]}' ##################'
    rm /etc/SUSEConnect
    rm -f /etc/zypp/{repos,services,credentials}.d/*
    rm -f /usr/lib/zypp/plugins/services/*
    sed -i '/^# Added by SMT reg/,+1d' /etc/hosts
    /usr/sbin/registercloudguest --force-new

    zypper update -y
    zypper install -y libgcc_s1 libstdc++6 libatomic1 libltdl7 insserv
    echo 4 > $LOG
    reboot
}

function check_hostname(){
    echo '################## '${FUNCNAME[0]}' ##################'
    if [ $FQDN != $(cat /etc/hostname) ]; then
        echo 'Hostname is wrong.'
        exit 1
    fi
    local line=${IPADDR} ${FQDN} ${HOSTNAME}
    if [[ $line != $(tail -n 1 /etc/hosts) ]]; then
        echo 'Hosts is wrong.'
        exit 1
    fi
    echo 3 > $LOG
}

function set_hostname(){
    echo '################## '${FUNCNAME[0]}' ##################'
    sed -i 's/preserve_hostname: false/preserve_hostname: true/' /etc/cloud/cloud.cfg
    echo ${FQDN} > /etc/hostname
    echo ${IPADDR} ${FQDN} ${HOSTNAME} >> /etc/hosts
    hostnamectl
    cat /etc/hosts
    echo 2 > $LOG
    reboot
}

function unzip_installer(){
    echo '################## '${FUNCNAME[0]}' ##################'
    #unzip $INSTALL_PACKAGE
    echo 1 > $LOG
}

function main(){
    LOG='.history_install.log'
    [[ ! -e $LOG ]] && { echo 0 > $LOG; }

    while true
    do
        FLAG=$(cat $LOG)
        case $FLAG in
            0)
                unzip_installer
                ;;
            1)
                set_hostname
                ;;
            2)
                check_hostname
                ;;
            3)
                install_by_zypper
                ;;
            *)
                rm ${LOG}
                exit 0;;
        esac
    done
}

[[ $USER != 'root' ]] && { echo 'Must be root!!'; exit 1; }
main
