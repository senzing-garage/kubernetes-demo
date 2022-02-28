#!/usr/bin/env bash

# List all of the docker images to be installed into the minikube registry.

DOCKER_IMAGES=(
    "arey/mysql-client:${SENZING_DOCKER_IMAGE_VERSION_AREY_MYSQL_CLIENT:-latest}"
    "bitnami/kafka:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_KAFKA:-latest}"
    "bitnami/mysql:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_MYSQL:-latest}"
    "bitnami/nginx-ingress-controller:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_NGINX_INGRESS_CONTROLLER:-latest}"
    "bitnami/phpmyadmin:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_PHPMYADMIN:-latest}"
    "bitnami/postgresql:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_POSTGRESQL:-latest}"
    "bitnami/rabbitmq:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_RABBITMQ:-latest}"
    "bitnami/zookeeper:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_ZOOKEEPER:-latest}"
    "coleifer/sqlite-web:${SENZING_DOCKER_IMAGE_VERSION_SQLITE_WEB:-latest}"
    "confluentinc/cp-kafka:${SENZING_DOCKER_IMAGE_VERSION_CONFLUENTINC_CP_KAFKA:-latest}"
    "obsidiandynamics/kafdrop:${SENZING_DOCKER_IMAGE_VERSION_OBSIDIANDYNAMICS_KAFDROP:-latest}"
    "senzing/apt:${SENZING_DOCKER_IMAGE_VERSION_APT:-latest}"
    "senzing/configurator:${SENZING_DOCKER_IMAGE_VERSION_CONFIGURATOR:-latest}"
    "senzing/db2-driver-installer:${SENZING_DOCKER_IMAGE_VERSION_DB2_DRIVER_INSTALLER:-latest}"
    "senzing/entity-search-web-app:${SENZING_DOCKER_IMAGE_VERSION_ENTITY_SEARCH_WEB_APP:-latest}"
    "senzing/ibm-db2:${SENZING_DOCKER_IMAGE_VERSION_IBM_DB2:-latest}"
    "senzing/init-container:${SENZING_DOCKER_IMAGE_VERSION_INIT_CONTAINER:-latest}"
    "senzing/phppgadmin:${SENZING_DOCKER_IMAGE_VERSION_PHPPGADMIN:-latest}"
    "senzing/postgresql-client:${SENZING_DOCKER_IMAGE_VERSION_POSTGRESQL_CLIENT:-latest}"
    "senzing/redoer:${SENZING_DOCKER_IMAGE_VERSION_REDOER:-latest}"
    "senzing/resolver:${SENZING_DOCKER_IMAGE_VERSION_RESOLVER:-latest}"
    "senzing/senzing-api-server:${SENZING_DOCKER_IMAGE_VERSION_SENZING_API_SERVER:-latest}"
    "senzing/senzing-base:${SENZING_DOCKER_IMAGE_VERSION_SENZING_BASE:-latest}"
    "senzing/senzing-console:${SENZING_DOCKER_IMAGE_VERSION_SENZING_CONSOLE:-latest}"
    "senzing/senzing-debug:${SENZING_DOCKER_IMAGE_VERSION_SENZING_DEBUG:-latest}"
    "senzing/stream-loader:${SENZING_DOCKER_IMAGE_VERSION_STREAM_LOADER:-latest}"
    "senzing/stream-producer:${SENZING_DOCKER_IMAGE_VERSION_STREAM_PRODUCER:-latest}"
    "senzing/yum:${SENZING_DOCKER_IMAGE_VERSION_YUM:-latest}"
)
