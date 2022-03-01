#!/usr/bin/env bash

# Pull docker images listed in "${DOCKER_IMAGES}"
# References:
#  -  https://docs.docker.com/engine/reference/commandline/pull

# Instantiate "DOCKER_IMAGES", a list of docker images manipulated.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/docker-images.sh

# Manipulate Docker images in list.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    echo ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
done
