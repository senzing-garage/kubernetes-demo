# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
[markdownlint](https://dlaa.me/markdownlint/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2021-11-18

### Added in 1.4.1

- Helm deployment of SwaggerUI

### Changed in 1.4.1

- Migrate `helm-values-templates` files to work with Senzing Helm Charts 1.1.0
- Renamed files in `helm-values-templates` to be more consistent

## [1.4.0] - 2021-11-03

### Added in 1.4.0

- Improved documentation for Helm 3
- Support for specifying Helm Chart versions

### Removed in 1.4.0

- `docs/helm-kafka-db2`
- `docs/helm-rabbitmq-sqlite-cluster`
- `docs/helm-rabbitmq-sqlite`
- `helm-values-templates/coleifer-sqlite-web-libfeat.yaml`
- `helm-values-templates/coleifer-sqlite-web-res.yaml`
- `helm-values-templates/coleifer-sqlite-web.yaml`
- `helm-values-templates/configurator-sqlite-cluster.yaml`
- `helm-values-templates/configurator-sqlite.yaml`
- `helm-values-templates/db2-cluster.yaml`
- `helm-values-templates/hello-world-on-hub-docker-com.yaml`
- `helm-values-templates/hello-world.yaml`
- `helm-values-templates/init-container-sqlite-cluster.yaml`
- `helm-values-templates/init-container-sqlite.yaml`
- `helm-values-templates/redoer-sqlite-cluster.yaml`
- `helm-values-templates/redoer-sqlite.yaml`
- `helm-values-templates/senzing-api-server-sqlite-cluster.yaml`
- `helm-values-templates/senzing-api-server-sqlite.yaml`
- `helm-values-templates/senzing-console-sqlite-cluster.yaml`
- `helm-values-templates/senzing-console-sqlite.yaml`
- `helm-values-templates/senzing-debug.yaml`
- `helm-values-templates/stream-loader-kafka-db2.yaml`
- `helm-values-templates/stream-loader-kafka-mysql.yaml`
- `helm-values-templates/stream-loader-rabbitmq-sqlite-cluster.yaml`
- `helm-values-templates/stream-loader-rabbitmq-sqlite.yaml`
- `kubernetes-templates/persistent-volume-claim-db2-data-stor.yaml`
- `kubernetes-templates/persistent-volume-db2-data-stor.yaml`

## [1.3.0] - 2021-09-29

### Added in 1.3.0

- azure-helm-message-bus-mssql
- azure-helm-rabbitmq-postgresql

### Changed in 1.3.0

- Deprecated:
  - helm-kafka-db2
  - helm-rabbitmq-sqlite
  - helm-rabbitmq-sqlite-cluster
- Updated
  - helm-kafka-postgresql
  - helm-rabbitmq-db2
  - helm-rabbitmq-mysql
  - helm-rabbitmq-postgresql
- Replaced hard-coded docker image tags with environment variables
- Improved `helm-values-templates` files
- Updated images
- Added `mountOptIbm` and `mountOptMicrosoft` where applicable
- Added `engineConfigurationJson`

### Removed in 1.3.0

- Support for IBM Db2 OLTP

## [1.2.0] - 2020-07-22

### Changed in 1.2.0

- Replaced mock-data-generator with stream-producer

## [1.1.0] - 2020-07-08

### Changed in 1.1.0

- Cumulative changes prior to senzing 2.0.0 release

## [1.0.0] - 2019-12-02

### Added to 1.0.0

- Initial demonstrations
