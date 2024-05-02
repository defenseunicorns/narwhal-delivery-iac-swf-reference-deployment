#!/bin/bash

COREFILE="$(kubectl get cm -n kube-system coredns -o=jsonpath='{.data.Corefile}')"

echo -e "$COREFILE"

echo -e "####################"

COREFILE_EDIT="$(echo -e "$COREFILE" | sed '$d')"

COREFILE_EDIT="${COREFILE_EDIT%%rewrite*}"

newline() {
  COREFILE_EDIT+=$'\n'
}

TENANT_MATCH='(^\w*\.uds\.dev)'

ADMIN_MATCH='(.*admin\.uds\.dev)'

TENANT_GATEWAY_HOSTNAME="$(kubectl get svc -n istio-tenant-gateway tenant-ingressgateway -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

ADMIN_GATEWAY_HOSTNAME="$(kubectl get svc -n istio-admin-gateway admin-ingressgateway -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

REWRITE_START="    rewrite stop {"

REWRITE_END="    }"

newline

COREFILE_EDIT+="$REWRITE_START"

newline

COREFILE_EDIT+="        name regex $TENANT_MATCH $TENANT_GATEWAY_HOSTNAME answer auto"

newline

COREFILE_EDIT+="$REWRITE_END"

newline

COREFILE_EDIT+="$REWRITE_START"

newline

COREFILE_EDIT+="        name regex $ADMIN_MATCH $ADMIN_GATEWAY_HOSTNAME answer auto"

newline

COREFILE_EDIT+="$REWRITE_END"

newline

COREFILE_EDIT+="}"

echo -e "$COREFILE_EDIT"

echo "############"

PATCH="data:
  Corefile: |
$(while IFS= read -r line; do printf '%4s%s\n' '' "$line"; done <<< "$COREFILE_EDIT")"

kubectl patch cm -n kube-system coredns --patch-file <(echo -e "$PATCH")

kubectl rollout restart -n kube-system deployment/coredns
