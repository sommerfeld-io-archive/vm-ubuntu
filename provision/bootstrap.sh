#!/bin/bash


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


function caption() {
    if [[ -z "${1:-}" ]]; then
      echo "[ERROR] ------------------------------------------------------------------------------"
      echo "[ERROR] No parameter passed to caption function"
      echo "[ERROR] ------------------------------------------------------------------------------"
      exit 1
    fi

    echo "[INFO] -------------------------------------------------------------------------------"
    echo "[INFO] $1"
    echo "[INFO] -------------------------------------------------------------------------------"
}


caption "Info"
echo "User     = $USER"
echo "Hostname = $HOSTNAME"
echo "Home dr  = $HOME"


caption "Update apt cache"
sudo apt-get update


caption "Install basics"
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y gnupg
sudo apt-get install -y lsb-release


caption "Install tools"
sudo apt-get install -y git
sudo apt-get install -y tilix


caption "Install docker"
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"
newgrp docker

caption "Docker version"
docker --version
docker compose --version

caption "Test docker"
docker run --rm hello-world:latest

caption "Git version"
git --version

caption "Manual leftovers"
echo "[INFO] Maybe you still need to add the user to the docker group"
echo "[INFO]   -->  sudo usermod -aG docker \$USER"