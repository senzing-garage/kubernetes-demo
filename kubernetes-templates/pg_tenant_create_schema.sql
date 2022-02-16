CREATE SCHEMA AUTHORIZATION ${SENZING_TENANT};

SET search_path TO ${SENZING_TENANT};

ALTER DATABASE g2_${SENZING_TENANT} SET search_path TO ${SENZING_TENANT};

ALTER USER ${SENZING_TENANT} SET search_path = ${SENZING_TENANT};

GRANT SELECT   ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
GRANT INSERT   ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
GRANT UPDATE   ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
GRANT DELETE   ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
GRANT TRUNCATE ON ALL TABLES IN SCHEMA ${SENZING_TENANT} to ${SENZING_TENANT};
