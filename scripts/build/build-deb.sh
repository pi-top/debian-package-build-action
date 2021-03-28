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
tmp_dir="${tmp_dir_root}/src"
mkdir "${tmp_dir}"
cp -r /src/* "${tmp_dir}/"

debug_echo "Changing working directory to temporary directory..."
cd "${tmp_dir}"

debug_echo "DEBUG: Listing temporary directory contents BEFORE building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l
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
IFS=' ' read -ra DPKG_BUILDPACKAGE_OPTS_ARR <<< "$DPKG_BUILDPACKAGE_OPTS"

version="$(head -n1 debian/changelog | awk '{print $2}' | cut -d'-' -f1 | sed "s/(//g" | sed "s/)//g")"
if [[ "${version}" == *"-"* ]]; then
  debug_echo "Package is Debian revision of upstream - creating tarball of source..."

  source_package="$(head -n1 debian/changelog | awk '{print $1}')"
  upstream_version="$(echo "${version}" | cut -d'-' -f1)"
  tar \
    --exclude-vcs \
    --exclude ./debian \
    -cvzf "/build/${source_package}_${upstream_version}.orig.tar.gz" \
    -C /src \
    ./
else
  debug_echo "Package is not Debian revision of upstream - skipping tarball..."
fi

debug_echo "Building package..."
dpkg-buildpackage "${DPKG_BUILDPACKAGE_OPTS_ARR[@]}" | tee "${DPKG_BUILDPACKAGE_LOG_FILE}"

debug_echo "DEBUG: Listing temporary directory contents AFTER building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l
fi

debug_echo "Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     sudo mv -- "$x" /build
   fi
done

debug_echo "DEBUG: Listing /build directory contents..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l /build
fi

debug_echo "DONE!"
