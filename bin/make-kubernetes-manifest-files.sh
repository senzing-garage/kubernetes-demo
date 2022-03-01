#!/usr/bin/env bash

# Instantiate templates into a working directory.

# Test environment variables.

ERRORS=0

if [[ -z "${KUBERNETES_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: KUBERNETES_DIR must be set"
fi

if [[ -z "${GIT_REPOSITORY_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: GIT_REPOSITORY_DIR must be set"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# In a new directory, create instantiated files.

mkdir -p ${KUBERNETES_DIR}

for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*
do
  envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})"
done
