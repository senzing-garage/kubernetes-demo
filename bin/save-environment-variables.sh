#!/usr/bin/env bash

# Save environment variable values into a file that can be "sourced" later.

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
