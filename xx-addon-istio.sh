#!/bin/bash

# Configuration
source ./00-vars

# https://cloud.google.com/istio/docs/istio-on-gke/installing
gcloud beta container \
  clusters update "${GCLOUD_CONTAINER_CLUSTER_NAME}" \
    --update-addons Istio=ENABLED \
    --istio-config auth=MTLS_STRICT

kubectl get service -n istio-system -w
