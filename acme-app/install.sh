#!/bin/bash

# create secrets
kubectl apply -f secrets.yaml

printf "Component [secrets] deployed, sleeping...\n"
sleep 5

# deploy acme-fitness
kubectl apply -f ./
