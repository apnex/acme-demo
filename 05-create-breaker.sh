#!/bin/bash
source ./demo-magic.sh
clear

# create breaker
pe "kubectl apply -f acme-fitness/istio-manifests/circuitbreaker/circuitbreaker.yaml"
