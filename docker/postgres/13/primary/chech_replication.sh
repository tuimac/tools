#!/bin/bash

export PGPASSWORD='password'

docker exec postgresql psql -U test -h localhost -c 'select * from pg_stat_replication;'
echo '########################################################################################'
docker exec postgresql psql -t -U test -h localhost -c "select sync_state from pg_stat_replication where application_name = 'node1';"
echo '########################################################################################'
docker exec postgresql psql -U test -h localhost -c 'select * from pg_stat_activity;'
