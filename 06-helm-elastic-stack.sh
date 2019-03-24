#!/bin/bash

# https://github.com/helm/charts/tree/master/stable/elastic-stack

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
    ELASTICSEARCH_URL: 'http://elastic-stack-dev-elasticsearch-client.monitoring.svc.cluster.local:9200'

logstash:
  enabled: false

elasticsearch-exporter:
  enabled: true
EOF

helm install \
  --name elastic-stack-dev \
  --values /tmp/values.yaml \
  --namespace monitoring \
  stable/elastic-stack

rm -f /tmp/values.yaml

# open http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/elastic-stack-dev-elasticsearch-client:http/proxy/
# open http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/elastic-stack-dev-kibana:443/proxy/

# POD_NAME=$(kubectl get pods --namespace default -l "app=elastic-stack,release=elastic-stack-dev" -o jsonpath="{.items[0].metadata.name}")
# echo "Visit http://127.0.0.1:5601 to use Kibana"
# kubectl port-forward --namespace default $POD_NAME 5601:5601

# helm upgrade \
#   elastic-stack-dev \
#   --values /tmp/values.yaml \
#   --namespace monitoring \
#   stable/elastic-stack
