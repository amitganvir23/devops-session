#!/bin/bash 

## On Worker and Master Node

## Master Node Configuration - instance name : Ubuntu - ubuntu20.04  - t2.medium - create key pair -network setting , security group set to allow all traffic as of now from anywhere  --> launch instace
## Worker Node Configuration - instance name : Ubuntu - ubuntu20.04  - t2.micro - use existing key pair for master -network setting  , use existing security group for master - instance number 2 --> launch instace


sudo apt update

sudo apt install apt-transport-https ca-certificates curl software-properties-common  -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
wget -q -O - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo deb http://apt.kubernetes.io/ kubernetes-xenial main | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubelet=1.21.1-00 kubeadm=1.21.1-00 kubectl=1.21.1-00 -y
sudo apt-mark hold kubelet kubeadm kubectl
sysctl net.bridge.bridge-nf-call-iptables=1

#on master
#kubeadm init --pod-network-cidr=10.244.0.0/16 >> cluster_initialized.txt
kubeadm init --pod-network-cidr=192.168.0.0/16 >> cluster_initialized.txt
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
systemctl restart kubelet.service
kubeadm token create --print-join-command
## Execute output of 'kubeadm token' on Worker node
