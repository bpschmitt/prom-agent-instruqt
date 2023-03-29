#!/bin/bash

helm uninstall newrelic-bundle -n newrelic
helm uninstall prometheus-agent -n newrelic
kubectl delete ns newrelic
