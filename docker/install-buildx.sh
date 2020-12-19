#!/bin/bash

[[ ! -e 'Dockerfile' ]] && { echo 'There is no Dockerfile on your directory.'; exit 1; }

git clone git://github.com/docker/buildx && cd buildx
make install
export DOCKER_BUILDKIT=1
docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx
export DOCKER_CLI_EXPERIMENTAL=enabled
docker run --rm --privileged docker/binfmt
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
docker buildx create --use tuimac

docker login

echo -en 'Enter Image Name: '
read IMAGENAME

docker buildx build --platform linux/amd64,linux/arm64 -t ${IMAGENAME} --push .
