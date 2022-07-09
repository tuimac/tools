#!/bin/bash


function genCert(){
    mkdir -p certs
    openssl req \
        -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
        -addext "subjectAltName = DNS:"${DOMAIM} \
        -subj "/C=JP/ST=Osaka/L=Osaka/O=tuimac/OU=tuimac/CN="${DOMAIM} \
        -x509 -days 3650 -out certs/domain.crt
}

function create_config(){
    cat <<EOF> config.yml
version: 0.1
log:
  accesslog:
    disabled: true
  level: info
  formatter: text
loglevel: debug
storage:
  s3:
    region: $REGION
    bucket: $BUCKET_NAME
    encrypt: false
    secure: true
    v4auth: true
    chunksize: 5242880
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432
    rootdirectory: /
http:
  addr: 0.0.0.0:443
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
}

function create_container(){
    which docker > /dev/null
    if [ $? -eq 0 ]; then
        docker run -itd \
            --name registry \
            --restart=always \
            -p 443:443 \
            -v $(pwd)/certs:/certs \
            -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
            -e REGISTRY_STORAGE_S3_REGIONENDPOINT=s3.${REGION}.amazonaws.com \
            registry
        sudo mkdir -p /etc/docker/certs.d/$DOMAIM
        sudo cp certs/domain.crt /etc/docker/certs.d/$DOMAIM/ca.crt
    else
        which podman > /dev/null
        if [ $? -eq 0 ]; then
            podman run -itd \
                --name registry \
                --restart=always \
                -p 443:443 \
                -v $(pwd)/certs:/certs \
                -v $(pwd)/config.yml:/etc/docker/registry/config.yml \
                -e REGISTRY_STORAGE_S3_REGIONENDPOINT=s3.${REGION}.amazonaws.com \
                registry
            sudo mkdir -p /etc/containers/certs.d/$DOMAIM
            sudo cp certs/domain.crt /etc/containers/certs.d/$DOMAIM/ca.crt
        else
            echo 'There is no container CLI!!' | logger
            exit 1
        fi
    fi
}

function delete_registry(){
    podman stop registry
    podman rm registry
    rm -rf certs/
    rm -f config.yml
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
        genCert
        create_config
        create_container
    elif [ $1 == 'delete' ]; then
        delete_registry
    else
        userguide
    fi
}

main $1
