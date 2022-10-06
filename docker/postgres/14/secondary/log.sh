#!/bin/bash

podman logs postgresql
podman exec -it postgresql cat /var/log/postgresql/postgresql.log
