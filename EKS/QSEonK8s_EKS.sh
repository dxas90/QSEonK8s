#!/bin/bash

echo 'Getting Helm'
curl -s https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
# changed on 21-05-2019: helm version 2.14 doesn't work, getting an older version
./get_helm.sh --version v2.13.1

# https://docs.aws.amazon.com/eks/latest/userguide/helm.html
alias aws_tiller='tiller -listen=localhost:44134 -storage=secret -logtostderr &'

export TILLER_NAMESPACE=tiller
export HELM_HOST=:44134

kubectl create namespace tiller

aws_tiller

#Initialize Helm Tiller pod, upgrade and update the repos
helm init --wait --upgrade --client-only
helm repo update

helm repo add qlik-stable https://qlik.bintray.com/stable

# EFS storage
helm install --name efs-provisioner stable/efs-provisioner -f $PWD/efs.yaml

#Install MongoDB
helm install -n mongo stable/mongodb -f $PWD/mongo.yaml

# install the initial settings
helm install -n qlikinit qlik-stable/qliksense-init --version 1.1.0

# install qlik sense enterprise on kubernetes
helm install -n qlik qlik-stable/qliksense -f $PWD/qliksense.yaml --version 1.2.46
