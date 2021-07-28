# Docker-based Debian package build Github Action

Build a Debian package for a target architecture.
See `action.yml` for how to use.

## Example

### Select Correct Target Architecture To Build A Package for ARM (e.g. Raspberry Pi)
If `debian/control` has its `Architecture:` field set to `all`, then it does not
require any architecture-specific features of the host machine. This means that
`amd64` should be used. In all other cases, `armhf` should be used.


```
      - name: Determine architecture to use from package info
        run: |
          target_architecture=amd64
          if grep '^Architecture:' debian/control | grep -q -v 'all'; then
            target_architecture=armhf
          fi
          echo "TARGET_ARCHITECTURE=${target_architecture}" >> $GITHUB_ENV

      - name: Build Debian package
        uses: pi-top/debian-package-build-action@master
        with:
          target_architecture: ${{ env.TARGET_ARCHITECTURE }}
          docker_image: debian:stable
          build_directory: artifacts

      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: deb
          path: artifacts/*.deb
```

In addition to this action, this repository contains the Dockerfile and associated scripts
for creating a custom base Docker image for pi-topOS builds.
This contains additional repositories, Node.JS v16, and some pre-installed build dependencies used for pi-topOS packages for speed.
