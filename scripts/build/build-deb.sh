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
    echo "$1"
  fi
}

tmp_dir_root=$(mktemp -d)

debug_echo "[build-deb] Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir="${tmp_dir_root}/src"
mkdir "${tmp_dir}"
cp -r /src/* "${tmp_dir}/"

debug_echo "[build-deb] Changing working directory to temporary directory..."
cd "${tmp_dir}"

debug_echo "[build-deb] DEBUG: Listing temporary directory contents BEFORE building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l
fi

debug_echo "[build-deb] DEBUG: print DPKG_BUILDPACKAGE_OPTS..."
debug_echo "${DPKG_BUILDPACKAGE_OPTS}"

debug_echo "[check-deb] Parsing dpkg-buildpackage arguments..."
IFS=' ' read -ra DPKG_BUILDPACKAGE_OPTS_ARR <<< "$DPKG_BUILDPACKAGE_OPTS"

debug_echo "[build-deb] Building package..."
dpkg-buildpackage "${DPKG_BUILDPACKAGE_OPTS_ARR[@]}" | tee "${DPKG_BUILDPACKAGE_LOG_FILE}"

debug_echo "[build-deb] DEBUG: Listing temporary directory contents AFTER building..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l
fi

debug_echo "[build-deb] Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     sudo mv -- "$x" /build
   fi
done

debug_echo "[build-deb] DEBUG: Listing /build directory contents..."
if [[ "${DEBUG}" -eq 1 ]]; then
  ls -l /build
fi

debug_echo "[build-deb] DONE!"
