CREATE DATABASE g2_${SENZING_TENANT};

CREATE USER ${SENZING_TENANT} WITH PASSWORD '${DATABASE_PASSWORD}';

GRANT CONNECT ON DATABASE g2_${SENZING_TENANT} TO ${SENZING_TENANT};

CONNECT TO g2_${SENZING_TENANT};

CREATE SCHEMA AUTHORIZATION ${SENZING_TENANT};

ALTER DATABASE g2_${SENZING_TENANT} SET search_path TO ${SENZING_TENANT};

ALTER USER ${SENZING_TENANT} SET search_path = ${SENZING_TENANT};

GRANT SELECT INSERT UPDATE DELETE TRUNCATE ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
