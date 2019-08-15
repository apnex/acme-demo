#!/bin/bash

# tag for istio
kubectl label namespace default istio-injection=disable --overwrite=true

# create an ingress gateway
kubectl delete -f acme-fitness/istio-manifests/gateway.yaml

# create secrets
kubectl delete -f acme-fitness/kubernetes-manifests/secrets.yaml

# deploy acme fitness
kubectl delete -f acme-fitness/kubernetes-manifests/acme_fitness.yaml

# create load-generator
kubectl delete -f acme-fitness/traffic-generator/loadgen.yaml
