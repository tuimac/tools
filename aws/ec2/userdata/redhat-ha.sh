#!/bin/bash
LOG=/var/log/user-data.log
touch $LOG
exec >> $LOG 2>&1
    yum update -y --releasever=8.4
    yum install -y git vim*
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
    echo "alias vi='vim'" >> /etc/profile
    su - ec2-user
    cd /home/ec2-user
    git clone https://github.com/tuimac/tools.git; echo "cloned"
    chown -R ec2-user:ec2-user /home/ec2-user/tools
    reboot
