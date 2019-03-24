#!/bin/bash

# Configuration
source ./00-vars

gcloud container \
  clusters update "${GCLOUD_CONTAINER_CLUSTER_NAME}" \
    --update-addons KubernetesDashboard=ENABLED

gcloud config config-helper --format=json | jq -r '.credential.access_token' | pbcopy
kubectl proxy &
open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
