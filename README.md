# kubernetes-demo

## Overview

This repository illustrates reference implementations of Senzing on Kubernetes.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet.
1. Sends each JSON line as a message to a queue.
1. Reads messages from the queue and inserts into Senzing.
1. Reads information from Senzing via [Senzing API Server](https://github.com/Senzing/senzing-api-server) server.
1. Views resolved entities in a [web app](https://github.com/Senzing/entity-search-web-app).

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](docs/img-architecture/architecture.png)

## Implementation

The following table indicates the instructions for variations in components.

1. Component variants:
    1. Queue
        1. RabbitMQ
        1. Kafka
        1. Azure Message Bus
    1. Database
        1. PostgreSQL
        1. MySQL
        1. Azure SQL Database
1. Reference implementations of the docker formation:

    | Queue             | Database           | Instructions   |
    |-------------------|--------------------|:--------------:|
    | RabbitMQ          | PostgreSQL         | [:page_facing_up:](docs/helm-rabbitmq-postgresql/README.md) |
    | RabbitMQ          | MySQL              | [:page_facing_up:](docs/helm-rabbitmq-mysql/README.md) |
    | Kafka             | PostgreSQL         | [:page_facing_up:](docs/helm-kafka-postgresql/README.md) |
    | Azure Message Bus | Azure SQL Database | [:page_facing_up:](docs/azure-helm-message-bus-mssql/README.md) |

1. Variations:
    1. [Instructions](docs/helm-rabbitmq-postgresql-airgapped/README.md) demonstrating PostgreSQL and RabbitMQ in an air-gapped Kubernetes environment.
    1. [Instructions](docs/helm-rabbitmq-postgresql-multi-tenant/README.md) demonstrating Kubernetes namespace-based multi-tenancy on Kubernetes.
    1. [Instructions](docs/azure-helm-message-bus-mssql/README.md) demonstrating Microsoft MS-SQL and Message bus on Azure Kubernetes Service (AKS).
    1. [Instructions](docs/azure-helm-rabbitmq-postgresql/README.md) demonstrating PostgreSQL and RabbitMQ on Azure Kubernetes Service (AKS).


