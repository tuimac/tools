#!/bin/bash

PG_CONF='/var/lib/pgsql/data/postgresql.conf'
PG_HBA='/var/lib/pgsql/data/pg_hba.conf'
ARCHIVE_DIR='/var/lib/pgsql/archive'
PG_LOG_DIR='/var/log/postgresql'

[[ $USER -ne 'root' ]] && { echo 'Must be root!'; exit 1; }

# Install PostgreSQL13.3
yum module install postgresql:13/server
postgresql-setup --initdb
systemctl start postgresql.service
systemctl enable postgresql.service

# Configure database for Mattermost
sudo -u postgres -i psql -c "CREATE DATABASE mattermost WITH ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;"
sudo -u postgres -i psql -c "CREATE USER mmuser WITH PASSWORD 'mmuser-password';"
sudo -u postgres -i psql -c "GRANT ALL PRIVILEGES ON DATABASE mattermost to mmuser;"

# Configure PostgreSQL for Mattermost

## Create WAL Archive Directory
mkdir $ARCHIVE_DIR
chown postgres:postgres -R $ARCHIVE_DIR
chmod 700 -R $ARCHIVE_DIR

## Create Log Directory
mkdir $PG_LOG_DIR
chown postgres:postgres -R $PG_LOG_DIR
chmod 700 -R $PG_LOG_DIR

# Overwrite postgresql.conf
cat << EOF > $PG_CONF
listen_addresses = '*'
port = 5432
max_connections = 50
wal_level = minimal
archive_command = 'cp %p $ARCHIVE_DIR/%f'
archive_mode = on
ssl = off
timezone = 'Asia/Tokyo'
max_wal_size = 1GB
min_wal_size = 80MB
checkpoint_timeout = 5min
checkpoint_completion_target = 0.5
shared_buffers = 512MB
wal_buffers = 4MB
work_mem = 4MB
maintenance_work_mem = 64MB
log_directory '$PG_LOG_DIR'
log_filename 'postgresql-%a.log'
log_line_prefix='[%t]%u %d %p[%l]'
logging_collector on
log_min_messages INFO
log_min_error_statement ERROR
log_min_duration_statement 250ms
log_checkpoints on
log_timezone = 'Asia/Tokyo'
EOF

# Overwrite pg_hba.conf
cat << EOF > $PG_HBA
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            ident
host    all             all             ::1/128                 trust
local   replication     all                                     peer
host    replication     all             127.0.0.1/32           	ident
host    replication     all             ::1/128                 ident
EOF

# Reload configuration
systemctl reload postgresql
