#!/bin/bash

# https://github.com/helm/charts/tree/master/stable/prometheus-operator

if [[ -z "$1" ]]; then
  echo "Usage: 05-helm-prometheus-operator.sh <firstname.lastname>"
  exit
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERT_DIR="${BASEDIR}/build/certificates"
USER_CERT_DIR="${BASEDIR}/build/certificates/users"

USER_NAME="$1"
USER_CONFIG="${USER_CERT_DIR}/${USER_NAME}.rc"

source ${USER_CONFIG}

helm install \
  --name prometheus-dev \
  --namespace monitoring \
  stable/prometheus-operator

# https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/exposing-prometheus-and-alertmanager.md
# kubectl proxy &

# open http://127.0.0.1:8001/api/v1/namespaces/default/services/prometheus-dev-prometheus-prometheus:9090/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/default/services/prometheus-dev-prometheus-alertmanager:9093/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/default/services/prometheus-dev-prometheus-node-exporter:9100/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/default/services/prometheus-dev-kube-state-metrics:8080/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/default/services/prometheus-dev-grafana:80/proxy
