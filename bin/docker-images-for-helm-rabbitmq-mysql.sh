#!/usr/bin/env bash

# List all of the docker images to be installed into the minikube registry.

DOCKER_IMAGES=(
    "arey/mysql-client:${SENZING_DOCKER_IMAGE_VERSION_AREY_MYSQL_CLIENT:-latest}"
    "bitnami/mysql:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_MYSQL:-latest}"
    "bitnami/phpmyadmin:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_PHPMYADMIN:-latest}"
    "bitnami/rabbitmq:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_RABBITMQ:-latest}"
    "senzing/apt:${SENZING_DOCKER_IMAGE_VERSION_APT:-latest}"
    "senzing/configurator:${SENZING_DOCKER_IMAGE_VERSION_CONFIGURATOR:-latest}"
    "senzing/entity-search-web-app:${SENZING_DOCKER_IMAGE_VERSION_ENTITY_SEARCH_WEB_APP:-latest}"
    "senzing/init-container:${SENZING_DOCKER_IMAGE_VERSION_INIT_CONTAINER:-latest}"
    "senzing/installer:${SENZING_VERSION_SENZINGAPI:-latest}"
    "senzing/postgresql-client:${SENZING_DOCKER_IMAGE_VERSION_POSTGRESQL_CLIENT:-latest}"
    "senzing/redoer:${SENZING_DOCKER_IMAGE_VERSION_REDOER:-latest}"
    "senzing/senzing-api-server:${SENZING_DOCKER_IMAGE_VERSION_SENZING_API_SERVER:-latest}"
    "senzing/senzing-base:${SENZING_DOCKER_IMAGE_VERSION_SENZING_BASE:-latest}"
    "senzing/senzing-console:${SENZING_DOCKER_IMAGE_VERSION_SENZING_CONSOLE:-latest}"
    "senzing/stream-loader:${SENZING_DOCKER_IMAGE_VERSION_STREAM_LOADER:-latest}"
    "senzing/stream-producer:${SENZING_DOCKER_IMAGE_VERSION_STREAM_PRODUCER:-latest}"
    "senzing/yum:${SENZING_DOCKER_IMAGE_VERSION_YUM:-latest}"
    "swaggerapi/swagger-ui:${SENZING_DOCKER_IMAGE_VERSION_SWAGGERAPI_SWAGGER_UI:-latest}"
)
