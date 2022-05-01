#!/bin/bash

DB_USER='test'
DB_PASSWORD='password'
DB_NAME='test'
DB_CONN='postgres://'${DB_USER}':'${DB_PASSWORD}'@localhost/'${DB_NAME}'?sslmode=disable\u0026connect_timeout=10\u0026binary_parameters=yes'

echo $DB_CONN

jq -r --arg DB_CONN "$DB_CONN" '.SqlSettings.DataSource = $DB_CONN' config.json > config_new.json
sed 's/\\\\/\\/g' config_new.json
mv config_new.json config.json
