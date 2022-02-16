#!/usr/bin/env bash

# Save environment variable values into a file that can be "sourced" later.

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
