#!/usr/bin/env bash

# Load docker tar files into local Docker repository
# using "docker load" command.
# Reference: https://docs.docker.com/engine/reference/commandline/load

# Identify subdirectories for each repository.

DOCKER_REGISTRIES=(
    "bitnami"
    "senzing"
    "swaggerapi"
)

# For each Docker registry:

for DOCKER_REGISTRY in ${DOCKER_REGISTRIES[@]}; do

    # For each image in the Docker registry, load image into local Docker registry.

    for DOCKER_IMAGE in ${SENZING_AIRGAPPED_DIR}/docker-images/${DOCKER_REGISTRY}/* ; do
        echo "${DOCKER_IMAGE}"
        ${SENZING_SUDO} docker load --input ${DOCKER_IMAGE}
    done
done
