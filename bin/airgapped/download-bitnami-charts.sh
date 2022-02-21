#!/usr/bin/env bash

# Download entire git repository as zip file.

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/bitnami-charts.zip \
  https://codeload.github.com/bitnami/charts/zip/refs/heads/master

# Decompress zip file

unzip \
  -d ${SENZING_AIRGAPPED_DIR}/bitnami-charts-tmp \
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
rm -rf !("bitnami")
pushd ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami
rm -rf !("postgresql"|"rabbitmq")
popd
popd

# Get Helm dependencies.

for CHART_DIR in ${SENZING_AIRGAPPED_DIR}/bitnami-charts/bitnami/* ; do
    echo "Processing: ${CHART_DIR}"
    helm dependency update ${CHART_DIR}
done
