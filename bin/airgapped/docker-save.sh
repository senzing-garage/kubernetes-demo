#!/usr/bin/env bash

# Save Docker images listed in "${DOCKER_IMAGES}" into tar files
# using "docker save" command.
# Reference: https://docs.docker.com/engine/reference/commandline/save

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

# Instantiate "DOCKER_IMAGES", a list of docker images to be saved.

source ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/bin/airgapped/docker-images.sh

# For each Docker image, pull the image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]}; do
    echo "${DOCKER_IMAGE}"
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
done

# Save docker images into single tar file.

mkdir ${SENZING_AIRGAPPED_DIR}/docker-images
${SENZING_SUDO} docker save ${DOCKER_IMAGES[@]} \
    --output ${SENZING_AIRGAPPED_DIR}/docker-images/all-images.tar
