#!/usr/bin/env bash

# Pull docker images listed in "${DOCKER_IMAGES}"
# References:
#  -  https://docs.docker.com/engine/reference/commandline/pull

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    echo ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
done
