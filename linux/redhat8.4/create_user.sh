#!/bin/bash

USER_NAME='deploy'

sudo useradd -u 2000 -U -s /bin/bash -c 'Podman deploy user' -m -k /etc/skel ${USER_NAME}
