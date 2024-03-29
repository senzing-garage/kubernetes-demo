#!/usr/bin/env bash

# Download docker version files.

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

# Download version files.

mkdir ${SENZING_AIRGAPPED_DIR}/bin

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/bin/docker-versions-stable.sh \
    https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/docker-versions-stable.sh

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/bin/helm-versions-stable.sh \
    https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/helm-versions-stable.sh
