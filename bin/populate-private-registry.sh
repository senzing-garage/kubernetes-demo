#!/usr/bin/env bash

# Instantiate "DOCKER_IMAGES", a list of docker images to be installed into the private registry.

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

    # Pull images from DockerHub (docker.io)

    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}

    # Push images into private registry.

    echo ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker tag  ${DOCKER_IMAGE} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}

    # Remove tagged image.
    
    ${SENZING_SUDO} docker rmi  ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
done
