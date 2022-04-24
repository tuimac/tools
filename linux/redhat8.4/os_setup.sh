#!/bin/bash

LOG='os_setup.log'
HOST_NAME='devtest'
INSTALL_MODULES=''
LDAP_SERVER='ldap.tuimac.com'
BASE_DN='dc=tuimac,dc=com'
AUDIT_LOG_DIR='/var/log/os/audit'
SCRIPT_LOG_DIR='/var/log/os/script'
REGION='ap-northeast-3'
CW_PARAM_STORE='cloudwatch'
MEM_SIZE='2'

function update_modules(){
    echo '8.4' > /etc/yum/vars/releasever
    echo '8.4' > /etc/dnf/vars/releasever
    dnf update -y
    sleep 1
    dnf install -y python3-pip
    pip3 install --upgrade requests
    if [ ! -z $INSTALL_MODULES ]; then
        dnf install -y $INSTALL_MODULES
    fi
    cat /etc/redhat-release
    cat /etc/os-release
}

function config_audit(){
    local config='/etc/audit/auditd.conf'
    local rule_config='/etc/audit/rules.d/audit.rules'
    mkdir -p $AUDIT_LOG_DIR

    sed -i "s|log_file = \/var\/log\/audit\/audit.log|log_file = ${AUDIT_LOG_DIR}\/audit.log|g" $config
    echo '-a exit,always -F arch=b32 -S execve -k auditcmd' >> $rule_config
    echo '-a exit,always -F arch=b64 -S execve -k auditcmd' >> $rule_config

    cat $config
    cat $rule_config

    mkdir -p $SCRIPT_LOG_DIR

    cat <<EOF >> /etc/profile

# Script
P_PROC=\`ps aux | grep \$PPID | grep sshd | awk '{ print \$11 }'\`
if [ "\$P_PROC" = sshd: ]; then
  script -q $SCRIPT_LOG_DIR/\`whoami\`_\`date '+%Y%m%d%H%M%S'\`.log
  exit
fi
EOF
    chmod 666 -R $SCRIPT_LOG_DIR
    cat /etc/profile
}

function config_selinux(){
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    cat /etc/selinux/config
}

function update_hostname(){
    hostnamectl set-hostname ${HOST_NAME}
    cat /etc/hostname 
}

function update_timezone(){
    timedatectl set-timezone Asia/Tokyo
    date
}

function config_cloudinit(){
    local config='/etc/cloud/cloud.cfg'
    sed -i 's/^ssh_pwauth:   0/ssh_pwauth:   1/g' $config
    sed -i '12 a preserve_hostname: true' $config
    sed -i '13 a repo_upgrade: none' $config
    cat $config
}

function config_sshd(){
    local config='/etc/ssh/sshd_config'
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/g' $config
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' $config
    systemctl restart sshd
}

function install_sssd(){
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

function install_ssmagent(){
    dnf install -y https://s3.${REGION}.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    sleep 1
    systemctl status amazon-ssm-agent
}

function install_cloudwatchagent(){
    rpm -U https://s3.${REGION}.amazonaws.com/amazoncloudwatch-agent-${REGION}/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${CW_PARAM_STORE}
    systemctl enable amazon-cloudwatch-agent
    systemctl start amazon-cloudwatch-agent
    sleep 1
    systemctl status amazon-cloudwatch-agent
}

function config_history(){
    cat <<EOF >> /etc/profile

# Custom History
export HISTTIMEFORMAT=\"%d/%m/%y %T \"
EOF
    cat /etc/profile
}

function install_tdagent(){
    rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
    cat <<EOF > /etc/yum.repos.d/td.repo
[treasuredata]
name=TreasureData
baseurl=http://packages.treasuredata.com/4/redhat/8/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF
    yum install -y td-agent
    chmod 644 -R /var/log
    systemctl enable td-agent
    systemctl start td-agent
    sleep 1
    systemctl status td-agent
}

function create_swap(){
    local swapfile='/swap/swapfile'
    [[ ! -d /swap ]] && { mkdir /swap; }
    dd if=/dev/zero of=$swapfile bs=1024M count=$MEM_SIZE
    chmod 600 $swapfile
    mkswap $swapfile
    swapon $swapfile
    swapon -s
    sh -c 'echo "/swap/swapfile swap swap defaults 0 0" >> /etc/fstab'
    cat /etc/fstab
}

function main(){
    [[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }
    echo -en '\n####### update_modules #######\n' | tee -a -a $LOG
    update_modules >> $LOG 2>&1
    echo -en '\n####### config_audit #######\n' | tee -a $LOG
    config_audit >> $LOG 2>&1
    echo -en '\n####### config_selinux #######\n' | tee -a $LOG
    config_selinux >> $LOG 2>&1
    echo -en '\n####### update_hostname #######\n' | tee -a $LOG
    update_hostname >> $LOG 2>&1
    echo -en '\n####### update_timezone #######\n' | tee -a $LOG
    update_timezone >> $LOG 2>&1
    echo -en '\n####### config_cloudinit #######\n' | tee -a $LOG
    config_cloudinit >> $LOG 2>&1
    echo -en '\n####### config_sshd #######\n' | tee -a $LOG
    config_sshd >> $LOG 2>&1
    echo -en '\n####### install_sssd #######\n' | tee -a $LOG
    install_sssd >> $LOG 2>&1
    echo -en '\n####### install_ssmagent #######\n' | tee -a $LOG
    install_ssmagent >> $LOG 2>&1
    echo -en '\n####### install_cloudwatchagent #######\n' | tee -a $LOG
    install_cloudwatchagent >> $LOG 2>&1
    echo -en '\n####### config_history #######\n' | tee -a $LOG
    config_history >> $LOG 2>&1
    echo -en '\n####### install_tdagent #######\n' | tee -a $LOG
    install_tdagent >> $LOG 2>&1
    echo -en '\n####### create_swap #######\n' | tee -a $LOG
    create_swap >> $LOG 2>&1
    echo -en '\n####### reboot #######\n' | tee -a $LOG
    reboot
}

main
