#!/bin/bash

for container in $(podman ps -aq); do
    echo $container
done
