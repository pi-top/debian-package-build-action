#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


debug_echo() {
  [[ "${DEBUG}" -eq 1 ]] && echo "$1"
}

tmp_dir_root=$(mktemp -d)

debug_echo "[build-deb] Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir="${tmp_dir_root}/src"
mkdir "${tmp_dir}"
cp -r /src/* "${tmp_dir}/"

debug_echo "[build-deb] Changing working directory to temporary directory..."
cd "${tmp_dir}"

debug_echo "[build-deb] DEBUG: Listing temporary directory contents BEFORE building..."
[[ "${DEBUG}" -eq 1 ]] && ls -l

debug_echo "[build-deb] DEBUG: print DPKG_BUILDPACKAGE_OPTS..."
debug_echo "${DPKG_BUILDPACKAGE_OPTS}"

debug_echo "[build-deb] Building package..."
dpkg-buildpackage ${DPKG_BUILDPACKAGE_OPTS} | tee "${DPKG_BUILDPACKAGE_LOG_FILE:-/dev/null}"

debug_echo "[build-deb] DEBUG: Listing temporary directory contents AFTER building..."
[[ "${DEBUG}" -eq 1 ]] && ls -l

debug_echo "[build-deb] Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     sudo mv -- "$x" /build
   fi
done

debug_echo "[build-deb] DEBUG: Listing /build directory contents..."
[[ "${DEBUG}" -eq 1 ]] && ls -l /build

debug_echo "[build-deb] DONE!"
