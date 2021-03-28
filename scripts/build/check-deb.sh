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

if [[ "${LINTIAN_NO_FAIL}" -eq 0 ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on none"
  if [[ "${LINTIAN_FAIL_ON_ERROR}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on error"
  fi
  if [[ "${LINTIAN_FAIL_ON_WARNING}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on warning"
  fi
  if [[ "${LINTIAN_FAIL_ON_INFO}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on info"
  fi
  if [[ "${LINTIAN_FAIL_ON_PEDANTIC}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on pedantic"
  fi
  if [[ "${LINTIAN_FAIL_ON_EXPERIMENTAL}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on experimental"
  fi
  if [[ "${LINTIAN_FAIL_ON_OVERRIDE}" -eq 1 ]]; then
    LINTIAN_OPTS="${LINTIAN_OPTS} --fail-on override"
  fi
fi

LINTIAN_TAG_DISPLAY_LIMIT=0
if [[ "${LINTIAN_DISPLAY_INFO}" -eq 1 ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --display-info"
fi

if [[ "${LINTIAN_SHOW_OVERRIDES}" -eq 1 ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --show-overrides"
fi

if [[ "${LINTIAN_SHOW_OVERRIDES}" -eq 1 ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --show-overrides"
fi

if [[ -n "${LINTIAN_DONT_CHECK_PARTS}" ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --dont-check-part ${LINTIAN_DONT_CHECK_PARTS}"
fi

if [[ -n "${LINTIAN_TAGS_TO_SUPPRESS}" ]]; then
  LINTIAN_OPTS="${LINTIAN_OPTS} --suppress-tags ${LINTIAN_TAGS_TO_SUPPRESS}"
fi

LINTIAN_OPTS="${LINTIAN_OPTS} --tag-display-limit=${LINTIAN_TAG_DISPLAY_LIMIT}"

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
