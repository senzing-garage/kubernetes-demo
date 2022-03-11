#!/usr/bin/env bash

# Pull docker images listed in "${DOCKER_IMAGES}"
# References:
#  -  https://docs.docker.com/engine/reference/commandline/pull

DOCKER_IMAGE_LIST=$1

# If no parameters passed, use defaults.

if [ $# -eq 0 ]; then
    DOCKER_IMAGE_LIST="docker-images"
fi

# Test environment variables.

ERRORS=0

if [[ -z "${DOCKER_REGISTRY_URL}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: DOCKER_REGISTRY_URL must be set"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# Instantiate "DOCKER_IMAGES", a list of docker images manipulated.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/${DOCKER_IMAGE_LIST}.sh

# Process each docker image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]}
do
    echo ${DOCKER_IMAGE}

    # Pull images from DockerHub (docker.io)

    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
done
