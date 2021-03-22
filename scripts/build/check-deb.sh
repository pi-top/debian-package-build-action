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
    echo "[check-deb] $1"
  fi
}

debug_echo "Changing working directory to /build..."
cd /build

debug_echo "Checking for .changes file..."
changes_file="$(find . -name "*.changes" | head -n1)"
if [[ ! -f "${changes_file}" ]]; then
 echo "ERROR: No .changes file found."
 exit 1
fi

debug_echo "DEBUG: print LINTIAN_OPTS..."
debug_echo "${LINTIAN_OPTS}"

debug_echo "Parsing Lintian arguments..."
IFS=' ' read -ra LINTIAN_OPTS_ARR <<< "$LINTIAN_OPTS"

debug_echo "Running Lintian..."
lintian "${LINTIAN_OPTS_ARR[@]}" "${changes_file}" | tee "${LINTIAN_LOG_FILE}"

if [[ "${DEBUG}" -eq 1 ]]; then
  lintian-info "${LINTIAN_LOG_FILE}"
fi

debug_echo "DONE!"
