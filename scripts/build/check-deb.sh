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

debug_echo "[check-deb] Changing working directory to /build..."
cd /build

debug_echo "[check-deb] DEBUG: print LINTIAN_OPTS..."
debug_echo "${LINTIAN_OPTS}"

debug_echo "[check-deb] Running Lintian..."
lintian ${LINTIAN_OPTS} | tee "${LINTIAN_LOG_FILE:-/dev/null}"

debug_echo "[check-deb] DONE!"
