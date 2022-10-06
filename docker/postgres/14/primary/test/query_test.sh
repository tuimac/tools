#!/bin/bash

DB_USER='test'
DB='test'
DB_HOST='localhost'
COUNT='100'

function long_query(){
    echo 'long_query'
}

function many_query(){
    export PGPASSWORD='password'
    psql -U $DB_USER -d $DB -h $DB_HOST -c 'DROP TABLE ITEMS;'
    psql -U $DB_USER -d $DB -h $DB_HOST -c 'CREATE TABLE ITEMS (id SERIAL, name varchar(255), count int);'
    for((i=0; $i < $COUNT; i++)); do
        local name=$RANDOM'-'$RANDOM'-'$RANDOM
        psql -U $DB_USER -d $DB -h $DB_HOST -c 'INSERT INTO ITEMS (name, count) VALUES ('${name}', '$i');'       
    done
}

function list_table_data(){
    psql -U $DB_USER -d $DB -h $DB_HOST -c 'SELECT * FROM ITEMS;'
}

function main(){
    case $1 in
        'many')
            time many_query;;
        'long')
            time long_query;;
        'show')
            list_table_data;;
        *)
            echo 'Need argument.'
            exit 1;;
    esac

}

main $1
