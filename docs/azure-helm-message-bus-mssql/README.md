# kubernetes-demo-azure-helm-message-bus-mssql

## Synopsis

Bring up a reference implementation Senzing stack on Kubernetes
using Microsoft Azure Kubernetes Service, Azure Message Bus Queue,
Azure SQL Database, `kubectl`, and `helm`.

## Overview

These instructions illustrate a reference implementation of Senzing using
Microsoft's Azure SQL Database as the underlying database.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet and sends each JSON line to a message queue using the Senzing
   [stream-producer](https://github.com/Senzing/stream-producer).
    1. In this implementation, the queue is an
       [Azure Message Bus](https://azure.microsoft.com/en-us/services/service-bus/) queue.
1. Reads messages from the queue and inserts into Senzing via the Senzing
   [stream-loader](https://github.com/Senzing/stream-loader).
    1. In this implementation, Senzing keeps its data in an
       [Azure SQL Database](https://azure.microsoft.com/en-us/products/azure-sql/database/#overview) database.
1. Reads information from Senzing using the [Senzing API Server](https://github.com/Senzing/senzing-api-server) server.
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
    1. [Azure login](#azure-login)
    1. [EULA](#eula)
    1. [Set environment variables](#set-environment-variables)
    1. [Identify Docker registry](#identify-docker-registry)
    1. [Create an Azure Resource Group](#create-an-azure-resource-group)
    1. [Create an Azure Service Bus Queue](#create-an-azure-service-bus-queue)
    1. [Create an Azure SQL Database](#create-an-azure-sql-database)
    1. [Create an Azure Kubernetes Service Cluster](#create-an-azure-kubernetes-service-cluster)
    1. [Connect to your AKS Cluster](#connect-to-your-aks-cluster)
    1. [Create custom helm values files](#create-custom-helm-values-files)
    1. [Create custom kubernetes configuration files](#create-custom-kubernetes-configuration-files)
    1. [Save environment variables](#save-environment-variables)
    1. [Create namespace](#create-namespace)
    1. [Create persistent volume](#create-persistent-volume)
    1. [Add helm repositories](#add-helm-repositories)
    1. [Deploy Senzing](#deploy-senzing)
    1. [Install senzing-console Helm chart](#install-senzing-console-helm-chart)
    1. [Initialize database](#initialize-database)
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
        1. [View Azure Resource Group](#view-azure-resource-group)
        1. [View Azure Service Bus Queue](#view-azure-service-bus-queue)
        1. [View Azure SQL Database](#view-azure-sql-database)
        1. [View Azure Kubernetes Service Cluster](#view-azure-kubernetes-service-cluster)
        1. [View Senzing Console pod](#view-senzing-console-pod)
        1. [View Kubernetes services](#view-kubernetes-services)
        1. [View Senzing API Server](#view-senzing-api-server)
        1. [View Senzing Entity Search WebApp](#view-senzing-entity-search-webapp)
        1. [View SwaggerUI](#view-swaggerui)
        1. [View Senzing Configurator](#view-senzing-configurator)
1. [Cleanup](#cleanup)
    1. [Delete everything in Kubernetes](#delete-everything-in-kubernetes)
    1. [Delete Azure Kubernetes Service Cluster](#delete-azure-kubernetes-service-cluster)
    1. [Delete Azure SQL Database](#delete-azure-sql-database)
    1. [Delete Azure Service Bus Queue](#delete-azure-service-bus-queue)
    1. [Delete Azure Resource Group](#delete-azure-resource-group)
1. [Errors](#errors)
1. [References](#references)

## Preamble

At [Senzing](http://senzing.com),
we strive to create GitHub documentation in a
"[don't make me think](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/dont-make-me-think.md)" style.
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
  - [Docker](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/docker.md)
  - [Kubernetes](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/kubernetes.md)
  - [Helm](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/helm.md)

## Prerequisites

### Prerequisite software

1. [Azure subscription](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/azure-subscription.md)
1. [Azure Command Line Interface (CLI)](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/azure-cli.md)
1. [kubectl](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/kubectl.md)
1. [Helm 3](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/helm.md)

### Clone repository

The Git repository has files that will be used in the `helm install --values` parameter.

1. Using these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=kubernetes-demo
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

1. Follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/clone-repository.md) to install the Git repository.

### Create demo directory

1. :pencil2: Create a unique prefix.
   This will be used in a local directory name
   as well as a prefix to create unique names in Azure.

   :warning:  Because it's used in Kubernetes resource names,
   it must be all lowercase.

   Example:

    ```console
    export DEMO_PREFIX=xyzzy
    ```

1. Make a directory for the demo.
   Example:

    ```console
    export SENZING_DEMO_DIR=~/senzing-azure-demo-${DEMO_PREFIX}
    mkdir -p ${SENZING_DEMO_DIR}
    ```

### Azure login

1. Login to Azure.
   Example:

    ```console
    az login \
        > ${SENZING_DEMO_DIR}/az-login.json
    ```

### EULA

To use the Senzing code, you must agree to the End User License Agreement (EULA).

1. :warning: This step is intentionally tricky and not simply copy/paste.
   This ensures that you make a conscious effort to accept the EULA.
   Example:

    <pre>export SENZING_ACCEPT_EULA="&lt;the value from <a href="https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_accept_eula">this link</a>&gt;"</pre>

To use the "MICROSOFT ODBC DRIVER 17 FOR SQL SERVER", you must agree to the End User License Agreement (EULA).

1. :warning: This step is intentionally tricky and not simply copy/paste.
   This ensures that you make a conscious effort to accept the EULA.
   Example:

    <pre>export MSSQL_ACCEPT_EULA="&lt;the value from <a href="https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#mssql_accept_eula">this link</a>&gt;"</pre>

### Set environment variables

1. Set environment variables listed in "[Clone repository](#clone-repository)".

1. :pencil2: Identify Azure location.
   See [az-group-create > Required Parameters > --location](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az_group_create-required-parameters).
   Example:

    ```console
    export SENZING_AZURE_LOCATION=eastus
    ```

1. :pencil2: Specify Azure SQL Database credentials.
   Example:

    ```console
    export DATABASE_USERNAME=senzing
    export DATABASE_PASSWORD=$(< /dev/urandom tr -dc [:alnum:] | head -c${1:-20};echo;)
    echo "DATABASE_PASSWORD: ${DATABASE_PASSWORD}"
    ```

1. :pencil2: Specify Azure SQL Database firewall parameters.
   See [az sql server firewall-rule > Optional Parameters.](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_create-optional-parameters)
   Example:

    ```console
    export SENZING_AZURE_DATABASE_BEGIN_IP=0.0.0.0
    export SENZING_AZURE_DATABASE_END_IP=0.0.0.0
    ```

1. Synthesize environment variables.
   Example:

    ```console
    export DATABASE_DATABASE=G2
    export DEMO_NAMESPACE=${DEMO_PREFIX}-namespace
    export SENZING_AZURE_ACR_NAME="${DEMO_PREFIX}Acr"
    export SENZING_AZURE_AKS_NAME="${DEMO_PREFIX}Aks"
    export SENZING_AZURE_QUEUE_NAME="${DEMO_PREFIX}Queue"
    export SENZING_AZURE_RESOURCE_GROUP_NAME="${DEMO_PREFIX}ResourceGroup"
    export SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME="${DEMO_PREFIX}ServiceBus"
    export SENZING_AZURE_SQL_FIREWALL="${DEMO_PREFIX}SqlFirewall"
    export SENZING_AZURE_SQL_SERVER=${DEMO_PREFIX}SqlServer
    ```

1. Retrieve docker image version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/docker-versions-stable.sh)
    ```

1. Retrieve Helm Chart version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/helm-versions-stable.sh)
    ```

1. Retrieve Senzing version numbers and set their environment variables.
   Example:

    ```console
    source <(curl -X GET https://raw.githubusercontent.com/Senzing/knowledge-base/main/lists/senzing-versions-stable.sh)
    ```

1. :thinking: **Optional:**
   To use a license other than the Senzing complimentary 100K record license,
   the `SENZING_LICENSE_BASE64_ENCODED` environment variable needs to be set.
   *Note:* Modify the path to a file containing the Senzing license in Base64 format.
   Example:

    ```console
    export SENZING_LICENSE_BASE64_ENCODED=$(cat /etc/opt/senzing/g2lic_base64.txt)

    echo ${SENZING_LICENSE_BASE64_ENCODED}
    ```

### Identify Docker registry

1. Use the default public `docker.io` registry which pulls images from
   [hub.docker.com](https://hub.docker.com/).
   Example:

    ```console
    export DOCKER_REGISTRY_URL=docker.io
    export DOCKER_REGISTRY_SECRET=${DOCKER_REGISTRY_URL}-secret
    ```

### Create an Azure Resource Group

1. Create Resource group
   using
   [az group create](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az_group_create).
   Example:

    ```console
    az group create \
        --name ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --location ${SENZING_AZURE_LOCATION} \
        > ${SENZING_DEMO_DIR}/az-group-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups).

### Create an Azure Service Bus Queue

1. Create Azure Service Bus Namespace
   using
   [az servicebus namespace create](https://docs.microsoft.com/en-us/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_create).
   Example:

    ```console
    az servicebus namespace create \
        --location ${SENZING_AZURE_LOCATION} \
        --name ${SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        > ${SENZING_DEMO_DIR}/az-servicebus-namespace-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ServiceBus%2Fnamespaces).

1. Create Azure Queue in the Service Bus
   using
   [az servicebus queue create](https://docs.microsoft.com/en-us/cli/azure/servicebus/queue?view=azure-cli-latest#az_servicebus_queue_create).
   Example:

    ```console
    az servicebus queue create \
        --name ${SENZING_AZURE_QUEUE_NAME} \
        --namespace-name ${SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        > ${SENZING_DEMO_DIR}/az-servicebus-queue-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ServiceBus%2Fnamespaces).
   Select service bus.
   Near bottom, select "Queues" tab.

1. Create Authorization keys
   using
   [az servicebus namespace authorization-rule keys list](https://docs.microsoft.com/en-us/cli/azure/servicebus/namespace/authorization-rule/keys?view=azure-cli-latest#az_servicebus_namespace_authorization_rule_keys_list).
   Example:

    ```console
    az servicebus namespace authorization-rule keys list \
        --name RootManageSharedAccessKey \
        --namespace-name ${SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        > ${SENZING_DEMO_DIR}/az-servicebus-namespace-authorization-rule-keys-list.json
    ```

   FIXME: View in [Azure portal](https://portal.azure.com).
1. Capture values in environment variables.
   Example:

    ```console
    export SENZING_AZURE_QUEUE_CONNECTION_STRING=$(jq --raw-output ".primaryConnectionString" ${SENZING_DEMO_DIR}/az-servicebus-namespace-authorization-rule-keys-list.json)
    export SENZING_AZURE_QUEUE_NAME=$(jq --raw-output ".name" ${SENZING_DEMO_DIR}/az-servicebus-queue-create.json)
    ```

1. References:
    1. [Use the Azure CLI to create a Service Bus namespace and a queue](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-quickstart-cli)

### Create an Azure SQL Database

1. Create Azure SQL server
   using
   [az sql server create](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az_sql_server_create).
   Example:

    ```console
    az sql server create \
        --admin-password ${DATABASE_PASSWORD} \
        --admin-user ${DATABASE_USERNAME} \
        --location ${SENZING_AZURE_LOCATION}  \
        --name ${SENZING_AZURE_SQL_SERVER} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        > ${SENZING_DEMO_DIR}/az-sql-server-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fazuresql).

1. Configure a firewall rule for the server
   using
   [az sql server firewall-rule create](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_create).
   Example:

    ```console
    az sql server firewall-rule create \
        --end-ip-address ${SENZING_AZURE_DATABASE_END_IP} \
        --name ${SENZING_AZURE_SQL_FIREWALL} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --server ${SENZING_AZURE_SQL_SERVER} \
        --start-ip-address ${SENZING_AZURE_DATABASE_BEGIN_IP} \
        > ${SENZING_DEMO_DIR}/az-sql-server-firewall-rule-create.json
    ```

   FIXME: View in [Azure portal](https://portal.azure.com).

1. Create a single database
   using
   [az sql db create](https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az_sql_db_create).
   Example:

    ```console
    az sql db create \
        --capacity 2 \
        --compute-model Serverless \
        --edition GeneralPurpose \
        --family Gen5 \
        --name ${DATABASE_DATABASE} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --server ${SENZING_AZURE_SQL_SERVER} \
        > ${SENZING_DEMO_DIR}/az-sql-db-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fservers%2Fdatabases).

1. Capture values in environment variables.
   Example:

    ```console
    export DATABASE_HOST=$(tail +2 ${SENZING_DEMO_DIR}/az-sql-server-create.json | jq --raw-output ".fullyQualifiedDomainName")
    ```

1. References:
    1. [Create an Azure SQL Database single database](https://docs.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart?tabs=azure-cli)

### Create an Azure Kubernetes Service Cluster

1. [Create Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/quickstart-helm#create-an-aks-cluster)
   using
   [az aks create](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create)
   Example:

    ```console
    az aks create \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --name ${SENZING_AZURE_AKS_NAME} \
        --location ${SENZING_AZURE_LOCATION} \
        --generate-ssh-keys \
        > ${SENZING_DEMO_DIR}/az-aks-create.json
    ```

   View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters).

### Connect to your AKS cluster

1. [Connect to your AKS cluster](https://docs.microsoft.com/en-us/azure/aks/quickstart-helm#connect-to-your-aks-cluster).
   Get credentials for `kubectl` using
   [az aks get-credential](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_get_credentials)
   Example:

    ```console
    az aks get-credentials \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --name ${SENZING_AZURE_AKS_NAME}
    ```

### View Kubernetes

The [Kubernetes dashboard](https://github.com/kubernetes/dashboard)
can be used to view Kubernetes in the Azure Kubernetes Service (AKS).

1. References:
    1. [Access the Kubernetes web dashboard in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard)
    1. [Deploy and Access the Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
    1. [Access the Kubernetes Dashboard in Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-solution-template-kubernetes-dashboard?view=azs-2102)

### Create custom helm values files

For final customization of the Helm Charts,
various files need to be created for use in the
`--values` parameter of `helm install`.

:thinking: In this step, Helm template files are populated with actual values.
There are two methods of accomplishing this.
Only one method needs to be performed.

1. **Method #1:** Helm template files are instantiated with actual values
   into `${HELM_VALUES_DIR}` directory by using
   [make-helm-values-files.sh](../../bin/make-helm-values-files.sh).

    ```console
    export HELM_VALUES_DIR=${SENZING_DEMO_DIR}/helm-values
    ${GIT_REPOSITORY_DIR}/bin/make-helm-values-files.sh
    ```

1. **Method #2:** Copy and manually modify files method.
   Example:

    ```console
    export HELM_VALUES_DIR=${SENZING_DEMO_DIR}/helm-values
    mkdir -p ${HELM_VALUES_DIR}

    cp ${GIT_REPOSITORY_DIR}/helm-values-templates/* ${HELM_VALUES_DIR}
    ```

    :pencil2: Edit files in ${HELM_VALUES_DIR} replacing the following variables with actual values.

    1. `${DEMO_PREFIX}`
    1. `${DOCKER_REGISTRY_SECRET}`
    1. `${DOCKER_REGISTRY_URL}`
    1. `${SENZING_ACCEPT_EULA}`

1. :thinking: **Optional:**
   List newly generated files.
   Example:

    ```console
    ls ${HELM_VALUES_DIR}
    ```

### Create custom kubernetes configuration files

Create Kubernetes manifest files for use with `kubectl create`.

:thinking: In this step, Kubernetes template files are populated with actual values.
There are two methods of accomplishing this.
Only one method needs to be performed.

1. **Method #1:** Kubernetes manifest files are instantiated with actual values
   into `{KUBERNETES_DIR}` directory by using
   [make-kubernetes-manifest-files.sh](../../bin/make-kubernetes-manifest-files.sh).
   Example:

    ```console
    export KUBERNETES_DIR=${SENZING_DEMO_DIR}/kubernetes
    ${GIT_REPOSITORY_DIR}/bin/make-kubernetes-manifest-files.sh
    ```

1. **Method #2:** Copy and manually modify files method.
   Example:

    ```console
    export KUBERNETES_DIR=${SENZING_DEMO_DIR}/kubernetes
    mkdir -p ${KUBERNETES_DIR}

    cp ${GIT_REPOSITORY_DIR}/kubernetes-templates/* ${KUBERNETES_DIR}
    ```

    :pencil2: Edit files in ${KUBERNETES_DIR} replacing the following variables with actual values.

    1. `${DEMO_NAMESPACE}`

### Save environment variables

Environment variables will be needed in new terminal windows using
[save-environment-variables.sh](../../bin/save-environment-variables.sh).

1. Save environment variables into a file that can be sourced.
   Example:

    ```console
    ${GIT_REPOSITORY_DIR}/bin/save-environment-variables.sh
    ```

### Create namespace

A new
[Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
is created to isolate this demonstration from other applications running on Kubernetes.

1. Create Kubernetes namespace using
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

### Create persistent volume

"Azure Files" have been selected over "Azure Disks" because:
> Since Azure Disks are mounted as ReadWriteOnce, they're only available to a single pod.
> -- <https://docs.microsoft.com/en-us/azure/aks/concepts-storage#volumes>

1. Create Storage Class using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/storage-class-azure.yaml
    ```

   Reference: [Dynamically create and use a persistent volume with Azure Files in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv)

1. Create persistent volume claims using
   [kubectl create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create).
   Example:

    ```console
    kubectl create -f ${KUBERNETES_DIR}/persistent-volume-claim-senzing-azure.yaml
    ```

1. :thinking: **Optional:**
   Review persistent volumes and claims using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get persistentvolumeClaims \
      --namespace ${DEMO_NAMESPACE}
    ```

#### View persistent volume

To view persistent volume:

1. Visit [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ClassicStorage%2FStorageAccounts).
1. Select storage account having resource group containing value of `DEMO_PREFIX`.
1. In "Data Storage" section, select "File shares"
1. Select "kubernetes-dynamic-pvc-...`

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

### Deploy Senzing

:thinking: This deployment initializes the Persistent Volume with Senzing code and data
at `/opt/senzing/g2` and `/opt/senzing/data`.
These paths are relative to inside the containers via PVC mounts.
The actual location on the PVC may vary.

There are 2 options when it comes to initializing the Persistent Volume with Senzing code and data.
Choose one:

1. [Root container method](#root-container-method) - requires a root container
1. [Non-root container method](#non-root-container-method) - can be done on kubernetes with a non-root container

#### Root container method

**Method #1:** This method is simpler, but requires a root container.
This method uses a dockerized [apt](https://github.com/Senzing/docker-apt) command.

1. Install
   [senzing/senzing-apt](https://github.com/Senzing/charts/tree/main/charts/senzing-apt)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-apt \
      senzing/senzing-apt \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-apt-mssql.yaml \
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
    xyzzy-senzing-apt-8n2ql    0/1     Completed   0          2m44s
    ```

1. :thinking: **Optional:**
   To see results of installation, [view persistent volume](#view-persistent-volume).

#### Non-root container method

**Method #2:** This method can be done on kubernetes with a non-root container.
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

1. Install
   [senzing/senzing-base](https://github.com/Senzing/charts/tree/main/charts/senzing-base)
   chart with non-root container using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   This pod will be the recipient of `kubectl cp` commands.
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-base \
      senzing/senzing-base \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-base.yaml \
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

1. :thinking: **Optional:**
   To see results of installation, [view persistent volume](#view-persistent-volume).

### Install senzing-console Helm chart

The [senzing-console](https://github.com/Senzing/docker-senzing-console)
will be used later to
inspect mounted volumes,
debug issues, or
run command-line tools.

1. Install
   [senzing/senzing-console](https://github.com/Senzing/charts/tree/main/charts/senzing-console)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-console \
      senzing/senzing-console \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-console-mssql.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_CONSOLE:-""}
    ```

1. For the next steps, capture the pod name in `CONSOLE_POD_NAME` using
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    export CONSOLE_POD_NAME=$(kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --output jsonpath="{.items[0].metadata.name}" \
      --selector "app.kubernetes.io/name=senzing-console, \
                  app.kubernetes.io/instance=${DEMO_PREFIX}-senzing-console" \
      )
    ```

1. To use senzing-console pod, see [View Senzing Console pod](#view-senzing-console-pod).

### Install Senzing license

To ingest more than the default number of allowed records, a
[Senzing license](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/obtain-senzing-license.md)
is needed in the `/etc/opt/senzing` directory.

1. :pencil2: Identify location of license on local system.
   Example:

    ```console
    export SENZING_G2_LICENSE_PATH=/path/to/local/g2.lic
    ```

1. Copy the Senzing license to `/etc/opt/senzing/g2.lic`
   on pod's mounted volumes.
   Example:

    ```console
    kubectl cp \
      ${SENZING_G2_LICENSE_PATH} \
      ${DEMO_NAMESPACE}/${CONSOLE_POD_NAME}:/etc/opt/senzing/g2.lic
    ```

### Initialize database

1. [microsoft-mssql-tools](https://github.com/Senzing/charts/tree/main/charts/microsoft-mssql-tools)
   is used to create tables in the database (i.e. the schema) used by Senzing using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-microsoft-mssql-tools \
      senzing/microsoft-mssql-tools \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/microsoft-mssql-tools.yaml \
      --version ${SENZING_HELM_VERSION_MICROSOFT_MSSQL_TOOLS:-""}
    ```

1. View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fservers%2Fdatabases).
    1. Choose database. (Usually `G2`)
    1. Choose "Query editor" using `DATABASE_USERNAME` and `DATABASE_PASSWORD` values to log in.

### Install init-container Helm chart

The [init-container](https://github.com/Senzing/docker-init-container)
creates files from templates and initializes the G2 database.

1. Install
   [senzing/senzing-init-container](https://github.com/Senzing/charts/tree/main/charts/senzing-init-container)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-init-container \
      senzing/senzing-init-container \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-init-container-mssql.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_INIT_CONTAINER:-""}
    ```

1. Wait for pod to complete
   [kubectl get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get).
   Example:

    ```console
    kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --watch
    ```

### Install stream-producer Helm chart

The [stream producer](https://github.com/Senzing/stream-producer)
pulls JSON lines from a file and pushes them to a message queue.

1. Install
   [senzing/senzing-stream-producer](https://github.com/Senzing/charts/tree/main/charts/senzing-stream-producer)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-stream-producer \
      senzing/senzing-stream-producer \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-stream-producer-azure-queue.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_STREAM_PRODUCER:-""}
    ```

1. View in [Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ServiceBus%2Fnamespaces).
   Select service bus.
   Near bottom, select "Queues" tab.

### Install stream-loader Helm chart

The [stream loader](https://github.com/Senzing/stream-loader)
pulls messages from a message queue and sends them to Senzing.

1. Install
   [senzing/senzing-stream-loader](https://github.com/Senzing/charts/tree/main/charts/senzing-stream-loader)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-stream-loader \
      senzing/senzing-stream-loader \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-stream-loader-azure-queue-mssql.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_STREAM_LOADER:-""}
    ```

### Install senzing-api-server Helm chart

The [Senzing API server](https://github.com/Senzing/senzing-api-server)
receives HTTP requests to read and modify Senzing data.

1. Install
   [senzing/senzing-api-server](https://github.com/Senzing/charts/tree/main/charts/senzing-api-server)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-api-server \
      senzing/senzing-api-server \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-api-server-mssql.yaml \
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

### Install senzing-entity-search-web-app Helm chart

The [Senzing Entity Search WebApp](https://github.com/Senzing/entity-search-web-app)
is a light-weight WebApp demonstrating Senzing search capabilities.

1. Install
   [senzing/senzing-entity-search-web-app](https://github.com/Senzing/charts/tree/main/charts/senzing-entity-search-web-app)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-entity-search-web-app \
      senzing/senzing-entity-search-web-app \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-entity-search-web-app.yaml \
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

### Optional charts

These charts are not necessary for the demonstration,
but may be valuable in a production environment.

#### Install senzing-redoer Helm chart

The [redoer](https://github.com/Senzing/redoer) pulls Senzing redo records from the Senzing database and re-processes.

1. Install
   [senzing/senzing-redoer](https://github.com/Senzing/charts/tree/main/charts/senzing-redoer)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-redoer \
      senzing/senzing-redoer \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-redoer-mssql.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_REDOER:-""}
    ```

#### Install SwaggerUI Helm chart

The [SwaggerUI](https://swagger.io/tools/swagger-ui/) is a micro-service
for viewing the Senzing REST OpenAPI specification in a web browser.

1. Install
   [senzing/swaggerapi-swagger-ui](https://github.com/Senzing/charts/tree/main/charts/swaggerapi-swagger-ui)
   chart using
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

#### Install configurator Helm chart

The [Senzing Configurator](https://github.com/Senzing/configurator) is a micro-service for changing Senzing configuration.

1. Install
   [senzing/senzing-configurator](https://github.com/Senzing/charts/tree/main/charts/senzing-configurator)
   chart using
   [helm install](https://helm.sh/docs/helm/helm_install/).
   Example:

    ```console
    helm install \
      ${DEMO_PREFIX}-senzing-configurator \
      senzing/senzing-configurator \
      --namespace ${DEMO_NAMESPACE} \
      --values ${HELM_VALUES_DIR}/senzing-configurator-mssql.yaml \
      --version ${SENZING_HELM_VERSION_SENZING_CONFIGURATOR:-""}
    ```

1. To view Senzing Configurator, see [View Senzing Configurator](#view-senzing-configurator).

### View data

1. Username and password for the following sites are the values seen in the corresponding "values" YAML file located in
   [helm-values-templates](../helm-values-templates).
1. :pencil2: When using a separate terminal window in each of the examples below, set environment variables.
   **Note:** Replace `${DEMO_PREFIX}` with the actual DEMO_PREFIX value.
   Example:

    ```console
    source ~/senzing-azure-demo-${DEMO_PREFIX}/environment.sh
    ```

#### View Azure Resource Group

1. View [Resource Group](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups).

#### View Azure Service Bus Queue

1. View [Service Bus](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ServiceBus%2Fnamespaces).
    1. Select service bus.
    1. Near bottom, select "Queues" tab.

#### View Azure SQL Database

1. View [MS SQL Server](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fazuresql)
   in Azure Portal.
1. View [Database](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fservers%2Fdatabases)
   in Azure Portal.

#### View Azure Kubernetes Service Cluster

1. View [Kubernetes cluster](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters)
   in Azure Portal.

#### View Senzing Console pod

The [senzing-console](https://github.com/Senzing/docker-senzing-console)
is used to inspect mounted volumes, debug issues, or run command-line tools.

1. In a separate terminal window, log into Senzing Console pod using
   [kubectl exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec).
   Example:

    ```console
    export CONSOLE_POD_NAME=$(kubectl get pods \
      --namespace ${DEMO_NAMESPACE} \
      --output jsonpath="{.items[0].metadata.name}" \
      --selector "app.kubernetes.io/name=senzing-console, \
                  app.kubernetes.io/instance=${DEMO_PREFIX}-senzing-console" \
      )

    kubectl exec -it --namespace ${DEMO_NAMESPACE} ${CONSOLE_POD_NAME} -- /bin/bash
    ```

#### View Kubernetes services

The Senzing API Server, Senzing Entity Search WebApp, SwaggerUI, and Senzing Configurator
can be reached via the Kubernetes Services.

1. View [Kubernetes cluster](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.ContainerService%2FmanagedClusters)
   in Azure Portal.
1. Click the **Name** of the Kubernetes cluster.
1. In **Kubernetes resources**, click "Services and ingresses".
1. To condense the list, in **Filter by namespace**, choose the appropriate namespace.
   (Format: ${DEMO_PREFIX}-namespace).
1. Services can be reached by clicking on the appropriate **External IP** value.

#### View Senzing API Server

The [Senzing API server](https://github.com/Senzing/senzing-api-server)
receives HTTP requests to read and modify Senzing data.

1. In a separate terminal window, port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-api-server 8250:80
    ```

1. Make HTTP calls using `curl`.
   Example:

    ```console
    export SENZING_API_SERVICE=http://localhost:8250

    curl -X GET ${SENZING_API_SERVICE}/heartbeat
    curl -X GET ${SENZING_API_SERVICE}/license
    curl -X GET ${SENZING_API_SERVICE}/entities/1
    ```

#### View Senzing Entity Search WebApp

The [Senzing Entity Search WebApp](https://github.com/Senzing/entity-search-web-app)
is a light-weight WebApp demonstrating Senzing search capabilities.

1. In a separate terminal window, port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-entity-search-web-app 8251:80
    ```

1. Senzing Entity Search WebApp will be viewable at [localhost:8251](http://localhost:8251).
   The [demonstration](https://github.com/Senzing/knowledge-base/blob/main/demonstrations/docker-compose-web-app.md)
   instructions will give a tour of the Senzing web app.

#### View SwaggerUI

The [SwaggerUI](https://swagger.io/tools/swagger-ui/) is a micro-service
for viewing the Senzing REST OpenAPI specification in a web browser.

1. In a separate terminal window, port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-swaggerapi-swagger-ui 9180:80
    ```

   Then visit [http://localhost:9180](http://localhost:9180).

#### View Senzing Configurator

The [Senzing Configurator](https://github.com/Senzing/configurator) is a micro-service for changing Senzing configuration.

1. If the Senzing configurator was deployed,
   in a separate terminal window port forward to local machine using
   [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).
   Example:

    ```console
    kubectl port-forward \
      --address 0.0.0.0 \
      --namespace ${DEMO_NAMESPACE} \
      svc/${DEMO_PREFIX}-senzing-configurator 8253:80
    ```

1. Make HTTP calls using `curl`.
   Example:

    ```console
    export SENZING_API_SERVICE=http://localhost:8253

    curl -X GET ${SENZING_API_SERVICE}/datasources
    ```

## Cleanup

The following commands remove the Senzing Demo application from Kubernetes.

### Delete everything in Kubernetes

Delete Kubernetes artifacts using
[helm uninstall](https://helm.sh/docs/helm/helm_uninstall/),
[helm repo remove](https://helm.sh/docs/helm/helm_repo_remove/), and
[kubectl delete](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete).

1. Example:

    ```console
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-configurator
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-swaggerapi-swagger-ui
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-redoer
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-entity-search-web-app
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-api-server
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-stream-loader
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-init-container
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-stream-producer
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-microsoft-mssql-tools
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-console
    helm uninstall --namespace ${DEMO_NAMESPACE} ${DEMO_PREFIX}-senzing-apt
    helm repo remove senzing
    helm repo remove bitnami
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-claim-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/persistent-volume-senzing.yaml
    kubectl delete -f ${KUBERNETES_DIR}/namespace.yaml
    ```

1. :pencil2: Delete `kubectl config` values.
   Example:

    ```console
    kubectl config delete-cluster  "${DEMO_PREFIX}Aks"
    kubectl config delete-context  "${DEMO_PREFIX}Aks"
    kubectl config delete-user     "clusterUser_${DEMO_PREFIX}ResourceGroup_${DEMO_PREFIX}Aks"
    ```

### Delete Azure Kubernetes Service Cluster

1. Delete the Azure Kubernetes Service cluster using
   [az aks delete](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_delete).

    ```console
    az aks delete \
        --name ${SENZING_AZURE_AKS_NAME} \
        --no-wait \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --yes
    ```

### Delete Azure SQL Database

1. Delete the Azure SQL database using
   [az sql db delete](https://docs.microsoft.com/en-us/cli/azure/sql/db?view=azure-cli-latest#az_sql_db_delete).

    ```console
    az sql db delete \
        --name ${DATABASE_DATABASE} \
        --no-wait \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --server ${SENZING_AZURE_SQL_SERVER} \
        --yes
    ```

1. Delete the Azure SQL server using
   [az sql server delete](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az_sql_server_delete).

    ```console
    az sql server delete \
        --name ${SENZING_AZURE_SQL_SERVER} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --yes
    ```

### Delete Azure Service Bus Queue

1. Delete the Azure Queue using
   [az servicebus queue delete](https://docs.microsoft.com/en-us/cli/azure/servicebus/queue?view=azure-cli-latest#az_servicebus_queue_delete).

    ```console
    az servicebus queue delete \
        --name ${SENZING_AZURE_QUEUE_NAME} \
        --namespace-name ${SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME}
    ```

1. Delete the Azure Message Bus Namespace using
   [az servicebus Namespace delete](https://docs.microsoft.com/en-us/cli/azure/servicebus/namespace?view=azure-cli-latest#az_servicebus_namespace_delete).

    ```console
    az servicebus namespace delete \
        --name ${SENZING_AZURE_SERVICE_BUS_NAMESPACE_NAME} \
        --resource-group ${SENZING_AZURE_RESOURCE_GROUP_NAME}
    ```

### Delete Azure Resource Group

1. Delete the Azure Resource Group using
   [az group delete](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az_group_delete).

    ```console
    az group delete \
        --name ${SENZING_AZURE_RESOURCE_GROUP_NAME} \
        --yes \
        --no-wait
    ```

## Errors

1. See [docs/errors.md](docs/errors.md).

## References
