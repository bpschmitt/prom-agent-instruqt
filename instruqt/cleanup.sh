#!/bin/bash

helm uninstall prometheus-agent -n newrelic
kubectl delete -f ../newrelic/newrelic.yaml -n newrelic && kubectl delete ns newrelic
