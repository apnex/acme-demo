#!/bin/bash

# find load-balancer pod id
MYLOAD=$(kubectl get pods -o json | jq -r '.items[] | .metadata | select(.name | contains("load")).name')
printf "%s\n" "## Load Generator ##"
printf "%s\n" "${MYLOAD}"

# create port-forward for load-generator
kubectl port-forward "${MYLOAD}" 8089:8089

