#!/bin/bash

# Configuration
source ./00-vars

gcloud container \
  clusters delete "${GCLOUD_CONTAINER_CLUSTER_NAME}" \
    --zone "${GCLOUD_COMPUTE_ZONE}" \
    --quiet

gcloud compute \
  config-ssh \
    --ssh-key-file $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa \
    --remove
