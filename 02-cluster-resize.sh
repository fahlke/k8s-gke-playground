#!/bin/bash

# Configuration
source ./00-vars

if [[ -z $1 ]]; then
  echo "Usage: 04-cluster-resize.sh <num target nodes>"
  exit
fi

GCLOUD_CONTAINER_CLUSTER_NUM_NODES_RESIZE_TARGET=$1

gcloud container \
  clusters resize "${GCLOUD_CONTAINER_CLUSTER_NAME}" \
    --zone "${GCLOUD_COMPUTE_ZONE}" \
    --size "${GCLOUD_CONTAINER_CLUSTER_NUM_NODES_RESIZE_TARGET}" \
    --quiet

gcloud compute \
  config-ssh \
    --ssh-key-file $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa
