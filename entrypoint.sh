#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


if [[ "${BUILD}" -eq 1 ]]; then
    echo "[Entrypoint] 'BUILD' set to 1 - building..."
    /build-deb
else
    echo "[Entrypoint] 'BUILD' is not set to 1 - skipping build..."
fi

# ----

if [[ "${CHECK}" -eq 1 ]]; then
    echo "[Entrypoint] 'CHECK' set to 1 - checking..."
    /check-deb
else
    echo "[Entrypoint] 'CHECK' is not set to 1 - skipping check..."
fi

