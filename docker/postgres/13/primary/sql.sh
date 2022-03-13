#!/bin/bash

export PGPASSWORD='password'

psql -d test -U test -h localhost -c 'CREATE TABLE IF NOT EXISTS ITEMS (name varchar(255) PRIMARY KEY,count int);'
#psql -d test -U test -h localhost -c 'DROP TABLE ITEMS;'
