#!/bin/bash

BUCKET_NAME='docker-registry-000'
STORAGE_PATH='/'`hostname`
DOMAIN='registry.tuimac.me'
S3_REGION='ap-northeast-3'

function disableSELinux(){
    local result=`sudo getenforce`
    [[ $result == 'Enforcing' ]] && { sudo setenforce 0; }
}

function genCert(){
    mkdir -p certs
    openssl req \
        -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
        -addext "subjectAltName = DNS:"${DOMAIN} \
        -subj "/C=JP/ST=Osaka/L=Osaka/O=tuimac/OU=tuimac/CN="${DOMAIN} \
        -x509 -days 3650 -out certs/domain.crt
}

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
    region: $S3_REGION
    bucket: $BUCKET_NAME
    encrypt: false
    secure: true
    v4auth: true
    chunksize: 5242880
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432
    rootdirectory: $STORAGE_PATH
http:
  addr: 0.0.0.0:5000
  headers:
    X-Content-Type-Options: [nosniff]
  tls:
    certificate: /certs/domain.crt
    key: /certs/domain.key
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
EOF

    podman run -itd \
        --name registry \
        --restart=always \
        -p 443:5000 \
        -v $(pwd)/certs:/certs \
        -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
        -e REGISTRY_STORAGE_S3_REGIONENDPOINT=s3.${S3_REGION}.amazonaws.com \
        registry
    sudo mkdir -p /etc/containers/certs.d/$DOMAIN
    sudo cp certs/domain.crt /etc/containers/certs.d/$DOMAIN/ca.crt
    sudo systemctl restart podman
}

function delete_registry(){
    podman stop registry
    podman rm registry
    rm -rf certs/
    rm -f  config.yml
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
    disableSELinux
    if [ $1 == 'create' ]; then
        genCert
        create_registry
    elif [ $1 == 'delete' ]; then
        delete_registry
    else
        userguide
    fi
}

main $1
