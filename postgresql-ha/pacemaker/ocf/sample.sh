#/bin/bash

RUN_USER='ec2-user'
CONTAINER='postgresql'
status=$(su $RUN_USER -c 'podman inspect --type=container --format {{.State.Status}} '$CONTAINER)
echo $status
