# kubernetes-helm-db2-demo

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
    1. [Create custom answer files](#create-custom-answer-files)
    1. [Create custom kubernetes configuration files](#create-custom-kubernetes-configuration-files)
    1. [Set default context](#set-default-context)
    1. [Add catalogs](#add-catalogs)
    1. [Create project](#create-project)
    1. [Switch context](#switch-context)
    1. [Create namespace](#create-namespace)
    1. [Add registries](#add-registries)
    1. [Create persistent volume](#create-persistent-volume)
    1. [Install Kafka](#install-kafka)
    1. [Install Kafka test client](#install-kafka-test-client)
    1. [Install DB2](#install-db2)
    1. [Initialize database](#initialize-database)
    1. [Install mock-data-generator](#install-mock-data-generator)
    1. [Install stream-loader](#install-stream-loader)
    1. [Install senzing-api-server](#install-senzing-api-server)
    1. [Test Senzing REST API server](#test-senzing-rest-api-server)
1. [Cleanup](#cleanup)
    1. [Switch context for delete](#switch-context-for-delete)
    1. [Delete everything in project](#delete-everything-in-project)
    1. [Default context after cleanup](#default-context-after-cleanup)
    1. [Delete catalogs](#delete-catalogs)

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

#### IBM docker images

1. Authorize [hub.docker.com/_/db2-developer-c-edition](https://hub.docker.com/_/db2-developer-c-edition)
   1. Visit [hub.docker.com/_/db2-developer-c-edition](https://hub.docker.com/_/db2-developer-c-edition)
   1. Click "Proceed to Checkout" button.
   1. Agree to terms and click "Get Content" button.

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

1. Make Senzing docker images.

    ```console
    sudo docker build --tag senzing/db2                 https://github.com/senzing/docker-db2.git
    sudo docker build --tag senzing/db2express-c        https://github.com/senzing/docker-db2express-c.git
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
    for GIT_REPOSITORY in \
      "db2" \
      "db2express-c" \
      "mock-data-generator" \
      "senzing-api-server" \
      "stream-loader"; \
    do \
      sudo docker tag senzing/${GIT_REPOSITORY} ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
      sudo docker push ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
      sudo docker rmi  ${DOCKER_REGISTRY_URL}/senzing/${GIT_REPOSITORY}; \
    done
    ```

### Set environment variables

1. Environment variables that need customization.  Example:

    ```console
    export K8S_PREFIX=my
    export K8S_NAMESPACE_NAME=${K8S_PREFIX}-namespace
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

### Add registries

Because IBM docker images required acceptance of terms in
[IBM docker images](#ibm-docker-images) step,
Kubernetes needs username/password to hub.docker.com
to retrieve the images.

1. Add docker.io registry.
   :warning: hub.docker.com username and password used in previous
   [IBM docker images](#ibm-docker-images)
   step need to be supplied.
   Example:

    ```console
    export DOCKER_USERNAME=me@example.com
    export DOCKER_PASSWORD=fake-password

    kubectl create secret docker-registry ${K8S_PREFIX}-docker-io \
      --namespace ${K8S_NAMESPACE_NAME} \
      --docker-server=docker.io \
      --docker-username=${DOCKER_USERNAME} \
      --docker-password=${DOCKER_PASSWORD}
    ```

1. Review secrets.

    ```console
    kubectl get secrets \
      --namespace ${K8S_NAMESPACE_NAME}
    ```

### Create persistent volume

1. If you do not already have an `/opt/senzing` directory on your system, visit
   [HOWTO - Create SENZING_DIR](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/create-senzing-dir.md).

1. Create persistent volumes. Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-db2-data-stor.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    ```

1. Create persistent volume claims. Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-db2-data-stor.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    ```

1. Review persistent volumes and claims.

    ```console
    kubectl get persistentvolumes \
      --namespace ${K8S_NAMESPACE_NAME}

    kubectl get persistentvolumeClaims \
      --namespace ${K8S_NAMESPACE_NAME}
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

1. FIXME: Add IBM repository.  Example:

    ```console
    helm repo add ibm https://github.com/IBM/charts
    helm repo add ibm https://github.com/IBM/charts/repo/stable
    helm repo add ibm https://github.com/IBM/charts/tree/master/repo/stable
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

### Install Kafka

1. Example:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/kafka.yaml \
      --name ${K8S_PREFIX}-kafka \
      --namespace ${K8S_NAMESPACE_NAME} \
      bitnami/kafka
    ```

### Install Kafka test client

1. Install Kafka test client app. Example:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/kafka-test-client.yaml \
      --name ${K8S_PREFIX}-kafka-test-client \
      --namespace ${K8S_NAMESPACE_NAME} \
      senzing/kafka-test-client
    ```

1. Run the test client. Run in a separate terminal window. Example:

    ```console
    export K8S_PREFIX=my
    export K8S_NAMESPACE_NAME=${K8S_PREFIX}-namespace

    kubectl exec \
      -it \
      -n ${K8S_NAMESPACE_NAME} \
      ${K8S_PREFIX}-kafka-test-client -- /usr/bin/kafka-console-consumer \
        --bootstrap-server ${K8S_PREFIX}-kafka:9092 \
        --topic senzing-kafka-topic \
        --from-beginning
    ```  

### Install DB2

1. Example:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/ibm-db2oltp-dev.yaml \
      --name ${K8S_PREFIX}-ibm-db2oltp-dev \
      --namespace ${K8S_NAMESPACE_NAME} \
      ibm/ibm-db2oltp-dev
    ```

1. Work-around:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/ibm-db2oltp-dev.yaml \
      --name ${K8S_PREFIX}-ibm-db2oltp-dev \
      --namespace ${K8S_NAMESPACE_NAME} \
      https://github.com/IBM/charts/raw/master/repo/stable/ibm-db2oltp-dev-3.2.0.tgz
    ```

### Initialize database

1. Bring up a DB2 client. Example:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/db2-client.yaml \
      --name ${K8S_PREFIX}-senzing-db2-client \
      --namespace ${K8S_NAMESPACE_NAME} \
      senzing/db2-client
    ```

1. X

    ```console
    export K8S_PREFIX=my
    export K8S_NAMESPACE_NAME=${K8S_PREFIX}-namespace

    kubectl exec \
      -it \
      -n ${K8S_NAMESPACE_NAME} \
      ${K8S_PREFIX}-senzing-db2-client -- /bin/bash
    ```

1. Catalog "remote" database.
   :warning: Look at the results of the
   "[Initialize database](#initialize-database)"
   step for the correct value of `DB2_HOST`.
   In the DB2 client docker container, run

    ```console
    su - db2inst1

    export K8S_PREFIX=my
    export DB2_HOST=${K8S_PREFIX}-ibm-db2-ibm-db2oltp-dev-db2

    db2 catalog tcpip node G2_node remote ${DB2_HOST} server 50000
    db2 catalog database G2 at node G2_node
    db2 terminate
    ```


    ```console
    kubectl get pods --namespace ${K8S_PREFIX}-namespace
    
    kubectl logs --follow my-ibm-db2-ibm-db2oltp-dev-0 
    ```


1. Populate database. In docker container, run

    ```console
    db2 connect to g2 user db2inst1 using db2inst1
    db2 -tf /opt/senzing/g2/data/g2core-schema-db2-create.sql
    ```

1. Exit docker container.

    ```console
    db2 connect reset
    exit
    exit
    ```

### Install mock-data-generator

1. Example:

    ```console
    helm install \
      --values ${HELM_VALUES_DIR}/mock-data-generator.yaml \
      --name ${K8S_PREFIX}-senzing-mock-data-generator \
      --namespace ${K8S_NAMESPACE_NAME} \
      senzing/senzing-mock-data-generator
    ```

### ------------------------------------------------------------------------------
### The work below is not ready
### ------------------------------------------------------------------------------

### Install stream-loader

1. Example:

    ```console
    helm install \
      --name ${K8S_PREFIX}-senzing-stream-loader \
      --namespace ${K8S_NAMESPACE_NAME} \
      --values ${HELM_VALUES_DIR}/stream-loader-db2.yaml \
      senzing/senzing-stream-loader
    ```

### Install senzing-api-server

1. Example:

    ```console
    helm install \
      --name ${K8S_PREFIX}-senzing-api-server \
      --namespace ${K8S_NAMESPACE_NAME} \
      --values ${HELM_VALUES_DIR}/senzing-api-server-db2.yaml \
      senzing-senzing-api-server
    ```

1. Port forward to local machine.  Run in a separate terminal window. Example:

    ```console
    export K8S_PREFIX=my
    export K8S_NAMESPACE_NAME=${K8S_PREFIX}-namespace

    kubectl port-forward --namespace ${K8S_NAMESPACE_NAME} svc/${K8S_PREFIX}-senzing-api-server 8889:80
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

    helm delete --purge ${K8S_PREFIX}-senzing-mock-data-generator
    helm delete --purge ${K8S_PREFIX}-senzing-db2-client
    helm delete --purge ${K8S_PREFIX}-ibm-db2oltp-dev
    helm delete --purge ${K8S_PREFIX}-kafka-test-client
    helm delete --purge ${K8S_PREFIX}-kafka
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-db2-data-stor.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-opt-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-db2-data-stor.yaml
    # kubectl get secrets ${K8S_PREFIX}-docker-io --namespace ${K8S_NAMESPACE_NAME}
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```  

### Delete helm repositories

1. Delete Senzing catalog. Example:

    ```console
    helm repo ...
    ```
