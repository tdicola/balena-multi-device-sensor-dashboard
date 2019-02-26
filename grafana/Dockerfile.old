FROM grafana/grafana

# Need to install gettext-base package for envsubst command used in pre_run.sh.
USER root
RUN apt-get update && \
    apt-get install -y gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Swap back to the grafana user the base container image expects to use.
USER grafana

# Add custom entrypoint script to allow running on specific devices, materialize
# config into files, etc.
COPY balena_entrypoint.sh /balena_entrypoint.sh

# Add another custom pre-run script that substitutes environment variables into
# grafana's YAML provisioning config files (work around for this bug:
# https://github.com/grafana/grafana/issues/12896).
COPY pre_run.sh /pre_run.sh

# Copy the provisioning config files into the default location grafana expects.
# Note that these will be processed by the pre_run.sh script to substitute
# environment variable values (like the InfluxDB user, password, etc.).
COPY provisioning /etc/grafana/provisioning
#RUN chown -R grafana:grafana /etc/grafana/provisioning

# Override the entrypoint to use our custom one, then call our custom pre-run
# init script (which will finally call the grafana contaienr run script).
ENTRYPOINT [ "/balena_entrypoint.sh", "/pre_run.sh" ]
