#!/bin/bash

kubectl exec -it -n spire $(kubectl get pods -n spire -o=jsonpath='{.items[0].metadata.name}' \
    -l app=spire-server)  /bin/sh
