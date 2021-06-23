#!/usr/bin/env bash

DOCKER_IMAGES=(
    "senzing/yum:${SENZING_DOCKER_IMAGE_VERSION_YUM}"
    "senzing/senzing-base:${SENZING_DOCKER_IMAGE_VERSION_SENZING_BASE}"
    "bitnami/"
    "bitnami/zookeeper:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_ZOOKEEPER}"
)

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker tag  ${DOCKER_IMAGE} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker rmi  ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
done
