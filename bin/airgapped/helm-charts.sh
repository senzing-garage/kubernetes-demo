#!/usr/bin/env bash

# List all of the docker images to be installed into the Docker registry.

HELM_CHARTS=(
    "bitnami/postgresql;${SENZING_HELM_VERSION_BITNAMI_POSTGRESQL:-latest}"
    "bitnami/rabbitmq;${SENZING_HELM_VERSION_BITNAMI_RABBITMQ:-latest}"
    "runix/pgadmin4;${SENZING_HELM_VERSION_RUNIX_PGADMIN4:-latest}"
    "senzing/senzing-api-server;${SENZING_HELM_VERSION_SENZING_API_SERVER:-latest}"
    "senzing/senzing-configurator;${SENZING_HELM_VERSION_SENZING_CONFIGURATOR:-latest}"
    "senzing/senzing-console;${SENZING_HELM_VERSION_SENZING_CONSOLE:-latest}"
    "senzing/senzing-entity-search-web-app;${SENZING_HELM_VERSION_SENZING_ENTITY_SEARCH_WEB_APP:-latest}"
    "senzing/senzing-init-container;${SENZING_HELM_VERSION_SENZING_INIT_CONTAINER:-latest}"
    "senzing/senzing-installer;${SENZING_HELM_VERSION_SENZING_INSTALLER:-latest}"
    "senzing/senzing-postgresql-client;${SENZING_HELM_VERSION_SENZING_POSTGRESQL_CLIENT:-latest}"
    "senzing/senzing-redoer;${SENZING_HELM_VERSION_SENZING_REDOER:-latest}"
    "senzing/senzing-stream-loader;${SENZING_HELM_VERSION_SENZING_STREAM_LOADER:-latest}"
    "senzing/senzing-stream-producer;${SENZING_HELM_VERSION_SENZING_STREAM_PRODUCER:-latest}"
    "senzing/swaggerapi-swagger-ui;${SENZING_HELM_VERSION_SENZING_SWAGGERAPI_SWAGGER_UI:-latest}"
)
