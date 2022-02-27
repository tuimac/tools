#!/bin/bash

SQL="CREATE TABLE IF NOT EXISTS ITEMS (name varchar(255) PRIMARY KEY,count int);"

echo $SQL | podman exec -i -u postgres postgresql psql -d test -U test -h localhost
