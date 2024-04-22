#!/usr/bin/env bash

PKGS=$(kubectl get pkg -A | awk '{print $1 "," $2}' | tail -n +2)

for PKG in $PKGS; do
  NAMESPACE=$(echo $PKG | cut -d ',' -f 1)
  NAME=$(echo $PKG | cut -d ',' -f 2)
  kubectl patch pkg $NAME -n $NAMESPACE --subresource=status --type=json -p='[{"op": "remove", "path": "/status"}]'
  sleep 2s
  # wait for status.phase to be Ready
  kubectl wait --for=jsonpath='{.status.phase}'=Ready pkg/$NAME -n $NAMESPACE --timeout=60s
done
