#!/bin/bash

BUCKET_NAME='docker-registry-00'
STORAGE_PATH='/'`hostname`

function create_registry(){
    cat <<EOF> config.yml
version: 0.1
log:
  accesslog:
    disabled: false
  level: info
  formatter: json
storage:
  s3:
    region: ap-northeast-1
    bucket: $BUCKET_NAME
    encrypt: true
    secure: true
    v4auth: true
    chunksize: 5242880
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432
    rootdirectory: $STORAGE_PATH
http:
  addr: registry.tuimac.me:5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
EOF
    podman run -itd \
        --name registry \
        --restart=always \
        -p 5000:5000 \
        -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
        registry
    #[[ $? -eq 0 ]] && { rm config.yml; }
}

function delete_registry(){
    podman stop registry
    podman rm registry
}

function userguide(){
    echo -e "usage: ./registry [create | delete]"
    echo -e "
optional arguments:
create		Deploy registry container.
delete		Delete registry container.
    "    
}

function main(){
    [[ -z $1 ]] && { userguide; exit 1; }
    if [ $1 == 'create' ]; then
        create_registry
    elif [ $1 == 'delete' ]; then
        delete_registry
    else
        userguide
    fi
}

main $1
