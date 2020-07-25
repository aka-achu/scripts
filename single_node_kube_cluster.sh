# Updating the packages
sudo apt update

# Turning of the swap space
sudo swapoff -a

# Installing the dependencies
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Adding docker to apt package and verify the fingerprint
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Install docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Adding kubeadm to apt package
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sudo cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Updating the packages
sudo apt update

# Installing kubeadm, kubelet and kubectl
sudo apt-get install -y kubelet kubeadm kubectl 

# Changing the c-group driver
echo 'Environment=”cgroup-driver=systemd/cgroup-driver=cgroupfs”' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Starting the k8's master
echo "Enter the ip address of the master"
read master_ip
kubeadm init --apiserver-advertise-address=$master --pod-network-cidr=192.168.0.0/16

# Config kubectl to access the cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Installing a Pod network add-on
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml


# Disabling control plane isolation
kubectl taint nodes --all node-role.kubernetes.io/master-