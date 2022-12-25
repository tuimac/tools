#!/bin/bash

API_KEY=''
PARENT="1"

INFO=$(curl -X GET -H 'X-Redmine-API-Key:'${API_KEY} http://localhost:8003/projects/test/issues.json?limit=5)
echo $INFO
PARENT_IDS=$(echo $INFO | jq -sr '.[].issues[] | select(.parent.id != null) | .parent.id')
echo $PARENT_IDS
PARENTS=$(echo $INFO | jq -sr --argjson parent "$PARENT" '.[].issues[] | select(.tracker.id == $parent) | .id')
echo $PARENTS
