#!/bin/bash

docker run -itd \
    --name keycloak \
    -p 8000:8080 \
    -v keycloak:/opt/keycloak \
    -e "KEYCLOAK_ADMIN=admin" \
    -e "KEYCLOAK_ADMIN_PASSWORD=password" \
    --restart always \
    keycloak/keycloak:latest start-dev
