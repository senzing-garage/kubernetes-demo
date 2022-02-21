#!/usr/bin/env bash


# Build docker image for installing Senzing}"
# References:
#  -  https://docs.docker.com/engine/reference/commandline/build


${SENZING_SUDO} docker build \
    --build-arg SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    --build-arg SENZING_APT_INSTALL_PACKAGE="senzingapi=${SENZING_VERSION_SENZINGAPI_BUILD}" \
    --tag senzing/installer:${SENZING_VERSION_SENZINGAPI} \
    https://github.com/Senzing/docker-installer.git
