#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

kubectl create namespace monitoring

helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack

kubectl get deployments -n monitoring -w