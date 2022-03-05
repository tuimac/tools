#!/bin/bash

FLUENTD_CONF='/etc/td-agent/td-agent.conf'


function main(){
    if [ -z $1 ] || [ -z $2 ]; then
        echo 'Need properly argument!!'
    fi
}

main $1 $2
