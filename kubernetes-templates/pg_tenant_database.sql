CREATE DATABASE g2_${SENZING_TENANT};
CREATE USER ${SENZING_TENANT} WITH PASSWORD '${DATABASE_PASSWORD}';
GRANT CONNECT ON DATABASE g2_${SENZING_TENANT} TO ${SENZING_TENANT};
