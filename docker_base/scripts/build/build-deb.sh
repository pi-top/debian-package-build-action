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

source_package="$(cd /src && dpkg-parsechangelog --show-field Source)"
# Trim repack suffix and revision number
upstream_version="$(cd /src && dpkg-parsechangelog --show-field Version | cut -d'-' -f1 | cut -d'+' -f1)"
# Trim epoch version number
if [[ "${upstream_version}" == *":"* ]]; then
  upstream_version="$(echo ${upstream_version} | cut -d':' -f2)"
fi

tmp_dir_root=$(mktemp -d)

debug_echo "Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir_src="${tmp_dir_root}/${source_package}-${upstream_version}"
mkdir "${tmp_dir_src}"
cp -r /src/* "${tmp_dir_src}/"

debug_echo "Changing working directory to temporary directory..."
cd "${tmp_dir_src}"

debug_echo "DEBUG: Listing temporary directory contents BEFORE building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -la
fi

if ! grep -q "3.0 (native)" ./debian/source/format; then

  upstream_tarball_file="${source_package}_${upstream_version}.orig.tar.gz"

  debug_echo "Package is not native Debian package - creating tarball of source: ${upstream_tarball_file} ..."

  if [[ -f ./debian/watch ]]; then

    debug_echo "'debian/watch' found - using 'uscan' to create tarball..."
    uscan --download-current-version --verbose

    # Extract source files from upstream tarball
    tar xvf "../${upstream_tarball_file}" -C ../

  else

    debug_echo "'debian/watch' not found - using 'tar' to create tarball..."
    tar \
      --exclude-vcs \
      --exclude debian \
      --create --gzip \
      --verbose \
      --file="../${upstream_tarball_file}" \
      .

  fi
else
  debug_echo "Package is native Debian package - skipping tarball..."
fi

if [[ "${DPKG_BUILDPACKAGE_GPG_SIGN}" -eq 0 ]]; then
  DPKG_BUILDPACKAGE_OPTS="${DPKG_BUILDPACKAGE_OPTS} --no-sign"
fi

if [[ "${DPKG_BUILDPACKAGE_CHECK_BUILDDEPS}" -eq 0 ]]; then
  DPKG_BUILDPACKAGE_OPTS="${DPKG_BUILDPACKAGE_OPTS} --no-check-builddeps"
fi

if [[ "${DPKG_BUILDPACKAGE_POST_CLEAN}" -eq 1 ]]; then
  DPKG_BUILDPACKAGE_OPTS="${DPKG_BUILDPACKAGE_OPTS} --post-clean"
fi

debug_echo "DEBUG: print DPKG_BUILDPACKAGE_OPTS..."
debug_echo "${DPKG_BUILDPACKAGE_OPTS}"

if [[ -n "${SIGNING_KEY}" ]]; then
  debug_echo "Signing key found"

  KEY_PATH="/tmp/debsign.key"
  debug_echo "Writing signing key to file"
  echo "${SIGNING_KEY}" >"${KEY_PATH}"

  debug_echo "Importing signing key into keyring"
  gpg --import "${KEY_PATH}"

  debug_echo "Extracting key ID from signing key file"
  KEY_ID=$(gpg --with-colons --import-options show-only --import "${KEY_PATH}" | grep "^sec" | cut -d':' -f5)
  if [[ -n "${KEY_ID}" ]]; then
    debug_echo "Updating dpkg-buildpackage opts with signing key ID"
    DPKG_BUILDPACKAGE_OPTS="${DPKG_BUILDPACKAGE_OPTS} -k${KEY_ID}"
  else
    debug_echo "WARNING: Signing key has no valid ID"
  fi
fi

debug_echo "Parsing dpkg-buildpackage arguments..."
IFS=' ' read -ra DPKG_BUILDPACKAGE_OPTS_ARR <<<"$DPKG_BUILDPACKAGE_OPTS"

debug_echo "Building package..."
dpkg-buildpackage "${DPKG_BUILDPACKAGE_OPTS_ARR[@]}" | tee "${DPKG_BUILDPACKAGE_LOG_FILE}"

if [[ "${DEBUG}" -eq 1 ]]; then
  debug_echo "DEBUG: Listing temporary directory contents AFTER building..."
  ls -la
fi

debug_echo "Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
  if ! [ -d "$x" ]; then
    sudo mv -- "$x" /build
  fi
done

if [[ "${DEBUG}" -eq 1 ]]; then
  debug_echo "DEBUG: Listing /build directory contents..."
  ls -la /build
fi

debug_echo "DONE!"
