#!/bin/bash

IRISPOD=$(kubectl get pods -o=custom-columns='DATA:metadata.name' | grep iris-deployment)

printf "\n$IRISPOD\n"

kubectl exec -it $IRISPOD -- iris session iris <<EOF
Do \$System.CPU.Dump()
Halt
EOF

