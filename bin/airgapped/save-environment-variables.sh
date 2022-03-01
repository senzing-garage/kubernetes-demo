#!/usr/bin/env bash

# Save environment variable values into a file that can be "sourced" later.

# Test environment variables.

ERRORS=0

if [[ -z "${SENZING_AIRGAPPED_DIR}" ]]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_AIRGAPPED_DIR must be set"
fi

if [ ! -f "${SENZING_AIRGAPPED_DIR}/kubernetes-demo/helm-values-templates/senzing-stream-producer-rabbitmq.yaml" ]; then
    ERRORS=$((${ERRORS} + 1))
    echo "Error: SENZING_AIRGAPPED_DIR may not be set correctly."
    echo "       Current value: ${SENZING_AIRGAPPED_DIR}"
    echo "Error: Could not find ${SENZING_AIRGAPPED_DIR}/kubernetes-demo/helm-values-templates/senzing-stream-producer-rabbitmq.yaml"
fi

if [[ ${ERRORS} > 0 ]]; then
    echo "Error: No processing done. ${ERRORS} errors found."
    exit 1
fi

# Create a stub file.

cat <<EOT > ${SENZING_AIRGAPPED_DIR}/bin/environment.sh
#!/usr/bin/env bash

export GIT_REPOSITORY_DIR=\${SENZING_AIRGAPPED_DIR}/kubernetes-demo
EOT

# Append "export" statements to file.

env \
| grep \
    --regexp="^DOCKER_REGISTRY_URL" \
| sort \
| awk -F= '{ print "export", $0 }' \
>> ${SENZING_AIRGAPPED_DIR}/bin/environment.sh

# Make file executable.

chmod +x ${SENZING_AIRGAPPED_DIR}/bin/environment.sh
