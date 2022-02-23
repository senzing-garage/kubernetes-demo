#!/usr/bin/env bash

# Load docker tar files into local Docker repository
# using "docker load" command.
# Reference: https://docs.docker.com/engine/reference/commandline/load

# Test environment variables.

ERRORS=0

if [[ -z "${SENZING_AIRGAPPED_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_AIRGAPPED_DIR must be set"
fi

if [ ! -f "${SENZING_AIRGAPPED_DIR}/kubernetes-demo/helm-values-templates/senzing-stream-producer-rabbitmq.yaml" ]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_AIRGAPPED_DIR may not be set correctly."
    echo "       Current value: ${SENZING_AIRGAPPED_DIR}"
    echo "Error: Could not find ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/helm-values-templates/senzing-stream-producer-rabbitmq.yaml"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

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
