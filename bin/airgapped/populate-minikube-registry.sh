#!/usr/bin/env bash

# Instantiate "DOCKER_IMAGES", a list of docker images to be installed into the minikube registry.

source ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/airgapped/docker-images.sh

# Process each docker image.

for DOCKER_IMAGE in ${DOCKER_IMAGES[@]};
do

    # Push images into minikube registry.
    # https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-load

    minikube image load ${DOCKER_IMAGE}
done

# List images in the minikube docker registry.
# https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-ls

minikube image ls
