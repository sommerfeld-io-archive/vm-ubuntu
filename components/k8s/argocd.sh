#!/bin/bash
# @file argocd.sh
# @brief Bootstrap script to deploy ArgoCD and applications on minikube.
# @description
#   This script is used to deploy ArgoCD and applications on minikube. The installation of
#   minikube, helm, kubectl, etc is done by `bootstrap.sh`.
#
#   ArgoCD Autopilot is used to deploy ArgoCD itselt to the Kubernetes cluster. ArgoCD then deploys
#   the applications from the `components/k8s/manifests` directory.
#
#   Minikube must be up-and-running for argocd-autopilot to work. The minikube API server must be
#   reachable. The script will fail if minikube is not running.
#
#   **WARNING:** Only bootstrap ArgoCD, when there are no manifests in the repository
#   (`components/k8s/manifests`)! Bootstrapping will fail if there are already manifests in the
#   repository. This is intended to be run only once. If you want to deploy argocd and
#   applications, to a new  cluster based on existing configuration (e.g. after you  deleted the
#   minikube cluster), use the `recover` option instead.

# shellcheck disable=SC1091

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


readonly Y="\e[33m"
readonly D="\e[0m"

export GIT_REPO="https://github.com/sommerfeld-io/vm-ubuntu.git/components/k8s/manifests"
readonly ARGO_PROJECT="default-project"
readonly ARGO_PORT=7900


echo -e "$Y"
echo "[WARN] ========================================================="
echo "[WARN] Only bootstrap ArgoCD, when there are no manifests in the"
echo "[WARN] repository (components/k8s/manifests)!"
echo "[WARN]"
echo "[WARN] Bootstrapping will fail if there are already manifests in"
echo "[WARN] the repository. This is intended to be run only once."
echo "[WARN]"
echo "[WARN] If you want to deploy argocd and applications, to a new"
echo "[WARN] cluster based on existing configuration (e.g. after you"
echo "[WARN] deleted the minikube cluster), use the recover option"
echo "[WARN] instead."
echo "[WARN] ========================================================="
echo -e "$D"


function enterToken() {
  echo "[INFO] === Github Token ========================================"
  read -s -r -p "Enter Token: " GIT_TOKEN
  export GIT_TOKEN
  echo
}


echo "[INFO] === Environment ========================================"
echo "User     = $USER"
echo "Hostname = $HOSTNAME"
echo "Home dir = $HOME"
hostnamectl
echo "[INFO] === ArgoCD Autopilot version ==========================="
argocd-autopilot version
echo "Repo and path = $GIT_REPO"
echo "[INFO] ========================================================"
echo "[INFO] Documentation"
echo "[INFO]   https://sommerfeld-io.github.io/vm-ubuntu"
echo "[INFO] ========================================================"


PS3='Please select the ation: '
readonly OPTION_BOOTSTRAP="bootstrap"
readonly OPTION_RECOVER="recover"
readonly OPTION_PORT_FORWARD="access-argocd"

select opt in "$OPTION_BOOTSTRAP" "$OPTION_RECOVER" "$OPTION_PORT_FORWARD"; do
  case $opt in
    "$OPTION_BOOTSTRAP")
      enterToken

      echo "[INFO] Bootstrap ArgoCD"
      argocd-autopilot repo bootstrap

      echo "[INFO] Create Project"
      argocd-autopilot project create "$ARGO_PROJECT"

      echo "[INFO] Create Application"
      argocd-autopilot app create hello-world \
        --app github.com/argoproj-labs/argocd-autopilot/examples/demo-app \
        -p "$ARGO_PROJECT" \
        --wait-timeout 2m0s
      break
      ;;
    "$OPTION_RECOVER")
      enterToken

      echo "[INFO] Recover ArgoCD"
      argocd-autopilot repo bootstrap --recover
      break
      ;;
    "$OPTION_PORT_FORWARD")
      echo "[INFO] === Access ArgoCD ======================================"
      echo -e "[INFO] Default Username = ${Y}admin${D}"
      password=$(minikube kubectl -- -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
      echo -e "[INFO] Default Password = ${Y}${password}${D}"
      echo "[INFO]"
      echo "[INFO] Remember to establish an SSH tunnel before accessing the"
      echo "[INFO] ArgoCD UI through the browser"
      echo "[INFO]   vagrant ssh -- -L $ARGO_PORT:localhost:$ARGO_PORT"
      echo "[INFO]"
      echo "[INFO] Some browsers might block the connection, because the"
      echo "[INFO] certificate is self-signed."
      echo "[INFO]"
      echo "[INFO] Executing the port forward command ..."
      echo -e "[INFO] Browse to ${Y}https://localhost:$ARGO_PORT${D}"
      echo
      minikube kubectl -- port-forward svc/argocd-server -n argocd "$ARGO_PORT:443"
      break
      ;;
    *)
      echo "[ERROR] Invalid option, choose again ..."
      ;;
  esac
done
