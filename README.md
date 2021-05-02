# pi-top Docker-based Debian package builder

This repository builds pi-top's `deb-build` image, used across [pi-top's code base](https://github.com/pi-top/) to create Debian packages for Raspberry Pi.

### How to use

As a GitHub Action, start Docker container based on source code's architecture:
```
      - name: Build Debian package
        run: |
          platform="linux/amd64"
          if grep '^Architecture:' debian/control | grep -q -v 'all'; then
            echo "Package requires emulation - starting binfmt"
            docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
            platform="linux/arm/v7,linux/arm64"
          fi
          mkdir -p /tmp/artifacts/{src,bin}
          docker run --rm \
            --volume ${{ github.workspace }}:/src \
            --volume /tmp/artifacts/bin:/build \
            --platform="${platform}" \
            -e LINTIAN_TAGS_TO_SUPPRESS="debian-changelog-line-too-long,spelling-error-in-changelog,unreleased-changelog-distribution" \
            pitop/deb-build:latest
```

### Environment Variables

The following environment variables can be overriden to change the behaviour:

```sh
# Stages - boolean
DEBUG=0
INSTALL_BUILD_DEPS=1
BUILD=1
CHECK=1
# Build configuration
DPKG_BUILDPACKAGE_CHECK_BUILDDEPS=0
DPKG_BUILDPACKAGE_POST_CLEAN=0
# Quality check configuration - comma-separated lists
LINTIAN_DONT_CHECK_PARTS="nmu"
LINTIAN_TAGS_TO_SUPPRESS=""
# Quality check configuration - boolean
LINTIAN_DISPLAY_INFO=1
LINTIAN_SHOW_OVERRIDES=1
LINTIAN_TAG_DISPLAY_LIMIT=0
# LINTIAN_NO_FAIL overrides all others
LINTIAN_FAIL_ON_ERROR=1
LINTIAN_FAIL_ON_WARNING=1
LINTIAN_FAIL_ON_INFO=0
LINTIAN_FAIL_ON_PEDANTIC=0
LINTIAN_FAIL_ON_EXPERIMENTAL=0
LINTIAN_FAIL_ON_OVERRIDE=0
LINTIAN_NO_FAIL=0
# Additional options
DPKG_BUILDPACKAGE_OPTS=""
LINTIAN_OPTS=""
```

## Featured Repositories

[pi-top Python SDK](https://github.com/pi-top/pi-top-Python-SDK)
