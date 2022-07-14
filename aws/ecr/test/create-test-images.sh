#!/bin/bash

REG_URL='registry.tuimac.com'
IMAGES=(
    'nginx'
    'tomcat'
    'postgres'
)

for image in ${IMAGES[@]}; do
    podman pull docker.io/library/$image
    version=$(($RANDOM / 1))
    echo $version
    podman tag docker.io/library/$image $REG_URL/tuimac/dev/$image:$version
    podman push $REG_URL/tuimac/dev/$image:$version
    version=$(($RANDOM / 1))
    podman tag docker.io/library/$image $REG_URL/tuimac/dev/$image:$version
    podman push $REG_URL/tuimac/dev/$image:$version
    version=$(($RANDOM / 1))
    podman tag docker.io/library/$image $REG_URL/tuimac/test/$image:$version
    podman push $REG_URL/tuimac/test/$image:$version
    version=$(($RANDOM / 1))
    podman tag docker.io/library/$image $REG_URL/tuimac/test/$image:$version
    podman push $REG_URL/tuimac/test/$image:$version
done
