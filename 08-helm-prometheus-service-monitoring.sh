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
nameOverride: "service-monitoring"
fullNameOverride: ""

prometheusOperator:
  enabled: false

defaultRules:
  create: false

prometheus:
  enabled: true
  prometheusSpec:
    retention: 14d
    externalUrl: "prometheus.services.dev.ext.fahlke.dev"
    serviceMonitorNamespaceSelector: {"service-monitoring", "project-1", "project-2"}
  ingress:
    enabled: true
    hosts:
    - prometheus.services.dev.ext.fahlke.dev
  service:
    type: NodePort
    nodePort: 31990

alertmanager:
  enabled: true
  alertmanagerSpec:
    retention: 72h
    externalUrl: "alertmanager.services.dev.ext.fahlke.dev"
  ingress:
    enabled: true
    hosts:
    - alertmanager.services.dev.ext.fahlke.dev
  service:
    type: NodePort
    nodePort: 31993

grafana:
  enabled: true
  adminPassword: "CHANGEME"
  defaultDashboardsEnabled: false
  ingress:
    enabled: true
    hosts:
    - grafana.services.dev.ext.fahlke.dev

kubeApiServer:
  enabled: false

kubelet:
  enabled: false

kubeControllerManager:
  enabled: false

coreDns:
  enabled: false

kubeDns:
  enabled: false

kubeEtcd:
  enabled: false

kubeScheduler:
  enabled: false

kubeStateMetrics:
  enabled: false

nodeExporter:
  enabled: false

# defaults: https://github.com/helm/charts/blob/master/stable/prometheus-operator/values.yaml
EOF

helm install \
  --name service-monitoring \
  --values /tmp/values.yaml \
  --namespace service-monitoring \
  stable/prometheus-operator

# https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/exposing-prometheus-and-alertmanager.md
# kubectl proxy &

# open http://127.0.0.1:8001/api/v1/namespaces/service-monitoring/services/prometheus-operated:9090/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/service-monitoring/services/alertmanager-operated:9093/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/service-monitoring/services/prometheus-prometheus-node-exporter:9100/proxy
# open http://127.0.0.1:8001/api/v1/namespaces/service-monitoring/services/prometheus-kube-state-metrics:8080/proxy

# default password for grafana: kubectl get secret --namespace service-monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# open http://127.0.0.1:8001/api/v1/namespaces/service-monitoring/services/prometheus-grafana:80/proxy
