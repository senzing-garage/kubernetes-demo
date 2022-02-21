#!/usr/bin/env bash

# Download docker version files.

mkdir ${SENZING_AIRGAPPED_DIR}/bin

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/bin/senzing-versions-latest.sh \
    https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/senzing-versions-latest.sh

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/bin/docker-versions-latest.sh \
    https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/docker-versions-latest.sh

# Download Python file for PostgreSQL governor.

mkdir -p ${SENZING_AIRGAPPED_DIR}/opt/senzing/g2/python

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/opt/senzing/g2/python/senzing_governor.py \
    https://raw.githubusercontent.com/Senzing/governor-postgresql-transaction-id/master/senzing_governor.py

# Download sample data.

mkdir -p ${SENZING_AIRGAPPED_DIR}/var/opt/senzing/data

curl -X GET \
    --output ${SENZING_AIRGAPPED_DIR}/var/opt/senzing/loadtest-dataset.json \
    --range 0-4300000 \
    https://s3.amazonaws.com/public-read-access/TestDataSets/loadtest-dataset-1M.json
