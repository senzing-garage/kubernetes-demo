#!/usr/bin/env bash

# Instantiate templates into a working directory.

export KUBERNETES_DIR=${SENZING_DEMO_DIR}/kubernetes
mkdir -p ${KUBERNETES_DIR}

for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*; \
do \
  envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})";
done
