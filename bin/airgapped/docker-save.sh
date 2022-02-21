#!/usr/bin/env bash

# Save Docker images listed in "${DOCKER_IMAGES}" into tar files
# using "docker save" command.
# Reference: https://docs.docker.com/engine/reference/commandline/save

# Identify subdirectories for each repository.

DOCKER_REGISTRIES=(
    "bitnami"
    "senzing"
    "swaggerapi"
)

# Make directories where files will be saved.

mkdir ${SENZING_AIRGAPPED_DIR}/docker-images
for DOCKER_REGISTRY in ${DOCKER_REGISTRIES[@]}; do
    mkdir ${SENZING_AIRGAPPED_DIR}/docker-images/${DOCKER_REGISTRY}
done

# For each Docker image, run "docker save".

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]}; do
    echo "${DOCKER_IMAGE}"
    ${SENZING_SUDO} docker save ${DOCKER_IMAGE} \
        --output ${SENZING_AIRGAPPED_DIR}/docker-images/${DOCKER_IMAGE}.tar
done
