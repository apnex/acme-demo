#!/bin/bash
source ./demo-magic.sh
clear

# Remove Tag for istio
pe "kubectl label namespace default istio-injection=disabled --overwrite=true"

# Validate the 'default' namespace has been labelled correctly
pe "kubectl get namespace -L istio-injection"

# create an ingress gateway
pe "kubectl delete -f acme-fitness/istio-manifests/gateway.yaml"

# create secrets
pe "kubectl delete -f acme-fitness/kubernetes-manifests/secrets.yaml"

# deploy acme fitness
pe "kubectl delete -f acme-fitness/kubernetes-manifests/acme_fitness.yaml"

# create load-generator
pe "kubectl delete -f acme-fitness/traffic-generator/loadgen.yaml"

# watch pods for acme installation
pe "watch -n 5 kubectl get pods"
