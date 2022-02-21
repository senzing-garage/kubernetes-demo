#!/usr/bin/env bash

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

# Remove unneeded files.

rmdir ${SENZING_AIRGAPPED_DIR}/bitnami-charts-tmp
rm    ${SENZING_AIRGAPPED_DIR}/bitnami-charts.zip

# Remove unneeded directories.

pushd ${SENZING_AIRGAPPED_DIR}/bitnami-charts
rm *
rm .*
rm -rf .*




find ${SENZING_AIRGAPPED_DIR}/bitnami-charts -type f -not -name 'bitnami' -print0 | xargs -0 -I {} rm {}
popd
exit



rm -rf '!("bitnami")'
pushd ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami
rm -rf '!("postgresql"|"rabbitmq")'
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

# Remove unneeded files.

rmdir ${SENZING_AIRGAPPED_DIR}/senzing-charts-tmp
rm    ${SENZING_AIRGAPPED_DIR}/senzing-charts.zip

# Remove unneeded directories.

pushd ${SENZING_AIRGAPPED_DIR}/senzing-charts
rm *
rm .*
rm -rf .*
rm -rf '!("charts")'
pushd ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts
rm -rf '!("phppgadmin"|"senzing-api-server"|"senzing-configurator"|"senzing-console"|"senzing-entity-search-web-app"|"senzing-init-container"|"senzing-installer"|"senzing-postgresql-client"|"senzing-redoer"|"senzing-stream-loader"|"senzing-stream-producer"|"swaggerapi-swagger-ui"|)'
popd
popd

# Get Helm dependencies.

for CHART_DIR in ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts/* ; do
    echo "Processing: ${CHART_DIR}"
    helm dependency update ${CHART_DIR}
done
