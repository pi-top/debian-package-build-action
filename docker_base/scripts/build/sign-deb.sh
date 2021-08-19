#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################

# HARDCORE DEBUGGING
if [[ "${DEBUG}" -eq 1 ]]; then
  set -x
fi

debug_echo() {
  if [[ "${DEBUG}" -eq 1 ]]; then
    echo "[build-deb] $1"
  fi
}

main() {
  signing_key_path="/tmp/debsign.key"
  debug_echo "Writing signing key to ${signing_key_path}"
  echo "${SIGNING_KEY}" >"${signing_key_path}"

  debug_echo "Importing signing key into keyring"
  ${NO_TTY_GPG_COMMAND} --import "${signing_key_path}"

  debug_echo "Extracting key ID from signing key file"
  KEY_ID=$(${NO_TTY_GPG_COMMAND} --with-colons --show-keys "${signing_key_path}" | grep "^ssb" | head -n1 | cut -d':' -f5 | grep -o '.\{8\}$')

  rm "${signing_key_path}"

  if [[ -z "${KEY_ID}" ]]; then
    return
  fi

  debug_echo "Key ID: ${KEY_ID}"

  debsign -p${NO_TTY_GPG_COMMAND} -k${KEY_ID} /build/*.changes
}

main
