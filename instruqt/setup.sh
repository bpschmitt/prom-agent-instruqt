#!/bin/bash
# Wait for Instruqt bootstrap to complete
until [ -f /opt/instruqt/bootstrap/host-bootstrap-completed ]; do
    echo "Waiting for instruqt bootstrap to complete"
    sleep 1
done

# Docker install
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install git
sudo apt-get install git -y

# Start minikube
minikube start --memory 4000 --cpus 2 --force --driver=docker --kubernetes-version 1.24.10

# clone repo
mkdir -p /workdir && cd /workdir
git clone https://github.com/bpschmitt/prom-agent-instruqt
cd /workdir/prom-agent-instruqt
kubectl create ns nginx-ingress
kubectl apply -f nginx/. -n nginx-ingress
kubectl create ns cafe
kubectl apply -f nginx/cafe/. -n cafe

chmod 755 instruqt/*.sh
set-workdir /workdir/prom-agent-instruqt/instruqt

echo "alias k=kubectl" >> ~/.bashrc
echo "IC_IP=$(minikube ip)" >> ~/.bashrc
echo "IC_HTTPS_PORT=$(kubectl get svc nginx-ingress -n nginx-ingress -o=jsonpath='{.spec.ports[1].nodePort}')" >> ~/.bashrc