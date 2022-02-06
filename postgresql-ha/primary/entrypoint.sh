#!/bin/bash
initdb
mv /etc/postgresql.conf ${PGDATA}/postgresql.conf
mv /etc/pg_hba.conf ${PGDATA}/pg_hba.conf
postgres #-c config_file=/etc/postgresql/postgresql.conf -c hba_file=/etc/postgresql/pg_hba.conf
