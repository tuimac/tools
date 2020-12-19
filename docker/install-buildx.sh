#!/bin/bash

[[ ! -e 'Dockerfile' ]] && { echo 'There is no Dockerfile on your directory.'; exit 1; }

CURRDIR=`echo $PWD`

git clone git://github.com/docker/buildx && cd buildx
make install
export DOCKER_BUILDKIT=1
docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx
export DOCKER_CLI_EXPERIMENTAL=enabled
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
docker buildx create --name tuimac
docker buildx use tuimac

while true; do
    docker login
    [[ $? -eq 0 ]] && break
done

echo -en 'Enter Image Name: '
read IMAGENAME

cd $CURRDIR
rm -rf buildx/
docker buildx build --platform linux/amd64,linux/arm64 -t ${IMAGENAME} --push .
