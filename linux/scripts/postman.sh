#!/bin/bash

[[ -z $1 ]] && { echo 'There is no argument.'; exit 1; }

curl -X POST -H "Content-Type: application/json" \
    -d '{"Name": "test", "command": "docker ps -a"}' \
    $1 | jq
