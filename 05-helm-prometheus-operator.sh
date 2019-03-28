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

cat >/tmp/values.yaml <<EOF
nameOverride: "system-monitoring"
fullNameOverride: ""

prometheus:
  enabled: true
  prometheusSpec:
    retention: 14d
    externalUrl: "prometheus.system.dev.ext.fahlke.dev"
    serviceMonitorNamespaceSelector: {"system-monitoring", "service-monitoring", "logging"}
  ingress:
    enabled: true
    hosts:
    - prometheus.system.dev.ext.fahlke.dev
  service:
    type: NodePort
    nodePort: 30990

alertmanager:
  enabled: true
  alertmanagerSpec:
    retention: 72h
    externalUrl: "alertmanager.system.dev.ext.fahlke.dev"
  ingress:
    enabled: true
    hosts:
    - alertmanager.system.dev.ext.fahlke.dev
  service:
    type: NodePort
    nodePort: 30993

grafana:
  enabled: true
  adminPassword: "CHANGEME"
  ingress:
    enabled: true
    hosts:
    - grafana.system.dev.ext.fahlke.dev

coreDns:
  enabled: false

kubeDns:
  enabled: true

# defaults: https://github.com/helm/charts/blob/master/stable/prometheus-operator/values.yaml
EOF

helm install \
  --name system-monitoring \
  --values /tmp/values.yaml \
  --namespace system-monitoring \
  stable/prometheus-operator

# https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/exposing-prometheus-and-alertmanager.md
# kubectl proxy &

# open http://127.0.0.1:8001/api/v1/namespaces/system-monitoring/services/prometheus-operated:9090/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/system-monitoring/services/alertmanager-operated:9093/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/system-monitoring/services/prometheus-prometheus-node-exporter:9100/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/system-monitoring/services/prometheus-kube-state-metrics:8080/proxy

# default password for grafana: kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# open http://127.0.0.1:8001/api/v1/namespaces/system-monitoring/services/prometheus-grafana:80/proxy
