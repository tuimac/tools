#!/bin/bash

mkdir -p /etc/vim/undo
mkdir -p /etc/vim/backup
rm /etc/vimrc
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
chmod -R 777 /etc/vim
