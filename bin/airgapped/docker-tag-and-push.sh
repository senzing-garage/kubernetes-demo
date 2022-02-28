#!/usr/bin/env bash

# Push Docker images listed in "${DOCKER_IMAGES}"
# to a private Docker registry identified by "${DOCKER_REGISTRY_URL}".
# References:
#  -  https://docs.docker.com/engine/reference/commandline/pull
#  -  https://docs.docker.com/engine/reference/commandline/tag
#  -  https://docs.docker.com/engine/reference/commandline/push
#  -  https://docs.docker.com/engine/reference/commandline/rmi

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

if [[ -z "${DOCKER_REGISTRY_URL}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: DOCKER_REGISTRY_URL must be set"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# Instantiate "DOCKER_IMAGES", a list of docker images manipulated.

source ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/bin/airgapped/docker-images.sh

# Manipulate Docker images in list.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    echo ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker tag  ${DOCKER_IMAGE} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker rmi  ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
done
