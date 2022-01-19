# kubernetes-demo-helm-rabbitmq-postgresql

## Synopsis

Using `minikube`, bring up a Senzing stack on Kubernetes
using Helm, RabbitMQ, and a PostgreSQL database.

## Overview

This repository illustrates a reference implementation of Senzing using
PostgreSQL as the underlying database.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet and sends each JSON line to a message queue via the Senzing
   [stream-producer](https://github.com/Senzing/stream-producer).
    1. In this implementation, the queue is RabbitMQ.
1. Reads messages from the queue and inserts into Senzing via the Senzing
   [stream-loader](https://github.com/Senzing/stream-loader).
    1. In this implementation, Senzing keeps its data in a PostgreSQL database.
1. Reads information from Senzing via [Senzing API Server](https://github.com/Senzing/senzing-api-server) server.
1. Views resolved entities in a [web app](https://github.com/Senzing/entity-search-web-app).

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](architecture.png)

### Contents

1. [Preamble](#preamble)
1. [Related artifacts](#related-artifacts)
1. [Expectations](#expectations)
1. [Prerequisites](#prerequisites)
    1. [Prerequisite software](#prerequisite-software)
    1. [Clone repository](#clone-repository)
1. [Demonstrate](#demonstrate)
    1. [Create demo directory](#create-demo-directory)
    1. [Start minikube cluster](#start-minikube-cluster)
    1. [View minikube cluster](#view-minikube-cluster)
    1. [EULA](#eula)
    1. [Set environment variables](#set-environment-variables)
    1. [Identify Docker registry](#identify-docker-registry)
    1. [Create custom helm values files](#create-custom-helm-values-files)
    1. [Create custom kubernetes configuration files](#create-custom-kubernetes-configuration-files)
    1. [Save environment variables](#save-environment-variables)
    1. [Create namespace](#create-namespace)
    1. [Create persistent volume](#create-persistent-volume)
    1. [Add helm repositories](#add-helm-repositories)
    1. [Deploy Senzing](#deploy-senzing)
    1. [Install senzing-console Helm chart](#install-senzing-console-helm-chart)
    1. [Install Postgresql Helm chart](#install-postgresql-helm-chart)
    1. [Initialize database](#initialize-database)
    1. [Install phpPgAdmin Helm chart](#install-phppgadmin-helm-chart)
    1. [Install RabbitMQ Helm chart](#install-rabbitmq-helm-chart)
    1. [Install stream-producer Helm chart](#install-stream-producer-helm-chart)
    1. [Install init-container Helm chart](#install-init-container-helm-chart)
    1. [Install stream-loader Helm chart](#install-stream-loader-helm-chart)
    1. [Install senzing-api-server Helm chart](#install-senzing-api-server-helm-chart)
    1. [Install senzing-entity-search-web-app Helm chart](#install-senzing-entity-search-web-app-helm-chart)
    1. [Optional charts](#optional-charts)
        1. [Install senzing-redoer Helm chart](#install-senzing-redoer-helm-chart)
        1. [Install configurator Helm chart](#install-configurator-helm-chart)
        1. [Install SwaggerUI Helm Chart](#install-swaggerui-helm-chart)
    1. [View data](#view-data)
        1. [View RabbitMQ](#view-rabbitmq)
        1. [View PostgreSQL](#view-postgresql)
        1. [View Senzing Console pod](#view-senzing-console-pod)
        1. [View Senzing API Server](#view-senzing-api-server)
        1. [View Senzing Entity Search WebApp](#view-senzing-entity-search-webapp)
        1. [View SwaggerUI](#view-swaggerui)
        1. [View Senzing Configurator](#view-senzing-configurator)
1. [Cleanup](#cleanup)
    1. [Delete everything in Kubernetes](#delete-everything-in-kubernetes)
    1. [Delete minikube cluster](#delete-minikube-cluster)
1. [Errors](#errors)
1. [References](#references)

## Preamble

At [Senzing](http://senzing.com),
we strive to create GitHub documentation in a
"[don't make me think](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/dont-make-me-think.md)" style.
For the most part, instructions are copy and paste.
Whenever thinking is needed, it's marked with a "thinking" icon :thinking:.
Whenever customization is needed, it's marked with a "pencil" icon :pencil2:.
If the instructions are not clear, please let us know by opening a new
[Documentation issue](https://github.com/Senzing/kubernetes-demo/issues/new?assignees=&labels=&template=documentation_request.md)
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

## Prerequisites

### Prerequisite software

1. [minikube](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-minikube.md)
1. [kubectl](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-kubectl.md)
1. [Helm 3](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-helm.md)

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

## Demonstrate

### Create demo directory

1. :pencil2: Create unique prefix.
   This will be used in a local directory name
   as well as a prefix to kubernetes object.

   :warning:  Must be all lowercase.

   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. Make a directory for the demo.
   Example:

    ```console
    export SENZING_DEMO_DIR=~/senzing-multi-tenant-demo-${DEMO_PREFIX}
    mkdir -p ${SENZING_DEMO_DIR}
    ```

### Start minikube cluster

Using [Get Started with Bitnami Charts using Minikube](https://docs.bitnami.com/kubernetes/get-started-kubernetes/#overview)
as a guide, start a minikube cluster.

1. Start cluster using
   [minikube start](https://minikube.sigs.k8s.io/docs/commands/start/).
   Example:

    ```console
    minikube start --cpus 4 --memory 8192 --disk-size=50g
    ```

### View minikube cluster

:thinking: **Optional:** View the minikube cluster using the
[dashboard](https://minikube.sigs.k8s.io/docs/handbook/dashboard/).

1. In a separate terminal window, run start minikube dashboard using
   [minikube dashboard](https://minikube.sigs.k8s.io/docs/commands/dashboard/).
   Example:

    ```console
    minikube dashboard
    ```

### Set environment variables

1. Set environment variables listed in "[Clone repository](#clone-repository)".
1. Retrieve latest docker image version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/docker-versions-latest.sh)
    ```

1. Retrieve stable Helm Chart version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/helm-versions-stable.sh)
    ```

1. Retrieve latest Senzing version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/senzing-versions-latest.sh)
    ```

### Identify Docker registry

:thinking: There are 3 options when it comes to using a docker registry.  Choose one:

1. [Use public registry](#use-public-registry)
1. [Use private registry](#use-private-registry)
1. [Use minikube registry](#use-minikube-registry)

#### Use public registry

_Method #1:_ Pulls docker images from public internet registry.

1. Use the default public `docker.io` registry which pulls images from
   [hub.docker.com](https://hub.docker.com/).
   Example:

    ```console
    export DOCKER_REGISTRY_URL=docker.io
    export DOCKER_REGISTRY_SECRET=${DOCKER_REGISTRY_URL}-secret
    ```

#### Use private registry

_Method #2:_ Pulls docker images from a private registry.

1. :pencil2: Specify a private registry.
   Example:

    ```console
    export DOCKER_REGISTRY_URL=my.example.com:5000
    export DOCKER_REGISTRY_SECRET=${DOCKER_REGISTRY_URL}-secret
    export SENZING_SUDO=sudo
    ${GIT_REPOSITORY_DIR}/bin/populate-private-registry.sh
    ```

#### Use minikube registry

_Method #3:_ Pulls docker images from minikube's registry.

1. Use minikube's docker registry using
   [minkube addons enable](https://minikube.sigs.k8s.io/docs/commands/addons/#minikube-addons-enable) and
   [minikube image load](https://minikube.sigs.k8s.io/docs/commands/image/#minikube-image-load).
   Example:

    ```console
    minikube addons enable registry
    export DOCKER_REGISTRY_URL=docker.io
    export DOCKER_REGISTRY_SECRET=${DOCKER_REGISTRY_URL}-secret
    ${GIT_REPOSITORY_DIR}/bin/populate-minikube-registry.sh
    ```

### Add helm repositories

1. Add Bitnami repository using
   [helm repo add](https://helm.sh/docs/helm/helm_repo_add/).
   Example:

    ```console
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```

1. Add Senzing repository using
   [helm repo add](https://helm.sh/docs/helm/helm_repo_add/).
   Example:

    ```console
    helm repo add senzing https://hub.senzing.com/charts/
    ```

1. Update repositories using
   [helm repo update](https://helm.sh/docs/helm/helm_repo_update/).
   Example:

    ```console
    helm repo update
    ```

1. :thinking: **Optional:**
   Review repositories using
   [helm repo list](https://helm.sh/docs/helm/helm_repo_list/).
   Example:

    ```console
    helm repo list
    ```

### Create main

`main` is the owner of the shared database and RabbitMQ.
Think of `main` as the super-tenant.

#### Set environment variables for main

1. :pencil2: Identify the tenant administrator.
   Example:

    ```console
    export SENZING_TENANT_ADMIN=main
    ```

1. Synthesize environment variables.
   Example:

    ```console
    export DEMO_NAMESPACE_ADMIN=${SENZING_TENANT_ADMIN}-namespace

    export SENZING_TENANT=${SENZING_TENANT_ADMIN}
    export DEMO_NAMESPACE=${SENZING_TENANT}-namespace
    ```

#### Create custom helm values files for main

In this step, Helm template files are populated with actual values.

1. Using `envsubst`.
   Example:

    ```console
    export HELM_VALUES_DIR=${SENZING_DEMO_DIR}/${SENZING_TENANT}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml; \
    do \
      envsubst < "${file}" > "${HELM_VALUES_DIR}/$(basename ${file})";
    done
    ```

#### Create custom kubernetes configuration files for main

In this step, Kubernetes template files are populated with actual values.

1. Using `envsubst`.
   Example:

    ```console
    export KUBERNETES_DIR=${SENZING_DEMO_DIR}/${SENZING_TENANT}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*; \
    do \
      envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})";
    done
    ```

#### Save environment variables for main

1. Save environment variables into a file that can be sourced.
   Example:

    ```console
    cat <<EOT > ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh
    #!/usr/bin/env bash

    EOT

    env \
    | grep \
        --regexp="^DEMO_" \
        --regexp="^DATABASE_" \
        --regexp="^DOCKER_" \
        --regexp="^GIT_" \
        --regexp="^HELM_" \
        --regexp="^KUBERNETES_" \
        --regexp="^RABBITMQ_" \
        --regexp="^SENZING_" \
    | sort \
    | awk -F= '{ print "export", $0 }' \
    >> ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh

    chmod +x ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh
    ```

#### Create namespace for main

1. Create namespace using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/namespace.yaml
    ```

1. :thinking: **Optional:**
   Review namespaces using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get namespaces
    ```

#### Create persistent volume for main

1. Create persistent volumes using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-postgresql.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-rabbitmq.yaml
    ```

1. Create persistent volume claims using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-postgresql.yaml
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-rabbitmq.yaml
    ```

1. :thinking: **Optional:**
   Review persistent volumes and claims using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get persistentvolumes \
      --namespace ${DEMO_NAMESPACE}

    kubectl get persistentvolumeClaims \
      --namespace ${DEMO_NAMESPACE}
    ```

#### Install Postgresql Helm chart

1. Create Configmap for `pg_hba.conf` using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create configmap ${DEMO_PREFIX}-pg-hba \
      --namespace ${DEMO_NAMESPACE} \
      --from-file=${KUBERNETES_DIR}/pg_hba.conf
    ```

    Note: `pg_hba.conf` will be stored in the PersistentVolumeClaim.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-bitnami-postgresql \
      bitnami/postgresql \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/bitnami-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_BITNAMI_POSTGRESQL:-""}
    ```

1. Wait for pod to run using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. Example of pod running:

    ```console
    NAME                                   READY   STATUS      RESTARTS   AGE
    my-bitnami-postgresql-6bf64cbbdf-25gtb  1/1     Running     0          10m
    ```

#### Install phpPgAdmin Helm Chart

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-phppgadmin \
      senzing/phppgadmin \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/phppgadmin-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_PHPPGADMIN:-""}
    ```

1. To view PostgreSQL via phpPgAdmin, see [View PostgreSQL](#view-postgresql).

#### Install RabbitMQ Helm chart

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-bitnami-rabbitmq \
      bitnami/rabbitmq \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/bitnami-rabbitmq.yaml \
      --version ${SENZING_HELM_VERSION_BITNAMI_RABBITMQ:-""}
    ```

1. Wait for pods to run using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. To view RabbitMQ, see [View RabbitMQ](#view-rabbitmq).

### Deploy Tenant

A tenant is a share-nothing user of Senzing.
Each tenant will have:

1. A separate database schema in the single database instance.
1. Separate queues in the single RabbitMQ instance.
1. A separate copy of the senzing binary files in its own PV/PVC.

#### Set environment variables for tenant

These steps assume that a fresh environment is used.
As such, there will be some repetition from earler steps.

1. :pencil2: Identify the "tenant".
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. :thinking: Identify the tenant administrator, again.
   Example:

    ```console
    export SENZING_TENANT_ADMIN=main
    ```

1. :thinking: Identify the `DEMO_PREFIX`, again.

   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :thinking: Identify Docker registry, again.
   Use the same values as in [Identify Docker registry](#identify-docker-registry).
   Example:

    ```console
    export DOCKER_REGISTRY_URL=docker.io
    export DOCKER_REGISTRY_SECRET=${DOCKER_REGISTRY_URL}-secret
    ```

1. :thinking: To give each tenant unique data, choose a starting line number for the input file.
   For demonstration, the `TENANTS` list contains 10 tenant identifiers.
   Example:

    ```console
    export TENANTS=("tenant1" "tenant2" "tenant3" "tenant4" "tenant5" "tenant6" "tenant7" "tenant8" "tenant9" "tenant10")

    export SENZING_RECORD_MIN=1
    for TENANT in ${TENANTS[@]}; do
        export SENZING_RECORD_MIN=$((${SENZING_RECORD_MIN} + 10000))
        if [ ${SENZING_TENANT} = ${TENANT} ]; then
            break
        fi
    done
    echo ${SENZING_RECORD_MIN}
    ```

1. Identify git repository directory.
   Example:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=kubernetes-demo
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

1. "Source" variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/docker-versions-latest.sh)
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/helm-versions-stable.sh)
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/master/lists/senzing-versions-latest.sh)
    ```

1. Synthesize environment variables.
   Example:

    ```console
    export DEMO_NAMESPACE=${SENZING_TENANT}-namespace
    export DEMO_NAMESPACE_ADMIN=${SENZING_TENANT_ADMIN}-namespace
    export SENZING_DEMO_DIR=~/senzing-multi-tenant-demo-${DEMO_PREFIX}
    export SENZING_RECORD_MAX=$((${SENZING_RECORD_MIN} + 9999))
    ```

1. Create random passwords.
   Example:

    ```console
    export DATABASE_PASSWORD=$(< /dev/urandom tr -dc [:alnum:] | head -c${1:-20};echo;)
    export RABBITMQ_PASSWORD=$(< /dev/urandom tr -dc [:alnum:] | head -c${1:-20};echo;)
    ```

#### EULA

To use the Senzing code, you must agree to the End User License Agreement (EULA).

1. :warning: This step is intentionally tricky and not simply copy/paste.
   This ensures that you make a conscious effort to accept the EULA.
   Example:

    <pre>export SENZING_ACCEPT_EULA="&lt;the value from <a href="https://github.com/Senzing/knowledge-base/blob/master/lists/environment-variables.md#senzing_accept_eula">this link</a>&gt;"</pre>

#### Create custom helm values files for tenant

In this step, Helm template files are populated with actual values.

1. Using `envsubst`.
   Example:

    ```console
    export HELM_VALUES_DIR=${SENZING_DEMO_DIR}/${SENZING_TENANT}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/helm-values-templates/*.yaml; \
    do \
      envsubst < "${file}" > "${HELM_VALUES_DIR}/$(basename ${file})";
    done
    ```

#### Create custom kubernetes configuration files for tenant

In this step, Kubernetes template files are populated with actual values.

1. Using `envsubst`.
   Example:

    ```console
    export KUBERNETES_DIR=${SENZING_DEMO_DIR}/${SENZING_TENANT}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    for file in ${GIT_REPOSITORY_DIR}/kubernetes-templates/*; \
    do \
      envsubst < "${file}" > "${KUBERNETES_DIR}/$(basename ${file})";
    done
    ```

#### Save environment variables for tenant

1. Save environment variables into a file that can be sourced.
   Example:

    ```console
    cat <<EOT > ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh
    #!/usr/bin/env bash

    EOT

    env \
    | grep \
        --regexp="^DATABASE_" \
        --regexp="^DEMO_" \
        --regexp="^DOCKER_" \
        --regexp="^GIT_" \
        --regexp="^HELM_" \
        --regexp="^KUBERNETES_" \
        --regexp="^RABBITMQ_" \
        --regexp="^SENZING_" \
    | sort \
    | awk -F= '{ print "export", $0 }' \
    >> ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh

    chmod +x ${SENZING_DEMO_DIR}/${SENZING_TENANT}/environment.sh
    ```

#### Create namespace for tenant

1. Create namespace using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/namespace.yaml
    ```

1. :thinking: **Optional:**
   Review namespaces using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get namespaces
    ```

#### Create persistent volume for tenant

1. Create persistent volumes using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-senzing-multi-tenant.yaml
    ```

1. Create persistent volume claims using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-senzing-multi-tenant.yaml
    ```

1. :thinking: **Optional:**
   Review persistent volumes and claims using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get persistentvolumes \
      --namespace ${DEMO_NAMESPACE}

    kubectl get persistentvolumeClaims \
      --namespace ${DEMO_NAMESPACE}
    ```

#### Create PostgreSQL database user for tenant

Using a database user interface like [phpPgAdmin](#view-postgresql):

1. Log on as super user.

1. Create database and user by running SQL found in
   ${SENZING_DEMO_DIR}/${SENZING_TENANT}/kubernetes/pg_tenant_create_database.sql

1. Create schema and permissions by connecting to the database and running SQL found in
   ${SENZING_DEMO_DIR}/${SENZING_TENANT}/kubernetes/pg_tenant_create_schema.sql

#### Create RabbitMQ user for tenant

1. Using [RabbitMQ management console](#view-rabbitmq), "Admin" tab,
   create a new user with the following information.
   Example:

    ```console
    echo "RabbitMQ username: ${SENZING_TENANT}"
    echo "RabbitMQ password: ${RABBITMQ_PASSWORD}"
    ```

1. Using [RabbitMQ management console](#view-rabbitmq), "Admin" tab,
    1. In "Name" column, click on tenant
    1. In "Permissions", set permission for Virtual Host: `/`

#### Deploy Senzing

:thinking: This deployment initializes the Persistent Volume with Senzing code and data.

There are 3 options when it comes to initializing the Persistent Volume with Senzing code and data.
Choose one:

1. [Root container method](#root-container-method) - requires a root container
1. [Non-root container method](#non-root-container-method) - can be done on kubernetes with a non-root container
1. [yum localinstall method](#yum-localinstall-method) - Uses existing Senzing RPMs, so no downloading during installation.

##### Root container method

_Method #1:_ This method is simpler, but requires a root container.
This method uses a dockerized [apt](https://github.com/Senzing/docker-apt) command.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-apt \
      senzing/senzing-apt \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-apt.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_APT:-""}
    ```

1. Wait until Job has completed using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. Example of completion:

    ```console
    NAME                       READY   STATUS      RESTARTS   AGE
    my-senzing-apt-8n2ql       0/1     Completed   0          2m44s
    ```

##### Non-root container method

_Method #2:_ This method can be done on kubernetes with a non-root container.
The following instructions are done on a non-kubernetes machine which allows root docker containers.
Example: A personal laptop.

1. Set environment variables.
   Example:

    ```console
    export SENZING_DATA_DIR=${SENZING_DEMO_DIR}/data
    export SENZING_G2_DIR=${SENZING_DEMO_DIR}/g2
    ```

1. Run docker container to download and extract Senzing binaries to
   `SENZING_DATA_DIR` and `SENZING_G2_DIR`.
   Example:

    ```console
    sudo docker run \
      --env SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
      --interactive \
      --rm \
      --tty \
      --volume ${SENZING_DATA_DIR}:/opt/senzing/data \
      --volume ${SENZING_G2_DIR}:/opt/senzing/g2 \
      senzing/apt
    ```

1. Install chart with non-root container using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   This pod will be the recipient of `kubectl cp` commands.
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-base \
      senzing/senzing-base \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-base-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_BASE:-""}
    ```

1. Wait for pod to run using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. Identify Senzing Base pod name.
   Example:

    ```console
    export SENZING_BASE_POD_NAME=$(kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --output jsonpath="{.items[0].metadata.name}" \
      --selector "app.kubernetes.io/name=senzing-base, \
                  app.kubernetes.io/instance=${DEMO_PREFIX}-senzing-base" \
      )
    ```

1. Copy files from local machine to Senzing Base pod using
   [kubectl cp](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#cp).
   Example:

    ```console
    kubectl cp ${SENZING_DATA_DIR} ${DEMO_NAMESPACE}/${SENZING_BASE_POD_NAME}:/opt/senzing/data
    kubectl cp ${SENZING_G2_DIR}   ${DEMO_NAMESPACE}/${SENZING_BASE_POD_NAME}:/opt/senzing/g2
    ```

##### yum localinstall method

_Method #3:_ This method inserts the Senzing RPMs into the minikube environment for a `yum localinstall`.
The advantage of this method is that the Senzing RPMs are not downloaded from the internet during installation.
This produces the same result as the `apt` installs describe in prior methods.
_Note:_  The environment variables were "sourced" in
[Set environment variables](#set-environment-variables).

1. :pencil2: Identify a directory to store downloaded files.
   Example:

    ```console
    export DOWNLOAD_DIR=~/Downloads
    ```

1. Download Senzing RPMs.
   Example:

    ```console
    docker run \
      --rm \
      --volume ${DOWNLOAD_DIR}:/download \
      senzing/yumdownloader \
        senzingapi-${SENZING_VERSION_SENZINGAPI_BUILD} \
        senzingdata-v2-${SENZING_VERSION_SENZINGDATA_BUILD}
    ```

1. Copy files into minikube.
   Example:

    ```console
    scp -i $(minikube ssh-key) \
        ${DOWNLOAD_DIR}/${SENZING_VERSION_SENZINGAPI_RPM_FILENAME} \
        docker@$(minikube ip):/home/docker

    scp -i $(minikube ssh-key) \
        ${DOWNLOAD_DIR}/${SENZING_VERSION_SENZINGDATA_RPM_FILENAME} \
        docker@$(minikube ip):/home/docker
    ```

1. Log into `minikube` instance using
   [minikube ssh](https://minikube.sigs.k8s.io/docs/commands/ssh/).
   Example:

    ```console
    minikube ssh
    ```

1. :thinking: Identify the "tenant".
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. In the `minikube` instance, move files to `/mnt/vda1/senzing/senzing-rpms`.
   Example:

    ```console
    sudo mkdir -p /mnt/vda1/senzing/${SENZING_TENANT}/senzing-rpms
    sudo mv /home/docker/senzingdata* /mnt/vda1/senzing/${SENZING_TENANT}/senzing-rpms
    sudo mv /home/docker/senzingapi* /mnt/vda1/senzing/${SENZING_TENANT}/senzing-rpms
    exit
    ```

1. Install chart to perform `yum localinstall` using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-yum \
      senzing/senzing-yum \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-yum-localinstall.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_YUM:-""}
    ```

1. Wait until Job has completed using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. Example of completion:

    ```console
    NAME                       READY   STATUS      RESTARTS   AGE
    my-senzing-yum-8n2ql       0/1     Completed   0          2m44s
    ```

#### Install senzing-console Helm chart

The [senzing-console](https://github.com/Senzing/docker-senzing-console)
will be used later to:

- Inspect mounted volumes
- Debug issues
- Run command-line tools

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-console \
      senzing/senzing-console \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-console-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_CONSOLE:-""}
    ```

1. To use senzing-console pod, see [View Senzing Console pod](#view-senzing-console-pod).

#### Initialize database

1. The [PostgreSQL Client](https://github.com/Senzing/charts/tree/master/charts/senzing-postgresql-client)
   is used to create tables in the database (i.e. the schema) used by Senzing using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-postgresql-client \
      senzing/senzing-postgresql-client \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-postgresql-client-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_POSTGRESQL_CLIENT:-""}
    ```

#### Install stream-producer Helm chart

The [stream producer](https://github.com/Senzing/stream-producer)
pulls JSON lines from a file and pushes them to message queue using
[helm install](https://helm.sh/docs/helm/helm_install/).

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-stream-producer \
      senzing/senzing-stream-producer \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-stream-producer-rabbitmq-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_STREAM_PRODUCER:-""}
    ```

#### Install init-container Helm chart

The [init-container](https://github.com/Senzing/docker-init-container)
creates files from templates and initializes the G2 database.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-init-container \
      senzing/senzing-init-container \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-init-container-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_INIT_CONTAINER:-""}
    ```

1. Wait for pods to run using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

#### Install stream-loader Helm chart

The [stream loader](https://github.com/Senzing/stream-loader)
pulls messages from message queue and sends them to Senzing.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-stream-loader \
      senzing/senzing-stream-loader \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-stream-loader-rabbitmq-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_STREAM_LOADER:-""}
    ```

#### Install senzing-api-server Helm chart

The [Senzing API server](https://github.com/Senzing/senzing-api-server)
receives HTTP requests to read and modify Senzing data.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-api-server \
      senzing/senzing-api-server \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-api-server-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_API_SERVER:-""}
    ```

1. Wait for pods to run using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. To view Senzing API server, see [View Senzing API Server](#view-senzing-api-server).

#### Install senzing-entity-search-web-app Helm chart

The [Senzing Entity Search WebApp](https://github.com/Senzing/entity-search-web-app)
is a light-weight WebApp demonstrating Senzing search capabilities.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-entity-search-web-app \
      senzing/senzing-entity-search-web-app \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-entity-search-web-app-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_ENTITY_SEARCH_WEB_APP:-""}
    ```

1. Wait until Deployment has completed using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

1. To view Senzing Entity Search WebApp, see [View Senzing Entity Search WebApp](#view-senzing-entity-search-webapp).

#### Optional charts

These charts are not necessary for the demonstration,
but may be valuable in a production environment.

##### Install senzing-redoer Helm chart

The [redoer](https://github.com/Senzing/redoer) pulls Senzing redo records from the Senzing database and re-processes.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-redoer \
      senzing/senzing-redoer \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-redoer-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_REDOER:-""}
    ```

##### Install SwaggerUI Helm chart

The [SwaggerUI](https://swagger.io/tools/swagger-ui/) is a micro-service
for viewing the Senzing REST OpenAPI specification in a web browser.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-swaggerapi-swagger-ui \
      senzing/swaggerapi-swagger-ui \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/swaggerapi-swagger-ui.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_SWAGGERAPI_SWAGGER_UI:-""}
    ```

1. To view SwaggerUI, see [View SwaggerUI](#view-swaggerui).

##### Install configurator Helm chart

The [Senzing Configurator](https://github.com/Senzing/configurator) is a micro-service for changing Senzing configuration.

1. Install chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-configurator \
      senzing/senzing-configurator \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-configurator-postgresql-multi-tenant.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_CONFIGURATOR:-""}
    ```

1. To view Senzing Configurator, see [View Senzing Configurator](#view-senzing-configurator).

#### View data

1. Username and password for the following sites are the values seen in the corresponding "values" YAML file located in
   [helm-values-templates](../helm-values-templates).

1. Because some of the Kubernetes Services use LoadBalancer,
   a `minikube` tunnel is needed for
   [LoadBalancer access](https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access).
   Example:

    ```console
    minikube tunnel
    ```

##### View RabbitMQ

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/main/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-bitnami-rabbitmq 15672:15672
    ```

1. RabbitMQ will be viewable at [localhost:15672](http://localhost:15672).
    1. Login
        1. See `helm-values/bitnami-rabbitmq.yaml` for Username and password.

##### View PostgreSQL

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/main/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-phppgadmin 9171:80
    ```

1. PostgreSQL will be viewable at [localhost:9171](http://localhost:9171).
    1. Login
       1. See `helm-values/bitnami-postgresql.yaml` for postgres password (`postgresqlPassword`).
       1. Default: username: `postgres`  password: `postgres`
    1. On left-hand navigation, select "G2" database to explore.
    1. The records received from the queue can be viewed in the following Senzing tables:
        1. G2 > DSRC_RECORD
        1. G2 > OBS_ENT

##### View Senzing Console pod

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the existing "tenant" created in the
   "[Set environment variables for tenant](#set-environment-variables-for-tenant)" step.
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. Log into Senzing Console pod using
   [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/${SENZING_TENANT}/environment.sh

    export CONSOLE_POD_NAME=$(kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --output jsonpath="{.items[0].metadata.name}" \
      --selector "app.kubernetes.io/name=senzing-console, \
                  app.kubernetes.io/instance=${DEMO_PREFIX}-senzing-console" \
      )

    kubectl exec -it --namespace ${DEMO_NAMESPACE} ${CONSOLE_POD_NAME} -- /bin/bash
    ```

##### View Senzing API Server

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the existing "tenant" created in the
   "[Set environment variables for tenant](#set-environment-variables-for-tenant)" step.
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/${SENZING_TENANT}/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-api-server 8250:80
    ```

1. Make HTTP calls via `curl`.
   Example:

    ```console
    export SENZING_API_SERVICE=http://localhost:8250

    curl -X GET ${SENZING_API_SERVICE}/heartbeat
    curl -X GET ${SENZING_API_SERVICE}/license
    curl -X GET ${SENZING_API_SERVICE}/entities/1
    ```

##### View Senzing Entity Search WebApp

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the existing "tenant" created in the
   "[Set environment variables for tenant](#set-environment-variables-for-tenant)" step.
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/${SENZING_TENANT}/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-entity-search-web-app 8251:80
    ```

1. Senzing Entity Search WebApp will be viewable at [localhost:8251](http://localhost:8251).
   The [demonstration](https://github.com/Senzing/knowledge-base/blob/master/demonstrations/docker-compose-web-app.md)
   instructions will give a tour of the Senzing web app.

##### View SwaggerUI

In a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the existing "tenant" created in the
   "[Set environment variables for tenant](#set-environment-variables-for-tenant)" step.
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/${SENZING_TENANT}/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-swaggerapi-swagger-ui 9180:80
    ```

   Then visit [http://localhost:9180](http://localhost:9180).

##### View Senzing Configurator

If the Senzing configurator was deployed, in a separate terminal window:

1. :pencil2: Identify the existing demonstration prefix created in the
   "[Create demo directory](#create-demo-directory)" step.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the existing "tenant" created in the
   "[Set environment variables for tenant](#set-environment-variables-for-tenant)" step.
   Example:

    ```console
    export SENZING_TENANT=tenant1
    ```

1. Port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    source ~/senzing-multi-tenant-demo-${DEMO_PREFIX}/${SENZING_TENANT}/environment.sh

    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-configurator 8253:80
    ```

1. Make HTTP calls via `curl`.
   Example:

    ```console
    export SENZING_API_SERVICE=http://localhost:8253

    curl -X GET ${SENZING_API_SERVICE}/datasources
    ```

## Cleanup

### Delete tenant

1. :pencil2: Set environment variables for tenant.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the "tenant".
   Example:

    ```console
    SENZING_TENANT=tenant1
    ```

1. Synthesize environment variables.
   Example:

    ```console
    export DEMO_NAMESPACE=${SENZING_TENANT}-namespace
    ```

1. Delete Kubernetes artifacts using
   [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) and
   [kubectl delete](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete).
   Example:

    ```console
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-configurator
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-swaggerapi-swagger-ui
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-redoer
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-entity-search-web-app
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-api-server
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-stream-loader
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-init-container
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-stream-producer
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-postgresql-client
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-console
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-apt
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-yum
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```

### Delete main

1. :pencil2: Set environment variables for tenant.
   Example:

    ```console
    export DEMO_PREFIX=my
    ```

1. :pencil2: Identify the "tenant".
   Example:

    ```console
    SENZING_TENANT=main
    ```

1. Synthesize environment variables.
   Example:

    ```console
    export DEMO_NAMESPACE=${SENZING_TENANT}-namespace
    ```

1. Delete Kubernetes artifacts using
   [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) and
   [kubectl delete](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete).
   Example:

    ```console
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-bitnami-rabbitmq
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-phppgadmin
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-bitnami-postgresql
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-rabbitmq.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-postgresql.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-rabbitmq.yaml
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```

### Delete everything for Helm

1. Delete Kubernetes artifacts using
   [helm repo remove](https://helm.sh/docs/helm/helm_repo_remove/).
   Example:

    ```console
    helm repo remove senzing
    helm repo remove bitnami
    ```

### Delete minikube cluster

1. Delete minikube artifacts using
   [minikube stop](https://minikube.sigs.k8s.io/docs/commands/stop/) and
   [minikube delete](https://minikube.sigs.k8s.io/docs/commands/delete/)
   Example:

    ```console
    minikube stop
    minikube delete
    ```

## Errors

1. See [docs/errors.md](docs/errors.md).

## References
