ARG DEBIAN_BASE_IMAGE=bullseye

FROM debian:$DEBIAN_BASE_IMAGE

ENV DEBIAN_BASE_IMAGE $DEBIAN_BASE_IMAGE

# Root of source code to build
VOLUME /src
# Location of output package build
VOLUME /build

# Copy build scripts
COPY scripts/build/install-deb-build-deps.sh /install-deb-build-deps
COPY scripts/build/build-deb.sh /build-deb
COPY scripts/build/check-deb.sh /check-deb
COPY scripts/build/entrypoint.sh /entrypoint

#########################
# Environment variables #
#########################
# Add extra printing
ENV DEBUG=1

# Disable build stages by overriding these environment variables to 0
ENV INSTALL_BUILD_DEPS=1
ENV BUILD=1
ENV CHECK=1

# Optional log files
ENV BUILD_DEP_INSTALL_LOG_FILE="/dev/null"
ENV DPKG_BUILDPACKAGE_LOG_FILE="/dev/null"
ENV LINTIAN_LOG_FILE="/tmp/lintian.log"

# dpkg-buildpackage configuration
# TODO: add signing support
ENV DPKG_BUILDPACKAGE_GPG_SIGN=0
ENV DPKG_BUILDPACKAGE_CHECK_BUILDDEPS=0
ENV DPKG_BUILDPACKAGE_POST_CLEAN=0
# Manpage: https://manpages.debian.org/$DEBIAN_BASE_IMAGE/dpkg-dev/dpkg-buildpackage.1.en.html
# Space-separated arguments
ENV DPKG_BUILDPACKAGE_OPTS=""

# lintian configuration
# Comma-separated
ENV LINTIAN_DONT_CHECK_PARTS="nmu"
ENV LINTIAN_TAGS_TO_SUPPRESS="initial-upload-closes-no-bugs,debian-watch-file-is-missing"
# Boolean
ENV LINTIAN_DISPLAY_INFO=1
ENV LINTIAN_SHOW_OVERRIDES=1
ENV LINTIAN_TAG_DISPLAY_LIMIT=0
ENV LINTIAN_FAIL_ON_ERROR=1
ENV LINTIAN_FAIL_ON_WARNING=1
ENV LINTIAN_FAIL_ON_INFO=0
ENV LINTIAN_FAIL_ON_PEDANTIC=0
ENV LINTIAN_FAIL_ON_EXPERIMENTAL=0
ENV LINTIAN_FAIL_ON_OVERRIDE=0
ENV LINTIAN_NO_FAIL=0
# Manpage: https://manpages.debian.org/$DEBIAN_BASE_IMAGE/lintian/lintian.1.en.html
# Space-separated
ENV LINTIAN_OPTS=""

# ~ Debian
ENV DH_VERBOSE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV DPKG_COLORS=always
ENV FORCE_UNSAFE_CONFIGURE=1

# Install dev packages
COPY  scripts/setup/install-dev-packages.sh /.install-dev-packages
RUN /.install-dev-packages

# Disabled so that builds will be faster for testing

# Install Node.js from Nodesource
#COPY  scripts/setup/install-nodejs-from-nodesource.sh /.install-nodejs-from-nodesource
#RUN /.install-nodejs-from-nodesource

# Install build dependency packages
#COPY  scripts/setup/install-deb-build-deps.sh /.install-deb-build-deps
#RUN /.install-deb-build-deps

# Add a user with userid 1000 and name nonroot
RUN useradd --create-home -u 1000 nonroot

# Configure sudo for nonroot
COPY  sudoers.txt /etc/sudoers
RUN chmod 440 /etc/sudoers

# Run container as nonroot
USER nonroot
