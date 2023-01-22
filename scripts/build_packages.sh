#!/bin/sh

set -eu

# Adapted from pbuilder's support for cross-compilation:
if [ -n "$INPUT_HOST_ARCH" ]; then
	if [ -z "${CONFIG_SITE-}" ]; then
		export CONFIG_SITE="/etc/dpkg-cross/cross-config.$INPUT_HOST_ARCH"
	fi
	export DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:+$DEB_BUILD_OPTIONS }nocheck"
	export DEB_BUILD_PROFILES="${DEB_BUILD_PROFILES:+$DEB_BUILD_PROFILES }cross nocheck"
	INPUT_BUILDPACKAGE_OPTS="$INPUT_BUILDPACKAGE_OPTS --host-arch=$INPUT_HOST_ARCH"
fi

cd -- "$INPUT_SOURCE_DIR"

if [ "$INPUT_USE_DEBUILD" = "true" ]; then
	# shellcheck disable=SC2086
	debuild ${INPUT_DEBUILD_OPTS}
else
	# shellcheck disable=SC2086
	dpkg-buildpackage $INPUT_BUILDPACKAGE_OPTS
fi