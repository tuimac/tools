#!/bin/bash

IP='primary'

scp test@${IP}:~/volume.zip .
unzip volume.zip
cp recovery.conf volume/
