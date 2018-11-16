# Update package list
sudo apt-get update && sudo apt-get upgrade -q -y

# Dependencies
sudo apt-get install socat
sudo apt-get install unzip
sudo apt-get install systemd
curl -LC - -o /tmp/libltdl7.deb http://se.archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libltdl7_2.4.6-0.1_amd64.deb
sudo dpkg -i /tmp/libltdl7.deb

# Docker installation
echo "Add Docker repo..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get -qq install -y docker-ce=18.03.1~ce-0~ubuntu

# Install kubectl
curl -LC - -o /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
sudo chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin/kubectl

# Minikube installation
curl -LC - -o /tmp/minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64
chmod +x /tmp/minikube
sudo mv /tmp/minikube /usr/local/bin/minikube

# Install Helm
curl -LC - -o /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -zxvf /tmp/helm.tar.gz -C /tmp
sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm

# Install pachctl
curl -LC - -o /tmp/pachctl.deb https://github.com/pachyderm/pachyderm/releases/download/v1.7.10/pachctl_1.7.10_amd64.deb
sudo dpkg -i /tmp/pachctl.deb

sudo rm -rf ~/.minikube && sudo rm -rf ~/.kube
sudo rm -rf .minikube && sudo rm -rf .kube

# Start minikube
sudo minikube start --vm-driver=none --memory 8192 --cpus 4

# Start Helm client and daemon
sudo helm init