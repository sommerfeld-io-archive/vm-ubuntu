#!/bin/bash
# @file hardening.sh
# @brief ..
# @description
#   This script is designed to harden the system by applying security best practices. The goal is
#   to comply with the <https://github.com/dev-sec/linux-baseline> InSpec profile.

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


target="/etc/login.defs"
echo "[INFO] Update $target"
declare -A replacements=(
    # ["old"]="new"
    ["UMASK		022"]="UMASK		027"
    ["PASS_MAX_DAYS	99999"]="PASS_MAX_DAYS	60"
    ["PASS_MIN_DAYS	0"]="PASS_MIN_DAYS	7"
    ["UMASK		022"]="UMASK		027"
    ["UMASK		022"]="UMASK		027"
    ["UMASK		022"]="UMASK		027"
)
for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    sudo sed -i "s/$old/$new/" "$target"
done
