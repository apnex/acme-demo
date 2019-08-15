#!/bin/bash

# Organisation Name
CSP_ORGANIZATION_NAME="$(cat ./cluster.env)"

# Long Organisation Name
CSP_ORGANIZATION_ID="$(cat ./cluster.org)"
CSP_REFRESH_TOKEN="$(cat ./cluster.token)"

# Cluster Name
VKE_CLUSTER_NAME=${1}

vke account login --organization ${CSP_ORGANIZATION_ID} --refresh-token ${CSP_REFRESH_TOKEN}
vke cluster auth setup --folder SharedFolder --project SharedProject ${VKE_CLUSTER_NAME}
