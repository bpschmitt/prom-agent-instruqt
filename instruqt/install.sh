#!/bin/bash

printf 'Enter your New Relic Account ID: '
read -r value

export NEW_RELIC_ACCOUNT_ID=$value

printf 'Enter your New Relic License Key: '
read -r value

export NEW_RELIC_LICENSE_KEY=$value

printf 'Enter your New Relic User API Key: '
read -r value

export NEW_RELIC_USER_KEY=$value

echo ""
echo "Environment variables have been set! Let's roll..."
echo ""
echo "--------------------------------------------------"
echo ""
echo "Installing New Relic components into your cluster..."
echo ""


## Install the base New Relic components (Infra, K8s events, Logging)
kubectl create ns newrelic
kubectl create secret generic newrelic-license-key --from-literal=license-key=$NEW_RELIC_LICENSE_KEY -n newrelic
function ver { printf "%03d%03d" $(echo "$1" | tr '.' ' '); } && \
K8S_VERSION=$(kubectl version --short 2>&1 | grep 'Server Version' | awk -F' v' '{ print $2; }' | awk -F. '{ print $1"."$2; }') && \
if [[ $(ver $K8S_VERSION) -lt $(ver "1.25") ]]; then KSM_IMAGE_VERSION="v2.6.0"; else KSM_IMAGE_VERSION="v2.7.0"; fi && \
helm repo add newrelic https://helm-charts.newrelic.com && helm repo update && \
helm upgrade --install newrelic-bundle newrelic/nri-bundle \
 --set global.customSecretName=newrelic-license-key \
 --set global.customSecretLicenseKey=license-key \
 --set global.cluster=instruqt-cluster \
 --namespace=newrelic \
 --set newrelic-infrastructure.privileged=true \
 --set global.lowDataMode=true \
 --set kube-state-metrics.image.tag=${KSM_IMAGE_VERSION} \
 --set kube-state-metrics.enabled=true \
 --set kubeEvents.enabled=true \
 --set logging.enabled=true \
 --set newrelic-logging.lowDataMode=true 

echo ""
echo "--------------------------------------------------"
echo ""

## Install the Prometheus Agent using Helm
helm repo add newrelic-prometheus https://newrelic.github.io/newrelic-prometheus-configurator && helm repo update
helm upgrade --install prometheus-agent newrelic-prometheus/newrelic-prometheus-agent -f ../prom-agent/values-simple.yaml -n newrelic

echo ""
echo "--------------------------------------------------"
echo ""

## Deploy the lab dashboard
cat dashboard.txt | sed 's/REPLACE_ACCOUNT_ID/'$NEW_RELIC_ACCOUNT_ID'/g' | curl -H 'Content-Type: application/json' -H "API-Key: $NEW_RELIC_USER_KEY" -d @- https://api.newrelic.com/graphql > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Error creating dashboard!"
else
    echo "Lab dashboard installed successfully!"
fi

echo ""