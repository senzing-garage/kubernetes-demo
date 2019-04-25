# kubernetes-demo

## Overview

This repository illustrates a reference implementations of Senzing on Kubernetes.

The instructions show how to set up a system that:

1. Reads JSON lines from a file on the internet.
1. Sends each JSON line as a message to a Kafka topic.
1. Reads messages from the Kafka topic and inserts into Senzing.
1. Reads information from Senzing via [Senzing REST API](https://github.com/Senzing/senzing-rest-api) server.

The following diagram shows the relationship of the Helm charts, docker containers, and code in this Kubernetes demonstration.

![Image of architecture](docs/img-architecture/architecture.png)

Implementations of the docker formation:

1. [Using PostgreSQL database](docs/helm-postgresql-demo/README.md)
1. [Using DB2 database](docs/helm-db2-demo/README.md)
