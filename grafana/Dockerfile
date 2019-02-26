# Golang build container
FROM golang:1.11.5

ENV GOARM=7
ENV GOARCH=arm

WORKDIR $GOPATH/src/github.com/grafana/grafana

COPY ./grafana/Gopkg.toml ./grafana/Gopkg.lock ./
COPY ./grafana/vendor vendor

RUN go get -u github.com/golang/dep/cmd/dep && \
    dep ensure --vendor-only

COPY ./grafana/pkg pkg
COPY ./grafana/build.go build.go
COPY ./grafana/package.json package.json

RUN go run build.go build

# Node build container
FROM node:10.14.2

WORKDIR /usr/src/app/

COPY ./grafana/package.json yarn.lock ./
COPY ./grafana/packages packages

RUN yarn install --pure-lockfile --no-progress

COPY ./grafana/Gruntfile.js ./grafana/tsconfig.json ./grafana/tslint.json ./
COPY ./grafana/public public
COPY ./grafana/scripts scripts
COPY ./grafana/emails emails

ENV NODE_ENV production
RUN ./node_modules/.bin/grunt build

# Final container
FROM balenalib/armv7hf-debian:stretch

ARG GF_UID="472"
ARG GF_GID="472"

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -qq -y libfontconfig ca-certificates gettext-base && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY ./grafana/conf ./conf

RUN mkdir -p "$GF_PATHS_HOME/.aws" && \
    groupadd -r -g $GF_GID grafana && \
    useradd -r -u $GF_UID -g grafana grafana && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_PROVISIONING/notifiers" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" && \
    cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"

COPY --from=0 /go/src/github.com/grafana/grafana/bin/linux-amd64/grafana-server /go/src/github.com/grafana/grafana/bin/linux-amd64/grafana-cli ./bin/
COPY --from=1 /usr/src/app/public ./public
COPY --from=1 /usr/src/app/tools ./tools
COPY ./grafana/tools/phantomjs/render.js ./tools/phantomjs/render.js

EXPOSE 3000

COPY ./grafana/packaging/docker/run.sh /run.sh

# Add custom entrypoint script to allow running on specific devices, materialize
# config into files, etc.
COPY ./balena_entrypoint.sh /balena_entrypoint.sh

# Add another custom pre-run script that substitutes environment variables into
# grafana's YAML provisioning config files (work around for this bug:
# https://github.com/grafana/grafana/issues/12896).
COPY ./pre_run.sh /pre_run.sh

# Copy the provisioning config files into the default location grafana expects.
# Note that these will be processed by the pre_run.sh script to substitute
# environment variable values (like the InfluxDB user, password, etc.).
COPY ./provisioning /etc/grafana/provisioning
#RUN chown -R grafana:grafana /etc/grafana/provisioning

# Override the entrypoint to use our custom one, then call our custom pre-run
# init script (which will finally call the grafana contaienr run script).
USER grafana
ENTRYPOINT [ "/balena_entrypoint.sh", "/pre_run.sh" ]
