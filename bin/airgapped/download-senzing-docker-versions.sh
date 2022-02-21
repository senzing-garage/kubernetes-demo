#!/usr/bin/env bash


mkdir ${SENZING_AIRGAPPED_DIR}/bin

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/bin/senzing-versions-latest.sh \
  https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/senzing-versions-latest.sh

curl -X GET \
  --output ${SENZING_AIRGAPPED_DIR}/bin/docker-versions-latest.sh \
  https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/docker-versions-latest.sh
