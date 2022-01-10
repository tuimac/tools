#!/bin/bash

IP='10.3.0.212'

scp test@${IP}:~/volume.zip .
unzip volume.zip
mv recovery.conf volume/
