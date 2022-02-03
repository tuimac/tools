#!/bin/bash

docker exec -u postgres postgresql bash -c '/usr/lib/postgresql/10/bin/pg_ctl reload'
