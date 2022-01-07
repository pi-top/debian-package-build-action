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
  GPG_OPTIONS="--no-tty -v --pinentry-mode loopback --batch --passphrase='$SIGNING_PASSPHRASE'"

  debug_echo "Signing .changes file"
  dpkg-sig --sign builder --sign-changes full -k ${SIGNING_KEY_FINGERPRINT} --gpg-options ${GPG_OPTIONS} /build/*.changes

  debug_echo "Signing .deb files"
  dpkg-sig --sign builder -k "${SIGNING_KEY_FINGERPRINT}" -v --gpg-options ${GPG_OPTIONS} /build/*.deb
}

main
