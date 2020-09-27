#!/bin/bash

sudo mkdir -p /etc/vim/undo
sudo mkdir -p /etc/vim/backup
sudo rm /etc/vimrc
sudo curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vimrc
sudo chmod -R 777 /etc/vim
