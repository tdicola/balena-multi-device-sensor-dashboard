#!/bin/bash
# Small script to work around the issue of grafana not supporting environment
# variable substitution in its provisioning YAML files.  This will manually
# process the provisioning files and update them with the environment variable
# state, then invoke the grafana run script.  This is effectively a workaround
# for the bug/limitation here: https://github.com/grafana/grafana/issues/12896
set -e

cd /opt/grafana-6.0.0

echo 'run.sh: Replacing environment variables in provisioning configs.'
find ./conf/provisioning -name '*.yml' -exec sh -c 'envsubst < {} > {}' \;

./bin/grafana-server web \
  cfg:default.log.mode="console" \
  cfg:default.paths.data=/var/lib/grafana
