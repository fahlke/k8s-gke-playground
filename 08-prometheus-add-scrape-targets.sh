#!/bin/bash

# add elasticsearch_exporter to main prometheus
# http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/elasticsearch-exporter-efk:http/proxy/metrics
tee /tmp/es-exporter-servicemonitor.yaml >/dev/null <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: prometheus-operator-elasticsearch-exporter
    release: prometheus
  name: prometheus-oper-elasticsearch-exporter
  namespace: monitoring
spec:
  endpoints:
  - path: /metrics
    port: http
  namespaceSelector:
    matchNames:
    - monitoring
  selector:
    matchLabels:
      app: elasticsearch-exporter
      release: efk
EOF
kubectl apply -f /tmp/es-exporter-servicemonitor.yaml


# open http://127.0.0.1:8001/api/v1/namespaces/monitoring/services/elasticsearch-exporter-efk:http/proxy/metrics