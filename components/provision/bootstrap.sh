#!/bin/bash
# @file bootstrap.sh
# @brief Bootstrap script to provision the Vagrantbox and to install into non-virtual Ubuntu systems.
# @description
#   This script is used to provision the Vagrantbox and to install into non-virtual Ubuntu systems.
#   It installs
#   - some basic packages and tools
#   - Docker, minikube and helm
#   - Ansible

# shellcheck disable=SC1091

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


echo "[INFO] ========================================================"
echo "User     = $USER"
echo "Hostname = $HOSTNAME"
echo "Home dir = $HOME"
hostnamectl
echo "[INFO] ========================================================"


echo "[INFO] Install packages and tools"

sudo apt-get update
sudo apt-get install -y apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  auditd \
  git \
  tilix \
  tmux \
  vim \
  ncdu \
  neofetch \
  htop \
  jq
sudo snap install --classic code


echo "[INFO] Install Docker"

sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi

if id "vagrant" &>/dev/null; then
  sudo usermod -aG docker vagrant
fi
sudo usermod -aG docker "$USER"
newgrp docker

echo "[INFO] Test docker"
docker run --rm hello-world:latest


echo "[INFO] Install minikube"
readonly MINIKUBE_VERSION="latest"
curl -fsSL -o /tmp/minikube-linux-amd64 https://storage.googleapis.com/minikube/releases/$MINIKUBE_VERSION/minikube-linux-amd64
sudo install /tmp/minikube-linux-amd64 /usr/local/bin/minikube
rm /tmp/minikube-linux-amd64


echo "[INFO] Install helm"
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
rm /tmp/get_helm.sh


echo "[INFO] Install Inspec"
readonly INSPEC_VERSION="5.22.36"
curl -fsSL -o /tmp/inspec.deb "https://packages.chef.io/files/stable/inspec/$INSPEC_VERSION/ubuntu/20.04/inspec_$INSPEC_VERSION-1_amd64.deb"
sudo dpkg -i /tmp/inspec.deb
rm /tmp/inspec.deb
sudo apt-get install -y -f


echo "[INFO] Install k9s"
readonly K9S_VERSION="0.32.5"
curl -fsSL -o /tmp/k9s.deb https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/k9s_linux_amd64.deb
sudo apt-get install -y /tmp/k9s.deb
rm /tmp/k9s.deb


echo "[INFO] Install Ansible"
readonly UBUNTU_CODENAME=jammy
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt-get update
sudo apt-get install -y ansible


echo "[INFO] Clean up"
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*


echo "[INFO] Setup folders"
readonly base_dir="/opt/vm-ubuntu"
readonly folders=(
  "$base_dir"
  '/opt/vm-ubuntu/portainer'
)
for f in "${folders[@]}"; do
  sudo mkdir -p "$f"
done


echo "[INFO] Download minikube scripts from repository"
scripts=(
  'minikube-startup.sh'
  'minikube-shutdown.sh'
  'minikube-delete.sh'
  'minikube-dashboard.sh'
)
for s in "${scripts[@]}"; do
  sudo curl -fsSL -o "$base_dir/$s" "https://raw.githubusercontent.com/sommerfeld-io/vm-ubuntu/refs/heads/main/components/k8s/$s"
  sudo chmod 755 "$base_dir/$s"
done

echo "[INFO] Download Docker Compose config for Portainer from repository"
sudo curl -fsSL -o "$base_dir/portainer/docker-compose.yml" https://raw.githubusercontent.com/sommerfeld-io/vm-ubuntu/refs/heads/main/components/portainer/docker-compose.yml

echo "[INFO] Set permissions in $base_dir"
sudo chown -R "$(id -u):$(id -g)" "$base_dir"
sudo chmod -R 755 "$base_dir"
sudo chmod -x "$base_dir/portainer/docker-compose.yml"

echo "[INFO] ========================================================"
echo "[INFO] Maybe you still need to add the user to the docker group"
echo "[INFO]   sudo usermod -aG docker \$USER"
echo "[INFO]"
echo "[INFO] Documentation"
echo "[INFO]   https://sommerfeld-io.github.io/vm-ubuntu"
echo "[INFO] ========================================================"
