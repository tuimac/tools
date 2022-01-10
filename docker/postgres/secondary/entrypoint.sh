#!/bin/bash

DATA='/var/lib/postgresql/data'

echo 'standby_mode = on' >> ${DATA}/recovery.conf
echo "primary_conninfo = 'host=10.3.0.212 port=5432 user=test password=password'" >> ${DATA}/recovery.conf
