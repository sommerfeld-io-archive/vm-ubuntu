#!/bin/bash
# @file minikube-startup.sh
# @brief Start minikube and enable addons.
# @description
#   This script starts minikube and enables the addons metrics-server, dashboard and ingress. The
#   script starts minikube differently depending on whether it is running in a Vagrantbox or not.
#
#   ## Usage
#   The script accepts a flag "--nodes" to specify the number of nodes to start. The default is 1.
#
#   ```bash
#   ./minikube-startup.sh
#   ./minikube-startup.sh --nodes 3
#   ```


NODES=1
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        "--nodes") NODES="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
readonly NODES


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


echo "[INFO] ========================================================"
echo "[INFO] Running as user $USER"
hostnamectl
echo "[INFO] ========================================================"
echo "[INFO] Documentation"
echo "[INFO]   https://sommerfeld-io.github.io/vm-ubuntu"
echo "[INFO] ========================================================"

IS_VAGRANT=false
if [ "$USER" = "vagrant" ]; then
  IS_VAGRANT=true
fi
readonly IS_VAGRANT


echo "[INFO] Start minikube with $NODES nodes"
if [ "$IS_VAGRANT" = true ]; then
  echo "[INFO] with additional configuration for Vagrantbox"
  minikube start --nodes "$NODES" --extra-config=apiserver.service-node-port-range=7000-7080 --extra-config=apiserver.bind-address=0.0.0.0
else
  minikube start --nodes "$NODES"
fi

echo "[INFO] Enable addons"
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable ingress
