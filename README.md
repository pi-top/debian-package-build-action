# pi-top Docker image for building pi-top Debian packages for Raspberry Pi

## How to use

### Enable experimental features on host machine
_(This only needs to be done once)_

```sh
echo -e "{\n  \"experimental\": true\n}" | sudo tee /etc/docker/daemon.json &> /dev/null
sudo service docker restart

```

### Start Docker container based on source code's architecture

The following snippet will use `amd64` for packages that do not require compilation, which will result in the fastest package building.
Packages that require compilation will be built in a container that is emulating ARM hardware (32 and 64 bit), which results in a slower build.
```sh
platforms=()
if [[ "$(grep "Architecture" debian/control | grep -v "all")" != "" ]]; then
  docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64

  platforms+=("linux/arm/v7")
  platforms+=("linux/arm64")
else
  platforms+=("linux/amd64")
fi

# Source files are in current directory
# Build files will be in /tmp
for platform in ${platforms[@]}; do
  docker run --rm \
    --platform=${platform} \
    --volume $(pwd):/src \
    --volume /tmp:/build \
#    -e BUILD=1 \
#    -e CHECK=1 \
#    -e LINTIAN_DONT_CHECK_PARTS="nmu" \
#    -e LINTIAN_TAGS_TO_SUPPRESS="debian-changelog-line-too-long" \
#    -e LINTIAN_FAIL_ON_ERROR=1 \
#    -e LINTIAN_FAIL_ON_WARNING=1 \
#    -e LINTIAN_OPTS="" \
#    -e DPKG_BUILDPACKAGE_OPTS="" \
    pitop/deb-build:latest
done
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
