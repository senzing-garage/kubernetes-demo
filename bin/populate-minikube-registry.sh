#!/usr/bin/env bash

# Instantiate "DOCKER_IMAGES", a list of docker images to be installed into the minikube registry.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/docker-images.sh

# Process each docker image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do

    # Pull images from DockerHub (docker.io)

    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}

    # Push images into minikube registry.
    # https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-load

    minikube image load ${DOCKER_IMAGE}
done

# List images in the minikube docker registry.
# https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-ls

minikube image ls
