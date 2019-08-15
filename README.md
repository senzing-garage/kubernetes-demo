# kubernetes-demo

## Overview

This repository illustrates reference implementations of Senzing on Kubernetes.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet.
1. Sends each JSON line as a message to a queue.
1. Reads messages from the queue and inserts into Senzing.
1. Reads information from Senzing via [Senzing REST API](https://github.com/Senzing/senzing-rest-api) server.

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](docs/img-architecture/architecture.png)

## Implementation

The following table indicates the instructions for variations in components.

1. Component variants:
    1. Queue
        1. RabbitMQ
        1. Kafka
    1. Database
        1. PostgreSQL
        1. Db2
        1. SQLite
1. Implementations of the docker formation:

    | Queue    | Database   | Instructions |
    |----------|------------|:------------:|
    | RabbitMQ | PostgreSQL | [:page_facing_up:](docs/helm-rabbitmq-postgresql/README.md) |
    | RabbitMQ | Db2        | [:page_facing_up:](docs/helm-rabbitmq-db2/README.md) |
    | RabbitMQ | SQLite     | [:page_facing_up:](docs/helm-rabbitmq-sqlite/README.md) |
    | Kafka    | PostgreSQL | [:page_facing_up:](docs/helm-kafka-postgresql/README.md) |
    | Kafka    | Db2        | [:page_facing_up:](docs/helm-kafka-db2/README.md) |
