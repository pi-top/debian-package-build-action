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
    echo "[Entrypoint] $1"
  fi
}

if [[ "${INSTALL_BUILD_DEPS}" -eq 1 ]]; then
    debug_echo "'INSTALL_BUILD_DEPS' set to 1 - installing build dependencies..."
    /install-deb-build-deps
else
    debug_echo "'INSTALL_BUILD_DEPS' is not set to 1 - skipping build..."
fi

# ----

if [[ "${BUILD}" -eq 1 ]]; then
    debug_echo "'BUILD' set to 1 - building..."
    /build-deb
else
    debug_echo "'BUILD' is not set to 1 - skipping build..."
fi

# ----

if [[ "${CHECK}" -eq 1 ]]; then
    debug_echo "'CHECK' set to 1 - checking..."
    /check-deb
else
    debug_echo "'CHECK' is not set to 1 - skipping check..."
fi

