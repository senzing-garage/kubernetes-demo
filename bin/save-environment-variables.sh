#!/usr/bin/env bash

# Save environment variable values into a file that can be "sourced" later.

# Test environment variables.

ERRORS=0

if [[ -z "${SENZING_DEMO_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_DEMO_DIR must be set"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# Create a stub file.

cat <<EOT > ${SENZING_DEMO_DIR}/environment.sh
#!/usr/bin/env bash

EOT

# Append "export" statements to file.

env \
| grep \
    --regexp="^DATABASE_" \
    --regexp="^DEMO_" \
    --regexp="^DATABASE_" \
    --regexp="^DOCKER_" \
    --regexp="^GIT_" \
    --regexp="^HELM_" \
    --regexp="^KUBERNETES_" \
    --regexp="^RABBITMQ_" \
    --regexp="^SENZING_" \
| sort \
| awk -F= '{ print "export", $0 }' \
>> ${SENZING_DEMO_DIR}/environment.sh

# Make file executable.

chmod +x ${SENZING_DEMO_DIR}/environment.sh
