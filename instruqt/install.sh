#!/bin/bash

printf 'Enter your New Relic Account ID: '
read -r value

export NEW_RELIC_ACCOUNT_ID=$value

printf 'Enter your New Relic License Key: '
read value

export NEW_RELIC_LICENSE_KEY=$value

printf 'Enter your New Relic User API Key: '
read value

export NEW_RELIC_USER_KEY=$value

echo "Environment variables have been set!"

kubectl create ns newrelic
kubectl create secret generic newrelic-license-key --from-literal=license-key=$NEW_RELIC_LICENSE_KEY -n newrelic
mkdir ../newrelic
curl -s -X POST https://k8s-config-generator.service.newrelic.com/generate -H 'Content-Type: application/json' -d '{"global.cluster":"instruqt-cluster","global.namespace":"newrelic","newrelic-infrastructure.privileged":"true","kube-state-metrics.image.tag":"v2.6.0","kube-state-metrics.enabled":"true","kubeEvents.enabled":"true","logging.enabled":"true","global.licenseKey":"'${NEW_RELIC_LICENSE_KEY}'"}' > ../newrelic/newrelic.yaml

kubectl apply -f ../newrelic/newrelic.yaml -n newrelic
helm repo add newrelic-prometheus https://newrelic.github.io/newrelic-prometheus-configurator
helm upgrade --install prometheus-agent newrelic-prometheus/newrelic-prometheus-agent -f ../prom-agent/values.yaml -n newrelic
cat dashboard.txt | sed 's/REPLACE_ACCOUNT_ID/'$NEW_RELIC_ACCOUNT_ID'/g' | curl -H 'Content-Type: application/json' -H "API-Key: $NEW_RELIC_USER_KEY" -d @- https://api.newrelic.com/graphql