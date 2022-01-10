#!/bin/bash

sudo zip -r volume.zip volume/
sudo mv volume.zip /home/test
sudo chown test:test /home/test/volume.zip
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo systemctl restart sshd
