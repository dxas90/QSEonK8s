#!/bin/bash

echo 'Updating Ubuntu'
sudo apt-get -qq -y update

echo 'Installing git nfs-kernel-server'
sudo apt-get install -qq git nfs-kernel-server

#NFS
sudo mkdir -p /export/k8s
sudo mkdir -p /export/src
sudo chown nobody:nogroup /export/k8s
sudo bash -c 'cat << EOF >>/etc/exports
/export/k8s   *(rw,sync,no_subtree_check,no_root_squash)
/export/src  *(rw,sync,no_subtree_check,no_root_squash)
/export       *(rw,fsid=0,no_subtree_check,sync)
EOF'

sudo service nfs-kernel-server restart

echo 'Installing socat'
sudo apt-get -q install socat -y

#install microk8s and alias kubectl
sudo snap install microk8s --classic
sudo snap alias microk8s.kubectl kubectl

export KUBECONFIG=/snap/microk8s/current/configs/kubelet.config

echo "export KUBECONFIG=/snap/microk8s/current/configs/kubelet.config" >> $HOME/.bashrc
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

echo 'Getting Helm'
curl -s https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
# changed on 21-05-2019: helm version 2.14 doesn't work, getting an older version
./get_helm.sh --version v2.13.1

#Initialize Helm Tiller pod, upgrade and update the repos
helm init
helm init --wait --upgrade
helm repo update

#Install storageClass on NFS provider
helm install -n nfs stable/nfs-client-provisioner -f $PWD/files/storageClass.yaml

#Create Persistent Volume Claims
kubectl apply -f $PWD/files/pvc.yaml

# install keycloak
helm repo add codecentric https://codecentric.github.io/helm-charts
helm install --name keycloak codecentric/keycloak

#Install MongoDB
helm install -n mongo stable/mongodb -f $PWD/files/mongo.yaml

#Install qliksense from stable repo
helm repo add qlik-stable https://qlik.bintray.com/stable
helm repo add qlik-edge https://qlik.bintray.com/edge

# install the initial settings
helm install -n qlikinit qlik-stable/qliksense-init

# install qlik sense enterprise on kubernetes
helm install -n qlik qlik-stable/qliksense -f $PWD/files/qliksense.yaml
