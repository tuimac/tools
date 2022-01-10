#!/bin/bash

IP='10.3.0.212'

scp test@${IP}:~/volume.zip .
unzip volume.zip
cp recovery.conf volume/
