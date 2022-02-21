#!/usr/bin/env bash

# Download entire git repository as zip file.

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/senzing-charts.zip \
  https://codeload.github.com/Senzing/charts/zip/refs/heads/master

# Decompress zip file

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
rm -rf !("charts")
pushd ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts
rm -rf !("phppgadmin"|"senzing-api-server"|"senzing-configurator"|"senzing-console"|"senzing-entity-search-web-app"|"senzing-init-container"|"senzing-installer"|"senzing-postgresql-client"|"senzing-redoer"|"senzing-stream-loader"|"senzing-stream-producer"|"swaggerapi-swagger-ui"|)
popd
popd

# Get Helm dependencies.

for CHART_DIR in ${SENZING_AIRGAPPED_DIR}/senzing-charts/charts/* ; do
    echo "Processing: ${CHART_DIR}"
    helm dependency update ${CHART_DIR}
done
