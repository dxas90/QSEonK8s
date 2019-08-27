#!/bin/bash

echo 'Updating Ubuntu'
sudo apt-get -qq -y update

sudo apt-get -q install socat -y

#install microk8s and alias kubectl
sudo snap install microk8s --classic
sudo snap alias microk8s.kubectl kubectl
sudo snap alias microk8s.helm helm

sudo microk8s.enable dns storage helm

export KUBECONFIG=/snap/microk8s/current/configs/kubelet.config

echo "export KUBECONFIG=/snap/microk8s/current/configs/kubelet.config" >> $HOME/.bashrc
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

kubectl create namespace tiller
kubectl create namespace qlik

#Initialize Helm Tiller pod, upgrade and update the repos
helm init
helm init --wait --upgrade
helm repo update
sleep 10s

#Install MongoDB
helm install --namespace qlik -n mongo stable/mongodb -f $PWD/files/mongo.yaml

#Install qliksense from stable repo
helm repo add qlik-stable https://qlik.bintray.com/stable
helm repo add qlik-edge https://qlik.bintray.com/edge

# install the initial settings
helm install --namespace qlik -n qlikinit qlik-stable/qliksense-init

# install qlik sense enterprise on kubernetes
helm install --namespace qlik -n qlik qlik-stable/qliksense -f $PWD/files/qliksense.yaml
