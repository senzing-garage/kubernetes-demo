#!/usr/bin/env bash

# Build docker image for installing Senzing.
# Reference: https://docs.docker.com/engine/reference/commandline/build

# Test environment variables.

ERRORS=0

if [[ -z "${SENZING_ACCEPT_EULA}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_ACCEPT_EULA must be set"
fi

if [[ -z "${SENZING_VERSION_SENZINGAPI_BUILD}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_VERSION_SENZINGAPI_BUILD must be set"
fi

if [[ -z "${SENZING_VERSION_SENZINGAPI}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_VERSION_SENZINGAPI must be set"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# Build docker image.

${SENZING_SUDO} docker build \
    --build-arg SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    --build-arg SENZING_APT_INSTALL_PACKAGE="senzingapi=${SENZING_VERSION_SENZINGAPI_BUILD}" \
    --tag senzing/installer:${SENZING_VERSION_SENZINGAPI} \
    https://github.com/Senzing/docker-installer.git#main
