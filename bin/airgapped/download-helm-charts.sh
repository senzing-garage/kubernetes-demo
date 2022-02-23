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

# Enable the exclamation point ("!") to "exclude".

shopt -s extglob

# -----------------------------------------------------------------------------
# Bitnami Helm Charts
# -----------------------------------------------------------------------------

# Download entire git repository as zip file.

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/bitnami-charts.zip \
  https://codeload.github.com/bitnami/charts/zip/refs/heads/master

# Decompress zip file.

unzip \
  -d ${SENZING_AIRGAPPED_DIR}/bitnami-charts-tmp \
  -q \
  ${SENZING_AIRGAPPED_DIR}/bitnami-charts.zip

# Fiddle with directory structure.

mv ${SENZING_AIRGAPPED_DIR}/bitnami-charts-tmp/charts-master \
   ${SENZING_AIRGAPPED_DIR}/bitnami-charts

# Remove extraneous files.

rmdir ${SENZING_AIRGAPPED_DIR}/bitnami-charts-tmp
rm    ${SENZING_AIRGAPPED_DIR}/bitnami-charts.zip

# Remove extraneous sub-directories.

pushd ${SENZING_AIRGAPPED_DIR}/bitnami-charts
returnCode=$?
if [[ ${returnCode} -ne 0 ]]; then
    echo "Error: ${SENZING_AIRGAPPED_DIR}/bitnami-charts directory does not exist."
    exit 1
fi

rm *
rm .*
rm -rf .*
rm -rf !("bitnami")

pushd ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami
returnCode=$?
if [[ ${returnCode} -ne 0 ]]; then
    echo "Error: ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami directory does not exist."
    exit 1
fi

rm -rf !("postgresql"|"rabbitmq")
popd
popd

# Get Helm dependencies.

for CHART_DIR in ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami/* ; do
    echo "Processing: ${CHART_DIR}"
    helm dependency update ${CHART_DIR}
done

# -----------------------------------------------------------------------------
# Senzing Helm Charts
# -----------------------------------------------------------------------------

# Download entire git repository as zip file.

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/senzing-charts.zip \
  https://codeload.github.com/Senzing/charts/zip/refs/heads/master

# Decompress zip file.

unzip \
  -d ${SENZING_AIRGAPPED_DIR}/senzing-charts-tmp \
  ${SENZING_AIRGAPPED_DIR}/senzing-charts.zip

# Fiddle with directory structure.

mv ${SENZING_AIRGAPPED_DIR}/senzing-charts-tmp/charts-master \
   ${SENZING_AIRGAPPED_DIR}/senzing-charts

# Remove extraneous files.

rmdir ${SENZING_AIRGAPPED_DIR}/senzing-charts-tmp
rm    ${SENZING_AIRGAPPED_DIR}/senzing-charts.zip

# Remove extraneous sub-directories.

pushd ${SENZING_AIRGAPPED_DIR}/senzing-charts
returnCode=$?
if [[ ${returnCode} -ne 0 ]]; then
    echo "Error: ${SENZING_AIRGAPPED_DIR}/senzing-charts directory does not exist."
    exit 1
fi

rm *
rm .*
rm -rf .*
rm -rf !("charts")

pushd ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts
returnCode=$?
if [[ ${returnCode} -ne 0 ]]; then
    echo "Error: ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts directory does not exist."
    exit 1
fi

rm -rf !("phppgadmin"|"senzing-api-server"|"senzing-configurator"|"senzing-console"|"senzing-entity-search-web-app"|"senzing-init-container"|"senzing-installer"|"senzing-postgresql-client"|"senzing-redoer"|"senzing-stream-loader"|"senzing-stream-producer"|"swaggerapi-swagger-ui"|)

popd
popd

# Get Helm dependencies.

for CHART_DIR in ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts/* ; do
    echo "Processing: ${CHART_DIR}"
    helm dependency update ${CHART_DIR}
done
