#!/bin/bash
# @file bootstrap-vagrant.sh
# @brief Provisioning script for the Vagrant user.
# @description
#   This script is used to provision the Vagrant user. It is not executed as root. The script sets
#   up the bash prompt and writes some aliases.


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


readonly bashrc="$HOME/.bashrc"


echo "[INFO] === Environment ========================================"
echo "[INFO] Running as user $USER"
hostnamectl
echo "[INFO] ========================================================"


echo "[INFO] Update bash prompt"
promptDefinition="\${debian_chroot:+(\$debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ "
grep -qxF "export PS1='${promptDefinition}'" "$bashrc" || echo "export PS1='${promptDefinition}'" >>"$bashrc"


echo "[INFO] Write bash aliases"
readonly aliases=(
  'alias ll="ls -alFh --color=auto"'
  'alias ls="ls -a --color=auto"'
  'alias grep="grep --color=auto"'
  'alias kubectl="minikube kubectl --"'
)
for alias in "${aliases[@]}"; do
  grep -qxF "$alias" "$bashrc" || echo "$alias" >> "$bashrc"
done
