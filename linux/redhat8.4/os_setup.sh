#!/bin/bash

LOG='os_setup.log'
HOST_NAME=''
INSTALL_MODULES=''
LDAP_SERVER=''
BASE_DN=''

function 

function install_sssd(){
    echo '## install_sssd'
    dnf install oddjob-mkhomedir sssd -y
    cat <<EOF > /etc/sssd/sssd.conf
[sssd]
debug_level = 6
config_file_version = 2
services = nss, sudo, pam, ssh
domains = default

[domain/default]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
sudo_provider = ldap
ldap_sudo_search_base = ou=SUDOers,$BASE_DN
ldap_uri = ldaps://$LDAP_SERVER
ldap_search_base = $BASE_DN
ldap_id_use_start_tls = True
cache_credentials = False
ldap_tls_reqcert = never

[nss]
homedir_substring = /home
entry_negative_timeout = 20
entry_cache_nowait_percentage = 50

[pam]

[sudo]

[autofs]

[ssh]

[pac]
EOF
    chmod 600 /etc/sssd/sssd.conf
    systemctl restart sssd
    authconfig --enablemkhomedir --update
    authconfig --enableldap --update
    authconfig --enableldapauth --update
    authconfig --enableshadow --update
    authconfig --enablelocauthorize --update
    systemctl status sssd
}

function config_sshd(){
    echo -en '\n## config_sshd'
    local config='/etc/ssh/sshd_config'
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/g'
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g'
    systemctl restart sshd
}

function config_cloudinit(){
    echo -en '\n## config_cloudinit'
    local config='/etc/cloud/cloud.cfg'
    sed -i 's/^ssh_pwauth:   0/ssh_pwauth:   1/g' $config
    sed -i '12 a preserve_hostname: true' $config
}

function update_hostname(){
    echo -en '\n## update_hostname'
    echo $HOST_NAME > /etc/hostname
    cat /etc/hostname 
}

function update_modules(){
    echo '## update_modules'
    echo '8.4' > /etc/yum/vars/releasever
    echo '8.4' > /etc/dnf/vars/releasever
    dnf update -y
    if [ ! -z $INSTALL_MODULES ]; then
        dnf install -y $INSTALL_MODULES
    fi
    cat /etc/redhat-release
    cat /etc/os-release
}

function main(){
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
    update_modules >> $LOG 2>&1
    update_hostname >> $LOG 2>&1
    config_cloudinit >> $LOG 2>&1
    config_sshd >> $LOG 2>&1
    install_sssd >> $LOG 2>&1
    install_ssmagent >> $LOG 2>&1
}

main
