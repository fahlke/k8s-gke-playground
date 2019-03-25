#!/bin/bash

# https://github.com/helm/charts/tree/master/stable/elastic-stack
# https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/fluentd-elasticsearch/kibana-deployment.yaml#L35

if [[ -z "$1" ]]; then
  echo "Usage: 06-helm-elastic-stack.sh <firstname.lastname>"
  exit
fi

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CERT_DIR="${BASEDIR}/build/certificates"
USER_CERT_DIR="${BASEDIR}/build/certificates/users"

USER_NAME="$1"
USER_CONFIG="${USER_CERT_DIR}/${USER_NAME}.rc"

source ${USER_CONFIG}

tee /tmp/values.yaml >/dev/null <<EOF
elasticsearch:
  enabled: true

kibana:
  enabled: true
  env:
    ELASTICSEARCH_URL: 'http://efk-elasticsearch-client.monitoring.svc.cluster.local:9200'

logstash:
  enabled: false

elasticsearch-exporter:
  enabled: true
EOF

helm install \
  --name efk \
  --values /tmp/values.yaml \
  --namespace monitoring \
  stable/elastic-stack

rm -f /tmp/values.yaml

# kubectl proxy &
# curl http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/efk-elasticsearch-client:http/proxy/

# POD_NAME=$(kubectl get pods --namespace monitoring -l "app=kibana,release=efk" -o jsonpath="{.items[0].metadata.name}")
# kubectl port-forward --namespace monitoring $POD_NAME 5601:5601
# open http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/efk-kibana:443/proxy/
