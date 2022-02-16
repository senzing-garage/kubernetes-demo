#!/usr/bin/env bash

# Instantiate templates into a working directory.

mkdir -p ${HELM_VALUES_DIR}

for file in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml; \
do \
  envsubst < "${file}" > "${HELM_VALUES_DIR}/$(basename ${file})";
done
