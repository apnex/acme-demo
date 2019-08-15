#!/bin/bash

# find load-balancer pod id
MYINGRESS=$(kubectl get services --namespace istio-system -o json | jq -r '.items[] | select(.metadata.name | contains("ingress")).status.loadBalancer.ingress[0].hostname')
printf "%s\n" "## Ingress ##"
printf "%s\n" "${MYINGRESS}"
