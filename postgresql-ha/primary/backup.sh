#!/bin/bash

COMMAND='pg_basebackup -D /var/lib/pgsql/backup -F tar -z'
podman exec -it -u postgres postgresql ${COMMAND}
