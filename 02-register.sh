#!/bin/bash
source ./demo-magic.sh
clear

# make yaml file
./yaml.build.sh "$(cat ./cluster.name)" 1&>/dev/null

# tag for istio
pe "kubectl apply -f nsx-sm_$(cat ./cluster.name).yaml"

# watch pods for registration
pe "watch -n 5 kubectl get pods --all-namespaces"
