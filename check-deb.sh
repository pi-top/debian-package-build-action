#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

echo "[check-deb] Changing working directory to /build..."
cd /build

echo "[check-deb] DEBUG: print LINTIAN_OPTS..."
echo "${LINTIAN_OPTS}"

echo "[check-deb] Running Lintian..."
lintian ${LINTIAN_OPTS}

echo "[check-deb] DONE!"
