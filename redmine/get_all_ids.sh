#!/bin/bash

API_KEY='a3b01687bd26a29e4eb35acbbddebd2e08a0f7b5'
REDMINE_URL='http://redmine.tuimac.com'
PJT_NAME='arch'

curl -X GET -H 'X-Redmine-API-Key:'${API_KEY} ${REDMINE_URL}/issues.json | jq -sr
