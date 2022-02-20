#!/bin/bash

status=$(su ec2-user -c 'docker inspect --type=container --format {{.State.Status}} postgresql' >> test.log)
echo $status
