#!/usr/bin/env bash

# Instantiate "DOCKER_IMAGES", a list of docker images to be installed into the minikube registry.

source ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/bin/airgapped/docker-images.sh

# Process each docker image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]}
do

    # Pull images from DockerHub (docker.io)

    ${SENZING_SUDO} docker pull ${DOCKER_IMAGE}

    # Push images into minikube registry.
    # https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-load

    echo ${DOCKER_IMAGE}
    minikube image load ${DOCKER_IMAGE}
done

# List images in the minikube docker registry.
# https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-ls

minikube image ls
