#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


debug_echo() {
  [[ "${DEBUG}" -eq 1 ]] && echo "$1"
}

debug_echo "[install-build-dep] Updating package list..."
[[ "${DEBUG}" -eq 1 ]] && sudo apt-get update

debug_echo "[install-build-dep] Installing build dependencies..."
sudo apt-get build-dep -y . | tee "${BUILD_DEP_INSTALL_LOG_FILE:-/dev/null}"
