#!/usr/bin/env bash

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

# Get Helm Chart metadata.

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add senzing https://hub.senzing.com/charts/
helm repo update

# Instantiate "HELM_CHARTS", a list of helm charts to be saved.

source ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/bin/airgapped/helm-charts.sh

# Process Helm Charts.

for HELM_CHART in ${HELM_CHARTS[@]};
do

    # Get metadata.

    IFS=";" read -r -a HELM_CHART_DATA <<< "${HELM_CHART}"
    HELM_CHART_NAME="${HELM_CHART_DATA[0]}"
    HELM_CHART_VERSION="${HELM_CHART_DATA[1]}"

    echo "Helm pull ${HELM_CHART_NAME}:${HELM_CHART_VERSION}"

    # Get requested version of submodule.

    helm pull \
        ${HELM_CHART_NAME} \
        --destination ${SENZING_AIRGAPPED_DIR}/helm-charts \
        --untar \
        --version ${HELM_CHART_VERSION}

    helm pull \
        ${HELM_CHART_NAME} \
        --destination ${SENZING_AIRGAPPED_DIR}/helm-charts \
        --version ${HELM_CHART_VERSION}

done
