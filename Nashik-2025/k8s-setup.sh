#!/bin/bash 


# Step1: ---------------------------------------------------------------------------------------------------------------------------------
Create Security Group and allow all Traffic port as of now on temprory bases. Use this Security Group while launching Maseter and Worker ec2.

#Step2: ---------------------------------------------------------------------------------------------------------------------------------
##### Launche ec2 instances
###### Use your Security Group while luanching and your keypair
# 1) ec2 master Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.medium - create key pair -network setting , security group set to allow all traffic as of now from anywhere  --> launch instace
# 2) ec2 Worker Node Configuration - instance name : Ubuntu - Ubuntu, 22.04 LTS  - t2.micro - use existing key pair for master -network setting  , use existing security group for master - instance number 2 --> launch instace


#

# Step3: ---------------------------------------------------------------------------------------------------------------------------------
##### Putty(ssh) Master and Worker ec2 and perofrm below commands on both - Login with root user #####
sudo su -

apt-get update -y
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common  -y
apt-get install docker.io -y

sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd.service
sudo systemctl status containerd.service
sudo apt-get install curl ca-certificates apt-transport-https  -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.listecho "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl
sysctl net.bridge.bridge-nf-call-iptables=1




# Step4: # On master Side ---------------------------------------------------------------------------------------------------------------------------------
sudo su -

kubeadm init --pod-network-cidr=192.168.0.0/16 >> cluster_initialized.txt
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

kubectl apply -f calico.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml



## create token to join workernode. execute below commands output on worker side. Use below output in the Workernode in Step5
kubeadm token create --print-join-command


Step5: ---------------------------------------------------------------------------------------------------------------------------------
#On Worker Side
## Execute 'kubeadm token' command output from master node and run it in Worker node. So that it will join to as a Worker node in k8s cluster
For example: ##kubeadm join 172.31.22.254:6443 --token t5wam7.35gqolngm80zf9di --discovery-token-ca-cert-hash sha256:60b88e1203525836853e98022aefe92348262bf8e63986dece6bb8270209daf4

Step6: ---------------------------------------------------------------------------------------------------------------------------------
# On Master Side, now execute below command to check cluster nodes.
kubectl get nodes
