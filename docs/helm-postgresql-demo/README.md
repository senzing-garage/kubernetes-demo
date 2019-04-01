# kubernetes-helm-postgresql-demo

## Overview

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](architecture.png)

### Contents

1. [Expectations](#expectations)
    1. [Space](#space)
    1. [Time](#time)
    1. [Background knowledge](#background-knowledge)
1. [Demonstrate](#demonstrate)
    1. [Clone repository](#clone-repository)
    1. [Prerequisites](#prerequisites)
    1. [Set environment variables](#set-environment-variables)
    1. [Create custom helm values.yaml files](#create-custom-helm-valuesyaml-files)
    1. [Create custom kubernetes configuration files](#create-custom-kubernetes-configuration-files)
    1. [Create namespace](#create-namespace)
    1. [Create persistent volume](#create-persistent-volume)
    1. [Deploy Senzing_API.tgz](#deploy-senzing_apitgz)
    1. [Add helm repositories](#add-helm-repositories)
    1. [Install Kafka](#install-kafka)
    1. [Install Kafka test client](#install-kafka-test-client)
    1. [Install Postgresql](#install-postgresql)
    1. [Initialize database](#initialize-database)
    1. [Install phpPgAdmin](#install-phppgadmin)
    1. [Install mock-data-generator](#install-mock-data-generator)
    1. [Install stream-loader](#install-stream-loader)
    1. [Install senzing-api-server](#install-senzing-api-server)
    1. [Test Senzing REST API server](#test-senzing-rest-api-server)
1. [Cleanup](#cleanup)
    1. [Delete everything in project](#delete-everything-in-project)

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

## Demonstrate

### Clone repository

1. Using these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=kubernetes-demo
    ```

   Then follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/clone-repository.md).

1. After the repository has been cloned, be sure the following are set:

    ```console
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

### Prerequisites

#### kubectl

1. [Install kubectl](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-kubectl.md).

#### minikube cluster

1. [Install minikube](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-minikube.md).
1. [Start cluster](https://docs.bitnami.com/kubernetes/get-started-kubernetes/#overview)

    ```console
    minikube start --cpus 4 --memory 8192
    ```

#### Helm/Tiller

1. [Install Helm](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-helm.md).
1. [Install Tiller](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-tiller.md).

#### Senzing docker images

1. Build [senzing/senzing-base](https://github.com/Senzing/docker-senzing-base) docker image.
1. Build [senzing/senzing-package](https://github.com/Senzing/senzing-package) docker image.

1. Make Senzing docker images.

    ```console
    sudo docker build --tag senzing/stream-loader       https://github.com/senzing/stream-loader.git
    sudo docker build --tag senzing/mock-data-generator https://github.com/senzing/mock-data-generator.git
    ```

1. Build [senzing/senzing-api-server](https://github.com/Senzing/senzing-api-server#using-docker) docker image.

#### Docker registry

1. If you need to create a private docker registry, see
       [HOWTO - Install docker registry server](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-docker-registry-server.md).
1. Set environment variable. Example:

    ```console
    export DOCKER_REGISTRY_URL=my.docker-registry.com:5000
    ```

1. Add Senzing docker images to private docker registry.

    ```console
    export GIT_REPOSITORIES=( \
      "mock-data-generator" \
      "senzing-api-server" \
      "senzing-package" \
      "stream-loader" \
    )

    for GIT_REPOSITORY in ${GIT_REPOSITORIES[@]};\
    do \
      sudo docker tag senzing/${GIT_REPOSITORY} ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
      sudo docker push ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
      sudo docker rmi  ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
    done
    ```

### Set environment variables

1. Environment variables that need customization.  Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    ```

1. Set environment variables listed in "[Clone repository](#clone-repository)".

### Create custom helm values.yaml files

1. Variation #1. Quick method using `envsubst`.

    ```console
    export HELM_VALUES_DIR=${GIT_REPOSITORY_DIR}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml; \
    do \
      envsubst < "${file}" > "${HELM_VALUES_DIR}/$(basename ${file})";
    done
    ```

### Create custom kubernetes configuration files

1. Variation #1. Quick method using `envsubst`.

    ```console
    export KUBERNETES_DIR=${GIT_REPOSITORY_DIR}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*; \
    do \
      envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})";
    done
    ```

### Create namespace

1. Create namespace.

    ```console
    kubectl create -f ${KUBERNETES_DIR}/namespace.yaml
    ```

1. Review namespaces.

    ```console
    kubectl get namespaces
    ```

### Create persistent volume

1. Create persistent volumes.  Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-postgresql.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    ```

1. Create persistent volume claims. Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-postgresql.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    ```

1. Review persistent volumes and claims.

    ```console
    kubectl get persistentvolumes \
      --namespace ${DEMO_NAMESPACE}

    kubectl get persistentvolumeClaims \
      --namespace ${DEMO_NAMESPACE}
    ```

### Add helm repositories

1. Add Bitnami repository. Example:

    ```console
    helm repo add bitnami https://charts.bitnami.com
    ```

1. Add Senzing repository.  Example:

    ```console
    helm repo add senzing https://senzing.github.io/charts/
    ```

1. Update repositories.

    ```console
    helm repo update
    ```

1. Review repositories

    ```console
    helm repo list
    ```

1. Reference: [helm repo](https://helm.sh/docs/helm/#helm-repo)

### Deploy Senzing_API.tgz

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-package \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-package.yaml \
      senzing/senzing-package
    ```

### Install Kafka

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-kafka \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/kafka.yaml \
      bitnami/kafka
    ```

### Install Kafka test client

1. Install Kafka test client app. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-kafka-test-client \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/kafka-test-client.yaml \
      senzing/kafka-test-client
    ```

1. Run the test client. Run in a separate terminal window. Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace

    kubectl exec \
      -it \
      -n ${DEMO_NAMESPACE} \
      ${DEMO_PREFIX}-kafka-test-client -- /usr/bin/kafka-console-consumer \
        --bootstrap-server ${DEMO_PREFIX}-kafka:9092 \
        --topic senzing-kafka-topic \
        --from-beginning
    ```  

### Install Postgresql

1. Create Configmap for `pg_hba.conf`. Example

    ```console
    kubectl create configmap ${DEMO_PREFIX}-pg-hba \
      --namespace ${DEMO_NAMESPACE} \
      --from-file=${KUBERNETES_DIR}/pg_hba.conf
    ```

    Note: `pg_hba.conf` will be stored in the PersistentVolumeClaim.

1. Install Postgresql. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-postgresql \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/postgresql.yaml \
      bitnami/postgresql
    ```

### Initialize database

**FIXME:** Does not work.  Use phpPgAdmin, the next step, to initialize database.

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-postgresql-client \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/postgresql-client.yaml \
      senzing/postgresql-client
    ```

### Install phpPgAdmin

1. Install phpPgAdmin app. Example:

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

1. Port forward to local machine.  Run in a separate terminal window. Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace

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

### Install mock-data-generator

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-mock-data-generator \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/mock-data-generator.yaml \
      senzing/senzing-mock-data-generator
    ```

### Install stream-loader

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-stream-loader \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/stream-loader-postgresql.yaml \
      senzing/senzing-stream-loader
    ```

### Install senzing-api-server

1. Example:

    ```console
    helm install \
      --name ${DEMO_PREFIX}-senzing-api-server \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-api-server-postgresql.yaml \
      senzing/senzing-api-server
    ```

1. Port forward to local machine.  Run in a separate terminal window. Example:

    ```console
    export DEMO_PREFIX=my
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace

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
    helm delete --purge ${DEMO_PREFIX}-phppgadmin
    helm delete --purge ${DEMO_PREFIX}-postgresql-client
    helm delete --purge ${DEMO_PREFIX}-postgresql
    helm delete --purge ${DEMO_PREFIX}-kafka-test-client
    helm delete --purge ${DEMO_PREFIX}-kafka
    helm delete --purge ${DEMO_PREFIX}-senzing-package
    helm repo remove senzing
    helm repo remove bitnami
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```  

### Delete minikube

1. If `minikube` was used,  

    ```console
    minikube stop
    minikube delete    
    ```
