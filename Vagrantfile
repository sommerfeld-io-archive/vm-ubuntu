# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = "bento/ubuntu-24.04" # https://portal.cloud.hashicorp.com/vagrant/discover/bento/ubuntu-24.04
VM_HOSTNAME = "vm-ubuntu-vagrant"

Vagrant.configure("2") do |config|
  config.vm.box = BOX_NAME
  config.vm.hostname = VM_HOSTNAME

  config.vm.provider "virtualbox" do |v|
    v.memory = "4096"
    v.cpus = 2
    v.name = VM_HOSTNAME
  end

  config.vm.provision "shell", path: "components/provision/bootstrap.sh"
  config.vm.provision "shell", path: "components/provision/hardening.sh"
  config.vm.provision "shell", path: "components/provision/bootstrap-vagrant.sh", privileged: false

  # Fix permissions and ownership because bootstrap.sh is run as root
  config.vm.provision "shell", inline: "chown -R vagrant:vagrant /opt/vm-ubuntu"
  config.vm.provision "shell", inline: "chmod -R 755 /opt/vm-ubuntu"
  config.vm.provision "shell", inline: "chmod 644 /opt/vm-ubuntu/portainer/docker-compose.yml"

  # Overwrite files from remote repository with local files to allow for local development
  # This section copies the files from the local repository to the Vagrant box
  # The original files are also available in the Vagrant box in the /vagrant directory
  config.vm.provision "file", source: "components/k8s/minikube-startup.sh", destination: "/opt/vm-ubuntu/minikube-startup.sh"
  config.vm.provision "file", source: "components/k8s/minikube-shutdown.sh", destination: "/opt/vm-ubuntu/minikube-shutdown.sh"
  config.vm.provision "file", source: "components/k8s/minikube-delete.sh", destination: "/opt/vm-ubuntu/minikube-delete.sh"
  config.vm.provision "file", source: "components/k8s/minikube-delete.sh", destination: "/opt/vm-ubuntu/minikube-dashboard.sh"
  config.vm.provision "file", source: "components/k8s/argocd-bootstrap.sh", destination: "/opt/vm-ubuntu/argocd-bootstrap.sh"

  # Run inspec tests from script inside Vagrantbox
  config.vm.provision "shell", inline: "(cd /vagrant/components/test-compliance && ./run.sh)", privileged: false

  # Portainer from VM
  config.vm.network "forwarded_port", guest: 7990, host: 7990

  # ArgoCD from VM
  config.vm.network "forwarded_port", guest: 7900, host: 7900

  # minikube port range
  (7000..7080).each do |port|
    config.vm.network "forwarded_port", guest: port, host: port
  end
end
