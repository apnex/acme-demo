#!/bin/bash
kubectl port-forward --address 0.0.0.0 deployment/frontend 3333:3000
