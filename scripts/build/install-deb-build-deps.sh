#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


debug_echo() {
  if [[ "${DEBUG}" -eq 1 ]]; then
    echo "$1"
  fi
}

debug_echo "[install-build-dep] Updating package list..."
if [[ "${DEBUG}" -eq 1 ]]; then
  sudo apt-get update
else
  sudo apt-get update &> /dev/null
fi

debug_echo "[install-build-dep] Installing build dependencies..."
sudo apt-get build-dep -y /src | tee "${BUILD_DEP_INSTALL_LOG_FILE}"
