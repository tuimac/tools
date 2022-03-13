#!/bin/bash

export PGPASSWORD='password'

docker exec -it postgresql psql -U test -h localhost -c 'select * from pg_stat_replication;'
echo '########################################################################################'
docker exec -it postgresql psql -U test -h localhost -c 'select * from pg_stat_activity;'
