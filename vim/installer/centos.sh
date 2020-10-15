#!/bin/bash

mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vimrc
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
chmod -R 777 /etc/vim

echo 'if [ -n "$BASH_VERSION" -o -n "$KSH_VERSION" -o -n "$ZSH_VERSION" ]; then
  #[ -x /usr/bin/id ] || return
  ID=`/usr/bin/id -u`
  #[ -n "$ID" -a "$ID" -le 200 ] && return
  # for bash and zsh, only if no alias is already set
  alias vi >/dev/null 2>&1 || alias vi=vim
fi' > /etc/profile.d/vim.sh
