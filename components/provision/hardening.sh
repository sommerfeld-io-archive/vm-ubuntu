#!/bin/bash
# @file hardening.sh
# @brief Harden the system by applying security best practices.
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


target="/etc/modprobe.d/dev-sec.conf"
echo "[INFO] Update $target"
sudo rm -f "$target"
declare -a settings=(
    "install cramfs /bin/true"
    "install freevxfs /bin/true"
    "install jffs2 /bin/true"
    "install hfs /bin/true"
    "install hfsplus /bin/true"
    "install udf /bin/true"
    "install vfat /bin/true"
)
for setting in "${settings[@]}"; do
    echo "$setting" | sudo tee -a "$target"
done
sudo chmod 644 "$target"

echo "[INFO] Update cron permissions"
declare -a cron_config=(
    "/etc/cron.d"
    "/etc/crontab"
    "/etc/cron.hourly"
    "/etc/cron.daily"
    "/etc/cron.weekly"
    "/etc/cron.monthly"
)
for cfg in "${cron_config[@]}"; do
    sudo chmod 711 "$cfg"
done
