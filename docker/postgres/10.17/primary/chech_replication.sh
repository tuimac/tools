#!/bin/bash

export PGPASSWORD='password'

psql -U test -h localhost -c 'select * from pg_stat_replication;'
