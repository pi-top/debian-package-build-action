#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


[[ "${DEBUG}" -eq 1 ]] && echo "[check-deb] Changing working directory to /build..."
cd /build

[[ "${DEBUG}" -eq 1 ]] && echo "[check-deb] DEBUG: print LINTIAN_OPTS..."
[[ "${DEBUG}" -eq 1 ]] && echo "${LINTIAN_OPTS}"

[[ "${DEBUG}" -eq 1 ]] && echo "[check-deb] Running Lintian..."
lintian ${LINTIAN_OPTS}

[[ "${DEBUG}" -eq 1 ]] && echo "[check-deb] DONE!"
