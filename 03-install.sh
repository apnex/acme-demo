#!/bin/bash
source ./demo-magic.sh
clear

# tag for istio
pe "kubectl label namespace default istio-injection=enabled --overwrite=true"

# Validate the 'default' namespace has been labelled correctly
pe "kubectl get namespace -L istio-injection"

# create an ingress gateway
pe "kubectl apply -f acme-fitness/istio-manifests/gateway.yaml"

# create secrets
pe "kubectl apply -f acme-fitness/kubernetes-manifests/secrets.yaml"

# deploy acme fitness
pe "kubectl apply -f acme-fitness/kubernetes-manifests/acme_fitness.yaml"

# create load-generator
pe "kubectl apply -f acme-fitness/traffic-generator/loadgen.yaml"

# watch pods for acme installation
pe "watch -n 5 kubectl get pods"
