#!/bin/bash

mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vim/vimrc.local
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc.local
chmod -R 777 /etc/vim
