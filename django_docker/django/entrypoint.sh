#!/bin/bash

python /root/mysite/manage.py migrate

exec "$@"
