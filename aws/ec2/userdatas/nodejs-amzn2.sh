#!/bin/bash
LOG=/var/log/user-data.log
HOSTNAME=nodejs
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
    IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    cat <<EOF >> /etc/hosts
$IP $HOSTNAME ${HOSTNAME}.${DOMAIN}
    echo ${HOSTNAME}.${DOMAIN} > /etc/hostname
    curl -sL https://deb.nodesource.com/setup_12.x | bash -
    apt install nodejs
    export NG_CLI_ANALYTICS=ci
    npm install -g @angular/cli
EOF
    reboot
