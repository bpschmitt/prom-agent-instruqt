# prom-agent-instruqt

```
#!bin/bash

kubectl create ns newrelic
kubectl create secret generic newrelic-license-key --from-literal=license-key=$NEW_RELIC_LICENSE_KEY -n newrelic
kubectl apply -f newrelic/newrelic.yaml -n newrelic
helm repo add newrelic-prometheus https://newrelic.github.io/newrelic-prometheus-configurator
helm upgrade --install prometheus-agent newrelic-prometheus/newrelic-prometheus-agent -f prom-agent/values.yaml -n newrelic
```

# NGINX
```
kubectl create ns nginx-ingress
kubectl apply -f nginx/.
kubectl create ns cafe
kubectl apply -f nginx/cafe/.
export IC_IP=$(minikube ip)
export IC_HTTPS_PORT=443
curl --resolve cafe.example.com:$IC_HTTPS_PORT:$IC_IP https://cafe.example.com:$IC_HTTPS_PORT/coffee --insecure
curl --resolve cafe.example.com:$IC_HTTPS_PORT:$IC_IP https://cafe.example.com:$IC_HTTPS_PORT/tea --insecure
```
