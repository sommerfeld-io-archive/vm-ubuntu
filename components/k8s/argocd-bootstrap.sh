#!/bin/bash
# @file argocd-bootstrap.sh
# @brief Bootstrap script to deploy ArgoCD and applications on minikube.
# @description
#   This script is used to deploy ArgoCD and applications on minikube. The installation of
#   minikube, helm, kubectl, etc is done by `bootstrap.sh`.
#
#   ArgoCD Autopilot is used to deploy ArgoCD itselt to the Kubernetes cluster. ArgoCD then deploys
#   the applications from the `XXXXXXXXXXXXXXXXXXXX` directory.
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



export GIT_REPO="https://github.com/sommerfeld-io/vm-ubuntu.git/components/k8s/manifests"
readonly ARGO_PROJECT="default-project"


echo -e "\e[33m"
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
echo -e "\e[0m"


echo "[INFO] === Github Token ========================================"
read -s -r -p "Enter Token: " GIT_TOKEN
export GIT_TOKEN
echo


echo "[INFO] === Environment ========================================"
echo "User     = $USER"
echo "Hostname = $HOSTNAME"
echo "Home dir = $HOME"
hostnamectl
echo "[INFO] === ArgoCD Autopilot version ==========================="
argocd-autopilot version
echo "Repo and path = $GIT_REPO"
echo "[INFO] ========================================================"

echo "[INFO] === Select Mode ========================================"
PS3='Please select the ation: '
readonly OPTION_BOOTSTRAP="bootstrap"
readonly OPTION_RECOVER="recover"
select opt in "$OPTION_BOOTSTRAP" "$OPTION_RECOVER"; do
  case $opt in
    "$OPTION_BOOTSTRAP")
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
      echo "[INFO] Recover ArgoCD"
      argocd-autopilot repo bootstrap --recover
      break
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
  esac
done


echo "[INFO] === Login =============================================="
echo "Execute the port forward command, and browse to"
echo "http://localhost:7900. You can log in with user: admin, and the"
echo "password from the previous step."
echo "  kubectl port-forward svc/argocd-server -n argocd 7900:80"
echo
echo "Get the password with:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o yaml"
echo "[INFO] ========================================================"
