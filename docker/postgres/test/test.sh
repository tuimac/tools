#!/bin/bash

DB='test'
DB_USER='test'
export PGPASSWORD='password'
HOST='primary-public'

function create(){
    psql ${DB} -U ${DB_USER} -h ${HOST} -c 'CREATE TABLE IF NOT EXISTS ITEMS (name varchar(255) PRIMARY KEY,count int);'

    COUNT=0
    while true; do
        psql ${DB} -U ${DB_USER} -h ${HOST} -c "INSERT INTO ITEMS (name, count) VALUES ('"${COUNT}"', '${COUNT}');"
        COUNT=`expr $COUNT + 1`
        sleep 1
    done
}

function delete(){
    psql ${DB} -U ${DB_USER} -h ${HOST} -c 'DROP TABLE ITEMS;'
}

function main(){
    [[ -z $1 ]] && { echo 'failed'; exit 1; }
    if [ $1 == "create" ]; then
        create
    elif [ $1 == "delete" ]; then
        delete
    fi
}

main $1
