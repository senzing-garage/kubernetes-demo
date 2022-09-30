#!/usr/bin/env bash

# List all of the docker images to be installed into the minikube registry.

DOCKER_IMAGES=(
    "bitnami/mysql:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_MYSQL:-latest}"
    "bitnami/phpmyadmin:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_PHPMYADMIN:-latest}"
    "bitnami/rabbitmq:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_RABBITMQ:-latest}"
    "senzing/entity-search-web-app:${SENZING_DOCKER_IMAGE_VERSION_ENTITY_SEARCH_WEB_APP:-latest}"
    "senzing/init-mysql:${SENZING_DOCKER_IMAGE_VERSION_INIT_MYSQL:-latest}"
    "senzing/redoer-mysql:${SENZING_DOCKER_IMAGE_VERSION_REDOER:-latest}"
    "senzing/senzing-api-server-mysql:${SENZING_DOCKER_IMAGE_VERSION_SENZING_API_SERVER:-latest}"
    "senzing/senzing-console-mysql:${SENZING_DOCKER_IMAGE_VERSION_SENZING_CONSOLE:-latest}"
    "senzing/stream-loader-mysql:${SENZING_DOCKER_IMAGE_VERSION_STREAM_LOADER:-latest}"
    "senzing/stream-producer:${SENZING_DOCKER_IMAGE_VERSION_STREAM_PRODUCER:-latest}"
    "swaggerapi/swagger-ui:${SENZING_DOCKER_IMAGE_VERSION_SWAGGERAPI_SWAGGER_UI:-latest}"
)
