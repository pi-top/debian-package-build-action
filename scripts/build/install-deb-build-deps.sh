#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


[[ "${DEBUG}" -eq 1 ]] && echo "[install-build-dep] Updating package list..."
[[ "${DEBUG}" -eq 1 ]] && sudo apt-get update

[[ "${DEBUG}" -eq 1 ]] && echo "[install-build-dep] Installing build dependencies..."
sudo apt-get build-dep -y .
