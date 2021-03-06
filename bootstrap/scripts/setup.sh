# Update package list
apt-get update && apt-get upgrade -q -y

# Dependencies
apt-get install socat
apt-get install unzip
apt-get install systemd
curl -LC - -o /tmp/libltdl7.deb http://se.archive.ubuntu.com/ubuntu/pool/main/libt/libtool/libltdl7_2.4.6-0.1_amd64.deb
dpkg -i /tmp/libltdl7.deb

# Docker installation
echo "Add Docker repo..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -qq install -y docker-ce=18.03.1~ce-0~ubuntu

# Install kubectl
curl -LC - -o /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
chmod +x /tmp/kubectl
mv /tmp/kubectl /usr/local/bin/kubectl

# Minikube installation
curl -LC - -o /tmp/minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64
chmod +x /tmp/minikube
mv /tmp/minikube /usr/local/bin/minikube

# Install Helm
curl -LC - -o /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar -zxvf /tmp/helm.tar.gz -C /tmp
mv /tmp/linux-amd64/helm /usr/local/bin/helm

# Install pachctl
curl -LC - -o /tmp/pachctl.deb https://github.com/pachyderm/pachyderm/releases/download/v1.8.2/pachctl_1.8.2_amd64.deb
dpkg -i /tmp/pachctl.deb

rm -rf ~/.minikube && rm -rf ~/.kube
rm -rf .minikube && rm -rf .kube

# Start minikube
minikube start --vm-driver=none --memory 4096 --cpus 4

# Start Helm client and daemon
helm init

# Set permissions fro user 'vagrant'
chown -R vagrant:vagrant ~/.minikube/ && chown -R vagrant:vagrant ~/.kube/