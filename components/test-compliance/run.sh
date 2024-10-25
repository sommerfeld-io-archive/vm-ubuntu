#!/bin/bash
# @file run.sh
# @brief Run InSpec tests.
# @description
#   This script runs the audit tests defined in the InSpec profile to check if the setup is as
#   intended.


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


echo "[INFO] ========================================================"
echo "[INFO] Running as user $USER"
hostnamectl
echo "[INFO] ========================================================"
echo "[INFO] Inspec version"
inspec --version
echo "[INFO] ========================================================"
echo "[INFO] Documentation"
echo "[INFO]   https://sommerfeld-io.github.io/vm-ubuntu"
echo "[INFO] ========================================================"


PROFILES=(
  'vm-ubuntu'
  'https://github.com/dev-sec/linux-baseline'
)
for profile in "${PROFILES[@]}"; do
  echo "[INFO] Validate profile $profile"
  inspec check "$profile" --chef-license=accept-no-persist

  echo "[INFO] Run profile $profile"
  inspec exec "$profile" --chef-license=accept-no-persist
done
