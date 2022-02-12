#!/bin/bash

mkdir volume

podman unshare chown 0:0 volume/

podman run -itd \
    --name nginx \
    -p 8000:80 \
    --log-driver journald \
    -v $(pwd)/volume:/var/log/nginx:Z \
    nginx
