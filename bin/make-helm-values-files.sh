#!/usr/bin/env bash

# Instantiate templates into a working directory.

# Test environment variables.

ERRORS=0

if [[ -z "${HELM_VALUES_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: HELM_VALUES_DIR must be set"
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

mkdir -p ${HELM_VALUES_DIR}

for FILE in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml
do
  envsubst < "${FILE}" > "${HELM_VALUES_DIR}/$(basename ${FILE})"
done
