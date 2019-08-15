#!/bin/bash

# tag for istio
kubectl label namespace default istio-injection=enabled --overwrite=true

# Validate the 'default' namespace has been labelled correctly
#kubectl  get namespace -L istio-injection

# create an ingress gateway
kubectl apply -f istio-manifests/gateway.yaml

# create secrets
kubectl apply -f kubernetes-manifests/secrets.yaml

# deploy acme fitness
kubectl apply -f kubernetes-manifests/acme_fitness.yaml

# create load-generator
kubectl apply -f traffic-generator/loadgen.yaml
