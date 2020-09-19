#!/bin/bash

sudo mkdir /etc/vim/undo
sudo mkdir /etc/vim/backup
curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
sudo chmod -R 777 /etc/vim
