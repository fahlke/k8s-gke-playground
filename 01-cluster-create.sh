#!/bin/bash

# Configuration
source ./00-vars

gcloud container \
  clusters create "${GCLOUD_CONTAINER_CLUSTER_NAME}" \
    --zone "${GCLOUD_COMPUTE_ZONE}" \
    --enable-ip-alias \
    --enable-autorepair \
    --enable-autoscaling \
    --enable-autoupgrade \
    --preemptible \
    --no-enable-basic-auth \
    --no-issue-client-certificate \
    --no-enable-legacy-authorization \
    --maintenance-window "${GCLOUD_CONTAINER_CLUSTER_MAINTENANCE_UTC}" \
    --metadata "${GCLOUD_CONTAINER_CLUSTER_METADATA}" \
    --create-subnetwork "${GCLOUD_CONTAINER_CLUSTER_SUBNETWORK}" \
    --image-type "${GCLOUD_CONTAINER_CLUSTER_IMAGE_TYPE}" \
    --machine-type "${GCLOUD_COMPUTE_MACHINE_TYPE}" \
    --num-nodes "${GCLOUD_CONTAINER_CLUSTER_NUM_NODES_PER_ZONE}" \
    --min-nodes="${GCLOUD_CONTAINER_CLUSTER_AUTOSCALE_MIN_NODES}" \
    --max-nodes="${GCLOUD_CONTAINER_CLUSTER_AUTOSCALE_MAX_NODES}" \
    --cluster-version "${GCLOUD_CONTAINER_CLUSTER_MASTER_VERSION}" \
    --node-version "${GCLOUD_CONTAINER_CLUSTER_NODE_VERSION}" \
    --node-labels "${GCLOUD_CONTAINER_CLUSTER_NODE_LABELS}" \
    --addons "${GCLOUD_CONTAINER_CLUSTER_ADDONS}"

gcloud compute \
  config-ssh \
    --ssh-key-file $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa

open https://console.cloud.google.com/kubernetes/list?project=${GCLOUD_PROJECT_ID}
