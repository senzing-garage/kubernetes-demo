#!/usr/bin/env bash

# Push Docker images listed in "${DOCKER_IMAGES}"
# to a private Docker registry identified by "${DOCKER_REGISTRY_URL}".
# References:
#  -  https://docs.docker.com/engine/reference/commandline/pull
#  -  https://docs.docker.com/engine/reference/commandline/tag
#  -  https://docs.docker.com/engine/reference/commandline/push
#  -  https://docs.docker.com/engine/reference/commandline/rmi

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do
    echo ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}
    ${SENZING_SUDO} docker tag  ${DOCKER_IMAGE} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
    ${SENZING_SUDO} docker rmi  ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE}
done
