#!/bin/bash
echo 'executing "3_minikube.sh"'
# this will install minikube Kubernetes and Helm

sudo swapoff -a

echo 'Installing Kubernetes'

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-`lsb_release -cs` main" >/etc/apt/sources.list.d/kubernetes.list
apt-get update -y -qq
apt-get install -y kubectl kubeadm kubelet

sudo curl -s -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo chmod +x minikube && sudo mv minikube /usr/local/bin/

#https://github.com/kubernetes/minikube
echo 'Setting Developer Mode'
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=/home/ubuntu
export CHANGE_MINIKUBE_NONE_USER=true
export KUBECONFIG=/home/ubuntu/.kube/config

#we want things things to stick each time we login or start the machine
echo "export MINIKUBE_WANTUPDATENOTIFICATION=false" >> /home/ubuntu/.bash_profile
echo "export MINIKUBE_WANTREPORTERRORPROMPT=false" >> /home/ubuntu/.bash_profile
echo "export MINIKUBE_HOME=/home/ubuntu" >> /home/ubuntu/.bash_profile
echo "export CHANGE_MINIKUBE_NONE_USER=true" >> /home/ubuntu/.bash_profile
echo "export KUBECONFIG=/home/ubuntu/.kube/config" >> /home/ubuntu/.bash_profile
echo "sudo swapoff -a" >> /home/ubuntu/.bash_profile
echo "source <(kubectl completion bash)" >> /home/ubuntu/.bash_profile
echo "sudo chown -R ubuntu /home/ubuntu/.kube" >> /home/ubuntu/.bash_profile
echo "sudo chgrp -R ubuntu /home/ubuntu/.kube" >> /home/ubuntu/.bash_profile

#sudo cp /root/.minikube $HOME/.minikube
echo "sudo chown -R ubuntu /home/ubuntu/.minikube" >> /home/ubuntu/.bash_profile
echo "sudo chgrp -R ubuntu /home/ubuntu/.minikube" >> /home/ubuntu/.bash_profile

mkdir /home/ubuntu/.kube || true
touch /home/ubuntu/.kube/config

echo 'Starting minikube local cluster'

minikube start --memory 4096 --cpus=2 --vm-driver=none

#sudo cp /root/.kube $HOME/.kube
sudo chown -R ubuntu /home/ubuntu/.kube
sudo chgrp -R ubuntu /home/ubuntu/.kube

#sudo cp /root/.minikube $HOME/.minikube
sudo chown -R ubuntu /home/ubuntu/.minikube
sudo chgrp -R ubuntu /home/ubuntu/.minikube

echo 'Getting Helm'
curl -s https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
# changed on 21-05-2019: helm version 2.14 doesn't work, getting an older version
./get_helm.sh --version v2.13.1

