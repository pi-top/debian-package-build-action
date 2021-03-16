#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


if [[ "${INSTALL_BUILD_DEPS}" -eq 1 ]]; then
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'INSTALL_BUILD_DEPS' set to 1 - installing build dependencies..."
    /install-deb-build-deps
else
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'INSTALL_BUILD_DEPS' is not set to 1 - skipping build..."
fi

# ----

if [[ "${BUILD}" -eq 1 ]]; then
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'BUILD' set to 1 - building..."
    /build-deb
else
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'BUILD' is not set to 1 - skipping build..."
fi

# ----

if [[ "${CHECK}" -eq 1 ]]; then
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'CHECK' set to 1 - checking..."
    /check-deb
else
    [[ "${DEBUG}" -eq 1 ]] && echo "[Entrypoint] 'CHECK' is not set to 1 - skipping check..."
fi

