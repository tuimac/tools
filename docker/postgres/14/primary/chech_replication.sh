#!/bin/bash

export PGPASSWORD='password'

psql -U test -d test -h localhost -c 'select * from pg_stat_replication;'
echo '########################################################################################'
psql -t -U test -d test -h localhost -c "select sync_state from pg_stat_replication where application_name = 'node1';"
echo '########################################################################################'
psql -U test -d test -h localhost -c 'select * from pg_stat_activity;'
