#!/usr/bin/env bash

# List all of the docker images to be installed into the minikube registry.

DOCKER_IMAGES=(
    "bitnami/postgresql:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_POSTGRESQL:-latest}"
    "bitnami/rabbitmq:${SENZING_DOCKER_IMAGE_VERSION_BITNAMI_RABBITMQ:-latest}"
    "dpage/pgadmin4:${SENZING_DOCKER_IMAGE_VERSION_DPAGE_PGADMIN4:-latest}"
    "senzing/configurator:${SENZING_DOCKER_IMAGE_VERSION_CONFIGURATOR:-latest}"
    "senzing/entity-search-web-app:${SENZING_DOCKER_IMAGE_VERSION_ENTITY_SEARCH_WEB_APP:-latest}"
    "senzing/init-postgresql:${SENZING_DOCKER_IMAGE_VERSION_INIT_POSTGRESQL:-latest}"
    "senzing/redoer:${SENZING_DOCKER_IMAGE_VERSION_REDOER:-latest}"
    "senzing/senzing-api-server:${SENZING_DOCKER_IMAGE_VERSION_SENZING_API_SERVER:-latest}"
    "senzing/senzing-console:${SENZING_DOCKER_IMAGE_VERSION_SENZING_CONSOLE:-latest}"
    "senzing/stream-loader:${SENZING_DOCKER_IMAGE_VERSION_STREAM_LOADER:-latest}"
    "senzing/stream-producer:${SENZING_DOCKER_IMAGE_VERSION_STREAM_PRODUCER:-latest}"
    "swaggerapi/swagger-ui:${SENZING_DOCKER_IMAGE_VERSION_SWAGGERAPI_SWAGGER_UI:-latest}"
)
