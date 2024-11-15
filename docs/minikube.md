# Run minikube

[minikube](https://minikube.sigs.k8s.io) is a tool that simplifies running Kubernetes clusters locally. It allows developers to set up a single-node Kubernetes cluster on their local workstation, which is useful for development, testing, and learning purposes. minikube supports various hypervisors (like VirtualBox, KVM, Hyper-V) and container runtimes (like Docker, Podman, containerd, and CRI-O). By providing a local Kubernetes environment, minikube helps developers emulate the behavior of a production cluster, enabling them to test Kubernetes applications in a controlled, local setup before deploying them to a larger, more complex cluster.

[Helm](https://helm.sh) is a package manager for Kubernetes, designed to streamline the deployment, management, and scaling of applications on Kubernetes clusters. It uses "charts",which are packages of pre-configured Kubernetes resources, to define, install, and upgrade Kubernetes applications. Helm helps automate the deployment process, manage dependencies, and simplify updates and rollbacks, making it easier to manage  Kubernetes applications consistently and reproducibly.

## Prerequisites

minikube requires a virtualization software to run. The default hypervisor is `docker` which is used in this setup.

minikube ships with a `kubectl` binary to interact with the minikube cluster. Keep in mind, that the bootstrap script creates a `kubectl` alias which points to `minikube kubectl` so this might conflict with other `kubectl` installations.

## Interact with minikube

The bootstrap script downloads the `components/k8s/minikube-*.sh` scripts from this repo into `/opt/vm-ubuntu`. The scripts are utilities to start / stop / delete minikube with some default settings. minikube startup is slightly different depending on whether it is running in a Vagrantbox or not.

### Running inside a Vagrantbox

minikube binds itself to `127.0.0.1` (which represents the localhost from inside the Vagrantbox, not from the host). Requests from the host to the VM are not possible unless the `apiserver.bind-address` is changed.

Make sure the Vagrantbox forwards all needed ports to the host.

```bash
# Startup inside Vagrantbox
minikube start --extra-config=apiserver.service-node-port-range=7000-7080 --extra-config=apiserver.bind-address=0.0.0.0

# Expose the minikube dashboard on specified port and without opening the browser
minikube dashboard --port 7999 --url
```

Since the dashboard (despite setting the bind address) still only answers to requests from inside the Vagrantbox, you need an SSH tunnel to the dashboard inside the Vagrantbox.

```bash
vagrant ssh -- -L 7999:localhost:7999
```

`7999` is the port on the host which tunnels to `localhost:7999` inside the Vagrantbox. The port on the host must be a free port, so it cannot be part of the NodePort range.

### Cluster with multiple nodes

The `minikube-startup.sh` script accepts a flag `--nodes` to specify the number of nodes to start. The default is 1.

Minikube determines the control plane and worker nodes based on the number of nodes. The control plane is always the first node, and the worker nodes are the rest. The control plane node is the node where the Kubernetes API server is running. The worker nodes are the nodes where the application workloads are scheduled.

```bash
/opt/vm-ubuntu/minikube-startup.sh
/opt/vm-ubuntu/minikube-startup.sh --nodes 3
```

When you want to change the number of nodes in the minikube cluster, you need to delete the existing cluster and start a new one with the desired number of nodes. Simply stopping and starting the cluster with another number of nodes does not work.

#### HAProxy

*TODO ...* Lorem ipsum dolor sit amet, consectetur adipiscing elit.

*TODO ...* Ditaa / Plantuml diagram

### Increasing the NodePort range

By default, minikube exposes ports `30000-32767`. If this does not work for you, you can adjust the range by using: `minikube start --extra-config=apiserver.service-node-port-range=1024-65535`

### k9s

To interact with the cluster, you can use the [`k9s` cli tool](https://k9scli.io) (which is installed through the bootstrap script). It is a terminal-based UI to interact with your Kubernetes clusters. It allows you to navigate and manage your Kubernetes clusters with ease.

### Example commands

Some example commands to interact with minikube (which are also used by the scripts):

```bash
minikube version
minikube status
helm version

# Startup
minikube start

# Shutdown
minikube stop

# Destroy
minikube delete

# Enable addons
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable ingress

# Expose the minikube dashboard
minikube dashboard

# List pods from all namespaces
kubectl -- get po -A

# List services from all namespaces
minikube service list # --namespace apps
```

## Argo CD

[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes. Deployment is done by [Argo-CD Autopilot](https://argocd-autopilot.readthedocs.io/en/stable/). The autopilot bootstrap command will deploy an Argo CD manifest to a target K8s cluster and will commit an Argo CD Application manifest under a specific directory in your GitOps repository. This Application will manage the Argo CD installation itself - so after running this command, you will have an Argo CD deployment that manages itself through GitOps.

The `components/k8s/argocd.sh` script handles bootstrapping Argo CD into this repository (which is only done once). The script also allows to forward the Argo CD port to access th Argo CD UI through a browser. When you deleted your minikube cluster, the script allows to recover the Argo CD instance based in the existing configs from this repo into a fresh minikube instance. The scripts offers an interactive prompt to choose your action.

Remember to establish an SSH tunnel before accessing the ArgoCD UI through the browser.

```bash
# Tunnel the Argo CD port
vagrant ssh -- -L 7900:localhost:7900

# Tunnel the Argo CD port and the Dashboard port
vagrant ssh -- -L 7900:localhost:7900 -L 7999:localhost:7999
```

Then browse to <https://localhost:7900>. Some browsers might block the connection, because the certificate is self-signed.
