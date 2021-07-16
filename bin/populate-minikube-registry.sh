#!/usr/bin/env bash

# List all of the docker images to be installed into the private registry.

source ./docker-images.sh

# Process each docker image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
    minikube cache add ${DOCKER_IMAGE}
done
