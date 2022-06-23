#!/bin/bash

docker run -itd --name test \
    -p 80:80 \
    -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
    -v $(pwd)/webapp:/usr/share/nginx \
    nginx
