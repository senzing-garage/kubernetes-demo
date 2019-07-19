# kubernetes-demo-helm-rabbitmq-sqlite

## Overview

This repository illustrates a reference implementation of Senzing using PostgreSQL as the underlying database.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet.
1. Sends each JSON line to a message queue.
    1. In this implementation, the queue is RabbitMQ.
1. Reads messages from the queue and inserts into Senzing.
    1. In this implementation, Senzing keeps its data in a PostgreSQL database.
1. Reads information from Senzing via [Senzing REST API](https://github.com/Senzing/senzing-rest-api) server.

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](architecture.png)

### Contents

1. [Expectations](#expectations)
    1. [Space](#space)
    1. [Time](#time)
    1. [Background knowledge](#background-knowledge)
1. [Prerequisites](#prerequisites)
    1. [Prerequisite software](#prerequisite-software)
    1. [Clone repository](#clone-repository)
    1. [Docker images](#docker-images)
1. [Demonstrate](#demonstrate)
    1. [Set environment variables](#set-environment-variables)
    1. [Create custom helm values files](#create-custom-helm-values-files)
    1. [Create custom kubernetes configuration files](#create-custom-kubernetes-configuration-files)
    1. [Create namespace](#create-namespace)
    1. [Create persistent volume](#create-persistent-volume)
    1. [Add helm repositories](#add-helm-repositories)
    1. [Deploy Senzing_API.tgz package](#deploy-senzing_apitgz-package)
    1. [Install senzing-debug Helm chart](#install-senzing-debug-helm-chart)
    1. [Install Postgresql Helm chart](#install-postgresql-helm-chart)
    1. [Initialize database](#initialize-database)
    1. [Install phpPgAdmin](#install-phppgadmin)
    1. [Install RabbitMQ Helm chart](#install-rabbitmq-helm-chart)
    1. [Install mock-data-generator Helm chart](#install-mock-data-generator-helm-chart)
    1. [Install stream-loader Helm chart](#install-stream-loader-helm-chart)
    1. [Install senzing-api-server Helm chart](#install-senzing-api-server-helm-chart)
    1. [Test Senzing REST API server](#test-senzing-rest-api-server)
1. [Cleanup](#cleanup)
    1. [Delete everything in project](#delete-everything-in-project)
    1. [Delete minikube cluster](#delete-minikube-cluster)

## Expectations

### Space

This repository and demonstration require 20 GB free disk space.

### Time

Budget 4 hours to get the demonstration up-and-running, depending on CPU and network speeds.

### Background knowledge

This repository assumes a working knowledge of:

1. [Docker](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/docker.md)
1. [Kubernetes](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/kubernetes.md)
1. [Helm](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/helm.md)

## Prerequisites

### Prerequisite software

#### kubectl

1. [Install kubectl](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-kubectl.md).

#### minikube cluster

1. [Install minikube](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-minikube.md).
1. [Start cluster](https://docs.bitnami.com/kubernetes/get-started-kubernetes/#overview)

    ```console
    minikube start --cpus 4 --memory 8192
    ```

    Alternative:

    ```console
    minikube start --cpus 4 --memory 8192 --vm-driver kvm2
    ```

#### Helm/Tiller

1. [Install Helm](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-helm.md) on your local workstation.
1. [Install Tiller](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-tiller.md) in the minikube cluster.

### Clone repository

The Git repository has files that will be used in the `helm install --values` parameter.

1. Using these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=kubernetes-demo
    ```

1. Follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/clone-repository.md) to install the Git repository.

1. After the Git repository has been cloned, be sure the following environment variables are set:

    ```console
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

### Docker images

#### Senzing docker images

1. In a new terminal window, build [senzing/senzing-package](https://github.com/Senzing/senzing-package) docker image.

#### Docker registry

1. If you need to create a private docker registry, see
       [HOWTO - Install docker registry server](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-docker-registry-server.md).

1. :pencil2: Set environment variable.  Example:

    ```console
    export DOCKER_REGISTRY_URL=my.docker-registry.com:5000
    ```

1. Add Senzing docker images to private docker registry.  Example:

    ```console
    export DOCKER_IMAGE_NAMES=( \
      "senzing/senzing-package" \
    )

    for DOCKER_IMAGE_NAME in ${DOCKER_IMAGE_NAMES[@]};\
    do \
      sudo docker tag  ${DOCKER_IMAGE_NAME} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}; \
      sudo docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}; \
      sudo docker rmi  ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}; \
    done
    ```

## Demonstrate

### Set environment variables

1. :pencil2: Environment variables that need customization.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace

    export DOCKER_REGISTRY_URL=docker.io
    ```

1. Set environment variables listed in "[Clone repository](#clone-repository)".

### Create custom helm values files

1. Variation #1. Quick method using `envsubst`.  Example:

    ```console
    export HELM_VALUES_DIR=${GIT_REPOSITORY_DIR}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml; \
    do \
      envsubst < "${file}" > "${HELM_VALUES_DIR}/$(basename ${file})";
    done
    ```

1. Variation #2. Copy and modify method.

    ```console
    export HELM_VALUES_DIR=${GIT_REPOSITORY_DIR}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    cp ${GIT_REPOSITORY_DIR}/helm-values-templates/* ${HELM_VALUES_DIR}
    ```

    :pencil2: Edit files in ${HELM_VALUES_DIR} replacing the following variables with actual values.

    1. `${DEMO_PREFIX}`
    1. `${DEMO_NAMESPACE}`

### Create custom kubernetes configuration files

1. Variation #1. Quick method using `envsubst`.  Example:

    ```console
    export KUBERNETES_DIR=${GIT_REPOSITORY_DIR}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*; \
    do \
      envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})";
    done
    ```

1. Variation #2. Copy and modify method.

    ```console
    export KUBERNETES_DIR=${GIT_REPOSITORY_DIR}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    cp ${GIT_REPOSITORY_DIR}/kubernetes-templates/* ${KUBERNETES_DIR}
    ```

    :pencil2: Edit files in ${KUBERNETES_DIR} replacing the following variables with actual values.

    1. `${DEMO_PREFIX}`
    1. `${DEMO_NAMESPACE}`

### Create namespace

1. Create namespace.

    ```console
    kubectl create -f ${KUBERNETES_DIR}/namespace.yaml
    ```

1. Optional: Review namespaces.

    ```console
    kubectl get namespaces
    ```

### Create persistent volume

1. Create persistent volumes.  Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    ```

1. Create persistent volume claims.  Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    ```

1. Optional: Review persistent volumes and claims.

    ```console
    kubectl get persistentvolumes \
      --namespace ${DEMO_NAMESPACE}

    kubectl get persistentvolumeClaims \
      --namespace ${DEMO_NAMESPACE}
    ```

### Add helm repositories

1. Add Senzing repository.  Example:

    ```console
    helm repo add senzing https://senzing.github.io/charts/
    ```

1. Update repositories.

    ```console
    helm repo update
    ```

1. Optional: Review repositories

    ```console
    helm repo list
    ```

1. Reference: [helm repo](https://helm.sh/docs/helm/#helm-repo)

### Deploy Senzing_API.tgz package

This deployment initializes the Persistent Volume with Senzing code and data.

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-package \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-package.yaml \
      senzing/senzing-package
    ```

1. Wait until Job has completed.  Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. Example of completion:

    ```console
    NAME                       READY   STATUS      RESTARTS   AGE
    my-senzing-package-8n2ql   0/1     Completed   0          2m44s
    ```

### Install senzing-debug Helm chart

This deployment will be used later to:

* Inspect the `/opt/senzing` volume
* Debug issues

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-debug \
      --namespace ${DEMO_NAMESPACE} \
      --values ${GIT_REPOSITORY_DIR}/helm-values/senzing-debug-postgresql.yaml \
       senzing/senzing-debug
    ```

1. Wait for pod to run.  Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. In a separate terminal window, log into debug pod.

    :pencil2:  Set environment variables.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    ```

    Log into pod.  Example:

    ```console
    export DEBUG_POD_NAME=$(kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --output jsonpath="{.items[0].metadata.name}" \
      --selector "app.kubernetes.io/name=senzing-debug, \
                  app.kubernetes.io/instance=${DEMO_PREFIX}-senzing-debug" \
      )

    kubectl exec -it --namespace ${DEMO_NAMESPACE} ${DEBUG_POD_NAME} -- /bin/bash
    ```

### Install phpPgAdmin

1. Install phpPgAdmin app.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-phppgadmin \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/phppgadmin.yaml \
      senzing/phppgadmin
    ```

1. Optional:  Background information on
    [senzing/phppgadmin](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/build-docker-senzing-phppgadmin.md)
    docker image.

1. In a separate terminal window, port forward to local machine.

    :pencil2: Set environment variables.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    ```

    Port forward.  Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-phppgadmin-phppgadmin 8081:8080
    ```

1. Open browser to [localhost:8081](http://localhost:8081)
    1. Login
       1. See `helm-values/postgresql.yaml` for postgresqlUsername and postgresqlPassword
       1. Default: username: `postgres`  password: `postgres`
    1. On left-hand navigation, select "G2" database to explore.

### Install RabbitMQ Helm chart

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-rabbitmq \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/rabbitmq.yaml \
      stable/rabbitmq
    ```

1. In a separate terminal window, port forward to local machine.

    :pencil2: Set environment variables.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    ```

    Port forward.  Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-rabbitmq 15672:15672
    ```

1. RabbitMQ is viewable at [localhost:15672](http://localhost:15672)

### Install mock-data-generator Helm chart

The mock data generator pulls JSON lines from a file and pushes them to Kafka.

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-mock-data-generator \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/mock-data-generator-rabbitmq.yaml \
      senzing/senzing-mock-data-generator
    ```

### Install stream-loader Helm chart

The stream loader pulls messages from Kafka and sends them to Senzing.

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-stream-loader \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/stream-loader-rabbitmq-postgresql.yaml \
      senzing/senzing-stream-loader
    ```

### Install senzing-api-server Helm chart

The Senzing API server receives HTTP requests to read and modify Senzing data.

1. Install chart.  Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-api-server \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-api-server-postgresql.yaml \
      senzing/senzing-api-server
    ```

1. Wait for pods to run.  Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. In a separate terminal window, port forward to local machine.

    :pencil2:  Set environment variables.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    ```

    Port forward.  Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-api-server 8889:80
    ```

### Test Senzing REST API server

*Note:* port 8889 on the localhost has been mapped to port 80 in the docker container.
See `kubectl port-forward ...` above.

1. Example:

    ```console
    export SENZING_API_SERVICE=http://localhost:8889

    curl -X GET ${SENZING_API_SERVICE}/heartbeat
    curl -X GET ${SENZING_API_SERVICE}/license
    curl -X GET ${SENZING_API_SERVICE}/entities/1
    ```

## Cleanup

### Delete everything in project

1. Example:

    ```console
    helm delete --purge ${DEMO_PREFIX}-senzing-api-server
    helm delete --purge ${DEMO_PREFIX}-senzing-stream-loader
    helm delete --purge ${DEMO_PREFIX}-senzing-mock-data-generator
    helm delete --purge ${DEMO_PREFIX}-rabbitmq
    helm delete --purge ${DEMO_PREFIX}-phppgadmin
    helm delete --purge ${DEMO_PREFIX}-postgresql-client
    helm delete --purge ${DEMO_PREFIX}-postgresql
    helm delete --purge ${DEMO_PREFIX}-senzing-debug
    helm delete --purge ${DEMO_PREFIX}-senzing-package
    helm repo remove senzing
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```

### Delete minikube cluster

1. Example:

    ```console
    minikube stop
    minikube delete
    ```