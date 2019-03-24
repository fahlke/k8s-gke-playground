#!/bin/bash

# Configuration
source ./00-vars

# enable Kubernetes Engine first
# https://console.cloud.google.com/apis/library/container.googleapis.com?q=kubernetes%20engine

if [[ -z $(gcloud auth list --filter=status:ACTIVE --format="value(account)") ]]
then
  gcloud config \
    set account "${GCLOUD_COMPUTE_ACCOUNT}"

  gcloud auth \
    login
fi

if [[ ! -f $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa ]]
then
  ssh-keygen \
    -t rsa \
    -b 2048 \
    -C "${GCLOUD_COMPUTE_ACCOUNT}" \
    -f $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa
fi

if [[ -f $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa ]]
then
  ssh-add $HOME/.ssh/${GCLOUD_PROJECT_ID}-${GCLOUD_CONTAINER_CLUSTER_NAME}.id_rsa
fi

gcloud config \
  set project "${GCLOUD_PROJECT_ID}"

gcloud config \
  set compute/region "${GCLOUD_COMPUTE_REGION}"

gcloud config \
  set compute/zone "${GCLOUD_COMPUTE_ZONE}"

gcloud config \
  set container/new_scopes_behavior true

gcloud components \
  update \
    --quiet

gcloud projects \
  create "${GCLOUD_PROJECT_ID}"

open "https://console.cloud.google.com/apis/api/container.googleapis.com/overview?project=${GCLOUD_PROJECT_ID}"
