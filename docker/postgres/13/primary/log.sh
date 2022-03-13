#!/bin/bash

docker logs postgresql
docker exec -it postgresql cat /var/log/postgresql/postgresql.log
