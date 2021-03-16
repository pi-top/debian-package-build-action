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

if [[ "${INSTALL_BUILD_DEPS}" -eq 1 ]]; then
    debug_echo "[Entrypoint] 'INSTALL_BUILD_DEPS' set to 1 - installing build dependencies..."
    /install-deb-build-deps
else
    debug_echo "[Entrypoint] 'INSTALL_BUILD_DEPS' is not set to 1 - skipping build..."
fi

# ----

if [[ "${BUILD}" -eq 1 ]]; then
    debug_echo "[Entrypoint] 'BUILD' set to 1 - building..."
    /build-deb
else
    debug_echo "[Entrypoint] 'BUILD' is not set to 1 - skipping build..."
fi

# ----

if [[ "${CHECK}" -eq 1 ]]; then
    debug_echo "[Entrypoint] 'CHECK' set to 1 - checking..."
    /check-deb
else
    debug_echo "[Entrypoint] 'CHECK' is not set to 1 - skipping check..."
fi

