#!/bin/bash

IP='10.0.0.4'

docker exec -it gitlab-runner gitlab-runner register \
    --non-interactive \
    --registration-token '' \
    --url 'http://'${IP}':8000/' \
    --clone-url 'http://'${IP}':8000/' \
    --name 'test' \
    --tag-list 'test' \
    --run-untagged='true' \
    --builds-dir '/home/ec2-user/gitlab-runner-work' \
    --executor 'ssh' \
    --ssh-user 'ec2-user' \
    --ssh-host ${IP} \
    --ssh-port 22 \
    --ssh-password '' \
	--identity_file '/host_ssh_key/tuimac.pem' \
    --ssh-disable-strict-host-key-checking='true'
