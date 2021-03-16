#!/bin/bash
###############################################################
#                Unofficial 'Bash strict mode'                #
# http://redsymbol.net/articles/unofficial-bash-strict-mode/  #
###############################################################
set -euo pipefail
IFS=$'\n\t'
###############################################################


tmp_dir_root=$(mktemp -d)

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] Copying source files to temporary directory (${tmp_dir_root})..."
tmp_dir="${tmp_dir_root}/src"
mkdir "${tmp_dir}"
cp -r /src/* "${tmp_dir}/"

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] Changing working directory to temporary directory..."
cd "${tmp_dir}"

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] DEBUG: Listing temporary directory contents BEFORE building..."
[[ "${DEBUG}" -eq 1 ]] && ls -l

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] DEBUG: print DPKG_BUILDPACKAGE_OPTS..."
[[ "${DEBUG}" -eq 1 ]] && echo "${DPKG_BUILDPACKAGE_OPTS}"

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] Building package..."
dpkg-buildpackage ${DPKG_BUILDPACKAGE_OPTS}

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] DEBUG: Listing temporary directory contents AFTER building..."
[[ "${DEBUG}" -eq 1 ]] && ls -l

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] Moving build files to /build..."
for x in "${tmp_dir_root}/"*; do
   if ! [ -d "$x" ]; then
     sudo mv -- "$x" /build
   fi
done

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] DEBUG: Listing /build directory contents..."
[[ "${DEBUG}" -eq 1 ]] && ls -l /build

[[ "${DEBUG}" -eq 1 ]] && echo "[build-deb] DONE!"
