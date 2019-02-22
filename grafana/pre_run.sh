#!/bin/bash
# Small script to work around the issue of grafana not supporting environment
# variable substitution in its provisioning YAML files.  This will manually
# process the provisioning files and update them with the environment variable
# state, then invoke the grafana run script.  This is effectively a workaround
# for the bug/limitation here: https://github.com/grafana/grafana/issues/12896
set -e

echo 'pre_run.sh: Replacing environment variables in provisioning configs.'
find /etc/grafana/provisioning -name '*.yml' -exec sh -c 'envsubst < {} > {}' \;

# Execute grafana container's run script.
exec /run.sh
