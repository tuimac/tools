#!/bin/bash

# Set Environment variable
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL=enabled

# Build buildx
git clone git://github.com/docker/buildx
cd buildx
make install
docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins
mv buildx ~/.docker/cli-plugins/docker-buildx

# binformat
docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3

# Make sure installation is fine or not
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
[[ $? -ne 0 ]] && { echo 'Setup buildx was failed.'; exit 1; }

# Create and use builder
docker buildx create --name travis
docker buildx use travis

# Build and Push docker images
docker buildx build --platform linux/amd64,linux/arm64 -t ${IMAGE} --push .
