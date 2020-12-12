#!/bin/bash
LOG=/var/log/user-data.log
HOSTNAME=docker
DOMAIN=tuimac.private
touch $LOG
exec >> $LOG 2>&1
    yum update -y
    mkdir -p /etc/vim/undo
    mkdir -p /etc/vim/backup
    rm /etc/vimrc
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
    chmod -R 777 /etc/vim
    echo 'if [ -n "$BASH_VERSION" -o -n "$KSH_VERSION" -o -n "$ZSH_VERSION" ]; then
      [ -x /usr/bin/id ] || return
      ID=`/usr/bin/id -u`
      #[ -n "$ID" -a "$ID" -le 200 ] && return
      # for bash and zsh, only if no alias is already set
      alias vi >/dev/null 2>&1 || alias vi=vim
    fi' > /etc/profile.d/vim.sh
    yum install -y docker git
    systemctl enable docker
    usermod -aG docker ec2-user
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    cat <<EOF >> /etc/hosts
$IP $HOSTNAME ${HOSTNAME}.${DOMAIN}
EOF
    echo ${HOSTNAME}.${DOMAIN} > /etc/hostname
    su - ec2-user
    git clone https://github.com/tuimac/tools.git; echo "cloned"
    reboot
