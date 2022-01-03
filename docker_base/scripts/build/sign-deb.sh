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
  SIGNING_KEY_FINGERPRINT=$(${NO_TTY_GPG_COMMAND} --with-colons --show-keys "${signing_key_path}" | grep "^fpr" | cut -d':' -f10 | head -n1)

  rm "${signing_key_path}"

  if [[ -z "${SIGNING_KEY_FINGERPRINT}" ]]; then
    return
  fi

  debug_echo "Key ID: ${SIGNING_KEY_FINGERPRINT}"

  debsign -p${NO_TTY_GPG_COMMAND} -k${SIGNING_KEY_FINGERPRINT} /build/*.changes
  debsigs --sign=origin -k${SIGNING_KEY_FINGERPRINT} -v /build/*.deb
}

main
