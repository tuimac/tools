#!/bin/bash

export PGPASSWORD='password'

podman exec -it postgresql psql -U test -h localhost -c 'select * from pg_stat_replication;'
