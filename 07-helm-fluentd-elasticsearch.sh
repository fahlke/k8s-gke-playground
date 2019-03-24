#!/bin/bash

# https://kiwigrid.github.io
# https://github.com/kiwigrid/helm-charts/tree/master/charts/fluentd-elasticsearch

if [[ -z "$1" ]]; then
  echo "Usage: 07-helm-fluentd-elasticsearch.sh <firstname.lastname>"
  exit
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERT_DIR="${BASEDIR}/build/certificates"
USER_CERT_DIR="${BASEDIR}/build/certificates/users"

USER_NAME="$1"
USER_CONFIG="${USER_CERT_DIR}/${USER_NAME}.rc"

source ${USER_CONFIG}

helm repo add kiwigrid https://kiwigrid.github.io

tee /tmp/values.yaml >/dev/null <<EOF
elasticsearch:
  host: 'elastic-stack-dev-elasticsearch-client.monitoring.svc.cluster.local'
  port: 9200
  logstash_prefix: 'fluentd'

prometheusRule:
  enabled: true
  prometheusNamespace: default
EOF

helm install \
  --name fluentd-es-dev \
  --values /tmp/values.yaml \
  --namespace monitoring \
  kiwigrid/fluentd-elasticsearch

rm -f /tmp/values.yaml