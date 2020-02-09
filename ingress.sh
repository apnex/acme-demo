#!/bin/bash

# find local-host nodeport ingress
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export NODE_ADDRESS=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

printf "%s\n" "## Ingress ##"
printf "%s\n" "${NODE_ADDRESS}:${INGRESS_PORT}"
printf "%s\n" "${NODE_ADDRESS}:${SECURE_INGRESS_PORT}"

# find load-balancer pod id
MYINGRESS=$(kubectl get services --namespace istio-system -o json | jq -r '.items[] | select(.metadata.name | contains("ingress")).status.loadBalancer.ingress[0].hostname')
printf "%s\n" "## Ingress ##"
printf "%s\n" "${MYINGRESS}"
