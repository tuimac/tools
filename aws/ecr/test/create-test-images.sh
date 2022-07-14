#!/bin/bash

REG_URL='registry.tuimac.com'
IMAGES=(
    'nginx'
    'tomcat'
    'postgres'
)

for image in ${IMAGES[@]}; do
    podman pull docker.io/library/$image
    local version=$RANDOM
    podman tag docker.io/library/$image $REG_URL/tuimac/dev/$image:$version
    podman push $REG_URL/tuimac/dev/$image:$version
    local version=$RANDOM
    podman tag docker.io/library/$image $REG_URL/tuimac/dev/$image:$version
    podman push $REG_URL/tuimac/dev/$image:$version
    local version=$RANDOM
    podman tag docker.io/library/$image $REG_URL/tuimac/test/$image:$version
    podman push $REG_URL/tuimac/test/$image:$version
    local version=$RANDOM
    podman tag docker.io/library/$image $REG_URL/tuimac/test/$image:$version
    podman push $REG_URL/tuimac/test/$image:$version
done
