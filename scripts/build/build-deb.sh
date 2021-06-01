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

tmp_dir_root=$(mktemp -d)

debug_echo "Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir_src="${tmp_dir_root}/src"
mkdir "${tmp_dir_src}"
cp -r /src/* "${tmp_dir_src}/"

debug_echo "Changing working directory to temporary directory..."
cd "${tmp_dir_src}"

debug_echo "DEBUG: Listing temporary directory contents BEFORE building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -la
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

debug_echo "Parsing dpkg-buildpackage arguments..."
IFS=' ' read -ra DPKG_BUILDPACKAGE_OPTS_ARR <<<"$DPKG_BUILDPACKAGE_OPTS"

if ! grep -q "3.0 (native)" ./debian/source/format; then

  source_package="$(dpkg-parsechangelog --show-field Source)"
  upstream_version="$(dpkg-parsechangelog --show-field Version | cut -d'-' -f1)"

  if [[ "${upstream_version}" == *":"* ]]; then
    upstream_version="$(echo ${upstream_version} | cut -d':' -f2)"
  fi

  upstream_tarball_file="${source_package}_${upstream_version}.orig.tar.gz"

  debug_echo "Package is not native Debian package - creating tarball of source: ${upstream_tarball_file} ..."

  if [[ -f ./debian/watch ]]; then

    debug_echo "'debian/watch' found - using 'uscan' to create tarball..."
    uscan --download-current-version --verbose

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

debug_echo "Building package..."
dpkg-buildpackage "${DPKG_BUILDPACKAGE_OPTS_ARR[@]}" | tee "${DPKG_BUILDPACKAGE_LOG_FILE}"

debug_echo "DEBUG: Listing temporary directory contents AFTER building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -la
fi

debug_echo "Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
  if ! [ -d "$x" ]; then
    sudo mv -- "$x" /build
  fi
done

debug_echo "DEBUG: Listing /build directory contents..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -la /build
fi

debug_echo "DONE!"
