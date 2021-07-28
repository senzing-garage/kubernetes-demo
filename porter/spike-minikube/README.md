# Spike: minikube

## Synopsis

Using `porter` create a CNAB bundle that runs on `minikube`.

## Overview



### Contents

1. [Expectations](#expectations)
1. [Prerequisites](#prerequisites)
    1. [Prerequisite software](#prerequisite-software)
    1. [Clone repository](#clone-repository)
1. [Demonstrate](#demonstrate)

1. [Cleanup](#cleanup)
    1. [Delete everything in project](#delete-everything-in-project)
    1. [Delete minikube cluster](#delete-minikube-cluster)

## Preamble

At [Senzing](http://senzing.com),
we strive to create GitHub documentation in a
"[don't make me think](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/dont-make-me-think.md)" style.
For the most part, instructions are copy and paste.
Whenever thinking is needed, it's marked with a "thinking" icon :thinking:.
Whenever customization is needed, it's marked with a "pencil" icon :pencil2:.
If the instructions are not clear, please let us know by opening a new
[Documentation issue](https://github.com/Senzing/template-python/issues/new?template=documentation_request.md)
describing where we can improve.   Now on with the show...

### Legend

1. :thinking: - A "thinker" icon means that a little extra thinking may be required.
   Perhaps you'll need to make some choices.
   Perhaps it's an optional step.
1. :pencil2: - A "pencil" icon means that the instructions may need modification before performing.
1. :warning: - A "warning" icon means that something tricky is happening, so pay attention.

## Related artifacts

1. [DockerHub](https://hub.docker.com/r/senzing)
1. [Helm Charts](https://github.com/Senzing/charts)

## Expectations

- **Space:** This repository and demonstration require 20 GB free disk space.
- **Time:** Budget 4 hours to get the demonstration up-and-running, depending on CPU and network speeds.
- **Background knowledge:** This repository assumes a working knowledge of:
  - [Docker](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/docker.md)
  - [Kubernetes](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/kubernetes.md)
  - [Helm](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/helm.md)
  - [Porter](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/porter.md)

## Prerequisites

### Prerequisite software

1. [minikube](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-minikube.md)
1. [Porter](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/porter.md)

### Clone repository

The Git repository has files that will be used in the `helm install --values` parameter.

1. Using these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=kubernetes-demo
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

1. Follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/clone-repository.md) to install the Git repository.

### Install Porter mixins

1. Install `helm3` mixin.
   Example:

    ```console
    porter mixin install helm3 --feed-url https://mchorfa.github.io/porter-helm3/atom.xml
    ```

## Demonstrate

### Start minikube cluster

1. [Start cluster](https://docs.bitnami.com/kubernetes/get-started-kubernetes/#overview).
   Example:

    ```console
    minikube start \
      --cpus 4 \
      --disk-size=50g  \
      --embed-certs \
      --memory 8192
    ```

### Build bundle

1. [Build bundle](https://porter.sh/cli/porter_build/).
   Example:

    ```console
    cd ${GIT_REPOSITORY_DIR}/porter/spike-minikube
    porter build
    ```

### Create credentials

1. []()
   Example:

    ```console
    cd ${GIT_REPOSITORY_DIR}/porter/spike-minikube
    porter credentials generate spike-helm3
    ```

    1. Set:
        1. *file path* = ~/.kube/config

### Install bundle

1. [Install bundle](https://porter.sh/cli/porter_install/).
   Example:

    ```console
    cd ${GIT_REPOSITORY_DIR}/porter/spike-minikube
    porter install --cred spike-helm3
    ```

## Cleanup

### Delete everything in project

1. Example:

    ```console
    cd ${GIT_REPOSITORY_DIR}/porter/spike-minikube
    porter uninstall
    ```

### Delete minikube cluster

1. Example:

    ```console
    minikube stop
    minikube delete
    ```
