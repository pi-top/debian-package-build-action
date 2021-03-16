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
IFS=' ' read -ra LINTIAN_OPTS_ARR <<< "$LINTIAN_OPTS"
lintian "${LINTIAN_OPTS_ARR[@]}" | tee "${LINTIAN_LOG_FILE}"

if [[ "${DEBUG}" -eq 1 ]]; then
  lintian-info "${LINTIAN_LOG_FILE}"
fi

debug_echo "[check-deb] DONE!"
