#!/bin/bash
source ./demo-magic.sh
clear

# login to cluster
./cluster.switch.sh "dc-cluster-west"
pe "./cluster.login.sh $(cat ./cluster.name)"

# check nodes
pe "kubectl get nodes"
