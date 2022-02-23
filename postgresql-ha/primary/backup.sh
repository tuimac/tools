#!/bin/bash

COMMAND='pg_basebackup -D /var/lib/pgsql/backup -Fp -Xs -P -R'
podman exec -it -u postgres postgresql ${COMMAND}
